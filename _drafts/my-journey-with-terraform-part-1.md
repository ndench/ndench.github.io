---
title: My Journey with Terraform - Part 1 - Dipping my toes in
categories: terraform
tags: terraform devops
---

A couple of years ago, I heard about a tool called Terraform. Our devops guy from work had just started using it and 
said it was pretty great. For me, that triggered a long and steady process where I started to use Terraform more and
more until now I couldn't even imagine myself doing devops without it. Recently, I've been telling people how great
Terraform is and how much they should use. I'm generally met with skepticism, they've heard how powerful Terraform is,
and that makes them wary. Everyone who's ever managed any IT infrastructure knows how fragile and finiky can be, which
makes them understandably cautious about automating the lot of it into a single bash command that has the power to 
bring your entire business to a halt if someone accidentally runs `terraform destroy`.

So I've decided to write a series of blog posts detailing the journey I've taken while learning Terraform. How I went
from being quite scared and lost, to going all in and Terraforming my world. This is the first post in which I'll go 
over the first time I used Terraform and the "Aha moment" I had which drove to deeper into devops.


## Why I love it

Initially I was scared of Terraform, it's code was hard to read and understand, and I could accidentally take down 
the entire business if I wasn't careful. However, using the AWS console I was able to accidentally take down parts of
our application anyway, and those parts of the infrastructure often had outdated documentation if any existed at all.

I've come to love Terraform for many reasons:

- Infrastructure is stored in git
    - Code reviews for changes
    - Easily view the history
    - Roll back to a working version
- Documentation
    - Every option is documented
    - Always up to date
- Automation
    - One command, go get a coffee
    - Don't have to copy paste ARN ids all over the place
- Education
    - Much easier to teach you colleagues how your infrastructure holds together


## My first experience

We had just hired a security company to do our first penetration test. We couldn't have them messing around on 
produciton, so I was tasked with creating them a testing environment. After some nudging and a little help from another
dev who had been using Terraform recently, I managed to create a web instance with a domain name. All the 
configuration was stored in git. Below is an example of what I did (sorry about the lack of syntax highlighting):

```hcl
# main.tf

# We're using AWS in Sydney
provider "aws" {
  region = "ap-southeast-2"
}

# Create an EC2 instance
resource "aws_instance" "pen_testing" {
  # I created an AMI from our staging instance, 
  # which had mysql, redis, nginx and PHP installed
  ami = "ami-xxxxxxxx" 

  # The size of the instance I want
  instance_type = "t2.nano"

  # Name of my key pair that already exists
  key_name = "my-key.pem"

  # The subnet I want the instance in
  subnet_id = "subnet-xxxxxxxxxxx"

  # Give it the default security group, so it can talk to the load balancer
  vpc_security_group_ids = ["sg-xxxxxx"]

  # Give 100GB disk space
  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }

  # Make sure it has a name, so I can identify it
  tags {
    Name = "PenTesting"
  }
}

# Create a DNS record pointing to the instance
resource "aws_route53_record" "pen_testing" {
  # Where hosted zone
  zone_id = "xxxxxxxx"

  # The URL to register
  name = "testing.example.com"
  type = "A"
  ttl  = 60

  # Point the domain name at the instance we created above
  records = ["${aws_instance.pen_testing.public_ip}"]
}
```

After running `terraform apply`, I saw a nice output detailing what Terraform wanted to do. I typed `yes` and watched 
the magic. A couple minutes later, I had an instance with a domain name. I thought "yeah that's not bad, I could have 
done that like 5 times faster with the AWS console though". But that was fine, I had learnt a few things about 
Terraform:

- It's not like real code - you declare what state you want and Terraform finds a way to make it happen (or throws 
    an error)
    - Unlike PHP I was used to writing, which is literally a set of steps I want the computer to take
- Terraform stores the current state of the infrastructure in a `terraform.tfstate` file
    - I committed this state file to git so that I didn't lose it
    - There are better ways of managing state which I'll get into in a later post, but committing it is fine for now
- Terraform resources have types and names
    - The type is what you want to create, ie. `aws_instance`
    - The name is like a variable name, and allows you to refer to in else where, ie. `pen_testing`
- Multiple resources can have the same name - as long as they're different resources
- Resources are references with this notation:
    ```hcl
    # "${type.name.attribute}"
    "${aws_instance.pen_testing.public_ip}"
    ```
    - type is the instance type
    - name is the name you gave it
    - attribute is what you want to reference in the resource, ie. `public_ip`

It was at this point that I realised, I can't give penetration testers a site that's not behind HTTPS, so I challenged
myself to put the instance behind a load balancer with our HTTPS certificate:

```hcl
# main.tf
...

# Update my existing Route53 record to point to the 
# load balancer created below
resource "aws_route53_record" "pen_testing" {
  zone_id = "xxxxxxxx"
  name    = "testing.example.com"

  # The load balancer has a dns name, not an IP address
  # so we need CNAME
  type    = "CNAME"
  ttl     = 60

  # Use the load balancer dns name instead of the instance IP address
  records = ["${aws_lb.pen_testing.dns_name}"]
}

# Create the load balancer
resource "aws_lb" "pen_testing" {
  name = "pen-testing"
  load_balancer_type = "application"

  # Give it a web security group, which allows HTTP and HTTPS traffic
  security_groups = ["sg-xxxxxxx"]

  # Put the load balancer in subnets across 
  # multiple AZ's to increase stability
  subnets = ["subnet-xxxx", "subnet-xxxx"]
}

# Create a target group to hold the instance
resource "aws_lb_target_group" {
  name = "pen-testing"

  # The port/protocol to forward traffic to/with
  port     = 80
  protocol = "HTTP"

  # Our VPC which contains the subnets above
  vpc_id = "vpc-xxxxx"
}

# Add my instance to the target group
resouce "aws_target_group_attachment" "pen_testing" {
  # The target group to attach to
  target_group_arn = "${aws_lb_target_group.pen_testing.arn}"

  # The instance to attach
  target_id = "${aws_instance.pen_testing.id}"
}

# Create a listener for the load balancer
resource "aws_lb_listener" "pen_testing" {
  # The load balancer this listener is for
  load_balancer_arn = "${aws_lb.pen_testing.arn}"

  # The port/protocol we are accepting connections on/with
  port     = 443
  protocol = "HTTPS"

  # Our HTTPS certificate that covers testing.example.com
  certificate_arn = "arn:aws:iam::xxxxx:server-certificate/xxxxx"

  # Where we should forward traffic to
  default_action {
    # Our target group, which will send the traffic to the instance
    target_gorup_arn = "${aws_lb_target_group.pen_testing.arn}"
    type             = "forward"
  }
}
```

At this point, I was a little impressed. The Terraform documentation was pretty great, and I was staring to get the 
hang of the language. I still felt like could have done it faster in the console, but this was pretty quick and meant
I didn't have be clicking through AWS wizards all afternoon. However, I still wasn't entirely sold on Terraform until
months later.


## My "Aha moment"

A couple of months later, we had fixed our first round of bugs raised by the penetration testers. So they were going
back through the app to verify the problems were solved. However, they contacted me to say that the instance wasn't
working anymore, they were getting 504's.

I jumped onto the instance and had a look around - but I couldn't find what was wrong, it just wouldn't load. I ended 
up deciding just to recreate it. I went back to my Terraform code and wasn't sure what to do. After some googling, I 
ran `terraform destroy`, which will destroy all the resources that Terraform knows about. In 2 minutes the instance,
load balancer and Route53 record were all gone. I then ran `terraform apply`, and a few minutes later they were all
created again, and everything working!

This literally saved me hours of debugging and tweaking config files, and was the first time I truly understood the 
mentality of "don't fix it, just throw it away" that comes with ephemeral infrastructure. I still wasn't set on getting
Terraform to manage everything, but I was convinced that I should be using it more.


## Conclusion

You don't have to start a new project and use Terraform from the ground up. You can slowy add more to you existing
infrastructure and even migrate your handbuilt stuff into Terraform (more on this in a later post). Terraform reminds
me a little bit of git, in the fact that it only cares about the stuff you tell it to. Git won't store a file you 
haven't told it to track yet - although it does complain that you're not tracking it. Terraform will only manage the
resources that it knows about, so you can run it alongside your handcrafted resources and there won't be a problem 
(as long as you don't go making changes to Terraform resources through the console).

I hope I've peaked your interest in Terraform, please leave a comment letting me know anything specific you'd like
me to cover in future posts. This series will cover pretty much every "Aha moment" I've had, and what makes me refuse
to make any infrastructure changes by "clicking on shit in the console".

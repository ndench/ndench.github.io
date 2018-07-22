---
title: My Journey with Terraform - Part 1 - Dipping my toes in
categories: terraform
tags: terraform devops
---

A couple of years ago, I heard about a tool called Terraform. Our devops guy from work had just started using it and 
said it was pretty great. For me, that triggered a long and steady process where I started to use Terraform more and
more until now I couldn't even imagine myself doing devops without it. Recently, I've been telling people how great
Terraform is and how much they should use. I'm generally met with skepticism, they've heard how powerful Terraform is,
and that makes them wary. Everyone who's ever managed any IT infrastructure knows how fragile and finicky can be, which
makes them understandably cautious about automating the lot of it into a single bash command that has the power to 
bring your entire business to a halt if someone accidentally runs `terraform destroy`.

So I've decided to write a series of blog posts detailing the journey I've taken while learning Terraform. How I went
from being quite scared and lost, to going all in and Terraforming my world. This is the first post in which I'll go 
over the first time I used Terraform and the "Aha moment" I had which drove me to deeper into devops.


## Why I love it

Initially I was scared of Terraform - it's code was hard to read and understand, and I could accidentally take down 
the entire business if I wasn't careful. However, using the AWS Console I was able to accidentally take down parts of
our application anyway, and those parts of the infrastructure had outdated, if an, documentation.

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
    - Much easier to teach your colleagues how your infrastructure holds together


## My first experience

We had just hired a security company to do our first penetration test. We couldn't have them messing around on 
produciton, so I was tasked with creating them a testing environment. After some nudging and a little help from another
dev who had been using Terraform recently, I managed to create a web instance with a domain name. All the 
configuration was stored in git. Below is an example of what I did:

{% gist 471a7a3dba8c2da5ee1eb424db095876 %}

After running `terraform apply`, I saw a nice output detailing what Terraform wanted to do. I typed `yes` and watched 
the magic. A couple minutes later, I had an instance with a domain name. I thought "yeah that's not bad, I could have 
done that like 5 times faster with the AWS Console though". But that was fine, I had learnt a few things about 
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
- Multiple resources can have the same name - as long as they're of different types
    - Two `aws_instance`'s cannot have the same name
    - An `aws_instance` and `aws_route53_record` can have the same name
- Resources are referenced with the notation `"${type.name.attribute}"`, ie. `"${aws_instance.pen_testing.public_ip}"`
    - type is the instance type
    - name is the name you gave it
    - attribute is what you want to reference in the resource, ie. `public_ip`

It was at this point that I realised, I can't give penetration testers a site that's not behind HTTPS, so I challenged
myself to put the instance behind a load balancer with our HTTPS certificate:

{% gist 53fdd121247f05f5574d37bd78788bec %}

At this point, I was a little impressed. The Terraform documentation was pretty great, and I was staring to get the 
hang of the language. I still felt like could have done it faster in the Console, but this was pretty quick and meant
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

You don't have to start a new project and use Terraform from the ground up. You can slowly add more to you existing
infrastructure and even migrate your handbuilt stuff into Terraform (more on this in a later post). Terraform reminds
me a little bit of git, in the fact that it only cares about the stuff you tell it to. Git won't store a file you 
haven't told it to track yet - although it does complain that you're not tracking it. Terraform will only manage the
resources that it knows about, so you can run it alongside your handcrafted resources and there won't be a problem 
(as long as you don't go making changes to Terraform resources through the Console).

I hope I've peaked your interest in Terraform, please leave a comment letting me know anything specific you'd like
me to cover in future posts. This series will cover pretty much every "Aha moment" I've had, and what makes me refuse
to make any infrastructure changes by "clicking on shit in the Console".

<!-- Override default table style to show gists better -->
<style>
.gist table tr {
    background-color: #fff;
}

.gist table td {
    border: none;
}
</style>


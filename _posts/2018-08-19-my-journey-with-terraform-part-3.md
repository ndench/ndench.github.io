---
title: My Journey with Terraform - Part 3 - Infrastructure as code
categories: terraform
tags: terraform devops
---

Over time I've learnt a lot about Terraform and using it to manage infrastructure. Most of the
knowledge I have today has come through trial and error, and a constant desire to always do 
everything a little bit better than last time. Understanding the value in Terraform can be a long
journey, one that a lot of people just don't take. Especially when you can easily click around the
AWS Console and have what you need in half an hour or so, when it would take you days or weeks to
gain enough understanding in Terraform to accomplish the same thing. They aim of this blog series
is to share how I went through that journey so that you can get through it faster and see the light
at the end of the Terraform Tunnel<sup>TM</sup>. This is part 3 in the series, you can read
[part 2 here]({% post_url 2018-08-05-my-journey-with-terraform-part-2 %}).


## Where I was at

By this time I had a solid hatred for doing anything manually, especially with infrastructure. I
had seen the value in infrastructure as code in that it's easily repeatable and servers as up to
date documentation for when I come back to it months later, or when someone else needs to make 
changes. Once I had a handle on it, it also dramatically sped up the process of creating new 
servers, removing stress and human errors.


## What's next?

Around the start of the year, I left my old job to join a start-up as one of two technical 
co-founders. It became my job to create and manage our infrastructure and I was determined to do
it well. I needed to automate as much of it as possible, because with only two devs, we had a lot
of work ahead of us to build a killer product. We couldn't afford to be wasting time manually doing
the same things over and over.


## Step 1: The dev environment

While I can't use Terraform to manage our local dev environments, I can still automate it as much
as possible. I used Packer and Ansible to create and provision Vagrant boxes that were ready to go.
It only took a day or two to get them working using public Ansible roles available on the Galaxy.
This worked out really well, because all a dev needs now is the vagrant box and access the GitHub
repo, one `vagrant up` command and they have a fully fledged environment with data fixtures, and 
if something breaks `vagrant destroy -f && vagrant up` and a few minutes later everything is good
to go again.


## Step 2: Remote backend

Until now, I had been storing the Terraform state in the git repo. Which works fine if there's
only one dev working on it. But one thing you definitely do not want is merge conflicts in you
state files. If two people are applying changes at the same time, they'll end up destroying each
others work and not understanding what's happening.

So I decided to set up a remote backend for Terraform. It was much easier than I expected:

- Create a Dynamo DB table
- Create an S3 bucket
- Tell Terraform to use Dynamo and S3

So when Terraform runs, it uses the Dynamo table to lock the state so that no one else can
make changes at the same time. Then it stores all the state in S3, so that everyone gets
up to date state. I still don't recommend having two people making changes at the same time,
because you'll still destroy each others resources, but at least you prevent conflicts.


## Step 3: Create all the things

Now I was creating our staging infrastructure in Terraform, a lot of which I hadn't 
even created by hand before. So I got confused and lost very easily. The Terraform documentation
is very detailed, but to understand it you need to understand how AWS does things too, and the AWS
documentation can sometimes be very lacking. I ended up following a process which made everything
much easier:

1. Manually create a resource by hand, for example an RDS instance
2. Take note of all the settings and options
3. Manually test that it works how I wanted it to
4. For any settings I didn't understand, I changed them and tested again until I understood what they do
5. Create the same resource in Terraform
6. Compare the two resources side by side in the AWS Console and tweak things until they're the same
7. Delete the manual instance

This may seem like a lot of work, but keep in mind that even if you weren't using Terraform you would
still be doing at least the first three steps, and probably the fourth as well. Once you understand
how it's all working, creating the same resource in Terraform is very quick.

There was only a handful of things that I created by hand and didn't do in Terraform:

- The S3 bucket, it was so quick to do in the Console that I forgot about Terraforming it
- The Route 53 zone, it was also very quick in the Console so I didn't worry about it
- The HTTPS certificate, it required me to update DNS records for verification and I didn't realise
    that Terraform could do that. I later found out that it can and it's amazing.

Apart from those things, the entire rest of the app was in Terraform. In the next post I'll talk about
how I imported those resources into Terraform without destroying and re-creating them.


## The hard parts

The biggest problem I had was the long feedback loop. I'm used to writing code, refreshing the page or
running tests and knowing if it worked or not. Whereas sometimes Terraform will take a few minutes or
half an our to do some things like creating an RDS instance. The other thing that is really slow is 
building AMI's, Packer has to create a new EC2 instance, run Ansible against it, then create an AMI
and destroy the instance. All this waiting around was hard, so I started finding ways to speed it up.

Unfortunately I couldn't find a way to speed Terraform up, but I did drastically speed up my workflow
when building AMI's. By having a second Packer config which builds a Vagrant box, I can then run the box
locally and quickly reprovision it with any changes I need to make to Ansible. I can even pass flags to
Ansible to skip running roles that I didn't change. This alone is what saved my sanity. This is also the
reason I still stick with Ansible instead of running Bash scripts. I can run the same Ansible script 
100 times and it'll make changes that it needs to. In otherwords, it's idempotent. A Bash script on
the other hand needs to be run on a clean instance every time, so if you have an error at the end
of your script, you either wait for the entire script to run after you make a hange, or you comment
our the rest of you script, which just gets annoying.


## The great parts

It took me a little over a week to get our dev and staging environments up and running (we didn't need
production yet becase we didn't have users). After that, I pretty much completely ignored all the 
Terraform stuff for months while we were building the product. It just kept running and chugging away,
we never had a problem with it.

A month or so after it was up and running, we wanted to get some metrics and reporting on the servers.
So our other dev, Tom, took it upon himself to create a Grafana instance with a load balancer and it's
own database. He had never used Terraform before, and had barely touched the AWS Console either. But with
precious little help from me, he was able to get it all up and running, mainly from reading what I had 
done previously. The only problem we had was with different Terraform versions installed because we're
on different operating systems.

The other great part was when I came back to it months later to create our production infrastrucure.
While I had forgotten a lot, it all came rushing back when I went through the code. But I'll talk more
about or production infrastructure in a later post.


## Conclusion

By this time, I had quit a lot of HCL code lying around. A lot of it was copy pasta and there was so much
of it that it sometimes took a while to find what I was looking for. This is when I started digging into
Terraform modules, which are a great way of structuring your code into reusable components and also using
publicly available 3rd party modules so that you don't have to do it yourself. How I refactored my HCL
to use modules will form part of the next post in the series. Suffice it to say, that even though I had
come across some problems with my DevOps workflow, I was in love with Terraform by this point, and was
hell bent on using it for everything.

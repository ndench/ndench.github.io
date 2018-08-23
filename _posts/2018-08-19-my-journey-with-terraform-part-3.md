--- 
title: My Journey with Terraform - Part 3 - Infrastructure as code
categories: terraform 
tags: terraform devops 
---

Over time I've learnt a lot about Terraform and using it to manage
infrastructure. Most of the knowledge I have today has come through trial and
error, and a constant desire to always do everything a little bit better than
last time. Understanding the value in Terraform can be a long journey, one that
a lot of people just don't take. Especially when you can easily click around
the AWS Console and have what you need in half an hour or so, when it would
take you days or weeks to gain enough understanding in Terraform to accomplish
the same thing. 


The aim of this blog series is to share how I went through that journey so that
you can get through it faster and see the light at the end of the Terraform
Tunnel<sup>TM</sup>. This is part 3 in the series, you can read [part 2
here]({% post_url 2018-08-05-my-journey-with-terraform-part-2 %}).


## Where I was at

By this time I had a solid hatred for doing anything manually, especially with
infrastructure. I had seen the value in infrastructure as code:

* it's easily repeatable
* it serves as up to date documentation
* it dramatically sped up the process of creating new servers
* decreases stress and human errors

## What's next?

Around the start of the year, I left my old job to join a start-up as one of
two technical co-founders. It became my job to create and manage our
infrastructure and I was determined to do it well. I needed to automate as much
of it as possible -  between the two of us devs, we had a lot of work ahead of
us to build a killer product. We couldn't afford to waste time manually 
re-creating infrastructure or rebuilding servers.

### Step 1: The dev environment

While I can't use Terraform to manage our local dev environments, I can still
automate it as much as possible. I used Packer and Ansible to create and
provision Vagrant boxes that were ready to go.  It only took a day or two to
get them working using public Ansible roles available on the Galaxy.

This worked out really well - all a new developer needs to do is:

* clone the GitHub repo,
* download our prebuilt Vagrant box from S3
* run `vagrant up`

A few minutes later and they are ready to go with a fully fledged development
environment pre-loaded with sample data fixtures. If something breaks, or the
developer wants to completely reset their environment, running `vagrant destroy
-f && vagrant up` will always bring things back to a working state.

### Step 2: Remote backend

Terraform needs to know the current state of the resources it manages before
it's able to make changes. It uses this state to create plans and make changes
to the infrastructure.

Until now, I had been storing the Terraform state in the git repo as a
`terraform.tfstate` file. This works fine if there's only one dev working on it
but if two people are applying changes at the same time, Terraform won't know
about the other persons changes and there will be conflicts. Then you'll end
up with merge conflicts in the state file, which is not something you want.

Terraform recommends setting up a remote backend, which was much easier than
I expected:

- Create a Dynamo DB table
- Create an S3 bucket
- Tell Terraform to use Dynamo and S3

Now when Terraform runs, it uses the Dynamo table to lock the state so that no
one else can make changes at the same time. Then it stores all the state in S3,
so that everyone gets up to date state. You still run into problems when two
people are making changes at the same time:

1. Alice creates `resourceA` - adding it to the remote state
2. Once the `terraform apply` command has finished, Alice has released the state lock
2. Bob tries to create `resourceB`
    1. Terraform pulls down the remote state and learns about `resourceA`
    2. Bob's local code doesn't have any configuration for `resourceA`
    3. Terraform thinks Bob wants to delete `resourceA`

This is much better because Bob will know that someone has created `resourceA`
and can wait until Alice has merged her branch before continuing. Without remote
state, Bob could apply his changes then be confronted with merge conflicts in his
`terraform.tfstate` file when trying to merge his code with Alice's.

### Step 3: Create all the things

Now I was creating our staging infrastructure in Terraform, a lot of which I
hadn't even created by hand before. So I got confused and lost very easily. The
Terraform documentation is very detailed, but to understand it you need to
understand how AWS does things too, and the AWS documentation can sometimes be
very lacking. I ended up following a process which made everything much easier:

1. Manually create a resource by hand, for example an RDS instance
2. Take note of all the settings and options
3. Manually test that it works how I wanted it to
4. For any settings I didn't understand, I changed them and tested again until
I understood what they do
5. Create the same resource in Terraform
6. Compare the two resources side by side in the AWS Console and tweak things
until they're the same
7. Delete the manual instance

This may seem like a lot of work, but keep in mind that even if you weren't
using Terraform you would still be doing at least the first three steps, and
probably the fourth as well. Once you understand how it's all working, creating
the same resource in Terraform is very quick.

There was only a handful of things that I created by hand and didn't do in
Terraform:

- The S3 bucket, it was so quick to do in the Console that I forgot about
  Terraforming it
- The Route 53 zone, it was also very quick in the Console so I didn't worry
  about it
- The HTTPS certificate, it required me to update DNS records for verification
  and I didn't realise that Terraform could do that. I later found out that it
can and it's amazing.

With the exception of these resources, the rest of the application environment
(EC2, load balancers, etc.) was created and managed with Terraform. In the next
post I'll talk about how I imported those resources into Terraform without
destroying and re-creating them.


## The hard parts

The biggest problem I had was the long feedback loop. I'm used to writing code,
refreshing the page or running tests and knowing if it worked or not. Whereas
sometimes Terraform will take a few minutes or half an our to do some things
like creating an RDS instance. Likewise to build AMI's, Packer has to create a
new EC2 instance, run Ansible against it, then create an AMI and destroy the
instance.  All of this waiting around was hard, so I started finding ways to
speed it up.

Unfortunately I couldn't find a way to speed Terraform up as this is largely
limited by the time AWS takes to provision resources - RDS instances take quite
some time. I drastically sped up my workflow when building AMI's by having a
second Packer config which builds a Vagrant box, I can then run the box locally
and quickly reprovision it with any changes I need to make to Ansible. I can
even pass flags to Ansible to skip running roles that I didn't change. This
alone is what saved my sanity. 

This is the reason I still stick with Ansible instead of running Bash scripts.
Ansible is idempotent - I can run the same Ansible script 100 times and it'll
make changes that it needs to. A Bash script on the other hand needs to be run
on a clean instance every time, so if you have an error at the end of your
script, you either wait for the entire script to run after you make a change,
or you comment our the rest of you script, which is slow, error prone and
downright annoying.


## The great parts

It took me a little over a week to get our dev and staging environments up and
running (we didn't need production yet because we didn't have users). After
that, I completely ignored all the Terraform stuff for months while we were
building the product. It just kept running and chugging away, we never had a
problem with it.

A month or so after it was up and running, we wanted to get some metrics and
reporting on the servers.  So our other dev, Tom, took it upon himself to
create a [Grafana](https://grafana.com/) instance with a load balancer and it's
own database. He had never used Terraform before, and had barely touched the
AWS Console either. With precious little help from me, Tom was able to get it
all up and running, mainly from reading what I had done previously. 

The other great part was when I came back to it months later to create our
production infrastrucure.  While I had forgotten a lot, it all came rushing
back when I went through the code. As the staging infrastructure was
represented as code, I was able to copy paste and refactor the code to
duplicate it for a new environment. But I'll talk more about or production
infrastructure in a later post.


## Conclusion

By this time, I had quit a lot of HCL code laying around (the language
Terraform `.tf` files are written in). A lot of it was copy pasta and there was
so much of it that it sometimes took a while to find what I was looking for.
This is when I started digging into Terraform modules, which are a great way of
structuring your code into reusable components and also using publicly
available 3rd party modules so that you don't have to do it yourself. 

How I refactored my HCL to use modules will form part of the next post in the
series.  Suffice it to say, that even though I had come across some problems
with my DevOps workflow, I was in love with Terraform by this point, and was
hell bent on using it for everything.

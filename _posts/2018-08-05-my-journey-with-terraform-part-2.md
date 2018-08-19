---
title: My Journey with Terraform - Part 2 - Script the hard parts
categories: terraform
tags: terraform devops
---

This is part 2 in my series about how I learned Terraform. In each part I'll go over new things I 
learned and how Terraform convinced me to never create infrastructure by hand again. You can read
[part 1 here]({% post_url 2018-07-22-my-journey-with-terraform-part-1 %}).


## Where I was at

By this time I had played with Terraform and created a web app with a single instance behind a load
balancer. In terms of our infrastructure at work, we were managing our VPC's with Terraform, but 
everything else was manual (ie. S3 buckets, databases, redis, web instances, etc). However, we were
using Packer to build custom AMI's, so it was pretty easy to bring up new instances by hand. The 
business had grown and our clients were starting to question our disaster recovery ability. There
was only one dev who understood how our infrastructure held together and it would take him a few 
hours to re-create the entire stack if something went down. 

## What's next?

We decided to run disaster recovery scenarios to ensure that everyone in the team would be able 
to re-create production in less than two hours if we needed to. In order to do this, we needed 
much more documentation and scripting to remove the manual error-prone parts.


### Step 1: Build it by hand

That Friday we all got in a room and created a duplicate of production without using any Terraform
scripts. The only scripting we used was Packer and bash to re-build our AMI's, and that was only
because they were fairly simple to understand. In order to learn Terraform, you first must 
understand how to do everything manually. It took us 6 hours in total, not counting the hour break
we took from lunch. While this was much longer than our 2 hour goal, we all had an understanding
of how AWS works and what our app requires to run in production.

The most important thing was we noted down every single thing that we did. Any command we ran,
it's output, everything we clicked on in AWS (including screenshots), everything we talked about
and every decision we made. It seemed excessive at the time, but it proved invaluable later.

One issue we ran into quite a lot was human errors. We would often put a typo in a bash command
or when creating a VPC. Sometimes we would notice straight away but other times it took us 
an hour or more to track down the issue (when we used an incorrect IP address to set up an
Elasticsearch cluster).

The goal was to script a lot of it before our next disaster recovery scenario next month, this
would speed up our time and reduce errors.


### Step 2: Build the scripts

Over the next month I spent a few hours a week updating our Terraform scripts to automatically
create instances, load balancers and Route 53 records. I updated our bash scripts that built the
AMI's to prevent us having to run so many commands manually on the instances, and anything
that couldn't be baked into the AMI directly was scripted with Ansible, including deployments.
We didn't care about CI/CD for our disaster recovery, we just wanted it up and running.


### Step 3: The next scenario

Next month had come around, and it was time to beat our 6 hour time. In order to properly test
my Terraform and Ansible scripts, I sat in the corner and tried to have as little input as possible.
I gave my documentation to the team and they had a crack. Of course, it wasn't perfect. But every
question they asked pointed out a flaw either in my scripts or my docs, so everything improved
dramatically in that session. 

We ended up getting our time down to 3 hours, which is a 50% improvement and also included time
to teach the team how to use Terraform, as the majority of them hadn't even seen it before. We
also had a bunch more things we thought of to script and improve on for next time, we were 
confident we could crack 2 hours next month.


### Step 4: Eat, Sleep, Terraform, Repeat

Over the next few months we continued to improve the scripts and our disaster recovery process,
our best time was 1 hour and 40 minutes. By this point the only thing we were doing manually 
was creating the database from a backup, and updating variables in Ansible to point to different 
IP addresses. We also had every single person in the team able to confidently bring up an production 
environment in less than 2 hours by following some fairly robust documentation, this inclued our iOS 
developer who had never even touched the backend or any infrastructure before, and also a brand new 
employee who completed the scenario on her first week at the company.


## Conclusion

The best thing I took away from this was that Terraform makes it so easy for anyone to pick up
and learn your infrastructure. Everything is already documented in Terraform code, everytime
we scripted something, we could delete hundreds of lines from our manual documentation and replace 
it with a few dot points about how to run the script. Using Terraform might seem scary at first, 
but it's a lot less scary than manually clicking around the AWS Console which makes it incredibly 
hard to undo a mistake because you might forget what you changed. If you break something with 
Terraform, you can easily see what's changed and fix it in a few minutes.

Another incredibly valuable part of Terraform is reduction of human errors. During a disaster, we 
know that we'll make typos and miss thing due to the high stress situation. By removing humans from
the recovery process, it is much less stressful.

By this point Terraform had cemented itself a place in my heart, and my hatred of manually building
infrastructure had stated to grow. However I still wasn't 100% confident in my ability and was
unaware of how to migrate existing resources into Terraform.

In the next part I'll talk about when I started my new job and decided that our entire production
infrastructure had to be managed with Terraform.

**Update**: See [part 3 here]({% post_url 2018-08-19-my-journey-with-terraform-part-3 %}).

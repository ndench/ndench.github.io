---
title: My Journey with Terraform - Part 3 - Gaining confidence
categories: terraform
tags: terraform devops
---

- short intro
- use terraform to create new app for issue tracking
    - decided not to build ami's, instead to provision clean machines
        - I didn't understand packer
        - liked being able to reprovision running machines
        - too slow to constantly build new ami's
    - built VPC
    - create instances
    - run ansible
    - same ansible scripts run against vagrant box
    - didn't use terraform to do database, s3 or dns
- noticed terraform modules, but they scared me
- problems
    - takes too long to provision a new instance
    - too slow to provision vagrant box
    - issues when multiple devs are doing shit at the same time
- conclusion
    - allowed me to get up and running very quickly 
        - (copy pasted a lot of terraform code I'd written before)
    - pretty sold on terraform by this point

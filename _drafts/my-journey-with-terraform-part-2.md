---
title: My Journey with Terraform - Part 2 - Script the hard parts
categories: terraform
tags: terraform devops
---

- short intro
- use terraform to model entire DR scenario
    - started by doing it by hand, took ~6 hours
    - documented and scripted what we could
- terraform
    - create vpc (the hardest and most error prone part)
    - build AMI with packer and bash scripts
    - fire up instances
    - manually re-create databases from backups
    - manually assign domain name
    - get entire app back up and running in under 2 hours
    - with a simple wiki page, anyone in the team could do it
- it's easier to build something new starting with terraform, but you can
    migrate existing infra across (later post)
- conclusion
    - is so much faster and less error prone than manually clicking on things
    - I'm convinced terraform has a solid place in our infrastructure
    - still dubious about terraforming the world

---
title: My Journey with Terraform - Part 4 - Infrastructure as code
categories: terraform
tags: terraform devops
---

- short intro
- started again at hyraiq
    - use packer to build ami's and vagrant boxes
    - store terraform state in s3, use dynamodb as state lock
    - create almost everything with terraform, except:
        - iam users and terraform backend
        - initial route53 zone
        - https certificate
- to speed up developing ami's
    - used vagrant boxes that could be reprovisioned
    - use ec2 instances that could be reprovisioned
    - main reason to choose ansible over shell scripts
    - yaml > bash
    - started using ansible galaxy roles
- having everything in terraform had many benefits:
    - easier to get other people across the infrastructure (not necessarily devops)
    - everything is already documented
    - much easier to come back to after months and re-teach yourself
- conclusion
    - realised the benefits of modules once you've copy pasted enough hcl
    - want everything in terraform

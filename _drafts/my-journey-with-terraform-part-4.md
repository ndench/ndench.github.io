---
title: My Journey with Terraform - Part 4 - The state is not scary
categories: terraform
tags: terraform devops
---

- short intro
- import the state of existing assets
    - s3 bucket
    - route53 zone
    - https certificate
    - now all our infrastructure is in terraform
        - minus terraform backend and iam roles
- refactored hcl into submodules
    - not scared of modiying state anymore
    - didn't reuse any modules
    - just separated code to make it easier to understand
    - copied public modules
- conclusion
    - modules make things great
    - want to refactor everything to use modules
    - everything in one big terraform directory

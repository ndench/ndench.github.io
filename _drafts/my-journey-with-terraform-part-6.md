---
title: My Journey with Terraform - Part 6 - Terraform my world
categories: terraform
tags: terraform devops
---

- short intro
- aws architect said to use autoscaling groups
    - this means we need a new deployment strategy
- get everything into terraform and AWS
    - ci/cd pipeline
    - logging
    - notifications
- started again using 3rd party modules
    - X lines of vpc hcl replaced with Y
- separated internal modules so they could be reused
    - infra and web for staging and production
- conclusion
    - terraform is slow now
    - want to break it up into separate sections that run independently

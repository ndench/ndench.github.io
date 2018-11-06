---
title: My Journey with Terraform - Part 6 - Following best practices
categories: terraform
tags: terraform devops
---

- short intro
- problems:
    - terraform is running slow
    - hard to add new environments
    - hard to make changes in staging without afecting production
- terraform best practices say to have different directories per environment
- refactoring:
    - terraform import each resource
    - terraform state rm each resource
    - find how to use 2 different states
    - <https://stackoverflow.com/questions/50400007/terraform-how-to-migrate-state-between-projects/51489058?noredirect=1#comment93218894_51489058>
- conclusion
    - yay

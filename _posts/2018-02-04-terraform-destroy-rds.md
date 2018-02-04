---
title: Terraform refuses to destroy RDS instance without a snapshot
categories: terraform
tags: rds terraform
---

Recently I created an RDS instance for testing using Terraform. Since it's just
for testing, I didn't want to store a final snapshot when I destroyed the 
instance. However, when I ran `terraform destroy` I presented with an error:

```
aws_db_instance.db_instance: DB Instance FinalSnapshotIdentifier is required 
when a final snapshot is required
```

Even after I enabled the `skip_final_snapshot` parameter, terraform still 
refused to destroy the instance. 

```hcl
resource "aws_db_instance" "primary" {
  ...
  skip_final_snapshot = true
  ...
}

```


It turns out that terraform requires you to `apply` the change before you can
destroy the instance without a final snapshot:

```bash
$ terraform apply
$ terraform destroy
# Success!
```

However, if you're like me, and have just destroyed all your test 
infrastructure except the RDS instance, you don't want to run `apply` to 
re-create everything again. So I could have specified a 
`final_snapshot_identifier` then destroyed it, and then deleted the snapshot:

```hcl
resource "aws_db_instance" "primary" {
  ...
  final_snapshot_identifier = "DELETE ME"
  ...
}

```

But I just chose to delete the RDS instance through the web interface
(checking the box to 'skip final snapshot'), then run `terraform refresh` to
update the state.


## Links that helped me ##

* [GitHub issue explaining to run apply first](https://github.com/terraform-providers/terraform-provider-aws/issues/92)
* [Terraform RDS docs](https://www.terraform.io/docs/providers/aws/r/db_instance.html#skip_final_snapshot)

# blog

TODO:

Set up Jekyll and GitHub pages:
* https://jekyllrb.com/
* https://pages.github.com/

Full UTF8 support with MySQL, RDS and Symfony

* Convert existing database to utf8mb4: https://mathiasbynens.be/notes/mysql-utf8mb4
* Set doctrine charset and default table options: https://symfony.com/doc/3.3/doctrine.html
* Setting RDS parameter group: http://aprogrammers.blogspot.com.au/2014/12/utf8mb4-character-set-in-amazon-rds.html
* Manually connecting to the DB: https://stackoverflow.com/q/6787824/1393498

Destroying RDS instance with Terraform

* Apply `skip_final_snapshot = true` before destroying: https://github.com/terraform-providers/terraform-provider-aws/issues/92
* Or specify `final_snapshot_identifier`

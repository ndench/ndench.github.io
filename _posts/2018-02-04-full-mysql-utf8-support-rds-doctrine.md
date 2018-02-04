---
title: How to fully support MySQL UTF-8 with RDS and Doctrine
categories: mysql
tags: mysql rds doctrie symfony utf8 utf8mb4
---

If you're reading this it's probably because you've realised that MySQL's 
`utf8` encoding isn't really UTF-8, despite what it says on the packet. The 
reason behind is because UTF-8 stores characters with anywhere between 1 and 4
bytes, depending on the character. MySQL's bodged up form of UTF-8 can only use
1 to 3 characters. There's a bunch more detail about this which you can read 
about in the links posted at the end.

However, as it turns out MySQL released a new encoding `utf8mb4` which supports
full UTF-8, however there are a bunch of settings you have to change in order 
to use it. In all of my projects I use Symfony Doctrine and MySQL, in production
MySQL is running on AWS RDS, and in dev it's a MySQL installation on a vagrant 
box. I need to change settings in all three areas to utilise `utf8mb4`.

If you have an existing database that you want to change to `utf8mb4` check
out [this post](https://mathiasbynens.be/notes/mysql-utf8mb4), you need to
manually change the encoding and collation settings for each table in every
schema, and then the schema itself.


## Doctrine ##

You need to tell doctrine to create the database and tables with the `utf8mb4`
encoding:

```yaml
# app/config/config.yml
doctrine:
    dbal:
        charset: utf8mb4
        default_table_options:
            charset: utf8mb4
            collate: utf8mb4_unicode_ci
```


## MySQL ##

With a local installation (or a self managed instance) of MySQL, you need to 
edit the `my.cnf` file. You just add to the default `/etc/my.cnf`, but I find
it easier to just create a new file `/etc/mysq/conf.d/mysql_encoding.cnf`:

```conf
[client]
# If a client doesn't specify an encoding, use utf8mb4
default-character-set = utf8mb4

[mysql]
# Create tables with utf8mb4 encoding by default
default-character-set = utf8mb4

[mysqld]
# If a client specifies an encoding, ignore it and use the default
character-set-client-handshake = FALSE
# Use utf8mb4 enocding
character-set-server = utf8mb4
# Compare characters with utf8mb4
collation-server = utf8mb4_unicode_ci
```

I use the ansible role 
[geerlingguy.mysql](https://github.com/geerlingguy/ansible-role-mysql) and 
include the above file in the `mysql_config_include_files` array when I 
provision vagrant boxes.


## RDS ##

For RDS you need to create a new 
[DB parameter group](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html)
and add the following parameters to it:

```yaml
character_set_client: utf8mb4
character_set_database: utf8mb4
character_set_results: utf8mb4
character_set_connection: utf8mb4
collation_connection: utf8mb4_unicode_ci
collation_server: utf8mb4_unicode_ci
character_set_server: utf8mb4
```

I like to do this with Terraform:

```hcl
resource "aws_db_parameter_group" "utf8mb4" {
  name        = "utf8mb4"
  family      = "mysql5.7"
  description = "enable 'real' utf8 (utf8mb4)"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_unicode_ci"
  }
}

resource "aws_db_instance" "primary" {
  ...

  parameter_group_name = "utf8mb4"

  ...
}

```


## Testing the encoding ##

Once you've connected to your RDS or MySQL instance, you should test the 
encoding:

```mysql
mysql> SHOW VARIABLES WHERE Variable_name LIKE 'character%' OR Variable_name LIKE 'collation%';
+--------------------------+--------------------+
| Variable_name            | Value              |
+--------------------------+--------------------+
| character_set_client     | utf8mb4            |
| character_set_connection | utf8mb4            |
| character_set_database   | utf8mb4            |
| character_set_filesystem | binary             |
| character_set_results    | utf8mb4            |
| character_set_server     | utf8mb4            |
| character_set_system     | utf8               |
| collation_connection     | utf8mb4_unicode_ci |
| collation_database       | utf8mb4_unicode_ci |
| collation_server         | utf8mb4_unicode_ci |
+--------------------------+--------------------+
```

Don't worry about the `charater_set_filesystem` or `character_set_system`, they
cannot be changed, but don't break anything.


## Links that helped me ##

* [Unicode support in MySQL](https://mathiasbynens.be/notes/mysql-utf8mb4)
* [Symfony docs for Doctrine config](https://symfony.com/doc/3.3/doctrine.html)
* [MySQL utf8mb4 support in RDS](https://aprogrammers.blogspot.com.au/2014/12/utf8mb4-character-set-in-amazon-rds.html)
* [Connecting to a database with utf8mb4](https://stackoverflow.com/q/6787824/1393498)
* [Difference between character set and collation](https://stackoverflow.com/questions/341273/what-does-character-set-and-collation-mean-exactly)
* [character_set_server vs default_character_set](https://stackoverflow.com/questions/24150997/character-set-server-vs-default-character-set-in-mysql)

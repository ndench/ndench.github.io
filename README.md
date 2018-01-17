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

Symfony Capistrano Example

* https://github.com/ndench/symfony-capistrano-circleci-example

Symfony Deployer CircleCI with build artifacts

* Create artifact: https://circleci.com/docs/2.0/artifacts/
* Accessing artifact: https://circleci.com/docs/api/v1-reference/#build-artifacts
* Deploying PHP with Deployer.org: https://www.sitepoint.com/deploying-php-applications-with-deployer/
* Overriding deploy:update_code: https://deployer.org/docs/flow#deploy:update_code

Slack Webhook in PHP

* https://github.com/tototoshi/php-slack-webhook/blob/master/src/SlackWebhook.php
* https://api.slack.com/incoming-webhooks#advanced_message_formatting<Paste>

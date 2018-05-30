---
title: BrisPHP News - Q2 2018
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
Here are the things I found intersting in the first quater of 2018.


## PHP News ##

### Version Stats ###

Time for the latest [PHP version usage stats](https://seld.be/notes/php-versions-stats-2018-1-edition). 
Jordi Boggiano regularly trawls the logs to packagist.org to find the usage distribution of PHP 
versions. Here are some of the highlights:

![PHP Version Usage]({{ "/assets/images/php-version-stats-2018-01.png" }})

The greatest thing you can see here is that more than 20% of active projects are using PHP 7.2,
and almost 95% are using a maintained version of PHP. That's amazing.

![PHP Versions Over Time]({{ "/assets/images/php-versions-over-time-2018-01.png" }})

You can see here the version usage over time. You can see that all new versions are adopted pretty
quickly, but old ones hang around for a very long time.


### Ubuntu 18.04 uses PHP 7.2 by default ###

No longer will you have to add a separate repository to install the best PHP version. On the latest
Ubuntu `apt install php` will give you 7.2 by default! Of course, 16.04 also shipped with 7.0 by 
default, and it wasn't long we all wanted to install 7.1. So we'll probably need that extra 
repository again soon, but this should really help the update of 7.2. You can find the announcement
[here](https://symfony.fi/entry/ubuntu-18-04-lts-version-bionic-beaver-ships-php-7-2).


### What's on the way for PHP 7.3? ###

Ayesh Karunaratne is maintaining a live document detailing all the 
[changes we can expect in PHP 7.3](https://ayesh.me/Upgrade-PHP-7.3). Here are some of my favourite
features:

#### Better Heredoc syntax ####

At the moment any Heredoc you write has to break the flow of your code. Something like this:

```php
<?php

class AnimalSentences
{
    
    public function jumpLazyFox(string $animal): string
    {
        $foo = <<<EOF
the crazy "%s"
    jumps over the lazy fox;
EOF

        return sprintf($foo, $animal);
    }
}
```

As you can see, this looks terrible and ensure that I avoid using it at all costs.
However, with 7.3 we'll be able to format it like:


```php
<?php

class AnimalSentences
{
    
    public function jumpLazyFox(string $animal): string
    {
        $foo = <<<EOF
        the crazy "%s"
            jumps over the lazy fox;
        EOF

        return sprintf($foo, $animal);
    }
}
```

This works because you can have the ending `EOF` token not as the first thing on the line, and any 
whitespace before the ending `EOF` token will also be stripped from the start of every other line.
This you cannot have other lines in the Heredoc indented less than the ending `EOF` token:


```php
<?php

class AnimalSentences
{
    
    public function jumpLazyFox(string $animal): string
    {
        $foo = <<<EOF
        the crazy "%s"
    jumps over the lazy fox;                // Parse error
        EOF

        return sprintf($foo, $animal);
    }
}
```

The only backward compatibily issues that exist here is if you happen to have Heredoc somewhere 
that contains an indented `EOF` token like this:


```php
<?php

class AnimalSentences
{
    
    public function jumpLazyFox(string $animal): string
    {
        $foo = <<<EOF
the crazy "%s"
    EOF                         // This will terminate the Heredoc in 7.3+
    jumps over the lazy fox;
EOF

        return sprintf($foo, $animal);
    }
}
```


#### Trailing comma in function calls ####

Something I really like doing is adding a trailing comma in multi-line array declarations:

```php
<?php

$foo = [
    'bar',
    'baz',
    'bob',
];
```

Because if need to add another element, or remove the last element, it makes the git diff really 
tidy since you only modify a single line, and I see this:

```
$foo = [
    'bar',
    'baz',
+   'bob',
];
```

Instead of this:

```
$foo = [
    'bar',
-   'baz'
+   'baz',
+   'bob',
];
```

Which makes code reviews much easier since the actual change stands out. In 7.3 we'll be able to 
do this with function calls as well:

```php
<?php

foo(
    'bar',
    'baz',
    'bob',
);
```

Note: You'll be able to do this with single line function calls as well, just like single line array
declarations. However, I don't really see the point in that.


#### json_encode and json_decode to throw exceptions ####

How much do you hate checking `json_last_error` every-damn-time you encode or decode something?
Very soon, we'll be able to have some great looking code like:

```php
<?php

try {
  json_decode("{", false, 512, JSON_THROW_ON_ERROR);
} catch (\JsonException $exception) {
    echo $exception->getMessage(); // echoes "Syntax error"
}
```

Since this won't be the default behaviour (ie. you have to pass the `JSON_THROW_ON_ERROR` option),
there are no backwards compatibily problems!


#### PSR-12 - Extended Coding Style Guide ####

I love PSR-2 but it's quite limited in it's rules, leaving a lot open to interpretation and leading
to inconsistent code. [PSR-12](https://github.com/php-fig/fig-standards/blob/master/proposed/extended-coding-style-guide.md)
is an extended code style guide that's currently proposed (it hasn't been accepted yet), that provides
code style rules for a lot of the new features and syntax that has come out since PSR-2 was released.


### Framework news ###

Before I talk about all the new things in framework land, I'd like to mention this post by Kevin 
Smith about writing [Modern PHP Without a Framework](https://kevinsmith.io/modern-php-without-a-framework).
It's a very interesting read and in spite of the title Kevin's not recommending you write PHP 
without a framework. He's explaining how modern frameworks hang together and showing you how to
piece your own lightweight framework together with a few open source parts. The main goal of the 
post is to teach people that frameworks aren't magic and I think it does it very well.

#### Symfony 4.1 is on the horizon ####

Symfony 4.1 is due to be released any day, and there are a lot of very awesome things inluded.
If you want to see all the changes and new features you can see a list of all the 
[New in Symfony 4.1](https://symfony.com/blog/category/living-on-the-edge/4.1) blog posts which 
go into detail about each update. Here are my favourite changes:

* The serializer is bad ass:
    * [Up to 40% speed improvement](https://symfony.com/blog/new-in-symfony-4-1-faster-serializer)
    * [A bunch of cool impprovements](https://symfony.com/blog/new-in-symfony-4-1-serializer-improvements), including:
        * Automatically validating the serialized object for you
        * Being able to serialize objects that require constructor arguments
* A new [Messenger Component](https://symfony.com/blog/new-in-symfony-4-1-messenger-component) similar 
  to the awesome Laravel Queues
* Some improvements to the [Workflow Component](https://symfony.com/blog/new-in-symfony-4-1-workflow-improvements)
  including storing arbitrary metadata on workflow steps
* [Simpler service testing](https://symfony.com/blog/new-in-symfony-4-1-simpler-service-testing)
  by making services non-private by default in the test environment
* [Improvments to the Router](https://symfony.com/blog/new-in-symfony-4-1-fastest-php-router) which 
  is already the fastest in PHP, but now it's even faster!
* Ability to configure [Argon2i password hashing](https://symfony.com/blog/new-in-symfony-4-1-argon2i-configuration).
  I've already started using Argon2i and it's pretty great, with this we will be able to configure 
  it to be more secure. Here are some good links for how to choose the correct options:
    * [How to work with passwords securely](https://php.earth/docs/security/passwords)
    * [SO question about picking appropriate options](https://stackoverflow.com/q/48320403/1393498)
    * [A great cli tool](http://argon2-cffi.readthedocs.io/en/stable/cli.html) I used to find the appropriate values for my servers 


If you're still unfortunately stuck on an older version of Symfony, here's a great pot about how 
to [upgrade from 2.8 to 3.4 in only 6 steps](https://blog.shopsys.com/5-5-steps-to-migrate-from-symfony-2-8-lts-to-symfony-3-4-lts-in-real-prs-50c98eb0e9f6).

#### Laravel - Laracon is coming up! ####

Laracon is coming to Sydey on October 18-19 and early bird tickets are [on sale now](https://laracon.com.au/)!


#### Drupal ####

Drupal has had a tough start to the year with [3 critical vulnerabilities](https://www.drupal.org/security)
including 2 remote code execution vulnerabilities. One of them is called  Druaplgeddon 2 (which is
an awesome name) and here is agreat post about [how it was uncovered](https://research.checkpoint.com/uncovering-drupalgeddon-2/)


### Some new packages ###

[Bref](http://mnapoli.fr/serverless-php/) is a tool that allows you to deploy your PHP app to AWS 
Lambda and run it serverless. It seems a little crazy but it's pretty cool. In order to run PHP on
Lambda you have to:

* Compile PHP for the OS used on lambdas
* Add the compiled PHP binary to the lambda
* Write a Javascript handler (the code executed by the lambda) that executes the PHP binary
* Write a PHP handler (the code that will be executed by the Javascript handler)
* Deploy the lambda

It's pretty cool that the PHP community is pushing the boundaries of what we can do, this is we
progress PHP as a language!


[TBDM](https://thecodingmachine.io/tdbm5-coming-out) is an ORM for people that hate ORM's. I've 
heard many people complain about ORM's because they don't allow you to model your business data
in the way that you want. TBDM allows you to model your data in the database exactly how you want
to, then it generates your entities in code for you, not the other way around like a conventional
ORM.

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

* how to build a framework: <https://kevinsmith.io/modern-php-without-a-framework>

#### Symfony ####


* Migrate from Symfony 2.8 to 3.4 <https://blog.shopsys.com/5-5-steps-to-migrate-from-symfony-2-8-lts-to-symfony-3-4-lts-in-real-prs-50c98eb0e9f6>
* Symfony 7.3 and ctype polyfil: <https://symfony.com/blog/introducing-new-symfony-polyfills-for-php-7-3-and-ctype>
* argon 2i configuration for symfony: <https://symfony.com/blog/new-in-symfony-4-1-argon2i-configuration>
* a good explanation of password hashing in php: <https://php.earth/docs/security/passwords>
    * find best parameters: <http://argon2-cffi.readthedocs.io/en/stable/cli.html>
    * <https://stackoverflow.com/questions/48320403/argon2i-in-php7-picking-appropriate-options>
* Testing private services in Symfony 4.1: <https://www.tomasvotruba.cz/blog/2018/05/17/how-to-test-private-services-in-symfony/>

#### Laravel ####

* Laracon Sydney - October 18-19 <https://laracon.com.au/>


#### Drupal ####

* Drupal has has a lot of security vulnerabilites: <https://www.drupal.org/security>
    * Uncovering Drupalgeddon 2 <https://research.checkpoint.com/uncovering-drupalgeddon-2/>
* An example attack against drupalgeddon: <https://research.checkpoint.com/uncovering-drupalgeddon-2>


### Javascript ###

* Everything new in JavaScript from 2016-2018 <https://medium.freecodecamp.org/here-are-examples-of-everything-new-in-ecmascript-2016-2017-and-2018-d52fa3b5a70e>


### New packages ###

* bref serverless php <http://mnapoli.fr/serverless-php/>
* TBDM a database first ORM <https://thecodingmachine.io/tdbm5-coming-out>

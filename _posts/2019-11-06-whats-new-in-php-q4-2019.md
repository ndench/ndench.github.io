---
title: What's new in PHP land? - Q4 2019
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
Recently, we've had some security vulnerabilities, a few cool projects
in the community and more features accepted into PHP 8.0.

## PHP

### PHP 7.4

There are no new features going into PHP 7.4, and for very good reason. It's 
going to be [released at the end of this month](https://wiki.php.net/todo/php74)!

<div data-type="countdown" data-id="1555370" class="tickcounter" style="width: 100%; position: relative; padding-bottom: 25%"><a href="//www.tickcounter.com/countdown/1555370/php-74-release" title="PHP 7.4 Release">PHP 7.4 Release</a><a href="//www.tickcounter.com/" title="Countdown">Countdown</a></div><script>(function(d, s, id) { var js, pjs = d.getElementsByTagName(s)[0]; if (d.getElementById(id)) return; js = d.createElement(s); js.id = id; js.src = "//www.tickcounter.com/static/js/loader.js"; pjs.parentNode.insertBefore(js, pjs); }(document, "script", "tickcounter-sdk"));</script>

I can't wait for the new version, my favourite new features are:

1. Typed properties
2. Preloading
3. Arrow functions

See my previous posts for more info on these and other new features:

* [Q1 2019]({% post_url 2019-01-30-whats-new-in-php-q1-2019 %})
* [Q2 2019]({% post_url 2019-04-30-whats-new-in-php-q2-2019 %})
* [Q3 2019]({% post_url 2019-07-28-whats-new-in-php-q3-2019 %})

### PHP 8.0

There have been two new features accepted in PHP 8.0 this quarter.

#### Union types

The [Union Types 2.0](https://wiki.php.net/rfc/union_types_v2) RFC brings 
forward the idea of union types, or typing a variable to be one of two or more
different types. You can use union types everywhere that existing types are 
currently accepted.

DISCLAIMER: At the time of writing this one still had a few days left of voting.
However, an overwhelming majority of votes are in favour so I'll risk it for 
the biscuit and call it.

Example:

```php
<?php

class Number {
    private int|float $number;
 
    public function setNumber(int|float $number): void {
        $this->number = $number;
    }
 
    public function getNumber(): int|float {
        return $this->number;
    }
}
```

We already have a union type in order to allow for nullables. So `?int` and `int|null`
will be equivalent. But you will not be able to use the question mark when there are
multiple possible types. For example `?int|float` is invalid.

Additionally, an `false` psuedo type is being added to account for the many 
places in the core that a function returns `false` on error. For example 
`strpos()` can be typed as `int|false`. Note that `false` cannot be typed on
it's own, it must be part of a union type.

#### Reclassifying engine warnings

Nikita Popov suggested we should increase the error level for some internal 
warnings and notices because they represent bad programming errors. There were
23 changes proposed, of which 3 were voted on separately because they were 
controversial, while the remaining 20 were voted on as one. See 
[the RFC](https://wiki.php.net/rfc/engine_warnings) for the full list of 
reclassifications, I'll list the controversion ones here:

1. Undefined variables
    * Being promoted from a Notice to a Warning
    * Attempt was made to get it as an Error exception, but it did not have 
      enough votes
2. Undefined array index
    * Being promoted from a Notice to a Warning
3. Division by zero
    * Being promoted from a Warning to a DivisionByZeroError exception

There were 20 non-controversial changes proposed:
* Promoting 8 Warnings to Error exceptions
* Promoting 7 Notices to Warnings
* Promoting 5 Warnings to TypeError exceptions

### PHP++

The idea was [floated in the internal mailing list](https://externals.io/message/106453)
about creating a second "dialect" of PHP with some suggesting the name "P++". 
The idea was to have the same PHP engine running both the normal version of PHP 
and a strict type-safe version. It was raised because there has been a lot of 
internal discussion about whether or not PHP should become more strict moving 
forward, for which there are almost equal amounts of people for and against.

In the end, the idea was withdrawn after considerable discussion both internally
and from many randoms on the internet. With the outcome being that PHP would 
slowly introduce more strict features by making them optional.

### Security vulnerabilities

#### RCE through open php-fpm ports

If you have php-fpm configured to listen on a TCP port, and that port is exposed
to the world, at attacker can trick php-fpm in executing an arbitrary php file 
on the system. As such, you should follow best practices and hide php-fpm behind
a webserver such as nginx. See the [bug report here](https://www.openwall.com/lists/oss-security/2019/07/27/1).

#### Buffer overflow

PHP 7.3.10 fixed a heap buffer overflow vulnerability in the `mb_eregi()` 
function which could grant an attacker arbitrary code execution. 
A [post by SC Magazine](https://www.scmagazine.com/home/security-news/vulnerabilities/php-update-fixes-arbitrary-code-execution-flaw-9-other-bugs/)
has more details.

### Frameworks

#### Wordpress

Wordpress is talking about [strictly enforcing SSL for auto 
updates](https://make.wordpress.org/core/2019/08/16/ssl-for-auto-updates/).
From what I can gather, getting either core WordPress updates or plugin/theme 
updates doesn't necessarily happen over SSL at the moment, so they want to 
enforce it and also add checksum validation to enforce packgage integrity.
While I think this should already have been a thing, I'm glad to see
WordPress pushing forward on security.

#### Slim 4.0

Slim 4.0 [was released in August](https://www.slimframework.com/2019/08/01/slim-4.0.0-release.html)
and it has a bunch of changes to push the framework forward:

* Decoupling a lot of dependencies so you're not forced to install them
    * Dependency injection
    * Router
    * Error handling
    * PSR-7
* Only supports PHP 7.1+
* Removed a few "automagic" abilities to make the framework easier to understand

#### Symfony 5.0

Symofony 5.0 is [due to be released this month](https://symfony.com/releases)
along with 4.4. The 4.4 version will contain all the features for 5.0 with 
backward compatibility and a bunch of deprecations. This gives you an easy 
upgrade path because once you remove deprecations, your app will function
perfectly on 5.0.

There aren't as many groundbreaking features in 5.0 as there was in 4.0,
but there's a nice [list of them here](https://symfony.com/blog/category/living-on-the-edge/5.0-4.4).
My favourites are:

* [Encrypted secrets management](https://symfony.com/blog/new-in-symfony-4-4-encrypted-secrets-management)
  which allows you to store secrets in the git repo (eg. database passwords).
* [Automatic password migrations](https://symfony.com/blog/new-in-symfony-4-4-password-migrations)
  to automatically rehash users passwords with the latest algorithm.
* [Testing email content](https://symfony.com/blog/new-in-symfony-4-4-phpunit-assertions-for-email-messages)
  allows to assert email bodies contain specific content.

### Community

#### Client side PHP

Atymic has found a way to [run PHP in the browser](https://atymic.dev/blog/client-side-php/).
This may seem a little insane, and it is. Because you need to:

* Download PHP source
* Build your app into a .phar
* Complile your .phar and PHP source using web assembly
* Make your users load this and run it

While this terrifies me, it also excites me that we're still pushing the 
boundaries of PHP can (or even should) do.

#### Dependency graph support on GitHub

GitHub can now [hook into your 
composer.json](https://github.blog/2019-09-18-dependency-graph-supports-php-repos-with-composer-dependencies/)
to give you automatic security notifications/updates as well as insights into
your dependency tree.


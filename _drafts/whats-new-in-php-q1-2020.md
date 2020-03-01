---
title: What's new in PHP land? - Q1 2020
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
Recently, we've had a lot of progress on PHP 8.0 and lots of frameworks
released new versions.

## PHP

Let's start with some [PHP Version Stats](https://blog.packagist.com/php-versions-stats-2019-2-edition)
released December last year by Jordi Boggiano.

![PHP Version Usage]({{ "/assets/images/php-version-stats-2019-11.png" }})

We can see PHP 5.6 is still hanging around a bit, bit it has dropped a bit. 
PHP 7 versions are definitely taking the majority of the market, however with 
7.2+ being the only supported versions, there is still a large number of 
projects on unsupported versions :'(.

![PHP Versions Over Time]({{ "/assets/images/php-versions-over-time-2019-11.png" }})

Here it's easy to see that PHP 7.4 is picking up just as fast as all 
previous versions that have been released.

### PHP 8.0

There are [already lots](https://stitcher.io/blog/new-in-php-8) of 
[other posts](https://thephp.website/en/issue/state-of-php-8/) about the
features in PHP 8.0, but I'm going to list the changes that have happened
in the last few months. 

#### Static return type

I use fluent methods a lot and not having the `static` return type
really gets me. Here's an example:

```php
<?php

interface FooInterface {
    public function doSomething(): static;
}

class Foo implements FooInterface {
    public function doSomething(): static {
        // Do some things

        return $this;
    } 
}
```

At the moment, we can't need to use `self` as the return
type, which gives us a fatal error because 
`Foo::self !== FooInterface::self` and is not compatible.
The `static` return type lets us benefit from late static 
binding and makes this work as you would expect.

Take a look at [the RFC](https://wiki.php.net/rfc/static_return_type)
for more information.

#### Allow `$object::class`

I also use FQCN's a lot, to populate exception/log messages
and as keys in an array, etc. Since PHP  5.5 we've been able 
to use `Foo\Bar::class` to get the FQCN, but if you have an
instance of `Foo\Bar` you must use `\get_class($foo)` instead.

```php
<?php

$foo = new Foo\Bar();

// Works in 5.5+
var_dump(Foo\Bar::class);
var_dump(get_class($foo));

// Works in 8.0+
var_dump($foo::class);
```

Here's a link to [the RFC](https://wiki.php.net/rfc/class_name_literal_on_object)
if you're interested.

#### Stringable interface

Any object that implements `__toString()` in an 8.0 world
will implicitly impliment the `stringable` interface:

```php
<?php

interface Stringable
{
    public function __toString(): string;
}
```

This allows you to use the union type `string|Stringable`
when it becomes available in 8.0. The goal is that 
eventually everyone will explicitly implement the interface
but for BC reasons, it will be automatically added during 
compile time.

Take a peek at [the RFC](https://wiki.php.net/rfc/stringable).

## Frameworks

### Symfony

Symfony claimed a big achievement last year. It has the 
[most contributors out of any backend framework](https://symfony.com/blog/symfony-was-the-backend-framework-with-the-most-contributors-in-2019).
Not in just PHP frameworks, but any backend framework, 
in any language.

![Backend framework contributors 2019]({{ "/assets/images/backend-framework-contributors-2019.png" }})

### Laravel

Laravel [released version 6.5](https://laravel-news.com/laravel-6-5) with some new features:


* Added LazyCollection::remember()
* New string helpers
* Improvements to the QueryBuilder
* Added unless condition to Blade custom if directives

### Phalcon

Phalcon [released version 4.0.0](https://blog.phalcon.io/post/phalcon-4-0-0-released)
in December, with an impressive list of highlights:

* PHP 7.2 minimum version
* PHP 7.4 support
* Removed unsupported code
* PSR 7, 11, 13, 16, 17
* Rewrote all documentation

### CakePHP

December also brought [CakePHP 4.0.0](https://bakery.cakephp.org/2019/12/15/cakephp_400_released.html)
with a matching list of impressive highlights:

* PHP 7.2 minimum version
* Streamlined APIs by removing deprecated methods
* More typing/type hints
* Improved error messages
* A refreshed application skeleton
* New database types
* Middleware for CSP headers
* Improvements to the FormHelper

### WordPress

[Version 5.3 of WordPress](https://wordpress.org/news/2019/11/kirk/) is now live:

* PHP 7.4 support
* Date/Time component fixes
* Improved block editor
* Automatic image rotation
* Improved site health checks

## Tools

### Codeception

December was the month of 4.0, with Codeception also 
[releasing version 4.0](https://codeception.com/12-18-2019/codeception-4) 
which splits the core into modules allowing each 
module to upgrade individually and adds support for Symfony 5.

### PHPUnit

PHPUnit 9 was [released in Februrary](https://phpunit.de/announcements/phpunit-9.html)
which cleaned up a lot of old code. It only only supports PHP 7.3+, 
uses more strict types and removed a lot of old functions/options that
have newer alternatives.

### Xdebug

While it might not be 4.0, Xdebug did 
[release version 2.9](https://xdebug.org/announcements/2019-12-09)
in December. The main part of this release was to
dramatically *speed up code coverage by 250%*!. 
That's incredible.

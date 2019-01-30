---
title: What's new in PHP land? - Q1 2019
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
The biggest news recently is the release of PHP 7.3 and development of 7.4!

## PHP versions

Let's start with a quick look at PHP version usage stats courtesy of 
[Jrodi Boggiano](https://blog.packagist.com/php-versions-stats-2018-2-edition/)
from packagist:

![PHP Version Usage]({{ "/assets/images/php-version-stats-2018-11.png" }})

We can see that PHP 7.2 is the most popular version and 84% of projects are using PHP 7+, that's
amazing!

![PHP Versions Over Time]({{ "/assets/images/php-versions-over-time-2018-11.png" }})

We can also see that PHP 7.2 was picked up just as quickly as every other new version that was
released, while the old versions continue to decline steadily.


### End of support

PHP 5.6 and 7.0 are no longer supported. Not even with security fixes. So if you're still using
these versions, getting off them should be priority #1! Here we can see that 7.1 is currently in
security support until the end of the year, while 7.2 and 7.3 still have a while to go:

![PHP Supported Versions]({{ "/assets/images/php-version-support-2019-01.png" }})

If you're struggling to upgrade your codebase, whether it be a PHP version or a framework version,
you should definitely take a look at [rector](https://github.com/RectorPHP/Rector) which can
automatically refactor and upgrade your code base for you.

## PHP 7.3 was released

PHP 7.3 was [released in December](http://php.net/releases/7_3_0.php) and comes with a few cool new
features which I've already been over in [Q2]({% post_url 2018-08-30-brisphp-news-q3-2018 %}#new-features-in-73)
and [Q3]({% post_url 2018-05-31-brisphp-news-q2-2018 %}#whats-on-the-way-for-php-73) news last year.
But here's the final list:

- Flexible Heredoc and Nowdoc Syntax
- The regex extension (PCRE) has been upgrade to PCRE2
- More multibyte string functions to convert the case of strings
- More support for LDAP controls
- Better logging for PHP FPM
- Better file deletion on Windows
- Deprecated features - mostly undocumented features or edge cases you shouldn't be doing anyway

There are a handful of backwards incompatible changes in 7.3, most of which are for relatively
unused functions so most people should be able to upgrade without any problems. Check the [upgrade
guide](https://github.com/php/php-src/blob/PHP-7.3/UPGRADING) for help.


## PHP 7.4 in development

So far, there have been a handful of RFC's accepted for PHP 7.4. Originally meant to only add
deprecations to prepare for 8.0, we now get some exciting new features.
[stitcccher.io](https://stitcher.io/blog/new-in-php-74) provides a great up-to-date overview of the
new features.


### Foreign Function Interface

A foreign function interface allows calling C functions and data types from PHP. It's modelled after
a similar feature in both Python and Lua and will allow PHP extensions to be written in PHP, albeit
with a lot of C code in what is essentially a HEREDOC.
Here's an example from the [rfc](https://wiki.php.net/rfc/ffi) that shows defining some C structs,
and calling a C function:


```php
<?php
// create gettimeofday() binding
$ffi = FFI::cdef("
    typedef unsigned int time_t;
    typedef unsigned int suseconds_t;
 
    struct timeval {
        time_t      tv_sec;
        suseconds_t tv_usec;
    };
 
    struct timezone {
        int tz_minuteswest;
        int tz_dsttime;
    };
 
    int gettimeofday(struct timeval *tv, struct timezone *tz);    
", "libc.so.6");
// create C data structures
$tv = $ffi->new("struct timeval");
$tz = $ffi->new("struct timezone");
// calls C gettimeofday()
var_dump($ffi->gettimeofday(FFI::addr($tv), FFI::addr($tz)));
// access field of C data structure
var_dump($tv->tv_sec);
// print the whole C data structure
var_dump($tz);
```


### Typed properties V2

Typed properties has been propesed and rejected before, but along came version 2 of the proposal,
fixing up the issues raised the first time around, it has now been accepted for PHP 7.4. Here's an
example from [the rfc](https://wiki.php.net/rfc/typed_properties_v2):

What type-safe code currently looks like:

```php
<?php

class User {
    /** @var int $id */
    private $id;
    /** @var string $name */
    private $name;
 
    public function __construct(int $id, string $name) {
        $this->id = $id;
        $this->name = $name;
    }
 
    public function getId(): int {
        return $this->id;
    }
    public function setId(int $id): void {
        $this->id = $id;
    }
 
    public function getName(): string {
        return $this->name;
    }
    public function setName(string $name): void {
        $this->name = $name;
    }
}
```

What it will look like with typed properties:

```php
<?php

class User {
    public int $id;
    public string $name;
 
    public function __construct(int $id, string $name) {
        $this->id = $id;
        $this->name = $name;
    }
}
```

No longer will we have to make every single property private. Of course if you want some business 
logic around setting the value, then it will need to be private.


### Null coalescing assignment operator

In a pre-PHP7 world, we used to see code like this a lot:

```php
<?php

$this->request->data['comments']['user_id'] = isset($this->request->data['comments']['user_id']) ? $this->request->data['comments']['user_id']? 'value';
```

And then PHP7 brought us the null coalescing operator, allowing us to do:

```php
<?php

$this->request->data['comments']['user_id'] = $this->request->data['comments']['user_id'] ?? 'value';
```

And now, PHP7.4 will give us:

```php
<?php

$this->request->data['comments']['user_id'] ??= 'value';
```

You can read the [rfc here](https://wiki.php.net/rfc/null_coalesce_equal_operator).


### Preloading

Preloading is a performance improvement that allows loading PHP files into memory on server boot, so
they never need to be accessed or re-compiled again. This means you could load your framework
or even your entire application into memory to drastically reduce the overhead of PHP.

This does come at a cost though, if you enable preloading you MUST restart your server
(php-fpm/apache) whenever files changed. This is because the files are never read from the disk again.

For more information, check [the rfc](https://wiki.php.net/rfc/preload).


### Permanent hash extension

[This rfc](https://wiki.php.net/rfc/permanent_hash_ext) proposes that the `ext-hash` extension
become permenantly availble in PHP. Since 5.1.2 it's been bundled with PHP by default, but it was
possible to disable it. Post 7.4 it will always be enabled.


### Password hashing registry

Everyone has to deal with passwords at some point. So [this
rfc](https://wiki.php.net/rfc/password_registry) plans to make dealing with passwords in userland
hashig libraries easier to use.


### Improve openssl_random_psuedo_bytes()

It's pretty easy to generate some cryptographically secure random bytes in PHP:

```php
<?php

function genCsrfToken(): string
{
    return bin2hex(openssl_random_pseudo_bytes(32));
}
```

Except, according [the rfc](https://wiki.php.net/rfc/improve-openssl-random-pseudo-bytes), this code
doesn't correctly handle errors that can sneak through from the `openssl_random_psuedo_bytes`
function. The correct usage looks more like this:


```php
<?php

function genCsrfToken(): string
{
    $strong = false;
    $bytes = openssl_random_pseudo_bytes(32, $strong);

    if (false === $bytes || false === $strong) {
        throw new \Exception('CSPRNG error');
    }

    return bin2hex($bytes);
}
```

Which is, let's face it, kind of gross. In a post 7.2 world, we'll be able to safely use the first
example.


## Framework news

### Laravel 5.7

Laravel 5.7 [was released](https://laravel-news.com/laravel-5-7-is-now-released) containing a few
new features:

- new directory structure
- easier pagination through database records
- better error messages
- easier testing of artisan commands
- dump server command
- Better syntax for action urls

### Yii 3

Yii 3 [was
released](https://github.com/yiisoft/yii-core/blob/41f358a716f46125118fdae3b5436f4e9a8f426a/UPGRADE.md)
which contains a large list of new features. My personal favourite are:

- PHP 7.1 minimum requirement
- Using semver after version 3.0
- Split the Yii repository into smaller component repositories
- Supporting more PSR's

### Symfony 4.2

Symfony 4.2 [was released](https://symfony.com/blog/symfony-4-2-curated-new-features) with an
absolute ton of changes, mainly small improvements. My personal favourites are:

- Auto-secure cookies
- A bunch of deprecations for things you probably shouldn't be doing
- Much simpler functional tests
- Easier debugging of autowiring magic
- Making it easy to customise serialised names


### WordPress 5.0

WordPress 5.0 [was released](https://wordpress.org/news/2018/12/bebo/) bringing a brand new editor
and generally making the UI much more appealing.


## Security

Perhaps the most serious security vulnerability for PHP developers recently is the [PEAR PHP
breach](https://arstechnica.com/information-technology/2019/01/pear-php-site-breach-lets-hackers-slip-malware-into-official-download/)
in which hackers were able to compromise the pear.php.net website to upload a malicios go-pear.phar
package manager. No one is, as of yet, fully aware what the malicious version does, but some are suggesting it opens
a backdoor into a webserver, giving the hackers complete control of the system. 

The pear.php.net site has been shut down since the hack was discovered, but it went undiscovered for
six months, meaning there probably quite a lot off malicious versions out and still being used. The
current recommendation is to download a new phar archive from GitHub (pear/pearweb_phars) which was
unaffected.

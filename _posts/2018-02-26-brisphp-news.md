---
title: BrisPHP News - 1 March 2018
categories: brisphp
tags: brisphp php news
---

I organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
Here are the things I found intersting in the first quater of 2018.


## PHP News ##

### PHP 7.2 is released ###

PHP 7.2 was [released](https://secure.php.net/releases/7_2_0.php)! It includes 
a few cool new features (disclaimer, this is not a full list of all the features,
see the link if you want everything):

#### Converting numeric keys in object/array casts ####
There are more subtle differences between arrays and objects in PHP than I 
first though. I used to think that an array was just an object with numerical
keys, but that's not the case. 

Array:
* integer OR string keys
* if a string key is numerical, it is converted to an int

Example:
```php
<?php

$arr = ['test' => 1, '1' => 2, 2 => 3];

var_dump($arr);
// array(3) {
//   ["test"]=>
//   int(1)
//   [1]=>
//   int(2)
//   [2]=>
//   int(3)
// }
```

Object:
* string keys
* integer keys are converted to strings

Example:
```php
<?php

$obj = new \stdClass();
$obj->test = 1;
// syntax error, unexpected ''1'' (T_CONSTANT_ENCAPSED_STRING)
//$obj->'1' = 2;
$obj->{'1'} = 2;
// syntax error, unexpected '2' (T_LNUMBER)
//$obj->2 = 2;
$obj->{2} = 3;

var_dump($obj);
// object(stdClass)#1 (3) {
//   ["test"]=>
//   int(1)
//   ["1"]=>
//   int(2)
//   ["2"]=>
//   int(3)
//}
```

This is the behaviour of all php versions from 5.3 and up. The problem comes 
when casting between arrays and objects when the keys are numeric (either 
numerical strings or integers):

```php
<?php
// PHP < 7.0

$arr = ['test' => 1, '1' => 2, 2 => 3];
$obj = (object) $arr;

var_dump($obj);
// object(stdClass)#1 (3) {
//   ["test"]=>
//   int(1)
//   [1]=>
//   int(2)
//   [2]=>
//   int(3)
// }

var_dump($obj->test);
// int(1)

var_dump($obj->{"1"});
// Notice: Undefined property: stdClass::$1
// NULL
```

The integer keys continue to be integers in the object, but this is not valid.
So now you can no longer access those properties in the object.

PHP 7.2 fixes this, to make it work how you would expect:

```php
<?php
// PHP >= 7.2
$arr = ['test' => 1, '1' => 2, 2 => 3];
$obj = (object) $arr;

var_dump($obj);
// object(stdClass)#1 (3) {
//   ["test"]=>
//   int(1)
//   ["1"]=>
//   int(2)
//   ["2"]=>
//   int(3)
// }

var_dump($obj->test);
// int(1)

var_dump($obj->{"1"});
// int(2)
```


#### Counting of non-countable objects ####
For some reason, if you count something is not countable, ie. a scalar, null 
or an object that doesn't implement the `Countable` interface, then count will 
return `1` and pretend that everything is fine. After version 7.2, a warning will
be thrown, BUT it still returns `1` so that backwards compatibility is maintained.
I imagine this will eventually throw an error in PHP 8 or some future version.


#### Object typehint ###

You can now use `object` as a parameter or return type:

```php
<?php
// PHP >= 7.2

function foo(object $bar): object
{
    ...
}
```


#### Argon2i password hashing ####

Argon2 won the Password Hashing Competition in 2015 and is now the standard
hashing algorithm. It has 3 different versions:

* Argon2d maximizes resistance to GPU attacks but allows side-channel attacks
* Argon2i is optimised to prevent side-channel attacks but is slower
* Argon2id is a hybrid that tries to combine the two

Argon2i is the recommended approach for password hashing and has been added to
PHP 7.2. The main difference to Bcrypt is that it takes three cost factors
instead of 1:

1. How much memory to use in KiB (default: 1024 KiB)
2. How many iterations to do (default: 2)
3. Number of parallel threads (default 2)


For the moment, the `PASSWORD_DEFAULT` constant still points to the Bcrypt
algorithm, but I expect that will change soon. You can use Argon2 like this:

```php
<?php

// Argon2i with default cost factors
password_hash('password', PASSWORD_ARGON2I);
 
// Argon2i by name with custom cost factors
$options = [
    'memory_cost' => 1<<17,
    'time_cost' => 4,
    'threads' => 4,
];
password_hash('password', PASSWORD_ARGON2I, $options);
```

#### Improved TLS defaults ####

We have even more improvements to security: 

* `tls://` default to TLSv1.0 + TLSv1.1 + TLSv1.2
* `ssl://` an alias of tls://
* `STREAM_CRYPTO_METHOD_TLS_*` constants default to TLSv1.0 + TLSv1.1 + TLSv1.2
instead of TLSv1.0 only

#### Ditch Mcrypt ####

Don't use Mcrypt, it's old and broken and hasn't been updated in over 10 years.
It's no longer bundled with PHP and you have to install it manually, although 
I really beg you not to.

### Version support ###

* Both 5.6 and 7.0 are out of active support now, and are only getting 
security updates until December this year.
* 7.1 has active support until December and security support until 
December next year.
* 7.2 has active support until December next year

### PSR-15 was released ###

[PSR-15](https://www.php-fig.org/psr/psr-15/) defines common interfaces for
server request handlers and HTTP middleware. Which means that if you're using
a framework that works with PSR-15 then you can swap out you request handlers
and middleware with drop in replacements. 
[This article](https://www.php-fig.org/psr/psr-15/) has a good overview of what
PSR-15 does and why.

### PHP GitHub stats ###

Marcel Pociot wrote a great blog post:
[2017 - A PHP year in review](http://marcelpociot.de/blog/2017-12-21-a-php-year-in-review)
in which he shows some cool stats for PHP repositories on GitHub.

Here we can see the PHP repositories that received the most stars on GitHub last
year:

![Most starred repositories]({{ "/assets/images/most-starred-php-repositories-2017.png" }})

And here's the PHP repositories that had the most contributions last year:

![Most contributed repositories]({{ "/assets/images/most-contributed-php-repositories-2017.png" }})

And finally, Marcel took the top 600 projects projects above, and determined
which other packages they depend on the most:

![Most used dependencies]({{ "/assets/images/most-used-php-dependencies-2017.png" }})

### Xdebug 2.6 ###

Xdebug 2.6 has [been released](https://derickrethans.nl/xdebug-26.html) and it
has a few cool new things:

* It can now provide insight into the PHP garbage collector
* The profiler collects information about memory usage and attaches a header to
the response to tell you the location of file it's profiling to.
* It can send errors and warning through to the IDE now


## Framework news ##

I found [this post](https://www.zenofcoding.com/2017/12/31/php-mvc-frameworks-preview-of-2018-phalcon-3-symfony-4-laravel-5-x-and-others/)
which gives a pretty great overview of progress of most of the PHP frameworks
last year, I'll add a bit below as well.

### Symfony 4 ###

[Symfony 4](https://symfony.com/blog/hello-symfony-4) was released at the end 
of last year, and it's awesome. A lot of people have written 
[blog posts](https://medium.com/@zawadzki.jerzy/symfony-4-new-hope-dbf99dde91d8)
about the [cool new features](https://medium.com/@zawadzki.jerzy/symfony-4-new-hope-dbf99dde91d8)
so I'll just do a quick recap of the big ones.

#### Project structure ####

The project structure has been really simplified to be more standardised. 

* It's not recommended to structure your app in separate bundles anymore, 
instead you organise the code into separate namespaces under `src/`.
* Bundles you depend on have their config organised and separated from each
other. This removes the need for a massive `config.yml`.

#### Dependency injection ####

Symfony now recommends you make all services private, this means you can't get
them from the container, you have to inject them. Which makes your code cleaner
and less of a nightmare to maintain.

Also, services are autowired. So you don't need to update `services.yml` every
time you create or change a service. It takes a bit to get used to this change
but once you do, you'll love it.

#### Symfony Flex ####

[Symfony Flex](https://symfony.com/doc/current/setup/flex.html) is really great.
It seems like magic but at it's heart, it's fairly straight forward. It's just 
a composer plugin which hooks into events fired during `composer update` and 
`composer install` to:

* Prefetch dependencies and make installing quicker; and
* Automagically configure bundles according to recipes

Also, to make things easier the Symfony team have built an official list of 
good bundles and given them easy to remember names. For example
`composer require orm` will install and configure Doctrine, because that's the
recommended ORM. You can always install something else if you prefer, but it's 
great to have this official list to easily get started.

#### No more Symfony Standard Edition ####

Symfony 4 comes super lightweight, with only the bare minimum dependencies.
Which makes it's a microframework that you can build up however you want.
This has caused Fabien to 
[remove the Standard Edition](https://symfony.com/blog/the-end-of-the-symfony-standard-edition)
which came with a bunch of extra dependencies like doctrine and twig, even
though you might not want them.

However, if you liked being able to run one command and get everything
you need then there's still a way to do that and it's even better.
[Symfony Packs](http://fabien.potencier.org/symfony4-unpack-the-packs.html)
are composer metapackages which bundle several dependencies together so you can
install them at once. An example is the `orm` pack that I mentioned above. 
which gives you the Doctrine core, DocrineBundle and the DoctrineMigrationsBundle.

#### Webpack Encore ####

[Webpack Encore](https://symfony.com/doc/current/frontend.html) is a pure JS
library you can add to Symfony 4. It gives you a simple and opinionated way to
build Webpack config files and integrate your JS frontend with the Symfony
backend.

### Silex end of life ###

Another change that Symfony 4 made is that it has killed Silex, with Fabien 
announcing [the end of Silex](https://symfony.com/blog/the-end-of-silex).
Since Silex mainly existed as a microframework alternative to Symfony, it's
no longer required in a Symfony 4 world.

### Laravel 5.6 ###

There's a great new version of Laravel out as well, again there have been 
[many people](https://laravel-news.com/laravel-5-6) writing about 
[cool new features](https://medium.com/pine-code/neat-features-in-laravel-from-2017-736096bdf5d2)
so here's a summary:

#### New Blade directives ####

There have been some [new additions](https://laravel-news.com/new-blade-directives-laravel-5-6)
to Blade, including a `@csrf` and `@method` directive which you can attach to
forms to give you easy CSRF protection and use methods other than GET and POST
for HTML forms (it does this little bit of magic with a hidden `method` form 
field).

#### No more Artisan optimize ####

The optimize command is [no longer required](https://laravel-news.com/laravel-5-6-removes-artisan-optimize)
since there have been massive improvements to the PHP opcache since the release
of 7.0.

#### Dynamic rate limiting ####

Previously in Laravel 5.5, you can only rate limit an endpoint with a maximum
number of total requests. But in 5.6 you can rate limit 
[individual users](https://laravel-news.com/laravel-5-6-dynamic-rate-limiting)
on specific authenticated routes.

#### Logging improvements ####

There have been [big changes](https://laravel.com/docs/5.6/logging) to the 
logging component. Which allow you to configure 'stacks' and separate handlers
to send log messages to different channels.


## Random things I thought were cool ##

* A really in depth look at comparing different ORM libraries in PHP:
[Objectively comparing ORM/DAL libraries](https://medium.com/@romaninsh/objectively-comparing-orm-dal-libraries-e4f095de80b5)

* The [PHP Security Advent Calendar](https://blog.ripstech.com/2017/php-security-advent-calendar/)
is a set of 24 code snippets you're presented with and have to find the 
security vulnerability.

* Ever thought the MAN pages were too hard to understand, or just took too long 
to read? Check out the [TL;DR man pages](https://laravel-news.com/tldr-pages).
A cli program which summarises the man pages for you.

* A really great and in depth look at build secure PHP web applications by
[Paragon Initiative](https://paragonie.com/blog/2017/12/2018-guide-building-secure-php-software).

* Want to "level up your PhpStorm game"? Check out [phpstorm.tips](http://phpstorm.tips). 
A collection of small tips and tricks you can use to get better at PhpStorm.

* I've been sending through a few PR's to open source repositories lately and I
stumbled across [this post](https://www.jeffgeerling.com/blog/2016/why-i-close-prs-oss-project-maintainer-notes)
by Jeff Geerling about what he looks for in a PR to one of his open source
repositories. Also [another post](https://mattstauffer.com/blog/how-to-contribute-to-an-open-source-github-project-using-your-own-fork/)
(which is a little old), which walks you through your first open source
contribution.

* The Vancouver PHP user group recently had 
[Q&A session](https://murze.be/vancouver-phps-qa-session-with-taylor-otwell)
with Taylor Otwell.

* [PHP-PM](https://symfony.fi/entry/php-pm-1-0-launches-with-official-docker-images)
is a recently released alternative to PHP-FPM, written entirely in PHP. It 
looks pretty interesting and I'd like to play with it one day.

* I always like reading about how to write code better. Recently I've foind these
articles about [paying down technical debt](https://blog.intracto.com/paying-technical-debt-how-to-rescue-legacy-code-through-refactoring)
and [modular application architecture](https://www.goetas.com/blog/modular-application-architecture-intro/)
which are both pretty good.

* I found [this post](https://hackernoon.com/im-harvesting-credit-card-numbers-and-passwords-from-your-site-here-s-how-9a8cb347c5b5)
particlarly entertaining. The author describes how easy it would be to harvest
credit card numbers from a large portion of sites on the internet. Just by 
creating a dodgy npm package and getting other popular packages to depend on 
it.

* While writing this blog post, I also found [3v4l.org](https://3v4l.org), which 
allows you run PHP code against almost every version of PHP ever released in one
go.

* A description of [setting up a Makefile](https://localheinz.com/blog/2018/01/24/makefile-for-lazy-developers/)
for PHP application. I love Makefiles, they're quick and easy and allow all the
commands you need to run in your project to come through a common interface.

* A super in depth look at [how sessions work in PHP](https://www.phparch.com/2018/01/php-sessions-in-depth/).

* An [explanation of CQRS](https://matthiasnoback.nl/2018/01/simple-cqrs-reduce-coupling-allow-the-model-to-evolve/)
which keeps popping up everywhere but until now I've never really understood it.


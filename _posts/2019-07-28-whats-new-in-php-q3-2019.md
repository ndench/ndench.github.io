---
title: What's new in PHP land? - Q3 2019
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
Recently, PHP 7.4 features have been finalised and development of PHP 8.0 continues.

## PHP

### Process changes

There have been a couple of RFC's passed recently which change the way any future RFCs are voted
on.

1. [Abolish narrow margins](https://wiki.php.net/rfc/abolish-narrow-margins) changes benchmark for
   acceptance of all future RFS to a 2/3 majority. They did this because previously some RFCs could
   pass with a 50%+1 majority while others required 2/3 and the rules that goverened this were
   "misleading and confusing".
2. [Abolish short votes](https://wiki.php.net/rfc/abolish-short-votes) increases the minimum voting
   period for future RFCs from 1 week to 2 weeks because there is no reason to squeeze votes into a
   single week and they don't want big features passed with only a week of voting.

### PHP 7.4

PHP 7.4 is now in feature freeze with Beta 3 being released last week. Now it will go through a
handful of release candidates before it's final release date of 
[November 28](https://wiki.php.net/todo/php74)! There is actually quite a lot 
[being released PHP 7.4](https://wiki.php.net/rfc#php_74), I've covered some of them my
[Q1]({% post_url 2019-01-30-whats-new-in-php-q1-2019 %}) and 
[Q2]({% post_url 2019-04-30-whats-new-in-php-q2-2019 %}) posts so I'll just cover the new ones 
here. Take a look at this very good overview on
[stitcher.io](https://stitcher.io/blog/new-in-php-74) for more details.

#### Numeric literal separator

You can add an underscore (`_`) anywhere you like in a numeric literal to help increase readability.
It applies to all supported numeric literal notations, see 
[the RFC](https://wiki.php.net/rfc/numeric_literal_separator) for more info.

```php
<?php

$threshold = 1_000_000_000;  // a billion!
$testValue = 107_925_284.88; // scale is hundreds of millions
$discount = 135_00;          // $135, stored as cents
```

#### Throwing exceptions in __toString()

I didn't know this but apparently you can't throw exception in `__toString()`. Until now. 
[This RFC](https://wiki.php.net/rfc/tostring_exceptions) points out that exceptions aren't allowed
in `__toString()` because string conversions are performed in many places that aren't equipped to
handle exceptions. However recoverable errors can still be thrown when converting un-convertable
variables so there's really no reason to prevent exceptions as well.

#### Properly calculating time differences across Daylight Saving Time transitions

Something else I recently learnt is that depending on how you create a DateTime, PHP might not be
able to correctly calculate additions and subtractions across Daylight Saving Time transitions. And
even if you do use the "correct" way, the result is still sometimes wrong because the edge case was
not sufficiently unit tested. However, moving forward - if you create your dates the "correct" way,
then all calculations will be correct.

```php
// PHP only knows the offset, not the timezone 
// so it has no idea if or when to apply Daylight Savings Time
$type1 = new DateTime('2011-09-13 14:15:16 -0400');

// Internally PHP stores dates created using the timezone abbreviation the same as $type1 above
// ie. it only knows the offset
$type2 = new DateTime('2011-09-13 14:15:16 EDT');

// This is the only way to create a DateTime such that PHP is able to make correct calculations 
// across Daylight Savigs Time transitions, because internally it actually stores the timezone
// not the offset.
$type3 = new DateTime('2011-09-13 14:15:16', new DateTimeZone('America/New_York'));

// This is also correct because it uses `date_default_timezone` from php.ini
$type3 = new DateTime('2011-09-13 14:15:16');
```

#### Escaping "?" in PDO

Some databases, namely PostgreSQL use the question mark character in operators. However it's
currently impossible to use thes operators with PDO because all `?` are treatedd as parameter
placeholder. [This RFC](https://wiki.php.net/rfc/pdo_escape_placeholders) makes it possible to
escape question marks by using a `??`, which passes a single question mark to database:

```php
<?php

$stmt = $pdo->prepare('SELECT * FROM tbl WHERE json_col ?? ?');
$stmt->execute(['foo']); 
```

Will execute the following query:

```sql
SELECT * FROM tbl WHERE json_col ? 'foo'
```

Since `??` is not valid syntax in PDO, there shouldn't be any BC breaks. However, if you have
defined `??` as a custom operator in your database, you will need to pass `????` though PDO in order
to use it.

#### Spread operator in array expansion

For a while now, you've been able to use the spread operator (`...`) to unpack an array and pass
it's values into a function:

```php

<?php

$arr = ['a', 'b', 'c'];

// Takes a variable number of string arguments
function foo(string ...$strings): void
{
    // Do something with the strings
}

// Pass each element in the array as a separate argument
foo(...$arr);
```

Now you can do that inside an array, as a better alternative to `array_merge`:

```php
<?php

$parts = ['apple', 'pear'];
$fruits = ['banana', 'orange', ...$parts, 'watermelon'];
// ['banana', 'orange', 'apple', 'pear', 'watermelon'];
```

See [the RFC](https://wiki.php.net/rfc/spread_operator_for_array) for details.

#### Deprecations

There has been a big list of deprecations in 7.4, allowing us to prepare for a lot of cruft being
removed in 8.0. In fact, there is [an RFC](https://wiki.php.net/rfc/deprecations_php_7_4) which
includes 14 separate deprecations, which were all passed. These were all relatively undocumented or
incorrect usage of functions, see the linked RFC for details.  However there are a few separate 
RFCs to deprecate specific functionalty, which I'll list below.

**PHP short opening tags**

PHP 7.0 completely removed most of [alternative PHP opening
tags](https://wiki.php.net/rfc/remove_alternative_php_tags), however, short opening tags (`<?`) were
exempt. Now in 7.4 they will be deprecated and completely removed in 8.0 because they clash with 
XML opening tags and require an INI directive, making them non-portable. See [the
RFC](https://wiki.php.net/rfc/deprecate_php_short_tags) for more information.

**Nested ternaries without explicit parenthesis**

Have you even seen a ternary this ungoodly?

```php
<?php

return $a == 1 ? 'one'
     : $a == 2 ? 'two'
     : $a == 3 ? 'three'
     : $a == 4 ? 'four'
               : 'other';
```

If you have these in your codebase, they are "almost certainly bugs" according [this
RFC](https://wiki.php.net/rfc/ternary_associativity). This is because in PHP this is
left-associative instead of right-associative like most other programming languages. Take a look at
the following example:

```php
<?php

// How PHP interprets the above ternary
return ((($a == 1 ? 'one'
     : $a == 2) ? 'two'
     : $a == 3) ? 'three'
     : $a == 4) ? 'four'
               : 'other';

// How most other languages interpret it
return $a == 1 ? 'one'
     : ($a == 2 ? 'two'
     : ($a == 3 ? 'three'
     : ($a == 4 ? 'four'
               : 'other')));
```


**Array access curly brace syntax**

Apparently you can use curly braces to access elements within an array, or characters in a string.
This has been deprecated in 7.4 since it's largely undocumented and has reduced functionality from
normal array syntax. Here's some examples taken from 
[the RFC](https://wiki.php.net/rfc/deprecate_curly_braces_array_access).

```php
<?php 

/*
 * You can use curly braces to access items in arrays or string
 */
$array = [1, 2];
echo $array[1]; // prints 2
echo $array{1}; // also prints 2
 
$string = "foo";
echo $string[0]; // prints "f"
echo $string{0}; // also prints "f"

/*
 * You can NOT use curly braces to append to an array
 */
$array[] = 3;
echo $array[2]; // prints 3
 
$array{} = 3; // Parse error: syntax error, unexpected '}'

/*
 * You can NOT use curly braces to create an array
 */
$array = [1, 2]; // works
 
$array = {1, 2}; // Parse error: syntax error, unexpected '{''}'
```

## PHP 8.0

In my [Q2 post]({% post_url 2019-04-30-whats-new-in-php-q2-2019 %}) I covered most of the accepted
features for 8.0. I did mention that arrow functions were coming it 8.0, but they were actually
accepted for 7.4, so we get much sooner! There has also been one more accepted RFC for 8.0 and is to
[always generate fatal errors for incompatible method
signatures](https://wiki.php.net/rfc/lsp_errors). Currently, if you implement a method that has an
incompatible method signature to the interface or abstract class it's declared in, you get a fatal 
error. However, if the method was declared in a parent class and you're overriding it, then you only
get a warning. These will all throw fatal errors as of 8.0.

## Cool stats

### PHP versions stats

The [May edition](https://blog.packagist.com/php-versions-stats-2019-1-edition/) of PHP Versions
Stats has been released by Packagist. When someone does a `composer install`, Composer tells
packagist.org what PHP version is being run. This gives us a good understanding of what versions are
in use, but it skews the data by ignoring all the projects that aren't using Composer (eg. a lot 
of WordPress sites).

![PHP version usage]({{ "/assets/images/php-version-stats-2019-01.png" }})

![PHP versions over time]({{ "/assets/images/php-versions-over-time-2019-01.png" }})

### Framework trends

[Tomas Votruba](https://www.tomasvotruba.cz/php-framework-trends/)
tracks trends in PHP framework installations by pulling data from the Packagist API.
It really is fascinating to see just how many downloads each framework gets.

![PHP framework trends]({{ "/assets/images/framework-trends-jul-2019.png" }})

### JetBrains dev ecosystem survey

JetBrains ran a [developer ecosystem survey](https://www.jetbrains.com/lp/devecosystem-2019/php/) 
this year and they found some fascinating data about PHP:

* 57% of respondents use a supported version of PHP (7.2 or 7.3)
* Only 14% of respondents use 5.x
* 50% of respondents use Laravel while only 23% use Symfony (this is quite different to the
    framework trends shown above)


## Frameworks

### ReactPHP

ReactPHP has [release v1.0.0](https://www.lueck.tv/2019/announcing-reactphp-lts) as an LTS version
with 24 months support. This is the first stable release of ReactPHP since it was created 7 years
ago.

### Symfony

SymfonyCloud [moved from Early Access to General
Availability](https://symfony.com/blog/symfonycloud-from-early-access-to-general-availability). This
provides a "batteries included" platform to host your Symfony applications.

### Laravel

It's been a big quarter for Laravel:

* [Laravel v6 was released](https://laravel-news.com/laravel-v6-announcement). This doesn't include
    any paradigm shifting features, but instead moves Laravel to using SemVer which is amazing.
* [Laravel Nova was released](https://medium.com/@taylorotwell/introducing-laravel-nova-7df0c9f67273).
    Nova allows you to create beautiful customised admin panels with minimum effort.
* [Laravel Vapor was released](https://mattstauffer.com/blog/introducing-laravel-vapor/) which
    provides a [serverless
    platform](https://divinglaravel.com/what-is-aws-lambda-and-how-laravel-vapor-uses-it) 
    to host your Laravel applications.

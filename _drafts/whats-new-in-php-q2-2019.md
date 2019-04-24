---
title: What's new in PHP land? - Q2 2019
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
The biggest news recently is the development of PHP 7.4 and 8.0!

## Language News

PHP 7.4 and 8.0 are both being [developed in parallel](https://externals.io/message/103862) with a
number of of really great features already implemented.

### PHP 7.4 Features

There is quite a lot of [features going into PHP 7.4](https://wiki.php.net/rfc#php_74), some of them
I mentioned in my [last PHP news post]({% post_url 2019-01-30-whats-new-in-php-q1-2019 %}) but here
are some rew ones:

#### Weak References

[Weak References](https://wiki.php.net/rfc/weakrefs) allow you to keep a reference to an object
without preventing the garbage collector from destroying it. Solutions for this already exist but
have been rendered unusable by PHP 7.3. They're useful for cache like structures, allowing the
garbage collector to uncache things for you. Here's an example:

```php
<?php
function checkReference(WeakReference $ref): void
{
    if (null !== $ref->get()) {
        echo "Object still exists!\n";
        var_dump($ref->get());
    } else {
        echo "Object is dead!\n";
    }
}

$foo = new Foo();

$ref = WeakReference::create($foo);

checkReference($ref); // Object still exists!

// Somewhere else our object is removed
unset($foo);

checkReference($ref); // Object is dead!
// Cache miss, we'll have to re-create it

```

#### mb_str_split

We already have `mb_split` which allows splitting by a regex, but this allows splitting a multibyte
string into set chunk sizes. Here's an example from [the rfc](https://wiki.php.net/rfc/mb_str_split):

```php
<?php 
print_r(mb_str_split("победа", 2));
 
--EXPECT--
 
Array
(
    [0] => по
    [1] => бе
    [2] => да
)
```

#### __serialize() and __unserialize()

We get two new magic methods which we can use instead of the current ways to serialize objects. 
These methods are added because the current ways being the `Serializable` interface and the 
`__sleep()` and `__wakeup()` methods are difficult to use and easily introduce bugs. See
[the rfc](https://wiki.php.net/rfc/custom_object_serialization) for more info.

```php
<?php

// Returns array containing all the necessary state of the object.
public function __serialize(): array;
 
// Restores the object state from the given data array.
public function __unserialize(array $data): void;
```

### PHP 8.0 features

#### Arrays starting with negative index

Currently, all the following result in unexpected behaviour:

```php
<?php

$a = array_fill(-2, 3, true);
$b = [-2 => true, true, true];
$c = [-2 => true, true, true];
$d[-2] = true;
$d[] = true;
$d[] = true;
```

The keys following the negative number start at 0 and increment from there, ie. they skip the next
negative numbers:

```
array(3) {
  [-2]=>
  bool(true)
  [0]=>
  bool(true)
  [1]=>
  bool(true)
}
```

Post 7.4 they will work as you would expect:

```
array(3) {
  [-2]=>
  bool(true)
  [-1]=>
  bool(true)
  [0]=>
  bool(true)
}
```

See [the rfc](https://wiki.php.net/rfc/negative_array_index) for more info.

#### Consistent type errors for internal functions

Most of the internal PHP functions will throw a warning and return null (or some other ridiculous
value) when you pass in parameters of an illegal type. [This rfc](https://wiki.php.net/rfc/consistent_type_errors)
will bring internal functions into alignment with user-defined functions and make them throw a
`TypeError`.

#### JIT compiler

The performance improvements in PHP 7 were initiated by attempts to implement a JIT compiler, but
were ultimately not released because the improvements made without it were much more substantial.
However, we are now in a place where the performance of PHP can no longer be improved without JIT so
[this rfc](https://wiki.php.net/rfc/jit) will bring it into 8.0.

#### Arrow functions v2

[Arrow functions](https://wiki.php.net/rfc/arrow_functions_v2) are finally coming to PHP! They will
dramatically improve the syntax of closures from this:

```php
<?php

function array_values_from_keys($arr, $keys) {
    return array_map(function ($x) use ($arr) { return $arr[$x]; }, $keys);
}
```

To this:

```php
<?php

function array_values_from_keys($arr, $keys) {
    return array_map(fn($x) => $arr[$x], $keys);
}
```


* PSR 14 was accepted <https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-14-event-dispatcher.md>
* PHPUnit 8 was released <https://phpunit.de/announcements/phpunit-8.html>
* Symfony push notifications <https://symfony.com/blog/symfony-gets-real-time-push-capabilities>
* Psalm support laravel <https://medium.com/@muglug/announcing-psalm-support-for-laravel-8a0fc507e220>
* Laravel SQL injection <https://blog.laravel.com/unique-rule-sql-injection-warning>
* And again <https://stitcher.io/blog/unsafe-sql-functions-in-laravel>
* RCE vuln in TCPDF <https://www.zdnet.com/article/severe-security-bug-found-in-popular-php-library-for-creating-pdf-files/>
* Wordpress minimum version to 5.6 <https://wptavern.com/wordpress-ends-support-for-php-5-2-5-5-bumps-minimum-required-php-version-to-5-6>

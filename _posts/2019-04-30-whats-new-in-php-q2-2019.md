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
number of really great features already implemented.

### PHP 7.4 Features

There is quite a lot of [features going into PHP 7.4](https://wiki.php.net/rfc#php_74), some of them
I mentioned in my [last PHP news post]({% post_url 2019-01-30-whats-new-in-php-q1-2019 %}) but here
are some rew ones:

#### Covariance and contravariance

Currently, PHP is missing some really core object-oriented behaviours:

* Contravariance
    * replacing an object with it's parent without breaking anything 
    * widening type parameters
* Covariance
    * replace an object with it's children without breaking anything 
    * tightening type parameters

Fortunately, this feature is coming in 7.4, here are some examples from 
[the rfc](https://wiki.php.net/rfc/covariant-returns-and-contravariant-parameters):


We can widen the type for method parameters, because anything that expects to be using the 
`Concatable` interface will successfully be able to use the `Collection` class when passing in
`Iterator` types:
```php
<?php

interface Concatable {
    function concat(Iterator $input); 
}
 
class Collection implements Concatable {
    // accepts all iterables, not just Iterator
    function concat(iterable $input) {/* . . . */}
}
```

We can tighten the return type because anything expecting the `Factory` interface can successfully
use the `UserFactory` because it returns a subtype of `object`:
```php
<?php

interface Factory {
    function make(): object;
}
 
class UserFactory implements Factory {
    function make(): User;
}
```


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

$c = []
$c[-2] = true;
$c[] = true;
$c[] = true;
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

**Update**
Arrow function have actually been accepted for 7.4!

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

## Other news

### PSR 14 accepted

[PSR 14](https://github.com/php-fig/fig-standards/blob/4a10f033b4e5690ad90d656281e6e72b82c0626e/accepted/PSR-14-event-dispatcher.md)
was accepted. It defines a standard for event dispatchers and listeners:

```php
<?php

namespace Psr\EventDispatcher;

interface EventDispatcherInterface
{
    /**
     * Provide all relevant listeners with an event to process.
     *
     * @param object $event
     *   The object to process.
     *
     * @return object
     *   The Event that was passed, now modified by listeners.
     */
    public function dispatch(object $event);
}
```

```php
<?php

namespace Psr\EventDispatcher;

interface ListenerProviderInterface
{
    /**
     * @param object $event
     *   An event for which to return the relevant listeners.
     * @return iterable[callable]
     *   An iterable (array, iterator, or generator) of callables.  Each
     *   callable MUST be type-compatible with $event.
     */
    public function getListenersForEvent(object $event) : iterable;
}
```

```php
<?php

namespace Psr\EventDispatcher;

interface StoppableEventInterface
{
    /**
     * Is propagation stopped?
     *
     * This will typically only be used by the Dispatcher to determine if the
     * previous listener halted propagation.
     *
     * @return bool
     *   True if the Event is complete and no further listeners should be called.
     *   False to continue calling listeners.
     */
    public function isPropagationStopped() : bool;
}
```

### PHPUnit 8 released

Containing mainly deprecations and dropping support for PHP 7.1, 
[PHPUnit 8 was released](https://github.com/sebastianbergmann/phpunit/blob/130104cf796a88dd1547dc5beb8bd555c2deb55e/ChangeLog-8.0.md#800---2019-02-01).

### Laravel gets Psalm support

The best static analyser (IMO) has [released support for Laravel](https://medium.com/@muglug/announcing-psalm-support-for-laravel-8a0fc507e220).
It's been a long time coming, mainly because of all the magic and static calls in Laravel, but it's
here and it will drastically improve your codebase.

### SQL injection in Laravel

There were a couple of SQL injection vulnerabilities discovered in Laravel. Both of them come down
to the developer passing untrusted data into query builders so if you follow best practices and
don't do this, then you're fine.

The first one has been "fixed" by adding a warning to the documentation to let the developer know
not to pass in untrusted data. Here is an example from the [laravel blog
post](https://blog.laravel.com/unique-rule-sql-injection-warning) on the issue:

```
Rule::unique('users')->ignore($user->id);
```

If instead of using `$user->id` in the above function call, you use some user provided data, then
you are vulnerable to an SQL injection.

The second one, described in a [stitcher.io
post](https://stitcher.io/blog/unsafe-sql-functions-in-laravel) relates to querying JSON data in
SQL.

You write this:
```
Blog::query()
    ->addSelect('title->en');
```

Laravel converts it to this:
```
SELECT json_extract(`title`, '$."en"') FROM blogs;
```

But again, if you get `'title->en'` from user supplied input, you're vulnerable. Although, this
particular vulnerability is fixed in Laravel 5.8.11.

It's important to note, that while it is the frameworks job to help you build fast and secure
applications, quite a lot of responsibility still falls on the developer to make sure they're
following best practices.

### Remote code execution in TCPDF

A [severe security vulnerability was found in
TCPDF](https://www.zdnet.com/article/severe-security-bug-found-in-popular-php-library-for-creating-pdf-files/)
allowing an attacker to achieve the holy grail of attacks - a remote code execution. While this
vulnerability was fixed in version 6.2.20, it was accidentally reintroduced so you have to use
version 6.2.22 to be safe.

### WordPress minimum PHP version

WordPress has [ended support for 5.2
5.5](https://wptavern.com/wordpress-ends-support-for-php-5-2-5-5-bumps-minimum-required-php-version-to-5-6)
so you must now be using 5.6 or above. While this is absolutely great news that we're finally
raising the bar, we should keep in mind that version 5.6 has been unsupported since the beginning of
the year. Let's hope they will soon enforce a minimum supported version!

### Symfony gets push capabilities

Symfony has released the [Mercure
component](https://symfony.com/blog/symfony-gets-real-time-push-capabilities) which allows
integration with a Mercure Hub - an open protocol for servers to publish updates to clients. You
either have to run your own Mercure Hub or use a third party service.

You then subscribe to topics using the vanilla JavaScript `EventSource` and publish updates to the
topics from PHP. `EventSource` opens a persistent connection to the Mercure Hub and registers an
event handler for updates.

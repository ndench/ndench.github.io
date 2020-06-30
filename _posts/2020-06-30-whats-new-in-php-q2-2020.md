---
title: What's new in PHP land? - Q2 2020
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
Recently, we've had an absolute ton of progress on PHP 8.0.

In fact, there has been so much progress on PHP 8.0 that I am under
no illusions on how the PHP core team kept entertained during COVID-19
lockdows! I've selected my favourite and most important changes for this 
post.

## PHP

Jordi Boggiano released the latest [PHP Version Stats](https://blog.packagist.com/php-versions-stats-2020-1-edition/)
back in May.

![PHP Version Usage]({{ "/assets/images/php-version-stats-2020-01.png" }})

The main change here has been a 14% uptick in PHP 7.4 usage, with most of that
coming out of the 7.2 and 7.3 usage as of November last year.

![PHP Versions Over Time]({{ "/assets/images/php-versions-over-time-2020-01.png" }})

Backing this statement up, we can see that 7.0 has less usage than 5.6 but only just.
The good news is that 5.6 usage is still trending downward, albeit very slowly.

### PHP 8.0

It appears that PHP core developers kept themselves entertained during COVID 
isolation by pushing forward on PHP 8.0. Back in March there was only a handful
of implemented features but now the list is huge and it's still growing.

We have a release date of November 26! The first alpha version is already out
and the feature freeze comes in on August 4.

![PHP 8.0 Release Schedule]({{ "/assets/images/php8-release.png" }})

#### Attributes
The accepted [RFC](https://wiki.php.net/rfc/attributes_v2) and another accepted
[RFC proposing ammendments](https://wiki.php.net/rfc/attribute_amendments).

You might know these by another name, "Annotations". We currently have a widely
used third-party implementation: Doctrine Annotations. For this reason, it's been
decided to use the name "Attributes" to avoid conflicts.

The good news is, we finally have Attributes baked into the language and we don't
have to use docblocks to execute code! You can define an attribute in many places
including classes, methods, properties, parameters and more.

Attributes have the following syntax:

```php
<?php

<<ExampleAttribute>>
class Foo
{
    <<ExampleAttribute>>
    public const FOO = 'foo';
 
    <<ExampleAttribute>>
    public $x;
 
    <<ExampleAttribute>>
    public function foo(<<ExampleAttribute>> $bar) { }
}
``` 

A more concrete and recognisable example is a Doctrine entity:

```php
<?php

use Doctrine\ORM\Attributes as ORM;
use Symfony\Component\Validator\Constraints as Assert;
 
<<ORM\Entity>>
class User
{
    <<ORM\Id>><<ORM\Column("integer")>><<ORM\GeneratedValue>>
    private $id;
 
    <<ORM\Column("string", ORM\Column::UNIQUE)>>
    <<Assert\Email(array("message" => "The email '{{ value }}' is not a valid email."))>>
    private $email;
 
    <<ORM\ManyToMany(Phonenumber::class)>>
    <<ORM\JoinTable("users_phonenumbers")>>
    <<ORM\JoinColumn("user_id", "id")>>
    <<ORM\InverseJoinColumn("phonenumber_id", "id", JoinColumn::UNIQUE)>>
    private $phonenumbers;
}
```

Attributes are PHP classes with the `<<Attribute>>` attribute:

```php
<?php

namespace Doctrine\ORM\Attributes;
 
<<Attribute>>
class Column
{
    public $type;
 
    public function __construct(string $type)
    {
        $this->type = $type;
    }
}
```

Shortly after the [Attributes RFC](https://wiki.php.net/rfc/attributes_v2)
was accepted, an [ammendments RFC](https://wiki.php.net/rfc/attribute_amendments)
was proposed and accepted which allows Attributes to be grouped:

```php
<?php

// Ungrouped
<<Attr1>><<Attr2>>
class Example
{
    <<Attr2("foo")>>
    <<Attr2("bar")>>
    public function test()
    {
    }
}

// Grouped
<<Attr1, Attr2>>
class Example
{
    <<Attr2("foo"),
      Attr2("bar")>>
    public function test()
    {
    }
}
```

And to validate Attributes and ensure they are only used in the correct location:
```php
<?php

namespace Doctrine\ORM\Attributes;
 
<<Attribute(Attribute::TARGET_PROPERTY)>>
class Column
{
    public $type;
 
    public function __construct(string $type)
    {
        $this->type = $type;
    }
}
```

And now there is another [RFC proposing a diffreent syntax](https://wiki.php.net/rfc/shorter_attribute_syntax).
Voting on this RFC closes on July 1 and it looks like we'll get the `@@Attribute` syntax which is much nicer than
`<<Attribute>>`` and allows nested attributes:

```php
<?php

use Doctrine\ORM\Attributes as ORM;
use Symfony\Component\Validator\Constraints as Assert;
 
@@ORM\Entity
class User
{
    @@ORM\Id
    @@ORM\Column("integer")
    @@ORM\GeneratedValue
    private $id;
 
    @@ORM\Column("string", ORM\Column::UNIQUE)
    @@Assert\Email(array("message" => "The email '{{ value }}' is not a valid email."))
    private $email;
 
    @@ORM\ManyToMany(Phonenumber::class)
    @@JoinTable(
        "users_phonenumbers",
        @@JoinColumn("User_id", "id"),
        @@JoinColumn("phonenumber_id", "id"),
    )
    private $phonenumbers;
}
```

Attributes are fetched with Reflection methods. Very similar, but much easier
than fetching annotations from the doc block because they don't need to be 
manually parsed.

```php
<?php

$reflector = new \ReflectionClass(User::class);
$idProperty = $reflector->getProperty('id');
$attrs = $idProperty->getAttributes();

foreach ($attrs as $attriubute) {
    $attribute->getName(); // "Doctrine\ORM\Attributes\Column"
    $attribute->getArguments(); // ["integer"]
    $attribute->newInstance();
        // object(Doctrine\ORM\Attributes\Colunm)#1 (2) {
        //  ["type":"User":private]=> string(11) "integer"        
        // }
}
```


#### JIT

[RFC](https://wiki.php.net/rfc/jit)

Probably the most anticipated feature of PHP 8 is the JIT, which is a Just In Time
compiler. Initially PHP was going to get a JIT in version 7, however there was a lot 
of tweaks and fixes required to effectively implement a JIT and it just so happeded that
those tweaks and fixes provided most of the performance gains. As a result, those gains 
were released on their own in PHP 7 and the JIT moved back to PHP 8.

To understand the benefit provided by JIt, you need to know how PHP code is executed:

![PHP executino diagram]({{ "/assets/images/php-execution-diagram.png" }})

PHP code is first broken down into tokens using a process called "Lexing", these
tokens are then parsed into an Abstract Syntax Tree (AST) which allows the compiler
to understand the code. The compiler takes the AST and produces OPcodes which are
then passed to the Zend VM to get executed on the CPU. Since PHP 5.5 we've been
able to cache these OPcodes after the compilation step to prevent having to lex and
parse the same code many times, but the Zend VM still has to interperet the OPcodes
and execute them.

With the JIT enabled, the Zend VM will identify sections of code that are executed 
many times. These "hot" code parts will be compiled directly into machine code and
stored alongside the OPcodes. The next time that section of code is executed, it
can bypass the Zend VM and be executed directly on the CPU.

The main performance gains from the JIT will likely be to non-web code. Web related code
is often bound by I/O calls (ie. databases, filesystems, etc) and the JIT will only speed
up CPU bound code. However, the JIT does open the doors for PHP to be used for many 
things you wouldn't want to use it for in the past. Think image and data manipulation,
long running processes and even machine learning.


#### Construction property promotion

[RFC](https://wiki.php.net/rfc/constructor_promotion)

Classes carry a lot of boilerplate code in PHP, one way of cutting this down is with
property promotion. This allows you to declare and define a property directly in the
constructor.

```php
<?php

// Without property promotion
class User
{
    public string $name;

    public string $email;

    /** @var string[] */
    public array $phoneNumbers;

    public function __construct(
        string $name, 
        string $email, 
        array $phoneNumbers
    ) {
        $this->name = $name;
        $this->email = $email;
        $this->phoneNumbers = $phoneNumbers;

    }
}

// With property promotion
class User
{
    public function __construct(
        public string $name, 
        public string $email, 
	/** @var string[] */
        public array $phoneNumbers,
    ) {}
}
```

A few caveats:
* Can be used to declare/assign `public`, `protected` and `private` properties
* Only allowed in constructors
* Can skip types if you like
* Can only have simple default values like before, ie. no calling functions
* Can combine promoted and non-promoted properties in the same class
* Can have doc commments and annotations on promoted properties
* Cannot promote properties in abstract classes, but you can in traits
* Cannot use varidic propreties, eg. `public string ...$names` because `$names` is actually an array, not a string.




#### Type improvements

[Mixed type RFC](https://wiki.php.net/rfc/mixed_type_v2) 

[Static return type RFC](https://wiki.php.net/rfc/static_return_type)

[Union type RFC](https://wiki.php.net/rfc/union_types_v2)

There have been quite a few type improvements in PHP 8. We can now use union types, 
the `mixed` type and the `static` return type.

```php
<?php

class Dog
{
    public function breed(): static
    {
        return new static();
    }

    abstract public function speak(): mixed;
}

class Husky extends Dog
{
    public function speak(): Growl|Howl|Bark // Liskov substitution since PHP7.4
    {
        if ($this->isHungry()) {
            return new Growl();
	}

	if ($this->isExcited()) {
	    return new Howl();
	}

	return new Bark();
    }
}

$zara = new Husky();

// Typed as "Husky" using `static' return type
// Typed as "Dog" using `self` return type
$puppy = $zara->breed(); 
```


#### String functions

[str_contains RFC](https://wiki.php.net/rfc/str_contains) 

[str_starts_with & str_ends_with RFC](https://wiki.php.net/rfc/add_str_starts_with_and_ends_with_functions)

It's only taken 25 years, but PHP finally has canonical functions to check if a string
contains, starts with or ends with another string.

```php
<?php

$string = "abc";

// New way
if (str_contains($string, "b")) {
}

// Old way
// Note: Need to ensure strict comparison here, in case the 
// position is at index 0
if (strpos($string, "b") !== false) {
}


// New way
if (str_starts_with($string, "ab")) {
}

// Old way
$prefix = "ab";
if (substr($string, 0, strlen($prefix)) ==$prefix) {
}


// New way
if (str_ends_with("abc", "bc")) {
}

// Old way
$suffix = "bc"
if (substr($haystack, -strlen($suffix)) == $suffix) {
}
```

#### Exceptions

[Non-capturing catches RFC](https://wiki.php.net/rfc/non-capturing_catches)

[Throw expression RFC](https://wiki.php.net/rfc/throw_expression)

There are also a couple of changes to to the way we can use exceptions.
The ablility to catch an exception and ignore the actual exception object.
This is useful when the type of the exception is enough information for you
to determine how to handle it and you don't need the rest of the data contained
in the exception object.

```php
<?php

try {
    changeImportantData();
} catch (PermissionException $ex) {
    echo "You don't have permission to do this";
}
```

Internally, PHP thinks of different constructs as either "expressions" or "statements".
There are some places that you're not allowed to use "statements", only expressions.
Throwing exceptions has been considered a "statement" which means you aren't able
to throw exceptions in certain places, like arrow functions and ternaries. So the
following examples will work correctly as of PHP 8.0, but will throw a FatalError
in previous versions.

```php
<?php

$fn = fn() => throw new \Exception('oops');

$value = isset($_GET['value'])
    ? $_GET['value']
    : throw new \InvalidArgumentException('value not set');
```

#### get_debug_type()

`get_debug_type()` is an alternative to `gettype()` which actually
returns something useful:

<table>
<thead>
<tr><th>Value</th><th>get_debug_type()</th><th>gettype()</th></tr>
</thead>
<tbody>
<tr><td>0</td><td>int</td><td>integer</td></tr>
<tr><td>0.1</td><td>float</td><td>double</td></tr>
<tr><td>true</td><td>bool</td><td>boolean</td></tr>
<tr><td>"hello world"</td><td>string</td><td></td></tr>
<tr><td>[]</td><td>array</td><td></td></tr>
<tr><td>null</td><td>null</td><td>NULL</td></tr>
<tr><td>new Foo\Bar()</td><td>Foo\Bar</td><td>object</td></tr>
<tr><td>new class() {}</td><td>class@anonymous</td><td>object</td></tr>
<tr><td>tmpfile()</td><td>resource (stream)</td><td>resource</td></tr>
<tr><td>curl_init()</td><td>resource (curl)</td><td>resource</td></tr>
<tr><td>curl_close($ch)</td><td>resource (closed)</td><td></td></tr>
</tbody>
</table>


#### Weakmaps

[RFC](https://wiki.php.net/rfc/weak_maps)

In PHP 7.4 we got support for Weak References. This allows us to store
a reference to some object without preventing the garbage collector from
deleting it. Weak References on their own are of limited usefulness, so
now we have WeakMaps which allow us to build caches:

```php
<?php

class Foo 
{
    private WeakMap $cache;
 
    public function getSomethingWithCaching(object $obj): object
    {
        return $this->cache[$obj]
           ??= $this->computeSomethingExpensive($obj);
    }
}
```

This is very useful for the likes of ORMs, which often implment
their own caching.


#### Breaking changes

There are been quite a few breaking changes in 8.0, ranging from
won't affect much at all, to will probably make it hard to upgrade
(especially for older projects). Here are some that I think are
worth mentioning:

* Ensure correct signatures of magic methods [RFC](https://wiki.php.net/rfc/magic-methods-signature)
    * Until now, it was possible to declare `public function __get(string $name): void`
* Method signatures in abstract methods defined in traits are now enforced [RFC](https://wiki.php.net/rfc/abstract_trait_method_validation)
    * Previously, you could completely change the method signature of an abstract method that comes from a trait
* `curl_*()` methods accept and return `CurlHandle` objects instead of `resource`
    * Use `$handle !== false` instead of `!is_resource($handle)`
    * This snuck through without an RFC...


## Composer 2

Composer version 2 is just around the corner. The alpha2 version is out and you can test it.
It comes with a few great new features, here are my favourites.

* Faster download times
    * All downloads now run in parallel and offer quite a speed boost.
* Platform check - ensure the current platform is supported
    * `vendor/composer/platform_check.php` is created during `composer install`
    * It ensures the the platform running the code is suppored (ie. has correct PHP version and extensions)
* `--ignore-platform-req [req]` to selectively ignore specfic platform requirements instead of all of them
    * eg. Ignore only the PHP version requirement and nothing else with `--ignore-platform-req php`
* `--dry-run` for add/remove
    * This was previously only available on update
* PEAR repository type is removed
    * You can no longer install custom PEAR packages
    * You can still install PEAR packages hosted on php.net

You can find out more about [Composer v2 here](https://php.watch/articles/composer-2).

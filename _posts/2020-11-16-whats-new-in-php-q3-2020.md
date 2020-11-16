---
title: What's new in PHP land? - Q3 2020
categories: brisphp
tags: brisphp php news
---

I co-organise the [BrisPHP Meetup](https://www.meetup.com/BrisPHP/)
and at the start of every meetup I give a quick talk on recent news and 
other interesting things that have been happening in the PHP world.
This issue is all about PHP 8.0, Laravel 8 and Composer 2.

### PHP Versions

PHP 8.0 is less than 2 weeks away, it will go live on the 
[26th of November](https://wiki.php.net/todo/php80)!

![PHP 8.0 Release Schedule]({{ "/assets/images/php8-release.png" }})

Additionally, there is also less than 2 weeks of security support left for PHP 7.2.
Updating to 7.3 or 7.4 is quite seamless, so make sure you do ASAP!

![PHP Version Support]({{ "/assets/images/php-version-support-2020-11.png" }})

#### Shorter attributes

[RFC](https://wiki.php.net/rfc/shorter_attribute_syntax_change)

Setting a new record for the number of accepted RFCs for a single feature, we have
a new syntax for attributes. The 4th accepted attribute RFC changes attributes from
`@@` to `#[]`.

The main reason behind changing this again are:
- The `@@` syntax turned out to be harder than originally anticipated 
    (due to `@` already being a valid token on it's own)
- The `@@` syntax removed the ability to group annotations, which was in a previously
    accepted RFC
- The `@@` syntax does not have a closing delimiter, which is inconsistent with other 
    language features
- The `#[]` gives forward compatibility, ie. annotations can exist in code that is run
    on older language versions

The RFC shows an example of a doctrine entity with the new syntax:

```php
<?php

use Doctrine\ORM\Attributes as ORM;
use Symfony\Component\Validator\Constraints as Assert;
 
#[
  ORM\Entity,
  ORM\Table("user")
]
class User
{
    #[ORM\Id, ORM\Column("integer"), ORM\GeneratedValue]
    private $id;
 
    #[ORM\Column("string", ORM\Column::UNIQUE)]
    #[Assert\Email(["message" => "The email '{{ value }}' is not a valid email."])]
    private $email;
}
```


#### Match expression

[RFC](https://wiki.php.net/rfc/match_expression_v2)

This new expression is a direct competitor of the `switch` statement. It gives all the advantages
with none of the disadvantges, namely:
- no type coercion
- exception if the parameter does not match any branch
- no need for a `break` -> can't fallthrough to the next branch

The example from the RFC shows how much clearer a `match` is when compared to a `switch`:

```php
<?php

// Before
switch ($this->lexer->lookahead['type']) {
    case Lexer::T_SELECT:
        $statement = $this->SelectStatement();
        break;
 
    case Lexer::T_UPDATE:
        $statement = $this->UpdateStatement();
        break;
 
    case Lexer::T_DELETE:
        $statement = $this->DeleteStatement();
        break;
 
    default:
        $this->syntaxError('SELECT, UPDATE or DELETE');
        break;
}
 
// After
$statement = match ($this->lexer->lookahead['type']) {
    Lexer::T_SELECT => $this->SelectStatement(),
    Lexer::T_UPDATE => $this->UpdateStatement(),
    Lexer::T_DELETE => $this->DeleteStatement(),
    default => $this->syntaxError('SELECT, UPDATE or DELETE'),
};
```

#### Named parameters

[RFC](https://wiki.php.net/rfc/named_params)

Named parameters allow us to pass parameters to functions by their name instead of their position
in the parameter list. You can combine both of these approaches, but you cannot specify a 
positional paramater after a named one. A simple example from the RFC shows the main advantages:

```php
<?php
// Without named parameters
htmlspecialchars($string, ENT_COMPAT | ENT_HTML401, 'UTF-8', false);

// With named parameters
htmlspecialchars($string, double_encode: false);
```

Using named arguments makes the code more readable, ie. the boolean flag is self-documented.
It also makes it possible to skip over parameters which have default values.

Value objects or DTOs often either have large parameter lists with many default values,
or take a single `$options` associative array which is then parsed in the constructor.
Using named parameters can greatly improve the API of any large value object.


## Laravel 8

Laravel 8 has [been released](https://laravel.com/docs/8.x/releases#laravel-8) and it 
contains a bunch of cool new features:

- Jetstream -> scaffolding to make it quicker to start a new Laravel project. Comes with
    user management and API support built in, and your choice of Liveware or Inertia for
    the frontend
- New `app/Models` directory in the application skeleton to help organise your models
- Squash migrations into a single SQL file
- Improved rate limiting with much more flexibility
- Time testing helpers to easily manipulate the current time in tsets
- Job batching, with support for `then`, `try`, `catch`, `finally`

    ```php
    <?php

    $batch = Bus::batch([
        new ProcessPodcast(Podcast::find(1)),
        new ProcessPodcast(Podcast::find(2)),
        new ProcessPodcast(Podcast::find(3)),
        new ProcessPodcast(Podcast::find(4)),
        new ProcessPodcast(Podcast::find(5)),
    ])->then(function (Batch $batch) {
        // All jobs completed successfully...
    })->catch(function (Batch $batch, Throwable $e) {
        // First batch job failure detected...
    })->finally(function (Batch $batch) {
        // The batch has finished executing...
    })->dispatch();
    ```
  
- Model factories are now class based

    ```php
    <?php
    // database/factories/UserFactory.php

    // Old way
    $factory->define(App\User::class, function (Faker $faker) {
        return [
            'name' => $faker->name,
            'email' => $faker->unique()->safeEmail,
            'email_verified_at' => now(),
            'password' => 'not a real password',
            'remember_token' => Str::random(10),
        ];
    });


    // New way
    class UserFactory extends Factory
    {
        /**
         * The name of the factory's corresponding model.
         *
         * @var string
         */
        protected $model = User::class;

        /**
         * Define the model's default state.
         *
         * @return array
         */
        public function definition()
        {
            return [
                'name' => $this->faker->name,
                'email' => $this->faker->unique()->safeEmail,
                'email_verified_at' => now(),
                'password' => 'not a real password',
                'remember_token' => Str::random(10),
            ];
        }
    }
    ```

    ```php
    <?php
    // Old way
    $users = factory(App\User::class, 3)->make();

    // Nwe way
    $users = User::factory()->count(3)->make();
    ```


## Composer 2

Composer version 2 is [now available](https://blog.packagist.com/composer-2-0-is-now-available/)!
It's most anticipated feature being a massive preformance improvement:

![Composer 2 Performance Improvements]({{ "/assets/images/composer-2-speed-improvements.png" }})

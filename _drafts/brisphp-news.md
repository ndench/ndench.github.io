---
title: BrisPHP News - Q3 2018
categories: brisphp
tags: brisphp php news
---

- A look at Json eror handling in 7.3: <https://laravel-news.com/php-7-3-json-error-handling>
- What's new it 7.3: <https://www.tomasvotruba.cz/blog/2018/08/16/whats-new-in-php-73-in-30-seconds-in-diffs/>
- New array_key functions: <https://laravel-news.com/outer-array-functions-php-7-3>
- API platform 2.3: <https://dunglas.fr/2018/07/api-platform-2-3-major-perf-improvement-api-evolution-deprecation-better-dev-tools-and-much-more/>
- PHP 5.6 EOL: <https://haydenjames.io/php-5-6-eol-end-of-life-php-7-compatibility-check>
- Features in MySQL 8.0: <https://mysqlserverteam.com/whats-new-in-mysql-8-0-generally-available/> <https://dev.mysql.com/doc/refman/8.0/en/mysql-nutshell.html>
- MySQL releases: <https://endoflife.software/applications/databases/mysql>
- What happened to MySQL 6 & 7: <https://dba.stackexchange.com/questions/207506/what-happened-to-mysql-6-7>

## PHP 7.3

PHP 7.3 is just around the corner, with Beta 3 being released today, and final release due for 
December. You can check the [release schedule here](https://wiki.php.net/todo/php73). This 
triggered me to check which versions of PHP are [currently supported](https://secure.php.net/supported-versions.php):

- Both 5.6 and 7.0 our out of active support
    - Have security support until **December this year**
- 7.1 has active support until **December this year**
- 7.2 has active upport until **November next year**

One of the core PHP developers (Zeev Suraski) posted his [thougths about PHP 8](https://externals.io/message/102415),
in which mentions that 7.4 will likely be the final version in the 7.* release line that will only include deprecations
allowing them to pave the way forward for PHP 8.


### New features in 7.3

PHP 7.3 brings a [huge list of changes and bug fixes](https://github.com/php/php-src/blob/PHP-7.3/NEWS), the best of which
 are summarised quite well by [Tomas Votruba here](https://www.tomasvotruba.cz/blog/2018/08/16/whats-new-in-php-73-in-30-seconds-in-diffs/),
Here are my favourites in order of coolness:

1. [JSON_THROW_ON_ERROR](https://laravel-news.com/php-7-3-json-error-handling) - no longer will you have to 
    check `json_last_error()` to handle json errors properly:
    ```php
    <?php

    public function safeJsonDecode(string $json): array
    {
        $data = json_decode($json);
        if (JSON_ERROR_NONE === json_last_error()) {
            throw new \RuntimeException('Invalid JSON data!');
        }

        return $data;
    }

    try {
        $data = safeJsonDecode($myJsonData);
    } catch (\RuntimeException $e) {
        // Handle errors
    }
    ```
    Instead you can replace it with:
    ```php
    <?php

    try {
        $data = json_decode($myJsonData, false, 512, JSON_THROW_ON_ERROR);
    } catch (JsonException $e) {
        // handle error
    }
    ```
2. [Trailing comma in function calls](https://laravel-news.com/php-trailing-commas-functions) -
    very useful for clean git diffs on multi-line function calls (the same as multi-line array declarations):
    ```php
    <?php

    $this->foo(
        $bar,
        $baz,
    );
    ```
3. [array_key_first() and array_key_last()](https://laravel-news.com/outer-array-functions-php-7-3) - 
    get the first and last values of an array:
    ```php
    <?php

    $array = ['foos' => 1, 'bars' => 2, 'bazzes' => 3];

    $firstKey = array_key_first($array);
    $lastKey = array_key_last($array);

    echo $firstKey // 'foos'
    echo $lastKey // 'bazzes'
    ```
4. [Better heredoc](https://laravel-news.com/flexible-heredoc-and-nowdoc-coming-to-php-7-3) - 
    meaning you don't have to break your indentation to use heredoc:
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

## MySQL jumped 2 major version numbers

That's right, MySQL has gone from 5.7 to 8.0! [Apparently](https://dba.stackexchange.com/questions/207506/what-happened-to-mysql-6-7)
version 6 was too ambitious so it got canned (much like PHP 6 😂) and the number 7 was already 
being used my MySQL cluster.

Version 8.0 was released in April, which again caused me to check the 
[EOL for previous versions](https://endoflife.software/applications/databases/mysql):

- 5.7: October 2023
- 5.6: Februrary 2021
- 5.5: **December this year**
- All other versions are unsuppported


### New features in 8.0

There is a [certifiably gigantor list of new and removed features in 8.0](https://dev.mysql.com/doc/refman/8.0/en/mysql-nutshell.html),
here are my favourites:


---
layout: page
title: Useful Links
description: Any interesting links I find that I don't include in a blog post
---

I often read something online and want to reference it weeks or months later. However I can never 
find it again.  So here is where I leave all the interesting links I find that I don't want to 
write an entire blog post about.

# PHP

* [How you can buy a elePHPant](https://www.phpclasses.org/blog/post/712-how-you-can-buy-the-PHP-elephant-for-sale.html).
* Identify every breed of the PHP Elephpant with [A filed Guide to Elephpants](https://afieldguidetoelephpants.net/).
* Run PHP code agains almost every version of PHP ever released in one go with 
    [3v4l.org](https://3v4l.org). It even combines the output to make it easy to see the differences 
    between versions.
* A really in depth look at comparing different ORM libraries in PHP:
    [Objectively comparing ORM/DAL libraries](https://medium.com/@romaninsh/objectively-comparing-orm-dal-libraries-e4f095de80b5).
* The Vancouver PHP user group had a
    [Q&A session](https://murze.be/vancouver-phps-qa-session-with-taylor-otwell)
    with Taylor Otwell.
* [PHP-PM](https://symfony.fi/entry/php-pm-1-0-launches-with-official-docker-images)
    is a recently released alternative to PHP-FPM, written entirely in PHP. It 
    looks pretty interesting and I'd like to play with it one day.
* A description of [setting up a Makefile](https://localheinz.com/blog/2018/01/24/makefile-for-lazy-developers/)
    for PHP application. I love Makefiles, they're quick and easy and allow all the
    commands you need to run in your project to come through a common interface.
* A super in depth look at [how sessions work in PHP](https://www.phparch.com/2018/01/php-sessions-in-depth/).
* How to effectively [use generators](https://medium.com/ifixit-engineering/functional-programming-with-php-generators-837a6c91b0e3).
* Ever wondered how a framework holds together? [This post](https://kevinsmith.io/modern-php-without-a-framework)
    will walk you through building your own from open source components.
* A YouTube playlist of talks at the [PHP UK Conference 2017](https://www.youtube.com/watch?list=PL_aPVo2HeGF-_djRi_UVWWLdkVpYQFnFm&v=RH74_sFjqzs).
* A YouTube playlist of talks at the [PHP UK Conference 2018](https://www.youtube.com/watch?v=59fbepJZ_3w&list=PL_aPVo2HeGF85tk74MDDOckZUNKg7-qiz).
* Using classes and the `...` token to create [strictly typed arrays in PHP](https://medium.com/2dotstwice-connecting-the-dots/creating-strictly-typed-arrays-and-collections-in-php-37036718c921).
* A pretty long video explaining [CQRS and event sourcing](https://www.youtube.com/watch?v=RfnySciLUhc).
* A list of RSS feeds used by Freek Van der Herten to [keep up to date with PHP](https://gist.github.com/freekmurze/b7f78708697266d507311a6e800eaeae).
* A hilarious article comparing [PHP to 💩](https://medium.com/fuzz/php-a0d0b1d365d8).
* Real world examples of [array destructuring in PHP](https://sebastiandedeyne.com/the-list-function-and-practical-uses-of-array-destructuring-in-php).
* A list of useful simple [PHP snippets](https://github.com/appzcoder/30-seconds-of-php-code).
* A collection of [PHP development tutorials](https://www.startutorial.com/).
* A cool benchmark of [associative arrays vs stdClass vs named classes](https://steemit.com/php/@crell/php-use-associative-arrays-basically-never).
* [Keep credentials secure](https://websec.io/2018/06/14/Keep-Credentials-Secure.html) in PHP.
* [Concurrency in PHP with Swoole](https://blog.andreiavram.ro/concurrency-php-swoole/), essentially goroutines in PHP.
* Examples or implementing [design patters in PHP](https://github.com/domnikl/DesignPatternsPHP).
* [7 reasons I switched back to PHP after 2 years on Rails](https://sivers.org/rails2php).
* An explanation of [exploiting stream wrappers](https://thehiddenwiki.pw/blog/2017/08/31/exploitation-php-wrappers).
* A simple explanation about [how MVC routers work](https://www.codediesel.com/php/how-do-mvc-routers-work/).
* Busting some myths about [php performance](https://frederickvanbrabant.com/2018/07/24/php-performance.html).
* A YouTube playlist from the [PHP fwdays'18 conference](https://www.youtube.com/watch?v=v1I57-_Rsv0&list=PLPcgQFk9n9y-iZ0Ez_r9xYzQtT0iJ_MxA&index=1).
* Testing out a few ways to run [serverless PHP](https://medium.com/@stephenheron/serverless-php-9da3f00df5de).
* An argument for using the [`iterable` type over the `array` type](https://steemit.com/php/@crell/php-never-type-hint-on-arrays).
* Use nginx to route requests between a xdebug container and a non-xdebug container to [develop at full speed with xdebug](https://jtreminio.com/blog/developing-at-full-speed-with-xdebug/).
* [Fabian Potencier implementing a blockchan in PHP](https://www.youtube.com/watch?v=2FBHiz7ANEI) (video).
* [Weird behaviour of strtotime()](https://www.pixelstech.net/article/1533378413-The-confusing-strtotime()-function-in-PHP).
* [What's new in PHP 7.3 using diffs](https://www.tomasvotruba.cz/blog/2018/08/16/whats-new-in-php-73-in-30-seconds-in-diffs/).
* [Thoughts on PHP 8](https://externals.io/message/102415).
* [The story of PHP-istan vs. Ruby-istan](https://medium.com/@tedstein/thanks-for-correcting-me-on-expressjs-and-meteor-21f6409e9b71)
    and the differences between naked PHP warriors and those protected by powerful frameworks.


# Symfony

* A great explanation of [security roles vs. voters](https://stovepipe.systems/post/symfony-security-roles-vs-voters).
* An overview of [how the Symfony routing component works](https://code.tutsplus.com/tutorials/set-up-routing-in-php-applications-using-the-symfony-routing-component--cms-31231).
* [Tips for fast, reliable tests in Symfony](https://medium.com/@galopintitouan/tips-for-a-reliable-and-fast-test-suite-with-symfony-and-doctrine-813c37825b22).
* [Run Symfony command asynchronously](https://blog.forma-pro.com/symfony-async-commands-f05052e3b205) with php-enqueue.
* [CQRS is easy with the Symfony 4 Messenge Component](https://stefanoalletti.wordpress.com/2018/08/10/cqrs-is-easy-with-symfony-4-and-his-messanger-component).


# Javascript

* Everything new in JavaScript from 2016-2018 <https://medium.freecodecamp.org/here-are-examples-of-everything-new-in-ecmascript-2016-2017-and-2018-d52fa3b5a70e>>.
* A great explanation of [why modern JavaScript is the way it is](https://medium.com/the-node-js-collection/modern-javascript-explained-for-dinosaurs-f695e9747b70).
* [How to split your chucks with Webpack](https://hackernoon.com/the-100-correct-way-to-split-your-chunks-with-webpack-f8a9df5b7758).


# Security

* The [PHP Security Advent Calendar](https://blog.ripstech.com/2017/php-security-advent-calendar/)
    is a set of 24 code snippets you're presented with and have to find the 
    security vulnerability.
* A really great and in depth look at build secure PHP web applications by
    [Paragon Initiative](https://paragonie.com/blog/2017/12/2018-guide-building-secure-php-software).
* Check if your site has an A+ security rating with [securityheaders.com](https://securityheaders.com/).
* Not sure what a content security policy is? [Content Security Policy 101](https://christoph-rumpel.com/2018/03/content-security-policy-101) has got your back.
* How to [securely hash passwords in vanilla PHP](https://php.earth/docs/security/passwords).
* [Why you shouldn't use Javascript Object Signing and Encryption](https://paragonie.com/blog/2017/03/jwt-json-web-tokens-is-bad-standard-that-everyone-should-avoid) (JWT/JWE/JWS).
* Troy Hunt on [why your static site needs https](https://www.troyhunt.com/heres-why-your-static-website-needs-https/).
* Troy Hunt on [hack yourself first](https://www.troyhunt.com/hack-yourself-first-how-to-go-on/) with a [talk at Yow! Conference in 2014](https://www.youtube.com/watch?v=hOikSOzV4cw)
    and a [free pluralsight course](https://www.pluralsight.com/courses/hack-yourself-first).
* Troy Hunt on [Some Something Security](https://www.youtube.com/watch?v=gVXEwfH6FLc) at NDC 2017.
* Troy Hunt on [building a reset password feature](https://www.troyhunt.com/everything-you-ever-wanted-to-know/).


# Software Engineering

* A great article about [paying down technical debt](https://blog.intracto.com/paying-technical-debt-how-to-rescue-legacy-code-through-refactoring).
* A post about [modular application architecture](https://www.goetas.com/blog/modular-application-architecture-intro/).
* How to use [value objects like a pro](https://hackernoon.com/value-objects-like-a-pro-f1bfc1548c72) to perfec your domain model.
* Examples of implementing common [design patterns in PHP](https://github.com/domnikl/DesignPatternsPHP).
* A curated collection of project-based programming tutorials: [Build your own X](https://github.com/danistefanovic/build-your-own-x).
* A discussion about how object-oriented and functional programming can, and [should be used together](http://blog.cleancoder.com/uncle-bob/2018/04/13/FPvsOO.html).
* A great way of [combating legacy code by copy pasting a lot](https://matthiasnoback.nl/2018/04/combing-legacy-code-string-by-string/),
    allowing you to remove the original abstractions and come up with better ones.
* Awesome talk by Bob Martin about [The Future of Programming](https://www.youtube.com/watch?v=ecIWPzGEbFc).
* A community curated list of [awesome tech talks](https://awesometalks.party/).
* An awesomely hilarious post on [how do deal with time](https://zachholman.com/talk/utc-is-enough-for-everyone-right) and why it sucks.
* A quick read about the value of [converting procedural code to OOP](https://patricklouys.com/2018/05/26/tell-dont-ask/).
* Some concrete examples of how to [stop using if statements](https://code.joejag.com/2016/anti-if-the-missing-patterns.html).
* A book explaning [Category Theory for Programmers](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/).
* An article clearly explaining the [Liskov Substitution Principle](https://www.stitcher.io/blog/liskov-and-type-safety).
* An example of how to migrate legacy code to use [dependency injection](https://matthiasnoback.nl/2018/06/road-to-dependency-injection/).
* A lecture by Bob Martin about [SOLID principles of Object Oriented and Agile design](https://www.youtube.com/watch?v=TMuno5RZNeE).
* A quick explanation of the [collector pattern](https://www.tomasvotruba.cz/blog/2018/06/14/collector-pattern-for-dummies/).
* Why you should embrace the [Majestic Monolith](https://m.signalvnoise.com/the-majestic-monolith-29166d022228) especially with a small team.
* [What's so great about OOP](https://kevinsmith.io/whats-so-great-about-oop) a comparison between procedural and object-oriented.
* How to combat legacy code by treating it as [3rd party code](https://robertbasic.com/blog/legacy-code-is-3rd-party-code/).
* A [series of posts about software architecture](https://herbertograca.com/tag/software-architecture/).
* [The future of programming is dependent types](https://medium.com/background-thread/the-future-of-programming-is-dependent-types-programming-word-of-the-day-fcd5f2634878) - 
    an explanation of how we can make type systems better.
* A post explaining why [objects should be constructed in one go](https://matthiasnoback.nl/2018/07/objects-should-be-constructed-in-one-go/).
* [Guys, REST APIs are not Database](https://medium.com/@marinithiago/guys-rest-apis-are-not-databases-60db4e1120e4): Why CRUD !== REST.
* [If you think of coding as the manipulation of data, you’re going to have a hard time writing object-oriented code.](https://kevinsmith.io/if-you-think-of-coding-as-the-manipulation-of-data-youre-going-to-have-a-hard-time-writing-object-oriented-code).
* Using [negative architecture](https://matthiasnoback.nl/2018/08/negative-architecture-and-assumptions-about-code/) to reason about your code lets you easily make assumptions about how it behaves.
* Why you should [declare all classes as final](https://ocramius.github.io/blog/when-to-declare-classes-final/).
* [Resources to learn about SOLID design](https://barryvanveen.nl/blog/51-8-resources-to-learn-about-solid-design-principles).
* A breakdown of [when to, and not-to use comments](https://matthiasnoback.nl/2018/08/more-code-comments/).
* [The service locator anti-pattern](https://www.stitcher.io/blog/service-locator-anti-pattern).
* [Code should be like an orange](https://michaelfeathers.silvrback.com/orange-code) and have a better surface area to volume ration.
* An [explanation of CQRS](https://matthiasnoback.nl/2018/01/simple-cqrs-reduce-coupling-allow-the-model-to-evolve/)
    which keeps popping up everywhere but until now I've never really understood it.
* Design for flexibility, not for perfection and [stop future proofing software](https://medium.com/@george3d6/stop-future-proofing-software-c984cbd65e78).
* A collection of posts about [software anti-patterns](https://exceptionnotfound.net/tag/anti-patterns/).
* How to [make e technical debt payment plan](https://trishkhoo.com/2018/09/make-a-technical-debt-payment-plan/).
* [Nature doesn't architect for scale, and neither should you](https://jcooney.net/post/2018/09/scale.html).
* How to tidy your code in a piecemeal daily approach: [The life changeng magic of tidying up code](https://medium.com/@kentbeck_7670/what-to-tidy-28cb46e55009).


# Testing

* [Class based model factories](https://tighten.co/blog/tidy-up-your-tests-with-class-based-model-factories) are a way of easily setting up data for a test.
* A package for [snapshot testing in PHPUnit](https://hackernoon.com/a-package-for-snapshot-testing-in-phpunit-2e4558c07fe3).
* How to write better tests and avoid [software testing anti-patterns](http://blog.codepipes.com/testing/software-testing-antipatterns.html).
* Improve your testing with [the help of static analysis](https://www.phparch.com/2018/04/testing-strategy-with-the-help-of-static-analysis/).
* [Testing strategy with the help of static analysis](https://www.phparch.com/2018/04/testing-strategy-with-the-help-of-static-analysis/).
* An explanation of [exploratory testing](https://blog.usejournal.com/what-is-exploratory-testing-the-programmer-edition-881765411f2c).


# DevOps

* A post explaining [Terraform loops and if statements](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9).
* How to use grep in vim: [Demystifying multi-file searches in Vim](https://seesparkbox.com/foundry/demystifying_multi_file_searches_in_vim_and_the_command_line).
* Overview of [Terraform 0.12](https://www.hashicorp.com/blog/terraform-0-1-2-preview).


# Databases

* YouTube video about [How SQL databases came up with their algorithms](https://www.youtube.com/watch?v=wTPGW1PNy_Y).
* [Safe database migrations operations](https://www.braintreepayments.com/blog/safe-operations-for-high-volume-postgresql/) at Braintree.
* A talk by Ondrej Mirtes on [zero downtime database migrations](https://www.youtube.com/watch?v=hMO63IC6R7c&feature=youtu.be).


# Programming Tools

* Want to "level up your PhpStorm game"? Check out [phpstorm.tips](http://phpstorm.tips). 
    A collection of small tips and tricks you can use to get better at PhpStorm.
* Some more [PhpStorm tips for power users](https://www.stitcher.io/blog/phpstorm-tips-for-power-users).
* Ever thought the MAN pages were too hard to understand, or just took too long to read? Check out the 
    [TL;DR man pages](https://laravel-news.com/tldr-pages).  A cli program which summarises the man pages for you.
* Some really fun [programming tutorials and challenges](https://www.hackerrank.com).
* A set of steps to follow to [always be automating](https://queue.acm.org/detail.cfm?id=3197520) and how you shouldn't accept manual work.
* Use `git rebase --onto` to [rebase your feature branch from one branch to another](https://makandracards.com/makandra/10173-git-how-to-rebase-your-feature-branch-from-one-branch-to-another).
* [GitHub tips and tricks](https://laravel-news.com/github-tips-tricks).
* A great post from GitHub about [how to undo (almost) anything with Git](https://blog.github.com/2015-06-08-how-to-undo-almost-anything-with-git/).


# Functional Programming

* [Explanation of folds](https://medium.com/@zaid.naom/exploring-folds-a-powerful-pattern-of-functional-programming-3036974205c8) and why they're so great.
* [Monads explained in C#](https://mikhail.io/2018/07/monads-explained-in-csharp-again/).

# Regex

* The [last regex guide](https://medium.com/tech-tajawal/regular-expressions-the-last-guide-6800283ac034)
    that you'll ever need.
* [RegexOne](https://regexone.com) is a great regex tutorial that starts out really simple.
* [Regex Golf](https://alf.nu/RegexGolf) is a fun regex challege where you try to use few characters as possible.
* Another fun [regex challenge](http://play.inginf.units.it/).
* A [reverse regex challenge](https://regexcrossword.com) where you have to write the text that matches the regex.


# Open Source

* A [post by Jeff Geerling](https://www.jeffgeerling.com/blog/2016/why-i-close-prs-oss-project-maintainer-notes)
    about what he looks for in a PR to his projects.
* A walkthrough for your [first open source PR](https://mattstauffer.com/blog/how-to-contribute-to-an-open-source-github-project-using-your-own-fork/).
* Avoid disappointent by [makinig smaller pull requests](https://www.igvita.com/2011/12/19/dont-push-your-pull-requests/).
* [A bitter guide to open source](https://medium.com/codezillas/a-bitter-guide-to-open-source-a8e3b6a3c1c4).


# Design

* Some great tips to [cheat at design](https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886).
* A super fun game that teaches you flexbox by killing zombies with a crossbow [Flexbox Zombies](https://flexboxzombies.com).
* [The art of the error message](https://thestyleofelements.org/the-art-of-the-error-message-9f878d0bff80) digs into the design of showing errors to your users.
* [Optimistic UI](https://uxplanet.org/optimistic-1000-34d9eefe4c05) is a UI that assumes actions will be successful in order to make a smoother flow for users.

# Development Processes

* An argument for [not using standups and retros](https://medium.com/@jsonpify/you-dont-need-standup-9a74782517c1).

# Business

* [Java will kill your startup. PHP will save it.](https://medium.com/@alexkatrompas/java-will-kill-your-startup-php-will-save-it-f3051968145d): Why architecture + design > language + tools.
* [How to be technical leader](https://medium.com/a-software-engineer/being-a-technical-leader-5284548f7749).


# Jokes

* [How to design for the modern web](https://medium.com/commitlog/how-to-design-for-the-modern-web-52eaa926bae2).
* An [entertaining read](https://hackernoon.com/im-harvesting-credit-card-numbers-and-passwords-from-your-site-here-s-how-9a8cb347c5b5)
    describing how easy it would be to harvest credit card numbers from a large portion of sites on 
    the internet. Just by creating a dodgy npm package and getting other popular packages to depend on it.

# General

* Learn how to learn things: [How to teach yourself hard things](https://jvns.ca/blog/2018/09/01/learning-skills-you-can-practice/).
* How to [conduct a technical interview](https://adamsitnik.com/Conducting-Interview/).
* How to [effectively work from home](https://watirmelon.blog/2018/09/07/three-years-of-working-from-home/).
* 8 steps to [fail as an engineering manager](https://blog.usejournal.com/how-to-fail-as-a-new-engineering-manager-30b5fb617a).

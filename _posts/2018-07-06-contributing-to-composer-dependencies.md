---
title: How to easily contribute to your composer dependencies
categories: php
tags: php composer open-source
---

Sometimes you find an issue with one of your composer dependencies. You'd like ot fix it, but it
can be difficult to test the changes within the context of your application because you have to
constantly push to your fork and run another `composer update`.

Following the steps below will allow you clone your fork into the `vendor/` directory of your 
application, so you can make changes, test and push - all within the context of your app.

For the purposes of this example, I'm going to be updating 
[easycorp/easyadmin-bundle](https://github.com/EasyCorp/EasyAdminBundle).


## Making the change

1. Fork the `easycoprp/easyadmin-bundle` repository you want to update
2. Create a branch in your repository (eg. "fix-foo"), choose one that's not already in use.
3. Add your fork to your composer.json:
    ```json
    {
        ...
        "repositories": [
            {
                "type": "vcs",
                "url": "https://github.com/ndench/EasyAdminBundle"
            }
        ]
        ...
    }
    ```
    NOTE: Don't update the `"require"` block, it will still point to the original `easycopy/easyadmin-bundle`.
4. Install your fork from source:
    ```bash
    $ composer require --prefer-source easycorp/easyadmin-bundle:dev-fix-foo
    ```
    This will look for the branch name `fix-foo` in the EasyAdminBundle repo and any of it's forks,
    which is why your branch name must be unique, otherwise it might install the wrong one.
    The `--prefer-source` option makes composer install with a `git clone` instead of downloading
    a zip.
5. Do your planned changes, you can test them in the context of your project.


## Submitting a PR

Once you have your changes working, you need to submit your branch as PR. But before you do that,
you'll need to run any tests and other checks required by the project.

1. Install the dependencies
    ```bash
    $ cd vendor/<vendor>/<repo name>
    $ composer install
    ```
7. Run the projects tests, linters and analysers to ensure you didn't break anything (you did 
    write tests for you change right??). You might have to check their README.md, or 
    CONTRIBUTORS.md or some other form of documentation to find what checks you need to run.
8. Add, commit and push your changes.
9. Now you can submit a pull request to the project and feel all warm and fuzzy inside.


## Keeping your fork up to date

The next time you want to submit a PR, you'll notice that your repo is out of date with it's parent.
This is because the original repo will continue merging PRs that don't get pulled into your fork.
To fix this, you'll need to bring your `master` branch (or whatever the default branch is for the repo)
up to date with the upstream one.

1. Close your project somewhere less temporary than your vendor directory.
2. Add the upstream remote:
    ```bash
    $ git remote add upstream https://github.com/EasyCorp/EasyAdminBundle.git
    ```
3. Update your master branch to be inline with the upstream
    ```bash
    $ git checkout master
    $ git fetch upstream
    $ git merge upstream/master
    ```
    NOTE: You'll have to do this for every branch you want to keep up to date.
    For example, the project might have a `develop` branch as their main branch, instead of master.

    NOTE II: You should ALWAYS create a new branch for you work. If you use any branches that already
    exist in the project, you will get merge conflicts and you won't be able to keep your fork in sync.


## Links that hepled me

* [Using your own fork in Composer](https://snippets.khromov.se/composer-use-your-own-fork-for-a-package/)
* [SO question: How to require a fork in Composer?](https://stackoverflow.com/q/13498519/1393498)
* [SO question: How to install a specific package version with Composer](https://stackoverflow.com/q/40914114/1393498)

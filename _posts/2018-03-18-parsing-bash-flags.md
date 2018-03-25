---
title: Parsing flags in bash scripts
categories: bash
tags: bash flags cli
---

I'm very lazy. I don't like to do things more than once. So, when I have to
run a command a lot when developing (for example, to clear the cache, update
the database or install dependencies), I will often write a bash alias for it
so that I have less keys to press. However, sometimes these shortcuts I have
are useful to the rest of my team, in which case I'll put them in a Makefile,
so that everyone can benefit and also update them. However, sometimes you 
need parameters being passed into the command which gets difficult with a 
Makefile, so I move onto a bash script.

## First pass at bash parameters

Initially I handled bash parameters something like this:

```bash
#!/usr/bin/env bash

PARAM=$1
OPTION=$2

./foo $PARAM --option $OPTION
```

But sometimes you want to be able to specify options as well, and that's where
it starts to get messy.

## Second pass at bash parameters, with options

```bash
#!/usr/bin/env bash

PARAM=$1; shift
FORCE=''

if [[ "$PARAM" == "--force" ]]; then
    $FORCE='--force'
    PARAM=$1
    OPTION=$2
else
    OPTION=$1
fi

./foo $PARAM --option $OPTION $FORCE
```

But this very quickly gets hard to read and maitain. It's also hard to use, you
have to remember that you can only use the `--force` option as the first
paramter. The `shift` keyword moves all the parameters forward one, so `$2`
becomes `$1`, and `$3` becomes `$2`, etc. This allows branching logic to work
better because it doesn't need to know how many parameters have already been
used.


## Third pass at bash parameters, with getopts

I stumbled acrcoss `getopt` and `getopts`, it seems that `getopt` is generally
[not recommended](https://unix.stackexchange.com/q/62950/121949) because it's
less portable and apparently doesn't handle certain cases. After reading 
[this post](https://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/)
I tweaked my scripts to be something like this:

```bash
#!/usr/bin/env bash

usage()
{
cat << EOF
usage: $0 -p PARAM -o OPTION [-f] [-h]

This script does foo.

OPTIONS:
   -p PARAM  The param
   -o OPTION The option
   -h        Show this message
   -f        Enable --force
EOF
}

PARAM=
OPTION=
FORCE=
while getopts “:hfp:o:” OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    f)
      FORCE='--force'
      ;;
    p)
      PARAM=$OPTARG
      ;;
    o)
      OPTION=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

./foo $PARAM --option $OPTION $FORCE
```

The magic for this one happens in the string `:hfp:o:` which is passed into 
`getopts`. `getopts` will set `$OPTION` to the option that was specified, and 
will optionally set `$OPTARG`, if the option requires a value. The letters are
the options that are allowed, so `:hfp:o:` allows the options `-h`, `-f`, `-p`
and `-o`. The colons (`:`) that appear throughout mean a couple of things. The
one at the very start is for error checking, and allows you to match on `?`
when an invalid option was passed. The other colons (`:`) come directly after
the options that require a value, so `p:o:` means that both `-p` and `-o`
require an argument.

So `getopts` works pretty well, but is limited because it can only use single
letter flags so you start to run out of the common letters pretty quickly and
then it gets hard to remeber the option you want to specify.


## Fourth pass at bash parameters, with manual parsing

Then I found [this great post](https://jonalmeida.com/posts/2013/05/26/different-ways-to-implement-flags-in-bash/)
which essentially walks through everything I've done up to this point, and also
provides a way to get longer flag names. However it doesn't deal with options
requiring a value, so I had to combine it with an example from the 
[bash FAQ](http://mywiki.wooledge.org/BashFAQ/035#Manual_loop):

```bash
#!/usr/bin/env bash


usage()
{
cat << EOF
usage: $0 PARAM [-o|--option OPTION] [-f|--force] [-h|--help]

This script does foo.

OPTIONS:
   PARAM        The param
   -o|--option  OPTION The option
   -h|--help    Show this message
   -f|--force   Enable --force
EOF
}

PARAM=$1; shift
OPTION=''
FORCE=''

while [ ! $# -eq 0 ]; do
    case "$1" in
        -o | --option)
            if [ "$2" ]; then
                OPTION='--option $2'
                shift
            else
                echo '--option requires a value'
                exit 1
            fi
            ;;
        -f | --force)
            FORCE='--force'
            ;;
        -h | --help)
            usage
            exit
            ;;
        *)
            usage
            exit
            ;;
    esac
    shift
done

./foo $PARAM $OPTION $FORCE
```

This is getting fairly complex, but what it's doing is looping until there are
no more parameters left. `$#` gives you then number of parameters left so when
it equals `0` then we can stop looping. The `shift` at the bottom  keeps moving
the parameters forward so we can iterate through them. You can see an extra
`shift` needs be added in when we want to take a value, because we're using
`$2`. The `*)` at the end will match everything else so we can display the
usage when a non-supported option is being passed.

This approach gives us all the benefits:

* I don't need to specify extra option on the command line for `PARAM` because 
  it's always required.
* I can make `OPTION` optional now.
* We can have long option names that are easier to remember

The only downside is that it's a fair bit of setup and really complicates
simple bash scripts.

## My approach

I like things to be simple, so I pretty much always start out with the first approach 
and will upgrade to `getopts` if I need more than a couple options. Once it starts
getting complicated, I'll migrate to using the manual approach. And if it gets too
complicated for that, then it's probably too complicated to be in bash script 
anyway 😂.


## Links that helped me

* [great explanation of getopts](https://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/)
* [getopt vs getopts](https://unix.stackexchange.com/q/62950/121949)
* [how to manually parse arguments](https://jonalmeida.com/posts/2013/05/26/different-ways-to-implement-flags-in-bash/)
* [manual parsing in an init script](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_03.html)
* [great walthrough of all the options](http://abhipandey.com/2016/03/getopt-vs-getopts/)
* [bash FAQ on parsing arguments](http://mywiki.wooledge.org/BashFAQ/035)

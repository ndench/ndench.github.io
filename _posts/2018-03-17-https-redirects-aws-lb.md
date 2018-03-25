---
title: Setting up HTTPS redirects behind an AWS load balancer
categories: aws
tags: aws nginx https
---

The easiest way I've found to set up https is by creating a free https 
certificate with AWS Certificate Manager and adding it a load balancer.
You then put a webserver behind the load balancer listening on http port 80
(because the load balancer terminates the https connection).

TL;DR? Skip to the [final solution](#solution-3).

## Problem #1

Your site works great at https://mycoolsite.com, however, if a user goes to
http://mycoolsite.com, they receive a 404, because the load balancer rejects
connections to port 80.

## Solution #1

Make the load balancer listen on http port 80 as well, and proxy traffic
through to the webserver.

## Problem #2

Now users can connect to http://mycoolsite.com, but they should not be able to
view your site over http, you want them using https. A quick google around and 
you might find a solution like [this](https://bjornjohansen.no/redirect-to-https-with-nginx):

```nginx
server {
	listen 80;
	server_name _;
	return 301 https://$host$request_uri;
}
```

But you will soon find that doesn't work, because all traffic connects to your 
server on port 80 and is then redirected to https, only to come back on port 80
again, because of the load balancer. You've created an infinite loop!

## Solution #2

A little more googling you might come across a solution like 
[this](https://oanhnn.github.io/2016-02-29/how-to-force-https-behind-aws-elb.html):

```nginx
server {
    listen 80;
    server_name _;
    if ($http_x_forwarded_proto != "https") {
        rewrite ^(.*)$ https://$server_name$REQUEST_URI permanent;
    }
}
```

The load balancer helps you out by setting extra headers on the request that 
it's proxying to you. The `X-FORWARDED-PROTO` header is the one which tells
you the initial protocol that the user connected with. You can check if it's
been set to `https` and if it hasn't redirect to https, and depending on your 
AWS setup, this might work.

## Problem #3

The load balancer sends periodic health checks to your instance to check that
it's alive and well. It doesn't set the `X-FORWARDED-PROTO` so nginx will 
return a 301 and the load balancer thinks it's unheathly. However, if all your
instances are unhealthy, then the load balancer will just send traffic to one
of them anyway, meaning you might not even know about the issue. I ran a 
production servers for 2 months and never knew that the load balancer 
considered them unhealthy. This problem was even listed in the 
AWS documentation until
[October 2017](https://web.archive.org/web/20171027023806/https://aws.amazon.com/premiumsupport/knowledge-center/redirect-http-https-elb/)
so you can understand the confusion some people were having.

## Solution #3

It wasn't until I read [this post](http://fuzzyblog.io/blog/aws/2017/02/03/redirecting-http-to-https-with-aws-and-elb.html)
which showed apache config which negated the if check. So it only redirected 
if the `X-FORWARDED-PROTO` header was set to `http`, meaning that someone
connected to the load balancer with `http` and not `https`. So I tweaked my
nginx config:

```nginx
server {
    listen 80;
    server_name _;
    if ($http_x_forwarded_proto = "http") {
        rewrite ^(.*)$ https://$server_name$REQUEST_URI permanent;
    }
}
```

And now everything works as expected!


## Links that helped me

* [blog post that pointed me in the right direction](http://fuzzyblog.io/blog/aws/2017/02/03/redirecting-http-to-https-with-aws-and-elb.html)
* NOTE: [The AWS documentation has been updated with the correct solution](https://aws.amazon.com/premiumsupport/knowledge-center/redirect-http-https-elb/)
* [another solution using a special health-check location blockc](https://serverfault.com/a/721358/243144)

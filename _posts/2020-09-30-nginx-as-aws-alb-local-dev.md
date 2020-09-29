---
title: Using Nginx like an AWS load balancer in local dev
categories: nginx
tags: aws nginx local development
---

A typical production web application is set up behind a load balancer, with the SSL connection
terminating at the load balancer. The web server then has an nginx reverse proxy accepting a
plain HTTP connection and proxying through to the application.

Without having a load balancer in your local development environment, the nginx setup is the 
same, but the application is accessed over a HTTP connection. This creates a separation
between production and development which can become a problem. Especially if you're building
an integration which requires the application be served over a HTTPS connection.

In this post, we'll add another nginx reverse proxy in the front which will accept and
terminate the SSL connection.

## Creating the SSL certificate

Creating a self signed certificate is easy, however some tools will still not trust it even
if you add it as a trusted root certificate. To get around this, we have to create a root 
Certificate Authority (CA) which we will use to sign our SSL certificate. Once we add the
root CA certificate to our system, then everything will trust our SSL certificate.

You can use the following script to create the root CA and private encryption keys.

`create_root_cert_and_key.sh`:
```sh
#!/usr/bin/env bash

##########################################################################
# Create a root CA certificate that devs can add as trusted.
# We use this root certificate to create other ssl certificates which are
# not "self signed".
# Adapted from https://stackoverflow.com/a/43666288/1393498
##########################################################################

if [ -f rootCA.pem ]; then
  echo 'rootCA.pem already exists!'
  exit
fi

if [ -f rootCA.key ]; then
  echo 'rootCA.key already exists!'
  exit
fi

if [ -f certificate.key ]; then
  echo 'certificate.key already exists!'
  exit
fi

# Create the root CA's private key and certificate
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem

# Create a private key to be used to sign other certificates
openssl genrsa -out certificate.key 2048

echo
echo "###################################################################"
echo Done!
echo "###################################################################"
echo "You can generate new certificates with create_cert_for_domain.sh"
echo "Be sure to add the generated rootCA as trusted to your system"
echo
echo "For Mac:"
echo "    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain rootCA.pem"
echo
echo "For Arch:"
echo "    sudo trust anchor --store rootCA.pem"
echo
echo "For Ubuntu:"
echo "    sudo cp rootCA.pem /usr/local/share/ca-certificates/myRootCA.crt"
echo "    sudo update-ca-certificates"
```

Running this script will generate:
1. `rootCA.key`
    * your root CA private encryption key
    * used to sign SSL certificates
    * must be kept a *secret*
    * anyone with access to this can serve you any content over HTTPS, and your system will trust it
2. `rootCA.pem`
    * certificate for your root CA
    * will be added to your system as a trusted root CA
3. `certificate.key`
    * private encryption key used for any SSL certificates you generate
    * must be kept a *secret*
    
You can now use the following script to create an SSL certificate for any domain.

`create_cert_for_domain.sh`:
```sh
#!/usr/bin/env bash

##########################################################################
# Create an ssl certificate which is signed by our own root CA.
# The certificate is not "self signed" and easier for tools to trust.
# Note: We need to add the root CA as "trusted" for it to work.
# Adapted from https://stackoverflow.com/a/43666288/1393498
##########################################################################

if [ ! -f rootCA.pem ]; then
  echo 'rootCA.pem does not exist'
  echo 'Create it with "create_root_cert_and_key.sh"'
  exit
fi

if [ ! -f rootCA.key ]; then
  echo 'rootCA.key does not exist'
  echo 'Create it with "create_root_cert_and_key.sh"'
  exit
fi

if [ ! -f certificate.key ]; then
  echo 'certificate.key does not exist'
  echo 'Create it with "create_root_cert_and_key.sh"'
  exit
fi

if [ -z "$1" ]
then
  echo "Please supply a subdomain to create a certificate for"
  echo "e.g. www.mysite.com"
  exit
fi

DOMAIN=$1
SUBJECT="/C=CA/ST=None/L=NB/O=None/CN=${DOMAIN}"
NUM_OF_DAYS=825
EXT_FILE_PATH=/tmp/__v3.ext

# An extension is used to pass metadata into the certificate
# It specifies the subjectAltName, # which is required by some 
# tools in order to trust the certificate (eg. Chrome)
cat > ${EXT_FILE_PATH} <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}
DNS.2 = *.${DOMAIN}
EOF

# Create the certificate and the certificate signing request
openssl req -new -newkey rsa:2048 -sha256 -nodes -key certificate.key -subj "$SUBJECT" -out ${DOMAIN}.csr

# Sign the certificate as the root CA
openssl x509 -req -in ${DOMAIN}.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out ${DOMAIN}.crt -days ${NUM_OF_DAYS} -sha256 -extfile ${EXT_FILE_PATH}

echo
echo "###################################################################"
echo Done!
echo "###################################################################"
echo "To use these files on your server, simply copy both ${DOMAIN}.csr"
echo "and certificate.key to your webserver (Nginx example)"
echo
echo "    ssl_certificate /etc/ssl/certs/${DOMAIN}.crt;"
echo "    ssl_certificate_key /etc/ssl/private/certificate.key;"
```

Running this script with `example.com` will generate:
1. `example.com.csr`
    * a Certificate Signing Request
    * used to sign `example.com.crt`
    * this step would be skipped if you used a self-signed certificate
2. `example.com.crt`
    * your SSL certificate, signed by your root CA
    * your root CA is not trusted yet, so it still will not work

## Set up nginx like an AWS load balancer

When behind an AWS load balancer, you'll want your nginx configuration to look like this:
(see my post on [setting up https redirects in AWS]({% post_url 2018-03-17-https-redirects-aws-lb %})
for more details on this)

```nginx
server {
    listen 80;
    server_name _;
    if ($http_x_forwarded_proto = "http") {
        return 301 https://$host$request_uri;
    }

    # the rest of your nginx configuration
}
```

While in dev, it will look very similar:

```nginx
server {
    listen 80;
    server_name _;

    # the rest of your nginx configuration
}
```

But now, add a reverse proxy to our dev configuration to handle the HTTPS connection:

```nginx
server {
    listen 80;
    server_name _;
    if ($http_x_forwarded_proto = "http") {
        return 301 https://$host$request_uri;
    }

    # the rest of your nginx configuration
}

server {
   listen 443 ssl;
   server_name sunfish.local;
   ssl_certificate /etc/ssl/certs/example.com.crt;
   ssl_certificate_key /etc/ssl/private/certificates.key;

   location / {
      proxy_pass http://localhost;
      # Pass through the existing Host header, otherwise the application will 
      # think it's accessed via localhost
      proxy_set_header Host $host;
      # Set the same X-Forwarded-* headers that an AWS load balancer sets
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-forwarded-Port $server_port;
   }
}
```

Now you can access your development environment over HTTPS, however your certificate will not be 
trusted. You can tell Chrome/Firefox to ignore this, however it's harder to make other tools ignore
it without completely disabling SSL verification.

## Trusting your root CA

On your system, you need to install the generated root CA certificate as a trusted certificate.
As mentioned in the `create_root_cert_and_key.sh` script above, you can do that with the following
commands. Be sure to do this on all systems that need to access the development environment, this
may include:
* your physical dev computer
* the virtual machine/container your application runs in
* all of the above for each developer on your team

For Mac:

```sh
$ sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain rootCA.pem
```

For Arch:

```sh
$ sudo trust anchor --store rootCA.pem
```

For Ubuntu:

```sh
# It's important to give the certificate the .crt extension here
# otherwise it will not be picked up by `update-ca-certificates`
$ sudo cp rootCA.pem /usr/local/share/ca-certificates/myRootCA.crt
$ sudo update-ca-certificates
```

## Conclusion

Now you can successfully access your local development environment over HTTPS without any warnings
from any tools, and your dev environment is one step closer to production!

## Links that helped me

* [StackOverflow answer providing the scripts above](https://stackoverflow.com/a/43666288/1393498)
* [AWS load balancer headers documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/x-forwarded-headers.html)
* [Setting up an nginx load balancer in AWS](https://medium.com/datadriveninvestor/nginx-server-ssl-setup-on-aws-ec2-linux-b6bb454e2ef2)
* [Setting X-Forwarded-* headers on nginx](https://plone.lucidsolutions.co.nz/web/reverseproxyandcache/setting-nginx-http-x-forward-headers-for-reverse-proxy)
* [Adding a trusted CA in Arch Linux](https://wiki.archlinux.org/index.php/User:Grawity/Adding_a_trusted_CA_certificate)
* [Adding a trusted CA in Ubuntu](https://askubuntu.com/questions/73287/how-do-i-install-a-root-certificate)

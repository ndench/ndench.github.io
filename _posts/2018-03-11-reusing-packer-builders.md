---
title: How to reuse packer builders
categories: packer
tags: packer ansible infra json
---

When I'm setting up a new web app, I like to use [packer](https://packer.io) to 
bake an AMI with everything required to run the app. Then I use some other tool
to deploy the latest code changes to each instance. 

## The problem

The issue I run into with 
Packer is that I want to run multiple environments with very similar AMI's, but
packer has no native support for this. I have to copy-paste the builder block
to build both a staging and production AMI, even though they are both almost
exactly the same. So I end up with a `packer.json` config looking like:

{% raw %}
```json
{
    "builders": [
        {
            "type": "amazon-ebs",
            "region": "ap-southeast-2",
            "source_ami_filter": {
                "filters": {
                    "virtualization-type": "hvm",
                    "name": "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*",
                    "root-device-type": "ebs"
                },
                "owners": ["099720109477"],
                "most_recent": true
            },
            "instance_type": "t2.medium",
            "ssh_username": "ubuntu",
            "force_deregister": true,
            "force_delete_snapshot": true,
            "ami_name": "my-ami-staging"
        },
        {
            "type": "amazon-ebs",
            "region": "ap-southeast-2",
            "source_ami_filter": {
                "filters": {
                    "virtualization-type": "hvm",
                    "name": "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*",
                    "root-device-type": "ebs"
                },
                "owners": ["099720109477"],
                "most_recent": true
            },
            "instance_type": "t2.medium",
            "ssh_username": "ubuntu",
            "force_deregister": true,
            "force_delete_snapshot": true,
            "ami_name": "production",
            "ami_description": "AMI to run the production environment"
        }
    ],
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "../ansible/provisioning/site.yml",
            "ansible_env_vars": ["ANSIBLE_CONFIG=../ansible/ansible.cfg"],
            "inventory_directory": "../ansible/provisioning",
            "groups": ["staging"]
        },
        {
            "type": "ansible",
            "playbook_file": "../ansible/provisioning/site.yml",
            "ansible_env_vars": ["ANSIBLE_CONFIG=../ansible/ansible.cfg"],
            "inventory_directory": "../ansible/provisioning",
            "groups": ["production"]
        }
    ]
}
```
{% endraw %}

This is a terrible amount of duplication, and becomes a problem when I want to
change something with the builder or provisioner because there's a good chance
I'll make a typo having to copy-paste everything. Also, it's a lot of work
having to do everything twice (or more times if you have more environments).

After a bit of research I stubled across this 
[stack overflow question](https://stackoverflow.com/q/41147141/1393498) which
suggested using different names for each builder, and one of the questions
suggested preprocessing the json to duplicate the builder block. So I set work.


## The investigation

I found this [awesome tutorial](https://programminghistorian.org/lessons/json-and-jq)
about [jq](https://stedolan.github.io/jq/) which is "like sed for JSON". It's an 
awesome tool which allows me to query and manipulate JSON on the command line.
The tutorial linked me to [jqplay](https://jqplay.org) which is another great
website that lets you run `jq` in the browser and quickly iterate on your
query string (like [regex101](https://regex101.com/) for jq).

So I cut my JSON down to the bare minimum and named the builder:

{% raw %}
```json
{
    "builders": [
        {
            "type": "amazon-ebs",
            "name": "staging",
            "region": "ap-southeast-2",
            "source_ami_filter": {
                "filters": {
                    "virtualization-type": "hvm",
                    "name": "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*",
                    "root-device-type": "ebs"
                },
                "owners": ["099720109477"],
                "most_recent": true
            },
            "instance_type": "t2.medium",
            "ssh_username": "ubuntu",
            "force_deregister": true,
            "force_delete_snapshot": true,
            "ami_name": "my-ami-{{ build_name }}"
        }
    ],
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "../ansible/provisioning/site.yml",
            "ansible_env_vars": ["ANSIBLE_CONFIG=../ansible/ansible.cfg"],
            "inventory_directory": "../ansible/provisioning",
            "groups": ["{{ build_name }}"]
        }
    ]
}
```
{% endraw %}

After much messing around on jqplay, I managed to find the correct query string
(you can see my result [here on jqplay](https://jqplay.org/s/xGA99WWoKT)):

```
.builders += [.builders[0] | .name = "production"]
```

Translating this query string to english and you get:

* Take the `builders` object and append the object created by the following:
	* Take the 0th element from the `builders` object; and
	* Change the value of the `name` element to `"production"`

So running the following `jq` command:

```bash
$ jq '.builders += [.builders[0] | .name = "production"]' packer.json > packer_temp.json
```

gives me a `packer_temp.json` that looks like:

{% raw %}
```json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "name": "staging",
      "region": "ap-southeast-2",
      "source_ami_filter": {
        "filters": {
          "virtualization-type": "hvm",
          "name": "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*",
          "root-device-type": "ebs"
        },
        "owners": [
          "099720109477"
        ],
        "most_recent": true
      },
      "instance_type": "t2.nano",
      "ssh_username": "ubuntu",
      "force_deregister": true,
      "force_delete_snapshot": true,
      "ami_name": "my-ami-{{ build_name }}"
    },
    {
      "type": "amazon-ebs",
      "name": "production",
      "region": "ap-southeast-2",
      "source_ami_filter": {
        "filters": {
          "virtualization-type": "hvm",
          "name": "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*",
          "root-device-type": "ebs"
        },
        "owners": [
          "099720109477"
        ],
        "most_recent": true
      },
      "instance_type": "t2.nano",
      "ssh_username": "ubuntu",
      "force_deregister": true,
      "force_delete_snapshot": true,
      "ami_name": "my-ami-{{ build_name }}"
    }
  ],
  "provisioners": [
    {
      "type": "ansible",
      "playbook_file": "provisioning/site.yml",
      "groups": [
        "{{ build_name }}"
      ]
    }
  ]
}
```
{% endraw %}

which is exactly what I want. This way I can modify a single builder block and 
have the changes automatically propogate to both the `staging` and `production`
AMI's.

## Links that helped me

* [stack overflow question](https://stackoverflow.com/q/41147141/1393498)
* [awesome jq tutorial](https://programminghistorian.org/lessons/json-and-jq)
* [jqplay.org](https://stackoverflow.com/q/41147141/1393498)

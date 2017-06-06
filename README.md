# redmine-compose
Docker compose setup for Redmine hosting.

The main problem this repository is trying to address is the (automated) installation of plugins.

The `docker-compose.yml` is almost exactly the one documented in the 
[official Redmine docker image](https://hub.docker.com/_/redmine/), with the addition of a plugin setup stage. 

## The Problem

Normally installing plugins into Redmine is pretty easy (although unfortunately not managed by the built-in
administration interface) - you `cd` into the `plugins` directory, download the plugin, perform whatever setup 
is necessary, then restart Redmine.

But under Docker compose, there's no easy way to handle this restart - except running `docker restart redmine_redmine_1`
manualy, which is not exactly something you can do in an automated setup.

The redmine startup in the official Docker image helpfuly does wait for the database to be ready and can complete the
database initialization step even if the database takes time to start (which it does for MariaDB/MySQL at least), but it
doesn't wait for us to install plugins.

## The Solution

I've added a new Docker service that is performing a one time setup for the plugins into a shared volume and finishes by
writing a "plugins are ready" notification file. 

A new wrapper script is set up as the Redmine entry-point, which waits for the "plugins are ready" file before executing
the original entry-point. At which point the standard Redmine initialization takes place and can register the installed
plugins.
  
## Usage

1. Update the `install-plugins.sh` file to install the plugins that you need. The current script installs 
`redmine_omniauth_google` as an example (and also because its useful for my use case.
1. If more dependancies are needed for the plugin insallation, update the Dockerfile with the new dependencies.
1. Run `docker-compose up`.
1. Wait for the services to finish initialization.

## Deploy on AWS

Also available is a sample CloudFormation template that you can deploy with minimal effort on an AWS account.

The defaults are pretty useful and will start a "free tier eligable" EC2 instance and load balancer. I use
a load balancer because its easy to add Route53 aliases and SSL certificates to the service if you use a
load balancer. Otherwise this template does not assign a DNS name (though it is highly recommended) or an
SSL certificate (which is also highly recommended and you can easily get one for free from Amazon).

To deploy the CloudFormation template:

1. Create an EC2 key pair
2. Create a new stack and upload the template to the new stack, using the created key in the required parameter.

The process can be run from the command line using the AWS CLI tool and the 
[cloudformation-tool Ruby gem](https://rubygems.org/gems/cloudformation-tool):

```
aws --region eu-west-1 ec2 create-key-pair --key-name redmine | jq .KeyMaterial -cr > ~/.ssh/redmine.pem
cftool -r eu-west-1 create -p KeyName=webhost1 cloud-formation.yaml redmine
```

The `cftool` command will output the host name for the redmine server and the load balancer.

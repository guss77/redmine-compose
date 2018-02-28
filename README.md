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
2. Create Simple Email Service SMTP Credentials (see AWS Email Delivery below)
3. Log in to the AWS CloudFormation console
4. Click "Create Stack" to create a new stack.
5. Name the new stack
5. Click "Choose File" and load the `cloud-formation.yaml` from this repository.
7. Click "Next"
8. In the parameters page, fill in the email domain you want Redmine to send emails from, the SES username and password, and the name of the EC2 key pair you created in step 1.
9. Click "Next" and then "Next" again, then "Create".
10. Wait until the stack finishes creating, then select the stack in the stacks list and click "Outputs". Copy the value of the `LoadBalancerAddress` and use that to access Redmine.

### AWS Email Delivery

To setup Redmine to send and receive emails through Amazon Simple Email Service, follow the following steps:

1. Go to the Simple Email Service console.
2. Under "Domains" click "Verify a new domain", and follow the on-screen instructions. You'd need access to an internet domain and to the DNS server for that domain.
3. Under "SMTP Settings" click "Create My SMTP Credentials".
4. You will be moved to the IAM console where you'd need to specify a user name (or accept the default one), then click "Create".
5. You will then be shown yuor "SMTP Security Credentials". Copy the "SMTP Username" and "SMTP password" and save them somewhere safe.

### Automated Deployment

The process can be run from the command line using the AWS CLI tool and the 
[cloudformation-tool Ruby gem](https://rubygems.org/gems/cloudformation-tool):

```
aws --region eu-west-1 ec2 create-key-pair --key-name redmine | jq .KeyMaterial -cr > ~/.ssh/redmine.pem
cftool -r us-east-1 create -p KeyName=redmine -p EmailDomain=tickets.example.com -p SESUsername=sesuser -p SESPassword=sespass cloud-formation.yaml redmine
```

The `cftool` command will output the host name for the redmine server and the load balancer.

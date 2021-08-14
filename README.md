This command combines [Amazon EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Connect-using-EC2-Instance-Connect.html) and [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) to provide a secure and easy connection to EC2 instances.

Using this command has the following advantages.

- **No need to open the port.** All ingress rules can be made closed.
- **No need to place instances on public subnets.** Instances can be placed in a private subnet (Internet access is required).
- **No need to manage keypairs.** Connect using a temporary public key that is only valid for 60 seconds instead of a keypairs.
- Access permissions to the instance can be centrally managed by IAM.
- With the Instance Connect feature, all SSH accesses can be logged by CloudTrail.

# Usage

## Pattern1: Set up a custom ProxyCommand.(Recommended)

Add the following configuration to your `.ssh/config` .
(see: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)

```sshconfig
host i-* mi-*
    ProxyCommand sh -c "ssh_ec2 %r %h --send-key-only && aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```

Use the following command to connect to the instance.

```sh
ssh ec2-user@i-xxxxxxx
```

## Pattern2: use `ssh_ec2` command instead of `ssh` command

This pattern can coexist with the normal configuration of ssh via ssm without `ssh_ec2`.

Add the following configuration to your `.ssh/config` .
(see: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)

```sshconfig
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```

Use the following command to connect to the instance.

```sh
# ssh_ec2 <user-name> <instance-id> [--key-file <key-file>] [--send-key-only]
ssh_ec2 ec2-user i-xxxxxxx

# equivalent to
ssh_ec2 ec2-user i-xxxxxxx --send-key-only
ssh ec2-user@i-xxxxxxx
```

# Requirements

- AWS CLI is installed.
- Permission to run "aws ssm start-session".
- Permission to run "aws ec2 describe-instances" to determine which AZ the instance is in.
- Permission to run "aws ec2-instance-connect send-ssh-public-key"

# Installation

Copy `ssh_ec2` in your $PATH

```sh
git clone https://github.com/moajo/ssh_ec2.git $HOME/ssh_ec2
ln -s $HOME/ssh_ec2/ssh_ec2 /usr/local/bin/ssh_ec2
```

# usage

```
ssh_ec2: ssh to ec2 instance via ssm/instance-connect

Requirements:
    - AWS CLI is installed.
    - Permission to run "aws ssm start-session".
    - Permission to run "aws ec2 describe-instances" to determine which AZ the instance is in.
    - Permission to run "aws ec2-instance-connect send-ssh-public-key"
    - SSH connections through the SessionManager are allowed in ~/.ssh/config as shown below.
      (see: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html)
        host i-* mi-*
            ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"

Usage:
    ssh_ec2 <instance-id> <user-name> [<key-file>]

Options:
    instance-id: ID of the instance to ssh to.(e.g. "i-12345678")
    user-name:   User name to ssh as.(e.g. "ec2-user")
    key-file:    (default: "$HOME/.ssh/id_rsa.pub")
```

# installation

Copy `ssh_ec2` in your $PATH

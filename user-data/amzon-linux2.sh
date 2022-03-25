#!/usr/bin/env bash

set -e
set +x

# Waiting YUM be unlocked
while [ "$(sudo ps aux | grep -v grep | grep yum)" != "" ]; do sleep 1; done

# Update packages
sudo yum update -y
sudo amazon-linux-extras install docker
sudo yum upgrade -y
sudo yum install -y\
 amazon-ecr-credential-helper\
 amazon-efs-utils\
 curl\
 nfs-utils\
 jq\
 htop\
 python3.x86_64\
 python3-debug.x86_64\
 python3-devel.x86_64\
 python3-libs.x86_64\
 python3-pip.noarch\
 python3-setuptools.noarch\
 python3-test.x86_64\
 python3-tools.x86_64\
 python3-pip\
 rsync\
 tree\
 unzip\
 vim\
 wget

# Installing Python Main Requirements
sudo python3 -m pip install -U pip --no-warn-script-location setuptools wheel

# Installing Python Tools
sudo python3 -m pip install -U --no-warn-script-location boto3 ansible ansible-lint

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"\
 && unzip ./awscliv2.zip\
 && sudo ./aws/install\
 && rm -rf ./aws\
 && rm -rf ./awscliv2.zip

# Installing and configuring Gitlab Runner
echo -e "\nRunning scripts as '$(whoami)'\n\n"

# Docker cleanup cron job
echo -e "\nCleaning up unused docker objects.\n\n"
new_jobs='0 */4 * * * docker system prune -af --volumes > /dev/null 2>&1'

set +e  # Suspend error-exit
old_jobs="$(sudo crontab -l 2>&1 | sed '/docker system prune/d')"

set -e  # Restore error-exit.
if [[ "$old_jobs" != "no crontab"* ]]; then
    new_jobs=$(printf "$old_jobs\n$new_jobs\n")
fi
echo "$new_jobs" | sudo crontab -

# Configuring docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo mkdir -p /root/.docker && sudo touch /root/.docker/config.json
sudo sh -c "echo '{	\"credsStore\": \"ecr-login\" }' >> /root/.docker/config.json"

# Service file changed - refresh systemd daemon
sudo systemctl daemon-reload

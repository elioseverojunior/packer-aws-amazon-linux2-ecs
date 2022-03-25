# Packer AWS Amazon Linux 2 ECS

## Generating aws key_pairs

### You can run the command below or execute the bash script `bash ./create-packer-aws-key-pairs.sh`

```bash
aws ec2 create-key-pair\ 
 --key-name packer 
 --key-type rsa 
 --query "KeyMaterial" 
 --output text > ~/.ssh/packer.pem

chmod 400 ~/.ssh/packer.pem

ssh-keygen -y -f ~/.ssh/packer.pem > ~/.ssh/packer.pub

chmod 600 ~/.ssh/packer.pub

ls -la ~/.ssh/
```

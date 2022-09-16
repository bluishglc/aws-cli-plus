# AWS CLI PLUS

```bash
git clone https://github.com/bluishglc/aws-cli-plus.git

sudo ./aws-cli-plus/install.sh

aws-cli-plus emr list-services \
    --region "cn-north-1" \
	--ssh-key "/path/to/my/pem/file" \
	--emr-cluster-id "j-my-emr-cluster-id"
```
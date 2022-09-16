# AWS CLI PLUS

```bash
git clone https://github.com/bluishglc/aws-cli-plus.git

sudo ./aws-cli-plus/install.sh

aws-cli-plus emr list-services --region "cn-north-1" --ssh-key "/path/to/your/pem" --emr-cluster-id "your-emr-cluster-id"
	
aws-cli-plus emr list-packages --region "cn-north-1" --ssh-key "/path/to/your/pem" --emr-cluster-id "your-my-emr-cluster-id"

```
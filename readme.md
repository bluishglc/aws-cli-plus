# AWS CLI PLUS


## Install

```bash
git clone https://github.com/bluishglc/aws-cli-plus.git
sudo ./aws-cli-plus/install.sh
```

## Prerequisites

```bash
export REGION='<your-region>'
export SSH_KEY='<your-pem-file-path>'
export ACCESS_KEY_ID='<your-access-key-id>'
export SECRET_ACCESS_KEY='<your-secret-access-key>'
export EMR_CLUSTER_ID='<your-emr-cluster-id>'
```

## Commands

### EMR

#### List Apps

```bash
aws-cli-plus emr list-apps --region "$REGION" --emr-cluster-id "$EMR_CLUSTER_ID"
```

#### List Services

```bash
aws-cli-plus emr list-services --region "$REGION" --ssh-key "$SSH_KEY" --emr-cluster-id "$EMR_CLUSTER_ID"
```

#### List Packages

```bash
aws-cli-plus emr list-packages --region "$REGION" --ssh-key "$SSH_KEY" --emr-cluster-id "$EMR_CLUSTER_ID"
```

#### Find Log Errors

```bash
aws-cli-plus emr find-log-errors --region "$REGION" --emr-cluster-id "$EMR_CLUSTER_ID"
```

### EC2

```bash
aws-cli-plus ec2 init --region "$REGION" --access-key-id "$ACCESS_KEY_ID" --secret-access-key "$SECRET_ACCESS_KEY"
```

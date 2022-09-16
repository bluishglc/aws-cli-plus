# AWS CLI PLUS

This command line tool is a useful complement to aws-cli. It offers a suite of utilities that manages and operates ec2, emr and other aws services.

## 1. Install

```bash
sudo yum -y install git
git clone https://github.com/bluishglc/aws-cli-plus.git
sudo ./aws-cli-plus/install.sh
```

## 2. Prerequisites

```bash
export REGION='<your-region>'
export SSH_KEY='<your-pem-file-path>'
export ACCESS_KEY_ID='<your-access-key-id>'
export SECRET_ACCESS_KEY='<your-secret-access-key>'
export EMR_CLUSTER_ID='<your-emr-cluster-id>'
```

## 3. Usage

### 3.1 EMR

#### 3.1.1 List Apps

```bash
aws-cli-plus emr list-apps --region "$REGION" --emr-cluster-id "$EMR_CLUSTER_ID"
```

#### 3.1.2 List Services

```bash
aws-cli-plus emr list-services --region "$REGION" --ssh-key "$SSH_KEY" --emr-cluster-id "$EMR_CLUSTER_ID"
```

#### 3.1.3 List Packages

```bash
aws-cli-plus emr list-packages --region "$REGION" --ssh-key "$SSH_KEY" --emr-cluster-id "$EMR_CLUSTER_ID"
```

#### 3.1.4 Find Log Errors

```bash
aws-cli-plus emr find-log-errors --region "$REGION" --emr-cluster-id "$EMR_CLUSTER_ID"
```

### 3.2 EC2

#### 3.2.1 Init EC2 Instance

```bash
# sudo is required for ec2 init operation
sudo aws-cli-plus ec2 init --region "$REGION" --access-key-id "$ACCESS_KEY_ID" --secret-access-key "$SECRET_ACCESS_KEY"
```

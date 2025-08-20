# 배포 가이드 (Deployment Guide)

이 문서는 3-tier 웹 서비스 아키텍처와 비동기 채점 시스템의 배포 과정을 단계별로 설명합니다.

## 📋 목차

- [사전 요구사항](#사전-요구사항)
- [배포 준비](#배포-준비)
- [단계별 배포](#단계별-배포)
- [배포 후 검증](#배포-후-검증)
- [환경별 배포](#환경별-배포)
- [롤백 가이드](#롤백-가이드)
- [문제 해결](#문제-해결)
- [모니터링 설정](#모니터링-설정)

## 사전 요구사항

### 1. 필수 도구

| 도구 | 버전 | 설치 확인 |
|------|------|-----------|
| **Terraform** | >= 1.0 | `terraform --version` |
| **AWS CLI** | >= 2.0 | `aws --version` |
| **Docker** | >= 20.0 | `docker --version` |
| **Git** | >= 2.0 | `git --version` |

### 2. AWS 계정 설정

#### 필수 권한
배포를 위해 다음 AWS 서비스에 대한 권한이 필요합니다:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "ecs:*",
        "rds:*",
        "s3:*",
        "mq:*",
        "iam:*",
        "logs:*",
        "ssm:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "application-autoscaling:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### AWS CLI 설정
```bash
# AWS 자격 증명 설정
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: ap-northeast-2
# Default output format: json

# 설정 확인
aws sts get-caller-identity
```

### 3. 네트워크 요구사항

- **인터넷 연결**: Terraform 프로바이더 다운로드 및 AWS API 호출
- **방화벽**: AWS API 엔드포인트 (443 포트) 접근 허용
- **DNS**: AWS 서비스 도메인 해석 가능

## 배포 준비

### 1. 프로젝트 클론 및 설정

```bash
# 프로젝트 디렉토리로 이동
cd ~/q-terraform-1

# 프로젝트 구조 확인
tree -L 2
```

### 2. 환경 변수 설정

```bash
# 환경 변수 파일 생성
cat > .env << 'EOF'
export TF_VAR_environment_name="production"
export TF_VAR_aws_region="ap-northeast-2"
export AWS_DEFAULT_REGION="ap-northeast-2"
EOF

# 환경 변수 로드
source .env
```

### 3. 설정 파일 준비

```bash
# terraform.tfvars 파일 생성
cp terraform.tfvars.example terraform.tfvars

# 설정 파일 편집
vim terraform.tfvars
```

#### 필수 설정 항목
```hcl
# terraform.tfvars
environment_name = "production"
aws_region = "ap-northeast-2"

# 보안 설정 (반드시 변경!)
db_password = "your-secure-db-password-here"
mq_admin_password = "your-secure-mq-password-here"

# 채점 시스템 설정
grading_container_image = "your-registry/grading-service:latest"

# 네트워크 설정 (필요시 변경)
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
```

### 4. 채점 서비스 컨테이너 준비

#### Docker 이미지 빌드
```bash
# 채점 서비스 디렉토리 생성
mkdir -p grading-service
cd grading-service

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY src/ .

# 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080
CMD ["python", "grading_worker.py"]
EOF

# requirements.txt 생성
cat > requirements.txt << 'EOF'
boto3==1.34.0
stomp.py==8.1.0
flask==2.3.3
psutil==5.9.6
requests==2.31.0
EOF
```

#### 컨테이너 이미지 푸시
```bash
# ECR 레지스트리 생성 (선택적)
aws ecr create-repository --repository-name grading-service --region ap-northeast-2

# Docker 이미지 빌드
docker build -t grading-service:latest .

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | \
    docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 태그 및 푸시
docker tag grading-service:latest YOUR_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/grading-service:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/grading-service:latest
```

## 단계별 배포

### 1단계: Terraform 초기화

```bash
# 프로젝트 루트 디렉토리로 이동
cd ~/q-terraform-1

# Terraform 초기화
terraform init

# 초기화 결과 확인
ls -la .terraform/
```

**예상 출력:**
```
Initializing modules...
- compute in modules/compute
- database in modules/database
- ecs_grading in modules/ecs-grading
- messaging in modules/messaging
- security_groups in modules/security-groups
- storage in modules/storage
- vpc in modules/vpc

Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### 2단계: 배포 계획 검토

```bash
# 배포 계획 생성
terraform plan -out=tfplan

# 계획 상세 검토
terraform show tfplan
```

**주요 확인 사항:**
- ✅ 생성될 리소스 수 (약 50-60개)
- ✅ 보안 그룹 규칙
- ✅ 서브넷 CIDR 충돌 없음
- ✅ IAM 역할 및 정책
- ✅ 비용 예상치

### 3단계: 인프라 배포

```bash
# 배포 실행
terraform apply tfplan

# 또는 대화형 배포
terraform apply
```

**배포 시간:** 약 15-20분

**배포 순서:**
1. VPC 및 네트워킹 (2-3분)
2. 보안 그룹 (1분)
3. S3 버킷 (1분)
4. RDS 인스턴스 (8-10분)
5. Amazon MQ (3-5분)
6. ECS 클러스터 및 서비스 (2-3분)
7. ALB 및 Auto Scaling Group (3-4분)

### 4단계: 배포 상태 확인

```bash
# Terraform 상태 확인
terraform state list

# 주요 리소스 출력값 확인
terraform output

# AWS 콘솔에서 확인할 리소스들
echo "확인할 AWS 서비스:"
echo "- VPC: $(terraform output -raw vpc_id)"
echo "- ALB: $(terraform output -raw load_balancer_dns_name)"
echo "- ECS Cluster: $(terraform output -raw ecs_cluster_name)"
echo "- RDS: $(terraform output -raw database_endpoint)"
echo "- S3 Bucket: $(terraform output -raw grading_bucket_name)"
```

## 배포 후 검증

### 1. 웹 애플리케이션 접근 테스트

```bash
# ALB DNS 이름 가져오기
ALB_DNS=$(terraform output -raw load_balancer_dns_name)

# 웹 애플리케이션 접근 테스트
curl -I http://$ALB_DNS

# 브라우저에서 접근
echo "웹 애플리케이션 URL: http://$ALB_DNS"
```

**예상 응답:**
```
HTTP/1.1 200 OK
Content-Type: text/html
```

### 2. ECS 서비스 상태 확인

```bash
# ECS 클러스터 상태 확인
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
aws ecs describe-clusters --clusters $CLUSTER_NAME

# ECS 서비스 상태 확인
aws ecs describe-services --cluster $CLUSTER_NAME --services ${CLUSTER_NAME}-grading-service

# 실행 중인 태스크 확인
aws ecs list-tasks --cluster $CLUSTER_NAME --service-name ${CLUSTER_NAME}-grading-service
```

### 3. Amazon MQ 연결 테스트

```bash
# MQ 브로커 정보 확인
MQ_BROKER_ID=$(terraform output -raw mq_broker_id)
aws mq describe-broker --broker-id $MQ_BROKER_ID

# MQ 콘솔 URL 확인 (보안상 민감한 정보)
terraform output mq_console_url
```

### 4. 데이터베이스 연결 테스트

```bash
# RDS 엔드포인트 확인
DB_ENDPOINT=$(terraform output -raw database_endpoint)
DB_PORT=$(terraform output -raw database_port)

# 네트워크 연결 테스트 (VPC 내부에서)
# 주의: RDS는 프라이빗 서브넷에 있어 직접 접근 불가
echo "Database endpoint: $DB_ENDPOINT:$DB_PORT"
```

### 5. S3 버킷 접근 테스트

```bash
# S3 버킷 확인
BUCKET_NAME=$(terraform output -raw grading_bucket_name)
aws s3 ls s3://$BUCKET_NAME/

# 테스트 파일 업로드
echo "test" | aws s3 cp - s3://$BUCKET_NAME/test.txt

# 업로드 확인
aws s3 ls s3://$BUCKET_NAME/test.txt
```

### 6. 로그 확인

```bash
# ECS 태스크 로그 확인
LOG_GROUP=$(terraform output -raw ecs_log_group_name)
aws logs describe-log-streams --log-group-name $LOG_GROUP

# 최근 로그 확인
aws logs get-log-events \
    --log-group-name $LOG_GROUP \
    --log-stream-name "grading-worker/grading-worker/$(date +%Y/%m/%d)" \
    --limit 10
```

## 환경별 배포

### 개발 환경 (Development)

```bash
# 개발 환경용 설정
cat > terraform.tfvars << 'EOF'
environment_name = "dev"
aws_region = "ap-northeast-2"

# 비용 최적화 설정
db_instance_class = "db.t3.micro"
mq_instance_type = "mq.t3.micro"
ecs_desired_count = 1
ecs_max_capacity = 3
min_size = 1
max_size = 2
desired_capacity = 1

# 개발용 보안 설정
enable_ssh_access = true
ssh_cidr_blocks = ["0.0.0.0/0"]  # 개발 환경에서만!

# 간소화된 설정
db_multi_az = false
mq_deployment_mode = "SINGLE_INSTANCE"
enable_s3_lifecycle = false
EOF

terraform apply
```

### 스테이징 환경 (Staging)

```bash
# 스테이징 환경용 설정
cat > terraform.tfvars << 'EOF'
environment_name = "staging"
aws_region = "ap-northeast-2"

# 프로덕션과 유사한 설정
db_instance_class = "db.t3.small"
mq_instance_type = "mq.t3.micro"
ecs_desired_count = 2
ecs_max_capacity = 5

# 보안 설정
enable_ssh_access = false
db_multi_az = false
mq_deployment_mode = "SINGLE_INSTANCE"
EOF

terraform apply
```

### 프로덕션 환경 (Production)

```bash
# 프로덕션 환경용 설정
cat > terraform.tfvars << 'EOF'
environment_name = "production"
aws_region = "ap-northeast-2"

# 고성능 설정
db_instance_class = "db.t3.medium"
mq_instance_type = "mq.t3.small"
ecs_task_cpu = "1024"
ecs_task_memory = "2048"
ecs_desired_count = 3
ecs_max_capacity = 10

# 고가용성 설정
db_multi_az = true
mq_deployment_mode = "ACTIVE_STANDBY_MULTI_AZ"
enable_deletion_protection = true
db_deletion_protection = true

# 보안 강화
enable_ssh_access = false
mq_enable_audit_logs = true
enable_s3_versioning = true
EOF

terraform apply
```

## 롤백 가이드

### 1. 긴급 롤백 (Emergency Rollback)

```bash
# 이전 상태로 즉시 롤백
terraform apply -target=module.compute -auto-approve

# 또는 특정 리소스만 롤백
terraform apply -target=module.ecs_grading -auto-approve
```

### 2. 단계적 롤백 (Gradual Rollback)

```bash
# 1. ECS 서비스 스케일 다운
terraform apply -var="ecs_desired_count=0"

# 2. 문제 해결 후 다시 스케일 업
terraform apply -var="ecs_desired_count=2"
```

### 3. 완전 롤백 (Complete Rollback)

```bash
# 전체 인프라 제거 (주의!)
terraform destroy

# 확인 후 재배포
terraform apply
```

## 문제 해결

### 1. 일반적인 배포 오류

#### Terraform 초기화 실패
```bash
# 캐시 정리
rm -rf .terraform .terraform.lock.hcl

# 다시 초기화
terraform init
```

#### 권한 오류
```bash
# AWS 자격 증명 확인
aws sts get-caller-identity

# IAM 권한 확인
aws iam get-user
aws iam list-attached-user-policies --user-name YOUR_USERNAME
```

#### 리소스 생성 실패
```bash
# 상세 로그 확인
export TF_LOG=DEBUG
terraform apply

# 특정 리소스만 재생성
terraform taint module.vpc.aws_vpc.main
terraform apply
```

### 2. 네트워크 관련 문제

#### VPC CIDR 충돌
```bash
# 기존 VPC 확인
aws ec2 describe-vpcs --region ap-northeast-2

# CIDR 블록 변경
vim terraform.tfvars
# vpc_cidr = "10.1.0.0/16"  # 다른 CIDR 사용
```

#### 서브넷 가용성 존 오류
```bash
# 사용 가능한 AZ 확인
aws ec2 describe-availability-zones --region ap-northeast-2

# AZ 설정 확인
terraform console
> data.aws_availability_zones.available.names
```

### 3. 서비스별 문제 해결

#### RDS 생성 실패
```bash
# DB 서브넷 그룹 확인
aws rds describe-db-subnet-groups

# 파라미터 그룹 확인
aws rds describe-db-parameter-groups
```

#### ECS 태스크 시작 실패
```bash
# 태스크 정의 확인
aws ecs describe-task-definition --task-definition production-grading-task

# 서비스 이벤트 확인
aws ecs describe-services --cluster production-grading-cluster --services production-grading-service
```

#### MQ 브로커 생성 실패
```bash
# MQ 서브넷 확인
aws mq describe-broker --broker-id BROKER_ID

# 보안 그룹 확인
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx
```

## 모니터링 설정

### 1. CloudWatch 대시보드 생성

```bash
# 대시보드 JSON 파일 생성
cat > dashboard.json << 'EOF'
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "production-grading-service"],
          ["AWS/ECS", "MemoryUtilization", "ServiceName", "production-grading-service"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "ap-northeast-2",
        "title": "ECS Grading Service Metrics"
      }
    }
  ]
}
EOF

# 대시보드 생성
aws cloudwatch put-dashboard \
    --dashboard-name "3Tier-Grading-System" \
    --dashboard-body file://dashboard.json
```

### 2. 알람 설정

```bash
# CPU 사용률 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "ECS-CPU-High" \
    --alarm-description "ECS CPU utilization is high" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2

# 큐 크기 알람
aws cloudwatch put-metric-alarm \
    --alarm-name "MQ-Queue-Size-High" \
    --alarm-description "MQ queue size is high" \
    --metric-name QueueSize \
    --namespace AWS/AmazonMQ \
    --statistic Average \
    --period 300 \
    --threshold 100 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2
```

### 3. 로그 집계 설정

```bash
# 로그 그룹 생성 (이미 Terraform으로 생성됨)
aws logs describe-log-groups --log-group-name-prefix "/ecs/production-grading"

# 로그 스트림 확인
aws logs describe-log-streams --log-group-name "/ecs/production-grading"

# 로그 쿼리 예시
aws logs start-query \
    --log-group-name "/ecs/production-grading" \
    --start-time $(date -d '1 hour ago' +%s) \
    --end-time $(date +%s) \
    --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc'
```

## 배포 체크리스트

### 배포 전 체크리스트
- [ ] AWS 자격 증명 설정 완료
- [ ] terraform.tfvars 파일 설정 완료
- [ ] 채점 서비스 컨테이너 이미지 준비 완료
- [ ] 네트워크 CIDR 충돌 확인
- [ ] 비용 예산 확인
- [ ] 백업 계획 수립

### 배포 중 체크리스트
- [ ] Terraform 초기화 성공
- [ ] 배포 계획 검토 완료
- [ ] 배포 진행 상황 모니터링
- [ ] 오류 발생 시 즉시 대응

### 배포 후 체크리스트
- [ ] 웹 애플리케이션 접근 확인
- [ ] ECS 서비스 정상 동작 확인
- [ ] 데이터베이스 연결 확인
- [ ] MQ 브로커 상태 확인
- [ ] S3 버킷 접근 확인
- [ ] 모니터링 설정 완료
- [ ] 문서 업데이트

## 추가 리소스

- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS 배포 가이드](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/)
- [Amazon MQ 설정 가이드](https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/)
- [AWS 비용 최적화 가이드](https://aws.amazon.com/aws-cost-management/)

---

📝 **참고**: 이 가이드는 지속적으로 업데이트됩니다. 배포 중 문제가 발생하면 GitHub Issues에 보고해 주세요.

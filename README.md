# 3-Tier Web Service Architecture with Async Grading System

이 Terraform 프로젝트는 AWS에서 모듈화된 3-tier 웹 서비스 아키텍처와 비동기 채점 시스템을 구성합니다.

## 아키텍처 개요

### 기본 3-Tier 아키텍처

#### Presentation Tier (프레젠테이션 계층)
- **Application Load Balancer (ALB)**: 인터넷 트래픽을 받아 애플리케이션 서버로 분산
- **Public Subnets**: ALB가 위치하는 퍼블릭 서브넷 (ap-northeast-2a, ap-northeast-2d)

#### Application Tier (애플리케이션 계층)
- **EC2 Instances**: 웹 애플리케이션을 실행하는 서버들
- **Auto Scaling Group**: 트래픽에 따라 자동으로 인스턴스 수 조정
- **Private Subnets**: 애플리케이션 서버가 위치하는 프라이빗 서브넷

#### Data Tier (데이터 계층)
- **RDS MySQL**: 애플리케이션 데이터를 저장하는 관리형 데이터베이스
- **Database Subnets**: 데이터베이스가 위치하는 격리된 서브넷

### 비동기 채점 시스템 🆕

#### Message Queue Tier
- **Amazon MQ (ActiveMQ)**: 채점 요청과 결과를 처리하는 메시지 큐
- **SSM Parameter Store**: MQ 연결 정보 안전 저장

#### Processing Tier
- **ECS Fargate**: 채점 작업을 처리하는 컨테이너 서비스
- **Auto Scaling**: 작업량에 따른 자동 확장
- **CloudWatch**: 모니터링 및 로깅

#### Storage Tier
- **S3 Bucket**: 채점 파일 및 결과 저장
- **Lifecycle Management**: 자동 아카이빙 및 정리

> 📖 **자세한 비동기 채점 시스템 정보**: [README.ASYNC-GRADING.md](./README.ASYNC-GRADING.md)

## 모듈 구조

```
modules/
├── vpc/                    # VPC, 서브넷, 라우팅 관리
├── security-groups/        # 보안 그룹 관리 (ALB, Web, DB, MQ, ECS)
├── compute/               # ALB, ASG, Launch Template 관리
├── database/              # RDS 및 관련 리소스 관리
├── storage/               # S3 버킷 관리 (채점 파일용) 🆕
├── messaging/             # Amazon MQ 관리 🆕
└── ecs-grading/           # ECS 채점 시스템 관리 🆕
```

### 모듈별 기능

**기존 모듈들**
- **VPC 모듈 (`modules/vpc/`)**: VPC, Internet Gateway, NAT Gateway, 서브넷, 라우팅
- **Security Groups 모듈 (`modules/security-groups/`)**: 모든 계층의 보안 그룹 관리
- **Compute 모듈 (`modules/compute/`)**: ALB, Target Group, Launch Template, ASG
- **Database 모듈 (`modules/database/`)**: RDS MySQL, DB Subnet Group, Enhanced Monitoring

**새로운 모듈들 🆕**
- **Storage 모듈 (`modules/storage/`)**: 채점 파일용 S3 버킷, 라이프사이클, 암호화
- **Messaging 모듈 (`modules/messaging/`)**: Amazon MQ 브로커, SSM 파라미터, 로깅
- **ECS Grading 모듈 (`modules/ecs-grading/`)**: ECS 클러스터, 태스크, 오토스케일링

## 네트워크 구성

- **VPC**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.3.0/24, 10.0.4.0/24
- **Database Subnets**: 10.0.5.0/24, 10.0.6.0/24
- **NAT Gateways**: 각 AZ에 하나씩 배치하여 프라이빗 서브넷의 아웃바운드 연결 제공

## 사용 방법

### 1. 사전 요구사항
- Terraform >= 1.0
- AWS CLI 구성
- 적절한 AWS IAM 권한

### 2. 배포 단계

```bash
# 1. 변수 파일 생성
cp terraform.tfvars.example terraform.tfvars

# 2. 변수 파일 수정 (특히 db_password)
vim terraform.tfvars

# 3. Terraform 초기화
terraform init

# 4. 계획 확인
terraform plan

# 5. 배포 실행
terraform apply
```

### 3. 접속 확인

배포 완료 후 출력되는 `load_balancer_url`로 접속하여 웹 애플리케이션 확인

### 4. 정리

```bash
terraform destroy
```

## 주요 특징

- **모듈화**: 재사용 가능한 모듈 구조로 관리 용이
- **고가용성**: 2개의 가용성 존에 걸쳐 배포
- **자동 확장**: Auto Scaling Group으로 트래픽에 따른 자동 확장
- **보안**: 계층별 보안 그룹으로 최소 권한 원칙 적용
- **모니터링**: CloudWatch를 통한 종합적 모니터링
- **백업**: RDS 자동 백업 설정
- **비동기 처리**: Amazon MQ + ECS를 통한 확장 가능한 채점 시스템 🆕
- **메시지 큐**: 안정적인 작업 처리를 위한 ActiveMQ 🆕
- **컨테이너화**: ECS Fargate를 통한 서버리스 컨테이너 실행 🆕
- **파일 관리**: S3를 통한 채점 파일 및 결과 저장 🆕

## 설정 옵션

### 기본 설정
- `aws_region`: AWS 리전 설정
- `environment_name`: 환경 이름 (리소스 명명에 사용)

### 보안 설정
- `enable_ssh_access`: 웹 서버에 SSH 접근 허용 여부
- `ssh_cidr_blocks`: SSH 접근 허용 CIDR 블록
- `enable_ecs_alb_access`: ECS 태스크에 ALB 접근 허용 여부
- `enable_ecs_ssh`: ECS EC2 인스턴스에 SSH 접근 허용 여부

### 컴퓨팅 설정
- `instance_type`: EC2 인스턴스 타입
- `key_pair_name`: SSH 키 페어 이름
- `min_size`, `max_size`, `desired_capacity`: Auto Scaling 설정

### 데이터베이스 설정
- `db_multi_az`: Multi-AZ 배포 여부
- `db_deletion_protection`: 삭제 보호 활성화
- `db_backup_retention_period`: 백업 보관 기간

### 비동기 채점 시스템 설정 🆕
- `mq_engine_type`: 메시지 큐 엔진 (ActiveMQ/RabbitMQ)
- `mq_instance_type`: MQ 브로커 인스턴스 타입
- `use_fargate`: ECS에서 Fargate 사용 여부
- `ecs_task_cpu`, `ecs_task_memory`: ECS 태스크 리소스
- `grading_container_image`: 채점 서비스 컨테이너 이미지
- `enable_ecs_autoscaling`: ECS 오토스케일링 활성화

## 비용 최적화

- **EC2**: t3.micro 인스턴스 사용 (프리 티어 적용 가능)
- **RDS**: db.t3.micro, Single-AZ 배포 (개발/테스트 환경용)
- **MQ**: mq.t3.micro 인스턴스 사용 🆕
- **ECS**: Fargate 사용으로 서버 관리 불필요 🆕
- **S3**: 라이프사이클 정책으로 자동 아카이빙 🆕
- **CloudWatch**: 선택적 Enhanced Monitoring

## 보안 고려사항

- **네트워크 격리**: 프라이빗 서브넷에 애플리케이션 및 데이터베이스 배치
- **보안 그룹**: 계층별 최소 권한 네트워크 접근 제어
- **암호화**: RDS 및 S3 암호화 활성화
- **접근 제어**: RDS 및 MQ는 퍼블릭 액세스 비활성화
- **자격 증명 관리**: SSM Parameter Store를 통한 안전한 자격 증명 저장 🆕
- **IAM 역할**: ECS 태스크용 최소 권한 IAM 역할 🆕
- **VPC 엔드포인트**: AWS 서비스 접근을 위한 프라이빗 연결 (선택적)

## 확장성

모듈 구조로 인해 다음과 같은 확장이 용이합니다:
- **환경 복제**: 새로운 환경 (dev, staging, prod) 쉽게 추가
- **리전 확장**: 다른 리전으로 동일한 아키텍처 배포
- **서비스 추가**: 새로운 모듈 개발 및 통합
- **독립적 업데이트**: 각 모듈의 독립적 버전 관리
- **채점 시스템 확장**: 다양한 채점 엔진 추가 가능 🆕
- **메시지 큐 확장**: 다른 큐 시스템 (SQS, Kafka) 통합 가능 🆕

## 관련 문서

- 📖 [비동기 채점 시스템 상세 가이드](./README.ASYNC-GRADING.md)
- 🚀 [배포 가이드](./DEPLOYMENT.md)
- 🔧 [개발자 가이드](./docs/DEVELOPMENT.md) (예정)
- 🔍 [모니터링 가이드](./docs/MONITORING.md) (예정)

# 환경별 설정 (Environment Configurations)

이 디렉토리는 각 환경별 Terraform 설정 파일을 포함합니다.

## 환경 구성

### 개발 환경 (dev/)
- **목적**: 개발 및 테스트
- **특징**: 비용 최적화, 보안 완화, 최소 리소스
- **사용법**: 
  ```bash
  cp environments/dev/terraform.tfvars .
  ./scripts/deploy.sh dev apply
  ```

### 스테이징 환경 (staging/)
- **목적**: 프로덕션 배포 전 검증
- **특징**: 프로덕션과 유사하지만 축소된 리소스
- **사용법**:
  ```bash
  cp environments/staging/terraform.tfvars .
  ./scripts/deploy.sh staging apply
  ```

### 프로덕션 환경 (production/)
- **목적**: 실제 서비스 운영
- **특징**: 고가용성, 보안 강화, 모니터링 완비
- **사용법**:
  ```bash
  cp environments/production/terraform.tfvars .
  # 반드시 비밀번호 변경 후 배포!
  ./scripts/deploy.sh production apply
  ```

## 환경별 주요 차이점

| 구성 요소 | 개발 | 스테이징 | 프로덕션 |
|-----------|------|----------|----------|
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | 10.0.0.0/16 |
| **EC2 인스턴스** | t3.micro (1개) | t3.micro (2개) | t3.small (3개) |
| **RDS 인스턴스** | db.t3.micro | db.t3.small | db.t3.medium |
| **Multi-AZ** | ❌ | ❌ | ✅ |
| **MQ 배포 모드** | Single | Single | Multi-AZ |
| **ECS 태스크** | 256MB/0.25vCPU | 512MB/0.5vCPU | 1GB/1vCPU |
| **오토스케일링** | 1-3 | 1-8 | 2-20 |
| **백업 보관** | 1일 | 7일 | 30일 |
| **로그 보관** | 3일 | 7일 | 30일 |
| **삭제 보호** | ❌ | ❌ | ✅ |
| **SSH 접근** | ✅ | ❌ | ❌ |
| **모니터링** | 최소 | 기본 | 완전 |

## 보안 주의사항

⚠️ **중요**: 프로덕션 환경 배포 전 반드시 다음 항목을 변경하세요:

1. **데이터베이스 비밀번호**: `db_password`
2. **MQ 관리자 비밀번호**: `mq_admin_password`
3. **컨테이너 이미지**: 실제 채점 서비스 이미지로 변경
4. **SSH 키 페어**: 필요시 `key_pair_name` 설정

## 환경 전환

환경 간 전환 시 다음 명령어를 사용하세요:

```bash
# 개발 환경으로 전환
cp environments/dev/terraform.tfvars .

# 스테이징 환경으로 전환
cp environments/staging/terraform.tfvars .

# 프로덕션 환경으로 전환
cp environments/production/terraform.tfvars .
```

## 비용 예상

환경별 월 예상 비용 (서울 리전 기준):

- **개발**: ~$50-80
- **스테이징**: ~$150-200
- **프로덕션**: ~$400-600

*실제 비용은 사용량에 따라 달라질 수 있습니다.*

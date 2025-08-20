#!/bin/bash

# 3-Tier Architecture with Async Grading System - Deployment Script
# Usage: ./scripts/deploy.sh [environment] [action]
# Example: ./scripts/deploy.sh production apply

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=${1:-"dev"}
ACTION=${2:-"plan"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check required tools
    local tools=("terraform" "aws" "docker" "git")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed or not in PATH"
            exit 1
        fi
    done
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or invalid"
        exit 1
    fi
    
    # Check Terraform version
    local tf_version=$(terraform version -json | jq -r '.terraform_version')
    log_info "Terraform version: $tf_version"
    
    # Check AWS CLI version
    local aws_version=$(aws --version | cut -d/ -f2 | cut -d' ' -f1)
    log_info "AWS CLI version: $aws_version"
    
    log_success "Prerequisites check completed"
}

setup_environment() {
    log_info "Setting up environment: $ENVIRONMENT"
    
    cd "$PROJECT_DIR"
    
    # Set environment variables
    export TF_VAR_environment_name="$ENVIRONMENT"
    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-northeast-2}"
    export TF_VAR_aws_region="$AWS_DEFAULT_REGION"
    
    # Check if terraform.tfvars exists
    if [[ ! -f "terraform.tfvars" ]]; then
        log_warning "terraform.tfvars not found, creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        log_warning "Please edit terraform.tfvars with your specific values before proceeding"
        exit 1
    fi
    
    # Validate terraform.tfvars
    if grep -q "your-secure.*password-here" terraform.tfvars; then
        log_error "Please update default passwords in terraform.tfvars"
        exit 1
    fi
    
    log_success "Environment setup completed"
}

terraform_init() {
    log_info "Initializing Terraform..."
    
    cd "$PROJECT_DIR"
    
    # Initialize Terraform
    terraform init -upgrade
    
    # Validate configuration
    terraform validate
    
    log_success "Terraform initialization completed"
}

terraform_plan() {
    log_info "Creating Terraform plan..."
    
    cd "$PROJECT_DIR"
    
    # Create plan
    terraform plan -out="tfplan-$ENVIRONMENT" -var-file="terraform.tfvars"
    
    # Show plan summary
    terraform show -json "tfplan-$ENVIRONMENT" | jq -r '
        .planned_values.root_module.resources | length as $total |
        "Plan Summary:",
        "  Resources to create: \($total)",
        "  Environment: \(.[] | select(.type == "aws_vpc") | .values.tags.Environment // "unknown")"
    '
    
    log_success "Terraform plan created: tfplan-$ENVIRONMENT"
}

terraform_apply() {
    log_info "Applying Terraform plan..."
    
    cd "$PROJECT_DIR"
    
    # Check if plan exists
    if [[ ! -f "tfplan-$ENVIRONMENT" ]]; then
        log_error "Plan file not found. Run 'plan' action first."
        exit 1
    fi
    
    # Apply plan
    terraform apply "tfplan-$ENVIRONMENT"
    
    # Clean up plan file
    rm -f "tfplan-$ENVIRONMENT"
    
    log_success "Terraform apply completed"
}

terraform_destroy() {
    log_warning "This will destroy all resources in environment: $ENVIRONMENT"
    read -p "Are you sure? Type 'yes' to confirm: " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "Destroy cancelled"
        exit 0
    fi
    
    log_info "Destroying Terraform resources..."
    
    cd "$PROJECT_DIR"
    terraform destroy -var-file="terraform.tfvars" -auto-approve
    
    log_success "Terraform destroy completed"
}

post_deployment_checks() {
    log_info "Running post-deployment checks..."
    
    cd "$PROJECT_DIR"
    
    # Get outputs
    local alb_dns=$(terraform output -raw load_balancer_dns_name 2>/dev/null || echo "")
    local ecs_cluster=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "")
    local s3_bucket=$(terraform output -raw grading_bucket_name 2>/dev/null || echo "")
    
    if [[ -n "$alb_dns" ]]; then
        log_info "Testing ALB endpoint..."
        if curl -s -o /dev/null -w "%{http_code}" "http://$alb_dns" | grep -q "200"; then
            log_success "ALB is responding"
        else
            log_warning "ALB is not responding yet (may take a few minutes)"
        fi
    fi
    
    if [[ -n "$ecs_cluster" ]]; then
        log_info "Checking ECS service status..."
        local service_status=$(aws ecs describe-services \
            --cluster "$ecs_cluster" \
            --services "${ecs_cluster}-grading-service" \
            --query 'services[0].status' \
            --output text 2>/dev/null || echo "UNKNOWN")
        log_info "ECS service status: $service_status"
    fi
    
    if [[ -n "$s3_bucket" ]]; then
        log_info "Checking S3 bucket..."
        if aws s3 ls "s3://$s3_bucket" &>/dev/null; then
            log_success "S3 bucket is accessible"
        else
            log_warning "S3 bucket access check failed"
        fi
    fi
    
    log_success "Post-deployment checks completed"
}

show_outputs() {
    log_info "Deployment outputs:"
    
    cd "$PROJECT_DIR"
    
    echo ""
    terraform output
    echo ""
    
    # Show useful URLs and information
    local alb_dns=$(terraform output -raw load_balancer_dns_name 2>/dev/null || echo "")
    if [[ -n "$alb_dns" ]]; then
        echo -e "${GREEN}Web Application URL:${NC} http://$alb_dns"
    fi
    
    local mq_console=$(terraform output -raw mq_console_url 2>/dev/null || echo "")
    if [[ -n "$mq_console" ]]; then
        echo -e "${GREEN}MQ Console URL:${NC} $mq_console"
    fi
    
    echo ""
}

cleanup() {
    log_info "Cleaning up temporary files..."
    cd "$PROJECT_DIR"
    rm -f tfplan-*
    log_success "Cleanup completed"
}

show_help() {
    cat << EOF
3-Tier Architecture with Async Grading System - Deployment Script

Usage: $0 [environment] [action]

Environments:
  dev         Development environment (default)
  staging     Staging environment
  production  Production environment

Actions:
  plan        Create Terraform plan (default)
  apply       Apply Terraform plan
  destroy     Destroy all resources
  output      Show deployment outputs
  check       Run post-deployment checks
  help        Show this help message

Examples:
  $0 dev plan              # Create plan for dev environment
  $0 production apply      # Apply plan for production
  $0 staging destroy       # Destroy staging environment
  $0 production output     # Show production outputs

Prerequisites:
  - Terraform >= 1.0
  - AWS CLI >= 2.0
  - Docker >= 20.0
  - Valid AWS credentials
  - Configured terraform.tfvars file

EOF
}

# Main execution
main() {
    case "$ACTION" in
        "plan")
            check_prerequisites
            setup_environment
            terraform_init
            terraform_plan
            ;;
        "apply")
            check_prerequisites
            setup_environment
            terraform_init
            terraform_apply
            post_deployment_checks
            show_outputs
            ;;
        "destroy")
            check_prerequisites
            setup_environment
            terraform_init
            terraform_destroy
            cleanup
            ;;
        "output")
            cd "$PROJECT_DIR"
            show_outputs
            ;;
        "check")
            cd "$PROJECT_DIR"
            post_deployment_checks
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown action: $ACTION"
            show_help
            exit 1
            ;;
    esac
}

# Trap to cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"

# Contributing to AWS 3-Tier Async Grading Terraform

Thank you for your interest in contributing to this project! This document provides guidelines for contributing to the AWS 3-Tier Architecture with Async Grading System.

## 🤝 How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use issue templates** when available
3. **Provide detailed information**:
   - Environment details (Terraform version, AWS region, etc.)
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages and logs

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes** following our coding standards
4. **Test your changes** thoroughly
5. **Commit with clear messages**
6. **Submit a pull request**

## 📋 Development Guidelines

### Code Standards

#### Terraform Code
- Use consistent indentation (2 spaces)
- Add meaningful comments for complex logic
- Follow Terraform naming conventions
- Use variables for configurable values
- Include proper resource tags

#### Documentation
- Update README files for significant changes
- Include inline comments for complex configurations
- Provide examples for new features
- Update deployment guides if needed

### Testing

Before submitting changes:

1. **Validate Terraform syntax**:
   ```bash
   terraform fmt -check
   terraform validate
   ```

2. **Test in development environment**:
   ```bash
   cp environments/dev/terraform.tfvars .
   terraform plan
   ```

3. **Verify documentation**:
   - Check all links work
   - Ensure examples are accurate
   - Validate markdown syntax

### Commit Messages

Use clear, descriptive commit messages:

```
type(scope): brief description

Detailed explanation if needed

- List specific changes
- Reference issues: Fixes #123
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Examples**:
- `feat(ecs): add auto-scaling configuration`
- `fix(security): update security group rules`
- `docs(readme): add deployment troubleshooting section`

## 🏗️ Project Structure

```
├── modules/                 # Terraform modules
│   ├── vpc/                # VPC and networking
│   ├── security-groups/    # Security configurations
│   ├── compute/           # ALB and Auto Scaling
│   ├── database/          # RDS configuration
│   ├── storage/           # S3 bucket setup
│   ├── messaging/         # Amazon MQ setup
│   └── ecs-grading/       # ECS grading system
├── environments/          # Environment-specific configs
├── scripts/              # Deployment and utility scripts
└── docs/                 # Additional documentation
```

## 🔧 Development Setup

1. **Prerequisites**:
   - Terraform >= 1.0
   - AWS CLI >= 2.0
   - Git
   - Text editor with Terraform support

2. **Clone and setup**:
   ```bash
   git clone https://github.com/Mugen-Houyou/aws-3tier-async-grading-terraform.git
   cd aws-3tier-async-grading-terraform
   cp environments/dev/terraform.tfvars .
   ```

3. **Configure AWS credentials**:
   ```bash
   aws configure
   ```

## 📝 Pull Request Process

1. **Ensure your PR**:
   - Has a clear title and description
   - References related issues
   - Includes tests if applicable
   - Updates documentation if needed

2. **PR will be reviewed for**:
   - Code quality and standards
   - Security best practices
   - Documentation completeness
   - Backward compatibility

3. **After approval**:
   - Squash commits if requested
   - Ensure CI passes
   - Maintainer will merge

## 🚀 Release Process

1. **Version bumping**: Follow semantic versioning
2. **Changelog**: Update CHANGELOG.md
3. **Testing**: Verify in staging environment
4. **Tagging**: Create git tags for releases
5. **Documentation**: Update version references

## 💡 Contribution Ideas

### High Priority
- [ ] Add support for additional AWS regions
- [ ] Implement blue-green deployment strategy
- [ ] Add CloudFormation alternative
- [ ] Create Helm charts for Kubernetes deployment

### Medium Priority
- [ ] Add monitoring dashboards
- [ ] Implement cost optimization features
- [ ] Add support for different grading engines
- [ ] Create CI/CD pipeline examples

### Documentation
- [ ] Video tutorials
- [ ] Architecture decision records (ADRs)
- [ ] Performance benchmarking guide
- [ ] Security hardening checklist

## 🛡️ Security

- **Never commit sensitive data** (passwords, keys, tokens)
- **Use Terraform variables** for configurable values
- **Follow AWS security best practices**
- **Report security issues privately** to the maintainers

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check existing docs first
- **AWS Documentation**: For AWS-specific questions

## 🏆 Recognition

Contributors will be:
- Listed in the project README
- Mentioned in release notes
- Invited to join the maintainers team (for significant contributions)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to make this project better! 🎉

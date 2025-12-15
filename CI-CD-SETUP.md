# CI/CD Pipeline Setup Guide

This document provides a comprehensive guide to the multi-stage CI/CD pipeline implementation for the PetClinic application.

## Overview

The pipeline consists of 6 automated stages that build, test, secure, containerize, provision infrastructure, and deploy the application.

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    STAGE 1: BUILD & INSTALL                 │
│  • Maven build with Java 17                                 │
│  • JAR artifact creation                                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              STAGE 2: LINT & SECURITY SCAN                  │
│  • Checkstyle (code quality)                                │
│  • SpotBugs (bug detection)                                 │
│  • Trivy (vulnerability scanning)                           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│         STAGE 3: TEST WITH DATABASE & REDIS                 │
│  • PostgreSQL 15 service                                    │
│  • Redis 7 service                                          │
│  • Comprehensive test suite                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│           STAGE 4: DOCKER BUILD & PUSH                      │
│  • Multi-stage Docker build                                 │
│  • Image tagging (SHA, latest, timestamp)                   │
│  • Push to Docker Hub                                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│      STAGE 5: INFRASTRUCTURE PROVISIONING (TERRAFORM)       │
│  • Terraform validation                                     │
│  • Infrastructure planning                                  │
│  • Resource provisioning (AWS)                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│            STAGE 6: DEPLOY & SMOKE TESTS                    │
│  • Kubernetes manifest validation                           │
│  • kind cluster deployment                                  │
│  • Application health checks                                │
│  • Endpoint verification                                    │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

1. **GitHub Account** with repository access
2. **Docker Hub Account** (for image push)
3. **AWS Account** (optional, for Terraform)
4. **kubectl** (optional, for manual Kubernetes operations)

### Initial Setup

1. **Configure GitHub Secrets**

   Navigate to: `Settings → Secrets and variables → Actions`

   Required secrets:
   ```
   DOCKERHUB_USERNAME=your-dockerhub-username
   DOCKERHUB_TOKEN=your-dockerhub-access-token
   ```

   Optional secrets (for Terraform):
   ```
   AWS_ACCESS_KEY_ID=your-aws-access-key
   AWS_SECRET_ACCESS_KEY=your-aws-secret-key
   ```

2. **Trigger the Pipeline**

   ```bash
   git push origin main
   ```

   Or manually trigger from GitHub Actions UI.

3. **Monitor the Pipeline**

   Go to: `Actions` tab → Select workflow run → View stages

## Directory Structure

```
.
├── .github/
│   ├── workflows/
│   │   ├── main.yml                    # Main CI/CD pipeline
│   │   └── README.md                   # Workflow documentation
│   └── SECRETS.md                      # Secrets documentation
├── k8s/
│   ├── namespace.yaml                  # Kubernetes namespace
│   ├── configmap.yaml                  # Application configuration
│   ├── secret.yaml                     # Secrets (base64 encoded)
│   ├── postgres-statefulset.yaml       # PostgreSQL deployment
│   ├── redis-deployment.yaml           # Redis deployment
│   ├── deployment.yaml                 # Application deployment
│   ├── service.yaml                    # Service definition
│   └── ingress.yaml                    # Ingress configuration
├── infra/
│   └── terraform/
│       ├── main.tf                     # Infrastructure resources
│       ├── provider.tf                 # Provider configuration
│       ├── variables.tf                # Input variables
│       ├── outputs.tf                  # Output values
│       ├── terraform.tfvars.example    # Example variables
│       └── README.md                   # Terraform documentation
├── scripts/
│   └── smoke-test.sh                   # Smoke test script
├── Dockerfile                          # Multi-stage Docker build
└── pom.xml                             # Maven configuration (Java 17)
```

## Detailed Stage Information

### Stage 1: Build & Install

**Purpose**: Compile application and create distributable JAR

**Tools**:
- Maven 3.9.6
- Java 17 (Eclipse Temurin)

**Outputs**:
- JAR artifact: `target/spring-petclinic-*.jar`

**Success Criteria**:
- Clean build with no compilation errors
- All dependencies resolved
- JAR file created successfully

### Stage 2: Lint & Security Scan

**Purpose**: Ensure code quality and security

**Tools**:
- Checkstyle: Code style verification
- SpotBugs: Static analysis for bugs
- Trivy: Vulnerability scanning

**Outputs**:
- Security reports (XML format)

**Success Criteria**:
- No critical security vulnerabilities
- Code meets style guidelines
- No high-severity bugs detected

### Stage 3: Test with Database & Redis

**Purpose**: Verify application functionality

**Services**:
- PostgreSQL 15 (port 5432)
- Redis 7 (port 6379)

**Tests**:
- Unit tests
- Integration tests
- Database connectivity tests

**Outputs**:
- Test reports (Surefire format)

**Success Criteria**:
- All tests pass
- Services start successfully
- Database connections work

### Stage 4: Docker Build & Push

**Purpose**: Containerize application

**Base Images**:
- Build: `maven:3.9.6-eclipse-temurin-17`
- Runtime: `eclipse-temurin:17-jre`

**Image Tags**:
- `latest`: Latest build
- `<commit-sha>`: Specific commit
- `v1.0-<timestamp>`: Versioned release

**Success Criteria**:
- Image builds successfully
- Multi-stage build optimizes size
- Images pushed to Docker Hub (if configured)

### Stage 5: Infrastructure Provisioning

**Purpose**: Provision cloud resources

**Resources Created**:
- VPC (10.0.0.0/16)
- Public subnet (10.0.1.0/24)
- Security groups (SSH, HTTP)
- EC2 instance (t2.micro)
- S3 bucket

**Modes**:
- **Dry-run**: Validation only (no credentials)
- **Full**: Plan and apply (with credentials)

**Success Criteria**:
- Terraform configuration valid
- Plan executes without errors
- Resources created (if apply enabled)

### Stage 6: Deploy & Smoke Tests

**Purpose**: Deploy and verify application

**Deployment**:
1. Create kind cluster
2. Load Docker image
3. Apply Kubernetes manifests
4. Wait for pods to be ready

**Smoke Tests**:
- Health endpoint check
- Database connectivity
- Redis connectivity
- Critical endpoints

**Success Criteria**:
- All manifests apply successfully
- Pods start and become ready
- All smoke tests pass

## Configuration Files

### Kubernetes Manifests

#### namespace.yaml
Creates the `petclinic` namespace for resource isolation.

#### configmap.yaml
Environment configuration:
- Database connection details
- Redis configuration
- Logging settings

#### secret.yaml
Sensitive data (base64 encoded):
- Database username: `petclinic`
- Database password: `petclinic`

#### postgres-statefulset.yaml
PostgreSQL deployment:
- StatefulSet for data persistence
- PersistentVolumeClaim (1Gi)
- Health probes
- Resource limits

#### redis-deployment.yaml
Redis deployment:
- Deployment for caching
- ClusterIP service
- Health probes
- Resource limits

#### deployment.yaml
Application deployment:
- 2 replicas for HA
- Environment variables from ConfigMap/Secret
- Health and readiness probes
- Resource requests/limits

#### service.yaml
LoadBalancer service:
- Exposes port 80 → 8080
- Session affinity enabled

#### ingress.yaml
Ingress configuration:
- Host: `petclinic.local`
- NGINX ingress class

### Terraform Configuration

See [infra/terraform/README.md](infra/terraform/README.md) for detailed Terraform documentation.

### Smoke Test Script

Location: `scripts/smoke-test.sh`

Tests performed:
1. Application availability
2. Health endpoint status
3. Database connectivity
4. Redis connectivity
5. Critical endpoints
6. Metrics endpoint

Configuration via environment variables:
```bash
APP_URL=http://localhost:8080
MAX_RETRIES=30
RETRY_INTERVAL=10
```

## Running Components Locally

### Build Application
```bash
./mvnw clean package
```

### Run with Docker Compose
```bash
docker-compose up -d
# Access at http://localhost:8080
docker-compose down
```

### Run Tests
```bash
./mvnw test
```

### Build Docker Image
```bash
docker build -t petclinic-app:latest .
docker run -p 8080:8080 petclinic-app:latest
```

### Deploy to Kubernetes (Local)
```bash
# Create kind cluster
kind create cluster --name petclinic-test

# Load image
kind load docker-image petclinic-app:latest --name petclinic-test

# Apply manifests
kubectl apply -f k8s/

# Check status
kubectl get all -n petclinic

# Port forward
kubectl port-forward -n petclinic service/petclinic-service 8080:80

# Cleanup
kind delete cluster --name petclinic-test
```

### Run Smoke Tests
```bash
./scripts/smoke-test.sh
```

### Terraform Operations
```bash
cd infra/terraform

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy
```

## Troubleshooting

### Build Failures

**Symptom**: Maven build fails

**Solutions**:
1. Check Java version: `java -version` (should be 17)
2. Clear Maven cache: `rm -rf ~/.m2/repository`
3. Check network connectivity for dependency downloads

### Docker Build Failures

**Symptom**: Docker image build fails

**Solutions**:
1. Verify Dockerfile syntax
2. Check base image availability
3. Ensure sufficient disk space

### Test Failures

**Symptom**: Tests fail with database errors

**Solutions**:
1. Verify PostgreSQL service is running
2. Check database credentials
3. Review test logs in artifacts

### Deployment Failures

**Symptom**: Kubernetes pods fail to start

**Solutions**:
1. Check pod logs: `kubectl logs -n petclinic <pod-name>`
2. Verify image availability
3. Check resource limits
4. Validate manifest syntax

### Smoke Test Failures

**Symptom**: Health checks fail

**Solutions**:
1. Verify application is running: `kubectl get pods -n petclinic`
2. Check application logs
3. Verify database connectivity
4. Test endpoint manually: `curl http://localhost:8080/actuator/health`

## Security Considerations

### Secrets Management

- ✅ Use GitHub Secrets for sensitive data
- ✅ Never commit secrets to repository
- ✅ Use access tokens instead of passwords
- ✅ Rotate secrets regularly
- ✅ Use least privilege principle

### Docker Security

- ✅ Use official base images
- ✅ Multi-stage builds to minimize image size
- ✅ Run as non-root user (where possible)
- ✅ Scan images for vulnerabilities (Trivy)

### Kubernetes Security

- ✅ Use namespaces for isolation
- ✅ Store secrets in Kubernetes Secrets
- ✅ Apply resource limits
- ✅ Use network policies (where supported)
- ✅ Enable RBAC

### Infrastructure Security

- ✅ Use security groups to restrict access
- ✅ Enable encryption at rest and in transit
- ✅ Regular security audits
- ✅ Implement least privilege IAM policies

## Monitoring and Observability

### Pipeline Monitoring

- View workflow runs in GitHub Actions
- Download artifacts for detailed analysis
- Review stage-specific logs

### Application Monitoring

- Actuator endpoints: `/actuator/health`, `/actuator/info`, `/actuator/metrics`
- Application logs via `kubectl logs`
- Resource usage via `kubectl top`

## Maintenance

### Regular Updates

1. **Dependencies**: Update regularly for security patches
2. **Base Images**: Keep Docker images up to date
3. **Secrets**: Rotate credentials quarterly
4. **Documentation**: Keep in sync with changes

### Backup and Disaster Recovery

1. **Database**: Regular PostgreSQL backups
2. **Configuration**: Version control all configs
3. **Images**: Maintain multiple tagged versions
4. **Infrastructure**: Terraform state backup

## Support and Contributing

### Getting Help

1. Check this documentation
2. Review workflow logs
3. Check [.github/workflows/README.md](.github/workflows/README.md)
4. Open an issue in the repository

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request
5. Wait for CI/CD to pass
6. Request review

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Spring Boot PetClinic](https://github.com/spring-projects/spring-petclinic)

## License

See [LICENSE.txt](LICENSE.txt) for details.

---

**Last Updated**: December 2024
**Pipeline Version**: 1.0
**Maintainer**: DevOps Team

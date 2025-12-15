# GitHub Actions Workflows

This directory contains GitHub Actions workflow files for the PetClinic CI/CD pipeline.

## Active Workflows

### `main.yml` - Multi-Stage CI/CD Pipeline

The comprehensive production CI/CD pipeline with 6 stages:

#### Stage 1: Build & Install
- Builds the application using Maven with Java 17
- Creates JAR artifact
- Uploads artifact for use in subsequent stages

#### Stage 2: Lint & Security Scan
- Runs Checkstyle for code quality
- Executes SpotBugs for bug detection
- Performs Trivy security scanning
- Uploads security reports

#### Stage 3: Test with Database & Redis
- Spins up PostgreSQL 15 and Redis 7 services
- Runs comprehensive test suite
- Uploads test reports

#### Stage 4: Docker Build & Push
- Builds Docker image with Java 17
- Tags image with commit SHA, latest, and timestamp
- Pushes to Docker Hub (if credentials are configured)
- Saves image as artifact

#### Stage 5: Infrastructure Provisioning (Terraform)
- Validates Terraform configuration
- Runs terraform plan (dry-run if no AWS credentials)
- Applies infrastructure (main branch only, with credentials)

#### Stage 6: Deploy & Smoke Tests
- Validates Kubernetes manifests
- Creates kind (Kubernetes in Docker) cluster
- Deploys application with PostgreSQL and Redis
- Runs comprehensive smoke tests
- Verifies health endpoints

### Workflow Triggers

The `main.yml` workflow runs on:
- Push to `main`, `develop`, or `k8` branches
- Pull requests to `main` branch
- Manual trigger via workflow_dispatch

### Required Secrets

See [.github/SECRETS.md](../SECRETS.md) for details on required secrets:
- `DOCKERHUB_USERNAME` - Docker Hub username (required for push)
- `DOCKERHUB_TOKEN` - Docker Hub access token (required for push)
- `AWS_ACCESS_KEY_ID` - AWS credentials (optional, for Terraform)
- `AWS_SECRET_ACCESS_KEY` - AWS credentials (optional, for Terraform)

## Backup Workflows

### `ci-cd-old.yml.backup`

Previous CI/CD pipeline configuration. Kept for reference but not actively used.
This file has been renamed to prevent it from running and potentially conflicting with the main workflow.

## Workflow Artifacts

Each workflow run produces several artifacts:

- **app-jar**: Built application JAR file (1 day retention)
- **security-reports**: Checkstyle and SpotBugs reports (7 days retention)
- **test-reports**: Test results and coverage (7 days retention)
- **docker-image**: Compressed Docker image (1 day retention)

## Workflow Behavior

### Graceful Degradation

The pipeline is designed to handle missing secrets gracefully:

- **Docker Push**: Skipped if Docker Hub credentials not configured
- **Terraform Apply**: Runs in plan-only mode if AWS credentials not configured
- **Kubernetes Deploy**: Uses local kind cluster for testing

### Error Handling

- Non-critical steps use `continue-on-error: true`
- Each stage provides detailed logging
- Failed stages don't block subsequent stages where appropriate

### Stage Dependencies

```
build-and-install
    ↓
lint-and-security
    ↓
test
    ↓
docker-build-and-push
    ↓
terraform-provision
    ↓
deploy-and-test
    ↓
pipeline-summary
```

## Local Testing

### Test Workflow Syntax
```bash
# Install act (GitHub Actions local runner)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
act -W .github/workflows/main.yml
```

### Test Individual Components

#### Build
```bash
./mvnw clean package -DskipTests
```

#### Security Scan
```bash
./mvnw checkstyle:check
./mvnw spotbugs:spotbugs
```

#### Tests
```bash
docker-compose up -d postgres redis
./mvnw test
docker-compose down
```

#### Docker Build
```bash
docker build -t petclinic-app:latest .
docker run -p 8080:8080 petclinic-app:latest
```

#### Kubernetes Deploy
```bash
kind create cluster --name petclinic-test
kubectl apply -f k8s/
kind delete cluster --name petclinic-test
```

#### Smoke Tests
```bash
./scripts/smoke-test.sh
```

## Monitoring Workflow Runs

1. Go to the **Actions** tab in the GitHub repository
2. Click on the workflow run you want to monitor
3. View individual job logs by clicking on the job name
4. Download artifacts from the run summary page

## Troubleshooting

### Build Failures

- Check Java version (should be 17)
- Verify Maven dependencies are accessible
- Review build logs for compilation errors

### Test Failures

- Check if PostgreSQL and Redis services started correctly
- Review test logs in artifacts
- Verify database connection settings

### Docker Push Failures

- Verify Docker Hub credentials in secrets
- Check if Docker Hub repository exists
- Ensure token has push permissions

### Terraform Failures

- Verify AWS credentials are correct
- Check IAM permissions
- Review Terraform plan output

### Deployment Failures

- Validate Kubernetes manifests syntax
- Check kind cluster logs
- Review pod logs for application errors

## Best Practices

1. **Always test locally first** before pushing changes
2. **Review workflow logs** for warnings even if the run succeeds
3. **Keep secrets up to date** and rotate regularly
4. **Monitor artifact storage** and adjust retention as needed
5. **Use pull requests** to trigger test runs before merging to main

## Contributing

When modifying workflows:

1. Test syntax locally with `yamllint`
2. Validate YAML structure
3. Test changes on a feature branch first
4. Document any new secrets or requirements
5. Update this README with changes

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [HashiCorp Setup Terraform](https://github.com/hashicorp/setup-terraform)
- [Trivy Action](https://github.com/aquasecurity/trivy-action)
- [kind Documentation](https://kind.sigs.k8s.io/)

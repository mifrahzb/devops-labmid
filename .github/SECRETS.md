# GitHub Actions Secrets Configuration

This document describes the GitHub Secrets required for the CI/CD pipeline to function properly.

## Required Secrets

### Docker Hub Credentials (Required for Docker Push)

#### `DOCKERHUB_USERNAME`
- **Description**: Your Docker Hub username
- **Required**: Yes (for pushing Docker images)
- **Example**: `myusername`
- **How to obtain**: Sign up at https://hub.docker.com

#### `DOCKERHUB_TOKEN`
- **Description**: Docker Hub access token (not password)
- **Required**: Yes (for pushing Docker images)
- **How to obtain**:
  1. Log in to Docker Hub
  2. Go to Account Settings → Security
  3. Click "New Access Token"
  4. Give it a name and create
  5. Copy the token (you won't see it again)

### AWS Credentials (Optional - for Terraform)

#### `AWS_ACCESS_KEY_ID`
- **Description**: AWS access key for Terraform operations
- **Required**: No (Terraform stage will run in dry-run mode without it)
- **How to obtain**:
  1. Log in to AWS Console
  2. Go to IAM → Users → Your User
  3. Security Credentials → Create Access Key
  4. Copy the Access Key ID

#### `AWS_SECRET_ACCESS_KEY`
- **Description**: AWS secret access key for Terraform operations
- **Required**: No (Terraform stage will run in dry-run mode without it)
- **How to obtain**: Provided when you create the access key (copy immediately)

### Kubernetes Configuration (Optional - for Deployment)

#### `KUBECONFIG`
- **Description**: Base64-encoded kubeconfig file for kubectl access
- **Required**: No (Deploy stage will be skipped without it)
- **How to obtain**:
  ```bash
  cat ~/.kube/config | base64 -w 0
  ```
- **Note**: This should contain credentials for your Kubernetes cluster

## How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Enter the secret name and value
6. Click **Add secret**

## Security Best Practices

### DO:
- ✅ Use access tokens instead of passwords where possible
- ✅ Rotate secrets regularly
- ✅ Use secrets with minimal required permissions
- ✅ Delete secrets when no longer needed
- ✅ Use environment-specific secrets for different deployments

### DON'T:
- ❌ Never commit secrets to the repository
- ❌ Never log secret values in workflow output
- ❌ Never share secrets via insecure channels
- ❌ Never use production secrets in development workflows
- ❌ Never grant excessive permissions to service accounts

## Pipeline Behavior Without Secrets

The pipeline is designed to handle missing secrets gracefully:

| Secret Missing | Stage Affected | Behavior |
|----------------|----------------|----------|
| DOCKERHUB_USERNAME/TOKEN | Docker Push | Stage is skipped (conditional execution) |
| AWS_ACCESS_KEY_ID/SECRET | Terraform | Runs in plan-only (dry-run) mode |
| KUBECONFIG | Kubernetes Deploy | Stage is skipped or uses local context |

## Verification

To verify secrets are properly configured:

1. **Docker Hub**: Push to main/develop branch and check Docker Build stage
2. **AWS**: Check Terraform stage logs for successful authentication
3. **Kubernetes**: Check Deploy stage for successful kubectl commands

## Troubleshooting

### Docker Hub Authentication Fails
- Verify username is correct (case-sensitive)
- Ensure token (not password) is used
- Check if token has push permissions
- Verify token hasn't expired

### AWS Authentication Fails
- Verify access key ID format (should start with AKIA)
- Ensure secret access key is complete (40 characters)
- Check IAM user has required permissions
- Verify region is correctly configured

### Kubernetes Authentication Fails
- Ensure kubeconfig is properly base64 encoded
- Verify cluster endpoint is accessible
- Check if credentials haven't expired
- Ensure context is set correctly

## Contact

For issues with secret configuration, contact the DevOps team or repository maintainers.

## References

- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Hub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Kubernetes Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

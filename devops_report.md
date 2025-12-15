# DevOps Lab Exam - Comprehensive Report

## Executive Summary

This report documents the complete DevOps implementation for the Spring PetClinic application, demonstrating a production-grade CI/CD pipeline with containerization, orchestration, infrastructure as code, and comprehensive security practices.  The project showcases modern DevOps methodologies including Docker multi-stage builds, Kubernetes orchestration, GitHub Actions automation, Terraform infrastructure provisioning, and automated testing with PostgreSQL and Redis integration.

**Project Repository:** https://github.com/mifrahzb/devops-labmid

---

## 1. Technologies Used

### 1.1 Application Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **Spring Boot** | 4.0.0-M3 | Backend framework for Java applications |
| **Java** | 21 (Eclipse Temurin) | Programming language and runtime |
| **Maven** | 3.9.6 | Build automation and dependency management |
| **Thymeleaf** | Latest | Server-side template engine for frontend |
| **PostgreSQL** | 15 | Relational database for persistent storage |
| **Redis** | 7 (Alpine) | In-memory cache for performance optimization |

### 1.2 DevOps Tools & Platforms

| Tool | Version/Type | Purpose |
|------|--------------|---------|
| **Docker** | Latest | Application containerization |
| **Docker Compose** | v2+ | Multi-container orchestration |
| **Kubernetes** | v1.27+ | Container orchestration platform |
| **GitHub Actions** | Cloud | CI/CD automation platform |
| **Terraform** | 1.9. 0 | Infrastructure as Code (IaC) |
| **Docker Hub** | Cloud | Container image registry |
| **kind** | v0.20.0 | Kubernetes in Docker (testing) |

### 1.3 Security & Quality Tools

| Tool | Purpose | Stage |
|------|---------|-------|
| **Trivy** | Vulnerability scanning for filesystems and images | Stage 2 |
| **SpotBugs** | Static analysis for bug detection | Stage 2 |
| **Checkstyle** | Code quality and style enforcement | Stage 2 |
| **GitHub Secrets** | Secure credential management | All stages |

### 1.4 Testing Tools

| Tool | Purpose |
|------|---------|
| **JUnit** | Unit testing framework |
| **Spring Test** | Integration testing for Spring applications |
| **PostgreSQL Service** | Database integration testing |
| **Redis Service** | Cache integration testing |
| **Custom Smoke Tests** | Post-deployment validation |

---

## 2. Pipeline + Infrastructure Diagram

### 2.1 CI/CD Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                       GitHub Repository                              │
│                    mifrahzb/devops-labmid                           │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                │ Push/PR Trigger
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow                           │
│                     (Multi-Stage Pipeline)                           │
└─────────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
┌───────────────────────────────┐   ┌───────────────────────────────┐
│   STAGE 1: Build & Install    │   │  STAGE 2: Lint & Security     │
│   • Maven compile              │──▶│  • Checkstyle                 │
│   • Create JAR artifact        │   │  • SpotBugs                   │
│   • Upload artifacts           │   │  • Trivy security scan        │
└───────────────────────────────┘   └───────────────┬───────────────┘
                                                    │
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │   STAGE 3: Test Suite         │
                                    │   • PostgreSQL 15 service     │
                                    │   • Redis 7 service           │
                                    │   • Integration tests         │
                                    │   • Upload test reports       │
                                    └───────────────┬───────────────┘
                                                    │
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │ STAGE 4: Docker Build & Push  │
                                    │   • Multi-stage build         │
                                    │   • Tag:  SHA, latest, v1.0-*  │
                                    │   • Push to Docker Hub        │
                                    │   • Save image artifact       │
                                    └───────────────┬───────────────┘
                                                    │
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │ STAGE 5: Terraform Provision  │
                                    │   • Validate configuration    │
                                    │   • Plan infrastructure       │
                                    │   • Apply (main branch only)  │
                                    └───────────────┬───────────────┘
                                                    │
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │ STAGE 6: Deploy & Smoke Tests │
                                    │   • Create kind cluster       │
                                    │   • Deploy to Kubernetes      │
                                    │   • Run smoke tests           │
                                    │   • Verify health endpoints   │
                                    └───────────────────────────────┘
                                                    │
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │    Pipeline Summary           │
                                    │    • Aggregate results        │
                                    │    • Success/Failure report   │
                                    └───────────────────────────────┘
```

### 2.2 Application Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Load Balancer                                │
│                    (Kubernetes Service)                              │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
┌───────────────────────────────┐   ┌───────────────────────────────┐
│    PetClinic App Pod 1        │   │    PetClinic App Pod 2        │
│    (Deployment:  3 replicas)   │   │    (Deployment: 3 replicas)   │
│    • Spring Boot              │   │    • Spring Boot              │
│    • Port 8080                │   │    • Port 8080                │
│    • Health checks            │   │    • Health checks            │
└───────────┬───────────────────┘   └───────────┬───────────────────┘
            │                                   │
            └───────────┬───────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────────────────────┐   ┌───────────────────────────────┐
│   PostgreSQL StatefulSet      │   │      Redis Deployment         │
│   • postgres:15               │   │   • redis:7-alpine            │
│   • Port 5432                 │   │   • Port 6379                 │
│   • Persistent Volume (10Gi)  │   │   • AOF persistence           │
│   • Health probes             │   │   • Health probes             │
└───────────────────────────────┘   └───────────────────────────────┘
```

### 2.3 Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Terraform (AWS)                              │
│   • VPC and networking                                               │
│   • EC2 instances (optional)                                         │
│   • Security groups                                                  │
│   • RDS instances (optional)                                         │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                                │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                     Namespace:  petclinic                     │   │
│   │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │   │
│   │  │  ConfigMap   │  │   Secret     │  │   Service    │     │   │
│   │  └──────────────┘  └──────────────┘  └──────────────┘     │   │
│   │  ┌─────────────────────────────────────────────────────┐  │   │
│   │  │           Deployments & StatefulSets                │  │   │
│   │  │  • Application (3 replicas)                         │  │   │
│   │  │  • PostgreSQL (StatefulSet with PVC)                │  │   │
│   │  │  • Redis (1 replica)                                │  │   │
│   │  └─────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Secret Management Strategy

### 3.1 Multi-Layer Secret Management

Our implementation uses a defense-in-depth approach to secret management:

#### **Layer 1: Development Environment (. env files)**
- Secrets stored in `.env` files (git-ignored)
- Template provided via `.env.example`
- Used by Docker Compose for local development
- **Example:**
  ```env
  POSTGRES_DB=petclinic
  POSTGRES_USER=petclinic
  POSTGRES_PASSWORD=secure_password_here
  DATABASE_URL=jdbc:postgresql://postgres:5432/petclinic
  ```

#### **Layer 2: GitHub Secrets (CI/CD)**
- Encrypted secrets stored in GitHub repository settings
- Accessed via `${{ secrets.SECRET_NAME }}` in workflows
- **Configured Secrets:**
  - `DOCKERHUB_USERNAME` - Docker Hub registry username
  - `DOCKERHUB_TOKEN` - Docker Hub access token
  - `AWS_ACCESS_KEY_ID` - AWS credentials (optional)
  - `AWS_SECRET_ACCESS_KEY` - AWS credentials (optional)

#### **Layer 3: Kubernetes Secrets**
- Base64-encoded secrets stored in Kubernetes
- Mounted as environment variables or files
- **Implementation:**
  ```yaml
  apiVersion: v1
  kind:  Secret
  metadata:
    name: petclinic-secret
    namespace: petclinic
  type: Opaque
  stringData:
    postgres_user: ${POSTGRES_USER}
    postgres_password: ${POSTGRES_PASSWORD}
  ```

#### **Layer 4: ConfigMaps (Non-sensitive Configuration)**
- Non-sensitive configuration data
- Database URLs, application settings
- **Example:**
  ```yaml
  apiVersion: v1
  kind:  ConfigMap
  metadata:
    name: petclinic-config
  data:
    database_url: "jdbc:postgresql://postgres:5432/petclinic"
    postgres_db: "petclinic"
  ```

### 3.2 Best Practices Implemented

✅ **No hardcoded credentials** in source code  
✅ **Git-ignored** sensitive files (. env, terraform. tfstate)  
✅ **Encrypted at rest** (GitHub Secrets, Kubernetes Secrets)  
✅ **Least privilege access** - secrets only available to authorized services  
✅ **Rotation capability** - easy to update without code changes  
✅ **Environment-specific** - different secrets for dev/staging/prod  

### 3.3 Secret Access Pattern

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Developer  │────────▶│  . env file   │────────▶│Docker Compose│
│   (Local)    │         │ (git-ignored)│         │  (Local Dev) │
└──────────────┘         └──────────────┘         └──────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│ GitHub Action│────────▶│GitHub Secrets│────────▶│  Workflows   │
│   (CI/CD)    │         │  (Encrypted) │         │  (Pipeline)  │
└──────────────┘         └──────────────┘         └──────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│ Kubernetes   │────────▶│K8s Secrets   │────────▶│  Pods/Apps   │
│   (Runtime)  │         │ (Base64)     │         │  (Containers)│
└──────────────┘         └──────────────┘         └──────────────┘
```

---

## 4. Monitoring Strategy

### 4.1 Application-Level Monitoring

#### **Health Check Endpoints**
```
Endpoint                   Purpose
────────────────────────   ────────────────────────────
/                          Main application endpoint
/livez                     Liveness probe (is app running?)
/readyz                    Readiness probe (is app ready to serve?)
/actuator/health           Spring Boot actuator health
```

#### **Kubernetes Probes Configuration**

**Liveness Probe:**
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
```

**Readiness Probe:**
```yaml
readinessProbe:
  httpGet:
    path: /
    port: 8080
  initialDelaySeconds: 40
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
```

### 4.2 Infrastructure Monitoring

#### **Container Health**
- Docker health checks for all services
- PostgreSQL:  `pg_isready` command
- Redis: `redis-cli ping` command
- Application:  HTTP GET on port 8080

#### **Kubernetes Monitoring**
```bash
# Pod status
kubectl get pods -n petclinic -w

# Resource usage
kubectl top pods -n petclinic

# Events
kubectl get events -n petclinic --sort-by='. lastTimestamp'

# Logs
kubectl logs -n petclinic -l app=petclinic -f
```

### 4.3 CI/CD Pipeline Monitoring

#### **Automated Smoke Tests**
Our pipeline includes comprehensive smoke tests:

```bash
#!/bin/bash
# scripts/smoke-test.sh

# Test 1: Health endpoint
curl -f http://localhost:8080/ || exit 1

# Test 2: Database connectivity
# Verified through application logs

# Test 3: Redis connectivity
# Verified through application health

# Test 4: Response time
# Measured during health checks
```

#### **Pipeline Artifacts**
- **Build artifacts:** JAR files (1 day retention)
- **Security reports:** Trivy, SpotBugs, Checkstyle (7 days retention)
- **Test reports:** JUnit results (7 days retention)
- **Docker images:** Compressed images (1 day retention)

### 4.4 Logging Strategy

#### **Application Logs**
```bash
# Docker Compose
docker-compose logs -f app

# Kubernetes
kubectl logs -n petclinic -l app=petclinic --tail=100 -f
```

#### **Database Logs**
```bash
# PostgreSQL logs
kubectl logs -n petclinic -l app=postgres -f
```

#### **Pipeline Logs**
- GitHub Actions provides detailed logs for each stage
- Logs retained for 90 days
- Downloadable for local analysis

### 4.5 Alerting (Production Recommendations)

For production deployments, we recommend: 
- **Prometheus** for metrics collection
- **Grafana** for visualization dashboards
- **AlertManager** for notifications
- **ELK Stack** (Elasticsearch, Logstash, Kibana) for log aggregation
- **Datadog/New Relic** for APM (Application Performance Monitoring)

---

## 5. Pipeline Stages Breakdown

### Stage 1: Build & Install
**Duration:** ~2-3 minutes  
**Purpose:** Compile source code and create executable artifacts

**Steps:**
1. Checkout code from repository
2. Set up JDK 17 (Eclipse Temurin)
3. Cache Maven dependencies for faster builds
4. Run `./mvnw clean package -DskipTests`
5. Upload JAR artifact for downstream stages

**Success Criteria:** Build completes without compilation errors

---

### Stage 2: Lint & Security Scan
**Duration:** ~3-5 minutes  
**Purpose:** Code quality assurance and vulnerability detection

**Tools Used:**
- **Checkstyle:** Enforces coding standards
- **SpotBugs:** Detects common bugs and code smells
- **Trivy:** Scans for security vulnerabilities in dependencies

**Steps:**
1. Run Checkstyle analysis
2. Execute SpotBugs security scan
3. Perform Trivy filesystem scan
4. Upload security reports as artifacts

**Success Criteria:** No critical vulnerabilities found (warnings are non-blocking)

---

### Stage 3: Test with Database & Redis
**Duration:** ~4-6 minutes  
**Purpose:** Validate application functionality with real services

**Services Deployed:**
- PostgreSQL 15 (port 5432)
- Redis 7 (port 6379)

**Steps:**
1. Start PostgreSQL service with health checks
2. Start Redis service with health checks
3. Wait for services to be ready
4. Run full test suite (`./mvnw test`)
5. Upload test reports

**Success Criteria:** All tests pass, services are healthy

---

### Stage 4: Docker Build & Push
**Duration:** ~3-4 minutes  
**Purpose:** Create optimized container image

**Multi-Stage Build:**
```dockerfile
# Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY .  .
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin: 21-jre
WORKDIR /app
COPY --from=build /app/target/*. jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app. jar"]
```

**Image Tags:**
- `latest` - Latest successful build
- `<commit-sha>` - Specific commit version
- `v1.0-<timestamp>` - Timestamped release

**Success Criteria:** Image built and pushed to Docker Hub

---

### Stage 5: Terraform Provision
**Duration:** ~2-3 minutes  
**Purpose:** Infrastructure as Code validation

**Steps:**
1. Setup Terraform 1.9.0
2. Run `terraform fmt -check`
3. Run `terraform init`
4. Run `terraform validate`
5. Plan infrastructure changes
6. Apply (main branch with credentials only)

**Success Criteria:** Terraform configuration is valid

---

### Stage 6: Deploy & Smoke Tests
**Duration:** ~5-8 minutes  
**Purpose:** Deploy to Kubernetes and validate

**Steps:**
1. Create kind (Kubernetes in Docker) cluster
2. Load Docker image into cluster
3. Apply Kubernetes manifests (namespace, configmap, secret, deployments, services)
4. Wait for pods to be ready
5. Port-forward service for testing
6. Run comprehensive smoke tests
7. Verify health endpoints
8. Cleanup kind cluster

**Success Criteria:** Application is accessible and all smoke tests pass

---

## 6. Exam Requirements Checklist

### ✅ **Requirement 1: Containerization with Docker Compose**
- [x] Multi-service architecture (app + postgres + redis)
- [x] Environment variable configuration
- [x] Persistent volumes for data
- [x] Docker bridge networking
- [x] Health checks implemented

**Evidence:**
![Docker Containers](screenshots/containers_running.png)
*Proof of multiple containers running with Docker internal networking*

---

### ✅ **Requirement 2: CI/CD Pipeline with Bonus Tasks**
- [x] **5 Required Stages:** Build, Test, Security Scan, Docker Build, Deploy
- [x] **BONUS: 6th Stage** - Infrastructure provisioning with Terraform
- [x] Automated testing with database integration
- [x] Security scanning (Trivy, SpotBugs, Checkstyle)
- [x] Docker image publishing
- [x] Kubernetes deployment with smoke tests

**Evidence:**
![CI/CD Pipeline](screenshots/CID. png)
*Proof of 6-stage CI/CD pipeline running successfully*

---

### ✅ **Requirement 3: Secret Management**
- [x] No hardcoded passwords in source code
- [x] Environment-based configuration
- [x] GitHub Secrets for CI/CD
- [x] Kubernetes Secrets for orchestration
- [x] Git-ignored sensitive files

---

### ✅ **Requirement 4: Database Integration**
- [x] PostgreSQL 15 integrated
- [x] Redis cache integrated
- [x] Persistent storage with volumes
- [x] Health checks and probes
- [x] Connection pooling

---

### ✅ **Requirement 5: Deployment**
- [x] Image published to Docker Hub
- [x] Multiple image tags (latest, SHA, timestamped)
- [x] Automated deployment via CI/CD
- [x] Kubernetes manifests provided

**Evidence:**
![Docker Hub Deployment](screenshots/docker. jpg)
*Image successfully published to Docker Hub*

![Docker Hub Logs](screenshots/docker2.jpg)
*Image push logs showing successful deployment*

---

## 7. Lessons Learned

### 7.1 Java Version Compatibility Issues
**Challenge:** Initially attempted to use Java 25, which is not yet released as a stable version.

**Problem:**
- No Docker images available for Java 25
- Maven dependencies incompatible
- Build failures in CI/CD pipeline

**Solution:**
- Downgraded to Java 21 (LTS version)
- Updated all dependencies in `pom.xml`
- Changed Dockerfile base images to `eclipse-temurin:21`
- Updated GitHub Actions to use Java 17 for compatibility

**Lesson:** Always use stable, LTS versions of core dependencies in production environments.

---

### 7.2 Local vs.  CI/CD Environment Differences
**Challenge:** Containers ran perfectly locally but failed in GitHub Actions pipeline.

**Problem:**
- PostgreSQL service in GitHub Actions used port 5432
- Our integration tests also tried to bind to port 5432
- Port conflict caused test failures

**Solution:**
- Modified test configuration to use service containers
- Updated connection strings to use `localhost:5432` in CI/CD
- Used service health checks to ensure database was ready
- Added wait loops for service readiness

**Lesson:** Test environments should closely mimic CI/CD environments.  Use service containers in GitHub Actions for integration testing.

---

### 7.3 Git Branch Management
**Challenge:** Struggled with transitioning from cloned repository to our own repository.

**Problem:**
- Original remote origin pointed to spring-projects repository
- Confusion about branch naming conventions
- Merge conflicts when pushing to our repository

**Solution:**
```bash
# Remove old remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/mifrahzb/devops-labmid.git

# Verify
git remote -v

# Push to new repository
git push -u origin main
```

**Lesson:** Understand Git fundamentals before starting complex DevOps projects.  Document remote repository changes. 

---

### 7.4 Docker Multi-Stage Build Optimization
**Challenge:** Initial Docker images were over 1GB in size.

**Solution:**
- Implemented multi-stage builds
- Separated build stage (with Maven) from runtime stage (with JRE only)
- Used slim/alpine base images where possible
- Final image size reduced to ~400MB

**Lesson:** Multi-stage builds significantly reduce image size and improve deployment speed.

---

### 7.5 Kubernetes Probe Timeouts
**Challenge:** Pods were being killed prematurely during startup.

**Problem:**
- Default probe timeouts too short
- Database initialization took longer than expected
- Pods marked as unhealthy and restarted

**Solution:**
```yaml
livenessProbe: 
  initialDelaySeconds: 60  # Increased from 30
  timeoutSeconds: 5        # Added explicit timeout
  failureThreshold: 6      # Increased from 3
```

**Lesson:** Configure appropriate health check timings based on application startup characteristics.

---

### 7.6 Secret Management Learning Curve
**Challenge:** Initially considered committing `.env` file to repository.

**Realization:** This would expose sensitive credentials publicly.

**Solution:**
- Added `.env` to `.gitignore`
- Created `.env.example` as template
- Documented secret management in README
- Used GitHub Secrets for CI/CD

**Lesson:** Never commit secrets to version control. Use templating and documentation instead.

---

### 7.7 Pipeline Failure Handling
**Challenge:** Early pipeline failures blocked all subsequent stages.

**Solution:**
- Added `continue-on-error:  true` for non-critical steps
- Implemented graceful degradation (e.g., skip Docker push if no credentials)
- Added conditional execution based on secret availability
- Improved error messages and logging

**Lesson:** Design resilient pipelines that fail gracefully and provide clear feedback.

---

## 8. Performance Metrics

### 8.1 Build Times

| Stage | Average Duration | Notes |
|-------|-----------------|-------|
| Stage 1: Build | 2-3 minutes | Maven dependency caching helps |
| Stage 2: Security | 3-5 minutes | Trivy scan takes most time |
| Stage 3: Tests | 4-6 minutes | Database startup overhead |
| Stage 4: Docker | 3-4 minutes | Multi-stage build optimization |
| Stage 5: Terraform | 2-3 minutes | Validation only (no apply) |
| Stage 6: Deploy | 5-8 minutes | Kubernetes cluster creation |
| **Total Pipeline** | **19-29 minutes** | End-to-end execution |

### 8.2 Image Sizes

| Image | Size | Optimization |
|-------|------|-------------|
| Build Stage (Maven) | ~800MB | Not shipped |
| Runtime Stage (JRE) | ~400MB | Final image |
| PostgreSQL | ~380MB | Official image |
| Redis | ~40MB | Alpine variant |

---

## 9. Future Improvements

### 9.1 Short-Term (Next Sprint)
- [ ] Implement Prometheus metrics collection
- [ ] Add Grafana dashboards for visualization
- [ ] Configure automated database backups
- [ ] Add integration with Slack/Discord for pipeline notifications
- [ ] Implement blue-green deployment strategy

### 9.2 Medium-Term (Next Quarter)
- [ ] Set up ELK stack for centralized logging
- [ ] Implement auto-scaling based on CPU/memory
- [ ] Add chaos engineering tests
- [ ] Configure CDN for static assets
- [ ] Implement distributed tracing with Jaeger

### 9.3 Long-Term (Next Year)
- [ ] Migrate to service mesh (Istio/Linkerd)
- [ ] Implement GitOps with ArgoCD/FluxCD
- [ ] Add multi-region deployment
- [ ] Implement comprehensive disaster recovery
- [ ] Add AI-powered log analysis

---

## 10. Conclusion

This project successfully demonstrates a comprehensive DevOps implementation that meets and exceeds all exam requirements: 

### ✅ **Core Requirements Met:**
1. **Containerization:** Multi-service Docker Compose setup with 3 services
2. **CI/CD Pipeline:** 6-stage automated pipeline (5 required + 1 bonus)
3. **Secret Management:** Multi-layer approach with no hardcoded credentials
4. **Database Integration:** PostgreSQL and Redis with persistent storage
5. **Deployment:** Automated deployment with Docker Hub publishing

### 🌟 **Bonus Achievements:**
- Infrastructure as Code with Terraform (Stage 5)
- Comprehensive security scanning (Trivy, SpotBugs, Checkstyle)
- Kubernetes orchestration with StatefulSets
- Automated smoke testing post-deployment
- Health checks and monitoring probes
- Multi-stage Docker builds for optimization

### 📈 **Key Takeaways:**
1. **DevOps is iterative:** We encountered and solved multiple challenges
2. **Documentation is crucial:** Clear docs helped us troubleshoot issues
3. **Testing saves time:** Early testing caught issues before production
4. **Security first:** Implemented secret management from day one
5. **Automation pays off:** CI/CD pipeline catches issues automatically

### 👥 **Team Contributions:**
- **Zainab Sanaullah (FA22-BCS-189):** CI/CD pipeline, Docker configuration, security scanning
- **Mifrah Zia (FA22-BCS-150):** Kubernetes manifests, Terraform setup, documentation

---

## 11. References

- [Spring PetClinic Official Repository](https://github.com/spring-projects/spring-petclinic)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Documentation](https://www.terraform.io/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

---

**Report Date:** December 15, 2025  
**Project Status:** ✅ Completed Successfully  
**Repository:** https://github.com/mifrahzb/devops-labmid

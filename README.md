# Spring PetClinic DevOps Lab Exam

## 📋 Project Overview

This project demonstrates a complete DevOps pipeline for the Spring PetClinic application with PostgreSQL database and Redis cache. The implementation includes Docker containerization, Kubernetes orchestration, CI/CD automation via GitHub Actions, Infrastructure as Code with Terraform, and comprehensive security scanning.

The open source project was taken from the following GitHub Repo: 
https://github.com/spring-projects/spring-petclinic

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Spring Boot    │────▶│   PostgreSQL     │     │      Redis       │
│  Application    │     │   Database       │     │      Cache       │
│  (Port 8080)    │◀────│   (Port 5432)    │     │   (Port 6379)    │
└─────────────────┘     └──────────────────┘     └──────────────────┘
        │                        │                         │
        └────────────── Docker Compose / Kubernetes ───────┘
```

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Kubernetes** (optional, for K8s deployment)
- **kubectl** (optional, for K8s deployment)
- **Git**

---

## 📦 Running Locally

### Method 1: Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/mifrahzb/devops-labmid.git
   cd devops-labmid
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example . env
   # Edit .env with your preferred values (optional - defaults provided)
   ```

   **Environment Variables (. env):**
   ```env
   POSTGRES_DB=petclinic
   POSTGRES_USER=petclinic
   POSTGRES_PASSWORD=petclinic
   DATABASE_URL=jdbc:postgresql://postgres:5432/petclinic
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - **Frontend:** http://localhost:8080
   - **Database:** localhost:15432 (mapped from container port 5432)
   - **Redis:** localhost:6379

   > ⚠️ **Note:** Please wait for the containers to start up (may take 1-2 minutes on first run).

5. **View logs**
   ```bash
   docker-compose logs -f app
   ```

6. **Stop the application**
   ```bash
   docker-compose down
   ```

7. **Remove volumes (clean slate)**
   ```bash
   docker-compose down -v
   ```

---

## ☸️ Running via Kubernetes

### Method 2: Deploy to Kubernetes Cluster

1. **Prerequisites**
   - Kubernetes cluster (minikube, kind, or cloud provider)
   - kubectl configured to access your cluster

2. **Create namespace and deploy**
   ```bash
   # Apply all Kubernetes manifests
   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/secret.yaml
   kubectl apply -f k8s/postgres-statefulset. yaml
   kubectl apply -f k8s/redis-deployment.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   ```

3. **Verify deployment**
   ```bash
   kubectl get all -n petclinic
   kubectl get pods -n petclinic -w
   ```

4. **Access the application**
   ```bash
   # For LoadBalancer (cloud)
   kubectl get svc petclinic-service -n petclinic
   
   # For local testing (port-forward)
   kubectl port-forward -n petclinic service/petclinic-service 8080:80
   ```
   Then access: http://localhost:8080

5. **View application logs**
   ```bash
   kubectl logs -n petclinic -l app=petclinic --tail=100 -f
   ```

---

## 🏗️ Infrastructure Setup and Teardown

### Terraform Infrastructure Provisioning

The project includes Terraform configurations for AWS infrastructure provisioning. 

#### Setup Infrastructure

1. **Navigate to infrastructure directory**
   ```bash
   cd infra/terraform
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Configure AWS credentials**
   ```bash
   export AWS_ACCESS_KEY_ID="your_access_key"
   export AWS_SECRET_ACCESS_KEY="your_secret_key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

4. **Plan infrastructure changes**
   ```bash
   terraform plan
   ```

5. **Apply infrastructure**
   ```bash
   terraform apply
   ```

#### Teardown Infrastructure

1. **Destroy all resources**
   ```bash
   terraform destroy
   ```

2. **Verify cleanup**
   ```bash
   terraform show
   ```

> **Note:** The CI/CD pipeline automatically handles Terraform operations on the main branch with proper AWS credentials configured.

---

## 📂 Project Structure

```
devops-labmid/
├── . github/
│   └── workflows/
│       └── main.yml              # 6-stage CI/CD pipeline
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── configmap.yaml            # Configuration data
│   ├── secret. yaml               # Sensitive data (secrets)
│   ├── postgres-statefulset.yaml # PostgreSQL StatefulSet
│   ├── redis-deployment.yaml     # Redis Deployment
│   ├── deployment.yaml           # Application Deployment
│   ├── service.yaml              # LoadBalancer Service
│   └── ingress.yaml              # Ingress configuration
├── infra/
│   └── terraform/                # Infrastructure as Code
│       ├── main.tf               # Main Terraform config
│       ├── provider.tf           # AWS provider setup
│       ├── variables. tf          # Variable definitions
│       └── outputs.tf            # Output values
├── scripts/
│   └── smoke-test. sh             # Automated smoke tests
├── src/                          # Spring Boot source code
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.yml            # Multi-container orchestration
├── . env.example                  # Environment template
├── pom.xml                       # Maven dependencies
├── README.md                     # This file
└── devops_report.md              # Detailed DevOps report
```

---

## 🛠️ Technologies Used

### Application Stack
- **Backend:** Spring Boot 4.0.0-M3
- **Java Version:** 21 (Eclipse Temurin)
- **Build Tool:** Maven 3.9.6
- **Frontend:** Thymeleaf Templates
- **Database:** PostgreSQL 15
- **Cache:** Redis 7 (Alpine)

### DevOps Tools
- **Containerization:** Docker, Docker Compose
- **Orchestration:** Kubernetes (StatefulSets, Deployments, Services)
- **CI/CD:** GitHub Actions (6-stage pipeline)
- **Container Registry:** Docker Hub
- **Infrastructure as Code:** Terraform (AWS)
- **Security Scanning:** Trivy, SpotBugs, Checkstyle
- **Secret Management:** GitHub Secrets + Kubernetes Secrets
- **Networking:** Docker Bridge Networks, Kubernetes Services

---

## 🔐 Secret Management

### Docker Compose
Secrets are managed via `.env` file (excluded from git):
```bash
cp .env.example .env
# Edit .env with your secrets
```

### Kubernetes
Secrets are stored in Kubernetes Secret objects:
```bash
kubectl get secrets -n petclinic
```

### CI/CD Pipeline
GitHub Secrets are used for sensitive data:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_ACCESS_KEY_ID` (optional)
- `AWS_SECRET_ACCESS_KEY` (optional)

---

## 🔍 Testing

### Run Tests Locally
```bash
# Unit tests
./mvnw test

# With PostgreSQL
docker-compose up -d postgres redis
./mvnw test -Dspring. profiles.active=postgres
docker-compose down
```

### Smoke Tests (Post-Deployment)
```bash
chmod +x scripts/smoke-test. sh
APP_URL=http://localhost:8080 ./scripts/smoke-test.sh
```

---

## 📊 Monitoring & Health Checks

### Application Health Endpoints
- **Liveness:** http://localhost:8080/livez
- **Readiness:** http://localhost:8080/readyz
- **Actuator:** http://localhost:8080/actuator/health

### Kubernetes Probes
The deployment includes: 
- **Liveness Probe:** HTTP GET on port 8080
- **Readiness Probe:** HTTP GET on port 8080
- **Startup Probe:** TCP check on PostgreSQL

### View Logs
```bash
# Docker Compose
docker-compose logs -f app

# Kubernetes
kubectl logs -n petclinic -l app=petclinic -f
```

---

## 🤝 Contributors

- **Zainab Sanaullah** - FA22-BCS-189
- **Mifrah Zia** - FA22-BCS-150

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE. txt](LICENSE.txt) file for details.

---

## 📚 Additional Documentation

For detailed information about the DevOps implementation, pipeline architecture, and lessons learned, see: 
- **[devops_report.md](devops_report.md)** - Comprehensive DevOps report
- **[CI-CD-SETUP.md](CI-CD-SETUP.md)** - CI/CD pipeline documentation
- **[. github/workflows/README.md](.github/workflows/README.md)** - Workflow documentation

---

## 🐛 Troubleshooting

### Container won't start
```bash
docker-compose down -v  # Remove volumes
docker-compose up --build  # Rebuild images
```

### Port already in use
```bash
# Check what's using the port
lsof -i :8080
# Kill the process or change port in docker-compose.yml
```

### Database connection errors
```bash
# Verify PostgreSQL is running
docker-compose ps postgres
# Check logs
docker-compose logs postgres
```

### Kubernetes pods not ready
```bash
# Describe the pod to see events
kubectl describe pod <pod-name> -n petclinic
# Check logs
kubectl logs <pod-name> -n petclinic
```

---

## 🌟 Features Implemented

✅ Multi-stage Docker build for optimized images  
✅ Docker Compose orchestration with 3 services  
✅ Kubernetes deployment with StatefulSets and Deployments  
✅ 6-stage CI/CD pipeline with GitHub Actions  
✅ Security scanning (Trivy, SpotBugs, Checkstyle)  
✅ Infrastructure as Code with Terraform  
✅ Automated testing with PostgreSQL and Redis  
✅ Secret management via environment variables  
✅ Health checks and monitoring  
✅ Automated smoke tests  
✅ Docker Hub image publishing  

---

**For detailed DevOps analysis and implementation details, please refer to [devops_report.md](devops_report.md)**

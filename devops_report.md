# DevOps Lab Exam Report

## Executive Summary

This report documents the complete DevOps implementation for containerizing and automating the Spring PetClinic application. The project demonstrates a production-grade CI/CD pipeline with PostgreSQL database integration, following DevOps best practices for security, automation, and deployment.

## Technologies Used

### Application Stack
- **Backend Framework:** Spring Boot 4.0.0-M3
- **Java Version:** 21 (Eclipse Temurin)
- **Build Tool:** Maven 3.9.6
- **Frontend:** Thymeleaf Templates
- **Database:** PostgreSQL 15

### DevOps Tools
- **Containerization:** Docker, Docker Compose
- **CI/CD:** GitHub Actions
- **Container Registry:** Docker Hub
- **Secret Management:** GitHub Secrets + Environment Variables
- **Networking:** Docker Bridge Networks

### Testing & Quality ????????????????????
- **Unit Testing:** JUnit 5
- **Integration Testing:** Spring Test Framework
- **Security Scanning:** GitHub CodeQL
- **Code Quality:** Maven Checkstyle

## Pipeline Design

### CI/CD Architecture?????????
┌─────────────────────────────────────────────────────────────┐
│ GitHub Repository │
└───────────────────────────────┬─────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ GitHub Actions Trigger │
│ (on: push, pull_request to main branch) │
└───────────────────────────────┬─────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ Pipeline Stages │
├─────────────────┬─────────────────┬─────────────────────────┤
│ Stage 1 │ Stage 2 │ Stage 3 │
│ Build & Install│ Lint & Security│ Test Suite │
│ │ Scan │ │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Stage 4 │      Stage 5 │ │
│ Build Docker │ Deploy │ │
│ Image        │ (Conditional) │ │
└─────────────────┴─────────────────┴─────────────────────────┘

### Pipeline Stages Details

#### Stage 1: Build & Install
- **Purpose:** Compile source code and resolve dependencies
- **Tools:** Maven
- **Commands:** `mvn clean compile`
- **Output:** Compiled application ready for testing

#### Stage 2: Lint & Security Scan ???????????????
- **Purpose:** Code quality and vulnerability assessment
- **Tools:** GitHub CodeQL, Maven Checkstyle
- **Checks:** Static code analysis, security vulnerabilities
- **Output:** Security report and code quality metrics

#### Stage 3: Test Suite ?????????????
- **Purpose:** Automated testing with database integration
- **Tools:** JUnit, Spring Test, PostgreSQL service container
- **Database:** GitHub Actions PostgreSQL service
- **Commands:** `mvn test`
- **Output:** Test results and coverage reports

#### Stage 4: Build Docker Image???????????????
- **Purpose:** Create optimized container image
- **Tools:** Docker Buildx
- **Features:** Multi-stage build, layer caching
- **Output:** Docker image tagged with commit SHA

#### Stage 5: Deploy ????????????
- **Purpose:** Automated deployment to production
- **Conditions:** Tests pass + main branch + not PR
- **Targets:** Docker Hub, Render/Railway
- **Credentials:** GitHub Secrets for secure access

## Exam Requirements 
- ✅ **Containerization** with Docker Compose (Multi-service architecture)

![Docker Containers](screenshots/containers_running.png)
*Proof of multiple containers (app + postgres) running with Docker internal networking*

- ✅ **CI/CD Pipeline** with 5 stages (Build, Test, Security Scan, Docker Build, Deploy)
- ✅ **Secret Management** using environment variables (No hardcoded passwords)s
- ✅ **Database Integration** with PostgreSQL and persistent storage
- ✅ **No Hardcoded Passwords** .env file for passwords

## Lessons Learnt
We started off with 
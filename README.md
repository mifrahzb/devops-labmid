# Spring PetClinic DevOps Lab Exam

##  Project Overview

This project demonstrates a complete DevOps pipeline for containerizing and automating the Spring PetClinic application with PostgreSQL database. The implementation includes Docker containerization, CI/CD pipeline, and cloud deployment following DevOps best practices.

The open source project was taken from the following GitHub Repo:
https://github.com/spring-projects/spring-petclinic


## Architecture
┌─────────────────┐ ┌──────────────────┐
│ Spring Boot │ │ PostgreSQL │
│ App │◄──►│ Database │
│ (Port 8080) │ │ (Port 5432) │
└─────────────────┘ └──────────────────┘
│ │
└───── Docker Compose ─┘


##  Quick Start

### Prerequisites
- Docker Desktop
- Docker Compose
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/mifrahzb/devops-labmid.git
   cd devops-labmid

2.  #### Edit .env with your configuration
    cp .env.example .env

3.  **docker-compose up**


## Access the application

Frontend: http://localhost:8080

Database: localhost:5432

note: Please wait for the containers to start up, will take a while.


### Main files Structure:

devops-labmid/
├── src/                    # Spring Boot application source
├── Dockerfile             # Multi-stage build configuration
├── docker-compose.yml     # Multi-container orchestration
├── .env.example          # Environment template
├── .github/workflows/    # CI/CD pipeline definitions
├── README.md             # Project documentation
└── devops_report.md      # Detailed DevOps implementation report

## Technologies Used
Backend: Spring Boot 4.0.0-M3, Java 21
Database: PostgreSQL 15
Containerization: Docker, Docker Compose, DockerHub
CI/CD: GitHub Actions
Security: Environment-based secret management


👥 Contributors
[Zainab Sanaullah] - [FA22-BCS-189]
[Mifrah Zia] - [FA22-BCS-150]

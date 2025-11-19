# TravelMemory — End-to-End MERN Deployment & Monitoring (Detailed Documentation)

## Overview
This project demonstrates a full production-grade MERN application deployment on AWS using:
- **Terraform** for infrastructure provisioning  
- **Ansible** for configuration management  
- **EC2 Instances** for Web + DB  
- **MongoDB** for the database  
- **Prometheus + MongoDB Exporter** for metrics  
- **Grafana** for visualization and alerting  

This README.md contains **every step required** to deploy, configure, monitor, and analyze the TravelMemory MERN stack application.

---

## 1. Prerequisites
### Local Machine Requirements
- Terraform ≥ 1.0
- Ansible ≥ 2.12
- AWS CLI configured:
```
aws configure
```
- SSH key:  
  `/Users/sainath/Downloads/sainath-sai.pem`

Secure it:
```
chmod 400 /Users/sainath/Downloads/sainath-sai.pem
```

---

## 2. Repository Structure
```
TravelMemory-deploy/
├── terraform/
├── ansible/
├── monitoring/
├── .env.sample
└── README.md
```

---

## 3. Terraform — Provision AWS Infrastructure
Terraform creates:
- 1 EC2 Web Server (Node + Nginx + Prometheus + Grafana)
- 1 EC2 DB Server (MongoDB + Exporter)
- Security groups
- Outputs public IPs

### Commands:
```
cd terraform
terraform init
terraform apply -auto-approve
```

After apply, capture:
```
web_public_ip
db_public_ip
```

---

## 4. Update Configuration with DB Public IP
Replace `<DB_PUBLIC_IP>` in:
- `ansible/inventory.ini`
- `ansible/roles/web/tasks/main.yml`
- `monitoring/prometheus/prometheus.yml`
- `.env.sample`

---

## 5. Ansible — Configure Servers and Deploy MERN App
### Test Connection
```
ansible -i ansible/inventory.ini all -m ping --private-key ~/Downloads/sainath-sai.pem
```

### Run Playbook
```
ansible-playbook -i ansible/inventory.ini ansible/site.yml --private-key ~/Downloads/sainath-sai.pem
```

Ansible performs:
- Updates package lists
- Installs Node, MongoDB, Git, Nginx
- Clones TravelMemory repo
- Builds frontend
- Generates `.env` file
- Starts backend via PM2
- Configures firewall
- Secures SSH

---

## 6. Metrics & Monitoring Setup
### On Web Server:
- Prometheus installed and configured
- Scrapes:
  - Backend metrics → `/metrics`
  - MongoDB exporter → port `9216`

### On DB Server:
- MongoDB exporter installed
- Exposes DB metrics for Prometheus

---

## 7. Grafana Setup
### Install Grafana:
```
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl enable --now grafana-server
```

Access Grafana:
```
http://16.144.21.60:3000
```
Default:
- Username: `admin`
- Password: `admin` (change on first login)

### Import Dashboard:
Upload:
```
monitoring/grafana/dashboards/travelmemory-backend.json
```

---

## 8. Adding Prometheus Metrics to Node Backend
Ensure backend has `/metrics` endpoint implemented using:
```
npm install prom-client
```

Example code has been included in deployment.

---

## 9. Alerts Configuration
Set alerts in Grafana:
- High error rate
- Slow API responses
- MongoDB performance issues

Sample Prometheus alert rules can be extended.

---

## 10. Validation & Testing
### Test web app:
```
http://16.144.21.60
```

### Test metrics:
Backend:
```
curl http://16.144.21.60:5000/metrics
```
Prometheus:
```
http://16.144.21.60:9090
```

---

## 11. Load Testing (Optional)
Example:
```
ab -n 1000 -c 50 http://16.144.21.60/api/some-endpoint
```

Monitor:
- p95 latency
- CPU/memory usage
- DB ops/sec

---

## 12. Cleanup
To avoid AWS costs:
```
cd terraform
terraform destroy -auto-approve
```

---

## 13. Security Recommendations
- Do not store real passwords or secrets in repo
- Move DB & JWT secrets to AWS SSM Parameter Store
- Restrict SSH to your IP only
- Use private subnets in production

---

## 14. Architecture Diagram
<img width="2654" height="1628" alt="image" src="https://github.com/user-attachments/assets/dd1e60ac-9351-4671-aeee-1ae753d84e1e" />

---

## 15: Screens 
<img width="2474" height="1512" alt="image" src="https://github.com/user-attachments/assets/f34d0a2b-5235-4b0f-b73e-5e49075e4d1d" />



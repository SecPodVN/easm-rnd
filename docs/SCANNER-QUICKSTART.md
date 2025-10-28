# Scanner Quick Start Guide

## 🚀 Getting Started with Scanner API

This guide will help you quickly start using the EASM Scanner API.

## ✅ Current Status

**Deployment**: Successfully deployed and running  
**API Endpoints**: All 11 endpoints live and visible in Swagger UI  
**MongoDB**: Connected and healthy  
**Access**: http://localhost:8000/api/scanner/

## Prerequisites

- Docker and Docker Compose installed
- Kubernetes cluster (Minikube) running
- Skaffold installed
- Python 3.12+ (required for PyMongo compatibility)

## 1. Start the Application

Use the existing startup script:

```powershell
.\skaffold.ps1
```

This will automatically:
- Start PostgreSQL, Redis, and MongoDB containers
- Deploy the Django API
- Set up port forwarding
- Make the API available at http://localhost:8000

## 2. Verify Scanner Service

Check that the scanner is running:

```bash
curl http://localhost:8000/api/scanner/healthStatus
```

Expected response:
```json
{
  "status": "healthy",
  "service": "scanner",
  "message": "Scanner service is running"
}
```

## 3. Upload Sample Resources

Create a file `resources.json`:

```json
{
  "resources": [
    {
      "name": "web-server-prod-1",
      "resource_type": "ec2",
      "region": "us-east-1",
      "status": "running",
      "public_ip": true,
      "port": 80,
      "tags": {
        "environment": "production",
        "team": "web"
      }
    },
    {
      "name": "database-prod-1",
      "resource_type": "rds",
      "region": "us-east-1",
      "status": "available",
      "public_access": false,
      "encryption": true,
      "tags": {
        "environment": "production",
        "team": "data"
      }
    },
    {
      "name": "storage-bucket-1",
      "resource_type": "s3",
      "region": "us-west-2",
      "public_access": true,
      "versioning": false,
      "tags": {
        "environment": "development"
      }
    }
  ]
}
```

Upload resources:

```bash
curl -X POST http://localhost:8000/api/scanner/uploadResources \
  -H "Content-Type: application/json" \
  -d @resources.json
```

## 4. Upload Sample Rules

Create a file `rules.json`:

```json
{
  "rules": [
    {
      "name": "Public EC2 Instance",
      "description": "Detects EC2 instances with public IP addresses",
      "field": "public_ip",
      "op": "eq",
      "value": "true",
      "severity": "HIGH",
      "resource_type": "ec2"
    },
    {
      "name": "Unencrypted Database",
      "description": "Detects RDS instances without encryption",
      "field": "encryption",
      "op": "eq",
      "value": "false",
      "severity": "CRITICAL",
      "resource_type": "rds"
    },
    {
      "name": "Public S3 Bucket",
      "description": "Detects S3 buckets with public access",
      "field": "public_access",
      "op": "eq",
      "value": "true",
      "severity": "HIGH",
      "resource_type": "s3"
    },
    {
      "name": "S3 Without Versioning",
      "description": "Detects S3 buckets without versioning enabled",
      "field": "versioning",
      "op": "eq",
      "value": "false",
      "severity": "MEDIUM",
      "resource_type": "s3"
    }
  ]
}
```

Upload rules:

```bash
curl -X POST http://localhost:8000/api/scanner/uploadRules \
  -H "Content-Type: application/json" \
  -d @rules.json
```

## 5. Run a Scan

Execute the scanner to evaluate all resources against all rules:

```bash
curl http://localhost:8000/api/scanner/scanResources
```

Expected response:
```json
{
  "message": "Scan completed successfully",
  "results": {
    "resources_scanned": 3,
    "rules_evaluated": 12,
    "findings_created": 3
  }
}
```

## 6. View Findings

Get all detected issues:

```bash
curl http://localhost:8000/api/scanner/findings
```

## 7. View Analytics

### Severity Summary

```bash
curl http://localhost:8000/api/scanner/getSeverityStatus
```

Response:
```json
{
  "CRITICAL": 0,
  "HIGH": 2,
  "MEDIUM": 1,
  "LOW": 0,
  "INFO": 0
}
```

### Issues by Resource Type

```bash
curl http://localhost:8000/api/scanner/getIssuesBasedOnResourceTypes
```

Response:
```json
[
  {
    "resource_type": "ec2",
    "count": 1
  },
  {
    "resource_type": "s3",
    "count": 2
  }
]
```

### Issues by Region

```bash
curl http://localhost:8000/api/scanner/getIssuesBasedOnRegions
```

## 8. List Resources with Filtering

List all EC2 instances:

```bash
curl -X POST http://localhost:8000/api/scanner/listResources \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {"resource_type": "ec2"},
    "page_number": 1,
    "page_size": 10,
    "sort_by": "name",
    "sort_order": "asc"
  }'
```

Search for production resources:

```bash
curl -X POST http://localhost:8000/api/scanner/listResources \
  -H "Content-Type: application/json" \
  -d '{
    "search_str": "prod",
    "page_number": 1,
    "page_size": 10
  }'
```

## 9. Clean Up Resources

Delete all development resources:

```bash
curl -X POST http://localhost:8000/api/scanner/deleteResources \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {
      "tags.environment": "development"
    }
  }'
```

Delete all rules with LOW severity:

```bash
curl -X POST http://localhost:8000/api/scanner/deleteRules \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {
      "severity": "LOW"
    }
  }'
```

## 10. View API Documentation

Access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/

## Common Use Cases

### Use Case 1: Detect Public Resources

1. Upload resources with `public_ip` or `public_access` fields
2. Create rules checking for `public_ip: true` or `public_access: true`
3. Run scan
4. Review findings with HIGH severity

### Use Case 2: Compliance Checking

1. Define compliance rules (encryption, versioning, backups, etc.)
2. Upload all infrastructure resources
3. Run scan to identify non-compliant resources
4. Group findings by severity to prioritize remediation

### Use Case 3: Regional Security Analysis

1. Upload resources with region information
2. Create region-specific rules
3. Run scan
4. Use "Issues by Region" endpoint to identify high-risk regions

## MongoDB Direct Access

If you need to query MongoDB directly:

```bash
# Connect to MongoDB container
kubectl exec -it mongodb-0 -n easm-rnd -- mongosh

# Switch to easm_mongo database
use easm_mongo

# Query resources
db.resources.find()

# Query findings by severity
db.findings.find({severity: "HIGH"})

# Count findings by resource type
db.findings.aggregate([
  {$group: {_id: "$resource_type", count: {$sum: 1}}}
])
```

## Troubleshooting

### MongoDB Connection Issues

Check MongoDB is running:
```bash
kubectl get pods -n easm-rnd | grep mongodb
```

Check MongoDB logs:
```bash
kubectl logs -n easm-rnd mongodb-0
```

### API Not Responding

Check API logs:
```bash
kubectl logs -n easm-rnd -l app=easm-api --tail=100
```

### No Findings After Scan

1. Verify resources are uploaded: `POST /listResources`
2. Verify rules are uploaded: Check MongoDB directly
3. Ensure rule operators and values match resource data
4. Check rule `resource_type` filter matches resource types

## Performance Tips

1. **Pagination**: Use appropriate page sizes for listing resources
2. **Filtering**: Apply filters to reduce data transfer
3. **Bulk Operations**: Use bulk upload/delete for better performance
4. **Indexes**: Consider adding MongoDB indexes for frequently queried fields

## Next Steps

- Explore the full API documentation at `/api/docs/`
- Create custom rules for your specific use cases
- Integrate with CI/CD pipelines for automated scanning
- Set up scheduled scans using cron jobs or scheduled tasks
- Build dashboards using the analytics endpoints

---

**Need Help?**

- Check `docs/SCANNER-API-DOCUMENTATION.md` for detailed API reference
- Review `src/backend/apps/scanner/README.md` for technical details
- See example requests in the API documentation

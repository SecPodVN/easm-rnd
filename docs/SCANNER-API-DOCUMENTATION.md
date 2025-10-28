# Scanner API Documentation

## Overview

The Scanner API provides External Attack Surface Management (EASM) capabilities through a flexible resource scanning system. It uses MongoDB for efficient storage and querying of resources, rules, and findings.

## Base URL

All scanner endpoints are prefixed with `/api/scanner/`

## Authentication

Scanner endpoints currently use `AllowAny` permission for development. In production, configure appropriate authentication in `views.py`.

## API Endpoints

### 1. Health Check

**Endpoint:** `GET /api/scanner/healthStatus`

**Description:** Returns a simple health check message to verify the scanner service is running.

**Response:**
```json
{
  "status": "healthy",
  "service": "scanner",
  "message": "Scanner service is running"
}
```

---

### 2. Upload Resources

**Endpoint:** `POST /api/scanner/uploadResources`

**Description:** Bulk inserts an array of resource objects into the MongoDB resources collection.

**Request Body:**
```json
{
  "resources": [
    {
      "name": "my-ec2-instance",
      "resource_type": "ec2",
      "region": "us-east-1",
      "status": "running",
      "public_ip": true,
      "tags": {
        "environment": "production",
        "team": "security"
      },
      "metadata": {
        "instance_type": "t3.micro",
        "ami_id": "ami-12345"
      }
    }
  ]
}
```

**Response:**
```json
{
  "message": "Resources uploaded successfully",
  "count": 1
}
```

---

### 3. List Resources

**Endpoint:** `POST /api/scanner/listResources`

**Description:** Returns a paginated list of resources matching the filter, with search and sort capabilities.

**Request Body:**
```json
{
  "filter": {
    "resource_type": "ec2",
    "region": "us-east-1"
  },
  "page_number": 1,
  "page_size": 10,
  "sort_by": "name",
  "sort_order": "asc",
  "search_str": "prod"
}
```

**Parameters:**
- `filter` (optional): MongoDB filter object
- `page_number` (optional, default: 1): Page number for pagination
- `page_size` (optional, default: 10): Number of items per page
- `sort_by` (optional, default: "name"): Field to sort by
- `sort_order` (optional, default: "asc"): Sort order ("asc" or "desc")
- `search_str` (optional): Search string for resource name

**Response:**
```json
{
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "prod-ec2-instance",
      "resource_type": "ec2",
      "region": "us-east-1",
      "created_at": "2025-10-27T10:00:00Z",
      "updated_at": "2025-10-27T10:00:00Z"
    }
  ],
  "total": 1,
  "page_size": 10,
  "page_number": 1
}
```

---

### 4. Delete Resources

**Endpoint:** `POST /api/scanner/deleteResources`

**Description:** Deletes resources matching the specified MongoDB filter.

**Request Body:**
```json
{
  "filter": {
    "resource_type": "ec2",
    "status": "terminated"
  }
}
```

**Response:**
```json
{
  "message": "Resources deleted successfully",
  "count": 5
}
```

---

### 5. Upload Rules

**Endpoint:** `POST /api/scanner/uploadRules`

**Description:** Bulk inserts an array of rule objects into the MongoDB rules collection.

**Request Body:**
```json
{
  "rules": [
    {
      "name": "Public EC2 Instance Detection",
      "description": "Detects EC2 instances with public IP addresses",
      "field": "public_ip",
      "op": "eq",
      "value": "true",
      "severity": "HIGH",
      "resource_type": "ec2"
    },
    {
      "name": "High Port Number",
      "description": "Detects resources using high port numbers",
      "field": "port",
      "op": "gt",
      "value": "8000",
      "severity": "MEDIUM"
    }
  ]
}
```

**Rule Fields:**
- `name`: Rule name
- `description`: Rule description
- `field`: Resource field to check
- `op`: Operator (eq, neq, gt, lt, gte, lte, contains, not_contains, in, not_in)
- `value`: Expected value
- `severity`: Severity level (CRITICAL, HIGH, MEDIUM, LOW, INFO)
- `resource_type` (optional): Filter by resource type

**Response:**
```json
{
  "message": "Rules uploaded successfully",
  "count": 2
}
```

---

### 6. Delete Rules

**Endpoint:** `POST /api/scanner/deleteRules`

**Description:** Deletes rules matching the specified MongoDB filter.

**Request Body:**
```json
{
  "filter": {
    "severity": "LOW"
  }
}
```

**Response:**
```json
{
  "message": "Rules deleted successfully",
  "count": 3
}
```

---

### 7. List Findings

**Endpoint:** `GET /api/scanner/findings`

**Description:** Returns all findings from the findings collection. Each finding represents a detected issue from resource scanning.

**Response:**
```json
[
  {
    "_id": "507f1f77bcf86cd799439011",
    "resource_id": "507f191e810c19729de860ea",
    "resource_name": "my-ec2-instance",
    "resource_type": "ec2",
    "rule_name": "Public EC2 Instance Detection",
    "rule_description": "Detects EC2 instances with public IP addresses",
    "severity": "HIGH",
    "field": "public_ip",
    "actual_value": "true",
    "expected_value": "true",
    "created_at": "2025-10-27T10:05:00Z"
  }
]
```

---

### 8. Scan Resources

**Endpoint:** `GET /api/scanner/scanResources`

**Description:** Fetches all resources and rules, evaluates each resource against all rules using the scanning engine, and creates findings for violations.

**Response:**
```json
{
  "message": "Scan completed successfully",
  "results": {
    "resources_scanned": 150,
    "rules_evaluated": 1500,
    "findings_created": 23
  }
}
```

**Note:** This operation clears all existing findings before scanning.

---

### 9. Get Severity Status

**Endpoint:** `GET /api/scanner/getSeverityStatus`

**Description:** Aggregates findings by severity level (CRITICAL, HIGH, MEDIUM, LOW, INFO).

**Response:**
```json
{
  "CRITICAL": 5,
  "HIGH": 12,
  "MEDIUM": 23,
  "LOW": 8,
  "INFO": 3
}
```

---

### 10. Get Issues by Resource Type

**Endpoint:** `GET /api/scanner/getIssuesBasedOnResourceTypes`

**Description:** Aggregates findings by resource type.

**Response:**
```json
[
  {
    "resource_type": "ec2",
    "count": 15
  },
  {
    "resource_type": "s3",
    "count": 8
  },
  {
    "resource_type": "rds",
    "count": 5
  }
]
```

---

### 11. Get Issues by Region

**Endpoint:** `GET /api/scanner/getIssuesBasedOnRegions`

**Description:** Joins findings with resources to get region information and aggregates findings by region.

**Response:**
```json
[
  {
    "region": "us-east-1",
    "count": 20
  },
  {
    "region": "us-west-2",
    "count": 8
  },
  {
    "region": "eu-west-1",
    "count": 3
  }
]
```

---

## Supported Operators

The scanning engine supports the following operators:

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `"value": "true"` |
| `neq` | Not equals | `"value": "false"` |
| `gt` | Greater than | `"value": "100"` |
| `lt` | Less than | `"value": "50"` |
| `gte` | Greater than or equal | `"value": "80"` |
| `lte` | Less than or equal | `"value": "20"` |
| `contains` | String contains | `"value": "prod"` |
| `not_contains` | String does not contain | `"value": "test"` |
| `in` | Value in list | `"value": ["a", "b", "c"]` |
| `not_in` | Value not in list | `"value": ["x", "y", "z"]` |

---

## Data Models

### Resource
Flexible schema supporting any resource type:
- `_id`: MongoDB ObjectId (auto-generated)
- `name`: Resource name
- `resource_type`: Type of resource (ec2, s3, rds, etc.)
- `region`: Geographic region
- `tags`: Key-value pairs for tagging
- `metadata`: Additional metadata
- Custom fields as needed
- `created_at`: Creation timestamp
- `updated_at`: Update timestamp

### Rule
- `_id`: MongoDB ObjectId
- `name`: Rule name
- `description`: Rule description
- `field`: Field to evaluate
- `op`: Operator
- `value`: Expected value
- `severity`: Severity level
- `resource_type`: Optional resource type filter
- `created_at`: Creation timestamp
- `updated_at`: Update timestamp

### Finding
- `_id`: MongoDB ObjectId
- `resource_id`: Reference to resource
- `resource_name`: Resource name
- `resource_type`: Resource type
- `rule_name`: Rule that was violated
- `rule_description`: Rule description
- `severity`: Severity level
- `field`: Field that was checked
- `actual_value`: Actual value found
- `expected_value`: Expected value
- `operator`: Operator used
- `created_at`: Creation timestamp

---

## Example Workflow

### 1. Upload Resources
```bash
curl -X POST http://localhost:8000/api/scanner/uploadResources \
  -H "Content-Type: application/json" \
  -d '{
    "resources": [
      {
        "name": "web-server-1",
        "resource_type": "ec2",
        "region": "us-east-1",
        "public_ip": true,
        "port": 80
      }
    ]
  }'
```

### 2. Upload Rules
```bash
curl -X POST http://localhost:8000/api/scanner/uploadRules \
  -H "Content-Type: application/json" \
  -d '{
    "rules": [
      {
        "name": "Public EC2 Detection",
        "field": "public_ip",
        "op": "eq",
        "value": "true",
        "severity": "HIGH",
        "resource_type": "ec2"
      }
    ]
  }'
```

### 3. Run Scan
```bash
curl -X GET http://localhost:8000/api/scanner/scanResources
```

### 4. Get Findings
```bash
curl -X GET http://localhost:8000/api/scanner/findings
```

### 5. Get Analytics
```bash
curl -X GET http://localhost:8000/api/scanner/getSeverityStatus
curl -X GET http://localhost:8000/api/scanner/getIssuesBasedOnResourceTypes
curl -X GET http://localhost:8000/api/scanner/getIssuesBasedOnRegions
```

---

## MongoDB Configuration

MongoDB is configured in `src/backend/config/settings.py`:

```python
MONGODB_SETTINGS = {
    'host': config('MONGODB_HOST', default='localhost'),
    'port': config('MONGODB_PORT', default='27017', cast=int),
    'database': config('MONGODB_DB', default='easm_mongo'),
}
```

## API Documentation

All scanner endpoints are automatically included in:
- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/
- **OpenAPI Schema**: http://localhost:8000/api/schema/

---

## Error Handling

All endpoints return appropriate HTTP status codes:
- `200 OK` - Successful GET/DELETE operations
- `201 Created` - Successful POST operations
- `400 Bad Request` - Invalid request data
- `500 Internal Server Error` - Server errors

Error responses include details:
```json
{
  "field_name": [
    "Error message details"
  ]
}
```

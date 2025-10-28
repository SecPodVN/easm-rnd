# Scanner App

The Scanner app provides EASM resource scanning capabilities with MongoDB integration for flexible data storage and powerful querying.

## Features

- **Resource Management**: Upload, list, search, filter, and delete resources
- **Rule Management**: Define and manage scanning rules with flexible operators
- **Automated Scanning**: Evaluate resources against rules to identify issues
- **Finding Analysis**: Track and analyze detected issues
- **Analytics**: Severity summaries, resource type analysis, and regional breakdowns

## API Endpoints

All endpoints are prefixed with `/api/scanner/`

### Health
- `GET /healthStatus` - Health check

### Resources
- `POST /uploadResources` - Bulk upload resources
- `POST /listResources` - List resources with filtering, pagination, search
- `POST /deleteResources` - Delete resources by filter

### Rules
- `POST /uploadRules` - Bulk upload rules
- `POST /deleteRules` - Delete rules by filter

### Findings
- `GET /findings` - List all findings
- `GET /scanResources` - Execute scan on all resources

### Analytics
- `GET /getSeverityStatus` - Get findings count by severity
- `GET /getIssuesBasedOnResourceTypes` - Get findings by resource type
- `GET /getIssuesBasedOnRegions` - Get findings by region

## MongoDB Collections

### resources
Stores resource information with flexible schema:
```json
{
  "_id": "ObjectId",
  "name": "resource-name",
  "resource_type": "ec2|s3|rds|...",
  "region": "us-east-1",
  "tags": {},
  "metadata": {},
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### rules
Stores scanning rules:
```json
{
  "_id": "ObjectId",
  "name": "rule-name",
  "description": "rule description",
  "field": "field-to-check",
  "op": "eq|gt|lt|contains|...",
  "value": "expected-value",
  "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "resource_type": "optional-filter",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### findings
Stores scan results:
```json
{
  "_id": "ObjectId",
  "resource_id": "resource-id",
  "resource_name": "resource-name",
  "resource_type": "resource-type",
  "rule_name": "rule-name",
  "severity": "severity-level",
  "field": "checked-field",
  "actual_value": "actual-value",
  "expected_value": "expected-value",
  "created_at": "timestamp"
}
```

## Supported Rule Operators

- `eq` - Equals
- `neq` - Not equals
- `gt` - Greater than
- `lt` - Less than
- `gte` - Greater than or equal
- `lte` - Less than or equal
- `contains` - String contains
- `not_contains` - String does not contain
- `in` - Value in list
- `not_in` - Value not in list

## Example Usage

### Upload Resources
```bash
POST /api/scanner/uploadResources
{
  "resources": [
    {
      "name": "my-ec2-instance",
      "resource_type": "ec2",
      "region": "us-east-1",
      "status": "running",
      "public_ip": true
    }
  ]
}
```

### Upload Rules
```bash
POST /api/scanner/uploadRules
{
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
}
```

### Run Scan
```bash
GET /api/scanner/scanResources
```

### Get Findings
```bash
GET /api/scanner/findings
```

## MongoDB Configuration

MongoDB is configured in `settings.py`:
```python
MONGODB_SETTINGS = {
    'host': 'localhost',
    'port': 27017,
    'database': 'easm_mongo',
}
```

## Development

The scanner app uses PyMongo directly (not djongo) for MongoDB operations, providing:
- Full MongoDB query capabilities
- Flexible schema
- Aggregation pipeline support
- High performance

All scanner endpoints are automatically included in the Swagger/ReDoc API documentation at `/api/docs/`.

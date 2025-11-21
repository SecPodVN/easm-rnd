# Scanner API Migration Guide

## Overview

The Scanner API has been refactored to comply with Django REST Framework (DRF) routing standards. This document outlines the changes and provides migration instructions.

## Date: November 21, 2025

---

## Summary of Changes

### ✅ Compliance Improvements

1. **ViewSet Base Classes**: Changed from basic `viewsets.ViewSet` to proper DRF mixins
2. **RESTful Endpoints**: Implemented standard CRUD operations (list, create, retrieve, destroy)
3. **HTTP Methods**: Fixed incorrect method usage (GET for list operations instead of POST)
4. **URL Patterns**: Standardized endpoint naming and structure
5. **Tag Organization**: Better API documentation grouping

---

## API Endpoint Changes

### 🔵 Resource Endpoints

#### ✅ NEW Standard Endpoints (RESTful)

```http
GET    /api/scanner/resources/              # List resources with pagination
POST   /api/scanner/resources/              # Create single resource
GET    /api/scanner/resources/{id}/         # Retrieve single resource
DELETE /api/scanner/resources/{id}/         # Delete single resource
```

#### 🆕 NEW Custom Endpoints (Bulk Operations)

```http
POST   /api/scanner/resources/bulk_upload/  # Bulk upload resources
POST   /api/scanner/resources/bulk_delete/  # Bulk delete resources
```

#### ❌ DEPRECATED Endpoints (Non-RESTful)

```http
POST   /api/scanner/resources/upload/       # Use bulk_upload/ instead
POST   /api/scanner/resources/list/         # Use GET /resources/ instead
POST   /api/scanner/resources/delete/       # Use bulk_delete/ instead
```

---

### 🟢 Rule Endpoints

#### ✅ NEW Standard Endpoints (RESTful)

```http
GET    /api/scanner/rules/                  # List all rules
POST   /api/scanner/rules/                  # Create single rule
GET    /api/scanner/rules/{id}/             # Retrieve single rule
DELETE /api/scanner/rules/{id}/             # Delete single rule
```

#### 🆕 NEW Custom Endpoints (Bulk Operations)

```http
POST   /api/scanner/rules/bulk_upload/      # Bulk upload rules
POST   /api/scanner/rules/bulk_delete/      # Bulk delete rules
```

#### ❌ DEPRECATED Endpoints (Non-RESTful)

```http
POST   /api/scanner/rules/upload/           # Use bulk_upload/ instead
POST   /api/scanner/rules/delete/           # Use bulk_delete/ instead
```

---

### 🟡 Finding Endpoints

#### ✅ UNCHANGED - Already Compliant

```http
GET    /api/scanner/findings/                        # List all findings
GET    /api/scanner/findings/severity_status/        # Severity summary
GET    /api/scanner/findings/by_resource_type/       # Group by resource type
GET    /api/scanner/findings/by_region/              # Group by region
```

---

### 🟣 Scanner Operation Endpoints

#### ✅ UNCHANGED - Already Compliant

```http
GET    /api/scanner/scan/                   # Trigger scan operation
```

---

## Migration Instructions

### For Frontend/Client Developers

#### 1. Update Resource Operations

**Before:**
```javascript
// Old way - POST to list resources
const response = await fetch('/api/scanner/resources/list/', {
  method: 'POST',
  body: JSON.stringify({
    page_number: 1,
    page_size: 10,
    filter: {},
    search_str: 'example'
  })
});
```

**After:**
```javascript
// New way - GET with query parameters
const params = new URLSearchParams({
  page: 1,
  page_size: 10,
  search: 'example',
  sort_by: 'name',
  sort_order: 'asc'
});
const response = await fetch(`/api/scanner/resources/?${params}`);
```

#### 2. Update Bulk Upload Operations

**Before:**
```javascript
// Old endpoint
const response = await fetch('/api/scanner/resources/upload/', {
  method: 'POST',
  body: JSON.stringify({ resources: [...] })
});
```

**After:**
```javascript
// New endpoint
const response = await fetch('/api/scanner/resources/bulk_upload/', {
  method: 'POST',
  body: JSON.stringify({ resources: [...] })
});
```

#### 3. Single Resource Operations (NEW)

```javascript
// Create single resource
const createResponse = await fetch('/api/scanner/resources/', {
  method: 'POST',
  body: JSON.stringify({
    name: 'my-resource',
    type: 's3-bucket',
    // ... other fields
  })
});

// Get single resource
const getResponse = await fetch('/api/scanner/resources/60abc123def456789/');

// Delete single resource
const deleteResponse = await fetch('/api/scanner/resources/60abc123def456789/', {
  method: 'DELETE'
});
```

---

## Breaking Changes

### ⚠️ URL Changes

1. **Resource List Endpoint**
   - **Old**: `POST /api/scanner/resources/list/`
   - **New**: `GET /api/scanner/resources/`
   - **Action**: Update all list API calls to use GET with query parameters

2. **Bulk Upload Endpoints**
   - **Old**: `POST /api/scanner/resources/upload/`
   - **New**: `POST /api/scanner/resources/bulk_upload/`
   - **Action**: Update endpoint URLs to use `bulk_upload` instead of `upload`

3. **Bulk Delete Endpoints**
   - **Old**: `POST /api/scanner/resources/delete/`
   - **New**: `POST /api/scanner/resources/bulk_delete/`
   - **Action**: Update endpoint URLs to use `bulk_delete` instead of `delete`

### ⚠️ Request/Response Format Changes

#### Resource List Query Parameters

**Old (POST body):**
```json
{
  "page_number": 1,
  "page_size": 10,
  "filter": {},
  "search_str": "example",
  "sort_by": "name",
  "sort_order": "asc"
}
```

**New (GET query parameters):**
```
?page=1&page_size=10&search=example&sort_by=name&sort_order=asc
```

---

## Benefits of the New Structure

### 1. **RESTful Compliance**
- Standard HTTP methods (GET for read, POST for create, DELETE for delete)
- Predictable URL patterns
- Follows REST best practices

### 2. **Better Developer Experience**
- Intuitive API design
- Consistent with industry standards
- Easier to understand and use

### 3. **Improved Documentation**
- Better OpenAPI/Swagger schema generation
- Clearer endpoint organization with tags
- More accurate HTTP method documentation

### 4. **Enhanced Functionality**
- Single resource operations (retrieve, delete by ID)
- Flexible filtering via query parameters
- Maintains backward compatibility for bulk operations

### 5. **DRF Best Practices**
- Uses proper ViewSet mixins
- Leverages DRF's built-in functionality
- Better error handling with proper HTTP status codes

---

## Testing the New Endpoints

### Using cURL

```bash
# List resources
curl -X GET "http://localhost:8000/api/scanner/resources/?page=1&page_size=10"

# Create single resource
curl -X POST "http://localhost:8000/api/scanner/resources/" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-bucket",
    "type": "s3-bucket",
    "region": "us-east-1"
  }'

# Get single resource
curl -X GET "http://localhost:8000/api/scanner/resources/60abc123def456789/"

# Delete single resource
curl -X DELETE "http://localhost:8000/api/scanner/resources/60abc123def456789/"

# Bulk upload resources
curl -X POST "http://localhost:8000/api/scanner/resources/bulk_upload/" \
  -H "Content-Type: application/json" \
  -d '{
    "resources": [
      {"name": "resource1", "type": "s3-bucket"},
      {"name": "resource2", "type": "ec2-instance"}
    ]
  }'
```

### Using Python requests

```python
import requests

base_url = "http://localhost:8000/api/scanner"

# List resources
response = requests.get(f"{base_url}/resources/", params={
    "page": 1,
    "page_size": 10,
    "search": "example"
})
resources = response.json()

# Create single resource
response = requests.post(f"{base_url}/resources/", json={
    "name": "my-resource",
    "type": "s3-bucket",
    "region": "us-east-1"
})
created_resource = response.json()

# Get single resource
resource_id = "60abc123def456789"
response = requests.get(f"{base_url}/resources/{resource_id}/")
resource = response.json()

# Delete single resource
response = requests.delete(f"{base_url}/resources/{resource_id}/")
```

---

## OpenAPI/Swagger Documentation

The refactored endpoints are now properly documented in the OpenAPI schema with:

- Correct HTTP methods
- Better tag organization:
  - `Scanner - Resources`
  - `Scanner - Rules`
  - `Scanner - Findings`
  - `Scanner - Operations`
- Detailed parameter descriptions
- Proper response schemas

Access the interactive documentation at:
- **Swagger UI**: `http://localhost:8000/api/docs/`
- **ReDoc**: `http://localhost:8000/api/redoc/`

---

## Backward Compatibility Notes

The old endpoints have been **removed** in this refactor. If you need a transition period:

1. **Option 1**: Deploy new endpoints on a different URL prefix (e.g., `/api/v2/`)
2. **Option 2**: Create proxy endpoints that redirect old calls to new endpoints
3. **Option 3**: Update all clients before deploying this change

**Recommended approach**: Update all clients to use the new RESTful endpoints for better long-term maintainability.

---

## Technical Details

### ViewSet Changes

**Before:**
```python
class ResourceViewSet(viewsets.ViewSet):
    @action(detail=False, methods=['post'])
    def upload(self, request):
        # ...
```

**After:**
```python
class ResourceViewSet(mixins.CreateModelMixin,
                      mixins.RetrieveModelMixin,
                      mixins.DestroyModelMixin,
                      mixins.ListModelMixin,
                      viewsets.GenericViewSet):

    def list(self, request):
        # Standard list endpoint

    def create(self, request):
        # Standard create endpoint

    def retrieve(self, request, pk=None):
        # Standard retrieve endpoint

    def destroy(self, request, pk=None):
        # Standard destroy endpoint

    @action(detail=False, methods=['post'])
    def bulk_upload(self, request):
        # Custom bulk upload endpoint
```

### Key Improvements

1. **Mixins**: Use proper DRF mixins for automatic CRUD implementation
2. **HTTP Methods**: Correct method usage (GET for read operations)
3. **Error Handling**: Proper 404, 400 status codes with meaningful error messages
4. **ID Validation**: BSON ObjectId validation with proper error responses
5. **Documentation**: Enhanced OpenAPI schema with parameters and responses

---

## Support

For questions or issues related to this migration:
1. Check the OpenAPI documentation at `/api/docs/`
2. Review this migration guide
3. Contact the backend team

---

## Version History

- **v2.0.0** (Nov 21, 2025): DRF-compliant refactor with standard CRUD endpoints
- **v1.0.0** (Previous): Original implementation with custom action-based endpoints

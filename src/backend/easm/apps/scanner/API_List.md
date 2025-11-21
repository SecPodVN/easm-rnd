API Endpoints Overview
General Setup
Database: Uses MongoDB (pymongo) with configuration root environment variables.
Blueprints: Supports modular blueprints (e.g., users_bp from users.py).
Serialization: Should be JSON, not sure how
API Endpoints
1. Health Check
Endpoint: GET /healthStatus
Description: Returns a simple health check message to verify the service is running.

2. Resource Upload
Endpoint: POST /uploadResources
Request:

JSON
{
  "resources": [ { resource_object }, ... ]
}
Description: Bulk inserts an array of resource objects into the resources MongoDB collection.

3. List Resources
Endpoint: POST /listResources
Request:

JSON
{
  "filter": { ... },        // MongoDB filter (optional)
  "page_number": 1,         // Pagination (default 1)
  "page_size": 10,          // Page size (default 10)
  "sort_by": "name",        // Sorting field (default "name")
  "sort_order": "asc",      // Sorting order (asc/desc)
  "search_str": "abc"       // Name search (optional)
}
Description: Returns a paginated list of resources matching the filter, with search and sort capabilities.

4. Rule Upload
Endpoint: POST /uploadRules
Request:

JSON
{
  "rules": [ { rule_object }, ... ]
}
Description: Bulk inserts an array of rule objects into the rules collection.

5. List Findings
Endpoint: GET /findings
Description: Returns all findings from the findings collection. Each finding typically represents a detected issue or alert from resource scanning.

6. Resource Scanning
Endpoint: GET /scanResources
Description:

Fetches all resources and rules.
For each resource, evaluates all rules using a simple logic engine (field, op, value).
If a rule matches, creates a finding (issue) and stores it in the findings collection.
Supported operations: "eq" (equals), "gt" (greater-than).
7. Severity Summary
Endpoint: GET /getSeverityStatus
Description: Aggregates findings by severity (CRITICAL, HIGH, MEDIUM, LOW, INFO). Handles missing/empty severity values gracefully.

8. Delete Resources
Endpoint: POST /deleteResources
Request:

JSON
{
  "filter": { ... } // MongoDB filter
}
Description: Deletes resources matching the specified filter.

9. Delete Rules
Endpoint: POST /deleteRules
Request:

JSON
{
  "filter": { ... } // MongoDB filter
}
Description: Deletes rules matching the specified filter.

10. Issues by Resource Type
Endpoint: GET /getIssuesBasedOnResourceTypes
Description: Aggregates the findings collection, grouping by resource_type.

11. Issues by Region
Endpoint: GET /getIssuesBasedOnRegions
Description:

Joins findings with resources to get region information for each affected resource.
Aggregates findings by region.
Additional Endpoints
Basic Hello World:
GET / — returns static HTML.
GET /hello — returns simple text.
POST /greet — returns a greeting message for a supplied name.
Technical Notes for Migration
Data Model: All persistence is in MongoDB; collections are resources, rules, and findings.
Filtering: Most endpoints accept flexible MongoDB-style JSON filters.
Aggregation: MongoDB aggregation pipeline is used for summary endpoints.
Pagination: Implemented via .skip() and .limit() in resource listing.
Bulk Operations: Uses insert_many and delete_many for bulk data operations.
Serialization: Uses bson.json_util for MongoDB document serialization.
Blueprint Support: Application is modular and can register additional blueprints (e.g. users).
Migration Considerations
Database: Ensure MongoDB connection and collections are migrated.
Endpoints: All RESTful endpoints should be mapped with equivalent logic.
Aggregation: Replicate aggregation pipelines in the target platform.
Bulk Insert/Delete: Ensure bulk operations are supported.
Pagination, Sorting, Filtering: Replicate client query capabilities.
Blueprints: Maintain modularity for user management or other future expansion.

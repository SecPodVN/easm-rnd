# Asset Discovery App

**Domain**: External Attack Surface Management (EASM) - Asset Discovery Module

This Django app handles the core asset discovery functionality for the EASM platform, including seed management, asset enumeration, service detection, certificate tracking, and evidence collection.

---

## 📁 Folder Structure

**Domain App** (`apps/asset_discovery/`) - Business Logic Only:

```
asset_discovery/
├── __init__.py
├── apps.py                     # Django app configuration
├── models.py                   # ⭐ Core models (Seed, Asset, Service, Certificate, etc.)
│
├── migrations/                 # Database migrations
│   └── __init__.py
│
├── services/                   # 🎯 Business Logic Layer
│   ├── __init__.py
│   ├── discovery.py            # Main discovery orchestration
│   ├── asset_manager.py        # Asset CRUD and lifecycle management
│   └── lineage_tracker.py      # Track asset discovery lineage (seed → asset)
│
├── tasks/                      # ⚙️ Celery Background Tasks
│   ├── __init__.py
│   ├── discovery_tasks.py      # Async discovery tasks
│   └── scan_tasks.py           # Scan scheduling and execution tasks
│
├── engines/                    # 🔧 Discovery Engines (External Tools Integration)
│   ├── __init__.py
│   ├── base.py                 # Base engine class/interface
│   ├── subfinder.py            # Subfinder integration
│   ├── amass.py                # Amass integration
│   └── dns_resolver.py         # DNS resolution engine
│
├── utils/                      # 🛠️ Utilities and Helpers
│   ├── __init__.py
│   ├── validators.py           # Input validation (domain, IP, CIDR)
│   └── helpers.py              # Helper functions
│
└── management/                 # 🎮 Django Management Commands
    ├── __init__.py
    └── commands/
        └── __init__.py
        # Example commands (to be created):
        # - seed_data.py          # Seed initial discovery targets
        # - run_discovery.py      # Manual discovery trigger
        # - import_assets.py      # Import assets from external sources
```

**API Layer** (`apps/api/asset_discovery/`) - Presentation Only:

```
apps/api/asset_discovery/
├── __init__.py
├── views.py                    # ViewSets for REST API endpoints
└── serializers.py              # DRF Serializers for models
```

**Shared API Components** (`apps/api/core/`) - Used by all API endpoints:

```
apps/api/
├── urls.py                     # ⭐ Central API routing (ONLY ONE)
├── views.py                    # Root API views
└── core/                       # Shared API utilities
    ├── __init__.py
    ├── filters.py              # Shared filter classes
    ├── permissions.py          # Shared permission classes
    ├── pagination.py           # Shared pagination classes
    └── serializers.py          # Base serializer classes
```

---

## 📊 Models Overview

Based on the database diagram, this app will contain:

### Core Inventory Models

- **Seed**: Initial discovery targets (domains, IPs, CIDRs)
- **Asset**: Discovered assets (domains, hosts, IPs)
- **Service**: Services running on assets (ports, protocols)
- **PortCatalog**: Reference data for well-known ports
- **Certificate**: TLS/SSL certificates (M:N with services)

### Evidence & Lineage Models

- **AssetLineage**: Track discovery path (seed → asset)
- **Evidence**: Store discovery evidence (screenshots, headers, etc.)
- **DNSObservation**: DNS query results
- **WhoisObservation**: WHOIS lookup results

### Scheduling Models

- **ScanTask**: Discovery/scan task queue
- **ScanEvent**: Audit log of discovery events

---

## 🎯 Responsibilities

### Models Layer (`models.py`)

- Define database schema
- Model relationships (FK, M2M)
- Model methods (e.g., `asset.get_active_services()`)
- Indexes and constraints

### Services Layer (`services/`)

**Purpose**: Business logic and orchestration

- `discovery.py`: Main discovery workflow orchestration
- `asset_manager.py`: Asset lifecycle management (create, update, archive)
- `lineage_tracker.py`: Track and record asset discovery paths

**Example**:

```python
# services/discovery.py
class DiscoveryService:
    def discover_from_seed(self, seed_id):
        # 1. Get seed
        # 2. Run discovery engines
        # 3. Process results
        # 4. Create assets
        # 5. Track lineage
        pass
```

### Tasks Layer (`tasks/`)

**Purpose**: Asynchronous background tasks (Celery)

- `discovery_tasks.py`: Run discovery engines asynchronously
- `scan_tasks.py`: Schedule and execute scans

**Example**:

```python
# tasks/discovery_tasks.py
@shared_task
def run_subdomain_discovery(seed_id):
    # Run subfinder, amass, etc.
    pass
```

### Engines Layer (`engines/`)

**Purpose**: External tool integrations

- `base.py`: Base engine interface
- `subfinder.py`: Subfinder wrapper
- `amass.py`: Amass wrapper
- `dns_resolver.py`: DNS resolution

**Example**:

```python
# engines/base.py
class BaseDiscoveryEngine(ABC):
    @abstractmethod
    def run(self, target: str) -> List[str]:
        pass

# engines/subfinder.py
class SubfinderEngine(BaseDiscoveryEngine):
    def run(self, target: str) -> List[str]:
        # Execute subfinder command
        # Parse results
        return discovered_subdomains
```

### Utils Layer (`utils/`)

**Purpose**: Reusable utilities

- `validators.py`: Input validation (domain format, IP validation, CIDR parsing)
- `helpers.py`: Common helper functions (domain parsing, IP manipulation)

---

## 🔄 Data Flow

```
┌──────────┐
│   Seed   │ (User adds domain/IP)
└────┬─────┘
     │
     ▼
┌────────────────┐
│ Discovery Task │ (Celery task triggered)
└────┬───────────┘
     │
     ▼
┌──────────────────┐
│ Discovery Service│ (Orchestration)
└────┬─────────────┘
     │
     ├──► Subfinder Engine ──┐
     ├──► Amass Engine ──────┤
     └──► DNS Resolver ───────┤
                              ▼
                    ┌───────────────────┐
                    │ Process Results   │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ Create Assets     │
                    │ + Services        │
                    │ + Lineage         │
                    └───────────────────┘
```

---

## 🌐 API Layer

API endpoints are defined in `apps/api/asset_discovery/` (presentation layer only):

```
apps/api/asset_discovery/
├── __init__.py
├── views.py            # ViewSets (SeedViewSet, AssetViewSet, ServiceViewSet)
└── serializers.py      # DRF Serializers
```

**Shared API utilities** used by all endpoints are in `apps/api/core/`:
- `apps/api/core/filters.py` - Shared filter classes (reuse across all APIs)
- `apps/api/core/permissions.py` - Shared permission classes
- `apps/api/core/pagination.py` - Shared pagination classes
- `apps/api/core/serializers.py` - Base serializer classes
- `apps/api/urls.py` - Central routing (register all ViewSets here - ONLY ONE)

**Example Endpoints**:

- `GET  /api/seeds/` - List seeds
- `POST /api/seeds/` - Create seed
- `GET  /api/assets/` - List assets (with filters: type, provider, labels)
- `GET  /api/services/` - List services
- `POST /api/discovery/run/` - Trigger discovery

**Example Filter Usage** (in `views.py`):

```python
from rest_framework import viewsets
from django_filters.rest_framework import DjangoFilterBackend
from apps.api.core.filters import BaseFilter  # Shared from core
from apps.api.core.permissions import IsOrgMember  # Shared from core
from apps.asset_discovery.models import Asset
from .serializers import AssetSerializer

class AssetViewSet(viewsets.ModelViewSet):
    queryset = Asset.objects.all()
    serializer_class = AssetSerializer
    permission_classes = [IsOrgMember]  # Reuse shared permission from core
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['type', 'provider', 'org_id']
```

---

## 🧪 Testing Structure

Comprehensive tests should be in a separate `tests/` directory:

```
tests/
├── __init__.py
├── unit/
│   ├── test_models.py
│   ├── test_services.py
│   ├── test_engines.py
│   └── test_validators.py
├── integration/
│   ├── test_discovery_flow.py
│   └── test_api.py
└── fixtures/
    ├── seeds.json
    └── assets.json
```

---

## 🚀 Getting Started

### 1. Configure the App

**Edit `apps/asset_discovery/apps.py`**:

```python
from django.apps import AppConfig

class AssetDiscoveryConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'easm.apps.asset_discovery'
    verbose_name = 'Asset Discovery'
```

**Register in `config/settings.py`**:

```python
INSTALLED_APPS = [
    # ...
    'easm.apps.asset_discovery.apps.AssetDiscoveryConfig',
]
```

### 2. Create Models

Edit `models.py` to define:

- Seed
- Asset
- Service
- Certificate
- etc.

### 3. Create & Run Migrations

```bash
cd src/backend/easm
poetry run python manage.py makemigrations asset_discovery
poetry run python manage.py migrate
```

### 4. Implement Services

Create business logic in `services/`:

- `discovery.py` - Main orchestration
- `asset_manager.py` - Asset management

### 5. Implement Engines

Create tool integrations in `engines/`:

- `subfinder.py`
- `amass.py`
- `dns_resolver.py`

### 6. Create API Endpoints

Edit `apps/api/asset_discovery/`:

- `serializers.py` - Define serializers
- `views.py` - Create ViewSets
- Register routes in `apps/api/urls.py`

### 7. Add Tests

Create comprehensive tests in `tests/`:

- Unit tests for models, services, engines
- Integration tests for API and workflows

---

## 📝 Key Design Principles

1. **Separation of Concerns**

   - Models = Data structure
   - Services = Business logic
   - Tasks = Async execution
   - Engines = External integrations
   - API = Presentation layer

2. **Multi-tenancy**

   - All models have `org_id` foreign key
   - All queries filtered by organization

3. **Lineage Tracking**

   - Every asset records its discovery path
   - Evidence stored for audit trail

4. **Change Detection**

   - `is_new` and `is_changed` flags
   - `first_seen` and `last_seen` timestamps

5. **Confidence Scoring**
   - Assets have confidence levels (0.0 to 1.0)
   - Helps prioritize and filter results

---

## 🔗 Related Apps

- `apps/api/` - API layer (presentation)
- `apps/risk_assessment/` - Risk scoring (consumer of asset data)
- `apps/reporting/` - Report generation (consumer of asset data)

---

## 📚 References

- Database Diagram: `docs/confluence/DATABASE-DIAGRAM.md`
- Architecture: `docs/confluence/ARCHITECTURE-OVERVIEW.md`
- API Development Guide: `docs/confluence/BACKEND-API-DEVELOPMENT-GUIDE.md`

---

**Created**: November 25, 2025
**Status**: Initial structure setup ✅
**Next Steps**: Implement models based on database diagram

# EASM Frontend Applications

This directory contains the frontend applications for the EASM platform.

## Architecture Overview

The frontend is organized into multiple applications, each serving a specific purpose:

### 📱 Applications

#### **easm-web-portal** (Main User Portal)
The primary user-facing application for External Attack Surface Management.

**Features:**
- Asset Discovery & Inventory
- Vulnerability Management
- Security & Risk Dashboard
- Job Management
- Reports & Compliance
- Settings & Configuration

**Status:** ✅ Active Development

---

#### **easm-web-admin** (Administrative Portal)
Administrative interface for platform management and configuration.

**Features:** (Planned)
- User Management
- System Configuration
- Platform Monitoring
- Access Control & RBAC
- Audit Logs
- License Management

**Status:** 🚧 Under Development

---

#### **easm-react** (Shared UI Library)
Shared component library and utilities used across all EASM applications.

**Contents:**
- Reusable UI Components
- Common Utilities
- Custom React Hooks
- TypeScript Type Definitions

**Status:** ✅ Active

---

## Directory Structure

```
frontend/
├── easm-web-portal/      # Main user portal
│   ├── src/
│   │   ├── features/     # Feature modules
│   │   ├── shared/       # Portal-specific shared code
│   │   └── components/   # Portal components
│   └── package.json
│
├── easm-web-admin/       # Admin portal
│   ├── src/
│   │   ├── features/     # Admin features
│   │   └── shared/       # Admin-specific shared code
│   └── package.json
│
└── easm-react/           # Shared UI library
    ├── src/
    │   ├── components/   # Shared components
    │   ├── utils/        # Utilities
    │   ├── hooks/        # Custom hooks
    │   └── types/        # Type definitions
    └── package.json
```

## Development Workflow

### Working on easm-web-portal

```bash
cd easm-web-portal
pnpm install
pnpm start
```

### Working on easm-web-admin

```bash
cd easm-web-admin
pnpm install
pnpm start
```

### Working on easm-react

```bash
cd easm-react
pnpm install
pnpm run dev  # Watch mode for development
```

## Shared Components Strategy

### App-Specific Shared Components
Each application (easm-web-portal, easm-web-admin) has its own `shared/` directory for components that are:
- Specific to that application's domain
- Used across multiple features within that app
- Not needed by other EASM applications

Example:
- `easm-web-portal/src/shared/components/` - Components specific to portal features
- `easm-web-admin/src/shared/components/` - Components specific to admin features

### Cross-Application Shared Components
Components used by multiple applications should be placed in `easm-react`:
- Generic UI components (buttons, cards, modals)
- Common utilities and helpers
- Shared custom hooks
- Type definitions

### When to Use Which?

**Use app-specific `shared/`:**
- Component is only used within one application
- Component has application-specific logic or styling
- Component relates to a specific domain concept

**Use `easm-react`:**
- Component is or could be used by multiple applications
- Component is purely presentational
- Utility function has no application-specific dependencies
- Type definition is used across applications

## Package Management

Each application manages its own dependencies independently:

- `easm-web-portal/package.json` - Portal dependencies
- `easm-web-admin/package.json` - Admin dependencies
- `easm-react/package.json` - Shared library dependencies

Applications can reference `easm-react` using:

```json
{
  "dependencies": {
    "@easm/ui-core": "file:../EASM-ui-core"
  }
}
```

## Building for Production

### Build All Applications

```bash
# From frontend directory
cd EASM-ui-core && pnpm run build && cd ..
cd EASM-portal && pnpm run build && cd ..
cd EASM-admin && pnpm run build && cd ..
```

### Build Individual Applications

```bash
# Portal only
cd EASM-portal && pnpm run build

# Admin only
cd EASM-admin && pnpm run build
```

## Tech Stack

All applications share the same core technology stack:

- **React** 18.3+ - UI library
- **TypeScript** 5.6+ - Type-safe JavaScript
- **Material-UI** 5.15+ - Component library
- **React Router** 6.26+ - Client-side routing

## Contributing

When adding new features:

1. Determine which application the feature belongs to
2. Create feature modules in the appropriate app's `features/` directory
3. Place app-specific shared code in the app's `shared/` directory
4. Place truly shared code in `EASM-ui-core`
5. Update documentation accordingly

## Questions?

See the README.md in each application directory for more specific information:
- [EASM-portal README](./EASM-portal/README.md)
- [EASM-admin README](./EASM-admin/README.md)
- [EASM-ui-core README](./EASM-ui-core/README.md)

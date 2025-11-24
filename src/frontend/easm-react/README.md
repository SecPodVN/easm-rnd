# EASM UI Core

Shared UI components, utilities, hooks, and types for EASM applications.

## Structure

```
EASM-ui-core/
├── src/
│   ├── components/      # Shared UI components
│   ├── utils/          # Utility functions
│   ├── hooks/          # Custom React hooks
│   ├── types/          # TypeScript type definitions
│   └── index.ts        # Main export file
├── package.json
├── tsconfig.json
└── README.md
```

## Usage

This package is used by EASM-portal, EASM-admin, and other EASM applications to share common components and utilities.

### In EASM-portal or EASM-admin

```typescript
import { SomeSharedComponent } from '@easm/ui-core';
```

## Development

```bash
# Install dependencies
npm install

# Build the package
npm run build

# Watch for changes
npm run dev
```

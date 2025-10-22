# Project Setup & Container Restart Instructions

## Restart All Containers and Reinitialize Database

To restart all services and ensure a fresh database initialization:

1. Stop and remove all running containers:
   ```cmd
   docker-compose down
   ```
2. Remove the old PostgreSQL data volume (if present):
   ```cmd
   docker volume rm easm-rnd_postgres_data
   ```
   If unsure of the volume name, run:
   ```cmd
   docker volume ls
   ```
3. Start all containers with the updated configuration:
   ```cmd
   docker-compose up -d
   ```

## Verification
- Connect to the PostgreSQL container and list databases to confirm `easm_user` exists:
  ```cmd
  docker exec -it easm-postgres psql -U easm_user
  ```
  Then, inside psql:
  ```sql
  \l
  ```

---

## Automated Database Initialization for PostgreSQL

- Added `init-easm-user.sql` in `src/backend/` to create the `easm_user` database automatically.
- Updated `docker-compose.yml` to mount the SQL script into the PostgreSQL container:
  - `./src/backend/init-easm-user.sql:/docker-entrypoint-initdb.d/init-easm-user.sql`
- On first container startup (with a fresh volume), the database is created automatically.
- To re-run initialization, remove the old data volume and restart the container.

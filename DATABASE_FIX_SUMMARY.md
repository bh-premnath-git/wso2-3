# WSO2 Identity Server 7.1.0 Database Schema Fix

## Problem Description

The WSO2 Identity Server 7.1.0 was failing to start with the following database errors:

1. **Missing Table**: `Table 'WSO2AM_DB.API_RESOURCE' doesn't exist`
2. **Missing Column**: `Unknown column 'DEFINED_BY' in 'field list'`

These errors occurred because the database schema was incomplete for WSO2 IS 7.1.0 requirements.

## Root Cause

The `mysql_apim.sql` initialization script was missing:

### Missing Tables:
- `API_RESOURCE` - Required for API resource management
- `SCOPE` - Required for scope management
- `API_RESOURCE_PROPERTY` - Required for API resource properties

### Missing Columns in IDP_AUTHENTICATOR:
- `IMAGE_URL VARCHAR(1024)`
- `DESCRIPTION VARCHAR(1024)`
- `DEFINED_BY VARCHAR(25) NOT NULL`
- `AUTHENTICATION_TYPE VARCHAR(25) NOT NULL`

## Solution Applied

### 1. Updated Database Schema (`conf/mysql/scripts/mysql_apim.sql`)

- **Commented out** the old `IDP_AUTHENTICATOR` table definition (lines 601-611)
- **Appended** at end of file:
  - Updated `IDP_AUTHENTICATOR` table with all required columns
  - Added `API_RESOURCE` table
  - Added `SCOPE` table
  - Added `API_RESOURCE_PROPERTY` table
  - Recreated dependent tables (`IDP_AUTHENTICATOR_PROPERTY`, `SP_FEDERATED_IDP`)

### 2. Created Migration Script (`conf/mysql/migration_is_7.1.0.sql`)

A standalone migration script is available for existing databases that need to be updated without recreation.

**Important:** This script is stored in `conf/mysql/` (NOT in `scripts/`) to prevent it from auto-running during fresh database initialization. It's only meant for manual migration of existing databases.

## How to Apply

### For New Deployments:
```bash
# The database will be initialized correctly on first startup
docker-compose up --build
```

### For Existing Deployments:
```bash
# Option 1: Recreate the database (DATA LOSS!)
docker-compose down -v
docker-compose up --build

# Option 2: Apply migration script to existing database
docker exec -i <mysql-container> mysql -uroot -proot WSO2AM_DB < conf/mysql/migration_is_7.1.0.sql
```

## Files Modified

1. `/conf/mysql/scripts/mysql_apim.sql` - Updated with WSO2 IS 7.1.0 required tables
2. `/conf/mysql/scripts/mysql_apim.sql.backup` - Backup of original file
3. `/conf/mysql/migration_is_7.1.0.sql` - Migration script for existing databases (stored outside scripts/ to prevent auto-execution)

## Verification

After applying the fix, the following should work:
- WSO2 Identity Server 7.1.0 should start without database errors
- API resource management features will function correctly
- Identity Provider authenticator configurations will work properly

## References

- WSO2 IS 7.1.0 Official Database Scripts: https://github.com/wso2/carbon-identity-framework/blob/master/features/identity-core/org.wso2.carbon.identity.core.server.feature/resources/dbscripts/mysql.sql
- Error logs showing missing `API_RESOURCE` table and `DEFINED_BY` column

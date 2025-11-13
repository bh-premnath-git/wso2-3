-- Create databases for WSO2 IS 7.1.0 and APIM 4.6.0
-- WSO2_SHARED_DB: Shared registry and user management database
-- WSO2AM_DB: Combined identity and APIM database

CREATE DATABASE IF NOT EXISTS WSO2AM_SHARED_DB;
CREATE DATABASE IF NOT EXISTS WSO2AM_DB;

-- Create database user
CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';

-- Grant permissions
GRANT ALL PRIVILEGES ON WSO2AM_SHARED_DB.* TO 'wso2carbon'@'%';
GRANT ALL PRIVILEGES ON WSO2AM_DB.* TO 'wso2carbon'@'%';

FLUSH PRIVILEGES;

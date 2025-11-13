#!/bin/bash

echo "========================================"
echo "WSO2 APIM + IS 7.0 Restart & Verification"
echo "========================================"
echo ""

# Step 1: Stop containers
echo "[1/5] Stopping containers..."
docker-compose down
echo "✓ Containers stopped"
echo ""

# Step 2: Optional - Clear volumes (WARNING: loses data)
read -p "Clear volumes? This will delete all data (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[2/5] Clearing volumes..."
    docker volume prune -f
    echo "✓ Volumes cleared"
else
    echo "[2/5] Skipping volume clear"
fi
echo ""

# Step 3: Start MySQL and wait
echo "[3/5] Starting MySQL..."
docker-compose up -d mysql
echo "Waiting for MySQL to be healthy (30s)..."
sleep 30
echo "✓ MySQL started"
echo ""

# Step 4: Start IS-AS-KM and wait
echo "[4/5] Starting Identity Server as Key Manager..."
docker-compose up -d is-as-km
echo "Waiting for IS-AS-KM bootstrap (60s)..."
sleep 60
echo "✓ IS-AS-KM started"
echo ""

# Step 5: Start API Manager
echo "[5/5] Starting API Manager..."
docker-compose up -d api-manager
echo "Waiting for API Manager startup (30s)..."
sleep 30
echo "✓ API Manager started"
echo ""

# Verification
echo "========================================"
echo "VERIFICATION CHECKS"
echo "========================================"
echo ""

# Check IS login page
echo "[Check 1] IS-AS-KM Login Page..."
IS_LOGIN=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:9444/carbon/admin/login.jsp)
if [ "$IS_LOGIN" = "200" ]; then
    echo "✓ IS-AS-KM login page accessible (HTTP $IS_LOGIN)"
else
    echo "✗ IS-AS-KM login page not accessible (HTTP $IS_LOGIN)"
fi
echo ""

# Check IS to APIM connectivity
echo "[Check 2] IS-AS-KM to API Manager connectivity..."
docker exec apim-is-as-km-with-analytics-is-as-km-1 curl -k -s -o /dev/null -w "%{http_code}" https://api-manager:9443/carbon/admin/login.jsp > /tmp/is_to_apim_check 2>&1
IS_TO_APIM=$(cat /tmp/is_to_apim_check)
if [ "$IS_TO_APIM" = "200" ]; then
    echo "✓ IS can reach API Manager (HTTP $IS_TO_APIM)"
else
    echo "✗ IS cannot reach API Manager (HTTP $IS_TO_APIM)"
fi
rm -f /tmp/is_to_apim_check
echo ""

# Check APIM to IS connectivity
echo "[Check 3] API Manager to IS-AS-KM connectivity..."
docker exec apim-is-as-km-with-analytics-api-manager-1 curl -k -s -o /dev/null -w "%{http_code}" https://is-as-km:9443/carbon/admin/login.jsp > /tmp/apim_to_is_check 2>&1
APIM_TO_IS=$(cat /tmp/apim_to_is_check)
if [ "$APIM_TO_IS" = "200" ]; then
    echo "✓ API Manager can reach IS (HTTP $APIM_TO_IS)"
else
    echo "✗ API Manager cannot reach IS (HTTP $APIM_TO_IS)"
fi
rm -f /tmp/apim_to_is_check
echo ""

# Check for errors in IS logs
echo "[Check 4] IS-AS-KM error count..."
IS_ERRORS=$(docker logs apim-is-as-km-with-analytics-is-as-km-1 2>&1 | grep -c ERROR)
if [ "$IS_ERRORS" -eq 0 ]; then
    echo "✓ No ERROR logs in IS-AS-KM"
else
    echo "⚠ Found $IS_ERRORS ERROR entries in IS-AS-KM logs"
fi
echo ""

# Check for JMS errors in APIM logs
echo "[Check 5] API Manager JMS error check..."
APIM_JMS_ERRORS=$(docker logs apim-is-as-km-with-analytics-api-manager-1 2>&1 | grep -c "JMS Provider")
if [ "$APIM_JMS_ERRORS" -eq 0 ]; then
    echo "✓ No JMS Provider errors in API Manager"
else
    echo "⚠ Found $APIM_JMS_ERRORS JMS Provider errors in API Manager"
fi
echo ""

# Check for password policy errors
echo "[Check 6] Password policy error check..."
PASSWORD_ERRORS=$(docker logs apim-is-as-km-with-analytics-is-as-km-1 2>&1 | grep -i "password" | grep -c ERROR)
if [ "$PASSWORD_ERRORS" -eq 0 ]; then
    echo "✓ No password policy errors"
else
    echo "⚠ Found $PASSWORD_ERRORS password-related errors"
fi
echo ""

echo "========================================"
echo "SUMMARY"
echo "========================================"
echo ""
echo "Access URLs:"
echo "  - IS-AS-KM:     https://localhost:9444/carbon"
echo "  - API Manager:  https://localhost:9443/carbon"
echo "  - APIM Publisher: https://localhost:9443/publisher"
echo "  - APIM DevPortal: https://localhost:9443/devportal"
echo ""
echo "Credentials:"
echo "  Username: admin"
echo "  Password: Admin@12345"
echo ""
echo "To monitor logs:"
echo "  docker logs -f apim-is-as-km-with-analytics-is-as-km-1"
echo "  docker logs -f apim-is-as-km-with-analytics-api-manager-1"
echo ""

#!/bin/bash
# ─── Admin Routes API Test Script ──────────────────────────────────────────────
# Tests all XploreApp / clubsetu Admin API endpoints using curl

API_URL="${API_URL:-https://clubsetu-backend.onrender.com/api}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@college.edu}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin123}"

echo "=========================================================================="
echo "🚀 Testing Admin API Routes on: $API_URL"
echo "=========================================================================="

# 1. Login to get JWT Token
echo -e "\n1. 🔑 Authenticating Admin ($ADMIN_EMAIL)..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/admin/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}")

# Extract Token using grep/sed
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "⚠️ /admin/login did not return a token. Trying /auth/login/admin..."
  LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login/admin" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}")
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed! Response:"
  echo "$LOGIN_RESPONSE"
  echo "Please set ADMIN_EMAIL and ADMIN_PASSWORD environment variables and retry."
  exit 1
fi

echo "✅ Auth successful! JWT Token acquired."

HEADER="Authorization: Bearer $TOKEN"

# 2. Test GET /admin/dashboard-stats
echo -e "\n2. 📊 Testing GET /admin/dashboard-stats..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/admin/dashboard-stats" | head -n 30

# 3. Test GET /admin/event-data-export
echo -e "\n3. 📅 Testing GET /admin/event-data-export..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/admin/event-data-export" | head -n 30

# 4. Test GET /admin/clubs-list
echo -e "\n4. 🏛️ Testing GET /admin/clubs-list..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/admin/clubs-list" | head -n 30

# 5. Test GET /admin/coordinators
echo -e "\n5. 🎓 Testing GET /admin/coordinators..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/admin/coordinators" | head -n 30

# 6. Test GET /admin/manual-payments
echo -e "\n6. 💳 Testing GET /admin/manual-payments..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/admin/manual-payments" | head -n 30

# 7. Test GET /venues
echo -e "\n7. 📍 Testing GET /venues..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/venues" | head -n 30

# 8. Test GET /notifications/sent
echo -e "\n8. 📢 Testing GET /notifications/sent..."
curl -s -w "\nHTTP Status: %{http_code}\n" -H "$HEADER" "$API_URL/notifications/sent" | head -n 30

echo -e "\n=========================================================================="
echo "✅ Admin API test execution complete!"
echo "=========================================================================="

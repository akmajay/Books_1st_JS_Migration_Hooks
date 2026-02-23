#!/bin/bash
sqlite3 /opt/pocketbase/pb_data/data.db "UPDATE _collections SET oauth2 = '{\"enabled\":true,\"providers\":[{\"name\":\"google\",\"clientId\":\"YOUR_CLIENT_ID\",\"clientSecret\":\"YOUR_CLIENT_SECRET\",\"displayName\":\"Google\",\"authUrl\":\"https://accounts.google.com/o/oauth2/auth\",\"tokenUrl\":\"https://accounts.google.com/o/oauth2/token\"}]}' WHERE name='users';"
echo "Database update complete."

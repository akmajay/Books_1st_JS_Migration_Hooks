#!/bin/bash
sqlite3 /opt/pocketbase/pb_data/data.db "SELECT oauth2 FROM _collections WHERE name='users';"

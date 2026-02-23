# Agent Context
> New chat? Read this first. Contains things you CAN'T know without being told.

## Credentials
| Key | Value |
|-----|-------|
| VPS IP | `65.2.186.236` |
| SSH User | `ubuntu` |
| Domain | `api.jayganga.com` |
| PB URL | `https://api.jayganga.com` |
| PB Admin | `https://api.jayganga.com/_/` |
| Superuser | `life.jay.com@gmail.com` |
| Password | `Akhilesh@2026` |

## Paths
| Location | Path |
|----------|------|
| Local project | `C:\Users\aijay\Desktop\JayGanga Books` |
| VPS PocketBase | `/opt/pocketbase/` |
| VPS migrations | `/opt/pocketbase/pb_migrations/` |
| VPS hooks | `/opt/pocketbase/pb_hooks/` |
| VPS service | `/etc/systemd/system/pocketbase.service` |
| SSH command | `ssh -i "JayGanga Books (1).pem" ubuntu@65.2.186.236` |

## API Keys & Identifiers
| Service | Key / Value |
|---------|-----|
| Firebase Project ID | `jayganga-books` |
| Firebase Project # | `1091198645080` |
| Android App ID | `1:1091198645080:android:29111d16133bbe13366b2d` |
| Web App ID | `1:1091198645080:web:c4e9c4a30f8be115366b2d` |
| Storage Bucket | `jayganga-books.firebasestorage.app` |
| Measurement ID | `G-Y7FQPVDQM9` |
| Android API Key | `AIzaSyBVq48LVgub8lthTP7OJDq9OE72PIajG3g` |
| Web API Key | `AIzaSyCymUMqYn-iKk0y11TozlGEwGKeM3jHKbI` |
| Package Name | `com.jayganga.books` |

## Verify Backend (Inspector)
```bash
# Get Admin Token (for testing)
curl -X POST https://api.jayganga.com/api/collections/_superusers/auth-with-password -H "Content-Type: application/json" -d '{"identity":"life.jay.com@gmail.com","password":"Akhilesh@2026"}'
# Collections exist?
curl -s https://api.jayganga.com/api/collections -H "Authorization: Bearer ADMIN_TOKEN"
curl -s -o /dev/null -w '%{http_code}' https://api.jayganga.com/api/collections/{name}/records
ssh -i "JayGanga Books (1).pem" ubuntu@65.2.186.236 journalctl -u pocketbase -n 20 | grep hook
```

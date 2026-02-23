$pbUrl = "https://api.jayganga.com"
$email = "life.jay.com@gmail.com"
$password = "Akhilesh@2026"

$loginUrl = "$pbUrl/api/collections/_superusers/auth-with-password"
$loginBody = @{
    identity = $email
    password = $password
}
$resp = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody
$headers = @{ Authorization = $resp.token }

$users = Invoke-RestMethod -Uri "$pbUrl/api/collections/users" -Headers $headers
$users.fields | ConvertTo-Json -Depth 10

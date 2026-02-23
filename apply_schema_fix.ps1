$pbUrl = "https://api.jayganga.com"
$email = "life.jay.com@gmail.com"
$password = "Akhilesh@2026"

$loginUrl = "$pbUrl/api/collections/_superusers/auth-with-password"
$loginBody = @{
    identity = $email
    password = $password
}
$resp = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody
$headers = @{ 
    Authorization = $resp.token
}

# Get Users Collection
$users = Invoke-RestMethod -Uri "$pbUrl/api/collections/users" -Headers $headers

# Update Fields
foreach ($field in $users.fields) {
    if ($field.name -eq "phone") {
        $field.required = $false
        $field.min = 0
    }
    if ($field.name -eq "user_type") {
        $field.required = $false
    }
}

# Save Collection
$updateBody = $users | ConvertTo-Json -Depth 20
Invoke-RestMethod -Uri "$pbUrl/api/collections/users" -Method Patch -Headers $headers -Body $updateBody -ContentType "application/json"

Write-Output "Successfully made user fields optional."

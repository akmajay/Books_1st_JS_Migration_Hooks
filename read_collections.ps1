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

$books = Invoke-RestMethod -Uri "$pbUrl/api/collections/books" -Headers $headers
$chats = Invoke-RestMethod -Uri "$pbUrl/api/collections/chats" -Headers $headers

$results = @{
    books = $books.fields
    chats = $chats.fields
}

$results | ConvertTo-Json -Depth 10

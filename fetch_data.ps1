try {
    # Token with %3D replaced by = manually
    $BearerToken = "AAAAAAAAAAAAAAAAAAAAAEAP4QEAAAAAKsklfNm5aMffbQgo1SKuj4KZkGA=lJGKXxPB8Pf30B2fpOmpXqbIIyQMPB8r7xEStvZSFdX6NVJbZb"
    
    # Hardcoded URL - no variables
    $Url = "https://api.twitter.com/2/users/44196397/tweets?max_results=100&tweet.fields=created_at,public_metrics,referenced_tweets"
    
    Write-Host "Requesting: $Url" -ForegroundColor Cyan
    
    $Headers = @{
        "Authorization" = "Bearer $BearerToken"
    }

    # Ensure TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get
    
    if ($Response.data) {
        Write-Host "Success! Fetched $($Response.data.Count) tweets." -ForegroundColor Green
        $Response.data | ConvertTo-Json -Depth 10 | Set-Content "data.json" -Encoding UTF8
    } else {
        Write-Host "No data returned." -ForegroundColor Yellow
        Write-Host ($Response | ConvertTo-Json -Depth 5)
    }

} catch {
    Write-Error "Script Failed."
    Write-Host "Exception: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
         try {
            $Reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $Body = $Reader.ReadToEnd()
            Write-Host "Response Body: $Body" -ForegroundColor Red
         } catch {
            Write-Host "Could not read response body."
         }
    }
}

try {
    # Prefer Environment Variable (for GitHub Actions), fallback to hardcoded (for local dev)
    if ($env:BEARER_TOKEN) {
        $BearerToken = $env:BEARER_TOKEN
    } else {
        # Token with %3D replaced by = manually
        $BearerToken = "AAAAAAAAAAAAAAAAAAAAAEAP4QEAAAAAKsklfNm5aMffbQgo1SKuj4KZkGA=lJGKXxPB8Pf30B2fpOmpXqbIIyQMPB8r7xEStvZSFdX6NVJbZb"
    }
    
    # Hardcoded URL - no variables
    $Url = "https://api.twitter.com/2/users/44196397/tweets?max_results=100&tweet.fields=created_at,public_metrics,referenced_tweets&exclude=replies"
    
    Write-Host "Requesting: $Url" -ForegroundColor Cyan
    
    $Headers = @{
        "Authorization" = "Bearer $BearerToken"
    }

    # Ensure TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if ($Response.data) {
        $NewTweets = $Response.data
        Write-Host "Fetched $($NewTweets.Count) new tweets." -ForegroundColor Green

        $ExistingTweets = @()
        if (Test-Path "data.json") {
            try {
                $Content = Get-Content "data.json" -Raw -ErrorAction Stop
                if ($Content) {
                    $ExistingTweets = $Content | ConvertFrom-Json
                    Write-Host "Loaded $($ExistingTweets.Count) existing tweets from history." -ForegroundColor Gray
                }
            } catch {
                Write-Host "Could not load existing data.json, starting fresh." -ForegroundColor Yellow
            }
        }

        # Merge and Deduplicate
        # Create a hash table for quick lookup by ID to prevent duplicates
        $TweetMap = @{}
        
        # Add existing
        foreach ($t in $ExistingTweets) {
            $TweetMap[$t.id] = $t
        }
        
        # Add new (will overwrite existing if same ID, or add if new)
        foreach ($t in $NewTweets) {
            $TweetMap[$t.id] = $t
        }

        # Convert back to array
        $CombinedTweets = $TweetMap.Values | Sort-Object created_at -Descending

        Write-Host "Total Database Size: $($CombinedTweets.Count) tweets." -ForegroundColor Cyan
        
        $CombinedTweets | ConvertTo-Json -Depth 10 | Set-Content "data.json" -Encoding UTF8
    } else {
        Write-Host "No new data returned from API." -ForegroundColor Yellow
        # Don't overwrite if fetch failed
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

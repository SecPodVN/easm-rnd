function Cleanup-Test {
    Write-Host "Cleanup executed!" -ForegroundColor Green
    Remove-Item "test.txt" -ErrorAction SilentlyContinue
}

"Test file" | Set-Content "test.txt"
Write-Host "Created test.txt"
Write-Host "Press Ctrl+C in 5 seconds to test cleanup..."

try {
    Start-Sleep -Seconds 10
    Write-Host "Completed normally"
}
finally {
    Cleanup-Test
}

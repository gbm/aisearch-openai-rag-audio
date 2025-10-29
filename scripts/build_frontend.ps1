param()

$root = Resolve-Path -Path (Join-Path $PSScriptRoot "..")
Push-Location (Join-Path $root "app/frontend")
try {
    Write-Host "Restoring frontend npm packages"
    npm install
    if ($LASTEXITCODE -ne 0) {
        throw "npm install failed"
    }

    Write-Host "Building frontend"
    npm run build
    if ($LASTEXITCODE -ne 0) {
        throw "npm run build failed"
    }
}
finally {
    Pop-Location
}

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

Push-Location (Join-Path $root "app/backend")
try {
    Write-Host "Preparing backend Python packages"
    if (Test-Path ".python_packages") {
        Remove-Item ".python_packages" -Recurse -Force -ErrorAction SilentlyContinue
    }

    python -m pip install --target ".python_packages/lib/site-packages" -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        throw "python -m pip install failed"
    }
}
finally {
    Pop-Location
}

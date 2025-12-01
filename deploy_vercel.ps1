# Build Flutter Web
Write-Host "Building Flutter Web..."
flutter build web --release

# Remove .gitignore from build/web if it exists (to prevent Vercel from ignoring build files)
if (Test-Path "build/web/.gitignore") {
    Write-Host "Removing .gitignore from build/web..."
    Remove-Item "build/web/.gitignore" -Force
}

# Create vercel.json in build/web using Python (to ensure UTF-8 encoding)
# Using 'rewrites' instead of 'routes' for better compatibility
Write-Host "Creating vercel.json in build/web..."
python -c "import json; config = {'rewrites': [{'source': '/(.*)', 'destination': '/index.html'}]}; open('build/web/vercel.json', 'w', encoding='utf-8').write(json.dumps(config, indent=2))"

# Deploy to Vercel
Write-Host "Deploying to Vercel..."
# We use --prod to deploy to production directly
# We use --yes to skip confirmation prompts
# We specify the project name to avoid using the user's name
vercel deploy build/web --prod --name techpilot-web --yes

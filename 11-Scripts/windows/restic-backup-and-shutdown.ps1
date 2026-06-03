# Set Restic repository password via environment variable
$env:RESTIC_PASSWORD = "password"

# Run Restic backup
C:\restic\restic backup `
  -r Z:\restic\yoga\ `
  D:\backup\ `
  --option compression=auto

# Shut down the system after successful backup
Stop-Computer

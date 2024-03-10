# PSDuckDnsUpdater

## Usage

### Install

```powershell
Set-Location .\repos
git clone https://github.com/kumarstack55/PSDuckDnsUpdater.git

# run as administrator
New-EventLog -LogName "Application" -Source "DuckDnsUpdater"
```

### Uninstall

```powershell
Remove-EventLog -Source "DuckDnsUpdater"
```

### Update domain

```powershell
Set-Location .\PSDuckDnsUpdater

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$domain = "YOUR-DOMAIN"
$token = "SECRETxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
.\Invoke-DuckDnsUpdate -Domain $domain -Token $token
```

### Update domain with IPv6 address

```powershell
Set-Location .\PSDuckDnsUpdater

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$domain = "YOUR-DOMAIN"
$token = "SECRETxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
.\Invoke-DuckDnsUpdate -Domain $domain -Token $token -Update IPv6
```

## Register in the task scheduler

```powershell
$domain = "YOUR-DOMAIN"
$token = "SECRETxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$taskName = "DuckDnsUpdater"

Set-Location .\PSDuckDnsUpdater

$location = Get-Location
$scriptDirectory = $location.Path

$execute = "powershell.exe"
$argument = "-NoProfile -ExecutionPolicy Bypass -Command `".\Invoke-DuckDnsUpdate -Domain '$domain' -Token '$token'`""
$action = New-ScheduledTaskAction -WorkingDirectory $scriptDirectory -Execute $execute -Argument $argument

$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -At (Get-Date) -Once

$settings = New-ScheduledTaskSettingsSet

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings
```

## Development

### Requirements

- Pester 5.5.0+

### Run tests

```powershell
Invoke-Pester
```

## License

MIT
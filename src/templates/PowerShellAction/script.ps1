$settings = Get-Content .\settings.json | ConvertFrom-Json

$settings.'Sample String Parameter'
$settings.'Sample Number Parameter'
$settings.'Sample Boolean Parameter'
$settings.'Sample Password Parameter'
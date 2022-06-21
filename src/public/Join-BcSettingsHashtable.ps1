Function Join-BcSettingsHashtable {
    [cmdletbinding()]
    param (
        [string]$AgentPath,
        [hashtable]$Parameters
    )
    $runnerSettings = Get-Content $AgentPath\runner_settings.json | ConvertFrom-Json

    $settings = [ordered]@{
        runner_identity      = $runnerSettings.identity
        host                 = $runnerSettings.host
        thread_id            = ''
        job_id               = ''
        action_instance_id   = ''
        repository_action_id = ''
        prodigal_object_id   = ''
        prodigal_asset_name  = $env:COMPUTERNAME
        atoken               = $runnerSettings.atoken
    }

    $x = 0
    foreach ($key in $Parameters.Keys) {
        $settings.Insert($x, $key, $Parameters[$key])
        $x++
    }

    $settings
}
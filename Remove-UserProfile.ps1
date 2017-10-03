Function Remove-UserProfile{
   <#
        .SYNOPSIS
            Removes specified user profile from a local or remote machine using Invoke-Command

        .PARAMETER
            Profile
            The profile you wish to remove from the workstation
        
        .PARAMETER
            Computername
            The remote computer(s) you wish to remove profiles from

        .EXAMPLE
            Remove-UserProfile -Profile demouser1
        
        .EXAMPLE
            Remove-UserProfile -Profile demouser1,demouser2
        
        .EXAMPLE
            Remove-UserProfile -Computername wrkstn01 -Profile demouser1

        .EXAMPLE
            Remove-UserProfile -Computername wrkstn01,wrkstn02 -Profile demouser1
   #>
    Param(
        [cmdletBinding()]
        [parameter(
                Mandatory,
                Position=1)]
                [string]
                $Profile,
        [parameter(
                Mandatory=$false,
                Position=0)]
                [array]
                $Computername
        )
    
    #First, we need to make sure that the current processes is being run As Administrator. Remove-CimInstance requires the elevated prompt    

    $currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentuser)
    $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    If($principal.IsInRole($admin))
    {

        $host.Ui.RawUI.WindowTitle = $MyInvocation.MyCommand.Definition + "(Elevated)"
    }

    else {
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "Powershell"

        $newProcess.Arguments = $MyInvocation.MyCommand.Definition

        $newProcess.Verb = "runas"

        [System.Diagnostics.Process]::Start($newProcess)

        Write-Output "Hello ELEVATION"
    }
    #Work with a remote machine.
    If($Computername -ne '')
    {
        Foreach($computer in $Computername)
            {
                Try
                    {
                        Foreach($p in $Profile)
                            {
                                Get-CimInstance -Computername $Computer win32_userprofile | 
                                Select-Object SID,LocalPath |                           
                                Where-Object { $_.localpath -match "$p" } |
                                Remove-CimInstance
                              
                            }#end foreach
                    }#end try
                
                Catch
                    {
                        $_.Exception.Message
                    
                    }#end catch
            }#end foreach
    }#end if
    
    #Working with the local machine.
    Else
        {
        foreach($p in $Profile)
            {
                Get-CimInstance win32_userprofile |
                Select-Object SID,LocalPath |
                Where-Object { $_.localpath -match "$p" } |
                Remove-CimInstance

            }#end foreach
        }#end else
}#end function
Function New-O365EmailSignature {

    $htmlTemplate = @"


"@

    $savelocation = 'E:\Data\Signatures'
    
    $users = Get-MSOLUser * | Select-Object FirstName, LastName, MobilePhone, 'Phone Number', Title, UserPrincipalName
    
    Foreach ($user in $users) {
        
        $props = @{
            $SAMAccount = $user.UserPrincipalName -replace ('@newpointe.org', '')
            $FName      = $user.FirstName
            $LName      = $user.LastName
            $Mobile     = $user.MobilePhone
            $Desk       = $user.'Phone Number'
            $Email      = $user.UserPrincipalName
        }

        $userObj = New-Object -Type psobject -Property $props

        $htmlFile = New-Item -Path $savelocation -ItemType File -Name "$user.htm"

        Set-Content -Path $htmlfile -Value $htmlContent

        Get-Mailbox $userObj.SAMAccount -RecipientTypeDetails UserMailbox | Set-MailboxMessageConfiguration -SignatureHTML $(Get-Content $htmlFile) -AutoAddSignature:$true

    }

}



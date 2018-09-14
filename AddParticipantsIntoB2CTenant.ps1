#1. Connect to Azire Active Directoy Account with admin member

Connect-AzureAD -TenantId '<TenantId>'
$Creds = (Get-Credential -Credential "<emailAddress>")


# 2. Function to generate random password
Function GET-RandomPassword() {
Param(
[int]$length=10,
[string[]]$sourcedata
) 

$ascii=$NULL;

For ($a=48;$a –le 122;$a++) {$ascii+=,[char][byte]$a }

For ($loop=1; $loop –le $length; $loop++) {
            $TempPassword+=($sourcedata | GET-RANDOM)
            }
return $TempPassword
}



# 3. Settings
$emailSendFromAddress = "<From Email>"
$emailSmtp="smtp.office365.com"
$mailSubject = "Hello!"
$ascii=$NULL;
For ($a=48;$a –le 122;$a++) {$ascii+=,[char][byte]$a }


# 4. Read CSV file
$userList = import-csv “Participants.csv"

# 5. Loop each user and add them into Azure Active Directory

ForEach ($user in $userList)
{
    $EmailAddress=$user.'Email'
    $firstName=$user.FirstName
    $lastName=$user.LastName


    #check if guest with same user is already exist
    $emialwithoutAt=$user.'Email' -replace '@','_'
    $participant = Get-AzureADUser -Filter "DisplayName eq '$emialwithoutAt'"
    if ([string]::IsNullOrEmpty($participant))
    {
    #-----------------------------------------------------------------------
    #Start block : Add participants to Active Azure Directory B2C Tenant
    #-----------------------------------------------------------------------
       
       $randomPassword = GET-RandomPassword –length 12 -sourcedata $ascii    

            $SignInNames = @(
                        (New-Object `
                    Microsoft.Open.AzureAD.Model.SignInName `
                    -Property @{Type = "userName"; Value = $emialwithoutAt}),
                   (New-Object `
                    Microsoft.Open.AzureAD.Model.SignInName `
                    -Property @{Type = "emailAddress"; Value = $EmailAddress})
            )

            $PasswordProfile = New-Object `
                -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile `
                -Property @{ 
                    'Password' = $randomPassword;
                    'ForceChangePasswordNextLogin' = $false;
                };


            New-AzureADUser `
            -DisplayName $emialwithoutAt `
            -CreationType "LocalAccount" `
            -AccountEnabled $true `
            -PasswordProfile $PasswordProfile `
            -SignInNames $SignInNames `
            -GivenName $firstName `
            -Surname $lastName 


            
    #-----------------------------------------------------------------------
    #End block : Add participants to Active Azure Directory B2C Tenant
    #-----------------------------------------------------------------------

    #-----------------------------------------------------------------------
    #Start block : Send Email to the added participants
    #-----------------------------------------------------------------------
       
      
       
       
       
       $mailBody = "<div style='font-family:Verdana;font-size:11pt;padding-left: 20px !important;'> Hi </div>"
       
       
       
        $MyEmail = $emailSendFromAddress
        $SMTP= $emailSmtp
        $To = $EmailAddress
        $Subject = $mailSubject
        $Body = $mailBody
       

        Start-Sleep 2

        Send-MailMessage -To $to -From $MyEmail -Subject $Subject -Body $Body -BodyAsHtml -Priority high -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587 -DeliveryNotificationOption never

         "Added new participant:  $EmailAddress" 
         "Email Sent           :  $EmailAddress" 
    #-----------------------------------------------------------------------
    #End block : Send Email to the added participants
    #-----------------------------------------------------------------------
    Start-Sleep 2
    }
    else
    { 
        "Already exist        :  $EmailAddress" 
    }
    
};
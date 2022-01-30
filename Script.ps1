#clearing console
Clear-Host
#variables
$domena = (Get-ADDomain).dnsroot
$DN = 'DC=' + $domena.Replace('.',',DC=')
$serwer = (Get-ADDomain).PDCEmulator
$nazwaOU = Read-Host -Prompt 'Enter your OU name'
$OU = ”OU=”+$nazwaOU+”,”+'DC=' + $domena.Replace('.',',DC=')



#creating organizational unit

if (Get-ADOrganizationalUnit -Filter "Name -eq '$nazwaOU' " ) { 

Write-Host "There is a OU $nazwaOU" -ForegroundColor Green 

} 

else 

{ 

Write-Host " OU $nazwaOU will be created" -ForegroundColor Red  

New-ADOrganizationalUnit -Name:$nazwaOU -Path:$DN -ProtectedFromAccidentalDeletion:$false

} 






 
#creating files and their headers

$plik1 = "c:\Program Files\"+"acc_name.csv"
$nag1 = "Nazwa,Haslo"
$nag1 > $plik1
$plik2 = "c:\Program Files\"+"create_user.csv"
$nag2 = "Creator|Date|Acc"
$nag2 > $plik2
$plik = "c:\Program Files\"+"create_csv.csv"
$nag = "Imie|Nazwisko|Grupa"
$nag > $plik 
$plik3 = "c:\Program Files\"+"blocked_data.txt"
$nag3 = "Blocker|Date|Blocked"
$nag3 > $plik3
$plik4 = "c:\Program Files\"+"passw_data.txt"
$nag4 = "Changer|Date|Acc"
$nag4 > $plik4
$plik5 = "c:\Program Files\"+"create_group.csv"
$nag5 = "Tworca|Data|Grupa"
$nag5 > $plik5
$plik6 = "c:\Program Files\"+"group_change.txt"
$nag6 = "Adder|Added|Group"
$nag6 > $plik6

#the a function creates one user

function a { 

    Param ( 

        [CmdletBinding()]  

        [Parameter(Mandatory=$true)] 

        [string]$imie, 

        [Parameter(Mandatory=$true)] 

        [string]$nazwisko, 

        [Parameter(Mandatory=$true)]  

        [int]$dzial
    ) 
    
    
    $nazwa = $imie+” ”+$nazwisko
    $netlog = $imie+”_”+$nazwisko
    $dnslog =  $imie+”.”+$nazwisko
    $nazwa2 = $nazwa
    $netlog2 = $netlog
    $dnslog2 =  $dnslog
    $i= 1
    $ErrorActionPreference = "SilentlyContinue"
    
    While ((Get-ADUser -Identity $netlog -ErrorAction SilentlyContinue) -ne $null){
     
    $netlog = $netlog2 + [string]$i
    $nazwa = $nazwa2 + [string]$i
    $dnslog = $dnslog2 + [string]$i
    $i++
    }
    $ErrorActionPreference = "Continue"
   
    
    $password = "A"
    1..12 | ForEach-Object { 

    $password += [char](Get-Random -Minimum 48 -Maximum 122)}
    $mail = $dnslog+”@”+$domena
    
    $nag11 = "$dnslog"+","+"$password"
    $nag11 >> $plik1
    $creator = (get-aduser $env:username | Select Name).Name 
    $date = get-date -UFormat "%d/%m/%Y"
    
    $nag11 = "$creator"+"|"+"$date"+"|"+"$dnslog"
    $nag11 >> $plik2
    
    
New-ADUser -Name "$nazwa" -DisplayName "$nazwa" -Office:"$grupa" -SamAccountName "$netlog" -UserPrincipalName "$dnslog" -GivenName "$imie" -Surname "$nazwisko" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false –PasswordNeverExpires $true -server "$serwer"
    }
   
   
 #functions b1,b2,b3 create users from a csv file

function b1 { 

    Param ( 

        [CmdletBinding()]  

        [Parameter(Mandatory=$true)] 

        [string]$imie, 

        [Parameter(Mandatory=$true)] 

        [string]$nazwisko, 

        [Parameter(Mandatory=$true)]  

        [int]$dzial
    ) 
  $dane1 = "$imie"+"|"+"$nazwisko"+"|"+"$dzial"  $dane1 >> $plik 
  }
    
 function b2 { 
 $Users = Import-Csv -Delimiter "|" -Path "$plik" 
 foreach ($User in $Users)    
 { 
    $nazwa = $User.Imie+” ”+$User.Nazwisko 
    $netlog = $User.Imie+”_”+$User.Nazwisko 
    $dnslog =  $User.Imie+”.”+$User.Nazwisko
    $grupa = $User.Grupa
    $imie = $User.Imie
    $nazwisko = $User.Nazwisko 
    $nazwa2 = $nazwa
    $netlog2 = $netlog
    $dnslog2 =  $dnslog
    $i= 1
 
    While ((Get-ADUser -Identity $netlog -ErrorAction SilentlyContinue) -ne $null){
     
    $netlog = $netlog2 + [string]$i
    $nazwa = $nazwa2 + [string]$i
    $dnslog = $dnslog2 + [string]$i
    $i++
    }

    
    $password = "A"
    1..12 | ForEach-Object { 

    $password += [char](Get-Random -Minimum 48 -Maximum 122)}

    $mail = $dnslog+”@”+$domena
    $nag11 = "$dnslog"+","+"$password"
    $nag11 >> $plik1
    $creator = (get-aduser $env:username | Select Name).Name
    $date = get-date -UFormat "%d/%m/%Y"
    $nag11 = "$creator"+"|"+"$date"+"|"+"$dnslog"
    $nag11 >> $plik2
    
    New-ADUser -Name "$nazwa" -DisplayName "$nazwa" -Office:"$grupa" -SamAccountName "$netlog" -UserPrincipalName "$dnslog" -GivenName "$imie" -Surname "$nazwisko" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false –PasswordNeverExpires $true -server "$serwer"

 }}
 function b 
 { 
 do
 {
    
    $select = Read-Host "1- enter new user data 2- create users z pliku csv q- quit"
    switch ($select)
    {
    '1' {
    b1
    } '2' {
    b2
    } 
    }
    pause
 }
 until ($select -eq 'q')}




 #the c function blocks the user 

    function c { 
    $blok = Read-Host "Enter the login to be blocked (e.g. anon_smith)" 
    Try {(Get-ADUser -Identity $blok -ErrorAction silentlycontinue)  }
    Catch { Write-Host "User does not exist"}
    $ErrorActionPreference = "SilentlyContinue"
    If ((Get-ADUser -Identity $blok -ErrorAction silentlycontinue) -ne $null) { 
    Disable-ADAccount -Identity $blok
    $creator = (get-aduser $env:username | Select Name).Name
    $date = get-date -UFormat "%d/%m/%Y"
    $nag12 = "$creator"+"|"+"$date"+"|"+"$blok"
    $nag12 >> $plik3
    Write-Host "Blocked Successfully"} 
    $ErrorActionPreference = "Continue"
    
    }
  #the d function changes the user's password
    function d { 
    $haslo = Read-Host "Enter the login which the password should be changed"
    Try {(Get-ADUser -Identity $haslo -ErrorAction silentlycontinue)  }
    Catch { Write-Host "User does not exist"}
    $ErrorActionPreference = "SilentlyContinue"
    If ((Get-ADUser -Identity $haslo -ErrorAction silentlycontinue) -ne $null) { 
    $haslo2 = Read-Host "Enter a new password"
    Set-ADAccountPassword -Identity $haslo -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$haslo2" -Force)
    $creator = (get-aduser $env:username | Select Name).Name
    $date = get-date -UFormat "%d/%m/%Y"
    $nag12 = "$creator"+"|"+"$date"+"|"+"$haslo"
    $nag12 >> $plik4
    Write-Host "Password has been changed"} 
    $ErrorActionPreference = "Continue"
    }
     
  #the e function creates an Active Directory group
   function e { 
   $gupa = Read-Host "Enter the group to be created"
   $aha = Get-ADGroup -LDAPFilter "(SAMAccountName=$gupa)"
   if ($aha -eq $null) {
   New-ADGroup “$gupa” -GroupScope Global -GroupCategory Security -Path "$OU"
   $creator = (get-aduser $env:username | Select Name).Name
   $date = get-date -UFormat "%d/%m/%Y"
   $nag12 = "$creator"+"|"+"$date"+"|"+"$gupa"
   $nag12 >> $plik5
   Write-Host "Group has been created"
   }
   else { Write-Host "Group already exist"}
   }
  #the f function adds the user to an Active Directory group
   function f { 
   $grupa = Read-Host "Enter the group to which the user is to be added"
   $log = Read-Host "Enter the user to be added"
   Try {(Get-ADUser -Identity $log -ErrorAction silentlycontinue)  }
   Catch { Write-Host "User does not exist"}
   $ErrorActionPreference = "SilentlyContinue"
   If ((Get-ADUser -Identity $log -ErrorAction silentlycontinue) -ne $null) { 
   $ErrorActionPreference = "Continue"
   Add-ADGroupMember -Identity $grupa -Members $log
   $creator = (get-aduser $env:username | Select Name).Name
   $nag12 = "$creator"+"|"+"$log"+"|"+"$grupa"
   $nag12 >> $plik6}
   $ErrorActionPreference = "Continue"
   }
   
   #the g function creates a list of groups and their members
   function g { 
   Get-ADGroup -Filter '*' |  Export-Csv -Path .\grupy.csv -NoTypeInformation 
   
   $grupy = Import-Csv .\grupy.csv
   
   foreach ($name in $grupy) { 
   $tekst = $name.name
   $tekst2 = "$tekst"+".csv"
   $pli = "c:\Program Files\"+"$tekst2"
   
   Get-ADGroupMember -identity $tekst | Select-Object name | Export-csv -path $pli -NoTypeInformation
   
   
   }
   
   }
   #the y function creates a list of blocjed accounts
   function y { 
   
   
   $plii = "c:\Program Files\"+"zablokowane_konta.csv"
   
   
   Get-ADUser -filter {Enabled -eq $False}  -properties * | Sort-Object DisplayName | Select-Object  whenChanged, name, DistinguishedName, SID | Export-csv -path $plii -NoTypeInformation
   }
   
   #the y function creates a list of all accounts in AD
    function x { 

   $plii = "c:\Program Files\"+"uzytkownicy.csv"
   Get-ADUser -filter *  -properties * | Sort-Object DisplayName | Select-Object  GivenName, Surname, userPrincipalName, SamAccountName, DistinguishedName, whenChanged, whencreated, LastLogonDate, passwordlastset | Export-csv -path $plii -NoTypeInformation
   
   }
   ##the k function creates files with info about computers in AD
   function k { 
   Get-ADComputer -Filter '*' -Properties operatingSystem |  Export-Csv -Path .\kompy.csv -NoTypeInformation 
   
   $grupy = Import-Csv .\kompy.csv
   
   foreach ($name in $grupy) { 
   $system = $name.OperatingSystem
   $tekst = $name.name
   $tekst2 = "$domena"+"_"+"$system"+".csv"
   $pli = "c:\Program Files\"+"$tekst2"
   
   Get-ADComputer -Identity "$tekst" -Properties *| Select-Object  Name, SID, DistinguishedName, Enabled, PasswordLastSet,whencreated | Export-csv -path $pli -NoTypeInformation
   
   
   }
   
   
   }
   #the l function creates a list of all OU in AD
   function l {
   $pli = "c:\Program Files\"+"OS.csv"
   Get-ADOrganizationalUnit -filter *  -properties *| Sort-Object DistinguishedName | Select-Object  DistinguishedName, Name | Export-csv -path $pli -NoTypeInformation
   }

   #Main menu function
   function menu
 { 
 do
 
    
     {
Write-Host "`n============= Select a category =============="
Write-Host " 'U' Managing user accounts"
Write-Host " 'G' Managing groups"
Write-Host " 'R' Reports "
Write-Host " 'Q' Quit"
Write-Host "========================================================"
$select = Read-Host "`nEnter Choice"
} until (($select -eq 'U') -or ($select -eq 'G') -or ($select -eq 'R') -or ($select -eq 'Q') )
switch ($select) {
   'U'{
       menuU 
   }
   'G'{
       menuG
   }
   'R'{
       menuR
    }
    'Q'{
      Return
   }
}}

#Submenu functions
function menuU 
 { 
 do
 
    
     {
Write-Host "`n============= Select an activity =============="
Write-Host " '1' Creating a user account"
Write-Host " '2' Creating multiple accounts based on a csv file"
Write-Host " '3' Blocking a user account"
Write-Host " '4' Changing the password"
Write-Host " 'Q' Quit"
Write-Host "========================================================"
$select = Read-Host "`nEnter Choice"
} until (($select -eq '1') -or ($select -eq '2') -or ($select -eq '3') -or ($select -eq '4') -or ($select -eq 'Q') )
switch ($select) {
   '1'{
       a
   }
   '2'{
      b
   }
   '3'{
       c
    }
    '4'{
       d
    }
    'Q'{
      Return
   }
}}

function menuG 
 { 
 do
 
    
     {
Write-Host "`n============= Select an activity =============="
Write-Host " '1' Creating new groups  "
Write-Host " '2' Adding users to groups"
Write-Host " 'Q' Quit"
Write-Host "========================================================"
$select = Read-Host "`nEnter Choice"
} until (($select -eq '1') -or ($select -eq '2')  -or ($select -eq 'Q') )
switch ($select) {
   '1'{
      e
   }
   '2'{
      f
    }
    'Q'{
      Return
   }
}}

function menuR 
 { 
 do
 
    
     {
Write-Host "`n============= Select an activity =============="
Write-Host " '1' List of groups with their members"
Write-Host " '2' List of blocked accounts"
Write-Host " '3' List of detailed information about user accounts"
Write-Host " '4' List of detailed information about computers in the domain"
Write-Host " '5' List of organizational units in the domain  "
Write-Host " 'Q' Quit"
Write-Host "========================================================"
$select = Read-Host "`nEnter Choice"
} until (($select -eq '1') -or ($select -eq '2') -or ($select -eq '3') -or ($select -eq '4') -or ($select -eq '5') -or ($select -eq 'Q') )
switch ($select) {
   '1'{
       g
   }
   '2'{
      y
   }
   '3'{
       x
    }
    '4'{
       k
    }
    '5'{
       l
    }
    'Q'{
      Return
   }
}}
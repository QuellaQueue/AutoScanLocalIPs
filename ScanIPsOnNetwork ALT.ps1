#Checks for active network connections
$activeadapters = get-netadapter | Where-Object {$_.status -eq "Up"}
$possibleips = 1..255
#Now we wipe our save file
$savelocation = Join-Path -Path $PSScriptRoot -ChildPath "nearbyips.txt"
Clear-Content -Path $savelocation

$testipandsaveJob = {
    #pulls in the global/loop variables. P is appended to the var names to specify this is the parallel version of the variable
                    $savelocationP = $using:savelocation
                    $targetaddressP = $using:targetaddress

                    $result = (Test-Connection -count 1 -targetname ($targetaddressP)).Status 
                    if ($result -eq "Success"){
                        Write-output "Success on $targetaddressP"
                        $targetaddressP >> $savelocationP
                    }
}

#Main Loop
foreach($adapter in $activeadapters){
    Write-Debug ("Adapter online: "+ $adapter.name)
    $nicinfo = Get-NetIPAddress -interfacealias $adapter.name -addressfamily "IPv4"
    $myip = ($nicinfo).IPAddress

    #This is the SubnetMaskLength's binary length under a different name. By default this is in Whack notation (/8)
    $SubnetMaskLength = ($nicinfo).PrefixLength

    #Splits up the host device's IPv4 address, and assigns each octet to a variable
    $ipwhack8 = $myip.split(".")[0]
    $ipwhack16 = $myip.split(".")[1]
    $ipwhack24 = $myip.split(".")[2]
    $ipwhack32 = $myip.split(".")[3]

    #Binary versions of each octet
    $binipw8 = '{0:d8}' -f [int]([Convert]::ToString($ipwhack8, 2))
    $binipw16 = '{0:d8}' -f [int]([Convert]::ToString($ipwhack16, 2))
    $binipw24 = '{0:d8}' -f [int]([Convert]::ToString($ipwhack24, 2))
    $binipw32 = '{0:d8}' -f [int]([Convert]::ToString($ipwhack32, 2))

    #binary string of the full ip address without delimiters
    $binaryIPstring = $binipw8 + $binipw16 + $binipw24 + $binipw32

    
    #Now we prep a variable to hold the binary subnetmask
    $binarySubnetMask = $binaryIPstring.ToCharArray(0,$binaryIPstring.length)
    Write-Output $binarySubnetMask$bin
    for ($i = 0; $i -lt $binarySubnetMask.length; $i++){
        $length =$binarysubnetmask.length
        if($i -lt $SubnetMaskLength){
            $binarySubnetMask[$i] = '1'
        }else{
            $binarySubnetMask[$i] = '0'
        }
    }
    Write-Output $binarySubnetMask
    #converts the subnetmask back to a string for seperation

    $binarySubnetMask = $binarySubnetMask -join ''
    $binarySubnetARRAY = {0,0,0,0}
    $binsubnetARRAY[0] = $binarySubnetMask.substring(0,8)
    $binsubnetARRAY[1] = $binarySubnetMask.substring(8,8)
    $binsubnetARRAY[2] = $binarySubnetMask.substring(16,8)
    $binsubnetARRAY[3] = $binarySubnetMask.substring(24,8) 
    #BinarySubnetmask is in 111111111111000 format, and will need to be split again before use. Best way to do this would be to check each octet, create a value from it

    #Need to have each section of the 
    for($i = 0; $i -lt $binarySubnetARRAY.length; $i++){
        if ([Convert]::ToInt32($binarySubnetARRAY[$i],2) -ne "255"){
                
        }
    }
    
                   
            
        }
        default{Write-Output ("Skipping " + $adapter.Name)}

    


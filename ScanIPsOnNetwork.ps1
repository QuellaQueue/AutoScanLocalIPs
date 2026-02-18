#Checks for active network connections
$activeadapters = get-netadapter | Where-Object {$_.status -eq "Up"}
$possibleips = 1..255

#Now we wipe our save file
$savelocation = Join-Path -Path $PSScriptRoot -ChildPath "nearbyips.txt"
"" > $savelocation

#Main Loop
foreach($adapter in $activeadapters){
    Write-Debug ("Adapter online: "+ $adapter.name)
    $nicinfo = Get-NetIPAddress -interfacealias $adapter.name -addressfamily "IPv4"
    $myip = ($nicinfo).IPAddress

    #This is the Subnetmask's binary length under a different name. By default this is in Whack notation (/8)
    $subnetmask = ($nicinfo).PrefixLength

    #Splits up the host device's IPv4 address, and assigns each octet to a variable
    $ipwhack8 = $myip.split(".")[0]
    $ipwhack16 = $myip.split(".")[1]
    $ipwhack24 = $myip.split(".")[2]

    #$networkid is unused as of now. May decide to use in the future
    switch ($subnetmask){
        8{$networkid = $ipwhack8 + ".0.0.0"}
        16{$networkid = $ipwhack8 + "."+ $ipwhack16 + ".0.0"}
        24{$networkid = $ipwhack8  +"."+ $ipwhack16 + "." +$ipwhack24 +".0"}
        default{Write-Output "Subnetmask $subnetmask is not a default whack value (8,16,24). Cannot Scan for IPs." }
    }

    #Checks all possible IPs on the subnet and records any that respond
    switch($subnetmask){
        8{   
            foreach($ip1 in $possibleips){ 
                foreach($ip2 in $possibleips){
                    foreach($ip3 in $possibleips){  
                        $targetaddress = $ipwhack8 + "." + $ip1 + "." + $ip2 + "." + $ip3
                        $result = (Test-Connection -count 1 -targetname $targetaddress).Status
                        if ($result -eq "Success"){
                            Write-output "Success on $targetaddress"
                            $targetaddress >> $savelocation
                        }
                    }
                }    
            }
        }
        16{
            foreach($ip2 in $possibleips){
                foreach($ip3 in $possibleips){
                    $targetaddress = $ipwhack8 + "." + $ipwhack16 + "." + $ip2 + "." + $ip3
                    $result = (Test-Connection -count 1 -targetname $targetaddress).Status
                    if ($result -eq "Success"){
                        Write-output "Success on $targetaddress"
                        $targetaddress >> $savelocation
                    }
                }
            }    
        }
        24{
            foreach($ip in $possibleips){
                #pulls in the global variables
                $targetaddress = $ipwhack8 + "." + $ipwhack16 + "." + $ipwhack24 + "." + $ip
                $result = (Test-Connection -count 1 -targetname ($targetaddress)).Status 
                if ($result -eq "Success"){
                    Write-output "Success on $targetaddress"
                    $targetaddress >> $savelocation
                }
            }
                   
            
        }
        default{Write-Output ("Skipping " + $adapter.Name)}

    }

}
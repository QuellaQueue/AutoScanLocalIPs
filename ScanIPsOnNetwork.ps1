$activeadapters = get-netadapter | Where-Object {$_.status -eq "Up"}
$possibleips = 1..255
#Now we wipe our save file
$savelocation = "C:\Users\qmmartin\OneDrive - Duly Health and Care\Scripts\Illegals\nearbyips.txt"
"" > $savelocation

#Checks for active network connections
foreach($adapter in $activeadapters){
    Write-Debug ("Adapter online: "+ $adapter.name)
    $nicinfo = Get-NetIPAddress -interfacealias $adapter.name -addressfamily "IPv4"
    $myip = ($nicinfo).IPAddress

    #This is the Subnetmask under a different name. By default this is in Whack notation
    $subnetmask = ($nicinfo).PrefixLength
    $ipwhack8 = $myip.split(".")[0]
    $ipwhack16 = $myip.split(".")[1]
    $ipwhack24 = $myip.split(".")[2]

    #

                $ipw8 = $ipwhack8
                $ipw16 = $ipwhack16
                $ipw24 = $ipwhack24
    
    $networkid
    switch ($subnetmask){
        8{$networkid = $ipwhack8 + ".0.0.0"}
        16{$networkid = $ipwhack8 + $ipwhack16 + ".0.0"}
        24{$networkid = $ipwhack8 + $ipwhack16 + $ipwhack24 +".0"}
        default{Write-Output "Subnetmask $subnetmask is not a default whack value (8,16,24). Cannot Scan for IPs." }
    }
    

    #checks all possible IPs and records any that 
    switch($subnetmask){
        8{    
            $possibleips | foreach-object -parallel{
                #pulls in the global variable
                $ipw8 = $using:ipwhack8
                
                $ip1 = $_
                $possibleips | foreach-object -parallel{
                    #pulls in the global variable
                    $ipw8 = $using:ipwhack8

                    $ip2 = $_
                    $possibleips | foreach-object -parallel{
                        $ip3 = $_
                        #pulls in the global variable
                        $ipw8 = $using:ipwhack8

                        $targetaddress = $ipw8 + "." + $ip1 + "." + $ip2 + "." + $ip3
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
            $possibleips | foreach-object -parallel{
                #Pulls in the global variables
                $ipw8 = $using:ipwhack8
                $ipw16 = $using:ipwhack16

                #non-volatiles the counter 
                $ip2 = $_
                $possibleips | foreach-object -parallel{
                    #Pulls in the global variables
                    $ipw8 = $using:ipwhack8
                    $ipw16 = $using:ipwhack16

                    #Non-volitiles the counter
                    $ip3 = $_
                    $targetaddress = $ipw8 + "." + $ipw16 + "." + $ip2 + "." + $ip3
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
                $ipw8 = $ipwhack8
                $ipw16 = $ipwhack16
                $ipw24 = $ipwhack24
                $targetaddress = $ipw8 + "." + $ipw16 + "." + $ipw24 + "." + $ip
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
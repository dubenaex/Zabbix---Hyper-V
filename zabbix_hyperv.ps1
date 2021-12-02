#
# Zabbix Hyper-V powershell monitoring
# (c) 2021 duBeNaex
#

#read args
$action = $args[0]

if ($action -eq 'HyperVstatus') {
	$HyperVstatus = $(Get-WindowsFeature -Name Hyper-V).installed	
	if ($HyperVstatus -eq 'True') {
		return 1
		}
	else {
		return 0	
		}
	}

elseif ($action -eq 'VMcount') {

	# get list of VMs
	try {
		$VMcount = $(Get-VM -ErrorAction Stop).Count
		}
	catch {
		$VMcount = 0	
		}
	return $VMcount

	}

elseif ($action -eq 'DiscoveryVMs') {

	# prepare output array
	$result = @{}
	$result.data = @()
	# get list of VMs
	$VMs = Get-VM
	foreach ($vm in $VMs) {
		# vmName
		if ($vm.State -ne 'Off') {
			$result.data += @{'{#VMNAME}' = $vm.VMName} 
			}
		}
		
	convertto-json $result
	}

	
elseif ($action -eq 'VMstatus')	{

	# Operating normally / Backing up virtual machine / ?
	$vm = $args[1]
	# vmHealth
	$vmHealth = $(Get-VM -VMName $vm).Status
	if ( $vmHealth -eq 'Operating normally') {
			return 1
		}
	elseif ( $vmHealth -eq 'Backing up virtual machine') {
			return 2
		}		
	else {
			return 0
		}
	}

elseif ($action -eq 'VMcheckpoint')	{
	$vm = $args[1]
	$checkpointCount = 0
	# vmCheckpoint
	$vmCheckpoints = $(Get-VMSnapshot -VMName $vm)
	foreach ($vmCheck in $vmCheckpoints) {
    # don't care about replica checkpoint
		if ($vmCheck.SnapshotType -ne 'Replica') {
			$checkpointCount++
			} 
		}
	
	return $checkpointCount
	
	}
	
elseif ($action -eq 'VMreplica') {
	# Normal (1) / Warning (2) / Critical (3)
	$vm = $args[1]
	# vmReplica
	try {
		$vmReplica = $(Get-VMReplication -VMname $vm -ErrorAction Stop).Health
		}
	catch {
		$vmReplica = 0
		}
	
	if ($vmReplica -eq 0) {
		return 0
		}
	else {
		if ($vmReplica -eq 'Normal') {
			return 1
			}
		elseif ($vmReplica -eq 'Warning') {
			return 2
			}
		elseif ($vmReplica -eq 'Critical') {
			return 3
			}			
		else {
			return 4
			}				
		}
	}
	
###################################################### zabbix-agent.conf ########################################################
# EnableRemoteCommands=1																										                                                    #
# UnsafeUserParameters=1																										                                                    #
# Alias=service.discovery.hyperv:service.discovery																				                                      #
# Timeout = 30																													                                                        #
# UserParameter=hyperv[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\script\zabbix_hyperv.ps1" "$1" "$2"	  #
#################################################################################################################################

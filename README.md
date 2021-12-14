# Zabbix Hyper-V template

Zabbix template to monitor Windows Hyper-V status. Template is monitoring health of the VMs, replication status and checkpoint situation. As you can see only hyper-V specific features are monitored, nothing else. Best is to combine this template with windows OS template to cover hypervisor monitoring completelly. Same goes to VMs monitoring, specific per VM monitoring is needed for best results.


## Installation

1. Import zabbix template on Zabbix server
2. Create powershell script on monitored host (ideally in C:\Zabbix\script\zabbix_hyperv.ps1 so you don't have to change anything)
3. Edit zabbix-agent configuration file and add following lines at the end (modify path to the file if needed)

*EnableRemoteCommands=1*
*UnsafeUserParameters=1*
*Alias=service.discovery.hyperv:service.discovery*
*Timeout = 30*
*UserParameter=hyperv[\*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\script\zabbix_hyperv.ps1" "$1" "$2"*

4. Restart zabbix-agent

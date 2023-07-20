# AutoBuildWSUS
Automated Build WSUS update package.

AutoBuildWSUS is complete automated software, producing compressed files with windows updates (KBs), 
and ready to be self-deployed on offline WSUS servers. The server running this software should have a configured 
WSUS system and connection to internet. 

As input, it receives list of KB titles, in ASCII format for each group of Windows servers we want to receive 
the updates (eg: GroupA.txt, GroupB.txt). On folder “Transfer” more tools or documentation that we may need to 
be included on the compressed Update Package can be copied. During execution process, information on the progress 
of the build process, possible fails and additional inputs (eg: name of produced) will be presented through 
PowerShell command line.    

The software is based on the Procedure described on the “OfflineUpdateWSUS” repo, but it is full automated.

When the compressed Update file is ready, it can be transferred to the client’s offline WSUS server, then 
uncompressed, open a CMD on the same path and just run the “DeployOnWSUS.bat”. Instructions, state of the 
installation and more information will be presented on the command line. 

This project has been past tests and it is ready for use. It is still though under development and more 
improvements will be added soon regarding extra automated checks on the approved updates and possibly a Graphical 
user interface which may allow personnel with no experience on WSUS systems to use it.   


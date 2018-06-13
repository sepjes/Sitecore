[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$PackagePath,

  [Parameter(Mandatory=$True)]
  [string]$nosql,

  [Parameter(Mandatory=$True)]
  [string]$ParamFile,

  [Parameter(Mandatory=$False)]
  [string]$PackageDestinationPath = $($PackagePath).Replace(".scwdp.zip", "-nodb.scwdp.zip")
)



$msdeploy = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"
$verb = "-verb:sync"
$source = "-source:package=`"$PackagePath`""
$destination = "-dest:package=`"$($PackageDestinationPath)`""
$declareParamFile = "-declareparamfile=`"$($ParamFile)`""
$declareParam = "-declareparam:name=`"IIS Web Application Name`",kind=ProviderPath,scope=IisApp,match=Website,defaultValue=vanilla"
$declareParam2 = "-declareparam:name=`"HasingAlgoritmSQL`",type=TextFile,scope=SetSitecoreAdminPassword.sql,match=SHA1"
$declareParam3 = "-declareparam:name=`"HasingAlgorithmWebC`",kind=XmlFile,scope=Web\.config$,match=//configuration/membership/setting[@name='hashAlgorithmType']/value/text()"
$skipDbFullSQL = "-skip:objectName=dbFullSql"
$skipDbDacFx = "-skip:objectName=dbDacFx"

#Extract paramter file

Add-Type -Assembly System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($packagePath)
$zip.Entries | where {$_.Name -like 'parameters.xml'} | foreach {[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "C:\sc9\parameters.xml", $true)}
$zip.Dispose()


 

# read parameter file
[xml]$paramfile_content = Get-Content -Path $ParamFile
$paramfile_paramnames = $paramfile_content.parameters.parameter.name
$params = ""
foreach($paramname in $paramfile_paramnames){
   $tmpvalue = "tmpvalue"
   if($paramname -eq "License Xml"){ $tmpvalue = "LicenseContent"}
   if($paramname -eq "IP Security Client IP"){ $tmpvalue = "0.0.0.0"}
   if($paramname -eq "IP Security Client IP Mask"){ $tmpvalue = "0.0.0.0"}
   $params = "$params -setParam:`"$paramname`"=`"$tmpvalue`""
}
$nosql

if ($nosql -eq "true"){write-host "ik moet sql skippen"
Invoke-Expression "& '$msdeploy' --% $verb $source $destination $declareParam $declareParam2 $declareParam3 $declareParamFile $params $skipDbFullSQL $skipDbDacFx"
}
else {
 write-host "ik moet sql niet skippen"
Invoke-Expression "& '$msdeploy' --% $verb $source $destination $declareParam $declareParam2 $declareParam3 $declareParamFile $params"}
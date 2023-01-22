$fileName = Read-Host "Please enter the name of the file that you want to use"
$file = Get-ChildItem -Recurse -Path '.\input' -Filter $fileName
$stringArrayGet = Get-Content $file
$NoExtFileName = $fileName -split ".txt"
New-Item -Path .\output -Name $NoExtFileName[0] -ItemType Directory -Force
$newLocation = ".\output\" + $NoExtFileName[0]
$itemContentList = New-Object System.Collections.ArrayList

function create {

   param (
      $creationName,
      $path
   )
   
   Write-Host "Am creat asta "$creationName
   Write-Host "Aici" $path

   if($creationName.Contains("."))
   {
      New-Item -Path $path -Name $creationName -ItemType File -Force
   }
   else {
       New-Item -Path $path -Name $creationName -ItemType Directory -Force
   }

}

# Ar mai fi mers si cu Join-Path
function pathCreation {

   param (
      $oldPath,
      $newSection
   )
   
   #Write-Host "Inainte de toate oldPath este " $oldPath "iar newSection este " $newSection 

   $newPath = $oldPath+"\"+$newSection
   return $newPath;
}

function lineInterpretation {
   
   param (
      [System.Collections.ArrayList] $itemList,
      [string] $currentPath,
      [string] $toBeCreated
   )

   foreach($item in $itemList)
   {
      if($item.Exists -eq 0 -and $toBeCreated -eq $item.Name )
      {  Write-Host "Item-ul urmator inca nu exista :  " $item.Name
         create $item.Name $currentPath
         $itemPath = pathCreation $currentPath $item.Name
         $item.Exists = 1
         
         if($item.Content -gt 0 )
        {
         foreach($part in $item.Content)
         {    
            if(-not($part.Contains(".")))
            {
               Write-Host "ITEM PATH INAINTE DE APEL ESTE " $itemPath
               lineInterpretation $itemList $itemPath $part

            }
            else
            {
              create $part $itemPath
            }
         }   
        }
        
      }
   }

}

$i = 0

foreach($line in $stringArrayGet)
{  
   $names = $line -split ">"
   $content = $names[1] -split ","
   
   if(-not($names[0]).Contains("."))
   {
   $temp =[PSCustomObject]@{
      Name = $names[0]
      Content = $content
      Index = $i
      Exists = 0
   }
   
   $i = $i+1

   $itemContentList.Add($temp)|Out-Null
   }
   else {
      create $names[0] $newLocation
   }
      
}

foreach($bucata in $itemContentList)
{
   Write-Host "HOST" $bucata.Name

   foreach($bucatica in $bucata.Content)
   {
      Write-Host $bucatica
   }
}

foreach($thing in $itemContentList)
{  
   if($thing.Exists -eq 0)
   {lineInterpretation $itemContentList $newLocation $thing.Name}
}

#lineInterpretation $itemContentList $newLocation $itemContentList[0].Name
param($crop)

function splt
{
	param([Parameter(ValueFromPipeline=$true)]$str)
	process
	{
		$array = ($str -split ",")[2..7] | ?{ $_ -ne "" }
		New-Object PSObject -Property @{ "Stages" = $array }
	}
}
function GenerateTable
{
	param($crop,$label,$interval,[Parameter(ValueFromPipelineByPropertyName=$true)]$stages)
	process
	{
		& "$PSScriptRoot\Generate-CropTable.ps1" -header $label -crop $crop -interval $interval -stages $stages
	}
}

$intervals = @{
	"Coffee Bean" = 2;
	"Green Bean" = 3;
	"Strawberry" = 4;
	"Blueberry" = 4;
	"Corn" = 4;
	"Hops" = 1;
	"Hot Pepper" = 3;
	"Tomato" = 4;
	"Cranberries" = 5;
	"Eggplant" = 5;
	"Grape" = 3;
	"Ancient Fruit" = 7;
}
$interval = 0;
if($intervals.ContainsKey($crop))
{
	$interval = $intervals[$crop];
}
$d = gc "$PSScriptRoot\data.csv"
$i = 0
while( $i -lt $d.length )
{
	
	if( $d[$i].Contains($crop) )
	{
		$base = $d[$i] | splt | GenerateTable -crop $crop -label Base -interval $interval
		$ten = $d[$i+1] | splt | GenerateTable -crop $crop -label "10%" -interval $interval
		$twenty = $d[$i+2] | splt | GenerateTable -crop $crop -label "20%" -interval $interval
		$twentyfive = $d[$i+3] | splt | GenerateTable -crop $crop -label "25%" -interval $interval
		$thirtyfive = $d[$i+4] | splt | GenerateTable -crop $crop -label "35%" -interval $interval
		
		$table= "
$base
{|
|
! style=""background-color: rgba(255,255,255,0.58)"" | Speed-gro
! style=""background-color: rgba(255,255,255,0.58)"" | Deluxe Speed-gro
|-
! style=""background-color: rgba(255,255,255,0.58)"" | Regular
|
$ten
|
$twentyfive
|-
! style=""background-color: rgba(255,255,255,0.58)"" | Agriculturist
|
$twenty
|
$thirtyfive
|}
"
		$table | clip
		return $table
	}
	$i++
}

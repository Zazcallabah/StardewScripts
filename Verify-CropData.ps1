function splt
{
	param([Parameter(ValueFromPipeline=$true)]$str)
	process
	{
		$array = ($str -split ",")[2..7] | ?{ $_ -ne "" } | %{ [int]$_ }
		New-Object PSObject -Property @{ "Stages" = $array }
	}
}


function discount
{
	param([float]$percent,$phasedays)
	if($percent -gt 1 )
	{
		$percent = $percent /100;
	}
	$r = @()
	$phasedays | %{ $r+=[int]$_ }
	$r += 99999;
	[int]$sum = $phasedays | select -first $phasedays.length | measure -Sum |select -expandproperty sum
	$discountDays = [int][System.Math]::Ceiling([double](([float]$sum)*$percent))
	for($i=0; $discountDays -gt 0 -and $i -lt 3; ++$i)
	{
		for($phaseIndex=0;$phaseIndex -lt $r.Length; ++$phaseIndex )
		{
			if( $phaseIndex -gt 0 -or $r[$phaseIndex] -gt 1 )
			{
				$r[$phaseIndex]--;
				$discountDays--;
			}
			if( $discountDays -le 0 )
			{
				return $r | select -first ($r.length-1)
			}
		}
	}
	return $r | select -first ($r.length-1)
}

function verify
{
	param($base,$percent,$actual,$name)
	
	write-host -nonewline "Testing $name at $percent"
	
	$expected = discount -percent $percent -phasedays $base.Stages
	
	$areEqual = @(Compare-Object $expected $actual.Stages -SyncWindow 0).Length -eq 0
	if($areEqual)
	{
		write-host " OK"
	}
	else
	{
		write-warning " Didn't match. Expected $expected got $($actual.Stages)"
	}
}

$namelookup = @{
	"Bean Starter"="Green Bean";
	"Jazz"="Blue Jazz";
	"Tulip Bulb"="Tulips";
	"Hops Starter"="Hops";
	"Pepper"="Hot Pepper";
	"Spangle"="Summer Spangle";
	"Grape Starter"="Grape";
	"Fairy"="Fairy Rose";
	"Rare Seed"="Sweet Gem Berry";
	"Ancient"="Ancient Fruit";
}

$names = @{}

gc names.txt | %{
	$data = ($_ -split "/" | select -first 1 ) -split """"
	$id = $data[0].Trim(@(" ",":"))
	$name = $data[1] -replace " Seeds",""
	if($namelookup.ContainsKey($name))
	{
		$name = $namelookup[$name]
	}
	$names.Add($id,$name);
}

$crops = gc rawdata.txt | %{
	$data = ($_ -split "/" | select -first 1 ) -split """"
	$id = $data[0].Trim(@(" ",":"))
	$name = $names[$id]
	$stages = $data[1] -split " "
	new-object psobject -Property @{ "Name"=$name; "Stages"=$stages }
}

$crops |out-host
$d = gc "$PSScriptRoot\data.csv"
$i = 1
while( $i -lt $d.length )
{
	$name = $d[$i] -split "," | select -first 1
	$base = $d[$i] | splt
	
	$currentcrop = $crops | ?{ $_.Name -eq $name }
	if( $currentcrop -eq $null )
	{
		throw "cant find $name"
	}
	
	$areEqual = @(Compare-Object $base.stages $currentcrop.Stages -SyncWindow 0).Length -eq 0
	if(!$areEqual)
	{
		throw "bad data for $name, was $($base.stages) expected $($currentcrop.stages)"
	}

	verify -base $base -percent 0.1 -actual ($d[$i+1]|splt) -name $name
	verify -base $base -percent 0.2 -actual ($d[$i+2]|splt) -name $name
	verify -base $base -percent 0.25 -actual ($d[$i+3]|splt) -name $name
	verify -base $base -percent 0.35 -actual ($d[$i+4]|splt) -name $name
	$i+=5
}

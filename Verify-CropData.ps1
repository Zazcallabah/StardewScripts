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
	param($percent,$phasedays)
	if($percent -gt 1 )
	{
		$percent = $percent /100;
	}
	$r = @()
	$phasedays | %{ $r+=[int]$_ }
	$sum = $phasedays | select -first ($phasedays.length-1) | measure -Sum |select -expandproperty sum
	$discountDays = [System.Math]::Ceiling($sum*$percent)
	for($i=0; $discountDays -gt 0 -and $i -lt 3; ++$i)
	{
		for($phaseIndex=0;$phaseIndex -lt $r.Length; ++$phaseIndex )
		{
			if( $phaseIndex -gt 0 -or $r[$phaseIndex] -gt 1 )
			{
				$r[$phaseIndex]--;
				$discountDays--;
				if( $discountDays -le 0 )
				{
					return $r
				}
			}
		}
	}
	return $r
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

$d = gc "$PSScriptRoot\data.csv"
$i = 1
while( $i -lt $d.length )
{
	$name = $d[$i] -split "," | select -first 1
	$base = $d[$i] | splt
	
	verify -base $base -percent 0.1 -actual ($d[$i+1]|splt) -name $name
	verify -base $base -percent 0.2 -actual ($d[$i+2]|splt) -name $name
	verify -base $base -percent 0.25 -actual ($d[$i+3]|splt) -name $name
	verify -base $base -percent 0.35 -actual ($d[$i+4]|splt) -name $name
	$i+=5
}

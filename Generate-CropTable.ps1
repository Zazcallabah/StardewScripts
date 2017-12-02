param($header,$crop,$interval,$stages)

$result = "{| class=""wikitable mw-collapsible"" style=""text-align:center;"" id=""roundedborder""`n!colspan=""7""|$header`n"
$result += "|-`n!Mon`n!Tue`n!Wed`n!Thu`n!Fri`n!Sat`n!Sun`n"


if( $stages -eq $null )
{
	throw "missing parameter"
}


function ConvertStagesToIndexed
{
	param($stages)
	$ix=0
	$stages | %{ $ix++;@($ix)*$_ }
}

$indexedStages = ConvertStagesToIndexed $stages
function ImageForIndex
{
	param($index,$crop,$indexedStages,$interval,$endstage,$single)
	$istruefirst = $index -eq 0
	if($interval -eq 0)
	{
		$index = $index % $indexedStages.Length
	}
	
	if( $index -lt $indexedStages.Length )
	{
		if( !$istruefirst -and $index -eq 0 )
		{
			return "$single.png"
		}
		else 
		{
			return "$crop Stage $($indexedStages[$index]).png"
		}
	}
	$harvest = ($index-$indexedStages.Length) % $interval -eq 0
	
	if( $harvest )
	{
		return "$single.png"
	}
	else
	{
		return "$crop Stage $endstage.png"
	}
}

$cropNameLookup =@{
	"Coffee Bean" = "Coffee";
	"Tulips" = "Tulip";
	"Summer Sprangles" = "Summer Sprangle"
}

$singularLookup = @{
	"Cranberry"="Cranberries";
	"Tulips" = "Tulip";
	"Summer Spangles" = "Summer Spangle"
}

$cropName = $crop
$single = $crop

if( $singularLookup.ContainsKey($crop) )
{
	$single=$singularLookup[$crop]
}
if( $cropNameLookup.ContainsKey($crop) )
{
	$cropName=$cropNameLookup[$crop]
}


0..3 | %{
	$week = $_
	$result += "|-`n"
	0..6 | %{
		$dayofweek = $_
		$index = ($week*7)+$dayofweek

		$linkname = ImageForIndex -index $index -crop $cropName -indexedStages $indexedStages -interval $interval -endstage ($stages.Length+2) -single $single
		$result += "|[[File:$($linkname)|center|link=]]`n"
	}
}
$result += "|}`n"
$result



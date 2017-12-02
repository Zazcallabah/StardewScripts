# StardewScripts

Example
-------

    $c = gc crops.txt
    $s = ""
    $c|%{
        $t = .\Build-Tables.ps1 -crop $_
        $s += "`n==$($_)==`n$t`n"
    }
    $s | clip


Sources
-------

* https://docs.google.com/spreadsheets/d/16vjeFnexYJ4n2Ib_nA9JubB6mvUcJanf9zu0SjpvPSI/edit

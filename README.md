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

Did you know?
-------------

    $> [float]10*[float]0.1
    1.00000001490116

Sources
-------

* https://docs.google.com/spreadsheets/d/16vjeFnexYJ4n2Ib_nA9JubB6mvUcJanf9zu0SjpvPSI/edit
* Decompiled SV source

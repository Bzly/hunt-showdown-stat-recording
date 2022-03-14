# Returns Steam install dir as directory object
function Get-SteamDirectory {
    try {
        if ([Environment]::Is64BitOperatingSystem) {
            $p = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Wow6432Node\Valve\Steam -Name InstallPath
        } else {
            $p = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Valve\Steam -Name InstallPath
        }
    } catch {
        throw "No Steam install found in registry. Aborting..."
    }
    return Get-Item -Path $p
}

# Gets last logged in Steam display name
function Get-SteamName {
    return Get-ItemPropertyValue -Path HKCU:\SOFTWARE\Valve\Steam -Name LastGameNameUsed
}

# Given the name of a key and a .vcf or .acf file, will return the value(s) of that key - so can be array!
# Note does not perform much checking, so you could actually pass an exact value and get a weird result. 
# Don't do that, and I hope your game isn't called 'installdir'. 
function Get-ValueFromValveFile {
    param (
		[Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
		[string]$Key
	)
    $t = Get-Content -Path $Path | Select-String """$Key"""
    return $t | % {$_ -replace ('\s+"' + [regex]::escape($Key) + '"\s+"(.*?)"'),'$1'}
}

# Returns Steam Library dirs as array of directory objects
# Presumably run like: Get-SteamLibraries -SteamDir (Get-SteamDirectory)
function Get-SteamLibraries {
    param (
		[Parameter(Mandatory=$true)]
		[string]$SteamDir
	)
    [string[]]$SteamLibs = Get-ValueFromValveFile -Path "$SteamDir\steamapps\libraryfolders.vdf" -Key "path"
    # Return as array of directory objects. Assumes all drives in libraryfolders.vdf are available.
    # Hope you don't have any libraries on removable drives :s
    return $SteamLibs | Get-Item
}

# Returns a Steam app install dir as directory object
function Get-SteamAppDirectory {
    param (
		[Parameter(Mandatory=$true)]
		[string]$AppID
	)
    $SteamLibs = Get-SteamLibraries -SteamDir (Get-SteamDirectory)
    foreach ($lib in $SteamLibs) {
        $TestPath = "$lib\steamapps\appmanifest_$AppID.acf"
        if (Test-Path $TestPath) {
            $inst = Get-ValueFromValveFile -Path $TestPath -Key "installdir"
            return Get-Item -Path "$lib\steamapps\common\$inst"
        }
    }
    throw "AppID not detected in Steam library folders. 'appmanifest_$AppID.acf' not found. Is the software installed properly?"
}

# Returns an array of XmlElements from Hunt's "attributes.xml"
function Get-HuntAttributes {
    $HuntDir = Get-SteamAppDirectory -AppID 594650
    [xml]$x = Get-Content -Path "$HuntDir\user\profiles\default\attributes.xml"
    return $x.Attributes.Attr
}

# Function to convert the useful bits of information from Hunt's attributes.xml to 
# 	a sensible data structure in JSON
# Currently this function returns only team and player information. It's a first draft. 
# Other keys to look at: MissionBagIsQuickPlay, MissionBagIsHunterDead, MissionBagNumAccolades, 
# 	MissionBagNumEntries, last_given_gift_mission_counter(?)
# In MissionBagEntry attr, is "_reward" value the type? 
	# 0 = Bounty
	# 2 = XP
	# 4 = gold
	# 12 = bloodline xp
	# 11 = upgrade points
	# 8 = (christmas?) event points
function ConvertFrom-HuntAttributes {
    $Attr = Get-HuntAttributes
    [int]$NumTeams = ($Attr | Where-Object {$_.name -eq "MissionBagNumTeams"}).value

    # Populate team data
    # Feels like there's probably a smart, recursive way to do this... but it's 4AM
    $TeamData = @()
    foreach ($i in 0..($NumTeams-1)) {
        $tp = "MissionBagTeam_$($i)_" 													# prefix for current team
        $td = $Attr | Where-Object {$_.name -like "$tp*"} 								# all Attr elements belonging to team
        $t = HuntAddKeys -Attributes $td -Dict ([ordered]@{"id" = $i}) -ReplaceStr $tp 	# create individual team

        # Populate player data
        $PlayerData = @()
        foreach ($j in 0..($t.numplayers-1)) {
            $pp = "MissionBagPlayer_$($i)_$($j)_" 										# prefix for current player
            $pd = $Attr | Where-Object {$_.name -like "$pp*"}							# all Attr elements belonging to player
            $PlayerData += HuntAddKeys -Attributes $pd `
				-Dict ([ordered]@{"id" = $j}) -ReplaceStr $pp							# create and add individual player
        }

        $t.players = $PlayerData
        $TeamData += $t
    }
    return $TeamData | ConvertTo-Json -Depth 100
}

# Loops through array of XML attributes, removes the prefix used, and adds them to an ordered dictionary
# Also performs type conversions for a set list of keys (to int), and for true/false values
# Helper function, not exported
function HuntAddKeys {
    param (
		[Parameter(Mandatory=$true)]
        [array]$Attributes, #td
        [Parameter(Mandatory=$false)]
		[System.Collections.Specialized.OrderedDictionary]$Dict = [ordered]@{},
        [Parameter(Mandatory=$true)]
		[string]$ReplaceStr
	)
    $NumericKeys = @("mmr", "numplayers", "handicap", "profileid", "killedbyme", "killedme")
    $Attributes | % {
        $key = $_.name -replace "$ReplaceStr"
        if ($key -in $NumericKeys) {
            $Dict[$key] = [Int64]$_.value # profileid > [int]::MaxValue, so use long
        } elseif ($_.value -in @("true", "false")) {
			$Dict[$key] = [System.Convert]::ToBoolean($_.value)
		} else {
            $Dict[$key] = $_.value
        }
    }
    return $Dict
}

Export-ModuleMember *-*
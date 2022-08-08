
# Hunt: Showdown Stat Recording
Tools to get statistics from your last Hunt match, with the goal of eventually watching for changes and recording the data after every match.

Written in PowerShell. 

## What
Scraping `$HuntInstallDirectory\user\profiles\default\attributes.xml` for information after every game. I don't know why they're using XML when the structure is entirely flat; this could be easier. I also don't know why some data is stored in there at all (icon paths, etc). 

Currently provides the following functions:
* Hunt:
  - **`ConvertFrom-HuntAttributes`** - parses the above and returns the JSON output below (or as an ordered dict if passed `-Object`)
  - **`Get-HuntAllMmr`** - returns a list of teams and players in the game and their MMR.
  - **`Get-HuntTeamMmr`** - returns a list of only the players on your team and their MMR. 
  - `Get-HuntAttributes` - returns an array of XmlElements from attributes.xml. Only useful if you want the raw data for some reason.
  - 2x helper functions which are not exported
* Steam:
  - `Get-SteamDirectory` - returns Steam install dir as directory object
  - `Get-SteamName` - returns last logged in Steam display name
  - `Get-ValueFromValveFile` - returns the value of a specific key from an .vcf or .acf
  - `Get-SteamLibraries` - returns an array of your Steam library folders as directory objects
  - `Get-SteamAppDirectory` - returns the install dir of a specific Steam AppID as a directory object

## How
1. Download `HuntToolkit.psm1` 
2. Import the module into your Powershell session
  a. If stored in an $env:PSModulePath location it will automatically import
  b. If storing somewhere else, either:
    * call `Import-Module "path\to\module\HuntToolkit.psm1"` before every run
    * add the above command to your Powershell profile (location is stored as $profile) and relaunch
3. Run `ConvertFrom-HuntAttributes`, and enjoy your JSON.


## To-do
* Complete `ConvertFrom-HuntAttributes`:
  - Include real number of revives
  - Add number of bounty tokens extracted
  - Add clues discovered
  - Work out how to tell match length
  - Find out more `MissionBagEntry_<i>_reward` types (including Blood Bonds)
  - Fix XP received calculation (but this is quite obtuse)
    * Validate current methods
* Function to write the data to storage
  - As an array of JSON objects, each representing a match (?)
* Function to monitor attributes.xml for changes
  - Possibly using [FileSystemWatcher](https://docs.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=net-5.0) 'Changed' events
* Function to check whether the match data has changed (file is updated more frequently than after every match)
  - How do we do this? Check to see if a bunch of values are the same?
* ~~Function to get the game install directory (using `$SteamInstallDir\steamapps\libraryfolders.vdf`?)~~
* Maybe something to plot a couple of quick graphs (MMR distribution of players in last match, your MMR over time, etc)

## Current data structure
The output of `ConvertFrom-HuntAttributes`, when run without the `-Object` flag, is rendered into JSON like so:
```json
{
  "playedas": "Blankedy Blank",
  "isquickplay": false,
  "rewards": {
    "bounty": 50,
    "xp": 3390,
    "money": 50,
    "bloodbonds": 0
  },
  "performance": {
    "kills": 2,
    "deaths": 2,
    "assists": 1,
    "revives": 69,
    "survived": true
  },
  "teams": [
    {
      "id": 0,
      "handicap": 0,
      "isinvite": true,
      "mmr": 2912,
      "numplayers": 3,
      "ownteam": false,
      "players": [
        {
          "id": 0,
          "blood_line_name": "Crusade",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2954,
          "profileid": 64424591974,
          "proximity": false,
          "skillbased": true
        },
        {
          "id": 1,
          "blood_line_name": "Cheroro",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2798,
          "profileid": 4295076022,
          "proximity": false,
          "skillbased": true
        },
        {
          "id": 2,
          "blood_line_name": "Lime Sherbert",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2950,
          "profileid": 21474911436,
          "proximity": false,
          "skillbased": true
        }
      ]
    },
    {
      "id": 1,
      "handicap": 0,
      "isinvite": true,
      "mmr": 2889,
      "numplayers": 3,
      "ownteam": false,
      "players": [
        {
          "id": 0,
          "blood_line_name": "Commander Xao",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2806,
          "profileid": 73014527508,
          "proximity": false,
          "skillbased": true
        },
        {
          "id": 1,
          "blood_line_name": "Shuua",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 1,
          "killedme": 0,
          "mmr": 2975,
          "profileid": 38654774043,
          "proximity": false,
          "skillbased": true
        },
        {
          "id": 2,
          "blood_line_name": "Gameaffobic",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 1,
          "mmr": 2848,
          "profileid": 34359747876,
          "proximity": false,
          "skillbased": true
        }
      ]
    },
    {
      "id": 2,
      "handicap": 0,
      "isinvite": true,
      "mmr": 2864,
      "numplayers": 3,
      "ownteam": true,
      "players": [
        {
          "id": 0,
          "blood_line_name": "Blankedy Blank",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2958,
          "profileid": 64424560816,
          "proximity": true,
          "skillbased": true
        },
        {
          "id": 1,
          "blood_line_name": "DashRendar",
          "hadWellspring": false,
          "hadbounty": true,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2772,
          "profileid": 17179947497,
          "proximity": false,
          "skillbased": true
        },
        {
          "id": 2,
          "blood_line_name": "Daario",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2816,
          "profileid": 81604489802,
          "proximity": false,
          "skillbased": true
        }
      ]
    },
    {
      "id": 3,
      "handicap": 0,
      "isinvite": true,
      "mmr": 2967,
      "numplayers": 3,
      "ownteam": false,
      "players": [
        {
          "id": 0,
          "blood_line_name": "[BB] uzi_01",
          "hadWellspring": false,
          "hadbounty": true,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2984,
          "profileid": 47244642844,
          "proximity": false,
          "skillbased": false
        },
        {
          "id": 1,
          "blood_line_name": "死亡! ($DBY$)",
          "hadWellspring": false,
          "hadbounty": false,
          "killedbyme": 1,
          "killedme": 1,
          "mmr": 2994,
          "profileid": 17179973327,
          "proximity": false,
          "skillbased": false
        },
        {
          "id": 2,
          "blood_line_name": "[BB] Fiddler Kid Diddler",
          "hadWellspring": false,
          "hadbounty": true,
          "killedbyme": 0,
          "killedme": 0,
          "mmr": 2917,
          "profileid": 77309435674,
          "proximity": false,
          "skillbased": false
        }
      ]
    }
  ]
}
```

## Example data structure
```json
[
  {
    matchTime: "2021-09-07T00:02:48+00:00",   #can only be calculated when watching file for changes(?)
    matchNumber: 247,                         #can only be calculated when writing to a store(?)
    bosses: {
      butcher: {
        present: true,
        kill: true,
        banish: true,
        extract: false,
      },
      spider: {...},
      assassin: {...},
      scrapbeak: {...},
    },
    ...(rest of the current structure)...
  }
]
```

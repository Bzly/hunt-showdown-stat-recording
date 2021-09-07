# Hunt: Showdown Stat Recording
Tools to get statistics from your last Hunt match, with the goal of eventually watching for changes and recording the data after every match.

Written in PowerShell. 

## How
Scraping `$HuntInstallDirectory\user\profiles\default\attributes.xml` for information after every game. I don't know why they're using XML when the structure is entirely flat; this could be easier. 

## To-do
* Finish rough draft of schema
* Main function to return the data in a sensible way. JSON?
  - How do we tell who the player is? We can easily tell what team they're on, but not who they are. Does it matter?
  - How do we tell who is on which team?
* Function to write the data
* Function to check whether the match data has changed (file is updated more frequently than after every match)
  - How do we do this? There is no match identifier AFAICT. Just check to see if all player IDs are the same?
* Function to use [FileSystemWatcher](https://docs.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=net-5.0) 'Changed' events to monitor the file for changes
* Function to get the game install directory (using `$SteamInstallDir\steamapps\libraryfolders.vdf`?)
* Maybe something to plot a couple of quick graphs (MMR distribution of players in last match, your MMR over time, etc)

## Example data structure
```json
[
  {
    matchTime: "2021-09-07T00:02:48+00:00",   #can only be calculated when watching file for changes(?)
    matchNumber: 247,                         #can only be calculated when writing to a store(?)
    bosses: {
      butcher: {
        kill: true,
        banish: true,
        extract: false,
      },
      spider: {...},
      assassin: {...},
      scrapbeak: {...},
    },
    rewards: {
      xp: 1234,
      money: 5678,
    },
    performance: {
      kills: 3,
      assists: 1,
      deaths: 1,
      revives: 2,
      survived: true,
    },
    teams: {
      team1: {
        mmr: 2850,
        handicap: 0,
        isInvite: true,
        isOwnTeam: false,
        players: {
          player1: {
            id: 27324541310,
            name: "Blankedy Blank",
            mmr: 2900
            hadBounty: true,
            killedByMe: false,
            killedMe: true,
          },
          player2: {...},
        },
        team2: {...},
      },
    },
  },
  {
    ...
  },
]
```

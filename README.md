# Hunt: Showdown Stat Recording
Tools to get statistics from your last Hunt match, with the goal of eventually watching for changes and recording the data after every match.

Written in PowerShell. 

## How
Scraping `$HuntInstallDirectory\user\profiles\default\attributes.xml` for information after every game. I don't know why they're using XML when the structure is entirely flat; this could be easier. 

## To-do
* Finish rough draft of schema
* Main function to return the data in a sensible way. JSON?
* Function to write the data
* Function to check whether the match data has changed (file is updated more frequently than after every match)
  - How do we do this? There is no match identifier AFAICT. Just check to see if all player IDs are the same?
* Function to use [FileSystemWatcher](https://docs.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=net-5.0) 'Changed' events to monitor the file for changes
* Maybe something to plot a couple of quick graphs (MMR distribution of players in last match, your MMR over time, etc)

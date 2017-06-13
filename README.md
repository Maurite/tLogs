# tLogs
Simple Logging system to keep an eye on your players.

**Features**

Overall
```
A file per Log (Combat.log, Actions.log..) to keep it clean
Separated by dates, if day changes, there will be a date separator for better log checking
HH:MM:SS timestamp on every log
```
Combat Logs
```
Logs the damage issued from player to other players, the bodypart and the weapon used
Logs the damage issued from player to vehicles and the weapon used
Logs the damage taken by player and the reason
Logs deaths
```
Actions Logs
```
Logs player change of state (drivig to on foot, spectating to driving)
Logs player's interior change
Logs player entering/exiting mod shop
Logs player's clicks on map and the coordinates
Logs players clicks on players through the scoreboard
```
Chat Logs
```
Logs all messages
Logs all commands issued
```
Connection Logs
```
Logs connections
Logs disconnections and the reason (kick, timeout, exit)
```


**How to use**

```
- Open the tLogs.pwn file and compile it in your filterscript folder.
- Add the following to the filterscript line in your server.cfg file
tLogs
- Start your server.
```

**How to configure**

```
- Uncomment the line #define FILEPATH "/folder/" to use a custom folder inside the scriptfiles folder.
```

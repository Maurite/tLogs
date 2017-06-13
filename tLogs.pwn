/*
	Troydere made this out of his ballsack.
	I'm from Venezuela. We clean our assholes with copyright so you can do pretty much what you want with this script.
		
	Disclaiming is gay aswell.
*/

#include <a_samp>

#define FILTERSCRIPT
#if defined FILTERSCRIPT

//#define FILEPPATH "/folder/" // Uncomment this if you want the files to be in other folder inside the scriptfiles folder. (replace folder with the folder's name. The folder MUST exist.)

new File:chat, File:actions, File:connection, File:combat, pName[MAX_PLAYERS][MAX_PLAYER_NAME],currentday;

public OnFilterScriptInit()
{
	printf("[tLogs] Script initialized correctly. This session is being recorded.");

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		GetPlayerName(i,pName[i],MAX_PLAYER_NAME);
	}
	
	#if defined FILEPATH
	
	connection = fopen(FILEPATH"Connection.log",io_append);
	actions = fopen(FILEPATH"Actions.log",io_append);
	combat = fopen(FILEPATH"Combat.log",io_append);
	chat = fopen(FILEPATH"Chat.log",io_append);
	
	#else
	
	connection = fopen("Connection.log",io_append);
	actions = fopen("Actions.log",io_append);
	combat = fopen("Combat.log",io_append);
	chat = fopen("Chat.log",io_append);
	
	#endif
	
	DayCheck();
	return 1;
}

public OnFilterScriptExit()
{
	printf("[tLogs] This session is no longer being recorded.");
	fclose(connection);
	fclose(actions);
	fclose(combat);
	fclose(chat);
	return 1;
}

// Utils

forward DayCheck();
public DayCheck()
{
	new iYear,iMonth,iDay;
	getdate(iYear,iMonth,iDay);
	if(iDay != currentday)
	{
		new sDate[50],sMonth[14];
		switch(iMonth)
		{
			case 1: sMonth = "January";
			case 2: sMonth = "February";
			case 3: sMonth = "March";
			case 4: sMonth = "April";
			case 5: sMonth = "May";
			case 6: sMonth = "June";
			case 7: sMonth = "July";
			case 8: sMonth = "August";
			case 9: sMonth = "September";
			case 10: sMonth = "October";
			case 11: sMonth = "November";
			case 12: sMonth = "December";
		}
		format(sDate, sizeof sDate,"~~~~~~~ [ DATE : %s %d %d ] ~~~~~~~ \r\n",sMonth,iDay,iYear);
		fwrite(connection,sDate);
		fwrite(actions,sDate);
		fwrite(combat,sDate);
		fwrite(chat,sDate);
		currentday = iDay;
	}
	
	fclose(connection);
	fclose(actions);
	fclose(combat);
	fclose(chat);
	
	#if defined FILEPATH
	
	connection = fopen(FILEPATH"Connection.log",io_append);
	actions = fopen(FILEPATH"Actions.log",io_append);
	combat = fopen(FILEPATH"Combat.log",io_append);
	chat = fopen(FILEPATH"Chat.log",io_append);
	
	#else
	
	connection = fopen("Connection.log",io_append);
	actions = fopen("Actions.log",io_append);
	combat = fopen("Combat.log",io_append);
	chat = fopen("Chat.log",io_append);
	
	#endif
	
	return SetTimer("DayCheck",10 * 60000,false);
}


TimeStamp()
{
	new sTime[9], iH, iM, iS;
	gettime(iH,iM,iS);
	format(sTime,sizeof sTime,"%d:%d:%d",iH,iM,iS);
	return sTime;
}

PlayerState(stateid)
{
	new sState[27];
	switch(stateid)
	{
		case 0: sState = "none";
		case 1:	sState = "on foot";
		case 2:	sState = "the driver of a vehicle";
		case 3:	sState = "passenger of a vehicle";
		case 7:	sState = "dead or on class selection";
		case 8:	sState = "spawned";
		case 9:	sState = "spectating";
	}
	return sState;
}
// ----------------------------

// Connection Logs
public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid,pName[playerid],MAX_PLAYER_NAME);
	if(IsPlayerNPC(playerid)) return 1;
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) logged in .\r\n",TimeStamp(),pName[playerid],playerid);
	fwrite(connection,sLog);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerNPC(playerid)) return 1;
	new sReason[14];
	switch(reason)
	{
		case 0:	sReason = "Timeout/Crash";
		case 1:	sReason = "Quit";
		case 2:	sReason = "Kick/Ban";
	}
	
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) logged out. Reason: %s .\r\n",TimeStamp(),pName[playerid],playerid,sReason);
	fwrite(connection,sLog);

	return 1;	
}
// ----------------------------

// Combat Logs
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(weaponid >= 22 && weaponid <=38)
	{
		if(hittype == BULLET_HIT_TYPE_VEHICLE)
		{
			if(IsPlayerConnected(hitid))
			{
				new sLog[156];
				format(sLog,sizeof sLog,"[%s] %s(%d) damaged vehicle id (%d) with weapon id (%d) .\r\n",TimeStamp(),pName[playerid],playerid,hitid,weaponid);
				fwrite(combat,sLog);
			}
		}
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	new sPart[10];
	switch(bodypart)
	{
		case 3: sPart = "Chest";
		case 4: sPart = "Groin";
		case 5: sPart = "Left arm";
		case 6: sPart = "Right arm";
		case 7: sPart = "Left leg";
		case 8: sPart = "Right leg";
		case 9: sPart = "Head";
		default: sPart = "Unknown";
	}
	
	if(issuerid != INVALID_PLAYER_ID)
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) damaged %s(%d) with weapon id (%d) . Amount (%0.2f) . Bodypart: %s .\r\n",TimeStamp(),pName[issuerid],issuerid,pName[playerid],playerid,weaponid,sPart,amount);
		fwrite(combat,sLog);
	}
	else
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) took (%0.2f) of damage. Bodypart: %s . Reason ID: %d .\r\n",TimeStamp(),pName[playerid],playerid,amount,sPart,weaponid);
		fwrite(combat,sLog);		
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID)
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) killed %s(%d). Reason: %d .\r\n",TimeStamp(),pName[killerid],killerid,pName[playerid],playerid,reason);
		fwrite(combat,sLog);
	}
	else
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) died. Reason: %d .\r\n",TimeStamp(),pName[playerid],playerid,reason);
		fwrite(combat,sLog);
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) destroyed vehicle id (%d) .\r\n",TimeStamp(),pName[killerid],killerid,vehicleid);
		fwrite(combat,sLog);	
	}
	return 1;
}
// ----------------------------

// Chat Logs
public OnPlayerText(playerid, text[])
{
	if(IsPlayerNPC(playerid)) return 1;
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d): %s\r\n",TimeStamp(),pName[playerid],playerid,text);
	fwrite(chat,sLog);		
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(IsPlayerNPC(playerid)) return 1;
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) issued command: %s .\r\n",TimeStamp(),pName[playerid],playerid,cmdtext);
	fwrite(chat,sLog);		
	return 0;
}
// ----------------------------

// Actions Logs

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(IsPlayerNPC(playerid)) return 1;
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) changed from state %s to state %s .\r\n",TimeStamp(),pName[playerid],playerid,PlayerState(oldstate),PlayerState(newstate));
	fwrite(actions,sLog);	
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) changed from interior %d to interior %d .\r\n",TimeStamp(),pName[playerid],playerid,oldinteriorid,newinteriorid);
	fwrite(actions,sLog);	
	return 1;
}

public OnEnterExitModShop(playerid, enterexit, interiorid)
{
	new sLog[156],sEnterExit[6];
	switch(enterexit)
	{
		case 1: sEnterExit = "enter";
		case 0: sEnterExit = "exit";
	}
	
	format(sLog,sizeof sLog,"[%s] %s(%d) %sed to/from mod shop interior %d .\r\n",TimeStamp(),pName[playerid],playerid,sEnterExit,interiorid);
	fwrite(actions,sLog);	
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) clicked their map at coordinates X:%0.4f Y:%0.4f Z:0.4f .\r\n",TimeStamp(),pName[playerid],playerid,fX,fY,fZ);
	fwrite(actions,sLog);	
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) clicked player %s(%d) on the scoreboard .\r\n",TimeStamp(),pName[playerid],playerid,pName[clickedplayerid],clickedplayerid);
	fwrite(actions,sLog);	
	return 1;
}
// ----------------------------

#endif 
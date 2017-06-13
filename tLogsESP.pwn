/*
	Troydere creó esto de sus bolas.
	Soy de Venezuela. Aquí nos limpiamos el culo con el copyright así que puedes hacer lo que gustes con este script.
		
*/

#include <a_samp>

#define FILTERSCRIPT
#if defined FILTERSCRIPT

//#define CARPETA "/carpeta/" // Descomenta esto si quieres que los logs estén en otra carpeta dentro de la carpeta scriptfiles. (reemplaza el nombre capera por el que desees. La carpeta debe existir primero.)

new File:chat, File:actions, File:connection, File:combat, pName[MAX_PLAYERS][MAX_PLAYER_NAME],currentday;

public OnFilterScriptInit()
{
	printf("[tLogs] El script inicializó correctamente. Esta sesión está siendo monitoreada.");

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		GetPlayerName(i,pName[i],MAX_PLAYER_NAME);
	}
	
	#if defined CARPETA
	
	connection = fopen(CARPETA"Conexion.log",io_append);
	actions = fopen(CARPETA"Acciones.log",io_append);
	combat = fopen(CARPETA"Combate.log",io_append);
	chat = fopen(CARPETA"Chat.log",io_append);
	
	#else
	
	connection = fopen("Conexion.log",io_append);
	actions = fopen("Acciones.log",io_append);
	combat = fopen("Combate.log",io_append);
	chat = fopen("Chat.log",io_append);
	
	#endif
	
	DayCheck();
	return 1;
}

public OnFilterScriptExit()
{
	printf("[tLogs] Esta sesión ya no está siendo monitoreada.");
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
			case 1: sMonth = "Enero";
			case 2: sMonth = "Febrero";
			case 3: sMonth = "Marzo";
			case 4: sMonth = "Abril";
			case 5: sMonth = "Mayo";
			case 6: sMonth = "Junio";
			case 7: sMonth = "Julio";
			case 8: sMonth = "Agosto";
			case 9: sMonth = "Septiembre";
			case 10: sMonth = "Octubre";
			case 11: sMonth = "Noviembre";
			case 12: sMonth = "Diciembre";
		}
		format(sDate, sizeof sDate,"~~~~~~~ [ FECHA : %s %d %d ] ~~~~~~~ \r\n",sMonth,iDay,iYear);
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
	
	#if defined CARPETA
	
	connection = fopen(CARPETA"Conexion.log",io_append);
	actions = fopen(CARPETA"Acciones.log",io_append);
	combat = fopen(CARPETA"Combate.log",io_append);
	chat = fopen(CARPETA"Chat.log",io_append);
	
	#else
	
	connection = fopen("Conexion.log",io_append);
	actions = fopen("Acciones.log",io_append);
	combat = fopen("Combate.log",io_append);
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
	new sState[35];
	switch(stateid)
	{
		case 0: sState = "ninguno";
		case 1:	sState = "a pie";
		case 2:	sState = "conductor de un vehiculo";
		case 3:	sState = "pasajero de un vehiculo";
		case 7:	sState = "muerto o en la selección de clase";
		case 8:	sState = "spawneado";
		case 9:	sState = "espectando";
	}
	return sState;
}
// ----------------------------

// Connection Logs
public OnPlayerConnect(playerid)
{
	new pIP[16];
	GetPlayerName(playerid,pName[playerid],MAX_PLAYER_NAME);
	GetPlayerIp(playerid,pIP,16);
	if(IsPlayerNPC(playerid)) return 1;
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) ha conectado. IP %s .\r\n",TimeStamp(),pName[playerid],playerid,pIP);
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
		case 1:	sReason = "Salió";
		case 2:	sReason = "Kick/Ban";
	}
	
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) se ha desconectado. Razón: %s .\r\n",TimeStamp(),pName[playerid],playerid,sReason);
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
				format(sLog,sizeof sLog,"[%s] %s(%d) dañó el vehiculo id (%d) con el arma id (%d) .\r\n",TimeStamp(),pName[playerid],playerid,hitid,weaponid);
				fwrite(combat,sLog);
			}
		}
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	new sPart[20];
	switch(bodypart)
	{
		case 3: sPart = "Pecho";
		case 4: sPart = "Entrepierna";
		case 5: sPart = "Brazo izquierdo";
		case 6: sPart = "Brazo derecho";
		case 7: sPart = "Pierna izquierda";
		case 8: sPart = "Pierna derecha";
		case 9: sPart = "Cabeza";
		default: sPart = "Desconocido";
	}
	
	if(issuerid != INVALID_PLAYER_ID)
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) dañó a %s(%d) con el arma id (%d) . Daño (%0.2f) . Parte del Cuerpo: %s .\r\n",TimeStamp(),pName[issuerid],issuerid,pName[playerid],playerid,weaponid,sPart,amount);
		fwrite(combat,sLog);
	}
	else
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) tomó (%0.2f) de daño. Parte del Cuerpo: %s . Razón ID: %d .\r\n",TimeStamp(),pName[playerid],playerid,amount,sPart,weaponid);
		fwrite(combat,sLog);		
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID)
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) mató a %s(%d). Razón: %d .\r\n",TimeStamp(),pName[killerid],killerid,pName[playerid],playerid,reason);
		fwrite(combat,sLog);
	}
	else
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) murió. Razón: %d .\r\n",TimeStamp(),pName[playerid],playerid,reason);
		fwrite(combat,sLog);
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
	{
		new sLog[156];
		format(sLog,sizeof sLog,"[%s] %s(%d) destruyó el vehiculo id (%d) .\r\n",TimeStamp(),pName[killerid],killerid,vehicleid);
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
	format(sLog,sizeof sLog,"[%s] %s(%d) ejecutó el comando: %s .\r\n",TimeStamp(),pName[playerid],playerid,cmdtext);
	fwrite(chat,sLog);		
	return 0;
}
// ----------------------------

// Actions Logs

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(IsPlayerNPC(playerid)) return 1;
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) cambió del estado %s al estado %s .\r\n",TimeStamp(),pName[playerid],playerid,PlayerState(oldstate),PlayerState(newstate));
	fwrite(actions,sLog);	
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) cambió del interior %d al interior %d .\r\n",TimeStamp(),pName[playerid],playerid,oldinteriorid,newinteriorid);
	fwrite(actions,sLog);	
	return 1;
}

public OnEnterExitModShop(playerid, enterexit, interiorid)
{
	new sLog[156],sEnterExit[8];
	switch(enterexit)
	{
		case 1: sEnterExit = "entró";
		case 0: sEnterExit = "salió";
	}
	
	format(sLog,sizeof sLog,"[%s] %s(%d) %s a/de un mod shop interior %d .\r\n",TimeStamp(),pName[playerid],playerid,sEnterExit,interiorid);
	fwrite(actions,sLog);	
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) clickeó su mapa en las coordenadas X:%0.4f Y:%0.4f Z:0.4f .\r\n",TimeStamp(),pName[playerid],playerid,fX,fY,fZ);
	fwrite(actions,sLog);	
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new sLog[156];
	format(sLog,sizeof sLog,"[%s] %s(%d) clickeó al jugador %s(%d) en la tabla de scores .\r\n",TimeStamp(),pName[playerid],playerid,pName[clickedplayerid],clickedplayerid);
	fwrite(actions,sLog);	
	return 1;
}
// ----------------------------

#endif 
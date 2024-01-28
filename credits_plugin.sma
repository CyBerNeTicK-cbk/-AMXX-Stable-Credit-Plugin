/*
*
*
* * * ***** ***** * ***** * * ***** * * * *
* * * * * * * * * * ** * * ** * * * *
* ****** ****** ****** * * ****** * * * * * * * * * * *
* * * * * ******* * * * * * * * * * * * *
* * * ***** ***** * * ***** * * ***** * * * *
*
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* AMX MOD X Script. *
* Plugin made by CyBer[N]eTicK *
  
  > ts.blackgames.ro
  > blackgames.ro/forum

* Important! You can modify the code, but DO NOT modify the author! *
* Contacts with me: *

* DISCORD: CyBer[N]eTicK#5615 - username cybernetick_cbk *
* STEAM: https://steamcommunity.com/client/CyBerNrcs/ *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Special thanks to: *
* - Askhanar [Ulquiorra] > Register Natives
* - Kidd0x - Indrumare salve pe Nvault si citarea flag-urilor.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*
*/


#include <amxmodx>

#include <amxmisc>

#include <nvault>



#if AMXX_VERSION_NUM < 190
    #error "[ CYBER ] :: This plugin was made on amxx version 190 and only on this goes compiled plugin."
#endif



new const PLUGIN_VERSION[]	=	"1.0"


#define ADMIN_ACCES ADMIN_LEVEL_H

new const szTag[]	=	"^4[Credits]^3"

new g_iCredits[33], g_iVault
new const credits_file_vault[]	=	"SaveCreditsVault"

public plugin_init()
{
	register_plugin("CYBER :: CREDITS PLUGIN STABLE", PLUGIN_VERSION, "CyBer[N]eTicK")
	register_cvar("cyber_credits", PLUGIN_VERSION, FCVAR_SERVER || FCVAR_SPONLY)

	register_concmd("amx_give_credits", "_CmdGiveCreditsPlayer", ADMIN_ACCES, "<player> <amount of credits>")
	register_concmd("amx_take_credits", "_CmdTakeCreditsPlayer", ADMIN_ACCES, "<player> <amount of credits>")
	register_concmd("amx_credits", "_CmdShowCredits", ADMIN_ALL, "<player name> ")

	register_clcmd("say", "hook_say")
	register_clcmd("say_team", "hook_say")

	g_iVault = nvault_open(credits_file_vault)
	if(g_iVault == INVALID_HANDLE)
	{
		server_print("ERROR: Something went wrong with saving credits")
	}
}

public hook_say(player)
{
	new szArgs[32], szArgsTwo[32]

	read_args(szArgs, 31)
	read_args(szArgsTwo, 31)

	remove_quotes(szArgs)
	remove_quotes(szArgsTwo)

	if(equali(szArgsTwo, "/credite", 8) || equali(szArgsTwo, "/credits", 8))
	{
		replace(szArgsTwo, 31, "/", "")
		client_print_color(player, print_team_blue, "%s Creditele tale sunt:^4 %i", szTag, g_iCredits[player])
	}

	if(equal(szArgs, "/credits", 8))
	{
		replace(szArgs, 31, "/", "")
		client_cmd(player, "amx_%s", szArgs)
	}
}

public _CmdShowCredits(player, level, cid)
{
	if(!cmd_access(player, level, cid, 2)) return PLUGIN_HANDLED

	new szNameArgv[32], szPlayerName[32], iPlayer

	read_argv(1, szNameArgv, 31)

	iPlayer = cmd_target(player, szNameArgv, (1<<0) | (1<<1) | (1<<3))

	get_user_name(iPlayer, szPlayerName, 31)

	if(!iPlayer)
	{
		console_print(player, "ERROR :: Jucatorul nu a fost gasit pe server, probabil nu e conectat, sau ai scris gresit numele.")
		return PLUGIN_HANDLED
	}

	if(equal(szNameArgv, ""))
	{
		console_print(player, "amx_credits <player name>")
		return PLUGIN_HANDLED
	}

	console_print(player, "Jucatorul %s, are [%i] de credite", szPlayerName, g_iCredits[iPlayer])
	client_print_color(player, print_team_red, "%s Jucatorul ^4%s^3 are: ^4%i^3 de credite", szTag, szPlayerName, g_iCredits[iPlayer])

	return PLUGIN_HANDLED
}

public _CmdGiveCreditsPlayer(player, level, cid)
{
	if(!cmd_access(player, level, cid, 2))	return PLUGIN_HANDLED

	new g_szNameArgv[32], g_iszAmountArgv[16], g_szPlayerName[32], g_szAdmiName[32], g_iClientCredits
	static g_szLogsMessage[256]

	read_argv(1, g_szNameArgv, 31)
	read_argv(2, g_iszAmountArgv, 15)

	new iPlayerTarget = cmd_target(player, g_szNameArgv, (1<<0) | (1<<1) | (1<<3))

	get_user_name(player, g_szPlayerName, 31)
	get_user_name(iPlayerTarget, g_szAdmiName, 31)

	if(equal(g_szNameArgv, "") || equal(g_iszAmountArgv, ""))
	{
		console_print(player, "ERROR :: amx_give_credits <player> <amount of credits>")
		return PLUGIN_HANDLED
	} 

	g_iClientCredits = str_to_num(g_iszAmountArgv)

	if(g_iClientCredits <= 0)
	{
		console_print(player, "ERROR :: Suma creditelor trebuie sa fie mai mare de cat '0'")
		return PLUGIN_HANDLED
	}

	if(!iPlayerTarget)
	{
		console_print(player, "ERROR :: Jucatorul nu a fost gasit pe server, probabil nu e conectat, sau ai scris gresit numele.")
		return PLUGIN_HANDLED
	}

	g_iCredits[iPlayerTarget] += str_to_num(g_iszAmountArgv)
	_SaveCredits(iPlayerTarget)

	client_print_color(0, print_team_blue, "%s Administratorul: ^4%s^3 i-a dat lui ^4[%s]^3 suma de credite:^4 %i", szTag, g_szAdmiName, g_szPlayerName, g_iClientCredits)

	formatex(g_szLogsMessage, charsmax(g_szLogsMessage), "ADMIN-ul: %s, i-a dat lui %s, suma de credite [%i]", g_szAdmiName, g_szPlayerName, g_iClientCredits)
	log_to_file("credits_logs.txt", g_szLogsMessage)

	return PLUGIN_HANDLED
}



public _CmdTakeCreditsPlayer(player, level, cid)
{
	if(!cmd_access(player, level, cid, 2))	return PLUGIN_HANDLED

	new g_szNameArgv[32], g_iszAmountArgv[16], g_szPlayerName[32], g_szAdmiName[32], g_iClientCredits
	static g_szLogsMessage[256]

	read_argv(1, g_szNameArgv, 31)
	read_argv(2, g_iszAmountArgv, 15)

	new iPlayerTarget = cmd_target(player, g_szNameArgv, (1<<0) | (1<<1) | (1<<3))

	get_user_name(player, g_szPlayerName, 31)
	get_user_name(iPlayerTarget, g_szAdmiName, 31)

	if(equal(g_szNameArgv, "") || equal(g_iszAmountArgv, ""))
	{
		console_print(player, "ERROR :: amx_take_credits <player> <amount of credits>")
		return PLUGIN_HANDLED
	} 

	g_iClientCredits = str_to_num(g_iszAmountArgv)

	if(g_iClientCredits <= 0)
	{
		console_print(player, "ERROR :: Suma creditelor trebuie sa fie mai mare de cat '0'")
		return PLUGIN_HANDLED
	}

	if(g_iCredits[iPlayerTarget] <= 0)
	{
		console_print(player, "ERROR :: Acestui jucator nu i se mai poate lua credite, deoarece are suma de '0' credite")
		return PLUGIN_HANDLED
	}

	if(!iPlayerTarget)
	{
		console_print(player, "ERROR :: Jucatorul nu a fost gasit pe server, probabil nu e conectat, sau ai scris gresit numele.")
		return PLUGIN_HANDLED
	}

	g_iCredits[iPlayerTarget] -= str_to_num(g_iszAmountArgv)
	_SaveCredits(iPlayerTarget)

	client_print_color(0, print_team_red, "%s Administratorul: ^4%s^3 i-a sters lui ^4[%s]^3 suma de credite:^4 %i", szTag, g_szAdmiName, g_szPlayerName, g_iClientCredits)

	formatex(g_szLogsMessage, charsmax(g_szLogsMessage), "ADMIN-ul: %s, i-a sters lui %s, suma de credite [%i]", g_szAdmiName, g_szPlayerName, g_iClientCredits)
	log_to_file("credits_logs.txt", g_szLogsMessage)

	return PLUGIN_HANDLED
}


public plugin_natives()
{
	register_native("set_user_credits", "_NativeSetUserCredits", 1)
	register_native("get_user_credits", "_NativeGetUserCredits", 1)
}
public _NativeSetUserCredits(player, credits){ g_iCredits[player] = credits; _SaveCredits(player);}
public _NativeGetUserCredits(player, credits){ return g_iCredits[player];}

public client_putinserver(player) _LoadCredits(player)

public client_disconnected(player)
{
	_SaveCredits(player)
}

public client_authorized(player)
{
	if(!is_user_alive(player) || !is_user_hltv(player)) return PLUGIN_HANDLED
	
	_LoadCredits(player)
	return PLUGIN_HANDLED
}

public client_connect(player)
{
	_LoadCredits(player)
}

public _SaveCredits(player)
{
	new g_iDataCredits[256], szGetAuthid[32]
	get_user_authid(player, szGetAuthid, charsmax(szGetAuthid))
	
	num_to_str(g_iCredits[player], g_iDataCredits, charsmax(g_iDataCredits))
	nvault_set(g_iVault, szGetAuthid, g_iDataCredits)
}


public _LoadCredits(player)
{
	new szGetAuthid[32]
	get_user_authid(player, szGetAuthid, charsmax(szGetAuthid))
	
	new g_iDataPoints = nvault_get(g_iVault, szGetAuthid)
	g_iCredits[player] = g_iDataPoints
}

public plugin_end()
{
	g_iVault = nvault_close(g_iVault)
}

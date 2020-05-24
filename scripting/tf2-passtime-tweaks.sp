#undef REQUIRE_PLUGIN
#include <updater>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

#include <dhooks>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>

// clang-format off
public
Plugin myinfo = {
    name = "TF2 Passtime Tweaks",
    author = "twiikuu",
    description = "",
    version = "0.3.0",
    url = "https://github.com/ldesgoui/tf2-passtime-tweaks"
};
// clang-format on

public
void OnPluginStart() {
    Handle game_config = LoadGameConfigFile("tf2-passtime-tweaks.games");

    if (game_config == INVALID_HANDLE) {
        SetFailState("Failed to load addons/sourcemod/gamedata/tf2-passtime-tweaks.games.txt");
    }

    if (LibraryExists("updater")) {
        OnLibraryAdded("updater");
    }

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client)) {
            SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
        }
    }

    Handle detour_PreventBunnyJumping =
        DHookCreateFromConf(game_config, "CTFGameMovement::PreventBunnyJumping");
    if (detour_PreventBunnyJumping == INVALID_HANDLE) {
        LogMessage("Could not set up detour for CTFGameMovement::PreventBunnyJumping");
    } else if (!DHookEnableDetour(detour_PreventBunnyJumping, false, Detour_PreventBunnyJumping)) {
        LogMessage("Coult not detour CTFGameMovement::PreventBunnyJumping");
    }
}

public
void OnLibraryAdded(const char[] name) {
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(
            "https://raw.githubusercontent.com/ldesgoui/tf2-passtime-tweaks/updater/updatefile.txt");
    }
}

public
void OnClientPutInServer(int client) { SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage); }

public
void TF2_OnConditionAdded(int client, TFCond condition) {
    if (condition == TFCond_PasstimeInterception) {
        ClientCommand(client, "r_screenoverlay \"\"");
    }
}

static Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage,
                                int &damage_type) {
    if (victim == attacker) {
        float factor = 1.0;

        if (TF2_GetPlayerClass(victim) == TFClass_Soldier &&
            !(GetEntityFlags(victim) & FL_ONGROUND)) {
            factor *= FindConVar("tf_damagescale_self_soldier").FloatValue;
        }

        if (TF2_IsPlayerInCondition(victim, TFCond_Ubercharged) ||
            TF2_IsPlayerInCondition(victim, TFCond_PasstimeInterception)) {
            factor *= 0.0;
        }

        SetEntityHealth(victim, GetClientHealth(victim) + RoundFloat(damage * factor));

        return Plugin_Continue;
    }

    if (damage_type & DMG_FALL) {
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

static MRESReturn Detour_PreventBunnyJumping(Address self) { return MRES_Supercede; }

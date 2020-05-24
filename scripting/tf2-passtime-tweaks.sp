#undef REQUIRE_PLUGIN
#include <updater>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

#include <tf2>

// clang-format off
public
Plugin myinfo = {
    name = "TF2 Passtime Tweaks",
    author = "twiikuu",
    description = "",
    version = "0.1.0",
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
}

public
void OnLibraryAdded(const char[] name) {
    if (StrEqual(name, "updater")) {
        Updater_AddPlugin(
            "https://raw.githubusercontent.com/ldesgoui/tf2-passtime-tweaks/updater/updatefile.txt");
    }
}

public
void TF2_OnConditionAdded(int client, TFCond condition) {
    if (condition == TFCond_PasstimeInterception) {
        ClientCommand(client, "r_screenoverlay \"\"");
    }
}

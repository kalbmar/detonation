#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define GAME_CONFIG "grenade-detonation"
#define GRENADE_DETONATE "CBaseGrenade::Detonate()"

static Handle g_detonate = null;

public Plugin myinfo = {
    name = "Detonation",
    author = "Kalbmar",
    description = "A grenade explodes when it hits a player",
    version = "1.0.0",
    url = "https://github.com/kalbmar/detonation",
};

public void OnPluginStart() {
    Handle gameConfig = LoadGameConfigFile(GAME_CONFIG);

    if (gameConfig != null) {
        g_detonate = SDKCall_Detonation(gameConfig);
    }

    delete gameConfig;
}

Handle SDKCall_Detonation(Handle gameConfig) {
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetFromConf(gameConfig, SDKConf_Virtual, GRENADE_DETONATE);

    Handle call = EndPrepSDKCall();

    if (call == null) {
        SetFailState("Unable to prepare SDK call for '%s'", GRENADE_DETONATE);
    }

    return call;
}

public void OnClientPutInServer(int client) {
    SDKHook(client, SDKHook_TraceAttackPost, Hook_TraceAttackPost);
}

void Hook_TraceAttackPost(int victim, int attacker, int inflictor, float damage, int damagetype, int ammotype, int hitbox, int hitgroup) {
    if (!IsClientValid(attacker) || !IsClientValid(victim) || !IsValidEntity(inflictor)) {
        return;
    }

    SDKCall(g_detonate, inflictor);
}

bool IsClientValid(int client) {
    return 1 <= client && client <= MaxClients;
}

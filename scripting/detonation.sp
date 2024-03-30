#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define GRENADE_ACTIVATE 2

public Plugin myinfo = {
    name = "Detonation",
    author = "Kalbmar",
    description = "A grenade explodes when it hits a player",
    version = "0.1.1",
    url = "https://github.com/kalbmar/detonation",
};

public void OnPluginStart() {
    PluginReload();
}

void PluginReload() {
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientConnected(i)) {
            SDKHook(i, SDKHook_TraceAttackPost, Hook_TraceAttackPost);
        }
    }
}

public void OnClientPutInServer(int client) {
    SDKHook(client, SDKHook_TraceAttackPost, Hook_TraceAttackPost);
}

void Hook_TraceAttackPost(int victim, int attacker, int inflictor, float damage, int damagetype, int ammotype, int hitbox, int hitgroup) {
    if (!IsClientValid(attacker) || !IsClientValid(victim) || !IsValidEntity(inflictor)) {
        return;
    }

    if (damagetype != DMG_CRUSH) {
        return;
    }

    SetEntProp(inflictor, Prop_Data, "m_takedamage", GRENADE_ACTIVATE);
    SDKHooks_TakeDamage(inflictor, inflictor, attacker, damage);
}

bool IsClientValid(int client) {
    return 1 <= client && client <= MaxClients;
}

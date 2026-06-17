#include <open.mp>
#include <cef>

#define PR27_OVERLAY_BROWSER_ID 1701
#define PR27_WORLD2D_BROWSER_ID 1702
#define PR27_WORLD3D_BROWSER_ID 1703

#define PR27_WORLD3D_OBJECT_MODEL 14772
#define PR27_WORLD3D_TEXTURE_NAME "CJ_TV_SCREEN"
#define PR27_INVALID_OBJECT_ID (-1)

new bool:g_CefReady[MAX_PLAYERS];
new g_PR27World3DObject[MAX_PLAYERS];

main(){}

public OnGameModeInit()
{
    CEF_AddResource("pr27_overlay");

    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        g_PR27World3DObject[playerid] = PR27_INVALID_OBJECT_ID;
    }

    return 1;
}

static bool:PR27_RequireCefReady(playerid)
{
    if (!g_CefReady[playerid])
    {
        SendClientMessage(playerid, -1, "[PR27] CEF is not ready yet.");
        return false;
    }

    return true;
}

static PR27_CreateOverlay(playerid)
{
    CEF_CreateBrowser(
        playerid,
        PR27_OVERLAY_BROWSER_ID,
        "http://cef/pr27_overlay/index.html",
        false,
        true,
        0.0,
        0.0
    );

    SendClientMessage(playerid, -1, "[PR27] Overlay2D created.");
    return 1;
}

static PR27_GetWorld2DTarget(playerid, &Float:x, &Float:y, &Float:z)
{
    GetPlayerPos(playerid, x, y, z);

    // Keep the target close to the player so the camera can quickly see it.
    // Move around and use /cefw2dmove to reposition it if needed.
    x += 3.0;
    z += 1.25;

    return 1;
}

static PR27_CreateWorld2D(playerid)
{
    new Float:x, Float:y, Float:z;
    PR27_GetWorld2DTarget(playerid, x, y, z);

    CEF_CreateWorld2DBrowser(
        playerid,
        PR27_WORLD2D_BROWSER_ID,
        "http://cef/pr27_overlay/index.html",
        x,
        y,
        z,
        480.0,
        260.0,
        0.0,
        0.5,
        1.0
    );

    SendClientMessage(playerid, -1, "[PR27] World2D created near your position. Use /cefw2dmove to reposition it.");
    printf("[PR27] World2D create target playerid=%d x=%f y=%f z=%f", playerid, x, y, z);

    return 1;
}

static PR27_GetWorld3DTarget(playerid, &Float:x, &Float:y, &Float:z)
{
    GetPlayerPos(playerid, x, y, z);

    // Put the TV object close to the player for quick visual checks.
    x += 3.0;
    z += 1.0;

    return 1;
}

static PR27_DestroyWorld3DObject(playerid)
{
    if (g_PR27World3DObject[playerid] != PR27_INVALID_OBJECT_ID)
    {
        DestroyObject(g_PR27World3DObject[playerid]);
        g_PR27World3DObject[playerid] = PR27_INVALID_OBJECT_ID;
    }

    return 1;
}

static PR27_AttachWorld3D(playerid)
{
    if (g_PR27World3DObject[playerid] == PR27_INVALID_OBJECT_ID)
    {
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D attach skipped: object does not exist.");
        return 1;
    }

    CEF_AttachBrowserToObject(playerid, PR27_WORLD3D_BROWSER_ID, g_PR27World3DObject[playerid]);
    SendClientMessage(playerid, -1, "[PR27] WorldObject3D attached to object.");
    printf("[PR27] WorldObject3D attached playerid=%d browserid=%d objectid=%d", playerid, PR27_WORLD3D_BROWSER_ID, g_PR27World3DObject[playerid]);

    return 1;
}

static PR27_DetachWorld3D(playerid)
{
    if (g_PR27World3DObject[playerid] == PR27_INVALID_OBJECT_ID)
        return 1;

    CEF_DetachBrowserFromObject(playerid, PR27_WORLD3D_BROWSER_ID, g_PR27World3DObject[playerid]);
    SendClientMessage(playerid, -1, "[PR27] WorldObject3D detached from object.");
    printf("[PR27] WorldObject3D detached playerid=%d browserid=%d objectid=%d", playerid, PR27_WORLD3D_BROWSER_ID, g_PR27World3DObject[playerid]);

    return 1;
}

static PR27_CreateWorld3D(playerid)
{
    PR27_DestroyWorld3DObject(playerid);

    new Float:x, Float:y, Float:z;
    PR27_GetWorld3DTarget(playerid, x, y, z);

    g_PR27World3DObject[playerid] = CreateObject(
        PR27_WORLD3D_OBJECT_MODEL,
        x,
        y,
        z,
        0.0,
        0.0,
        0.0
    );

    CEF_CreateWorldBrowser(
        playerid,
        PR27_WORLD3D_BROWSER_ID,
        "http://cef/pr27_overlay/index.html",
        PR27_WORLD3D_TEXTURE_NAME,
        512.0,
        256.0
    );

    SendClientMessage(playerid, -1, "[PR27] WorldObject3D browser/object created near your position.");
    SendClientMessage(playerid, -1, "[PR27] It will auto-attach when OnCefBrowserCreated is received. Use /cefw3dattach if needed.");
    printf("[PR27] WorldObject3D create target playerid=%d objectid=%d x=%f y=%f z=%f", playerid, g_PR27World3DObject[playerid], x, y, z);

    return 1;
}

static PR27_MoveWorld3D(playerid)
{
    if (g_PR27World3DObject[playerid] == PR27_INVALID_OBJECT_ID)
    {
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D object does not exist. Use /cefw3d first.");
        return 1;
    }

    new Float:x, Float:y, Float:z;
    PR27_GetWorld3DTarget(playerid, x, y, z);

    SetObjectPos(g_PR27World3DObject[playerid], x, y, z);
    SendClientMessage(playerid, -1, "[PR27] WorldObject3D object moved near your position.");
    printf("[PR27] WorldObject3D move target playerid=%d objectid=%d x=%f y=%f z=%f", playerid, g_PR27World3DObject[playerid], x, y, z);

    return 1;
}

static PR27_DestroyWorld3D(playerid)
{
    PR27_DetachWorld3D(playerid);
    CEF_DestroyBrowser(playerid, PR27_WORLD3D_BROWSER_ID);
    PR27_DestroyWorld3DObject(playerid);

    SendClientMessage(playerid, -1, "[PR27] WorldObject3D browser/object destroyed.");
    return 1;
}

static PR27_CreateAll(playerid)
{
    PR27_CreateOverlay(playerid);
    PR27_CreateWorld2D(playerid);
    PR27_CreateWorld3D(playerid);

    SendClientMessage(playerid, -1, "[PR27] Stress setup created: Overlay2D + World2D + WorldObject3D.");
    return 1;
}

static PR27_DestroyAll(playerid)
{
    CEF_DestroyBrowser(playerid, PR27_OVERLAY_BROWSER_ID);
    CEF_DestroyBrowser(playerid, PR27_WORLD2D_BROWSER_ID);
    PR27_DestroyWorld3D(playerid);

    SendClientMessage(playerid, -1, "[PR27] Stress setup destroyed.");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    g_CefReady[playerid] = false;
    PR27_DestroyWorld3DObject(playerid);
    return 1;
}

public OnCefInitialize(playerid, bool:success, E_CEF_INIT_REASON:reason, const message[])
{
    printf("[PR27] OnCefInitialize playerid=%d success=%d reason=%d message=%s", playerid, success, _:reason, message);

    if (success)
    {
        g_CefReady[playerid] = true;
        SendClientMessage(playerid, -1, "[PR27] CEF ready. Use /cef2d, /cefw2d, /cefw3d or /cefstress.");
    }
    else
    {
        g_CefReady[playerid] = false;
        SendClientMessage(playerid, -1, "[PR27] CEF init failed. Check server/client logs.");
    }

    return 1;
}

public OnCefBrowserCreated(playerid, browserid, bool:success, E_CEF_CREATE_STATUS:code, const reason[])
{
    printf("[PR27] OnCefBrowserCreated playerid=%d browserid=%d success=%d code=%d reason=%s", playerid, browserid, success, _:code, reason);

    if (success && browserid == PR27_WORLD3D_BROWSER_ID)
    {
        PR27_AttachWorld3D(playerid);
    }

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    // ---------------------------------------------------------------------
    // Overlay2D baseline tests
    // ---------------------------------------------------------------------
    if (!strcmp(cmdtext, "/cef2d", true))
    {
        if (!PR27_RequireCefReady(playerid))
            return 1;

        return PR27_CreateOverlay(playerid);
    }

    if (!strcmp(cmdtext, "/cefhide", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_OVERLAY_BROWSER_ID, false);
        SendClientMessage(playerid, -1, "[PR27] Overlay2D hidden.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefshow", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_OVERLAY_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] Overlay2D shown.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefreload", true))
    {
        CEF_ReloadBrowser(playerid, PR27_OVERLAY_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] Overlay2D reloaded.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefdestroy", true))
    {
        CEF_DestroyBrowser(playerid, PR27_OVERLAY_BROWSER_ID);
        SendClientMessage(playerid, -1, "[PR27] Overlay2D destroyed.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefrecreate", true))
    {
        CEF_DestroyBrowser(playerid, PR27_OVERLAY_BROWSER_ID);
        SetTimerEx("PR27_RecreateOverlay", 500, false, "i", playerid);

        SendClientMessage(playerid, -1, "[PR27] Overlay2D destroy/recreate requested.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefdevtools", true))
    {
        CEF_EnableDevTools(playerid, PR27_OVERLAY_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] Overlay2D DevTools enabled.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefred", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/red.html");
        SendClientMessage(playerid, -1, "[PR27] Overlay2D loaded red page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefblue", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/blue.html");
        SendClientMessage(playerid, -1, "[PR27] Overlay2D loaded blue page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefempty", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/empty.html");
        SendClientMessage(playerid, -1, "[PR27] Overlay2D loaded empty page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefanim", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/index.html");
        SendClientMessage(playerid, -1, "[PR27] Overlay2D loaded animation page.");
        return 1;
    }

    // ---------------------------------------------------------------------
    // World2D tests
    // ---------------------------------------------------------------------
    if (!strcmp(cmdtext, "/cefw2d", true))
    {
        if (!PR27_RequireCefReady(playerid))
            return 1;

        return PR27_CreateWorld2D(playerid);
    }

    if (!strcmp(cmdtext, "/cefw2dmove", true))
    {
        new Float:x, Float:y, Float:z;
        PR27_GetWorld2DTarget(playerid, x, y, z);

        CEF_SetWorld2DBrowserPos(playerid, PR27_WORLD2D_BROWSER_ID, x, y, z);
        SendClientMessage(playerid, -1, "[PR27] World2D moved near your position.");
        printf("[PR27] World2D move target playerid=%d x=%f y=%f z=%f", playerid, x, y, z);
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2dhide", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_WORLD2D_BROWSER_ID, false);
        SendClientMessage(playerid, -1, "[PR27] World2D hidden.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2dshow", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_WORLD2D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] World2D shown.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2dreload", true))
    {
        CEF_ReloadBrowser(playerid, PR27_WORLD2D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] World2D reloaded.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2ddestroy", true))
    {
        CEF_DestroyBrowser(playerid, PR27_WORLD2D_BROWSER_ID);
        SendClientMessage(playerid, -1, "[PR27] World2D destroyed.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2drecreate", true))
    {
        CEF_DestroyBrowser(playerid, PR27_WORLD2D_BROWSER_ID);
        SetTimerEx("PR27_RecreateWorld2D", 500, false, "i", playerid);

        SendClientMessage(playerid, -1, "[PR27] World2D destroy/recreate requested.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2ddevtools", true))
    {
        CEF_EnableDevTools(playerid, PR27_WORLD2D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] World2D DevTools enabled.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2dred", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/red.html");
        SendClientMessage(playerid, -1, "[PR27] World2D loaded red page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2dblue", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/blue.html");
        SendClientMessage(playerid, -1, "[PR27] World2D loaded blue page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2dempty", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/empty.html");
        SendClientMessage(playerid, -1, "[PR27] World2D loaded empty page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw2danim", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/index.html");
        SendClientMessage(playerid, -1, "[PR27] World2D loaded animation page.");
        return 1;
    }

    // ---------------------------------------------------------------------
    // WorldObject3D tests
    // ---------------------------------------------------------------------
    if (!strcmp(cmdtext, "/cefw3d", true))
    {
        if (!PR27_RequireCefReady(playerid))
            return 1;

        return PR27_CreateWorld3D(playerid);
    }

    if (!strcmp(cmdtext, "/cefw3dmove", true))
    {
        return PR27_MoveWorld3D(playerid);
    }

    if (!strcmp(cmdtext, "/cefw3dattach", true))
    {
        return PR27_AttachWorld3D(playerid);
    }

    if (!strcmp(cmdtext, "/cefw3ddetach", true))
    {
        return PR27_DetachWorld3D(playerid);
    }

    if (!strcmp(cmdtext, "/cefw3dhide", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_WORLD3D_BROWSER_ID, false);
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D hidden.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3dshow", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_WORLD3D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D shown.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3dreload", true))
    {
        CEF_ReloadBrowser(playerid, PR27_WORLD3D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D reloaded.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3ddestroy", true))
    {
        return PR27_DestroyWorld3D(playerid);
    }

    if (!strcmp(cmdtext, "/cefw3drecreate", true))
    {
        PR27_DestroyWorld3D(playerid);
        SetTimerEx("PR27_RecreateWorld3D", 700, false, "i", playerid);

        SendClientMessage(playerid, -1, "[PR27] WorldObject3D destroy/recreate requested.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3ddevtools", true))
    {
        CEF_EnableDevTools(playerid, PR27_WORLD3D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D DevTools enabled.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3dred", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/red.html");
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D loaded red page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3dblue", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/blue.html");
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D loaded blue page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3dempty", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/empty.html");
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D loaded empty page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefw3danim", true))
    {
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/index.html");
        SendClientMessage(playerid, -1, "[PR27] WorldObject3D loaded animation page.");
        return 1;
    }

    // ---------------------------------------------------------------------
    // Stress tests: Overlay2D + World2D + WorldObject3D together
    // ---------------------------------------------------------------------
    if (!strcmp(cmdtext, "/cefstress", true))
    {
        if (!PR27_RequireCefReady(playerid))
            return 1;

        return PR27_CreateAll(playerid);
    }

    if (!strcmp(cmdtext, "/cefstresshide", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_OVERLAY_BROWSER_ID, false);
        CEF_SetBrowserVisible(playerid, PR27_WORLD2D_BROWSER_ID, false);
        CEF_SetBrowserVisible(playerid, PR27_WORLD3D_BROWSER_ID, false);
        SendClientMessage(playerid, -1, "[PR27] Stress browsers hidden.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefstressshow", true))
    {
        CEF_SetBrowserVisible(playerid, PR27_OVERLAY_BROWSER_ID, true);
        CEF_SetBrowserVisible(playerid, PR27_WORLD2D_BROWSER_ID, true);
        CEF_SetBrowserVisible(playerid, PR27_WORLD3D_BROWSER_ID, true);
        SendClientMessage(playerid, -1, "[PR27] Stress browsers shown.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefstressred", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/red.html");
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/red.html");
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/red.html");
        SendClientMessage(playerid, -1, "[PR27] Stress browsers loaded red page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefstressblue", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/blue.html");
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/blue.html");
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/blue.html");
        SendClientMessage(playerid, -1, "[PR27] Stress browsers loaded blue page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefstressempty", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/empty.html");
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/empty.html");
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/empty.html");
        SendClientMessage(playerid, -1, "[PR27] Stress browsers loaded empty page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefstressanim", true))
    {
        CEF_LoadUrl(playerid, PR27_OVERLAY_BROWSER_ID, "http://cef/pr27_overlay/index.html");
        CEF_LoadUrl(playerid, PR27_WORLD2D_BROWSER_ID, "http://cef/pr27_overlay/index.html");
        CEF_LoadUrl(playerid, PR27_WORLD3D_BROWSER_ID, "http://cef/pr27_overlay/index.html");
        SendClientMessage(playerid, -1, "[PR27] Stress browsers loaded animation page.");
        return 1;
    }

    if (!strcmp(cmdtext, "/cefstressdestroy", true))
    {
        return PR27_DestroyAll(playerid);
    }

    if (!strcmp(cmdtext, "/cefstressrecreate", true))
    {
        PR27_DestroyAll(playerid);
        SetTimerEx("PR27_RecreateAll", 1000, false, "i", playerid);

        SendClientMessage(playerid, -1, "[PR27] Stress destroy/recreate requested.");
        return 1;
    }

    return 0;
}

forward PR27_RecreateOverlay(playerid);
public PR27_RecreateOverlay(playerid)
{
    if (!IsPlayerConnected(playerid))
        return 1;

    if (!g_CefReady[playerid])
        return 1;

    return PR27_CreateOverlay(playerid);
}

forward PR27_RecreateWorld2D(playerid);
public PR27_RecreateWorld2D(playerid)
{
    if (!IsPlayerConnected(playerid))
        return 1;

    if (!g_CefReady[playerid])
        return 1;

    return PR27_CreateWorld2D(playerid);
}

forward PR27_RecreateWorld3D(playerid);
public PR27_RecreateWorld3D(playerid)
{
    if (!IsPlayerConnected(playerid))
        return 1;

    if (!g_CefReady[playerid])
        return 1;

    return PR27_CreateWorld3D(playerid);
}

forward PR27_RecreateAll(playerid);
public PR27_RecreateAll(playerid)
{
    if (!IsPlayerConnected(playerid))
        return 1;

    if (!g_CefReady[playerid])
        return 1;

    return PR27_CreateAll(playerid);
}

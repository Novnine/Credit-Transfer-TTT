#pragma semicolon 1

#include <sourcemod>
#include <ttt>
#include <ttt_shop>

#pragma newdecls required

public Plugin myinfo =
{
    name = "Credit Transfer",
    author = "Novnine",
    description = "Allows credit's to be transferred from one player to another on TTT",
    version = "master",
    url = "https://github.com/Novnine/Credit-Transfer-TTT"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_donate", Command_Donate);
}

public Action Command_Donate(int client, int args)
{
    if (!TTT_IsClientValid(client))
    {
        return Plugin_Handled;
    }

    if (args != 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_donate <#userid|name> <credits>");
        return Plugin_Handled;
    }

    char arg1[32];
    GetCmdArg(1, arg1, sizeof(arg1));

    char arg2[32];
    GetCmdArg(2, arg2, sizeof(arg2));
    int donationAmt = StringToInt(arg2);

    char target_name[MAX_TARGET_LENGTH];
    int target_list[MAXPLAYERS];
    int target_count;
    bool tn_is_ml;

    if ((target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    int clientCredits = TTT_GetClientCredits(client);
    int clientDeduction = donationAmt * target_count;

    if (clientDeduction > clientCredits)
    {
        ReplyToCommand(client, "Insufficient credits");
        return Plugin_Handled;
    }

    for (int i = 0; i < target_count; i++)
    {
        if (!TTT_IsClientValid(target_list[i]))
        {
            return Plugin_Handled;
        }

        TTT_AddClientCredits(target_list[i], donationAmt);
        CPrintToChat(client, g_sPluginTag, "Donate", client, target_list[i], donationAmt, "Credits");
    }

    TTT_SetClientCredits(client, clientCredits - clientDeduction);

    return Plugin_Handled;
}

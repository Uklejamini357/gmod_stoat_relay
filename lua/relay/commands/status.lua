-- Currently the only commands. There is no role support yet.

Stoat.commands['status'] = function()
    local plys = player.GetCount() .. '/' .. game.MaxPlayers()
    local plyList = ''
    local plysTable = player.GetAll()

    if #plysTable > 0 then
        for num, ply in ipairs(plysTable) do
            if plyList ~= "" then plyList = plyList.."\n" end
            plyList = plyList.."- "..ply:Nick()
        end
    else plyList = StoatString.nobody .. '¯\\_(ツ)_/¯' end

    local firstpl = player.GetAll()[1]
    local connect = game.IsDedicated() and "steam://connect/" .. game.GetIPAddress() or GetConVar("p2p_enabled"):GetBool() and IsValid(firstpl) and "p2p:"..firstpl:SteamID64() or "Unavailable"
    local form = {
        content = "**[COMMAND]**: Status\
**Server name**: "..GetHostName().."\
"..StoatString.connect .. " - "..connect.."\
" .. StoatString.currentMap .. " - " .. game.GetMap() .. "\
" .. StoatString.players.." - "..plys..
"\n\n"..StoatString.playerList..":\n"..plyList
   }

    Stoat.send(form)
end

Stoat.commands['ping'] = function()
    local form = {
        ['content'] = '🏓 Pong!'
    }

    Stoat.send(form)
end

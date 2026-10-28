
print("check")

require("gwsockets") -- use 1.4.0 beta2 for GWSockets, v1.3.0 has issues that can cause freezes for some reason... at least in my experience, cuz I used linux during development for Stoat relay ahaha
util.AddNetworkString("!!stoat-receive")

local ipairs = ipairs

Stoat.isSocketReloaded = false

if Stoat.socket != nil then Stoat.isSocketReloaded = true; Stoat.socket:closeNow(); end

Stoat.socket = Stoat.socket or GWSockets.createWebSocket("wss://stoat.chat/events?version=1&format=json&token="..Stoat.botToken, false)

local socket = Stoat.socket

local function broadcastMsg(msg)
    print( '[Stoat] ' .. msg.author..': '.. msg.content )

    net.Start( '!!stoat-receive' )
        net.WriteTable( msg )
    net.Broadcast()
end

local function heartbeat()
    socket:write([[{
    "type": "Ping",
    "data": 0
}]])
end
local function createHeartbeat()
    timer.Create('!!stoat_hearbeat', 10, 0, function()
        heartbeat()
    end)
end

function socket:onMessage( txt )
    local resp = util.JSONToTable(txt)
    if not resp then return end

    if Stoat.debug then
        print('[Stoat] Received: ')
        PrintTable(resp)
    end

    -- not necessary
    -- if resp.op == 10 and resp.t == nil then createHeartbeat() end
    -- if resp.op == 1 then heartbeat() end

    if resp.type == "Message" and not resp.webhook and resp.channel == Stoat.readChannelID then
        -- if resp.d.author.bot == true then return end -- Unsure if that's declared in Stoat
        if string.sub(resp.content, 0, 1) == Stoat.botPrefix then
            command = string.sub(resp.content, 2)

            if Stoat.commands[command] then Stoat.commands[command]() end

            return
        end

        -- Later I transform this into a real thing
        -- if resp.referenced_message then
        --     resp.content = '[' .. StoatString.mentioned .. ' @' .. resp.referenced_message.author.username .. '] ' .. resp.content
        -- end

        if resp.attachments then 
        
            for _, attachment in ipairs(resp.attachments) do
                if attachment.proxy_url then 
                    resp.content = resp.content .. '\n' .. attachment.proxy_url
                end
            end

        end
        local authorName = resp.user and resp.user.username or resp.user.global_name or resp.user.username
        broadcastMsg({ ['author'] = authorName, ['content'] = resp.content })
    end
end

function socket:onError( txt )
    print( '[Stoat] Error: ', txt )
end

function socket:onConnected()
	print( '[Stoat] connected to Stoat server' )
    -- intents == 514 is needed due to guild members and messages
    -- (GUILD_MEMBERS and message intent)
    local req = [[{
    "type": "Authenticate",
    "token": "]]..Stoat.botToken..[["
}]]

    timer.Simple(1, function()
        socket:write(req)
        createHeartbeat()
    end)
end

function socket:onDisconnected()
    print( '[Stoat] WebSocket disconnected' )
    timer.Remove( '!!stoat_hearbeat' )

    if Stoat.isSocketReloaded != true then
        print( '[Stoat] WebSocket reload in 5 sec...' )
        timer.Simple( 5, function() socket:open() end )
    end
end

print( '[Stoat] Socket init...' )
timer.Simple( 3, function()
    socket:open()
    Stoat.isSocketReloaded = false
end )

-- request (lag when changelevel)
hook.Add("ShutDown", "!!stoat_srvShutdown_socketdown", function() 
    socket:closeNow()
end)


local lastupdate = os.time()
hook.Add("Think", "!!Stoat-Think", function()
    if not socket:isConnected() then return end
    if lastupdate+600 > os.time() then return end

    socket:write([[{
    "type": "Subscribe",
    "server_id": "01KFRKC3V1PAVV3H9PR73WR08S"
}]])
end)

require("chttp")

local tmpAvatars = {}
-- for bots
tmpAvatars['0'] = 'https://avatars.cloudflare.steamstatic.com/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg'

local IsValid = IsValid
local util_TableToJSON = util.TableToJSON
local util_SteamIDTo64 = util.SteamIDTo64
local http_Fetch = http.Fetch
local coroutine_resume = coroutine.resume
local coroutine_create = coroutine.create
local string_find = string.find

function Stoat.send(form) 
	if type( form ) ~= "table" then Error( '[Stoat] invalid type!' ) return end

	CHTTP({
		["failed"] = function( msg )
			print( "[Stoat] "..msg )
		end,
		["method"] = "POST",
		["url"] = Stoat.webhook,
		["body"] = util_TableToJSON(form),
		["type"] = "application/json; charset=utf-8"
	})
end

local function getAvatar(id, co)
	http_Fetch( "https://steamcommunity.com/profiles/"..id.."?xml=1", 
	function(body)
		body = string.sub(body, 1, 1500) -- try to fix issue #11
		local _, _, url = string_find(body, '<avatarFull>.*.(https://.*)]].*\n.*<vac')
		tmpAvatars[id] = url

		coroutine_resume(co)
	end, 
	function (msg)
		Error("[Stoat] error getting avatar ("..msg..")")
	end )
end

local function formMsg(ply, str, _, isLocal)
    if isLocal then return end -- The so-called GDPR compliance
	local id = tostring( ply:SteamID64() )

	local co = coroutine_create( function() 
		local form = {
			content = ply:Nick()..": "..str,
		}
		
		Stoat.send(form)
	end )

	coroutine_resume( co )
end

local function playerConnect( ply )
	local steamid64 = util_SteamIDTo64( ply.networkid )

	if Stoat.hideBots and (ply.networkid == "BOT") then return end

	local co = coroutine_create( function()
		local form = {
			["content"] = "**[Event]** Player joined: "..ply.name.." ("..ply.networkid..")",
		}

		Stoat.send(form)
	end)

	coroutine_resume( co )
end

local function plyFirstSpawn(ply)
	if IsValid(ply) then
		local steamid = ply:SteamID()
		local steamid64 = util_SteamIDTo64( steamid )

		if Stoat.hideBots and ply:IsBot() then return end

		local co = coroutine_create(function()
			local form = {
				["content"] = "**[Event]** Player spawned: "..ply:Nick().." ("..steamid..")",
			}

			Stoat.send(form)
		end)

		coroutine_resume( co )
	end
end

local function plyDisconnect(ply)
	local steamid64 = util_SteamIDTo64( ply.networkid )

	if Stoat.hideBots and (ply.networkid == "BOT") then return end

	local co = coroutine_create(function()
		local form = {
			content = "**[Event]** Player spawned: "..ply:Nick().." ("..ply.networkid..")"
		}

		Stoat.send(form)

		tmpAvatars[steamid64] = nil
	end)

	coroutine_resume( co )
end

hook.Add("PlayerSay", "!!stoat_sendmsg", formMsg)
gameevent.Listen( "player_connect" )
hook.Add("player_connect", "!!stoat_plyConnect", playerConnect)
hook.Add("PlayerInitialSpawn", "!!stoatPlyFirstSpawn", plyFirstSpawn)
gameevent.Listen( "player_disconnect" )
hook.Add("player_disconnect", "!!stoat_onDisconnect", plyDisconnect)

if Stoat.srvStarted and !Stoat.srvStartedTime then
	hook.Add("Initialize", "!!stoat_srvStarted", function() 
		Stoat.srvStartedTime = os.time()
		local form = {
			content = "**[SERVER]**: "..StoatString.serverStarted.." // Map: "..game.GetMap().." // Gamemode: "..engine.ActiveGamemode()
		}

		local co = coroutine_create(function()
			Stoat.send(form)
		end)
		coroutine_resume(co)

		hook.Remove("Initialize", "!!stoat_srvStarted")
	end)
end
if Stoat.srvShutdown then
	hook.Add("ShutDown", "!!stoat_srvShutdown", function()
		-- local uptime = os.time() - Stoat.srvStartedTime
		-- local timestr = ""
		-- if uptime >= 86400 then
		-- 	local d = math.floor(uptime/86400).." days"
		-- 	timestr = timestr == "" and d or timestr..", "..d
		-- 	uptime = uptime - math.floor(uptime/86400)*86400
		-- end
		-- if uptime >= 3600 then
		-- 	local d = math.floor(uptime/3600).." hours"
		-- 	timestr = timestr == "" and d or timestr..", "..d
		-- 	uptime = uptime - math.floor(uptime/3600)*3600
		-- end
		-- if uptime >= 60 then
		-- 	local d = math.floor(uptime/60).." minutes"
		-- 	timestr = timestr == "" and d or timestr..", "..d
		-- 	uptime = uptime - math.floor(uptime/60)*60
		-- end
		-- if uptime >= 1 then
		-- 	local d = math.floor(uptime).." seconds"
		-- 	timestr = timestr == "" and d or timestr..", "..d
		-- end

		local form = {
			content = "**[SERVER]**: Closed."
		}

		local co = coroutine_create(function()
			Stoat.send(form)
		end)
		coroutine_resume(co)
		hook.Remove("Initialize", "!!stoat_srvShutdown")
	end)
end

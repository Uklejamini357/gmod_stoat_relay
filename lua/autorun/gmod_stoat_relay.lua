if SERVER then 
	include("relay/sv_config.lua")
	include("relay/sv_msgSend.lua")
	include("relay/sv_msgGet.lua")

	if Stoat.language == "en" then
		include("relay/translations/en.lua")
	else
		include("relay/translations/ru.lua")
	end

	-- commands
	local files, _ = file.Find( 'relay/commands/' .. "*", "LUA" )

	for num, fl in ipairs(files) do
		include("relay/commands/" .. fl)
		print('[Stoat] module ' .. fl .. ' added!')
	end
	--

	AddCSLuaFile('relay/cl_config.lua')
	AddCSLuaFile('relay/cl_msgReceive.lua')

	print( "----------------------\n" )
	print( "STOAT RELAY LOADED!\n" )
	print( "----------------------" )
end

if CLIENT then 
	include('relay/cl_config.lua')
	include('relay/cl_msgReceive.lua')
end
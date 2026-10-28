Stoat = {
	-- ! Webhook used for sending messages to the server channel. Must be put correctly, otherwise, it will not work!
	webhook = "",
	
	-- Haven't figured out a way how to make a webhook display a different name.
	-- hookname = "Gmod Relay",

	-- ! Put your desired channel ID for Stoat below between quotations. Must be correct, otherwise the server cannot transfer user messages to in-game chat!
	readChannelID = "",

	-- ! Put your bot Token you copied from Stoat here. This is important.
	botToken = "",

	-- Prefix used for commands.
	botPrefix = "!",

	-- Announce in the channel when the server starts.
	srvStarted = true,

	-- Same as above, except it does when the server is closed. (Does not call when the server crashes)
	srvShutdown = true,

	-- Hides bots from in-game chat. (FUNCTIONALITY UNCONFIRMED)
	hideBots = true,

	-- Addon language
	language = "en",

	-- For developers (logs)
	debug = false,

	-- !!!!!!!!Don't touch, meant for transient storage of the commands executed by user.!!!!!!!!
	-- !!!!!!!!If touched WILL lead to the bot breaking!!!!!!!!
	commands = {}
}

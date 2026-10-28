local color_white = Color(255,255,255)

net.Receive("!!stoat-receive", function()
	local msg = net.ReadTable()

	chat.AddText(Stoat.prefixClr, "["..Stoat.prefix.."] ", Stoat.UserNameClr or color_white, msg.author, color_white, ": ", Stoat.UserMsgClr or color_white, msg.content)
end)

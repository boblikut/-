local discordia = require('discordia')
local timer = require('timer')
local client = discordia.Client()
client:enableIntents(discordia.enums.gatewayIntent.messageContent)

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

local function parseCommand(input)
    local commandTable = {}
    for word in string.gmatch(input, '([^,%s]+)') do
        table.insert(commandTable, word)
    end
    return table.remove(commandTable, 1), commandTable
end

function table.Shuffle( t )
	local n = #t
	for i = 1, n - 1 do
		local j = math.random( i, n )
		t[ i ], t[ j ] = t[ j ], t[ i ]
	end
end

local function GetMedia(attachments)
	local tab = {}
	for k1, v1 in ipairs(attachments) do
		for k2, v2 in pairs(v1) do
			if type(v2) == "string" and string.sub(v2, 1, 40) == "https://media.discordapp.net/attachments" then
				tab[#tab + 1] = v2
			end
		end
	end
	return tab
end

client:on('messageCreate', function(message)
	local command, args = parseCommand(message.content)
	local isAdmin = message.member:getPermissions():has(0x0000000000000008)
	local guild = message.guild
	if command == "!add_avatars" and isAdmin then
		local count = 0
		if not guild._avatars_tab then
			guild._avatars_tab = {}
		end
		for k,v in ipairs(args) do
			guild._avatars_tab[#guild._avatars_tab + 1] = v
		end
		count = count + #args
		local attachments = message.attachments
		if attachments then
			local media = GetMedia(attachments)
			for k,v in ipairs(media) do
				guild._avatars_tab[#guild._avatars_tab + 1] = v
			end
			count = count + #media
		end
		if count > 1 then
			message.channel:send('Avatars has been added!')
		elseif count == 1 then
			message.channel:send('Avatar has been added!')
		else
			message.channel:send('Avatars hasnt been added!')
		end
	end
	
	if command == "!add_nicks" and isAdmin then
		if not guild._nicks_tab then
			guild._nicks_tab = {}
		end
		for k,v in ipairs(args) do
			guild._nicks_tab[#guild._nicks_tab + 1] = v
		end
		if #args > 1 then
			message.channel:send('Nicknames has been added!')
		elseif #args == 1 then
			message.channel:send('Nickname has been added!')
		else
			message.channel:send('Nicknames hast been added!')
		end
	end
	
	if command == "!clear" and isAdmin then
		guild._avatars_tab = {}
		guild._nicks_tab = {}
		message.channel:send('Tables has been cleared')
	end
	
	if command == "!show" and isAdmin then
		if not (guild._avatars_tab or guild._nicks_tab) then message.channel:send('Not enough avatars or nicknames') return end
		table.Shuffle(guild._avatars_tab)
		for k,v in ipairs(guild._nicks_tab) do
			timer.sleep(1000)
				local avatar = guild._avatars_tab[k] or "No Avatar!!!"
				message.channel:send(string.upper(v).."\n"..avatar)
		end
	end
	
	if command == "!help" then
		message.channel:send([[
!add_avatars - add avatars
!add_nicks   - add nicknames(Example: !add_nicks Mike, Nick, Jonny)
!clear - clear nicknames and avatars table
!show - start roulette
		]])
	end
end)

client:run('Bot TOKEN')

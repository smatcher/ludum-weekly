local GameState = require "love-toys.third-party.hump.gamestate" 
local LoveFrames = require "love-toys.third-party.LoveFrames"
local Network = require "network"

local default_ip = "127.0.0.1"
local default_port = "42003"

local menu = {
	ip = default_ip,
	port = default_port,

	editing_ip = false,
	editing_port = false,
}

function menu:draw()
	local editing_color = Constants.Colors.TextInfo
	local default_color = Constants.Colors.Default
	local ip_color = self.editing_ip and editing_color or default_color
	local port_color = self.editing_port and editing_color or default_color
	love.graphics.print("Press c to run as a client", 10, 10)
	love.graphics.print("Press s to run as a server", 10, 30)
	love.graphics.print("Press d to run a debug game alone", 10, 50)
	love.graphics.setColor(ip_color)
	love.graphics.print("Press i to edit ip adress [" .. self.ip .. "]", 10, 100)
	love.graphics.setColor(port_color)
	love.graphics.print("Press p to edit port [" .. self.port .. "]", 10, 120)
	love.graphics.setColor(default_color)
	love.graphics.print("Press escape to quit", 10, 170)

	if Network.server ~= nil then
		local client_count = 0
		for _ in pairs(Network.server.clients) do
			client_count = client_count + 1
		end
		local status = "(" .. client_count .. " clients connected)"
		love.graphics.print("Server running" .. status, 10, 130)
	end

	if Network.client ~= nil then
		local status = "disconnected"
		if Network.client.connected then
			status = "connected"
		end
		love.graphics.print("Client running" .. status, 10, 130)
	end
end

function menu:update(dt)
	Network:update(dt)
end

local function toNum(key)
	local keys = {}
	for i=0,9,1 do
		keys[""   .. i] = i
		keys["kp" .. i] = i
	end
	return keys[key]
end

local function isValidIp(ip) -- return valid, partial_valid
	local partial_valid = true
	local dot_count = 0
	local last_num = ""

	for i = 1,#ip do
		local c = ip:sub(i,i)
		if c == '.' then
			if i == 1 or ip:sub(i-1, i-1) == '.' then
				partial_valid = false
			end
			last_num = ""
			dot_count = dot_count + 1
			if dot_count > 3 then
				partial_valid = false
			end
		else
			last_num = last_num .. c
			local to_num = tonumber(last_num)
			if to_num > 255 then
				partial_valid = false
			end
		end
	end

	local valid = partial_valid and dot_count == 3 and ip:sub(#ip, #ip) ~= '.'
	return valid, partial_valid
end

function menu:keyForIp(key, code)
	local num_key = toNum(key)
	if key == 'escape' then
		self.editing_ip = false
		self.ip = default_ip
	elseif key == 'return' then
		local valid, _ = isValidIp(self.ip)
		if valid then
			self.editing_ip = false
		end
	elseif key == 'backspace' then
		if #self.ip ~= 0 then
			self.ip = self.ip:sub(1, #self.ip - 1)
		end
	elseif key == 'kp.' or key == '.' then
		local candidate = self.ip .. '.'
		local _, valid = isValidIp(candidate)
		if valid then
			self.ip = candidate
		end
	elseif num_key ~= nil then
		local candidate = self.ip .. num_key
		local _, valid = isValidIp(candidate)
		if valid then
			self.ip = candidate
		end
	end
end

function menu:keyForPort(key, code)
	local num_key = toNum(key)
	if key == 'escape' then
		self.editing_port = false
		self.port = default_port
	elseif key == 'return' then
		if #self.port >= 2 then
			self.editing_port = false
		end
	elseif key == 'backspace' then
		if #self.port ~= 0 then
			self.port = self.port:sub(1, #self.port - 1)
		end
	elseif num_key ~= nil then
		self.port = self.port .. num_key
	end
end

function menu:keyreleased(key, code)
	if self.editing_ip then
		self:keyForIp(key, code)
		return
	elseif self.editing_port then
		self:keyForPort(key, code)
		return
	end

	if key == 'd' then
		GameState.switch(states.Game)
	end
	if key == 's' then
		Network.callbacks.connect = function() GameState.switch(states.Game) end
		Network.callbacks.disconnect = function() GameState.switch(states.Disconnected) end
		Network:initServer(self.port)
		GameState.switch(states.Connecting)
	end
	if key == 'c' then
		Network.callbacks.connect = function() GameState.switch(states.Game) end
		Network.callbacks.disconnect = function() GameState.switch(states.Disconnected) end
		Network:initClient(self.ip, self.port)
	end
	if key == 'i' then
		self.editing_ip = true
		self.ip = ""
	end
	if key == 'p' then
		self.editing_port = true
		self.port = ""
	end
	if key == 'escape' then
		love.event.quit()
	end
end

return menu


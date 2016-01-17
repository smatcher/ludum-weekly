local Class = require "love-toys.third-party.class" -- Common class
local Binary = require "love-toys.third-party.Binary"
local Lube = require "love-toys.third-party.LUBE"
local GameState = require "love-toys.third-party.hump.gamestate"

-- TODO: Prevent connection of more than one client

local network = {
	pong_timer = -1,

	callbacks = {
		connect = nil,
		disconnect = nil,
		recv = nil
	}
}

local debug_trafic = false
local use_tcp = true
local ping_rate = 3
local timeout_limit = 9

local handshake_msg = "HAKA"
local ping_msg = "PING"
local pong_msg = "PONG" -- LUBE does not send a keep alive from the server to the client we do it ourselves

function network:initClient(ip, port)
	assert(self.server == nil and self.client == nil)

	if use_tcp then
		self.client = Lube.tcpClient()
	else
		self.client = Lube.udpClient()
	end

	self.client.callbacks.recv = function (data, client)
		if debug_trafic then
			print("client recv", client, data)
		end

		if data == pong_msg then
			self.pong_timer = 0
		elseif self.callbacks.recv ~= nil then
			self.callbacks.recv(data, client)
		end
	end
	self.client.handshake = handshake_msg
	self.client:setPing(true, ping_rate, ping_msg)
	local ok, err = self.client:connect(ip, port)
	if ok then
		self.pong_timer = 0

		if self.callbacks.connect ~= nil then
			self.callbacks.connect()
		end
	else
		self:abort()
	end
	print("connection", ok, err)
end

function network:initServer(port)
	assert(self.server == nil and self.client == nil)

	if use_tcp then
		self.server = Lube.tcpServer()
	else
		self.server = Lube.udpServer()
	end

	self.server.callbacks.connect = function (client)
		print("connect", client)
		self.pong_timer = 0
		if self.callbacks.connect ~= nil then
			self.callbacks.connect()
		end
	end
	self.server.callbacks.disconnect = function (client)
		print("disconnect", client)
		self.pong_timer = -1
		if self.callbacks.disconnect ~= nil then
			self.callbacks.disconnect()
		end
	end
	self.server.callbacks.recv = function (data, client)
		if debug_trafic then
			print("server recv", client, data)
		end
		if self.callbacks.recv ~= nil then
			self.callbacks.recv(data)
		end
	end

	self.server.handshake = handshake_msg
	self.server:setPing(true, timeout_limit, ping_msg)
	self.server:listen(port)
	print("server started")
end

function network:update(dt)
	if self.server then
		self.server:update(dt)

		-- send pong if needed
		if self.pong_timer >= 0 then
			self.pong_timer = self.pong_timer + dt
			if self.pong_timer > ping_rate then
				for client_id,_ in pairs(self.server.clients) do
					self.server:send(pong_msg, client_id)
				end
				self.pong_timer = 0
			end
		end
	end
	if self.client then
		self.client:update(dt)

		-- check if timeout
		if self.pong_timer >= 0 then
			self.pong_timer = self.pong_timer + dt
			if self.pong_timer > timeout_limit then
				print("client disconnect due to server loss", client)
				if self.callbacks.disconnect ~= nil then
					self:abort()
					self.callbacks.disconnect()
				end
			end
		end
	end
end

function network:abort()
	if self.server ~= nil then
		self.server = nil
		print("server destroyed")
	end

	if self.client ~= nil then
		self.client:disconnect()
		self.client = nil
		print("client destroyed")
	end

	self.pong_timer = -1
end

function network:isConnected()
	if self.server ~= nil then
		local client_count = 0
		for _ in pairs(self.server.clients) do
			client_count = client_count + 1
		end
		return client_count > 0
	end

	if self.client ~= nil then
		return self.client.connected
	end

	return false
end

function network:sendPacket(p)
	if not self:isConnected() then
		print("Error : can't send packet, not connected")
		return
	end

	if self.server ~= nil then
		for client_id,_ in pairs(self.server.clients) do
			self.server:send(p, client_id)
		end
	end

	if self.client ~= nil then
		self.client:send(p)
	end
end

return network


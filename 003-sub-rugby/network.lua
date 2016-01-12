local Class = require "love-toys.third-party.class" -- Common class
local Binary = require "love-toys.third-party.Binary"
local Lube = require "love-toys.third-party.LUBE"

local network = {}

function network:initClient()
	assert(self.server == nil and self.client == nil)

	self.data_blob = {}
	self.client = Lube.tcpClient()
	--self.client = Lube.udpClient()
	self.client.callbacks.recv = function (data, client) print("recv", client, data) end
	self.client.handshake = "[Haka]"
	self.client:setPing(true, 9, "Ping")
	local ok, err = self.client:connect("127.0.0.1", 42003)
	print(ok, err)
end

function network:initServer()
	assert(self.server == nil and self.client == nil)

	self.data_blob = {}
	self.server = Lube.tcpServer()
	--self.server = Lube.udpServer()
	self.server.callbacks.connect = function (client) print("connect", client) end
	self.server.callbacks.disconnect = function (client) print("disconnect", client) end
	self.server.callbacks.recv = function (data, client) print("recv", client, data) end
	self.server.handshake = "[Haka]"
	self.server:setPing(true, 9, "Ping")
	self.server:listen(42003)
	print("server started")
end

function network:update(dt)
	if self.server then
		self.server:update(dt)
	end
	if self.client then
		self.client:update(dt)
	end
end

return network


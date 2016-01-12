local GameState = require "love-toys.third-party.hump.gamestate" 
local LoveFrames = require "love-toys.third-party.LoveFrames"
local Network = require "network"

local menu = {}

function menu:draw()
	love.graphics.print("Press enter to start", 10, 10)
	love.graphics.print("Press c to test network client", 10, 30)
	love.graphics.print("Press s to test network server", 10, 50)
	love.graphics.print("Press escape to quit", 10, 80)

	if Network.server ~= nil then
		local status = "(" .. #Network.server.clients .. "clients connected)"
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

	if Network.client == nil then
		return
	end

	if self.timer == nil then
		self.timer = 0
		self.times = 0
	end
	self.timer = self.timer + dt
	if self.timer > 1 then
		self.timer = 0
		self.times = self.times + 1
		print("sending message")
		Network.client:send("Hello times " .. self.times)
	end
end

function menu:keyreleased(key, code)
	if key == 'return' then
		GameState.switch(states.Game)
	end
	if key == 's' then
		Network:initServer()
	end
	if key == 'c' then
		Network:initClient()
	end
	if key == 'escape' then
		love.event.quit()
	end
end

return menu


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

function menu:keyreleased(key, code)
	if key == 'return' then
		GameState.switch(states.Game)
	end
	if key == 's' then
		Network.callbacks.connect = function() GameState.switch(states.Game) end
		Network.callbacks.disconnect = function() GameState.switch(states.Disconnected) end
		Network:initServer()
		GameState.switch(states.Connecting)
	end
	if key == 'c' then
		Network.callbacks.connect = function() GameState.switch(states.Game) end
		Network.callbacks.disconnect = function() GameState.switch(states.Disconnected) end
		Network:initClient()
	end
	if key == 'escape' then
		love.event.quit()
	end
end

return menu


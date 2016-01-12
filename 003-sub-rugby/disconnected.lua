local GameState = require "love-toys.third-party.hump.gamestate" 
local Network = require "network"

local disconnected = {
}

function disconnected:init()
end

function disconnected:draw()
	love.graphics.print("Disconnected", 10, 10)
	love.graphics.print("Press enter to return to menu", 10, 30)
end

function disconnected:update(dt)
	Network:update(dt)
end

function disconnected:keypressed(key, code, isrepeat)
--	if key == 'left' then
--		self.player.direction = PlayerEntity.LeftDirection
--	end
--
--	if key == 'right' then
--		self.player.direction = PlayerEntity.RightDirection
--	end
end

function disconnected:keyreleased(key, code)
	if key == 'return' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

return disconnected


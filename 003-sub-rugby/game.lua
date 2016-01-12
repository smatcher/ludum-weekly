local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"

local Entities = require "entities"
local Network = require "network"

local game = {
	grid_background = Entities.GridClass(),
	tooltips = Entities.TooltipsClass(),
}

function game:init()
end

function game:draw()
	-- Background
	love.graphics.clear(Constants.Colors.Background)
	-- Grid
	self.grid_background:draw()
	-- Units
	-- Tooltips
	self.tooltips:draw()
end

function game:update(dt)
	Network:update(dt)
end

function game:keypressed(key, code, isrepeat)
--	if key == 'left' then
--		self.player.direction = PlayerEntity.LeftDirection
--	end
--
--	if key == 'right' then
--		self.player.direction = PlayerEntity.RightDirection
--	end
end

function game:keyreleased(key, code)
	if key == 'escape' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

function game:mousemoved(x, y, dx, dy)
	self.tooltips:mousemoved(x, y, dx, dy)
end

return game


local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"

local Entities = require "entities"
local Network = require "network"

local game = {
	grid_background = Entities.GridClass(),
	tooltips = Entities.TooltipsClass(),
	console = Entities.ConsoleClass(),
}

function game:init()
	-- Create subs for both players
	self.player_subs = {}
	self.remote_subs = {}
	for i = 1,Constants.Game.SubCountPerTeam,1 do
		self.player_subs[i] = Entities.SubmarineClass()

		self.remote_subs[i] = Entities.SubmarineClass()
		self.remote_subs[i].team = Entities.SubmarineClass.Teams.Remote
	end
	self.console:print("Welcome to SubRugby General !", Constants.Colors.TextNormal)
	self.console:print("If you have any question hover the ? icon in the top right corner", Constants.Colors.TextNormal)
end

function game:draw()
	-- Background
	love.graphics.clear(Constants.Colors.Background)
	-- Grid
	self.grid_background:draw()
	-- Units
	for _,sub in pairs(self.player_subs) do
		sub:draw(self.grid_background)
	end
	for _,sub in pairs(self.remote_subs) do
		sub:draw(self.grid_background)
	end
	-- Console
	self.console:draw()
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


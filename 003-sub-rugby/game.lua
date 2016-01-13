local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"

local Entities = require "entities"
local Network = require "network"

local GamePhases = {
	Deployment = 0,
	Orders = 1,
	AwaitingOtherPlayer = 2,
	Resolution = 3,
	GameOver = 4,
}

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

	-- Init console
	self.console:print("Welcome to SubRugby !", Constants.Colors.TextNormal)
	self.console:print("If you have any question hover the ? icon in the top right corner.", Constants.Colors.TextNormal)

	-- Start the game
	self:setPhase(GamePhases.Deployment)
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

function game:keyreleased(key, code)
	if key == 'escape' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

function game:mousemoved(x, y, dx, dy)
	self.tooltips:mousemoved(x, y, dx, dy)
	self.grid_background:mousemoved(x, y, dx, dy)
end

function game:mousereleased(x, y, button)
	if self.current_phase == GamePhases.Deployment then
		local cell_x, cell_y = self.grid_background:cellAtCoord(x, y)
		if self.grid_background:isPlayerTeamArea(cell_x, cell_y) then
			self:deploySub(cell_x, cell_y)
		end
	end
end

function game:setPhase(phase)
	self.current_phase = phase
	if phase == GamePhases.Deployment then
		self.submarines_to_deploy = {}
		for _,v in pairs(self.player_subs) do
			if v.in_game == false and v.respawn_cooldown == 0 then
				-- TODO: add to some selection list
				table.insert(self.submarines_to_deploy, v)
			end
		end
		if #self.submarines_to_deploy > 0 then
			self.console:print("You have " .. #self.submarines_to_deploy .. " submarines to deploy.", Constants.Colors.TextInfo)
			self.grid_background:enableHovering(function(x, y) return game.grid_background:isPlayerTeamArea(x, y) end)
		else
			self:setPhase(GamePhases.Orders)
		end
	elseif phase == GamePhases.Orders then
		self.console:print("Fleet ready to receive orders.", Constants.Colors.TextInfo)

		-- Hovering functor reacts to player submarines only
		self.grid_background:enableHovering(function(x, y)
			for _,v in pairs(game.player_subs) do
				if v.in_game and v.x == x and v.y == y then
					return true
				end
			end
			return false
		end)
	elseif phase == GamePhases.AwaitingOtherPlayer then
		self.console:print("Awaiting for opponent orders.", Constants.Colors.TextInfo)
	elseif phase == GamePhases.Resolution then
	elseif phase == GamePhases.GameOver then
	end
end

function game:deploySub(cell_x, cell_y)
	-- Pop a sub
	assert(#self.submarines_to_deploy > 0)
	local sub = self.submarines_to_deploy[1]
	table.remove(self.submarines_to_deploy, 1)

	-- Fill sub data
	sub.x = cell_x
	sub.y = cell_y
	sub.in_game = true

	-- TODO: prepare serialisation data for turn RPC

	-- Check if phase change is needed
	if #self.submarines_to_deploy > 0 then
		self.console:print("Submarine deployed ( " .. #self.submarines_to_deploy .. " to go).", Constants.Colors.TextNormal)
	else
		self.console:print("Submarine deployed.", Constants.Colors.TextNormal)
		self:setPhase(GamePhases.Orders)
	end
end

return game


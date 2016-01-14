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
	grid = Entities.GridClass(),
	tooltips = Entities.TooltipsClass(),
	console = Entities.ConsoleClass(),
	orders_menu = Entities.OrdersMenuClass(),
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
	-- Create bomb
	self.bomb = Entities.BombClass()

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
	self.grid:draw()
	-- Units
	local draw_action_markers = self.current_phase == GamePhases.Orders
	for _,sub in pairs(self.player_subs) do
		sub:draw(self.grid, draw_action_markers)
	end
	for _,sub in pairs(self.remote_subs) do
		sub:draw(self.grid, false)
	end
	self.bomb:draw(self.grid)
	-- Console
	self.console:draw()
	-- Orders menu
	self.orders_menu:draw()
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
	self.grid:mousemoved(x, y, dx, dy)
	self.orders_menu:mousemoved(x, y, dx, dy)
end

function game:mousereleased(x, y, button)
	local cell_x, cell_y = self.grid:cellAtCoord(x, y)

	if self.current_phase == GamePhases.Deployment then
	-- DEPLOYMENT PHASE --
		if self.grid:isPlayerTeamArea(cell_x, cell_y) and self:playerSubAtCoord(cell_x, cell_y) == nil then
			self:deploySub(cell_x, cell_y)
		end

	elseif self.current_phase == GamePhases.Orders then
	-- ORDERS PHASE --
		local player_sub_clicked = self:playerSubAtCoord(cell_x, cell_y)
		if player_sub_clicked ~= nil then
			self.orders_menu:selectSub(player_sub_clicked)
		end

	end
end

function game:setPhase(phase)
	self.current_phase = phase

	if phase == GamePhases.Deployment then
	-- DEPLOYMENT PHASE --
		-- Build submarines to deploy list
		self.submarines_to_deploy = {}
		for _,v in pairs(self.player_subs) do
			if v.in_game == false and v.respawn_cooldown == 0 then
				table.insert(self.submarines_to_deploy, v)
			end
		end

		if #self.submarines_to_deploy > 0 then
			-- Begin deploying submarines
			self.console:print("You have " .. #self.submarines_to_deploy .. " submarines to deploy.", Constants.Colors.TextInfo)

			-- Hovering functor reacts to free spots in player area
			self.grid:enableHovering(function(x, y)
				return (game.grid:isPlayerTeamArea(x, y) and game:playerSubAtCoord(x, y) == nil)
			end)
		else
			-- No submarines to deploy (skipping this phase)
			self:setPhase(GamePhases.Orders)
		end

	elseif phase == GamePhases.Orders then
	-- ORDERS PHASE --
		self.console:print("Fleet ready to receive orders.", Constants.Colors.TextInfo)

		-- Hovering functor reacts to player submarines only
		self.grid:enableHovering(function(x, y) return game:playerSubAtCoord(x, y) ~= nil end)

	elseif phase == GamePhases.AwaitingOtherPlayer then
	-- AWAITING OTHER PLAYER PHASE --
		self.console:print("Awaiting for opponent orders.", Constants.Colors.TextInfo)

	elseif phase == GamePhases.Resolution then
	-- TURN RESOLUTION PHASE --

	elseif phase == GamePhases.GameOver then
	-- GAME OVER PHASE --
	end
end

function game:deploySub(cell_x, cell_y)
	-- Pop a submaring from the list of submarines to deploy
	assert(#self.submarines_to_deploy > 0)
	local sub = self.submarines_to_deploy[1]
	table.remove(self.submarines_to_deploy, 1)

	-- Fill submarine data
	sub.x = cell_x
	sub.y = cell_y
	sub.direction = Entities.SubmarineClass.Directions.East -- Player faces East
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

function game:playerSubAtCoord(x, y)
	for _,sub in pairs(self.player_subs) do
		if sub.in_game and sub.x == x and sub.y == y then
			return sub
		end
	end
	return nil
end

return game


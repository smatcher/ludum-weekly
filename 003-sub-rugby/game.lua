local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"
local Binary = require "love-toys.third-party.binary"

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

function game:enter()
	Network.callbacks.recv = function(data, client)
		self.remote_packet = data
	end
end

function game:leave()
	Network.callbacks.recv = nil
end

function game:init()
	-- Create subs for both players
	self.player_subs = {}
	self.remote_packet = nil
	self.remote_subs = {}
	for i = 1,Constants.Game.SubCountPerTeam,1 do
		self.player_subs[i] = Entities.SubmarineClass()

		self.remote_subs[i] = Entities.SubmarineClass()
		self.remote_subs[i].team = Entities.SubmarineClass.Teams.Remote
	end
	-- Create bomb
	self.bomb = Entities.BombClass()

	-- Create torpedoes
	self.torpedoes = {}

	-- Init console
	self.console:print("Welcome to SubRugby !", Constants.Colors.TextNormal)
	self.console:print("If you have any question hover the ? icon in the top right corner.", Constants.Colors.TextNormal)

	-- Misc
	self.submit_button_visible = false
	self.submit_button_hovered = false

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
	-- Submit button
	if self.submit_button_visible then
		if self.submit_button_hovered then
			love.graphics.setColor(Constants.Colors.SubmitHovered)
		else
			love.graphics.setColor(Constants.Colors.Submit)
		end
		love.graphics.rectangle("fill",
			Constants.Submit.DrawX,
			Constants.Submit.DrawY,
			Constants.Submit.DrawWidth,
			Constants.Submit.DrawHeight,
			Constants.Submit.DrawRadius
		)
		love.graphics.setColor(Constants.Colors.Default)
		love.graphics.print("Send orders",
			Constants.Submit.DrawX + Constants.Submit.TextOffsetX,
			Constants.Submit.DrawY + Constants.Submit.TextOffsetY
		)
	end
	-- Tooltips
	self.tooltips:draw()
end

function game:update(dt)
	Network:update(dt)
	Timer.update(dt)

	self.submit_button_visible = false
	if self.current_phase == GamePhases.Orders then
		self.submit_button_visible = true
		for _,s in pairs(self.player_subs) do
			if s.in_game and not s:ordersGiven() then
				self.submit_button_visible = false
			end
		end
	elseif self.current_phase == GamePhases.AwaitingOtherPlayer then
		if self.remote_packet ~= nil then
			self:decodeRemotePacket()
			self.remote_packet = nil
			self:setPhase(GamePhases.Resolution)
		end
	end
end

function game:keyreleased(key, code)
	if key == 'escape' then
		Network:abort()
		GameState.switch(states.Menu)
	end
end

local function hitSubmit(x, y)
	return (x > Constants.Submit.DrawX
		and x < Constants.Submit.DrawX + Constants.Submit.DrawWidth 
		and y > Constants.Submit.DrawY
		and y < Constants.Submit.DrawY + Constants.Submit.DrawHeight 
	)
end

function game:mousemoved(x, y, dx, dy)
	self.tooltips:mousemoved(x, y, dx, dy)
	self.grid:mousemoved(x, y, dx, dy)
	self.orders_menu:mousemoved(x, y, dx, dy)

	self.submit_button_hovered = hitSubmit(x, y)
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
		self.orders_menu:mousereleased(x, y, button)
		if self.submit_button_visible and hitSubmit(x, y) then
			-- send orders and change phase
			self.orders_menu:unselectSub()
			self:setPhase(GamePhases.AwaitingOtherPlayer)
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
		Network:sendPacket(self:buildTurnInfoPacket())

		self.grid:disableHovering()

		if Network:isConnected() then
			if self.remote_packet == nil then
				self.console:print("Awaiting for opponent orders.", Constants.Colors.TextInfo)
			end
		else
			self.console:print("No opponent connected.", Constants.Colors.TextAlert)
			self:setPhase(GamePhases.Resolution)
		end

	elseif phase == GamePhases.Resolution then
	-- TURN RESOLUTION PHASE --
		self.console:print("Resolving turn.", Constants.Colors.TextInfo)
		-- TODO : play a resolve animation
		-- Reset bleep
		for _,sub in pairs(self.player_subs) do sub.sonar_bleep = false end
		-- Resolve actions
		self:resolveAction(1)
		self:resolveAction(2)
		-- TODO : also wait or something
		for _,sub in pairs(self.player_subs) do sub:resetOrders() end
		for _,sub in pairs(self.remote_subs) do sub:resetOrders() end
		self:setPhase(GamePhases.Deployment)

	elseif phase == GamePhases.GameOver then
	-- GAME OVER PHASE --
	end
end

function game:resolveAction(suffix)
	-- Move and rotate subs
	for _,sub in pairs(self.player_subs) do
		sub:resolveAction(sub["action_" .. suffix], self.torpedoes)
	end
	for _,sub in pairs(self.remote_subs) do
		sub:resolveAction(sub["action_" .. suffix], self.torpedoes)
	end
	-- Move torpedoes

	-- check destroyed subs

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

function game:buildTurnInfoPacket()
	local t = {}
	for i,sub in pairs(self.player_subs) do
		t["X"  .. i] = sub.x
		t["Y"  .. i] = sub.y
		t["IG" .. i] = sub.in_game
		t["D"  .. i] = sub.direction
		t["A1" .. i] = sub.action_1
		t["A2" .. i] = sub.action_2
	end
	return Binary:pack(t)
end

function game:decodeRemotePacket()
	local t = Binary:unpack(self.remote_packet)
	local function flipTurnOrder(action)
			if action ~= nil
			and action >= Entities.SubmarineClass.Actions.Turn_N
			and action <= Entities.SubmarineClass.Actions.Turn_NW then
				return 10 + ((action - 6)%8)
			end
			return action
	end

	for i,sub in pairs(self.remote_subs) do
		sub.x = Constants.Grid.Width - t["X" .. i] - 1 -- Flip x
		sub.y = Constants.Grid.Height - t["Y" .. i] - 1 -- Flip y
		sub.in_game = t["IG" .. i]
		sub.direction = (t["D" .. i] + 4) % 8 -- Flip 180 degrees
		sub.action_1 = flipTurnOrder(t["A1" .. i])
		sub.action_2 = flipTurnOrder(t["A2" .. i])
	end
end

return game


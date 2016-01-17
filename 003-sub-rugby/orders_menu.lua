local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = require "submarine"

local OrdersMenuClass = Class {}

local OrderButton = Class {
	init = function(self, code, label, info, width, not_stealthy)
		self.code = code
		self.label = label
		self.hovered = false
		self.enabled = true
		self.width = width
		self.info = info
		self.bomb = nil

		if not_stealthy == true then
			self.warn = true
		else
			self.warn = false
		end
	end,

	setPosition = function(self, x, y)
		self.x = x
		self.y = y
	end,

	draw = function(self)
		local x = self.x
		local y = self.y
		if self.enabled then
			if self.hovered then
				if self.warn then
					love.graphics.setColor({128, 64, 34, 192})
				else
					love.graphics.setColor({64, 128, 255, 192})
				end
				love.graphics.rectangle("fill", x-2, y-2, self.width, Constants.OrdersMenu.LineHeight)
				if self.warn then
					love.graphics.setColor(Constants.Colors.TextHoveredAlert)
				else
					love.graphics.setColor(Constants.Colors.TextHovered)
				end
			else
				if self.warn then
					love.graphics.setColor(Constants.Colors.TextAlert)
				else
					love.graphics.setColor(Constants.Colors.TextNormal)
				end
			end
		else
			love.graphics.setColor(Constants.Colors.TextDisabled)
		end
		love.graphics.print(self.label, x, y)
		love.graphics.rectangle("line", x-2, y-2, self.width, Constants.OrdersMenu.LineHeight)
	end,

	hit = function(self, x, y)
		if x < self.x
		or x > self.x + self.width
		or y < self.y
		or y > self.y + Constants.OrdersMenu.LineHeight then
			return false
		end
		return true
	end,
}

function OrdersMenuClass:init()
	self.visible = false
	self.selected_sub = nil
	self.info_text = ""
	self.actions_description = ""

	local A = SubmarineClass.Actions

	self.move_orders = {
		OrderButton(A.Move_1, "Move 1", "Move forward 1 cell", 60),
		OrderButton(A.Move_2, "Move 2", "Move forward 2 cells", 60),
		OrderButton(A.Move_3, "Move 3*", "Move forward 3 cells *NON STEALTHY*", 60, true),
		OrderButton(A.Move_4, "Move 4*", "Move forward 4 cells *NON STEALTHY*", 60, true),
		OrderButton(A.Move_5, "Move 5*", "Move forward 5 cells *NON STEALTHY* *TAKES 2 ACTIONS*", 60, true),
		OrderButton(A.Move_6, "Move 6*", "Move forward 6 cells *NON STEALTHY* *TAKES 2 ACTIONS*", 60, true),
	}

	self.turn_orders = {
		OrderButton(A.Turn_NW, "NW", "Turn the submarine to face north-west", 30),
		OrderButton(A.Turn_N , "N" , "Turn the submarine to face north", 30),
		OrderButton(A.Turn_NE, "NE", "Turn the submarine to face north-east", 30),
		OrderButton(A.Turn_W , "W" , "Turn the submarine to face west", 30),
		nil,
		OrderButton(A.Turn_E , "E" , "Turn the submarine to face east", 30),
		OrderButton(A.Turn_SW, "SW", "Turn the submarine to face south-west", 30),
		OrderButton(A.Turn_S , "S" , "Turn the submarine to face south", 30),
		OrderButton(A.Turn_SE, "SE", "Turn the submarine to face south-east", 30),
	}

	self.interact_orders = {
		OrderButton(A.Fire,    "Fire*"  , "Fire a torpedo *NON STEALTHY*", 60, true),
		--OrderButton(A.Special, "Special", "NOT IMPLEMENTED", 60),
		OrderButton(A.Grab,    "Grab"   , "Grab the bomb", 60),
	}

	self.other_orders = {
		OrderButton(A.Wait, "Wait",   "Do nothing", 60),
		OrderButton(nil,    "Cancel", "Cancel orders", 60),
	}

	self:computeOrdersPositions()
end

function OrdersMenuClass:computeOrdersPositions()
	local column_padding = 10
	local header_height = 30

	local header_y = Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY
	local start_x = Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX
	local start_y = header_y + header_height

	for k,v in pairs(self.move_orders) do
		local x = start_x + ((k-1)%2) * v.width
		local y = start_y + math.floor((k-1)/2) * Constants.OrdersMenu.LineHeight
		v:setPosition(x, y)
	end

	start_x = start_x + 2*self.move_orders[1].width + column_padding
	for k,v in pairs(self.turn_orders) do
		local x = start_x + ((k-1)%3) * v.width
		local y = start_y + math.floor((k-1)/3) * Constants.OrdersMenu.LineHeight
		v:setPosition(x, y)
	end

	start_x = start_x + 3*self.turn_orders[1].width + column_padding
	for k,v in pairs(self.interact_orders) do
		v:setPosition(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end

	start_x = start_x + self.interact_orders[1].width + column_padding
	for k,v in pairs(self.other_orders) do
		v:setPosition(start_x, start_y + (k-1) * Constants.OrdersMenu.LineHeight)
	end
end

function OrdersMenuClass:draw()
	if self.visible == false then
		return
	end

	love.graphics.setColor(Constants.Colors.OrdersMenuBackground)
	love.graphics.rectangle("fill",
		Constants.OrdersMenu.DrawX,
		Constants.OrdersMenu.DrawY,
		Constants.OrdersMenu.DrawWidth,
		Constants.OrdersMenu.DrawHeight,
		Constants.OrdersMenu.DrawRadius
	)

	local column_padding = 10
	local header_height = 20

	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print(self.info_text,
		Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX,
		Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY + 5*Constants.OrdersMenu.LineHeight
	)

	love.graphics.print(self.actions_description,
		Constants.OrdersMenu.DrawX + Constants.OrdersMenu.ActionDescriptionOffsetX,
		Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY
	)

	local header_y = Constants.OrdersMenu.DrawY + Constants.OrdersMenu.TextOffsetY
	local start_x = Constants.OrdersMenu.DrawX + Constants.OrdersMenu.TextOffsetX
	local start_y = header_y + header_height
	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print("Move:", start_x, header_y)
	for k,v in pairs(self.move_orders) do
		v:draw()
	end

	start_x = start_x + 2*self.move_orders[1].width + column_padding
	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print("Turn:", start_x, header_y)
	for k,v in pairs(self.turn_orders) do
		v:draw()
	end

	start_x = start_x + 3*self.turn_orders[1].width + column_padding
	love.graphics.setColor(Constants.Colors.TextInfo)
	love.graphics.print("Interact:", start_x, header_y)
	for k,v in pairs(self.interact_orders) do
		v:draw()
	end

	start_x = start_x + self.interact_orders[1].width + column_padding
	for k,v in pairs(self.other_orders) do
		v:draw()
	end

end

function OrdersMenuClass:updateAvailableOrders()
	local function actionToLabel(action)
		if action == nil then
			return false, "..."
		end
		for _,o in pairs(self.move_orders)     do if o.code == action then return true, o.label end end
		for _,o in pairs(self.turn_orders)     do if o.code == action then return true, o.label end end
		for _,o in pairs(self.interact_orders) do if o.code == action then return true, o.label end end
		for _,o in pairs(self.other_orders)    do if o.code == action then return true, o.label end end
		return true, "UNKOWN"
	end

	local has_action1, action1_label = actionToLabel(self.selected_sub.action_1)
	local has_action2, action2_label = actionToLabel(self.selected_sub.action_2)
	if not has_action1 and not has_action2 then
		self.actions_description = "No orders given"
	elseif action1_label == "Move 5" or action1_label == "Move 6" then
		self.actions_description = "Orders: " .. action1_label .. " (will take both actions)"
	else
		self.actions_description = "Orders: " .. action1_label .. ", " .. action2_label
	end

	
	local has_any_free_action = true
	-- Move5 and Move6 take both actions
	if self.selected_sub.action_1 == SubmarineClass.Actions.Move_5
	or self.selected_sub.action_1 == SubmarineClass.Actions.Move_6 then
		has_any_free_action = false
	end
	-- Both actions are taken
	if self.selected_sub.action_1 ~= nil
	and self.selected_sub.action_2 ~= nil then
		has_any_free_action = false
	end

	local function hasActionInCategory(c)
		for _,o in pairs(c) do
			if self.selected_sub.action_1 == o.code
			or self.selected_sub.action_2 == o.code then
				return true
			end
		end
		return false
	end

	local can_move = has_any_free_action and not hasActionInCategory(self.move_orders)
	local can_turn = has_any_free_action and not hasActionInCategory(self.turn_orders)
	local can_interact = has_any_free_action and not hasActionInCategory(self.interact_orders)
	local can_other = has_any_free_action

	-- Move orders
	for _,o in pairs(self.move_orders) do o.enabled = can_move end
	if has_action1 then
		self.move_orders[5].enabled = false
		self.move_orders[6].enabled = false
	end
	-- Turn orders
	for _,o in pairs(self.turn_orders) do o.enabled = can_turn end
	if can_turn then
		local d = self.selected_sub.direction
		local ds = SubmarineClass.Directions
		if d == ds.North then
			self.turn_orders[2].enabled = false
		elseif d == ds.NorthEast then
			self.turn_orders[3].enabled = false
		elseif d == ds.East then
			self.turn_orders[6].enabled = false
		elseif d == ds.SouthEast then
			self.turn_orders[9].enabled = false
		elseif d == ds.South then
			self.turn_orders[8].enabled = false
		elseif d == ds.SouthWest then
			self.turn_orders[7].enabled = false
		elseif d == ds.West then
			self.turn_orders[4].enabled = false
		elseif d == ds.NorthWest then
			self.turn_orders[1].enabled = false
		end
	end
	-- Interact orders
	for _,o in pairs(self.interact_orders) do o.enabled = can_interact end
	-- Grab bomb if we are over it
	local sub_is_over_bomb = self.selected_sub.x == self.bomb.x and self.selected_sub.y == self.bomb.y
	self.interact_orders[2].enabled = sub_is_over_bomb and can_interact
	-- Other orders
	for _,o in pairs(self.other_orders) do o.enabled = can_other end

	-- Always enabled
	self.other_orders[2].enabled = true
end

function OrdersMenuClass:selectSub(sub)
	self:unselectSub()
	self.selected_sub = sub
	self.selected_sub.selected = true
	self.visible = true
	self:updateAvailableOrders()
end

function OrdersMenuClass:unselectSub()
	if self.selected_sub ~= nil then
		self.selected_sub.selected = false
	end
	self.selected_sub = nil
	self.visible = false
end

function OrdersMenuClass:mousemoved(x, y, dx, dy)
	self.info_text = ""
	local function updateHovered(t)
		for _,o in pairs(t) do
			o.hovered = o:hit(x,y)
			if o.hovered then
				self.info_text = o.info
			end
		end
	end
	updateHovered(self.move_orders)
	updateHovered(self.turn_orders)
	updateHovered(self.interact_orders)
	updateHovered(self.other_orders)
end

function OrdersMenuClass:mousereleased(x, y, button)
	if self.visible == false then
		return
	end

	local function handleClick(t)
		for _,o in pairs(t) do
			if o.enabled and o:hit(x, y) then
				if o.code == nil then
					self.selected_sub.action_1 = nil
					self.selected_sub.action_2 = nil
				elseif self.selected_sub.action_1 == nil then
					self.selected_sub.action_1 = o.code
				else
					self.selected_sub.action_2 = o.code
				end
				self:updateAvailableOrders()
			end
		end
	end
	handleClick(self.move_orders)
	handleClick(self.turn_orders)
	handleClick(self.interact_orders)
	handleClick(self.other_orders)
end

return OrdersMenuClass


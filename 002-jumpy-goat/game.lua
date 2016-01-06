local Camera = require "love-toys.third-party.hump.camera" 
local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"

require "entities"

local game = {
	high_score = 0
}

local goat_to_platform_offset = 64

function game:init()
	self.player = PlayerEntity(Vector(400, 400))
	self.background = BackgroundEntity()
	self.platforms = {}
	self.timer = Timer.new()
	self.score = 0

	-- Init camera
	self.cameraTarget = Vector(self.player.position.x, self.player.position.y)
	self:updateCameraTarget()
	self.camera = Camera(self.cameraTarget.x, self.cameraTarget.y)
	self.camera.smoother = function(dx, dy)
		local dt = 3.5 * love.timer.getDelta()
		return dt*dx, dt*dy
	end

	self.timer.after(1.0, function() self:jumpPlayer() end)
end

function game:generatePlatforms()
	if next(self.platforms) == nil then
		-- Initial fill
		table.insert(self.platforms, PlatformEntity(Vector(400, 400 + goat_to_platform_offset)))
	self.current_platform = 1
	end

	local max_offscreen_y = self.camera.y + 500 -- if a platform is below this value it is offscreen and must be destroyed (remember y points down so a lower value means it's higher onscreen)
	local min_offscreen_y = self.camera.y - 500 -- the last platform should be at least as hight as this

	-- Create new platform offscreen
	local x = self.platforms[#self.platforms].position.x
	local y = self.platforms[#self.platforms].position.y
	while y > min_offscreen_y do
		local dir = math.random(0, 1)
		local jiggle_x = math.random(-35, 35)
		local jiggle_y = math.random(-25, 25)
		if dir == 0 then
			x = x + 100 + jiggle_x
		else
			x = x - 100 + jiggle_x
		end
		y = y - 100 + jiggle_y
		table.insert(self.platforms, PlatformEntity(Vector(x, y)))
	end

	-- Dump platforms under the screen
	while self.platforms[1].position.y > max_offscreen_y do
		table.remove(self.platforms, 1)
		self.current_platform = self.current_platform - 1
	end

end

function game:updateCameraTarget()
	self.cameraTarget.x = self.player.position.x
	self.cameraTarget.y = self.player.position.y - 150
end

function game:jumpPlayer()
	local next_platform = self.platforms[self.current_platform + 1]
	local new_x = next_platform.position.x
	local new_y = next_platform.position.y - goat_to_platform_offset
	local jump_time = 0.3
	local next_jump_time = 0.5

	local next_platform_direction = PlayerEntity.RightDirection
	if self.player.position.x > next_platform.position.x then
		next_platform_direction = PlayerEntity.LeftDirection
	end

	if self.player.direction == next_platform_direction then
		-- Jump to the next step update score and what not
		self.score = self.score + 1
		self.current_platform = self.current_platform + 1
		self.timer.tween(jump_time, self.player.position, { y = new_y }, 'out-back')
		self.timer.tween(jump_time, self.player.position, { x = new_x })
		self.timer.after(jump_time, function() self:updateCameraTarget() end)
		self.timer.after(next_jump_time, function() self:jumpPlayer() end)
	else
		-- Go to fail state
		new_x = 2 * self.player.position.x - new_x
		self.timer.tween(1.5 * jump_time, self.player.position, { y = new_y }, 'out-back', function() self.timer.tween(jump_time, self.player.position, { y = new_y + 300 }) end)
		self.timer.tween(2.5 * jump_time, self.player.position, { x = new_x })
		self.timer.after(3, function() self:init() end)

		self.high_score = math.max(self.high_score, self.score)
	end
end

function game:draw()
	self.background:draw(self.camera)
	love.graphics.print("Score : " .. self.score, 10, 10)
	love.graphics.print("High score : " .. self.high_score, 10, 30)

	self.camera:attach()
	for _, platform in pairs(self.platforms) do
		platform:draw()
	end
	self.player:draw()
	self.camera:detach()
end

function game:update(dt)
	self.timer.update(dt)
	self.camera:lockPosition(self.cameraTarget.x, self.cameraTarget.y)
	self:generatePlatforms()
end

function game:keypressed(key, code, isrepeat)
	if key == 'left' then
		self.player.direction = PlayerEntity.LeftDirection
	end

	if key == 'right' then
		self.player.direction = PlayerEntity.RightDirection
	end
end

function game:keyreleased(key, code)
	if key == 'escape' then
		GameState.switch(states.Menu)
	end
end

return game


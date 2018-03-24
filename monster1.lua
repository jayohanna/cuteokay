local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'

local MonsterOne = class('MonsterOne', Entity)

local width, height = 10, 10
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

function MonsterOne:initialize(world, x,y)
  Entity.initialize(self, world, x, y, width, height)
  self.world = world
  self.timer = Timer()
  self.timer:every(4, function() 
  	self.leftKey = true 
  	self.rightKey = false
  	self.timer:after(2, function()
  		self.leftKey = false 
  		self.rightKey = true
  	end) 
  end)
end

function MonsterOne:AI(dt)

end

function MonsterOne:hit()
	self:destroy()
end

function MonsterOne:applyMovement(dt)

	local dx, dy = self.dx, self.dy

		if self.leftKey then
			if dx > -hspeed  then 
				dx = dx - haccel * dt
			end
			self.Sx = -1 
		end
		if self.rightKey then
			if dx < hspeed  then
				dx = dx + haccel * dt
			end
			self.Sx = 1
		end

		self.dx, self.dy = dx, dy

		if not (self.leftKey or self.rightKey) then
			self.dx = self.dx * math.pow(friction, dt)
		end

end


function MonsterOne:checkOnGround(ny)
  if ny < 0  then 
  	self.onGround = true
  end
end

function MonsterOne:moveCollision(dt)

	self.onGround = false

	local world = self.world
	local tx = self.x + self.dx * dt
	local ty = self.y + self.dy * dt 

	local rx, ry, cols, len = world:move(self, tx, ty, self.filter)

	for i=1, len do 
		local col = cols[i]
		self:checkOnGround(col.normal.y) 
	end

	self.x, self.y = rx, ry
end

function MonsterOne:update(dt)
	self.timer:update(dt)
	self:AI(dt)
	self:applyGravity(dt)
	self:applyMovement(dt)
	self:moveCollision(dt)
end

function MonsterOne:draw()
	love.graphics.rectangle('fill', self.x, self.y, width, height)
end

return MonsterOne
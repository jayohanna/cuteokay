local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'

local MonsterTwo = require 'monster2'

local MonsterOne = class('MonsterOne', Entity)
MonsterOne:include(Stateful)

local width, height = 10, 5
local friction = 0.00005

local hspeed = 20
local haccel = 500

local jumpSpeed = -200

local img = love.graphics.newImage('sprites/firstform.png')
local grid = anim8.newGrid(16, 16, img:getWidth(), img:getHeight())
local anim = anim8.newAnimation(grid('1-3', 1), 0.3)

local dmg_img = love.graphics.newImage('sprites/firstformdamaged.png')
local dmg_grid = anim8.newGrid(20, 16, dmg_img:getWidth(), dmg_img:getHeight())
local dmg_anim = anim8.newAnimation(dmg_grid(1, '1-5'), 0.1, 'pauseAtEnd')


local trs_img = love.graphics.newImage('sprites/firstformtransforming.png')
local trs_grid = anim8.newGrid(20, 16, trs_img:getWidth(), trs_img:getHeight())
local trs_anim = anim8.newAnimation(trs_grid(1, '1-7'), 0.3, 'pauseAtEnd')

function MonsterOne:initialize(game, world, x,y)
  Entity.initialize(self, world, x, y, width, height)

  self.game = game
  self.img = img 
  self.anim = anim
  self.enemy = true
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
	self:gotoState('OnHit')
end

function MonsterOne:applyMovement(dt)

	local dx, dy = self.dx, self.dy

		if self.leftKey then
			if dx > -hspeed  then 
				dx = dx - haccel * dt
			end
			self.Sx = 1 
		end
		if self.rightKey then
			if dx < hspeed  then
				dx = dx + haccel * dt
			end
			self.Sx = -1
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

function MonsterOne:filter(other)
	if other.passable then 
		return false 
	else
		return 'slide'
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
	self.anim:update(dt)
end

function MonsterOne:draw()
--	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	self.anim:draw(self.img, self.x+4, self.y, 0, self.Sx, 1, 8, 11)
end

local OnHit = MonsterOne:addState('OnHit')

function OnHit:enteredState()
	self.img = dmg_img
	self.anim = dmg_anim
	self.timer:after(0.5, function() 
		self.img = trs_img 
		self.anim = trs_anim
		self.timer:after(2.1, function()
			MonsterTwo:new(self.game, self.world, self.x, self.y)
			self:destroy()
			end)
	  end)
end

function OnHit:moveCollision()
	end

return MonsterOne
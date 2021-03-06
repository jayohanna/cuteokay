local Entity = require 'entity'
local class = require 'lib.middleclass'
local Timer = require 'lib.timer'
local anim8 = require 'lib.anim8'
local Stateful = require 'lib.stateful'
local Debris = require 'debris'
local Projectile = require 'projectile'

local debris1 = love.graphics.newImage('sprites/debris1.png')
local debris2 = love.graphics.newImage('sprites/debris2.png')
local debris3 = love.graphics.newImage('sprites/debris3.png')

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
  self.damaging = true
  self.world = world
 	self.drawOrder = 2
  self.timer = Timer()
  self.Sx = 1
  Projectile:new(self.world, x, y-11, 8, 8,  -100*self.Sx)
  self.timer:every(2, function() 
  	if not self.dying then 
  		local x, y = self:getCenter()
  		Projectile:new(self.world, x, y-11, 8, 8,  -100*self.Sx)
  	end
  end)
end

function MonsterOne:AI(dt)

end

function MonsterOne:hit()
	self:gotoState('OnHit')
end

function MonsterOne:applyMovement(dt)

	local dx, dy = self.dx, self.dy

		if self.game.player.x < self.x then
			if dx > -hspeed  then 
				dx = dx - haccel * dt
			end
			self.Sx = 1 
		end
		if self.game.player.x > self.x then
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

	if col.other.player == true then 
		col.other:die()
	end
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
	hit:play()
	local x, y = self:getCenter()
		
	self.dying = true
	music1:setVolume(0.8)	
	music1:setVolume(0.7)	
	music1:setVolume(0.6)	
	music1:setVolume(0.5)	
	music1:setVolume(0.4)	
	music1:setVolume(0.3)	
	music1:setVolume(0.2)	
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris1, 200)
	Debris:new(self, self.world, x, y, debris2, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)
	Debris:new(self, self.world, x, y, debris3, 200)

	self.game.player.movable = false 
	self.game.player:gotoState(nil)
	self.game.player.timer:after(1, function() self.game.player.movable = true end)
	self.game.player.dy = -200

	if self.x > self.game.player.x then
		self.game.player.dx = -150
	else 
		self.game.player.dx = 150
	end


	self.game.camera:screenShake(0.1, 5,5)
	self.img = dmg_img
	self.anim = dmg_anim
		self.anim:gotoFrame(1)
		self.anim:resume()

	self.timer:tween(2.1, self.game.backgroundcolor, {r = 116, g = 92, b = 116}, 'linear')

	self.timer:after(0.5, function() 
		self.img = trs_img 
		self.anim = trs_anim
		self.anim:gotoFrame(1)
		
		self.anim:resume()
		self.timer:after(2.1, function()
			MonsterTwo:new(self.game, self.world, self.x, self.y-16)
		music1:stop()
music1:setVolume(1)
music2:play()
music2:setLooping(true)
			self:destroy()
			end)
	  end)
end

function OnHit:moveCollision()
	end

return MonsterOne
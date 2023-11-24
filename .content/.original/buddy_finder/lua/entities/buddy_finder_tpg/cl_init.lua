--BuddyFinder Addon clientside laserbox entity code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: Draws a laser dimension box for buddyfinder

include('shared.lua')

local Laser = Material( "cable/redlaser" )

--laser draw help
function ENT:DrawLaser(fromVec, toVec)
  render.DrawBeam(fromVec, toVec, 5, 0, 0, Color( 255, 255, 255, 255 ) )
end

--draw the laser placement box
function ENT:Draw() 
  local LowTopLeft, HiBottomRight = self.Entity:WorldSpaceAABB()
  local LowTopRight    = Vector(HiBottomRight.x, LowTopLeft.y, LowTopLeft.z)
  local LowBottomLeft  = Vector(LowTopLeft.x, HiBottomRight.y, LowTopLeft.z)
  local LowBottomRight = Vector(LowTopRight.x, HiBottomRight.y, LowTopRight.z)
  local HiTopLeft      = Vector(LowTopLeft.x, LowTopLeft.y, HiBottomRight.z)
  local HiTopRight     = Vector(LowTopRight.x, HiTopLeft.y, HiTopLeft.z)
  local HiBottomLeft   = Vector(HiTopLeft.x, LowBottomLeft.y, HiTopLeft.z)
  
  render.SetMaterial(Laser)

  --box
  
  --diags
  self:DrawLaser(LowTopLeft, HiBottomRight)
  self:DrawLaser(LowBottomRight, HiTopLeft)
  self:DrawLaser(LowTopRight, HiBottomLeft)
  self:DrawLaser(LowBottomLeft, HiTopRight)  

  --prism

  --lower pane
  self:DrawLaser(LowTopLeft, LowTopRight)
  self:DrawLaser(LowTopRight, LowBottomRight)
  self:DrawLaser(LowBottomRight, LowBottomLeft)
  self:DrawLaser(LowBottomLeft, LowTopLeft)
  --upper pane
  self:DrawLaser(HiTopLeft, HiTopRight)
  self:DrawLaser(HiTopRight, HiBottomRight)
  self:DrawLaser(HiBottomRight, HiBottomLeft)
  self:DrawLaser(HiBottomLeft, HiTopLeft)
  --side lines
  self:DrawLaser(HiTopLeft, LowTopLeft)
  self:DrawLaser(HiTopRight, LowTopRight)
  self:DrawLaser(HiBottomLeft, LowBottomLeft)
  self:DrawLaser(HiBottomRight, LowBottomRight)
  
end

--yes, this is translucent
function ENT:IsTranslucent()
	return true
end

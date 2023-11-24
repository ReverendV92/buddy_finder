--BuddyFinder Addon serverside laserbox entity code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: Draws a laser dimension box for buddyfinder

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

--set up the basic details of the laser box
function ENT:Initialize()
  Dbg('LaserBox ENT:Initialize()')
  local ply = self.Entity:GetOwner()
  self.Entity:SetSolid(SOLID_NONE)
  self.Entity:SetMoveType(MOVETYPE_NONE)
  self.Entity:PhysicsInitBox(self.MinExt, self.MaxExt)
  self.Entity:SetCollisionBounds(self.MinExt, self.MaxExt)
  self.Entity:DrawShadow(false)
  --if the owner is an NPC then we add a self-destruct timer that
  --will automatically allow us to teleport (for debugging with buddy)
  if (ply != nil) 
  and (ply != NULL)
  and (ply:IsNPC()) then
    self.NPCMode = true
    timer.Create("Self-destruct", 3, 1, function() self:Remove() end)
  else
    self.NPCMode = false
  end 
  Dbg('LaserBox ENT:Initialize()^')
end

--originally this code was in the cl_init.lua and was much smoother
--but for now I have moved it to the server because I found that client
--code is only executed when the player is in a set range
function ENT:Think()
  local ply = self.Entity:GetOwner()
  if (ply == nil) or (ply == NULL) then
    return
  end
  --for an NPC, we stand 50 units diagonally from them
  if self.NPCMode then
    self.Entity:SetPos(ply:GetPos() + Vector(50, 50, 0))
    self.Entity:NextThink(CurTime() + 0.1)
    return
  else
    --this positions the laser box for the player
    local pos = ply:GetShootPos()
    local tracedata = {}
    tracedata.start = pos
    tracedata.endpos = pos + (ply:GetAimVector() * 300)
    tracedata.filter = {ply, self.Entity}
    local trace = util.TraceLine(tracedata)
    self.Entity:SetPos(trace.HitPos)
    self.Entity:NextThink(CurTime() + 0.1)
  end
end

--removing the laser box sends out teleport locations
--if the sender has a buddy finder
function ENT:OnRemove()
  Dbg('LaserBox ENT:OnRemove()')
  local pos = self.Entity:GetPos()
  local bf = GetBuddyFinder(self.Entity:GetOwner())
  bf:SetTeleportLocation(pos.x, pos.y, pos.z)
  Dbg('LaserBox ENT:OnRemove()^')
end

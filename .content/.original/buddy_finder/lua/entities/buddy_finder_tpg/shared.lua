--BuddyFinder Addon shared laserbox entity code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: Draws a laser dimension box for buddyfinder

ENT.Type = "anim"
ENT.Base = "base_gmodentity" 

--we are a 32x32x72 box
--human player hull + 1 padding
--with origin at 0,0,0
ENT.MinExt = Vector(-16.5, -16.5, 0)
ENT.MaxExt = Vector(16.5, 16.5, 73)


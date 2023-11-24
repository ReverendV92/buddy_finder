--BuddyFinder Addon serverside SWEP code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: The SWEP - teleporting and funky business

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight =	5
SWEP.AutoSwichTo =	false
SWEP.AutoSwichFrom =	false

--if the owner is an NPC then we call an alternate routine as
--the NPC doesn't have a clientside
function SWEP:SafeCallOnClient(routine, params)
  if (self.Weapon:GetOwner() == NULL) then
    return  
  elseif (self.Weapon:GetOwner():IsNPC()) then
    self:NPCCallOnClient(routine, params)
  else
    self.Weapon:CallOnClient(routine, params)
  end
end

--the first thing we do is tidy up - just in case
function SWEP:Initialize()
  self:FinishCall()
end

--returns true if this BuddyFinder is busy
--can also set this property
function SWEP:BuddyFinderBusy(isBusy)
  if (isBusy == nil) then
    return self.Weapon:GetNWBool(self.BuddyFinderBusyVarName)
  else
    self.Weapon:SetNWBool(self.BuddyFinderBusyVarName, isBusy)
  end
end

--I am unsure as to whether this is working properly or not
--but this should fade the tunnels out
function SWEP:FadeFunc(tunnel)
  local fadeval = tunnel:GetKeyValues().renderamt
  if (fadeval == nil) then
    fadeval = 255
  end
  tunnel:SetKeyValue("rendermode", RENDERMODE_TRANSTEXTURE)
  tunnel:SetKeyValue("renderamt", tostring(fadeval - 25))
end

--after a few seconds, the tunnels remove themselves
function SWEP:DelayedTunnelRemove(tunnel)
  timer.Create("FadeOut", 0.25, 10, function() self:FadeFunc(tunnel) end)
  timer.Simple(4, function() tunnel:Remove() end)
end

--creates/plays and automatically cleans up... the tunnel effects
function SWEP:TunnelEffect(ply)
  local tunnel = ents.Create('prop_dynamic')
  tunnel:SetModel('models/props_combine/stasisvortex.mdl')
  tunnel:SetPos(ply:GetPos() + tunnel:BoundingRadius() * Vector(0, 0, 1))
  tunnel:SetOwner(ply)
  tunnel:DrawShadow(false)
  tunnel:Spawn()
  ply:EmitSound(self.TeleportSound)
  self:DelayedTunnelRemove(tunnel)
end

--jump to the destination, triggering handlers as we go
function SWEP:DoTeleport(destination)
  local ply = self.Weapon:GetOwner()
  self:DoPreTeleport()
  ply:SetVelocity(Vector(0, 0, 0))
  ply:SetLocalVelocity(Vector(0, 0, 0))
  ply:ViewPunch(Vector(-5, 0, 0))
  ply:SetPos(destination)
  self:DoPostTeleport()
end

--tell the clientside to start pre-teleport sound and video effects
--this also spawns a self-managing tunnel effect
function SWEP:DoPreTeleport()
  local ply = self.Weapon:GetOwner()
  self:TunnelEffect(ply)
  self:SafeCallOnClient("DoPreTeleport", "")
end

--tell the clientside to start post-teleport sound and video effects
--this also spawns a self-managing tunnel effect
function SWEP:DoPostTeleport()
  local ply = self.Weapon:GetOwner()
  self:TunnelEffect(ply)
  self:SafeCallOnClient("DoPostTeleport", "")
  self:BuddyFinderBusy(false)
end

--tell the clientside to start warmup sound and video effects
function SWEP:DoTeleportWarmup()
  self:SafeCallOnClient("DoTeleportWarmup", "")
end

--send the "rang out" message back to the player calling
function SWEP:BuddyRangOut()
  self:NotifyIncomingCallHUD(false)
  self:SendBuddyCallInfo(BuddyCallInfo.bciBusy, self.Caller)
  self:FinishCall()
end

--enable or disable the incoming call blinking HUD icon
function SWEP:NotifyIncomingCallHUD(enable)
  self:SendHUDNotification(enable, BuddyCallInfo.bciIncoming)
end

--spawn the laser box and allow it to be moved about by the 
--direction the user is facing
function SWEP:StartSelectPoint()
  self:BuddyAnim(BuddyFinderAnim.LaserBoxIdle, false)
  if (self.LaserBox == nil) then
    self.LaserBox = ents.Create("buddy_finder_tpg")
    if !self.LaserBox:IsValid() then
      print('LaserBox IS NOT VALID!')
    end
    self.LaserBox:SetOwner(self.Weapon:GetOwner())
    self.LaserBox:DrawShadow(false)
    self.LaserBox:SetPos(self.Weapon:GetOwner():GetPos())
    self.LaserBox:Spawn()
    Dbg('LaserBox spawned')
  end
end

--return true if the buddy finder is on a call
function SWEP:HasIncomingCall()
  return (self.Caller != nil)
end

--tie up all loose ends
function SWEP:FinishCall()
  self:SafeCallOnClient("DoFinishCall", "")
  --terminate the call on the caller's end too
  if (self.Caller != nil) then
    self:SendBuddyCallInfo(BuddyCallInfo.bciSilentCancel, self.Caller)
  end
  self.Caller = nil
  self:BuddyFinderBusy(false)  
end

--set the buddyfinder animation, if a button was pressed then make a sound
--also able to specify a routine to call when done - if none specified then
--the swep returns to the idle animation
function SWEP:BuddyAnim(anim, pressedButton, callWhenDone)
  Dbg('Animating: '..tostring(anim))
  if pressedButton then
    self:SafeCallOnClient("PressButton", "")
  end
  self.Weapon:SendWeaponAnim(anim)
  if (callWhenDone != nil) then
    timer.Simple(self.Weapon:SequenceDuration(), function() callWhenDone() end)
  elseif (anim != BuddyFinderAnim.LaserBoxIdle) then
    timer.Simple(self.Weapon:SequenceDuration(), function() self:AnimReturnToIdle() end)
  end  
end

function SWEP:NPCCallOnClient(routine, params)
  --if we need to handle client style routines for the NPC
  --we do it here (not yet needed)
end

--revert buddyfinder animation to idle
function SWEP:AnimReturnToIdle()
  self.Weapon:SendWeaponAnim(BuddyFinderAnim.Idle)
end

--after the animation is played, the answer is sent to the callee
function SWEP:DelayedAnswer(accepted)
  if accepted then
    --play the new laser placement out action   
    self:SendBuddyCallInfo(BuddyCallInfo.bciAccepted, self.Caller)
    self:BuddyAnim(BuddyFinderAnim.LaserBoxIn, false, function() self:StartSelectPoint() end)
  else
    --play the deny out action
    self:BuddyAnim(BuddyFinderAnim.DenyOut, true)
    self:SendBuddyCallInfo(BuddyCallInfo.bciDenied, self.Caller)
    self:FinishCall()
  end
end

--called once we have decided whether to accept or deny the caller
function SWEP:AnswerBuddyFinder(accepted)
  if accepted == "true" then
    --play the accept action
    self:BuddyAnim(BuddyFinderAnim.AcceptIn, false, function() self:DelayedAnswer(true) end)
  else
    --play the deny action
    self:BuddyAnim(BuddyFinderAnim.DenyIn, false, function() self:DelayedAnswer(false) end)
  end
end

--called when the NPC answers the buddyfinder
function SWEP:NPCAnswer()
  self:DelayedAnswer(self.NPCAcceptCall)
  self.NPCAcceptCall = not self.NPCAcceptCall --toggle  
end

--send a pm to another player
function SWEP:SendPM(toSteamId, msg)
  local recvBuddy = GetBuddyFinder(player.GetByUniqueID(toSteamId))
  if (recvBuddy != nil) then
    recvBuddy:PrintPM(self.Weapon:GetOwner(), msg)
  end
end

--a private message has been received so we print it in the
--chat area immediately
function SWEP:PrintPM(fromPly, msg)
  self.Weapon:GetOwner():PrintMessage(HUD_PRINTTALK, fromPly:Nick().."{PM}: "..msg)
  self:SafeCallOnClient("MakePMSound", "")
end

--sends a HUD notification to the client screen
function SWEP:SendHUDNotification(start, notification)
  if (self.Weapon:GetOwner() == NULL) or (self.Weapon:GetOwner():IsNPC()) then
    return
  end
  umsg.Start("buddy_finder_hud_notify", self.Weapon:GetOwner())
  umsg.Bool(start)
  if (start) then
    umsg.String(notification.HUDNotify)
  end
  umsg.End()
end

--feedback, sent from the buddyfinder we are calling
function SWEP:ReceiveBuddyCallInfo(callInfo, teleportVector)
  Dbg(tostring(self.Weapon:GetOwner())..' received call info '..tostring(callInfo))
  --if at this point the ringing timer is still going, stop it
  timer.Stop("BuddyRinging")
  local hudnotify = callInfo.HUDNotify
  --if this call info requires a hud notification then 
  --send a message to the client to do so
  if (hudnotify != nil) then
    self:SendHUDNotification(true, callInfo)
  end
  local nextAction = callInfo.NextAction
  --if this call requires an action to be taken other than
  --finishing up everything then we do it here
  if (nextAction != nil) then
    if (nextAction == "Warmup") then
      self:DoTeleportWarmup()
    elseif (nextAction == "Teleport") then
      self:DoTeleport(teleportVector)
    else
      self:FinishCall() --the silent cancel will trigger this
    end
  end
end

--the final piece of the puzzle, provided by the laser box
function SWEP:SetTeleportLocation(tox, toy, toz)
  self:SendBuddyCallInfo(BuddyCallInfo.bciTeleport, self.Caller, Vector(tox, toy, toz))
  self.LaserBox = nil
  self:FinishCall()
end

--returns true if the owner of this weapon is an NPC
function SWEP:NPCMode()
  local theowner = self.Weapon:GetOwner()
  return (theowner != nil) and (theowner != NULL) and (theowner:IsNPC())
end

--a call is incoming - received here
function SWEP:ReceiveBuddyCall(ply)
  Dbg('Receiving a call from '..tostring(ply))
  if self:BuddyFinderBusy() then
    self:SendBuddyCallInfo(BuddyCallInfo.bciBusy, ply)
    Dbg('Sent busy tone')
  else
    Dbg('Ringing')
    self:BuddyFinderBusy(true)
    self.Caller = ply
    self:SetNWString("caller_name", ply:Nick())
    self:NotifyIncomingCallHUD(true)
    timer.Create("BuddyRinging", self.BuddyRingTime, 1, function() self:BuddyRangOut() end)
    if self:NPCMode() then
      timer.Create("NPCAnswer", self.NPCAnswerDelay, 1, function() self:NPCAnswer() end)
    end
  end
end

--send information about the call to the caller
function SWEP:SendBuddyCallInfo(callInfo, toCaller, tableInfo)
  local callerBuddy = GetBuddyFinder(toCaller)
  if (callerBuddy != nil) then
    callerBuddy:ReceiveBuddyCallInfo(callInfo, tableInfo)
    return true
  else
    return false
  end
end

--after the animation, continue placing the call
function SWEP:DelayedMakeBuddyCall(toBuddy)
  self:BuddyAnim(BuddyFinderAnim.DialOut, true)
  if (toBuddy != nil) then  
    self:SendHUDNotification(true, BuddyCallInfo.bciOutgoing)
    toBuddy:ReceiveBuddyCall(self.Weapon:GetOwner())
  else
    self:BuddyFinderBusy(false)
  end
end

--start the process of calling another buddy finder
function SWEP:StartBuddyCall(toPlayerSteamID)
  if self:BuddyFinderBusy() then
    Dbg('Cant make call - unit is busy')
    return
  end
  self:BuddyFinderBusy(true)
  local toPly = self.Weapon:GetOwner()
  if (string.Left(toPlayerSteamID, 3) == 'NPC') then
    toPly = ents.GetByIndex(string.Right(toPlayerSteamID, string.len(toPlayerSteamID) - 3))
  elseif (toPlayerSteamID != "me") then
    toPly = player.GetByUniqueID(toPlayerSteamID)
  end
  local toBuddy = GetBuddyFinder(toPly)
  self:BuddyAnim(BuddyFinderAnim.DialIn, false, function() self:DelayedMakeBuddyCall(toBuddy) end)
end

function SWEP:RemoveInvalidPlayers(playerTbl)
  local validPlayers = {}  
  for k, v in pairs(playerTbl) do
    if (v != self.Weapon:GetOwner())
    and v:HasWeapon("weapon_buddyfinder") then
      table.insert(validPlayers, v)
    end
  end
  return validPlayers
end

--sends a usermessage with all player details
function SWEP:PopulatePhonePlayerList()
  local allPlayers = table.Copy(player.GetAll())
  local npcs = ents.FindByClass('npc_*')  

  --if we are debugging then we also include 
  --all NPCs
  if bf_debug_mode then
    table.Merge(allPlayers, npcs)
  end

  --remove players without buddy finders
  --if not in debug mode, remove the local player and players without buddyfinders
  allPlayers = self:RemoveInvalidPlayers(allPlayers)
  
  umsg.Start("PopulatePhonePlayerList", self.Weapon:GetOwner())
  umsg.Short(table.Count(allPlayers))
  for k, v in pairs(allPlayers) do
    if v:IsNPC() then
      umsg.String(v:GetClass())
      umsg.String('NPC'..v:EntIndex())
    else
      umsg.String(v:Nick())
      umsg.String(v:UniqueID())
    end
  end
  umsg.End()
end

--after the animation, acknowledge that we have picked up the phone
function SWEP:DelayedPickup()
  self:SendHUDNotification(false) --turn off the ring
  self:SafeCallOnClient("ShowIncomingCallDialog", "")
  self:BuddyAnim(BuddyFinderAnim.DialOut, true)
end

--after the animation, populate the phone list and send it via umessage
function SWEP:DelayedContacts()
  self:PopulatePhonePlayerList()
  self:BuddyAnim(BuddyFinderAnim.DialOut, true)
end

--once the animation is played, destroy the laser box which sends out the coords
function SWEP:DoPlaceBox()
  self:BuddyAnim(BuddyFinderAnim.LaserBoxOut, true)
  self.LaserBox:Remove()
end

function SWEP:PrimaryAttack()
  --if we are in teleport point select mode then we work differently
  --animation pressing a button on the phone model
  if (self.LaserBox != nil) then
    --play the dial/pickup action
    Dbg('Attack: Teleport')
    self:DoPlaceBox()
  elseif self:HasIncomingCall() then
    --play the dial/pickup action
    Dbg('Attack: Answer')
    self:BuddyAnim(BuddyFinderAnim.DialIn, false, function() self:DelayedPickup() end)
  else
    --play the dial/pickup action
    Dbg('Attack: Dial')
    self:BuddyAnim(BuddyFinderAnim.DialIn, false, function() self:DelayedContacts() end) 
  end
end

--tidy up
function SWEP:OnRemove()
  self:SendHUDNotification(false)
  self:FinishCall() 
  --should fix the aimpos spam
  if (self.LaserBox != nil) then
    self.LaserBox:Remove()
  end
end


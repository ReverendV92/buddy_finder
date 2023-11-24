--BuddyFinder Addon serverside general code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: All the server console commands etc etc

bf_debug_mode = false

resource.AddFile("resource/fonts/phones.ttf")
resource.AddFile("resource/fonts/phones.txt")
resource.AddFile("materials/models/weapons/v_buddyfinder.vtf")
resource.AddFile("materials/models/weapons/v_buddyfinder.vmt")
resource.AddFile("models/weapons/v_buddyfinder.dx80.vtx")
resource.AddFile("models/weapons/v_buddyfinder.dx90.vtx")
resource.AddFile("models/weapons/v_buddyfinder.mdl")
resource.AddFile("models/weapons/v_buddyfinder.sw.vtx")
resource.AddFile("models/weapons/v_buddyfinder.vvd")
resource.AddFile("materials/vgui/entities/weapon_buddyfinder.vmt")
resource.AddFile("materials/vgui/entities/weapon_buddyfinder.vtf")

function GetBuddyFinder(ply)
  if (ply != nil) and ply:HasWeapon("weapon_buddyfinder") then
    return ply:GetWeapon("weapon_buddyfinder")
  end
end

function CCDial(ply, cmd, args)
  --ply will be the initiator
  --cmd will be bf_dial
  --args will be targetUID and requesting boolean
  local recvBuddy = GetBuddyFinder(ply)
  if (recvBuddy != nil) then
    recvBuddy:StartBuddyCall(args[1])
  end
end
concommand.Add("bf_dial", CCDial)

function CCAck(ply, cmd, args)
  --ply will be the recipient
  --cmd will be bf_ack
  --no args
  local recvBuddy = GetBuddyFinder(ply)
  if (recvBuddy != nil) then
    recvBuddy:AckBuddyFinder()
  end
end
concommand.Add("bf_ack", CCAck)

function CCAnswer(ply, cmd, args)
  --ply will be the recipient
  --cmd will be bf_answer
  --args 1 will be true or false
  local recvBuddy = GetBuddyFinder(ply)
  if (recvBuddy != nil) then
    recvBuddy:AnswerBuddyFinder(args[1])
  end
end
concommand.Add("bf_answer", CCAnswer)

function CCTeleportLoc(ply, cmd, args)
  if (args[4] != nil) then
    ply = ents.GetByIndex(args[4])
  end
  local recvBuddy = GetBuddyFinder(ply)
  if (recvBuddy != nil) then
    recvBuddy:SetTeleportLocation(args[1], args[2], args[3])
  end
end
concommand.Add("bf_settloc", CCTeleportLoc)

function CCTestNotifier(ply, cmd, args)
  umsg.Start("buddy_finder_hud_notify", ply)
  umsg.Bool(args[1] == "true")
  umsg.String(args[2])
  umsg.End()
end

function CreateDebugBuddy(ply)
  BuddyFinder_DebugBuddy = ents.Create('buddy_finder_buddy')
  BuddyFinder_DebugBuddy:SetOwner(ply)
  if (ply != nil) then
    local trace = ply:GetEyeTrace()
    BuddyFinder_DebugBuddy:SetPos(trace.HitPos)
  else
    BuddyFinder_DebugBuddy:SetPos(Vector(0, 0, 0))
  end
  BuddyFinder_DebugBuddy:Spawn()
end

function DestroyDebugBuddy()
  BuddyFinder_DebugBuddy:Remove()
end

function CCResetUnit(ply, cmd, args)
  local recvBuddy = GetBuddyFinder(ply)
  if (recvBuddy != nil) then
    recvBuddy:Remove()
    ply:Give("weapon_buddyfinder")
  end  
end

function CCToggleDebug(ply, cmd, args)
  if bf_debug_mode then
    concommand.Remove("bf_test_notify")
    concommand.Remove("bf_reset_unit")
    bf_debug_mode = false
    DestroyDebugBuddy()
  else
    concommand.Add("bf_test_notify", CCTestNotifier)
    concommand.Add("bf_reset_unit", CCResetUnit)
    bf_debug_mode = true
    CreateDebugBuddy(ply)
  end
end
concommand.Add("bf_toggle_debug", CCToggleDebug)

function CCPrivateMessage(ply, cmd, args)
  local recvBuddy = GetBuddyFinder(ply)
  if (recvBuddy != nil) then
    recvBuddy:SendPM(args[1], args[2])
  end
end
concommand.Add("bf_pm", CCPrivateMessage)

--BuddyFinder Addon clientside SWEP code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: The SWEP - teleporting and funky business

include("shared.lua")

SWEP.PrintName = "Buddy Finder"
SWEP.Slot =	1
SWEP.SlotPos =	1
SWEP.DrawAmmo =	false
SWEP.DrawCrosshair = false

SWEP.TargetList = {}

SWEP.SoundObjects = {}

--emit a sound when a button is pressed
function SWEP:PressButton()
  self.Weapon:EmitSound(self.MenuButtonSound)
end

--emit a sound when receiving or sending a PM
function SWEP:MakePMSound()
  self.Weapon:EmitSound(self.PMSound)
end

--incoming call dialog
function SWEP:ShowIncomingCallDialog()
  local fromPlayerNick = self.Weapon:GetNWString("caller_name")
  local frSimple = vgui.Create("DFrame")
  frSimple:SetSize(400, 100)
  frSimple:Center()
  frSimple:SetTitle("Buddy Finder - Incoming Call")
  frSimple:ShowCloseButton(false)
  function frSimple:Paint()
    draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), Color(100, 100, 100, 200))
    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawLine(0, 25, self:GetWide(), 25)
  end

  local lblQuestion = vgui.Create("DLabel", frSimple)
  lblQuestion:SetPos(30, 30)
  lblQuestion:SetText("Do you wish to allow player "..fromPlayerNick.." to teleport to your location?")
  lblQuestion:SizeToContents()
  lblQuestion:Center()

  local btnAllow = vgui.Create("DButton", frSimple)
  btnAllow:SetText("Yes")
  btnAllow:SetPos(250, 68)
  btnAllow.DoClick = function()
    LocalPlayer():ConCommand(BuddyFinderCC.Answer.." ".."true")
    frSimple:Remove()
  end

  local btnDeny = vgui.Create("DButton", frSimple)
  btnDeny:SetText("No")
  btnDeny:SetPos(323, 68)
  btnDeny.DoClick = function()
    LocalPlayer():ConCommand(BuddyFinderCC.Answer.." ".."false")
    frSimple:Remove()
  end

  frSimple:MakePopup()
  self.Weapon:EmitSound(self.QueryAppearSound)
end

--we have received a usermessage from the server
--detailing our contact list - process it then
--show the list dialog
function SWEP:PopulateThenShowList(um)
  table.Empty(self.TargetList)
  local plyCount = um:ReadShort()
  for k = 1, plyCount do
    local targetName = um:ReadString()
    local targetID = um:ReadString()
    self.TargetList[targetName] = targetID
  end
  self:ShowPhonePlayerList()
end

--returns first value in selected lines and column
function SWEP:GetSelectedColValue(listview, columnid)
  return listview:GetSelected()[1]:GetValue(columnid)
end

--start playing the warmup noise
function SWEP:DoTeleportWarmup()
  if (self.SoundObjects.PreTeleport == nil) then
    self.SoundObjects.PreTeleport = CreateSound(LocalPlayer(), Sound(self.PreTeleportSound))
  end
  self.SoundObjects.PreTeleport:Play()  
end

--gradual reduction of the teleport effect
function TeleportGlowEffect()
	DrawBloom( 0, ((LocalPlayer():GetNWInt("GlowEndTime") - CurTime())/ 5) * 0.75, 3, 3, 2, 3, 255, 255, 255 )
end

--the eye-blasting teleport effect
function SWEP:TeleportGlow(activate)
  if (activate) then
    LocalPlayer():SetNWInt("GlowEndTime", CurTime() + 4)
    hook.Add("RenderScreenspaceEffects", "TeleportGlowEffect", TeleportGlowEffect)
    timer.Simple(4, function() self:TeleportGlow(false) end)
  else
    hook.Remove("RenderScreenspaceEffects", "TeleportGlowEffect")
  end
end

--stop the warmup noise and start the self-managing eye blast
function SWEP:DoPreTeleport()
  self:TeleportGlow(true)
  self.SoundObjects.PreTeleport:Stop()  
end

--not yet used, but required to be here
function SWEP:DoPostTeleport()
  
end

--the server says we have finished the call - make sure all sounds
--have stopped playing
function SWEP:DoFinishCall()
  --stop all sounds if they are still playing
  for k,v in pairs(self.SoundObjects) do
    v:Stop()
  end
end

--the private message quick message box/send
function SWEP:SendPrivateMessage(playerName, playerSteamId)

  local frPM = vgui.Create("DFrame")
  frPM:SetSize(300, 100)
  frPM:SetTitle("Send Private Message to "..playerName)
  frPM:Center()

  local teMsg = vgui.Create("DTextEntry", frPM)
  teMsg:SetSize(240, 30)
  teMsg:Center()
  teMsg:AllowInput(true)

  local btnSend = vgui.Create("DButton", frPM)
  btnSend:SetPos(206, 70)
  btnSend:SetText("Send")

  local function SendPMToServer()
    local txtSend = teMsg:GetValue()
    if (txtSend != '') then    
      LocalPlayer():ConCommand(BuddyFinderCC.PM.." "..playerSteamId.."\""..txtSend.."\"")
      self:MakePMSound()
      frPM:Remove()
    end
  end

  teMsg.OnEnter = function() SendPMToServer() end
  btnSend.DoClick = function() SendPMToServer() end

  frPM:MakePopup()
  teMsg:RequestFocus()
  frPM:DoModal()
end

--the contact list menu
function SWEP:ShowPhonePlayerList(requestingTeleport)
  local frDirectory = vgui.Create("DFrame")
  frDirectory:SetSize(500, 500)
  frDirectory:SetTitle("Buddy Finder - Contacts")
  frDirectory:Center()

  function frDirectory:Paint()
    draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), Color(100, 100, 100, 200))
    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawLine(0, 25, self:GetWide(), 25)
  end

  local lvTargets = vgui.Create("DListView", frDirectory)
  lvTargets:SetPos(30, 30)
  lvTargets:SetSize(440, 420)
  local colName = lvTargets:AddColumn("Name")
  local colSteamId = lvTargets:AddColumn("SteamID")
  local targetCount = 0
  for k,v in pairs(self.TargetList) do
    lvTargets:AddLine(k, v)
    targetCount = targetCount + 1
  end

  local btnDial = vgui.Create("DButton", frDirectory)
  btnDial:SetPos(406, 460)
  btnDial:SetText("Dial")
  btnDial.DoClick = function()
    if (targetCount > 0) then
      LocalPlayer():ConCommand(BuddyFinderCC.Dial.." "..self:GetSelectedColValue(lvTargets, colSteamId:GetColumnID()))
      frDirectory:Remove()
    else
      Dbg('No players to call')
    end
  end

  local btnPM = vgui.Create("DButton", frDirectory)
  btnPM:SetPos(30, 460)
  btnPM:SetText("P.M.")
  btnPM.DoClick = function()
    if (targetCount > 0) then
      self:PressButton()
      self:SendPrivateMessage(self:GetSelectedColValue(lvTargets, colName:GetColumnID()),
                              self:GetSelectedColValue(lvTargets, colSteamId:GetColumnID()))
      frDirectory:Remove()
    else
      Dbg('No players to PM')
    end
  end

  lvTargets.OnRowSelected = function(selectedRow)
    btnDial:SetDisabled(selectedRow == nil)
  end

  lvTargets.DoDoubleClick = function()
    btnDial.DoClick()
  end

  lvTargets:SelectFirstItem()
  frDirectory:MakePopup()
  self.Weapon:EmitSound(self.ContactsAppearSound)
end

--mute the click sound of primary attack
function SWEP:PrimaryAttack()
  --mutes the click sound
end


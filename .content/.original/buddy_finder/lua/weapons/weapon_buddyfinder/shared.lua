--BuddyFinder Addon shared SWEP code
--Author: ancientevil
--Contact: facepunch.com
--Date: 29th May 2009
--Purpose: The SWEP - teleporting and funky business

SWEP.Author =	"ancientevil"
SWEP.Contact =	"www.facepunch.com"
SWEP.Purpose =	"Reduce commute time when looking for your friends on large maps.  Just call them with BuddyFinder and teleport to their location!"
SWEP.Instructions =	"Fire to show contact list or answer incoming calls - you'll figure it out.  Have fun - ae."

SWEP.Spawnable =	true
SWEP.Adminspawnable =	true

SWEP.ViewModel =	"models/weapons/v_buddyfinder.mdl"
SWEP.WorldModel =	"models/weapons/w_camphone.mdl"

SWEP.Primary.Clipsize =	-1
SWEP.Primary.DefaultClip =	-1
SWEP.Primary.Automatic =	false
SWEP.Primary.Ammo =	"none"

SWEP.Secondary.Clipsize =	-1
SWEP.Secondary.DefaultClip =	-1
SWEP.Secondary.Automatic =	false
SWEP.Secondary.Ammo =	"none"

SWEP.BuddyRingTime = 30
SWEP.NPCAnswerDelay = 3
SWEP.NPCAcceptCall = true
SWEP.TeleportSound = 'ambient/machines/teleport3.wav'
SWEP.TargetVarName = "buddy_finder_target"
SWEP.BuddyFinderBusyVarName = "buddy_finder_busy"
SWEP.BuddyFinderIncomingCallVarName = "buddy_finder_incoming"
SWEP.PreTeleportSound = 'ambient/levels/labs/teleport_active_loop1.wav'
SWEP.PreTeleportSuckInSound = 'ambient/levels/labs/teleport_preblast_suckin1.wav'
SWEP.ContactsAppearSound = 'npc/scanner/combat_scan5.wav'
SWEP.MenuButtonSound = 'ui/buttonclick.wav'
SWEP.QueryAppearSound = 'npc/dog/dog_playfull3.wav'
SWEP.PMSound = 'npc/scanner/scanner_scan4.wav'

BuddyFinderAnim = {}
BuddyFinderAnim.Idle = ACT_VM_IDLE
BuddyFinderAnim.DialIn = ACT_VM_PRIMARYATTACK
BuddyFinderAnim.DialOut = ACT_VM_PRIMARYATTACK_1
BuddyFinderAnim.AcceptIn = ACT_VM_PRIMARYATTACK_2
BuddyFinderAnim.AcceptOut = ACT_VM_PRIMARYATTACK_3
BuddyFinderAnim.DenyIn = ACT_VM_PRIMARYATTACK_4
BuddyFinderAnim.DenyOut = ACT_VM_PRIMARYATTACK_5
BuddyFinderAnim.LaserBoxIn = ACT_VM_PRIMARYATTACK_6
BuddyFinderAnim.LaserBoxIdle = ACT_VM_PRIMARYATTACK_7
BuddyFinderAnim.LaserBoxOut = ACT_VM_PRIMARYATTACK_8

--table of all possible outcomes from calling another buddyfinder
BuddyCallInfo = {}
BuddyCallInfo.bciBusy         = {HUDNotify = "bfhnBusy", NextAction = "FinishCall"} --target is on another call
BuddyCallInfo.bciAccepted     = {HUDNotify = "bfhnAccepted", NextAction = "Warmup"} --target has allowed a teleport request or accepted a teleport offer
BuddyCallInfo.bciDenied       = {HUDNotify = "bfhnDenied", NextAction = "FinishCall"} --target had denied a teleport request or refused a teleport offer
BuddyCallInfo.bciTeleport     = {NextAction = "Teleport"} --teleport is go go go
BuddyCallInfo.bciOutgoing     = {HUDNotify = "bfhnOutgoing"}
BuddyCallInfo.bciSilentCancel = {NextAction = "SilentCancel"}
BuddyCallInfo.bciIncoming     = {HUDNotify = "bfhnIncoming"} 

--console commands
BuddyFinderCC = {}
BuddyFinderCC.Dial = "bf_dial"
BuddyFinderCC.Ack = "bf_ack"
BuddyFinderCC.Answer = "bf_answer"
BuddyFinderCC.SetTLoc = "bf_settloc"
BuddyFinderCC.PM = "bf_pm"

BF_Umsg = {}
BF_Umsg.ConnectCall = "ConnectBuddyCall"

function SWEP:SecondaryAttack()
  --reverse use - offer a player to come to you instead
  --1. animation
  --2. if placing a call,vgui player list popup
  --3. if receiving a call, dialog popup
  return false
end

function SWEP:Deploy()
  return true
end

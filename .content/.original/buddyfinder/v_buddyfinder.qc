
$opaque
//$origin 0 0 0 270
$ModelName	jessev92/weapons/buddyfinder_c
$model	BFinder	c
$include	define.qci

$SurfaceProp	computer

$Contents	solid

$MaxEyeDeflection 90

$CDMaterials	models/jessev92/weapons
$CDMaterials	models/jessev92/weapons/buddyfinder

$Sequence	"draw" "draw" {
	activity "ACT_VM_DRAW" 1
	fadein 0.2
	fadeout 0.2
	fps 300
}

$Sequence	"holster" "holster" {
	activity "ACT_VM_HOLSTER" 1
	fadein 0.2
	fps 300
}

$Sequence	idle "idle" {
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$Sequence "tap" "tap" {
	
	activity "ACT_VM_PRIMARYATTACK" 1
	fadein 0.2
	fadeout 0.2
	snap
	fps 30
}

$Sequence "beam_in" "beam_in" {
	
	activity "ACT_VM_PRIMARYATTACK_6" 1
	fadein 0.2
	fadeout 0.2
	snap
	fps 90
}

$Sequence "beam_idle" "beam_idle" {
	
	activity "ACT_VM_PRIMARYATTACK_7" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	loop
}

$Sequence "beam_out" "beam_out" {
	
	activity "ACT_VM_PRIMARYATTACK_8" 1
	fadein 0.2
	fadeout 0.2
	snap
	fps 90
}

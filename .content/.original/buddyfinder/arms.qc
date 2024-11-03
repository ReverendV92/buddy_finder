$origin 0 0 0 270
$modelname "jessev92\weapons\buddyfinder_v_c01.mdl"
$model "iPhone4" "v_arms.smd"
$model "iPhone4" "v_phoneonly.smd"

$cdmaterials "jessev92\weapons\iphone4"
$cdmaterials "weapons\v_buddyfinder"
$cdmaterials "models\weapons"
$cdmaterials "models\weapons\v_hand"
$cdmaterials "models\weapons\v_buddyfinder"
$hboxset "default"
//$hbox 0 "Armature" -5.250  0.000  -13.582  1.678  15.088  0.000
//$hbox 0 "ValveBiped.Bip01_Spine4" 0.000  -1.938  0.000  2.033  1.938  1.001
//$hbox 0 "ValveBiped.Bip01_L_Forearm" -4.237  -3.024  -3.370  12.580  2.785  2.414
//$hbox 0 "ValveBiped.Bip01_L_Hand" -1.047  -1.215  -2.290  4.523  2.062  1.673
//$hbox 0 "ValveBiped.Bip01_L_Finger4" -0.489  -0.564  -0.241  1.580  1.218  0.969
//$hbox 0 "ValveBiped.Bip01_L_Finger3" 0.000  -0.384  -0.474  1.982  1.525  0.663
//$hbox 0 "ValveBiped.Bip01_L_Finger2" 0.000  -0.416  -0.951  2.074  0.952  0.830
//$hbox 0 "ValveBiped.Bip01_L_Finger1" -0.624  -0.444  -0.540  1.832  1.366  0.524
//$hbox 0 "ValveBiped.Bip01_L_Finger0" -0.252  -1.352  -0.351  2.235  1.253  2.121
//$hbox 0 "ValveBiped.Bip01_L_Finger01" -0.149  -0.547  -0.350  1.706  0.975  1.708
//$hbox 0 "ValveBiped.Bip01_L_Finger02" -0.429  -0.495  -0.228  1.680  0.623  0.814
//$hbox 0 "ValveBiped.Bip01_R_UpperArm" -1.320  -2.819  -3.381  11.693  3.362  2.589
//$hbox 0 "ValveBiped.Bip01_R_Forearm" -4.173  -2.728  -3.309  12.645  3.081  2.475
//$hbox 0 "ValveBiped.Bip01_R_Hand" -0.974  -2.016  -2.251  4.817  1.262  1.732
//$hbox 0 "ValveBiped.Bip01_R_Finger4" -0.499  -1.128  -0.348  1.840  0.546  0.973
//$hbox 0 "ValveBiped.Bip01_R_Finger3" 0.000  -1.420  -0.465  2.017  0.422  0.606
//$hbox 0 "ValveBiped.Bip01_R_Finger2" 0.000  -0.878  -0.920  2.093  0.515  0.861
//$hbox 0 "ValveBiped.Bip01_R_Finger1" -0.600  -1.271  -0.503  1.856  0.539  0.561
//$hbox 0 "ValveBiped.Bip01_R_Finger0" -0.258  -1.148  -0.362  1.934  1.456  2.132
//$hbox 0 "ValveBiped.Bip01_R_Finger01" -1.117  -0.978  -0.357  1.659  0.464  1.305
//$hbox 0 "ValveBiped.Bip01_MobilePhone" 0.000  -1.705  -4.669  2.814  0.000  0.404
$surfaceprop "plastic"
$illumposition 4.534 -2.213 -17.760
$sequence idle "idle" loop ACT_VM_IDLE 1 fps 30.00
$sequence dial_in "dial_in" ACT_VM_PRIMARYATTACK 1 fps 30.00
$sequence dial_out "dial_out" ACT_VM_PRIMARYATTACK_1 1 fps 30.00
$sequence accept_in "accept_in" ACT_VM_PRIMARYATTACK_2 1 fps 30.00
$sequence accept_out "accept_out" ACT_VM_PRIMARYATTACK_3 1 fps 30.00
$sequence deny_in "deny_in" ACT_VM_PRIMARYATTACK_4 1 fps 30.00
$sequence deny_out "deny_out" ACT_VM_PRIMARYATTACK_5 1 fps 30.00
$sequence beam_in "beam_in" ACT_VM_PRIMARYATTACK_6 1 fps 30.00
$sequence beam_idle "beam_idle" loop ACT_VM_PRIMARYATTACK_7 1 fps 30.00
$sequence beam_out "beam_out" ACT_VM_PRIMARYATTACK_8 1 fps 30.00


ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Shotgun - Friend"

ENT.Spawnable = true
ENT.Category = "Active NPCs"
ENT.Owner = nil

ENT.Model = "models/Kleiner.mdl"

ENT.Ragdoll = nil
ENT.Gun = nil
ENT.switch = false

ENT.counter = 0
ENT.PelvisUp = true

ENT.madePelvisTimer = false
ENT.madeTimer = false


//Searching
ENT.closestPlayer = nil
ENT.lastPlayer = nil
ENT.searchDistance = 1500
ENT.nextPos = nil


ENT.ragHealth = 240
ENT.currentFace = "faceneutral"
ENT.isDead = false

ENT.dieTime = 7
ENT.fullyDead = false
//die already.. newb (when dead they kinda twitch so this makes them fully dead yknow)
ENT.fullyDeadHealth = 100
ENT.deathTimer = false


//Used for determining fall damage
ENT.lastFallPos = nil 
ENT.justFell = false 



//You dont really need to change the max, just the walkspeed
ENT.maxWalkSpeed = 50
ENT.walkSpeed = 50

//Does it fight players or enemy npcs?
ENT.friendly = true

//Standing upright
ENT.headStrengthMult = 1.5
ENT.pelvisStrengthMult = 0.5
ENT.spineStrengthMult = 1.1

ENT.pelvisHeight = 40
ENT.headHeight = 80
ENT.spineHeight = 50




--------------------VV GUN/COMBAT STUFF VV---------------------

//When the distance between the ragdoll and the player is this, the ragdoll stops moving and just attacks.
ENT.minDistFromPlayer = 165

ENT.useFists = false -- PUNCHOUT!! (most other gun settings are used with this)
ENT.fistsRange = 85
//Less is faster!
ENT.fireRate = 20
//In percentage, so the og value below is 30% chance of the gun actually firing per "shot".
ENT.shootChance = 20


-- TWO HANDED GRIP STUFF

ENT.holdWithTwoHands = true
ENT.twoHandedConst = nil

//Left Hand Grip Pos on gun (LOCAL)
ENT.GunGripPos = Vector(	1.2434583902359	,	-1.3830659389496	,	0.67267715930939	)


//How close the lefthand needs to be to grip
ENT.GunGripLeeway = 10


ENT.GunModel = "models/weapons/w_shotgun.mdl"
ENT.GunsForwardIsReversed = true --for specific models like the hl2 pistol, in the case of the pistol if this is off then the gun shoots behind itself
ENT.GunSound = "weapons/shotgun/shotgun_fire6.wav"
//Offset angle for different models
ENT.GunSpawnAngle = Angle(-20,110,110   )
//Offset position for different models
ENT.GunSpawnOffset = Vector(1,-10.5,-2)

ENT.GunDamage = 20
//increase for like shotguns
ENT.GunBulletsPerShot = 6
//Bullet Spread
ENT.GunSpread = Vector(0.3, 0.3, 0)
//How much force the gun should jolt back per shot
ENT.GunRecoil = 400
//Multiplier for gunhand steadyness
ENT.GunHandSteadyness = 1.2
//Where the bullet is shot from (LOCAL)
ENT.GunMuzzlePos = Vector(	-15.053858757019	,	0.26332449913025	,	0.71451699733734	)



-----------------------^^ GUN STUFF ^^------------------------------------



//Wound stuff
ENT.headPos = nil
ENT.holdingWound = false
ENT.woundPos = nil
ENT.switchingWoundPos = true


ENT.isGrounded = true

ENT.movingBackwards = false

ENT.blinkCounter = 0

ENT.feetHurt = false

//This is NOT how many times the gun has shot, yeah im bad at naming stuff.
ENT.shotCounter = 0
ENT.recoverCount = 120
//If the ragdoll gets shot this gets enabled:
ENT.shot = false

ENT.justSpawned = true
ENT.spawnTimeCounter = 0
ENT.canShoot = true







ENT.painSounds = {
    "vo/npc/male01/pain01.wav",
    "vo/npc/male01/pain02.wav",
    "vo/npc/male01/pain04.wav",
    "vo/npc/male01/pain03.wav",
    "vo/npc/male01/pain07.wav"
}

ENT.hitSounds = {
    "physics/body/body_medium_impact_hard1.wav",
    "physics/body/body_medium_impact_hard2.wav",
    "physics/body/body_medium_impact_hard3.wav",
    "physics/body/body_medium_impact_hard4.wav",
    "physics/body/body_medium_impact_hard5.wav",
    "physics/body/body_medium_impact_hard6.wav"
}

ENT.bone = {
    pelvis = "ValveBiped.Bip01_Pelvis",
    spine = "ValveBiped.Bip01_Spine2",
    head = "ValveBiped.Bip01_Head1",

    lefthand = "ValveBiped.Bip01_L_Hand",
    righthand = "ValveBiped.Bip01_R_Hand",

    leftfoot = "ValveBiped.Bip01_L_Foot",
    rightfoot = "ValveBiped.Bip01_R_Foot",

    leftcalf = "ValveBiped.Bip01_L_Calf",
    rightcalf = "ValveBiped.Bip01_R_Calf"
}
ENT.physbone = {}
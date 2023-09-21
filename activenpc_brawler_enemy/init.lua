
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

include("entities/activeragdollbase/arms.lua")
include("entities/activeragdollbase/bodymovement.lua")
include("entities/activeragdollbase/ragdolltools.lua")
include("entities/activeragdollbase/entitycreation.lua")
include("entities/activeragdollbase/faceflexes.lua")
include("entities/activeragdollbase/pathfindingandseeking.lua")
include("entities/activeragdollbase/health.lua")
include("entities/activeragdollbase/misc.lua")
include("entities/activeragdollbase/sharedinit.lua")

function ENT:SpawnFunction(ply,tr,class)
    self.Owner = ply
    local ent = ents.Create( ClassName )
    ent:SetPos( tr.HitPos + Vector(0,0,10) )
    ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:Initialize()
    self:SetModel("")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self:ExtraInit()

    local phys = self:GetPhysicsObject()

    self:CreateRagdoll()    
    self:CreateGun()

end

function ENT:OnRemove()
    hook.Remove("EntityTakeDamage","ragdollHealth")
    if self.Ragdoll then
        self.Ragdoll:Remove()        
    end

    if self.Gun then
        self.Gun:Remove()        
    end

end

//Standing Up
function ENT:StandUp(distancePelvisFromGround,distanceHeadFromGround,distanceSpineFromGround, pelvis,spine,head)

    local function boneConditions(dist,height)
        if dist < height && dist < height + 10 then
            return true
        else
            return false
        end
    end

    //Standing up
    if self.isGrounded && !self.justFell then
        //PELVIS
        if boneConditions(distancePelvisFromGround,self.pelvisHeight)  && !self.feetHurt && distanceSpineFromGround > 42 then
            pelvis:ApplyForceCenter( Vector( 0, 0, 1000 * self.pelvisStrengthMult ) )         
        end
        //HEAD
        if boneConditions(distanceHeadFromGround,self.headHeight) then
            head:ApplyForceCenter( Vector( 0, 0, 295 * self.headStrengthMult) )
        end
        //SPINE
        if boneConditions(distanceSpineFromGround,self.spineHeight) && !self.feetHurt then
            spine:ApplyForceCenter( Vector( 0, 0, 700 * self.spineStrengthMult ) )             
        end 
    end
end


//basic movement stuff
function ENT:RagdollMovement()
    local ragdoll = self.Ragdoll
    self.counter = self.counter + 1
    local plr = self.closestPlayer    
    self:findPlayerBasic()
    local finalplr
    if !plr then
        //Last player
        finalplr = self.lastPlayer
    else
        //Normal nearest player
        finalplr = plr
    end

	local pelvis = self:GetRagBone(self.bone.pelvis)
    local spine = self:GetRagBone(self.bone.spine)
    local head = self:GetRagBone(self.bone.head)
    local distancePelvisFromGround = self:traceDistance(ragdoll, ragdoll:LookupBone(self.bone.pelvis))
    local distanceHeadFromGround = self:traceDistance(ragdoll, ragdoll:LookupBone(self.bone.head))
    local distanceSpineFromGround = self:traceDistance(ragdoll, ragdoll:LookupBone(self.bone.spine))
    --print(distancePelvisFromGround)
    --print(distanceSpineFromGround)
    local testing = false

    if self.holdingWound && !self.fullyDead then
        self:HoldWound(ragdoll:LookupBone(self.bone.lefthand))
    end
    if !self.isGrounded && !self.fullyDead then self:Falling(ragdoll) end
    if testing or self.isDead then return end


    local function GunHandManager()
        if self.useFists then
            self:FistsHands(finalplr,ragdoll, true)  
        else
            self:GunHand(finalplr,ragdoll)   
        end
    end
    local function GunFiringManager()
        if self.useFists then
            self:SwingFist(finalplr,ragdoll)  
        else
            self:ShootBullet(finalplr)  
        end
    end

    ----------------------------VV GUN STUFF VV--------------------------------------

    local function ShootConditions()
        if self.useFists then
            return (ragdoll:GetPos():Distance(finalplr:GetPos()) < self.minDistFromPlayer) &&
            self.counter >= math.Clamp(self.fireRate / (ragdoll:Health() / ragdoll:GetMaxHealth()),self.fireRate,self.fireRate + 10)
        else
            return self.counter >= math.Clamp(self.fireRate / (ragdoll:Health() / ragdoll:GetMaxHealth()),self.fireRate,self.fireRate + 10)
        end
    end
    local function GunHandConditions()
        return self.isGrounded && !GetConVar("ai_disabled"):GetBool() && (plr or (self.lastPlayer != nil && self.movingBackwards))
    end

    //hold out gun hand
    if GunHandConditions() then
        if self.holdWithTwoHands then
            self:LeftHandGrip(finalplr,ragdoll) 
        end
        if !self.canShoot then 
            if ragdoll:Health() < ragdoll:GetMaxHealth() / 2 then
                self.movingBackwards = true
                self:HoldWound(ragdoll:LookupBone(self.bone.righthand))

            else 
                GunHandManager() 
            end
        else
            GunHandManager()   
        end
        if ShootConditions() then
            if self.Gun != nil then
                if(math.Rand(0,1) < (self.shootChance / 100)) then
                    if self.canShoot then
                        GunFiringManager()
                    end
                    self.counter = 0
                else
                    self.counter = 0
                end
                end
                end
    end
    ----------------------------^^ GUN STUFF ^^--------------------------------------


    ---------------------------------VV STANDING UP STUFF VV-----------------------------------
    //So it goes out more
    local handl = self:GetRagBone(self.bone.lefthand)
    local handr = self:GetRagBone(self.bone.righthand)
    local targetDirectionHand = nil 
    if (plr or (self.lastPlayer != nil && self.movingBackwards)) then
        targetDirectionHand = (finalplr:EyePos() - handl:GetPos()):GetNormalized()
        targetDirectionHand:Mul(2)
        handl:ApplyForceCenter( targetDirectionHand) 
    end


    self:StandUp(distancePelvisFromGround,distanceHeadFromGround,distanceSpineFromGround,pelvis,spine,head)

    ---------------------------------^^ STANDING UP STUFF ^^-----------------------------------


    //This is gonna be a bit confusing, but just know that "footl" & "footr" are actually the calfs, and "actFootL" and "actFootR" are the feet, Sorry
    
    local footl = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone(self.bone.leftcalf)))
    local footr = ragdoll:GetPhysicsObjectNum(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone(self.bone.rightcalf)))


    //WALK
    if (plr or (self.lastPlayer != nil && (self.movingBackwards or !self.Gun))) then
        if footl != nil && footr != nil && !self.justFell then
            if (ragdoll:GetPos():Distance(finalplr:GetPos()) > self.minDistFromPlayer) or !self.Gun or self.movingBackwards && self.isGrounded then
                self:Walk(footl,footr,pelvis,ragdoll, finalplr)  
            end
        end
    end

    -------------------------------------VV FACING THE PLAYER VV-------------------------------------------

    //Everything below is how the ragdoll points towards the player
    local targetDirection = nil
    local currentDirection
    local rotationAxis
    
    local rotationAngle
    //so it actually faces the player correctly
    local offsetAngle
    local targetAngles

    local offsetAngleGun
    local targetAnglesGun

    -- Get the current angles of the prop
    local currentAngles
    local rotationSpeed
        
     -- Interpolate between the current angles and the target angles
    local newAngles = Angle(0,0,0)
    
    if plr or (self.lastPlayer != nil && (self.movingBackwards or !self.Gun)) then
        targetDirection = (finalplr:GetPos() - pelvis:GetPos()):GetNormalized()
        currentDirection = pelvis:GetEntity():GetForward()
        rotationAxis = currentDirection:Cross(targetDirection):GetNormalized()
        
        rotationAngle = math.acos(math.Clamp(currentDirection:Dot(targetDirection), -1, 1))
        //so it actually faces the player correctly
        offsetAngle = Angle(0,90, 0)
        targetAngles = (targetDirection:Angle() + offsetAngle)
    
        offsetAngleGun = Angle(-40,190, 0)
        targetAnglesGun = (targetDirection:Angle() + offsetAngleGun)

        -- Get the current angles of the prop
        currentAngles = pelvis:GetAngles()
        rotationSpeed = 50
        
        -- Interpolate between the current angles and the target angles
        if self.Gun then
            newAngles = LerpAngle(math.Clamp(FrameTime() * rotationSpeed, 0, 1), currentAngles, targetAngles) 
        else
            local angletoreverse = LerpAngle(math.Clamp(FrameTime() * rotationSpeed, 0, 1), currentAngles, targetAngles)
            newAngles = LerpAngle(math.Clamp(FrameTime() * rotationSpeed, 0, 1), currentAngles, -targetAngles)
        end
    end


    -- Face player

    local pelvAng = pelvis:GetAngles()
    if self.isGrounded then
        if self.lastFallPos != nil then
            if self.lastFallPos:Distance(ragdoll:GetPos()) > 400 && !self.isDead then
                self:Die()
            else
                self.justFell = true
                timer.Simple(2, function() self.justFell = false end)
                self.lastFallPos = nil
            end
        end
        if self.justFell then return end
        --print(self:IsGrounded(self.Ragdoll))
        if !GetConVar("ai_disabled"):GetBool() && (plr or (self.lastPlayer != nil && (self.movingBackwards or !self.Gun))) then
            pelvis:SetAngles(Angle(pelvAng.p, newAngles.y, pelvAng.r)) 
        end
    end


end
function ENT:Think()

    self:Misc()
    self:RagdollMovement()
    self.isGrounded = self:IsGrounded(self.Ragdoll)
    self:NextThink(CurTime() + 0.001)

    return true
end

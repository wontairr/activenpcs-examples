
include("shared.lua")
    
function ENT:Draw()
    self:DrawShadow(false) 
    self:DestroyShadow() 
    
    if !IsValid(self:GetNWEntity("activeRagdoll")) then return end
    local ragdoll = self:GetNWEntity("activeRagdoll")
end

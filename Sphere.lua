Hittable = require "Hittable"

SPHERE = {center = nil,radius = nil,material = nil}
setmetatable(SPHERE,HITTABLE)     --SPHERE inherents from HITTABLE

--make new SPHERE object
function SPHERE:new(center,radius,material)
    local o = HIT_RECORD:new(nil,nil)
    setmetatable(o,self)
    self.__index = self
    o.center   = center
    o.radius   = radius
    o.material = material
    return o
end

--if ray hits sphere
function SPHERE:hitSphere(ray,rec,temp,t_min,t_max)    
    if(temp < t_max and temp > t_min) then
        rec.t = temp
        rec.p = ray:at(rec.t)
        rec:setFaceNormal(ray,(rec.p - self.center) / self.radius)
        rec.material = self.material
        return true
    end
    return false
end

--check if given ray hits a sphere
function SPHERE:hit(ray,t_min,t_max,rec)
    local oc     = ray.orig - self.center
    local a      = #ray.dir
    local half_b = oc:dotP(ray.dir)
    local c      = #oc - self.radius * self.radius
    local discr  = half_b * half_b -  a * c
    if (discr > 0) then
        local root  = math.sqrt(discr)
        local temp  = (-half_b - root) / a
        local temp2 = (-half_b + root) / a
        return self:hitSphere(ray,rec,temp,t_min,t_max) or self:hitSphere(ray,rec,temp2,t_min,t_max)
    end
    return false
end

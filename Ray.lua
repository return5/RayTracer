local vectors  = require "Vectors"
local Sphere   = require "Sphere"

RAY = {orig = nil, dir = nil}

function RAY:new(origin,direction)
    local o = o or {}
    setmetatable(o,self)
    self.__index = self
    o.orig       = origin
    o.dir        = direction
    return o
end

function RAY:at(t)
    return self.orig + (self.dir * t)
end

--return vector of rgb colors of that ray
function RAY:color(world,depth)
    if(depth <= 0) then
        return VECTOR:new(0,0,0)
    else
        local rec = HIT_RECORD:new(nil,nil)
        if(world:hit(self,0.001,INFINITY,rec) == true) then
            local scattered    = RAY:new(nil,nil)
            local attenuation  = VECTOR:new(nil,nil,nil)
            if(rec.material:scatter(self,rec,attenuation,scattered) == true) then
                return attenuation * scattered:color(world,depth - 1)
            end
            return VECTOR:new(0,0,0)
        end
        local t = 0.5 * (self.dir:unitVector()[2] + 1.0)
        return (VECTOR:new(1.0,1.0,1.0) * (1.0 - t)) + (VECTOR:new(0.5,0.7,1.0) * t)
    end
end

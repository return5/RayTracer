local RTWEEKEND = require "RTweekend"

VECTOR = {nil,nil,nil}

function VECTOR:new(x,y,z)
    local o = o or {x,y,z}
    setmetatable(o,self)
    self.__index = self
    self.__add = VECTOR.add       
    self.__sub = VECTOR.sub      
    self.__mul = VECTOR.multiply 
    self.__len = VECTOR.len      
    self.__div = VECTOR.divide   
    return o
end

function VECTOR:dotP(v2)
    return self[1] * v2[1] + self[2] * v2[2] + self[3] * v2[3]
end

function VECTOR:add(v2)
    return VECTOR:new(self[1] + v2[1], self[2] + v2[2], self[3] + v2[3])
end

function VECTOR:sub(v2)
    return VECTOR:new(self[1] - v2[1], self[2] - v2[2], self[3] - v2[3])
end


function VECTOR:multiply(v2)
    --if v2 is a vector
    if(type(v2) == 'table') then
        return VECTOR:new(self[1] * v2[1], self[2] * v2[2], self[3] * v2[3])
    elseif(type(v2) == 'number') then
        return VECTOR:new(self[1] *v2, self[2] * v2, self[3] * v2)
    else
        io.write("error\n")
    end
end

function VECTOR:divide(v2)
    return self * (1/v2)
end

function VECTOR:cross(v2)
    return VECTOR:new(
        self[2] * v2[3] - self[3] * v2[2], 
        self[1] * v2[3] - self[3] * v2[1], 
        self[1] * v2[2] - self[2] * v2[1]) 
end

function VECTOR:len()
    return self:dotP(self)
end

function VECTOR:mag()
    return math.sqrt(#self)
end

function VECTOR:unitVector()
    return self / self:mag()
end

function VECTOR:reflect(n)
    return self - (n * self:dotP(n) * 2)
end

function VECTOR:refract(n,etai)
    local cos_theta  = (self * -1):dotP(n)
    local r_parallel = (self + n * cos_theta) * etai
    local r_perp     = n * -1 * math.sqrt(1.0 - #r_parallel)
    return r_parallel + r_perp
end

function randInUnitSphere()
    local rand = randDouble
    local vec  = VECTOR:new(0,0,0)
    repeat
        vec[1] = rand(-1,1)
        vec[2] = rand(-1,1)
        vec[3] = rand(-1,1)
    until(#vec >= 1)
    return vec
end

function randUnitVector()
    local a = randDouble(0,2 * PI)
    local z = randDouble(-1,1)
    local r = math.sqrt(1 - z * z)
    return VECTOR:new(r * math.cos(a),r * math.sin(a), z)
end

function randomInHemisphere(normal)
    local in_unit = randInUnitSphere()
    if(in_unit:dotP(normal) > 0.0) then
        return in_unit
    else
        return in_unit * -1
    end
end

function randomInUnitDisk()
    local rand = randDouble
    while true do
        local p = VECTOR:new(rand(-1,1),rand(-1,1),0)
        if(#p < 1) then
            return p
        end
    end
end


function randomVec(min,max)
    local rand = randDouble
    return VECTOR:new(rand(min,max),rand(min,max),rand(min,max))
end

--writes vector to stdout as three ints representing rgb values
function VECTOR:writeColor(samples_per_pixel)
    local toInt = toInteger
    local clamp = clampNum
    local sqrt  = math.sqrt
    local scale = 1.0 / samples_per_pixel
    local r = clamp(sqrt(self[1] * scale),0.0,0.999)
    local g = clamp(sqrt(self[2] * scale),0.0,0.999)
    local b = clamp(sqrt(self[3] * scale),0.0,0.999)
    io.write(toInt(r * 256)," ",toInt(g * 256)," ",toInt(b * 256),"\n")
end

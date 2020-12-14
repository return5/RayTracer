local Ray    = require "Ray"

LAMBERTIAN  = {}
MATERIAL    = {albedo = nil}
METAL       = {fuzz = nil}
DIELECTRIC  = {ref_idx = nil}

setmetatable(METAL,MATERIAL)
setmetatable(LAMBERTIAN,MATERIAL)
setmetatable(DIELECTRIC,MATERIAL)

function LAMBERTIAN:new(albedo)
    local o = MATERIAL:new(albedo)
    setmetatable(o,self)
    self.__index = self
    return o
end

function MATERIAL:new(albedo)
    local o = o or {}
    setmetatable(o,self)
    self.__index = self
    o.albedo     = albedo
    return o
end

function METAL:new(albedo,fuzz)
    local o = MATERIAL:new(albedo)
    setmetatable(o,self)
    self.__index = self
    if(fuzz < 1.0) then
        o.fuzz = fuzz
    else
        o.fuzz = 1.0
    end
    return o
end

function DIELECTRIC:new(ref_idx)
    local o = MATERIAL:new(nil)
    setmetatable(o,self)
    self.__index = self
    o.ref_idx    = ref_idx
    return o
end
local function schlickApprox(cosine,ref_idx) 
    local r0 = (1 - ref_idx) / (1 + ref_idx)
    r0 = r0 * r0
    local a = (1 - cosine)
    return (r0 + (1 - r0) * a * a * a * a * a)
end

local function setAtten(attenuation,x,y,z)
    attenuation[1] = x
    attenuation[2] = y
    attenuation[3] = z
end

local function setScattered(scattered,origin,direction)
    scattered.orig = VECTOR:new(origin[1],origin[2],origin[3])
    scattered.dir  = VECTOR:new(direction[1],direction[2],direction[3])
end

function LAMBERTIAN:scatter(r_in,rec,attenuation,scattered)
    local scatter_dir  = rec.normal + randUnitVector() 
    setAtten(attenuation,self.albedo[1],self.albedo[2],self.albedo[3])
    setScattered(scattered,rec.p,scatter_dir)
    return true
end

function METAL:scatter(r_in,rec,attenuation,scattered)
    local reflected = r_in.dir:unitVector():reflect(rec.normal)
    setAtten(attenuation,self.albedo[1],self.albedo[2],self.albedo[3])
    setScattered(scattered,rec.p,reflected + randInUnitSphere() * self.fuzz)
    return (scattered.dir:dotP(rec.normal) > 0)
end

function DIELECTRIC:scatter(r_in,rec,attenuation,scattered)
    setAtten(attenuation,1,1,1)
    local etai = nil
    if(rec.front_face == true) then
        etai = 1.0 / self.ref_idx
    else
        etai = self.ref_idx
    end
    local unit_direction = r_in.dir:unitVector()
    local cos_theta      = math.min((unit_direction * -1):dotP(rec.normal),1.0)
    local sin_theta      = math.sqrt(1.0 - cos_theta * cos_theta)
    local reflect_prob   = schlickApprox(cos_theta,etai)
    if(etai * sin_theta > 1.0 or math.random() < reflect_prob) then
        setScattered(scattered,rec.p,unit_direction:reflect(rec.normal))
    else
        setScattered(scattered,rec.p,unit_direction:refract(rec.normal,etai))
    end
    return true
end

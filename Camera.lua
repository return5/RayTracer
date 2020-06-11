local RAYs = require "Ray"

CAMERA = {
            origin = nil,lower_left = nil,
            horizontal = nil, vertical = nil,
            u = nil, v = nil, w = nil,
            lens_radius = nil
        }

function CAMERA:new(lookfrom,lookat,vup,vfov,aspect_ratio,aperture,focus)

    local o = o or {}
    setmetatable(o,self)
    self.__index      = self
    o.lens_radius     = aperture / 2
    local h           = math.tan(degreeToRadian(vfov) / 2)
    o.w               = (lookfrom - lookat):unitVector()
    o.u               = (vup:cross(o.w)):unitVector()
    o.v               = o.w:cross(o.u) * -1
    local height      = 2.0 * h
    local width       = aspect_ratio * height
    o.origin          = lookfrom
    o.horizontal      = o.u * width  * focus
    o.vertical        = o.v * height * focus
    o.lower_left      = o.origin - o.horizontal/2 - o.vertical/2 - o.w * focus
    return o
end

function CAMERA:getRay(s,t)
    local rd     = randomInUnitDisk() * self.lens_radius
    local offset = self.u * rd[1] + self.v * rd[2]
    return RAY:new(self.origin + offset,self.lower_left + self.horizontal * s + self.vertical * t - self.origin - offset)
end


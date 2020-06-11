HIT_RECORD = {p = nil,normal = nil,t = nil,front_face = nil,material = nil}
HIT_LIST   = {}

function HIT_LIST:new()    
    local o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function HIT_RECORD:new(p,normal)
    local o = o or {}
    setmetatable(o,self)
    self.__index  = self
    o.p        = p
    o.normal   = normal
    return o
end

function HIT_RECORD:setFaceNormal(ray,outward_normal)
   --is ray inside of sphere?
    self.front_face = ray.dir:dotP(outward_normal) < 0
    self.normal     = (self.front_face and outward_normal) or (outward_normal * -1)
end

function HIT_LIST:hit(ray,t_min,t_max,rec)
    local hit_anything   = false
    local closest_so_far = t_max
    for i,v in pairs(self) do
        if(v:hit(ray,t_min,closest_so_far,rec) == true ) then
            hit_anything   = true
            closest_so_far = rec.t
        end
    end
    return hit_anything
end

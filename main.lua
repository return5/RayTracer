--[[
        ray tracing program made by following through "Ray Tracing in One Weekend" by Peter Shirley
        https://raytracing.github.io/
    
        license: GPL 3.0.  written by: github/return5
    
        Copyright (C) <2020>  <return5>
    
        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.
    
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
    
        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local Camera   = require "Camera"
local Material = require "Material"

local function addSphere(world,center,diameter,material)
    world[#world + 1] = SPHERE:new(center,diameter,material)
end

local function populateWorldGIFs(world) 
    --addSphere(world,VECTOR:new(-1,0,-1),0.5,DIELECTRIC:new(1.5))
    addSphere(world,VECTOR:new(0,0,-1),0.5,LAMBERTIAN:new(VECTOR:new(0.1,0.2,0.5)))
    addSphere(world,VECTOR:new(0,-100.5,-1),100,LAMBERTIAN:new(VECTOR:new(0.8,0.8,0.0)))
    addSphere(world,VECTOR:new(1,0,-1),0.5,METAL:new(VECTOR:new(0.8,0.6,0.2),0.3))
    addSphere(world,VECTOR:new(-1,0,-1),0.5,DIELECTRIC:new(1.5))
    addSphere(world,VECTOR:new(-1,0,-1),-0.47,DIELECTRIC:new(1.5))
end

local function populateWorldStatic(world)
    addSphere(world,VECTOR:new(0,1,0),1.0,DIELECTRIC:new(1.5))
    addSphere(world,VECTOR:new(-4,1,0),1.0,LAMBERTIAN:new(VECTOR:new(0.4,0.2,0.1)))
    addSphere(world,VECTOR:new(4,1,0),1.0,METAL:new(VECTOR:new(0.7,0.6,0.5),0.0))
    addSphere(world,VECTOR:new(0,-1000,0),1000,LAMBERTIAN:new(VECTOR:new(0.5,0.5,0.5)))
end

local function randScene(world)
    local rand    = math.random
    local randD   = randDouble
    local vec     = VECTOR:new(4,0.2,0)
    local randVec = randomVec
    for a = -11,11,1 do
        for b = -11,11,1 do
            local choose_mat = rand()
            local material   = nil
            local center     = VECTOR:new( a + 0.9 * rand(), 0.2, b + 0.9 * rand())
            if((center - vec):mag() > 0.9) then
                if(choose_mat < 0.8) then
                    local albedo = randVec(0,1) * randVec(0,1)
                    material     = LAMBERTIAN:new(albedo)
                elseif(choose_mat < 0.95) then
                    material = METAL:new(randVec(0.5,1),randD(0,0.5))
                else
                    material = DIELECTRIC:new(1.5)
                end
                addSphere(world,center,0.2,material)
            end
        end
    end
end
                    
local function makeCamera(lookfrom,lookat,dist)
    local vup          = VECTOR:new(0,1,0)
    local aperture     = 0.1
    local aspect_ratio = 16.0 / 9.0
    return CAMERA:new(lookfrom,lookat,vup,20,aspect_ratio,aperture,dist)
end

local function rayTracePic(camera,world,height,width,file) 
    local file            = io.open(file,"w")
    local samples_pixel   = 100
    local max_depth       = 50
    local rand            = math.random
    local color           = VECTOR:new(0,0,0)
    io.output(file)
    io.write("P3\n",width + 1,' ',height + 1,'\n',"255\n")
    for j = height,0,-1 do
        for i = 0,width,1 do
        	color[1] = 0
        	color[2] = 0
        	color[3] = 0
            for s = 0,samples_pixel,1 do
                color = color + (camera:getRay((i + rand()) / width,(j + rand()) / height):color(world,max_depth))
            end
            color:writeColor(samples_pixel)
        end
    end
    file:close()
end

local function flyIn(height,width,world)
    local lookat = VECTOR:new(0,0,-1)   
    local str    = tostring
    for i=10,-0.3,-0.3 do
        rayTracePic(makeCamera(VECTOR:new(0,0,i),lookat,i + 1),world,height,width,"flyin_"..str(10 - i)..".ppm")
    end
end

local function dropBall(height,width,world)
    local lookat = VECTOR:new(0,0,-1)   
    local str    = tostring
    local camera = makeCamera(VECTOR:new(0,0,4),lookat,5)
    for i=2.0,-0.3,-0.3 do
        world[1].center[2] = i
        rayTracePic(camera,world,height,width,"drop_"..str((2.0 - i))..".ppm")
    end
end

local function panLeft(height,width,world)
    local lookfrom = VECTOR:new(0,0,4)
    local str      = tostring
    local lookat   = VECTOR:new(3,0,-1)
    for i=3,-2.7,-0.3 do
        lookat[1] = i
        rayTracePic(makeCamera(lookfrom,lookat,5),world,height,width,"pan_"..str(3 - i)..".ppm")
    end
end

--generates a series of images which are then combined into animated GIFs
local function makeGIFs(height,width)
    local world = HIT_LIST:new()
    populateWorldGIFs(world)
    flyIn(height,width,world)
    panLeft(height,width,world)
    dropBall(height,width,world)
end

--produces the image with lots of tiny balls as seen in Ray Tracing in One Weekend
local function makeStaticScene(height,width)
    local camera        = makeCamera(VECTOR:new(13,2,3),VECTOR:new(0,0,0),10)
    local world         = HIT_LIST:new()
    randScene(world)
    populateWorldStatic(world)
    rayTracePic(camera,world,height,width,"sample.ppm")
end

local function main()
    math.randomseed(os.time())
    local aspect_ratio    = 16.0 / 9.0
    local width           = 384
    local height          = toInteger((width) / aspect_ratio)
    makeGIFs(height - 1,width - 1)
    --makeStaticScene(height - 1,width - 1)
end

main()

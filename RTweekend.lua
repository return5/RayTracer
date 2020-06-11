INFINITY = math.huge
PI       = math.pi

function clampNum(x,min,max)
    if (x < min) then 
        return min
    elseif(x > max) then
        return max
    else
        return x
    end
end

function toInteger(x)
    if(x < 0.0) then
        return math.ceil(x) 
    else
        return math.floor(x)
    end
end

function randDouble(min,max)
    local rand = math.random
    return min + (max-min) * rand()
end

function degreeToRadian(degrees)
    return degrees * PI / 180
end

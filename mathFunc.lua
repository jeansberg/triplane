local mathFunc = {}

function mathFunc.lerp(a, b, t)
    return a * (1 - t) + b * t
end

return mathFunc

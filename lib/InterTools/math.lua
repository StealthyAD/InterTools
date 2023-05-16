--[[

    ██╗███╗   ██╗████████╗███████╗██████╗ ████████╗ ██████╗  ██████╗ ██╗     ███████╗
    ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
    ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝   ██║   ██║   ██║██║   ██║██║     ███████╗
    ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗   ██║   ██║   ██║██║   ██║██║     ╚════██║
    ██║██║ ╚████║   ██║   ███████╗██║  ██║   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
    ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
                                                                                    
    Features:
    - Compatible All Stand Versions if deprecated versions too.
    - Complete script.

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html

    Part: Math Functions
]]--

function sin(x) return math.sin(x) end
function cos(x) return math.cos(x) end
function tan(x) return math.tan(x) end
function arccos(x) return math.acos(x) end
function arcsin(x) return math.asin(x) end
function arctan(x) return math.atan(x) end
function exp(x) return math.exp(x) end
function ln(x) return math.log(x) end
function sqrt(x) return math.sqrt(x) end
function rand(x1, x2) return math.random(x1, x2) end
function pi() return math.pi() end
function absolute(x) return math.abs(x) end
function randomseed(x, y) return math.randomseed(x, y) end
function log10(x) return ln(x)/ln(10) end

function randomVariable(events, probabilities)
    local r = math.random()
    local i = 1
    while r > probabilities[i] do
        r = r - probabilities[i]
        i = i + 1
    end
    return events[i]
end

function totalProbability(events, probabilities)
    local total = 0
    for i=1,#events do
        total = total + (events[i] * probabilities[i])
    end
    return total
end

function comb(n, k)
    if k == 0 or k == n then
        return 1
    elseif k > n or k < 0 then
        return 0
    else
        local coeff = 1
        for i = 1, k do
            coeff = coeff * (n - i + 1) / i
        end
        return coeff
    end
end

function binomialDistribution(n, p, k)
    local coeff = comb(n, k)
    local prob = coeff * (p^k) * ((1-p)^(n-k))
    return prob
end
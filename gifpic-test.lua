-- better use luajit for this test
package.path = package.path .. ";?.lua;lib/?.lua"
local gifpic = require("gifpic")

local palette = {
    { 0, 0, 0 },
    { 29, 43, 83 },
    { 126, 37, 83 },
    { 0, 135, 81 },
    { 171, 82, 54 },
    { 95, 87, 79 },
    { 194, 195, 199 },
    { 255, 241, 232 },
    { 255, 0, 77 },
    { 255, 163, 0 },
    { 255, 240, 36 },
    { 0, 231, 86 },
    { 41, 173, 255 },
    { 131, 118, 156 },
    { 255, 119, 168 },
    { 255, 204, 170 },
    { 41, 24, 20 },
    { 17, 29, 53 },
    { 66, 33, 54 },
    { 18, 83, 89 },
    { 116, 47, 41 },
    { 73, 51, 59 },
    { 162, 136, 121 },
    { 243, 239, 125 },
    { 190, 18, 80 },
    { 255, 108, 36 },
    { 168, 231, 46 },
    { 0, 181, 67 },
    { 6, 90, 181 },
    { 117, 70, 101 },
    { 255, 110, 89 },
    { 255, 157, 129 },
}

local map = {[0]=0,1,17,1,19,28,12,6,16,18,20,4,25,9,15,7}
local function sin(v) return -math.sin(v*6.283185307179586) end
local function cos(v) return  math.cos(v*6.283185307179586) end
function Q(u,v,n,z)
    n,z = n or 8, z or 0
    local g, e = .6, 0
    for i=1,n do
        g = g*2
        e = e+.6^i*(sin(2^i*u+sin(g*v)/2)+sin(g*v+sin(g*u)/4+sin(g*e*z)))
    end
    return math.abs(e)
end

local b,k,x,y,z
local gp = gifpic.new(2048,2048,palette)

for c=0,2,1/gp.width do
    b=.6+c/6
    for a=0,2,1/gp.width/6 do
        z=.03+sin(b)*sin(a)/50
        if(z<.015)then
            k = math.floor(Q(a,b))*8+c+math.min(Q(a*4,b*2,5,.1)*c*5,6)
            k = k + math.random()*(k%1-0.5)*2
            k = k - k%1
            k = map[k]
            x = gp.width/2+(cos(b)*sin(a)/z)*gp.width/128
            y = gp.height/2+cos(a)/z*gp.width/128
            gp:pset(x,y,k)
        end
    end
end

gp:save("earth.gif")

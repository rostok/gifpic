# gifpic
GIFPIC is a ultra simple GIF encoder for Lua capable of handling very large resolutions.
The rationale for this was to overcome LOVE2D texture size limit in order to save enourmous game map. GIFPIC should handle massive resolutions like 32000x32000.

# usage
quite simple really. require gipic, call `new()`, draw with `pset()` and finally `save()`

```lua
package.path = package.path .. ";?.lua;lib/?.lua"
local gifpic = require("gifpic")

local palette = { {0,0,0}, {255,255,255} }

-- initialize gifpic canvas and set the palette
local gp = gifpic.new(128,128,palette)

for y=0,127 do
    for x=0,127 do
        -- draw some pixels
        local c = math.floor((math.abs((x+math.sin(y/5)*16)%64-32)+math.abs((y-math.sin(x/5)*16)%64-32))/16)%2
        gp:pset(x,y,c)
    end
end

-- write GIF file
gp:save("test.gif")
```
# pronunciation
for the GIFPIC use the hard "G" like in a word *geek*.

# license
MIT with additional condition that you can't use this for anything concerning military.

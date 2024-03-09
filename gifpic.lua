-- a simple GIF encoder library by rostok
-- based on gamax92's code for PICO-8
-- proper info https://www.w3.org/Graphics/GIF/spec-gif89a.txt
local bit = require("bit")

local function log2(x) return math.log(x) / math.log(2) end
local function num2str(data) return string.char(bit.band(data, 0xFF), bit.rshift(data, 8)) end

local gifpic = {}
gifpic.__index = gifpic

-- create new gif image, w/h are width/height, palette table is first color has 1 index
function gifpic.new(w, h, palette)
    local self = setmetatable({}, gifpic)
    self.width = w
    self.height = h
    self.palette = {}
    -- copy the palette by hand to make sure 1st color index is 1 not 0
    for i = (palette[0]~=nil and 0 or 1),#palette do
        local sc = palette[i]
        local dc = {}
        for _,rgb in pairs(sc) do dc[#dc+1] = rgb end
        self.palette[#self.palette+1] = dc
    end
    self:clear(0)
    local ps = #self.palette
    if ps<2^math.ceil(log2(ps)) then
        for i=ps+1,2^math.ceil(log2(ps)) do
            self.palette[i] = {0,0,0}
        end
    end
    return self
end

-- prepare gifpic canvas and, if provided, set the color (0 by default)
function gifpic:clear(color)
    self.pixels = {}
    local w,h = self.width, self.height
    for y = 0, h - 1 do
		local row = {}
		self.pixels[y]=row
        for x = 0, w - 1 do
            row[x] = color
        end
    end
end

-- pixel set at x,y post with color index
function gifpic:pset(x, y, color)
    if(y>=0 and y<self.height and x>=0 and x<self.width) then
		self.pixels[math.floor(y)][math.floor(x)] = color
    end
end

-- save gif to file
function gifpic:save(filename)
    local file = assert(io.open(filename, "wb"))

    -- Write GIF Header
    file:write("GIF89a")

    -- Logical Screen Descriptor, Logical Screen Width + Height
    file:write(num2str(self.width), num2str(self.height))
    -- packed field
    file:write(string.char(0xF0 + math.ceil(log2(#self.palette)-1)))
    --  Background Color Index ,  Pixel Aspect Ratio
    file:write("\0\0") 

    -- Global Color Table
    for _, color in ipairs(self.palette) do
        file:write(string.char(color[1], color[2], color[3]))
    end

	file:write("\33\249\4\4\3\0\0\0")

    local x0,y0,x1,y1 = 0,0,self.width-1,self.height-1
	file:write("\44"..num2str(x0)..num2str(y0)..num2str(x1-x0+1)..num2str(y1-y0+1).."\0")

    -- LZW Minimum Code Size
    file:write("\8") -- Start with code size 8

	local trie={}
	for i=0, 255 do trie[i]={[-1]=i} end
	local last=257
	local trie_ptr=trie
	local stream={256}
	for y=y0, y1 do
		for x=x0, x1 do

            local index = math.floor(self.pixels[y][x] or 0)
            if trie_ptr[index] then
				trie_ptr = trie_ptr[index]
			else
				stream[#stream+1]=trie_ptr[-1]
				last=last+1
				if last<4095 then
					trie_ptr[index]={[-1]=last}
				else
					stream[#stream+1]=256
					--trie={}
					for i=0, 255 do trie[i]={[-1]=i} end
					last=257
				end
				trie_ptr=trie[index]
			end
		end
	end
	stream[#stream+1]=trie_ptr[-1]
	stream[#stream+1]=257
	local output={}
	local size=9
	local bits=0
	local pack=0
	local base=-256
	for i=1, #stream do
		pack=pack+bit.lshift(stream[i], bits)
		bits=bits+size
		while bits>=8 do
			bits=bits-8
			output[#output+1]=string.char(bit.band(pack, 0xFF))
			pack=bit.rshift(pack, 8)
		end
		if i-base>=2^size then
			size=size+1
		end
		if stream[i]==256 then
			base=i-257
			size=9
		end
	end
	while bits>0 do
		bits=bits-8
		output[#output+1]=string.char(bit.band(pack, 0xFF))
		pack=bit.rshift(pack, 8)
	end
	output=table.concat(output)

    -- optimized for large GIFs so output is not modified 
    local index = 1  -- Initialize an index to keep track of the current position in the output string.
    local outputLength = #output  -- Store the total length of the output string for efficiency.
    while index <= outputLength do
        local chunkSize = math.min(255, outputLength - index + 1)  -- Calculate the size of the next chunk, ensuring it does not exceed 255 characters or the remaining length of the string.
        local chunk = output:sub(index, index + chunkSize - 1)  -- Extract the current chunk based on the index.
        file:write(string.char(chunkSize)..chunk)  -- Prepend the chunk size as a single byte, then write the chunk itself to the file.
        index = index + chunkSize  -- Update the index to the next position after the current chunk.
    end

	file:write("\0")

    -- good bye
    file:write("\59")

    assert(file:close())
end

return gifpic
-- pl-ana-4-perch.lua - chibi green plant-pal with red blossom, on a mossy stone perch
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ana-4-perch-20261120-162805/"
local GV = dofile(D .. "gvlib/gvlib.lua")
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#4f3e57", "#2b1c26", "#2b1c26"

local c = GV.canvas{ w = 36, h = 36, ol = 1, olx = 1 }

local R_BLOSSOM = GV.ramp("#c03b3d", { gloss = "#de7a73", dot = "#ecb4ac", shade = "#a5273d", deep = "#781c42", bounce = "#b8452f" })
local R_HEAD    = GV.ramp("#669f60", { gloss = "#99ce93", shade = "#42793c", deep = "#2c5d3d" })
local R_BODY    = GV.ramp("#42793c", { shade = "#2c5d3d", deep = "#204535" })
local R_STONE   = GV.ramp("#9d717c", { shade = "#7a5f6a", deep = "#4f3e57" })
local R_MUZZLE  = GV.ramp("#8ad0b6", { gloss = "#b9e5d6", dot = "#c5eadf" })
local R_BLUE    = GV.ramp("#4ca9c9")

c:ground(16.5, 30, 10.5, 1.5, "#4f3e57")

local mBlossom = c:ellipse(12.5, 7, 3, 2.5)
mBlossom:add(c:ellipse(18.5, 7, 3, 2.5))
mBlossom:add(c:ellipse(15.5, 6, 3.5, 2))
local mBloom2 = c:ellipse(22.5, 7.5, 2.5, 1.5)

local p = c:build{
  { "blossom", mBlossom, R_BLOSSOM, {} },
  { "bloom2",  c:ellipse(22.5, 7, 2.5, 1.5), R_BLOSSOM, {} },
  { "stone",   c:rrect(10, 24, 23, 29, 2), R_STONE, { cres = 1, deep = 1 } },
  { "body",    c:rrect(11, 19, 22, 25, 4), R_BODY, {} },
  { "footeL",  c:rrect(13, 25, 15, 26, 1), R_BODY, { flat = true } },
  { "footeR",  c:rrect(18, 25, 20, 26, 1), R_BODY, { flat = true } },
  { "head",    c:ellipse(15.5, 13.5, 9.5, 7.5), R_HEAD, {} },
  { "muzzle",  c:ellipse(15.5, 17, 3, 2), R_MUZZLE, { contour = false, bounce = false, cres = 1, deep = 1 } },
  { "wing",    (function() local m = c:ellipse(27.5, 13.5, 1.5, 1.5) m:add(c:ellipse(29, 16, 1.5, 1.5)) return m end)(), R_BLUE, { flat = true, contour = false } },
}

-- face
c:eye(10, 11); c:eye(17, 11)
c:px(14, 17, R_BLOSSOM.shade); c:px(15, 17, R_BLOSSOM.shade); c:px(16, 17, R_BLOSSOM.shade) -- open mouth
c:px(14, 18, R_BLOSSOM.deep); c:px(15, 18, R_BLOSSOM.deep); c:px(16, 18, R_BLOSSOM.deep)
c:px(8, 13, "#f5a0b8"); c:px(9, 13, "#f5a0b8") -- blush
c:px(22, 13, "#f5a0b8"); c:px(23, 13, "#f5a0b8")

-- accents
c:px(28, 14, "#2b1c26"); c:px(28, 15, "#2b1c26") -- butterfly body
c:px(13, 27, R_STONE.shade); c:px(20, 27, R_STONE.shade) -- stone speckles (visible front)
c:px(26, 12, "#c5eadf") -- wing glint
c:px(5, 8, GV.C.gold); c:px(4, 9, GV.C.goldS); c:px(6, 9, GV.C.goldS); c:px(5, 10, GV.C.gold) -- spark

-- texture: hand-placed, subtle
c:px(13, 4, R_BLOSSOM.deep); c:px(13, 5, R_BLOSSOM.deep) -- wine notch between lobes
c:px(17, 4, R_BLOSSOM.deep); c:px(17, 5, R_BLOSSOM.deep)
c:px(9, 9, R_HEAD.shade); c:px(12, 8, R_HEAD.shade); c:px(9, 12, R_HEAD.shade) -- leaf specks, lit zone
for _, y in ipairs({ 9, 12, 15, 19 }) do -- light dents in the terminator
  for x = 6, 25 do if c:get(x, y) == R_HEAD.shade then c:px(x, y, R_HEAD.base) break end end
end
for _, y in ipairs({ 11, 14 }) do -- shade dents
  for x = 6, 25 do
    if c:get(x, y) == R_HEAD.base and c:get(x + 1, y) == R_HEAD.shade then c:px(x, y, R_HEAD.shade) break end
  end
end
-- stone speckles moved next to the accents block (visible front face)

local t = c:save(D .. "out/pl-ana-4-perch.aseprite", D .. "out/pl-ana-4-perch.png")
print(GV.report(t))

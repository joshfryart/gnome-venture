-- pl-bjq-5-perch: chibi perch of the crowned teal pal (36x36)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-bjq-5-perch-20261120-170159/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- ramps (anchored on the pal's palette)
local R_TEAL  = GV.ramp("#59b7ca", { gloss = "#a3dcd6", shade = "#357fa1", deep = "#22486b" })
local R_GOLD  = GV.ramp("#e8b030", { gloss = "#fae899", shade = "#a27855", deep = "#5f4146" })
local R_STONE = GV.ramp("#6e5e8e", { shade = "#5f4146", deep = "#2b1c26" })
local R_BROWN = GV.ramp("#a27855", { deep = "#5f4146" })

-- soft ground shadow under everything
c:ground(16.5, 28.5, 11, 2.2, "#5f4146")

local p = c:build{
  { "body",  c:rrect(9, 18, 22, 24, 2), R_TEAL,  {} },
  { "slab",  c:rrect(6, 22, 24, 28, 3),  R_STONE, {} },
  { "head",  c:ellipse(15.5, 14.5, 7, 6), R_TEAL, { contour = false } },
  -- crown: one part (band + 3 spikes) so the outline runs only around the perimeter
  { "crown", (function()
      local m = c:rrect(9, 7, 22, 9, 1)
      m:add(c:rect(10, 6, 12, 7)); m:add(c:rect(14, 6, 16, 7)); m:add(c:rect(18, 6, 20, 7))
      return m
    end)(), R_GOLD, { flat = true } },
  { "mound", c:rrect(23, 25, 28, 27, 1), R_GOLD,  { flat = true } },
}
local rowfill = function(m, y, hex) local t = m:copy(); t:clip(c:rect(0, y, 35, y)); c:fill(t, hex) end
-- crown shading: rim row (auto) / gold base row w/ 2 gems / shade row; rims on lit left edges
rowfill(p.crown.m, 9, R_GOLD.shade)
rowfill(p.crown.m, 8, R_GOLD.base)
c:px(13, 8, R_GOLD.deep); c:px(18, 8, R_GOLD.deep)           -- gems
for _, sx in ipairs({ 10, 14, 18 }) do
  c:px(sx + 1, 6, R_GOLD.gloss); c:px(sx + 2, 6, R_GOLD.base)
  c:px(sx, 6, R_GOLD.rim)
  c:px(sx, 7, R_GOLD.base); c:px(sx + 1, 7, R_GOLD.base); c:px(sx + 2, 7, R_GOLD.base)
end
c:px(13, 7, R_GOLD.base); c:px(17, 7, R_GOLD.base)           -- solid gold in the spike gaps
c:px(21, 7, R_GOLD.shade); c:px(22, 8, R_GOLD.shade)         -- crown's shaded right end
-- mound shading: rim row (auto) / gold middle / brown shade bottom, 1px gloss glint
rowfill(p.mound.m, 26, R_GOLD.base)
rowfill(p.mound.m, 27, R_GOLD.shade)
c:px(24, 26, R_GOLD.gloss)
-- face: locked 5x5 eyes on the 15px head, tiny mouth, 1px cheek accents
c:eye(9, 12); c:eye(17, 12)
c:px(10, 13, "#fae899"); c:px(18, 13, "#fae899")             -- eye glints
c:fill(c:rect(15, 17, 16, 17), "#2b1c26")                    -- tiny mouth
c:px(9, 17, "#e8b030"); c:px(21, 17, "#e8b030")              -- cheeks
c:px(10, 17, "#e8b030"); c:px(20, 17, "#e8b030")
-- enamel gloss comma on the forehead, above the eyes
c:px(11, 10, R_TEAL.gloss); c:px(10, 11, R_TEAL.gloss); c:px(10, 10, R_TEAL.gloss)
-- subtle hand texture: 1px stone joint + tone-on-tone dither at the slab terminator
c:px(9, 26, R_STONE.shade); c:px(14, 26, R_STONE.shade); c:px(20, 25, R_STONE.shade)
c:px(13, 24, R_STONE.base); c:px(17, 23, R_STONE.gloss)
-- deep crescent belongs to the lower-right: soften the wrong-side deep on the bottom-left
for x = 7, 14 do
  for y = 27, 28 do
    if c:get(x, y) == R_STONE.deep then c:px(x, y, R_STONE.shade) end
  end
end

local t = c:save(D .. "out/pl-bjq-5-perch.aseprite", D .. "out/pl-bjq-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

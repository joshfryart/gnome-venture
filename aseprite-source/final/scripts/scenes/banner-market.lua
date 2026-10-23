-- scenes/banner-market : 480x120, drawn 240x60 written 2x. Three stalls with striped awnings, bunting, cobbles. Gold hem stitch top and bottom.
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 240, h = 60, mode = "scene", out = 2, ol = 1, olx = 1 }
local W = 240
local WOOD = GV.ramp("#b07a45", { shade = "#8a4f2a", deep = "#8a4f2a", bounce = "#8a4f2a", rim = "#d9a660" })
local RED = GV.ramp("#dd3a2a", { shade = "#ae2a2a", deep = "#ae2a2a", bounce = "#ae2a2a", rim = "#f2793a" })
c:bands(c:rect(0, 0, W - 1, 37), { "#bfe3ee", "#d3ecea", "#e6f0d6", "#f3efc9" })
c:fill(c:rect(0, 28, W - 1, 37), "#c9a96e")                                              -- far town wall (stone, pale)
for x = 0, W - 1, 8 do c:fill(c:rect(x, 24, x + 3, 27), "#c9a96e") end                  -- crenels
c:fill(c:rect(0, 38, W - 1, 59), "#c9a96e")                                              -- cobbled square
for y = 40, 56, 5 do for x = (y % 10 == 0) and 0 or 4, W - 1, 8 do c:fill(c:rect(x, y, x + 5, y), "#a8582f") end end
-- bunting string
for x = 0, W - 1 do c:px(x, 8 + math.floor(3 * math.sin(x / 38 * math.pi) + 0.5) + 3, "#4a2c1a") end
local flags = { "#dd3a2a", "#f5cf6a", "#3f8fb0" }
for i = 0, 17 do
  local x = 6 + i * 13
  local y = 11 + math.floor(3 * math.sin(x / 38 * math.pi) + 0.5)
  c:fill(c:poly({ { x, y }, { x + 6, y }, { x + 3, y + 5 } }), flags[i % 3 + 1])
end
local function stall(x0, x1, top, good, goodHex)
  local w = x1 - x0
  c:part(c:rect(x0 + 2, top + 12, x1 - 2, 50), WOOD, { gloss = false, cres = 3 })     -- counter body
  c:part(c:rect(x0, top + 10, x1, top + 13), WOOD, { gloss = false, flat = true }) -- counter top
  for i = 0, 3 do c:part(c:ellipse(x0 + 8 + i * (w - 16) / 3, top + 8, 3, 3), goodHex, { gloss = false, flat = true }) end
  local aw = c:poly({ { x0 + 2, top - 6 }, { x1 - 2, top - 6 }, { x1 + 3, top + 4 }, { x0 - 3, top + 4 } })
  c:part(aw, RED, { gloss = false, cres = 3 })
  for x = x0 - 3, x1 + 3, 8 do c:fill(c:rect(x, top - 6, x + 3, top + 4):clip(aw), "#f2e4c0") end
  c:fill(c:rect(x0 - 3, top + 4, x1 + 3, top + 4), "#ae2a2a")                             -- hem shade
  c:part(c:rect(x0 - 1, top + 5, x0, top + 22), WOOD, { gloss = false, flat = true })   -- posts
  c:part(c:rect(x1, top + 5, x1 + 1, top + 22), WOOD, { gloss = false, flat = true })
end
stall(14, 70, 26, "apple", "#dd3a2a")
stall(92, 150, 24, "loaf", "#f5cf6a")
stall(172, 226, 26, "cabbage", "#7ab55c")
-- hem: felt band with a gold stitch 2 on / 1 off along top and bottom edges
for _, y0 in ipairs({ 0, 57 }) do
  c:fill(c:rect(0, y0, W - 1, y0 + 2), "#7a4a1f")
  for x = 0, W - 1 do if x % 3 < 2 then c:px(x, y0 + 1, "#f5cf6a") end end
end
H.done(c, "banner-market", "scenes/banner-market.png", 24, true)

-- scenes/shop-general : 480x120, drawn 240x60 written 2x (size per art-handoff test run). Shelves of goods, counter along the bottom.
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 240, h = 60, mode = "scene", out = 2, ol = 1, olx = 1 }
local W = 240
local WOOD = GV.ramp("#b07a45", { shade = "#8a4f2a", deep = "#8a4f2a", bounce = "#8a4f2a", rim = "#d9a660" })
c:bands(c:rect(0, 0, W - 1, 59), { "#f1d9a0", "#ecce90", "#e6c383", "#dfb877", "#d9ad6b" }, { dir = "h" })
for x = 12, W - 1, 24 do c:fill(c:rect(x, 3, x, 59), "#c9a96e") end
c:fill(c:rect(0, 0, W - 1, 2), "#8a4f2a"); c:fill(c:rect(0, 3, W - 1, 3), "#5e2f1e")
local goods = { "#dd3a2a", "#7ab55c", "#f5cf6a", "#3f8fb0" }
for row = 0, 1 do
  local y = 22 + row * 17
  c:part(c:rect(6, y, W - 7, y + 2), WOOD, { gloss = false, flat = true })              -- shelf plank
  for i = 0, 15 do
    local x = 12 + i * 14
    local g = goods[(i + row * 2) % #goods + 1]
    if (i + row) % 3 == 0 then c:part(c:rrect(x, y - 9, x + 7, y - 1, 2), g, { gloss = false, flat = true })   -- jar
    elseif (i + row) % 3 == 1 then c:part(c:rect(x, y - 7, x + 8, y - 1), g, { gloss = false, flat = true })  -- tin
    else c:part(c:ellipse(x + 4, y - 4, 4, 3), g, { gloss = false, flat = true }) end                            -- sack
  end
end
c:part(c:rect(-2, 51, W + 1, 61), WOOD, { cres = 3, deep = 1 })                         -- counter along the bottom
c:fill(c:rect(0, 51, W - 1, 52), "#d9a660")
for x = 0, W - 1 do if x % 3 < 2 then c:px(x, 56, "#f5cf6a") end end                    -- gold hem stitch on the counter cloth
H.done(c, "shop-general", "scenes/shop-general.png", 24, true)

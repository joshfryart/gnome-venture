-- harvest-soil.lua : little soil bed under each harvest plant, Stitched Toy, 48x24.
-- Two same-footprint PNGs: harvest-soil-planted.png (tidy dark ring where the plant sits,
-- 3 crumbs) and harvest-soil-pulled.png (ring is now a hole, loose crumbs, stitched seam
-- across the front). harvest-soil.aseprite holds them as 2 frames.
-- Families: soil preset (#9a6b3f mound), soil dark #3d2a1c (ring/hole), wood deep #5e2f1e
-- (hole back wall), soil #c9a96e (crumb tops), gold (seam).
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/extras-pixel/"
local G = "/home/user/gnome-venture/game/assets/img/"
local S = GV.R.soil
local W, H = 48, 24
local HX, HY = 23.5, 10.5 -- ring / hole centre

local function mound(c)
  local m = c:ellipse(23.5, 12.5, 18.5, 6)
  m:add(c:ellipse(23.5, 11, 13.5, 5))  -- domed top
  c:part(m, "soil", { gloss = { 11, 9 }, cres = 3, deep = 2 })
  return m
end

local function crumb(c, x, y, big)
  c:px(x, y, "#c9a96e")
  if big then c:px(x + 1, y, S.rim) c:px(x + 1, y + 1, S.shade) end
  c:px(x, y + 1, S.shade)
end

local function planted(c)
  mound(c)
  local outer = c:ellipse(HX, HY, 6.5, 2.5)
  local inner = c:ellipse(HX, HY, 4.5, 1.5)
  local ring = outer:copy():cut(inner)
  c:fill(ring, "#3d2a1c")
  -- lit lip on the front edge of the ring (catches the upper-left light)
  outer:each(function(x, y) if not outer:has(x, y + 1) and c:get(x, y + 1) then c:px(x, y + 1, S.rim) end end)
  -- inside of the ring: firm patted soil, a touch darker
  c:fill(inner, S.shade)
  c:px(21, 10, S.base)
  -- 3 crumb pixels
  c:px(10, 13, "#c9a96e"); c:px(34, 9, "#c9a96e"); c:px(29, 16, "#c9a96e")
end

local function pulled(c)
  mound(c)
  local hole = c:ellipse(HX, HY, 6.5, 2.5)
  c:fill(hole, "#3d2a1c")
  hole:each(function(x, y)
    if not hole:has(x, y - 1) then c:px(x, y, "#5e2f1e") end        -- back wall
    if not hole:has(x, y + 1) and c:get(x, y + 1) then c:px(x, y + 1, S.rim) end -- front lip
  end)
  c:fill(c:ellipse(HX + 0.5, HY + 0.5, 3.5, 1), "#2a1a10")           -- deep middle
  -- stitched seam across the front of the mound (toy look)
  c:seam({ { 8, 15 }, { 13, 16 }, { 20, 17 }, { 28, 17 }, { 34, 16 }, { 39, 15 } })
  -- loose crumbs scattered
  crumb(c, 12, 10, true); crumb(c, 33, 12, true); crumb(c, 16, 14)
  crumb(c, 36, 8); crumb(c, 27, 14, true); crumb(c, 8, 12); crumb(c, 40, 13)
end

local cp = GV.canvas{ w = W, h = H, mode = "sticker" }; planted(cp)
local cq = GV.canvas{ w = W, h = H, mode = "sticker" }; pulled(cq)
local tp = cp:save(nil, O .. "png/harvest-soil-planted.png")
local tq = cq:save(nil, O .. "png/harvest-soil-pulled.png")

-- harvest-soil.aseprite: frame 1 planted, frame 2 pulled
local spr = Sprite(W, H, ColorMode.RGB)
spr.layers[1].name = "Soil"
spr.cels[1].image = cp:image()
local f2 = spr:newEmptyFrame()
spr:newCel(spr.layers[1], f2, cq:image(), Point(0, 0))
spr:saveAs(O .. "aseprite/harvest-soil.aseprite")
spr:close()

print("harvest-soil-planted " .. GV.report(tp))
print("harvest-soil-pulled  " .. GV.report(tq))
assert(tp.semi == 0 and tp.bw == 0 and tq.semi == 0 and tq.bw == 0)

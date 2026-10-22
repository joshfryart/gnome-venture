-- puzzles/flower.gif : pink two-layer flower on a sky-to-meadow backdrop.
-- Outer 8 petals turn clockwise, inner 8 counter-clockwise, 45 deg per loop (seamless, 8-fold symmetry).
-- 24 frames x 70 ms, 300x300 solid background. Drawn on a 150 grid, written at 2x nearest.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local N, FR, DUR = 8, 24, 0.07
local CX, CY = 74.5, 62.5
local SKY = { "#bee6f9", "#c4eaf0", "#c8ecdc", "#d2f0d6", "#dbf4d2" }
local OUTER = GV.ramp("#e46a9b")                  -- Part A petal
local INNER = GV.ramp("#f6b8cf")                  -- Part A petal light (pale, cream-safe gloss)

-- rotated ellipse petal: centre at radius rc along angle a, half length hl, half width hw;
-- pinched toward the flower centre so it reads as a petal, not a bean
local function petal(c, a, rc, hl, hw)
  local m = c:mask()
  local ca, sa = math.cos(a), math.sin(a)
  local R = rc + hl + 2
  for y = math.floor(CY - R), math.ceil(CY + R) do for x = math.floor(CX - R), math.ceil(CX + R) do
    local dx, dy = x - CX, y - CY
    local u = dx*ca + dy*sa - rc
    local v = -dx*sa + dy*ca
    local t = u / hl
    local w = hw * (t < 0 and (1 + 0.35*t) or 1)
    if t >= -1 and t <= 1 and (v / w)^2 + t*t <= 1 then m:set(x, y) end
  end end
  return m
end

local function frame(f)
  local c = GV.canvas{ w = 150, h = 150, mode = "scene", out = 2 }
  c:bands(nil, SKY)
  -- stem and leaves (static)
  c:part(c:line({ {74, 70}, {74, 155} }, 5), "moss", { gloss = false, cres = 3, deep = 0 })
  local lv = c:ellipse(58.5, 119.5, 14, 5):add(c:rect(70, 118, 73, 121))
  local rv = c:ellipse(91.5, 105, 13, 4.5):add(c:rect(76, 103, 79, 106))
  c:part(lv, "moss", { cres = 4, deep = 2, gloss = { 50, 116 } })
  c:part(rv, "moss", { cres = 4, deep = 2, gloss = { 83, 102 } })
  c:seam({ {47, 120}, {69, 120} })                -- stitched midribs
  c:seam({ {81, 105}, {102, 105} })
  -- outer petals, clockwise
  local ao = (f - 1) * (math.pi / 4) / FR
  for i = 0, N - 1 do
    local a = -math.pi/2 + i * 2*math.pi/N + ao
    c:part(petal(c, a, 29, 20, 10.5), OUTER, { stitch = true, cres = 6, deep = 3 })
  end
  -- inner petals, counter-clockwise, offset half a petal
  local ai = -(f - 1) * (math.pi / 4) / FR
  for i = 0, N - 1 do
    local a = -math.pi/2 + math.pi/N + i * 2*math.pi/N + ai
    c:part(petal(c, a, 19, 13, 6.5), INNER, { cres = 5, deep = 2 })
  end
  -- gold felt centre with a thread ring and seed knots
  local ctr = c:ellipse(CX, CY, 12.5)
  c:part(ctr, "gold", { cres = 6, deep = 2, gloss = { 68, 56 } })
  local ring = {}
  for k = 0, 48 do local t = k * 2*math.pi/48 ring[#ring+1] = { CX + 8.5*math.cos(t), CY + 8.5*math.sin(t) } end
  c:seam(ring, { gap = "#d0862a" })
  for _, p in ipairs({ {74, 62}, {77, 65}, {71, 66}, {78, 60}, {72, 59} }) do c:px(p[1], p[2], "#8a4a1c") end
  return c:image()
end

local spr = Sprite(300, 300, ColorMode.RGB)
for f = 1, FR do
  if f > 1 then spr:newEmptyFrame() end
  spr:newCel(spr.layers[1], spr.frames[f], frame(f), Point(0, 0))
  spr.frames[f].duration = DUR
end
pcall(function() app.fs.makeAllDirectories(O .. "aseprite") end)
pcall(function() app.fs.makeAllDirectories(O .. "png") end)
spr:saveAs(O .. "aseprite/flower.aseprite")
spr:saveCopyAs(O .. "png/flower.gif")
local img = Image(300, 300, ColorMode.RGB); img:drawSprite(spr, 1)
print(GV.report(GV.check(img)))
spr:close()

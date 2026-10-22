-- Gnome Venture flower head: daisy (Stitched Toy). Petals neutral grey (tinted at runtime), centre fixed gold.
-- Writes daisy.png (full), daisy-petals.png, daisy-centre.png and daisy.aseprite (layers petals + centre).
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0, cx = 31.5, cy = 31.5 }
c.t1 = -999 -- outline uses only the dark umbers (#4a2c1a lit, #2a1a10 shaded) so it survives a multiply tint

local CX, CY = 31.5, 31.5
local function petal(angDeg, d, rx, ry)
  local a = math.rad(angDeg)
  local ux, uy = math.sin(a), -math.cos(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - CX, y - CY
    local al = dx*ux + dy*uy - d
    local ac = dx*(-uy) + dy*ux
    if (ac/rx)^2 + (al/ry)^2 <= 1 then m:set(x, y) end
  end end
  return m, ux, uy
end

-- neutral grey felt ramps (no hue)
local FRONT = { base="#e2e2e2", rim="#efefef", gloss="#f7f7f7", dot="#fcfcfc", bounce="#bebebe", shade="#b2b2b2", deep="#8c8c8c", pale=false }
local BACK  = { base="#c9c9c9", rim="#d9d9d9", gloss="#e9e9e9", dot="#f2f2f2", bounce="#a9a9a9", shade="#9d9d9d", deep="#787878", pale=false }
local CREASE_F, CREASE_B = "#c6c6c6", "#b0b0b0"

local creases = {}
-- back ring: 6 petals between the front ones, slightly shorter
for i = 0, 5 do
  local ang = 30 + i*60
  local m, ux, uy = petal(ang, 13.5, 4.2, 11.5)
  c:part(m, BACK, { cres = 3, deep = 1, gloss = false })
  creases[#creases+1] = { m, ux, uy, 11, 21, CREASE_B }
end
-- front ring: 6 petals on the cardinal/60-degree axes
for i = 0, 5 do
  local ang = i*60
  local m, ux, uy = petal(ang, 14, 4.6, 12.5)
  c:part(m, FRONT, { cres = 3, deep = 1 })
  creases[#creases+1] = { m, ux, uy, 11, 22, CREASE_F }
end
-- quilted crease down each petal: grey running stitch, 2 on / 1 off (stays grey, tints with the petal)
for _, cr in ipairs(creases) do
  local m, ux, uy, r0, r1, col = cr[1], cr[2], cr[3], cr[4], cr[5], cr[6]
  local n, seen = 0, {}
  for r = r0, r1, 0.5 do
    local x, y = math.floor(CX + ux*r + 0.5), math.floor(CY + uy*r + 0.5)
    local k = y*64 + x
    if not seen[k] then
      seen[k] = true
      local cur = c:get(x, y)
      if m:has(x, y) and n % 3 < 2 and cur ~= FRONT.gloss and cur ~= FRONT.dot and cur ~= BACK.gloss then
        if cur == FRONT.base or cur == FRONT.rim or cur == BACK.base or cur == BACK.rim then c:px(x, y, col) end
      end
      n = n + 1
    end
  end
end

-- fixed gold felt centre: cushion with an ember edge stitch and seed knots
local centre = c:ellipse(31.5, 31.5, 8.5, 8.5)
c:part(centre, "gold", { cres = 3, deep = 1, bounce = false })
local x0, y0, x1, y1 = centre:bbox()
local inner = centre:shrink(1)
local ring = inner:copy():cut(inner:shrink(1)) -- 2 px inside the edge
ring:each(function(x, y)
  local cur = c:get(x, y)
  if (x + y) % 3 == 0 and cur ~= GV.R.gold.rim and cur ~= GV.R.gold.gloss and cur ~= GV.R.gold.dot then
    c:px(x, y, (cur == GV.R.gold.shade or cur == GV.R.gold.deep) and "#7a3a14" or "#b8661a")
  end
end)
-- seed knots (French knots), ember family
c:paint({
  "..s...",
  "s...s.",
  "..d...",
  ".s..d.",
}, 29, 30, { s = "#b8661a", d = "#7a3a14" })

-- ---------------------------------------------------------------- split + save
local img = c:image()
local t = GV.check(img)
local pc = app.pixelColor
local clear = pc.rgba(0, 0, 0, 0)
local pet = Image(64, 64, ColorMode.RGB); pet:clear(clear)
local cen = Image(64, 64, ColorMode.RGB); cen:clear(clear)
for y = 0, 63 do for x = 0, 63 do
  local v = img:getPixel(x, y)
  if pc.rgbaA(v) > 0 then
    if centre:has(x, y) then cen:putPixel(x, y, v) else pet:putPixel(x, y, v) end
  end
end end

local function savePng(im, path)
  local s = Sprite(64, 64, ColorMode.RGB)
  s.cels[1].image = im
  s:saveCopyAs(path)
  s:close()
end
pcall(function() app.fs.makeAllDirectories(OUT .. "png") end)
pcall(function() app.fs.makeAllDirectories(OUT .. "aseprite") end)
savePng(img, OUT .. "png/daisy.png")
savePng(pet, OUT .. "png/daisy-petals.png")
savePng(cen, OUT .. "png/daisy-centre.png")

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"
spr.cels[1].image = pet
local L2 = spr:newLayer(); L2.name = "centre"
spr:newCel(L2, 1, cen, Point(0, 0))
spr:saveAs(OUT .. "aseprite/daisy.aseprite")
spr:close()
print(GV.report(t))

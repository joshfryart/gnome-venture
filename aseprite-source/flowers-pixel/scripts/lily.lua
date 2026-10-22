-- Gnome Venture flower head: lily (Stitched Toy, tintable). Petals neutral grey, centre fixed gold/ember.
-- Outputs lily.png (full), lily-petals.png, lily-centre.png, lily.aseprite (layers: petals, centre).
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0 }

local CX, CY, S = 31.5, 31.5, 0.86
-- sample the SVG petal (pointing up) and rotate/scale it about the centre
local function petal(p0, c1, c2, p3, q1, q2, ang)
  local pts = {}
  local function bez(a, b, cc, d)
    for i = 0, 23 do
      local t = i / 24; local u = 1 - t
      local x = u^3*a[1] + 3*u*u*t*b[1] + 3*u*t*t*cc[1] + t^3*d[1]
      local y = u^3*a[2] + 3*u*u*t*b[2] + 3*u*t*t*cc[2] + t^3*d[2]
      pts[#pts+1] = { x, y }
    end
  end
  bez(p0, c1, c2, p3); bez(p3, q1, q2, p0)
  local a = math.rad(ang)
  local out = {}
  for _, p in ipairs(pts) do
    local dx, dy = (p[1] - 32) * S, (p[2] - 32) * S
    out[#out+1] = { CX + 0.5 + dx*math.cos(a) - dy*math.sin(a), CY + 0.5 + dx*math.sin(a) + dy*math.cos(a) }
  end
  return c:poly(out)
end
local function dir(ang, r) local a = math.rad(ang) return CX + r*math.sin(a), CY - r*math.cos(a) end

-- neutral grey ramps (no hue; the game multiplies a tint over them)
local FRONT = { gloss="#f6f6f6", dot="#fcfcfc", rim="#eaeaea", base="#dadada", bounce="#b2b2b2", shade="#a4a4a4", deep="#747474" }
local BACK  = { gloss="#e4e4e4", dot="#eeeeee", rim="#d2d2d2", base="#bebebe", bounce="#999999", shade="#8c8c8c", deep="#646464" }
local VEIN, FRECK = "#8e8e8e", "#6a6a6a"

-- back petals (shorter, darker) then front petals (longer, lit)
for _, a in ipairs({ 90, 210, 330 }) do
  c:part(petal({32,33},{20,28},{20,12},{32,4},{44,12},{44,28}, a), BACK, { gloss = false, cres = 3 })
end
local fronts = {}
for _, a in ipairs({ 30, 150, 270 }) do
  fronts[a] = c:part(petal({32,33},{17,27},{17,9},{32,1},{47,9},{47,27}, a), FRONT, { cres = 4 })
end

-- stitched midrib on each front petal: grey dashes 2 on / 1 off (reads after tint), skips gloss
for a, P in pairs(fronts) do
  local n, seen = 0, {}
  for r10 = 75, 205 do
    local x, y = dir(a, r10 / 10)
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    local k = y * 1000 + x
    if not seen[k] then
      seen[k] = true
      if P.m:has(x, y) then
        if n % 3 < 2 and not c.gl.s[c:key(x, y)] then
          local cur = c:get(x, y)
          c:px(x, y, (cur == FRONT.shade or cur == FRONT.deep or cur == FRONT.bounce) and FRONT.deep or VEIN)
        end
        n = n + 1
      end
    end
  end
end
-- lily freckles: neutral dark grey beans either side of the midrib near the throat (tint darkens them)
for _, a in ipairs({ 30, 150, 270 }) do
  for _, off in ipairs({ -22, 22 }) do
    local x, y = dir(a + off, 9.5)
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    c:px(x, y, FRECK)
  end
  local x, y = dir(a + 14, 13.5)
  c:px(math.floor(x + 0.5), math.floor(y + 0.5), FRECK)
end

-- CENTRE (fixed colours): gold filaments, ember anthers, ember pistil with a gold button
local centre = c:mask()
local GOLD = GV.R.gold
local EMBER = GV.ramp("#f08a24")
local PIST = GV.ramp("#e0501f")
for _, a in ipairs({ 30, 150, 270 }) do
  local x, y = dir(a, 10.5)
  local m = c:line({ { CX + 0.5, CY + 0.5 }, { x, y } }, 2)
  c:part(m, GOLD, { flat = true, contour = false, contact = false })
  centre:add(m)
end
for _, a in ipairs({ 30, 150, 270 }) do
  -- oblong anther lying across the filament tip (as in the SVG's rotated ellipse)
  local x, y = dir(a, 11.5)
  local r = math.rad(a)
  local px, py = math.cos(r) * 2.2, math.sin(r) * 2.2
  local m = c:line({ { x - px, y - py }, { x + px, y + py } }, 4)
  c:part(m, EMBER, { cres = 2, deep = 1, gloss = false })
  centre:add(m)
end
local pm = c:ellipse(31.5, 31.5, 3.5, 3.5)
c:part(pm, PIST, { cres = 3, deep = 1, gloss = false })
centre:add(pm)
c:button(30, 30)

local t = c:save(OUT .. "aseprite/lily-flat.aseprite", OUT .. "png/lily.png")
print("lily " .. GV.report(t))

-- split into tintable petals and fixed centre layers
local full = c:image()
local W, H = full.width, full.height
local pc = app.pixelColor
local petals = Image(W, H, ColorMode.RGB); petals:clear(pc.rgba(0,0,0,0))
local core   = Image(W, H, ColorMode.RGB); core:clear(pc.rgba(0,0,0,0))
local fillUnder = pc.rgba(0xa4, 0xa4, 0xa4, 255) -- petal shade under the centre so no hole shows
for y = 0, H-1 do for x = 0, W-1 do
  local v = full:getPixel(x, y)
  if pc.rgbaA(v) > 0 then
    if centre:has(x, y) then core:putPixel(x, y, v); petals:putPixel(x, y, fillUnder)
    else petals:putPixel(x, y, v) end
  end
end end
local function savePng(img, path)
  local s = Sprite(W, H, ColorMode.RGB); s.cels[1].image = img; s:saveCopyAs(path); s:close()
end
savePng(petals, OUT .. "png/lily-petals.png")
savePng(core, OUT .. "png/lily-centre.png")
local spr = Sprite(W, H, ColorMode.RGB)
spr.layers[1].name = "petals"; spr.cels[1].image = petals
local L2 = spr:newLayer(); L2.name = "centre"
spr:newCel(L2, 1, core, Point(0, 0))
spr:saveAs(OUT .. "aseprite/lily.aseprite"); spr:close()
os.remove(OUT .. "aseprite/lily-flat.aseprite")
print("centre px", centre:count())

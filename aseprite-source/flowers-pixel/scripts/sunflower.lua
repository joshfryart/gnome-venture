-- flowers-pixel/sunflower: tintable flower head (petals neutral grey, centre fixed warm), no halo.
-- Outputs: png/sunflower.png (full), png/sunflower-petals.png, png/sunflower-centre.png, aseprite/sunflower.aseprite (2 layers)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0 }

local CX, CY = 31.5, 31.5
local pi, sin, cos, abs, floor = math.pi, math.sin, math.cos, math.abs, math.floor

-- neutral grey ramps (no hue) so a multiply tint takes any colour
local FRONT = { gloss="#f6f6f6", dot="#fbfbfb", rim="#e9e9e9", base="#d4d4d4", shade="#a6a6a6",
                deep="#7c7c7c", bounce="#b8b8b8", pale=true }
local BACK  = { gloss="#d8d8d8", dot="#e2e2e2", rim="#c4c4c4", base="#adadad", shade="#878787",
                deep="#626262", bounce="#969696", pale=true }

-- pointed petal: along axis at angle a, from r0 to r1, half-width W (sin^0.7 profile, sharp tip)
local function petal(a, r0, r1, W)
  local m = c:mask()
  local ux, uy = sin(a), -cos(a)        -- a=0 points up
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - CX, y - CY
    local t = dx*ux + dy*uy             -- along axis
    local n = -dx*uy + dy*ux            -- across axis
    if t >= r0 and t <= r1 then
      local f = (t - r0) / (r1 - r0)
      local w = W * (sin(pi * (0.18 + 0.82*f)) ^ 0.7)
      if f < 0.25 then w = W end
      if abs(n) <= w then m:set(x, y) end
    end
  end end
  return m
end

local N = 16
local step = 2*pi / N
-- back ring: offset half a step, one part (darker grey shows between front petals)
local back = c:mask()
for i = 0, N-1 do back:add(petal((i + 0.5)*step + 0.06, 10, 26.6, 3.7)) end
local fronts = {}
local all = back:copy()
for i = 0, N-1 do local m = petal(i*step + 0.06, 10, 27.4, 3.3); fronts[i] = m; all:add(m) end
local light = all:closed(3)

c:part(back, BACK, { light = light, gloss = false, cres = 4 })
-- front petals, ordered so the upper-left (lit) petals are painted last (they sit on top)
local order = {}
for i = 0, N-1 do order[#order+1] = i end
table.sort(order, function(p, q)
  local function lit(i) local a = i*step return -(sin(a)*-1 + -cos(a)*-1) end -- dot with (-1,-1)
  return lit(p) > lit(q)
end)
for _, i in ipairs(order) do
  c:part(fronts[i], FRONT, { light = light, gloss = false, cres = 4 })
end

-- stitched midrib on each front petal: 2 on / 1 off, a shade-grey thread that survives the tint
for i = 0, N-1 do
  local a = i*step + 0.06
  local ux, uy = sin(a), -cos(a)
  local n, seen = 0, {}
  for t = 14.5, 23.5, 0.25 do
    local x, y = floor(CX + ux*t + 0.5), floor(CY + uy*t + 0.5)
    local k = x .. "," .. y
    if not seen[k] then
      seen[k] = true
      if fronts[i]:has(x, y) then
        local cur = c:get(x, y)
        if n % 3 < 2 then
          local col = "#a2a2a2"
          if cur == FRONT.shade or cur == FRONT.deep or cur == FRONT.bounce then col = "#d4d4d4" end
          if cur ~= FRONT.gloss and cur ~= FRONT.dot then c:px(x, y, col) end
        end
        n = n + 1
      end
    end
  end
end
-- enamel gloss on the three upper-left petals only
for _, i in ipairs({ 13, 14, 15 }) do
  local a = i*step + 0.06
  local ux, uy = sin(a), -cos(a)
  local gx, gy = CX + ux*19 - uy*1.5, CY + uy*19 + ux*1.5
  c:gloss(fronts[i], FRONT, { floor(gx), floor(gy) })
end

-- CENTRE (fixed colours): soil-brown seed disc with a thread-gold edge stitch, darker seed eye
local disc = c:ellipse(CX, CY, 12.5, 12.5)
local eye  = c:ellipse(CX, CY, 6.5, 6.5)
local DISC = GV.ramp("#7a4a1f")                       -- soil family
local EYE  = GV.ramp("#4e2a16", { gloss = "#9a6b3f", dot = "#c9a96e", rim = "#7a4a1f" })
c:part(disc, DISC, { stitch = true, gloss = { 23, 23 } })
c:part(eye, EYE, { gloss = false, contact = false })
-- seed florets: gold dots on a diamond lattice in the ring, ember-gold in the eye
for y = 0, 63 do for x = 0, 63 do
  local r = math.sqrt((x - CX)^2 + (y - CY)^2)
  local cur = c:get(x, y)
  if r < 5.8 and (x + y) % 2 == 1 and (x - y) % 4 == 1 and cur ~= EYE.gloss then
    c:px(x, y, "#d0862a")
  elseif r > 7.4 and r < 9.3 and (x + y) % 4 == 0 and (x - y) % 4 == 2 then
    if cur == DISC.base or cur == DISC.shade or cur == DISC.rim then
      c:px(x, y, (cur == DISC.shade) and "#b8661a" or "#c9a96e")
    end
  end
end end

-- full image
local full = c:image()
local t = GV.check(full)

-- split by ownership: centre = the disc mask, petals = everything else
local pc = app.pixelColor
local function split(want)
  local img = Image(64, 64, ColorMode.RGB)
  img:clear(pc.rgba(0, 0, 0, 0))
  for y = 0, 63 do for x = 0, 63 do
    local v = full:getPixel(x, y)
    if pc.rgbaA(v) > 0 and (disc:has(x, y) == want) then img:putPixel(x, y, v) end
  end end
  return img
end
local pet, cen = split(false), split(true)

local function savePng(img, path)
  local s = Sprite(64, 64, ColorMode.RGB)
  s.cels[1].image = img
  s:saveCopyAs(path)
  s:close()
end
pcall(function() app.fs.makeAllDirectories(O .. "png") end)
pcall(function() app.fs.makeAllDirectories(O .. "aseprite") end)
savePng(full, O .. "png/sunflower.png")
savePng(pet, O .. "png/sunflower-petals.png")
savePng(cen, O .. "png/sunflower-centre.png")

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"
spr.cels[1].image = pet
local L2 = spr:newLayer()
L2.name = "centre"
spr:newCel(L2, spr.frames[1], cen, Point(0, 0))
spr:saveAs(O .. "aseprite/sunflower.aseprite")
spr:close()

print("full   " .. GV.report(t))
print("petals " .. GV.report(GV.check(pet)))
print("centre " .. GV.report(GV.check(cen)))

-- Flower head "star" (tintable). Petals neutral grey (tinted at runtime), centre + stitches fixed gold/ember.
-- Outputs: star.png (full), star-petals.png, star-centre.png, star.aseprite (layers petals + centre).
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local OUT = ROOT .. "flowers-pixel/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0 }
local CX, CY = 31.5, 33
local floor = math.floor
local function rnd(v) return floor(v + 0.5) end

-- neutral grey ramp (no hue): near-white gloss to mid-grey shade
local GREY = { gloss = "#f2f2f2", dot = "#fafafa", rim = "#e2e2e2", base = "#c9c9c9",
               bounce = "#aeaeae", shade = "#9c9c9c", deep = "#707070", pale = false }

-- petal: ellipse along its axis (as the SVG: centre 14 px out, half length 13.5, half width 7.5),
-- tip slightly rounder-pointed like a felt cut-out
local DIST, L, HW = 14, 13.5, 7.2
local function axis(ang) return math.sin(ang), -math.cos(ang) end
local function petal(ang)
  local m = c:mask()
  local dx, dy = axis(ang)
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x - CX, y - CY
    local a = px * dx + py * dy
    local b = -px * dy + py * dx
    local u = (a - DIST) / L
    if u >= -1 and u <= 1 then
      local w = HW * math.sqrt(1 - u * u)
      if u > 0.55 then w = w * (1 - (u - 0.55) * 0.35) end
      if math.abs(b) <= w then m:set(x, y) end
    end
  end end
  return m
end

local angs = {}
for i = 0, 4 do angs[i + 1] = math.rad(i * 72) end
-- paint order: lower-right petals first, upper-left last (lit petals overlap the shaded ones)
local order = { 3, 2, 4, 5, 1 }
local pm = {}
for _, i in ipairs(order) do
  local a = angs[i]
  local dx, dy = axis(a)
  -- gloss near the tip on the lit (upper-left) side of the petal axis
  local nx, ny = -dy, dx
  if nx + ny > 0 then nx, ny = -nx, -ny end
  local m = petal(a)
  pm[i] = c:part(m, GREY, { gloss = false }).m
  -- enamel gloss streak near the tip on the lit side (SVG highlight ellipse), tapering, with a dot
  local function g(t, o, col)
    local x, y = rnd(CX + dx * t + nx * o - 0.5), rnd(CY + dy * t + ny * o - 0.5)
    local k = c:key(x, y)
    if m:has(x, y) and not c.shd[k] then c:px(x, y, col); c.gl.s[k] = true end
  end
  for t = 16, 22, 0.5 do g(t, 3, GREY.gloss) end
  for t = 17.5, 20.5, 0.5 do g(t, 2.2, GREY.gloss) end
  g(19, 2.2, GREY.dot)
end

-- snapshot of petal colours before fixed-colour pixels go on top
local snap = {}
for k, v in pairs(c.pix) do snap[k] = v end

local fixed = c:mask()
-- midline running stitch on each petal: thread gold 2 on / 1 off (fixed colour group)
for i = 1, 5 do
  local dx, dy = axis(angs[i])
  local n, seen = 0, {}
  for t = 9, 23, 0.25 do
    local x, y = rnd(CX + dx * t - 0.5), rnd(CY + dy * t - 0.5)
    local k = c:key(x, y)
    if not seen[k] and pm[i]:has(x, y) and c.own[k] and c.own[k].m == pm[i] then
      seen[k] = true
      if n % 3 < 2 and not c.gl.s[k] then
        c:px(x, y, c.shd[k] and GV.C.goldS or GV.C.gold)
        fixed:set(x, y)
      end
      n = n + 1
    end
  end
end

-- centre: felt gold button-disc with ember seeds (fixed colours)
local cm = c:ellipse(CX, CY, 6, 6)
c:part(cm, GV.ramp("#f5cf6a", { gloss = "#fff1c8", dot = "#fff8e0", rim = "#fde08a",
  shade = "#e8a317", deep = "#b8661a", bounce = "#d0862a" }), { gloss = false })
fixed:add(cm)
-- ember seed ring (5 seeds between the petals) + glossy highlight
for i = 0, 4 do
  local a = math.rad(i * 72)
  local dx, dy = axis(a)
  local x, y = rnd(CX + dx * 3.2 - 0.5), rnd(CY + dy * 3.2 - 0.5)
  c:px(x, y, (dx + dy > 0) and "#ae2a2a" or "#e0501f")
end
c:px(rnd(CX - 0.5), rnd(CY - 0.5), "#f08a24")
c:paint({ ".g", "gd" }, rnd(CX) - 4, rnd(CY) - 4, { g = "#fff1c8", d = "#fff8e0" })

-- build images
c:finish()
-- clean 1 px outline nubs (pixels with at most one opaque 4-neighbour)
for _ = 1, 2 do
  for y = 0, 63 do for x = 0, 63 do
    local k = c:key(x, y)
    if c.pix[k] and not c.own[k] then
      local n = 0
      for _, d in ipairs({ {1,0},{-1,0},{0,1},{0,-1} }) do if c:get(x + d[1], y + d[2]) then n = n + 1 end end
      if n <= 1 then c.pix[k] = nil end
    end
  end end
end
local pc = app.pixelColor
local function img(sel)
  local im = Image(64, 64, ColorMode.RGB)
  im:clear(pc.rgba(0, 0, 0, 0))
  for y = 0, 63 do for x = 0, 63 do
    local k = c:key(x, y)
    local h = sel(x, y, k)
    if h then
      local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
      im:putPixel(x, y, pc.rgba(r, g, b, 255))
    end
  end end
  return im
end
local full   = img(function(x, y, k) return c.pix[k] end)
local petals = img(function(x, y, k) if fixed.s[k] then return snap[k] end return c.pix[k] end)
local centre = img(function(x, y, k) if fixed.s[k] then return c.pix[k] end end)

for _, d in ipairs({ "png", "aseprite" }) do pcall(function() app.fs.makeAllDirectories(OUT .. d) end) end
local function savePng(im, p)
  local s = Sprite(64, 64, ColorMode.RGB); s.cels[1].image = im; s:saveCopyAs(p); s:close()
end
savePng(full, OUT .. "png/star.png")
savePng(petals, OUT .. "png/star-petals.png")
savePng(centre, OUT .. "png/star-centre.png")

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"
spr.cels[1].image = petals
local lc = spr:newLayer(); lc.name = "centre"
spr:newCel(lc, spr.frames[1], centre, Point(0, 0))
spr:saveAs(OUT .. "aseprite/star.aseprite")
spr:close()

print("full   " .. GV.report(GV.check(full)))
print("petals " .. GV.report(GV.check(petals)))
print("centre " .. GV.report(GV.check(centre)))

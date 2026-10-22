-- flowers/sprig-fern: pinnate fern frond, scalloped near-level pinnae, fiddlehead curl at the tip.
-- No halo (bouquet composite). Stem base (32,96), tip (32,8). Family: moss/forest, hue-shifted ramps.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 96, mode = "sticker", halo = 0, ol = 1, olx = 1, margin = 0, bleed = "b" }

local FRONT = GV.ramp("#3a8a4a")   -- forest fern, right (front) pinnae
local BACK  = GV.ramp("#2c6e44")   -- deeper fern, left (back) pinnae
local RACH  = GV.ramp("#2f5e34")   -- rachis
local STIPE = GV.ramp("#6a6230")   -- olive-brown stipe (soil/moss borrow)
local CURL  = GV.ramp("#5e9e3e")   -- young fiddlehead

local function sx(y) return 32 + math.floor(math.sin((y - 16) / 64 * math.pi) * 1.2 + 0.5) end

-- a pinna: chain of shrinking discs from the rachis outward, rising at angle a
local function pinna(y, side, L, a)
  local x0 = sx(y) + side
  local dx, dy = math.cos(a) * side, -math.sin(a)
  local m = c:mask()
  local n = math.max(2, math.floor(L / 3.2))
  for k = 0, n do
    local t = k / n
    local r = 2.3 - 1.1 * t
    if L < 10 then r = r - 0.5 end
    m:add(c:ellipse(x0 + dx * L * t, y + dy * L * t - 0.1 * L * t * t, r, r * 0.9))
  end
  return m, { x0 = x0, y = y, dx = dx, dy = dy, L = L }
end

local parts, ribs = {}, {}
local function frondLen(y) return math.max(5, 23 * math.sin(math.pi * (86 - y) / 72) ^ 0.7) end
local back, front = {}, {}
for y = 76, 22, -9 do back[#back + 1] = y end
for y = 71, 20, -9 do front[#front + 1] = y end
for _, y in ipairs(back) do
  local L = frondLen(y) * 0.92
  local a = math.rad(18 + (76 - y) * 0.45)
  local m, d = pinna(y, -1, L, a)
  parts[#parts + 1] = { "b" .. y, m, BACK, { cres = 2, deep = 1, gloss = false, contact = false } }
  if L >= 12 then ribs[#ribs + 1] = { d, BACK.deep } end
end
for _, y in ipairs(front) do
  local L = frondLen(y)
  local a = math.rad(18 + (71 - y) * 0.45)
  local m, d = pinna(y, 1, L, a)
  parts[#parts + 1] = { "f" .. y, m, FRONT, { cres = 2, deep = 1, gloss = false, contact = false } }
  if L >= 12 then ribs[#ribs + 1] = { d, FRONT.shade } end
end

-- rachis (thin, green) and stipe (thicker, olive-brown) down to the base
local rpts = {}
for y = 80, 17, -3 do rpts[#rpts + 1] = { sx(y), y } end
parts[#parts + 1] = { "rachis", c:line(rpts, 2), RACH, { flat = true } }
parts[#parts + 1] = { "stipe", c:line({ { 32, 96 }, { 32, 88 }, { sx(80), 79 } }, 3), STIPE, { flat = true } }

-- fiddlehead: a curled disc at the very tip (top pixel y = 8)
local coil = c:ellipse(32.5, 12.5, 4, 4)
parts[#parts + 1] = { "curl", coil, CURL, { cres = 2, deep = 1, gloss = { 31, 10 } } }
c:build(parts)

-- midribs on the bigger pinnae
for _, r in ipairs(ribs) do
  local d, col = r[1], r[2]
  for s = 2, math.floor(d.L * 0.72) do
    local t = s / d.L
    c:px(math.floor(d.x0 + d.dx * s + 0.5), math.floor(d.y + d.dy * s - 0.1 * d.L * t * t + 0.5), col)
  end
end

-- spiral groove inside the fiddlehead
c:paint({
  ".dd.",
  "d..d",
  "d.d.",
  ".d..",
}, 31, 11, { d = CURL.deep })

-- tiny gold stitch binding the stipe
c:seam({ { 32, 85 }, { 32, 92 } }, { free = true })

local t = c:save(O .. "aseprite/sprig-fern.aseprite", O .. "png/sprig-fern.png")
print(GV.report(t))

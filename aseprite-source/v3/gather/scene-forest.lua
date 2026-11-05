-- gather scene-forest, Hearth Pop v3 PILOT. 480x270 native (scale 1). Single pass.
-- Satchel back comes from satchel.lua (shared by every scene); satchel-front.png overlays it.
-- Quirk: a hollow in the log with two gold eyes watching.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local NAME = app.params.name or "scene-forest"
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = NAME }
local INK = P.ink
local floor, sin, cos, abs, min, max = math.floor, math.sin, math.cos, math.abs, math.min, math.max
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, h) c:fillMask(m, h) return m end
local function px(x, y, h) c:px(x, y, h) end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function rim(m, h) return c:rim(m, h or INK) end

local LEAF1 = { hi = "#b4dc6e", base = "#5fae52", shade = "#3f8a4a", deep = "#24544a" }
local LEAF2 = { hi = "#8fcf6a", base = "#46955a", shade = "#2f6e52", deep = "#1f4a46" }
local BARK = { hi = "#a8704a", base = "#7a4a34", shade = "#5a3430", deep = "#3a2229" }
local CAP = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }

-- shape then ramp lighting: base, lit upper-left edge, shade lower-right edge, optional deep underside
local function form(m, Rm, o)
  o = o or {}
  fm(m, Rm.base)
  local lt, sh, dp = {}, {}, {}
  m:each(function(x, y)
    if not m:has(x - 2, y - 2) then lt[#lt + 1] = { x, y } end
    if not m:has(x + 2, y + 2) then sh[#sh + 1] = { x, y } end
    if o.deep and not m:has(x, y + 1) then dp[#dp + 1] = { x, y } end
  end)
  for _, p in ipairs(lt) do px(p[1], p[2], Rm.hi) end
  for _, p in ipairs(sh) do px(p[1], p[2], Rm.shade) end
  for _, p in ipairs(dp) do px(p[1], p[2], Rm.deep) end
  return m
end

---------------------------------------------------------------- far: hazy light, far trunks, shafts
c:stripes(0, 150, { "#e8f2b0", "#d4e8a0", "#bfdc92", "#a9d086", "#94c47c" }, { 2, 3, 3, 3, 3 })
for i = 0, 6 do   -- light shafts
  local x = 40 + i * 62
  c:fillMask(c:poly{ { x, 0 }, { x + 22, 0 }, { x + 70, 150 }, { x + 36, 150 } }:clip(R(0, 0, 479, 150)), "#f0f7c0")
end
for _, t in ipairs{ { 28, 22 }, { 150, 16 }, { 250, 20 }, { 340, 14 }, { 420, 18 } } do   -- far trunks, desaturated
  fm(R(t[1], 30, t[1] + t[2] - 1, 150), "#8fb083")
  fm(R(t[1] + t[2] - 5, 30, t[1] + t[2] - 1, 150), "#7da077")
end
c:terrain(function(x) return 128 + floor(5 * sin(x / 31)) end, "#86bd6c", 160, 0, 479)
c:terrain(function(x) return 140 + floor(4 * sin(x / 23 + 2)) end, P.moss.base, 270, 0, 479)
c:terrain(function(x) return 214 + floor(5 * sin(x / 37 + 1)) end, P.moss.shade, 270, 0, 479)
c:terrain(function(x) return 246 + floor(3 * sin(x / 19)) end, "#2f7a4c", 270, 0, 479)
for i = 0, 340 do   -- grass flecks
  local x, y = hash(i, 7) % 480, 146 + hash(i, 11) % 120
  px(x, y, y > 214 and "#52a156" or "#8fd06a"); px(x, y - 1, y > 214 and "#52a156" or "#8fd06a")
end

---------------------------------------------------------------- canopy (ink rim, near plane)
local blobs = { { 30, 18, 44, 26, LEAF2 }, { 96, 8, 36, 22, LEAF1 }, { 150, 22, 40, 26, LEAF2 }, { 208, 10, 38, 22, LEAF1 }, { 268, 20, 42, 24, LEAF2 },
  { 330, 8, 40, 22, LEAF1 }, { 386, 22, 44, 26, LEAF2 }, { 446, 10, 40, 24, LEAF1 }, { 8, 40, 28, 16, LEAF1 }, { 232, 40, 26, 14, LEAF1 }, { 360, 44, 26, 14, LEAF1 } }
for _, b in ipairs(blobs) do rim(E(b[1], b[2], b[3], b[4]), INK) end
for _, b in ipairs(blobs) do
  local m = E(b[1], b[2], b[3], b[4]); form(m, b[5], { deep = true })
  for k = 1, 3 do   -- leaf vein glints
    local vx, vy = b[1] - b[3] + 8 + (k * 17 + b[1]) % (b[3] * 2 - 14), b[2] - 2 + (k * 5) % 7
    if m:has(vx, vy) and m:has(vx + 4, vy + 2) then px(vx, vy, b[5].hi); px(vx + 1, vy, b[5].hi); px(vx + 2, vy + 1, b[5].shade) end
  end
end

---------------------------------------------------------------- trunks (left and right, ink rim)
local function trunk(x0, x1, y0, y1)
  local m = R(x0, y0, x1, y1)
  local w = x1 - x0
  local flare = c:poly{ { x0 - 8, y1 + 8 }, { x0 + 2, y1 - 12 }, { x1 - 2, y1 - 12 }, { x1 + 8, y1 + 8 } }
  m = m:copy():add(flare)
  rim(m, INK)
  fm(m, BARK.base)
  fm(R(x0, y0, x0 + floor(w * 0.22), y1 - 10), BARK.hi)
  fm(R(x0 + floor(w * 0.22) + 1, y0, x0 + floor(w * 0.3), y1 - 10), "#8f5a3c")
  fm(R(x1 - floor(w * 0.34), y0, x1, y1 - 10), BARK.shade)
  fm(R(x1 - floor(w * 0.12), y0, x1, y1 - 10), BARK.deep)
  fm(flare:copy():clip(R(x0 - 8, y1 - 12, x1 + 8, y1 + 8)), BARK.shade)
  for y = y0 + 6, y1 - 4, 11 do   -- bark dashes
    local x = x0 + 5 + (hash(y, x0) % max(1, x1 - x0 - 12)); fm(R(x, y, x + 1, y + 5), BARK.deep)
  end
  return m
end
trunk(76, 112, 14, 140)
trunk(166, 178, 26, 122)   -- slim mid trunk
trunk(440, 479, 0, 166)

---------------------------------------------------------------- mossy log with hollow (left)
local log = R(10, 138, 142, 190):copy():add(E(10, 164, 2, 26))
rim(log, INK); form(log, { hi = "#c08550", base = "#9a6038", shade = "#6e3f2a", deep = "#43261f" }, { deep = true })
for y = 150, 184, 8 do fm(R(24 + hash(y, 3) % 40, y, 40 + hash(y, 5) % 70, y), "#5a3430") end   -- grain
local moss = R(12, 132, 140, 144):copy():add(E(76, 138, 66, 8))
fm(moss, P.moss.base); for x = 14, 138, 3 do px(x, 145 + hash(x, 1) % 5, P.moss.base); px(x, 138, P.moss.hi) end
for x = 14, 138, 7 do px(x, 134 + hash(x, 9) % 3, P.moss.hi) end
local ring = E(142, 164, 14, 28)   -- log end, hollow, eyes
rim(ring, INK); form(ring, { hi = "#e8b982", base = "#c08550", shade = "#9a6038", deep = "#6e3f2a" })
fm(E(143, 166, 8, 18), "#d19a62"); fm(E(143, 168, 6, 14), "#241418")
fm(R(139, 163, 140, 164), "#ffe38a"); fm(R(146, 163, 147, 164), "#ffe38a")   -- two gold eyes
local function shroom(x, y, s)   -- x,y = base of stem
  fm(R(x - 1, y - 7 * s, x + 1, y), P.cream); px(x + 1, y - 3 * s, "#e4d0aa")
  local cap = E(x, y - 8 * s, 4 * s + 2, 3 * s + 1); rim(cap, INK); form(cap, CAP)
  px(x - 2, y - 9 * s, P.cream); px(x + 2, y - 8 * s, P.cream); px(x, y - 10 * s, P.cream)
end
shroom(40, 134, 2); shroom(64, 134, 1); shroom(112, 132, 1)
fm(E(78, 190, 10, 3), "#2a6a45")   -- log contact shadow

---------------------------------------------------------------- fairy ring (centre)
local fr = E(240, 214, 52, 14)
fm(fr, "#8cd08a"); fm(E(240, 214, 44, 10), "#a8dc9a")
for a = 0, 17 do
  local t = a / 18 * 6.2832; local x, y = 240 + floor(52 * cos(t)), 214 + floor(14 * sin(t))
  fm(R(x, y - 5, x, y), P.cream); rim(E(x, y - 6, 3, 2), INK); fm(E(x, y - 6, 3, 2), P.cream); px(x + 1, y - 6, "#e4d0aa")
end

---------------------------------------------------------------- acorns, ferns, leaf scatter
local function acorn(x, y)
  local nut = E(x, y + 3, 4, 5); rim(nut, INK); form(nut, { hi = "#d19a62", base = "#b97a4a", shade = "#864c33", deep = "#51302b" })
  local cp = E(x, y - 1, 5, 3); rim(cp, INK); form(cp, { hi = "#a8704a", base = "#7a4a34", shade = "#5a3430", deep = "#3a2229" })
  fm(R(x, y - 5, x, y - 4), INK)
end
for _, a in ipairs{ { 172, 196 }, { 184, 206 }, { 62, 222 }, { 130, 244 }, { 250, 252 }, { 440, 224 }, { 326, 240 } } do acorn(a[1], a[2]) end
local function fern(x, y, dir)
  for i = 0, 6 do
    local ang = (-80 + i * 24) * dir
    local len = 30 - abs(i - 3) * 3
    local ex, ey = x + floor(len * sin(ang / 57.3)) , y - floor(len * cos(ang / 57.3))
    local mx, my = (x + ex) // 2 + dir * -3, (y + ey) // 2 - 4
    local fr = c:poly{ { x, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 4 } }
    rim(fr, INK); fm(fr, i % 2 == 0 and LEAF1.base or LEAF2.base)
    px(mx, my, LEAF1.hi); px(mx + 1, my + 1, LEAF1.hi)
  end
end
fern(20, 264, 1); fern(444, 218, -1); fern(300, 266, -1)
for i = 0, 70 do   -- fallen leaves
  local x, y = hash(i, 31) % 480, 150 + hash(i, 37) % 120
  local col = ({ "#f5b82e", "#e8883a", "#d98322", "#c94f3a" })[1 + i % 4]
  px(x, y, col); px(x + 1, y, col); px(x, y + 1, "#8f4a1f")
end

---------------------------------------------------------------- satchel back (shared)
dofile(d .. "/satchel.lua").back(c)

c:save{ aseprite = d .. "/out/" .. NAME .. ".aseprite", png = d .. "/out/" .. NAME .. ".png", scale = 1 }

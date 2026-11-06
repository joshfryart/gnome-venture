-- echo-stone (final, Opus single pass). A slim upright river stone, gently leaning, with ripple rings carved
-- into its face that glow sea-teal, as if a sound is still ringing inside.
-- Material: per-pixel egg light (6-tone blue-grey stone), mineral speckle grain, a pale quartz vein,
-- carved grooves (dark cut + lit lip) with a glowing teal inlay, cool bounce, 2-tone ground shadow.
-- quirk: a tiny tuft of moss with one bent sprig grows on its shoulder.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, atan = math.floor, math.max, math.min, math.sqrt, math.abs, math.atan
local NAME = "echo-stone"
local c = A.new(NAME)
local ST = { "#272a45", "#3f4566", "#5f6789", "#838cab", "#aab2c9", "#d6dbe8" }
local GL = { "#1b4a5c", "#2a8a9a", "#5fd0cc", "#b8fff0" }
local tok = { r = { name = "stone" } }

c:groundShadow(32, 56, 13, 2)
local CX, CY = 32, 33
local m, n = A.oval(CX, CY, 11, 19, 0.12, 0.8)
-- flatten the base a little so it stands
m:each(function(x, y) if y > 52 then m.s[K(x, y)] = nil end end)
local bias = {}
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local idx = X.tone(c, m, v, ST, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.83 }, bias = bias, tok = tok })
-- mineral grain: sparse light and dark specks
m:each(function(x, y) local h = X.hash(x, y, 7)
  if h < 0.06 then A.step(c, idx, ST, x, y, -1, tok) elseif h > 0.96 then A.step(c, idx, ST, x, y, 1, tok) end end)
-- quartz vein: a thin pale band crossing the lower body
for x = CX - 12, CX + 12 do
  local y = floor(44 + (x - CX) * -0.28 + ((x % 5 == 0) and 1 or 0) + .5)
  if m:has(x, y) and m:has(x, y - 1) and m:has(x, y + 1) then
    c:put(x, y, (idx[K(x, y)] or 3) >= 4 and "#ece8e0" or "#b8b4bc", tok)
  end
end
-- ripple rings: carved grooves glowing teal, centre a little above middle
local RX, RY = 31, 29
local inner = m:shrink(1)
local rings = { { 2.0, 0 }, { 4.6, 1 }, { 7.2, 2 } }
m:each(function(x, y)
  local dx, dy = x - RX, (y - RY) / 1.15
  local d = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  for i, r in ipairs(rings) do
    local gap = (i == 2 and a > 0.4 and a < 1.1) or (i == 3 and (a > -2.6 and a < -1.7 or a > 1.6 and a < 2.4))
    if not gap and abs(d - r[1]) < 0.55 and inner:has(x, y) then
      c:put(x, y, i == 1 and GL[4] or (dx + dy < 0 and GL[3] or GL[2]), tok)
    elseif not gap and d - r[1] >= 0.55 and d - r[1] < 1.45 and i > 1 and inner:has(x, y) then
      -- dark cut on the outer edge of each groove
      c:put(x, y, (dx + dy < 0) and ST[3] or ST[2], tok)
    end
  end
  if d < 1.2 then c:put(x, y, "#e8fff8", tok) end
end)
c:put(RX - 1, RY - 1, GL[3], tok)
-- cool bounce light on the lower-right edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.6 and y < 51 and y > 26 and x > CX then c:put(x, y, "#6f7fb0", tok) end end)
-- base sits dark where it meets the ground
m:each(function(x, y) if y >= 51 then A.step(c, idx, ST, x, y, -2, tok) end end)
-- glint on the upper-left shoulder
local gx, gy = A.specAt(m, n, 30)
c:put(gx, gy, "#f4f2ec", tok) c:put(gx + 1, gy, ST[6], tok)
-- quirk: moss tuft on the right shoulder with one bent sprig
local mo = {
  "......k.",
  ".....k..",
  "..g.lk..",
  ".gllmld.",
  "gmmmddd.",
}
local MC = { l = "#9dd06c", m = "#5fa850", g = "#c4e07a", d = "#2e6a44", k = "#3f9150" }
for yy, row in ipairs(mo) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if MC[ch] then c:put(35 + xx, 12 + yy, MC[ch]) end end end
A.save(c, NAME)

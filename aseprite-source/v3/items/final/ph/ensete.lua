-- ensete (lean P1pilot)
local NAME = "ensete"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local LEAF = { "#123a30", "#1c5a3a", "#2c7e44", "#4aa04c", "#7cc462", "#b8e68a" }
local SH = { "#5a3a44", "#8a5658", "#b87a68", "#d8a888", "#f0cfa8", "#fff0d4" }
local RED = "#c43a46"
c:groundShadow(32, 58, 14, 3)
-- paddle leaf with red midrib, ragged tears
local function paddle(ax, ay, cx, cy, bx, by, w, nm, tear)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, w * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.55)
  end, { fold = 0.4 })
  local tok = { r = { name = nm } }
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = {0.18,0.34,0.5,0.66,0.82}, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.1 and t < 0.97 then c:put(x, y, RED, tok) return end
    local d = (t * L) % 3
    if d < 1 and abs(s) > 0.2 and t > 0.1 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], tok) end
  end)
  if tear then for _, p in ipairs(tear) do if m:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], tok) end end end
  return m
end
paddle(31, 26, 10, 20, 6, 4, 6.5, "lL", { {10,13},{9,14} })
paddle(33, 26, 52, 14, 58, 10, 6, "lR")
paddle(32, 24, 30, 8, 36, 2, 3.4, "lC")
-- pseudostem: bulbous swollen base made of wrapped sheaths
local st = HP.mask()
for y = 22, 57 do local t = (y - 22) / 35
  local h = (t < 0.5) and (3.6 + 6 * t) or (6.6 + 5.6 * ((t - 0.5) / 0.5) ^ 1.4)
  if y > 54 then h = h - (y - 54) * 1.5 end
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do st:set(x, y) end end
G.toneN(c, st, X.pillow(st, 11), SH, { tok = { r = { name = "stem" } }, cuts = {0.16,0.32,0.5,0.68,0.84}, amb = 0.08, wrap = 0.2 })
-- overlapping sheath bands, curved
st:each(function(x, y) local yy = y - 0.03 * (x - 32) ^ 2
  if floor(yy) % 6 == 0 then c:put(x, y, SH[2], { r = { name = "band" } })
  elseif floor(yy) % 6 == 1 and abs(x - 32) < 8 then c:put(x, y, SH[1], { r = { name = "band" } }) end
  if (x - 32) % 5 == 0 and y > 30 and X.hash(x, y, 2) > 0.5 then c:put(x, y, SH[3], { r = { name = "band" } }) end end)
-- dark purple-brown streaks (ensete bloom stain)
for _, p in ipairs{ {36,30},{36,31},{37,38},{37,39},{26,34},{26,35},{27,44},{35,47} } do if st:has(p[1], p[2]) then c:put(p[1], p[2], "#6a3446", { r = { name = "band" } }) end end
-- sheath cuff where leaves emerge
for x = 27, 37 do c:put(x, 22, SH[1], { r = { name = "band" } }) end
-- spec
for _, p in ipairs{ {25,40},{25,41},{26,36} } do c:put(p[1], p[2], SH[6], { r = { name = "band" } }) end
-- tiny roots/ground tufts
for _, p in ipairs{ {18,57},{19,57},{46,57},{45,57},{22,58},{42,58} } do c:put(p[1], p[2], "#5a3a22", { r = { name = "soil" } }) end
G.save(c, NAME)

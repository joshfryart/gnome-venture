-- avocado (final, Opus aR3_1, single pass). A slim, tilted pear-shaped half: pebbly near-black Hass skin seen as a
-- rim (1 px on the lit upper-left, 3 px on the lower-right where the cut face tilts away), buttery flesh that grades
-- from green at the skin to pale yellow in the middle, faint vascular fibres running from the neck, and a glossy
-- brown stone proud in its cup (shadowed cavity wall upper-left, cast shadow lower-right, papery coat lines, one
-- specular, cool bounce). Short woody stem nub at the neck.
-- quirk: a single small leaf still clings to the stem nub.
local NAME = "avocado"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local SKIN  = { "#111915", "#19251c", "#223323", "#2d442a", "#3d5832", "#56723f" }
local FLESH = { "#3a6e2c", "#5f9636", "#8fbd44", "#bfd85e", "#e0ea86", "#f4f1b0" }
local STONE = { "#381c1a", "#58301f", "#7c4528", "#a16136", "#c6874f", "#e9bb84" }
local WOOD  = { "#3e2622", "#5e3a2a", "#86573a", "#b08050" }
local LEAF  = { "#173a2e", "#21553a", "#2f7244", "#46904a", "#6aae56", "#98ca6a" }
local SPEC, BOUNCE, SBOUNCE = "#fff4d6", "#4d6e6a", "#8a6f86"

-- outline of the half: pear along a tilted axis (neck circle + bulb circle + concave bridge)
local AX, AY, BX, BY = 25, 14, 38, 54
local len = sqrt((BX - AX) ^ 2 + (BY - AY) ^ 2)
local ux, uy = (BX - AX) / len, (BY - AY) / len
local NR, BR = 6.4, 12.2
local nc, bc = NR + 0.4, len - BR - 0.4
local m = X.cyl(AX, AY, BX, BY, function(t)
  local tl = t * len
  local w = 0
  local a = NR * NR - (tl - nc) ^ 2 if a > 0 then w = max(w, sqrt(a)) end
  local b = BR * BR - (tl - bc) ^ 2 if b > 0 then w = max(w, sqrt(b)) end
  if tl > nc and tl < bc then local u = (tl - nc) / (bc - nc) w = max(w, NR + (BR - NR) * u ^ 1.35) end
  return w > 0.4 and w or -1
end)

-- flesh = inset face, shifted toward the light so the rim is thick lower-right
local flesh = m:shrink(3):shift(-1, -1):clip(m:shrink(1))
local skin = m:copy():cut(flesh)

-- skin: pillow light + pebbles
local n = X.pillow(m, 4)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local stok = { r = { name = "skin" } }
local sidx = X.tone(c, skin, v, SKIN, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, tok = stok })
skin:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.74 then c:put(x, y, SKIN[min(6, sidx[k] + 1)], stok) elseif h < 0.12 then c:put(x, y, SKIN[max(1, sidx[k] - 1)], stok) end
end)
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and skin:has(x, y) and X.hash(x, y, 3) > 0.25 then c:put(x, y, BOUNCE, stok) end end)

-- stone position: bulb centre, nudged toward the neck
local SX, SY = AX + ux * (bc - 1.2), AY + uy * (bc - 1.2)
local SR = 6.6
local stone = c:ellipse(SX, SY, SR, SR)

-- flesh: tone by distance from the skin; pale halo round the cup; fibres; flat-face falloff lower-right
local fd = X.dist(flesh)
local fn = X.pillow(flesh, 2.5)
local fv = X.light(fn, { amb = 0.35, wrap = 0.4 })
local ftok = { r = { name = "flesh" } }
flesh:each(function(x, y) local k = K(x, y)
  local d = fd[k]
  local i = d < 0.6 and 2 or d < 1.6 and 3 or d < 3.0 and 4 or 5
  local ds = sqrt((x - SX) ^ 2 + (y - SY) ^ 2)
  if ds < SR + 3.2 and d >= 1.6 then i = 6 end
  if fv[k] < 0.55 and d < 3 then i = i - 1 end
  -- vascular fibres: two faint dashed strands from the neck curving round the cup
  local rx, ry = x - AX, y - AY
  local t = (rx * ux + ry * uy) / len
  local s = rx * -uy + ry * ux
  for _, off in ipairs{ -3.2, 3.6 } do
    local want = off * (0.6 + 0.9 * sin(min(1, t / 0.62) * pi / 2))
    if t > 0.14 and t < 0.6 and abs(s - want) < 0.5 and X.hash(x, y, 5) > 0.3 and d >= 1.6 then i = i - 1 end
  end
  c:put(x, y, FLESH[max(1, min(6, i))], ftok)
end)
-- cup: shadowed wall upper-left, cast shadow lower-right
stone:grow(1):cut(stone):each(function(x, y) if flesh:has(x, y) then
  local dx, dy = x - SX, y - SY
  c:put(x, y, (dx + dy < -1) and FLESH[4] or FLESH[3], ftok) end end)
stone:shift(1, 2):cut(stone):each(function(x, y) if flesh:has(x, y) and (x - SX) + (y - SY) > 2 then c:put(x, y, FLESH[3], ftok) end end)
stone:shift(1, 1):cut(stone):each(function(x, y) if flesh:has(x, y) and (x - SX) + (y - SY) > 2 then c:put(x, y, FLESH[2], ftok) end end)

-- stone: glossy sphere, papery coat lines, spec, bounce
local sn = X.sphere(SX - 0.3, SY - 0.3, SR, stone)
local sv = X.light(sn, { amb = 0.05, wrap = 0.15 })
local ttok = { r = { name = "stone" } }
local tidx = X.tone(c, stone, sv, STONE, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, tok = ttok })
-- coat: two thin meridian lines in a darker tone
stone:each(function(x, y) local k = K(x, y)
  local dx, dy = x - SX, y - SY
  local a = dx * 0.8 - dy * 0.6
  if (abs(a - 1.5 - 0.08 * dy * dy) < 0.5 or abs(a + 3.4 + 0.05 * dy * dy) < 0.5) and tidx[k] > 2 and X.hash(x, y, 9) > 0.35 then
    c:put(x, y, STONE[tidx[k] - 1], ttok) end
end)
local srim = X.rim(sn)
stone:edge():each(function(x, y) if srim[K(x, y)] > 0.75 then c:put(x, y, SBOUNCE, ttok) end end)
local px, py = floor(SX - 3), floor(SY - 3)
c:put(px, py, SPEC, ttok) c:put(px + 1, py, SPEC, ttok) c:put(px, py + 1, STONE[6], ttok)

-- stem nub (woody) out of the neck, then the leaf (quirk)
local wm, wn = G.tube({ { AX - 0.2, AY - 1 }, { AX - 0.8, AY - 3 }, { AX - 1.5, AY - 4.5 }, { AX - 2.2, AY - 6 } }, function(t) return 1.35 - 0.3 * t end)
wm:cut(m)
local wtok = { r = { name = "stem" } }
X.tone(c, wm, X.light(wn, { amb = 0.15, wrap = 0.3 }), WOOD, { cuts = { 0.3, 0.55, 0.8 }, tok = wtok })
c:put(floor(AX - 2.2 + .5), floor(AY - 6.4 + .5), WOOD[4], wtok)
-- AO where the stem enters the skin
for _, q in ipairs{ { AX - 1, AY - 1 }, { AX, AY - 1 } } do if m:has(q[1], q[2] + 1) then c:put(q[1], q[2] + 1, SKIN[1], stok) end end

local lm, ln, LT, LS = G.blade(AX - 2.6, AY - 5.4, AX - 6, AY - 9.5, AX - 12.5, AY - 8.2, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 2.6 * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.75)
end, { fold = 0.35 })
lm:cut(wm)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.16 and LT[k] > 0.08 and LT[k] < 0.86 then c:put(x, y, LS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
end)

G.save2(c, NAME)

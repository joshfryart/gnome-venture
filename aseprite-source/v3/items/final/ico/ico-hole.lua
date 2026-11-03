-- ico-hole (final pass, Opus). A burrow: a low earth mound with an arched opening on its front, seen from slightly
-- above. Soil: per-pixel dome light on a 6-tone loam ramp with pebbles (bevel + glint) and a pale root strand; a lit
-- earth lip around the arch; inside, a deep shaft that falls to near-ink at the back with the inner wall catching a
-- little light on the right. Grass tufts (3 px blades, 5 tones) sit on the crown. quirk: a pink earthworm curls out
-- of the soil beside the entrance.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("ico-hole")
local SOIL = { "#3a2026", "#5a3228", "#7a4a30", "#9c6638", "#c08a50", "#e2b478" }
local PIT  = { "#1e1218", "#2a1a20", "#3c2628", "#56362e" }
local GR   = { "#173f36", "#21593f", "#2e7a46", "#4fa24e", "#86cc5e" }
local STN  = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local WORM = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local CR = A.CREAM
local soT, piT, grT, stT, wmT = A.tok("soil"), A.tok("pit"), A.tok("grass"), A.tok("stone"), A.tok("worm")

c:groundShadow(32, 50, 25, 2)
-- mound: wide low dome with a flat base
local mound = A.ell(32, 46, 25, 21):cut(c:rect(0, 50, 63, 63))
mound:clip(A.ell(32, 47, 26, 21))
local mn = A.dome(mound, 9, 1.0, 2)
local sbias = {}
mound:each(function(x, y) if y >= 48 then sbias[K(x, y)] = -1 end end)
local sidx = A.shade(c, mound, mn, SOIL, { tok = soT, bias = sbias, amb = 0.04, wrap = 0.25, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tilt = { 30, 34, 24, 0.22 } })
-- soil crumbs: a few darker clods and paler grains (fixed pattern)
mound:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h < 0.06 then A.step(c, sidx, SOIL, x, y, -1, soT)
  elseif h > 0.965 then A.step(c, sidx, SOIL, x, y, 1, soT) end
end)
-- root strand across the left flank
for _, p in ipairs({ { 12, 40 }, { 13, 40 }, { 14, 41 }, { 15, 41 }, { 16, 41 }, { 17, 42 }, { 18, 42 } }) do
  c:put(p[1], p[2], "#e8c890", soT) c:put(p[1], p[2] + 1, SOIL[2], soT)
end

-- opening: arch (ellipse top, flat floor)
local OX, OY = 33, 41
local hole = A.ell(OX, OY, 11, 9):cut(c:rect(0, 47, 63, 63))
-- lit lip ring around the top of the arch, deep shadow ring just inside the lip
local lip = hole:grow(2):cut(hole):clip(mound)
lip:each(function(x, y)
  local d = A.ell(OX, OY, 12, 10):has(x, y)
  local up = y < OY + 2
  if up then c:put(x, y, d and SOIL[6] or SOIL[5], soT) else c:put(x, y, SOIL[4], soT) end
end)
-- lip shade on its lower-right portion
lip:each(function(x, y) if x > OX + 5 and y > OY - 5 and y < OY + 3 then c:put(x, y, SOIL[4], soT) end end)
-- shaft: tones by depth (top of arch = darkest shadow from the overhang, back wall dark, right inner wall lit)
hole:each(function(x, y)
  local dx, dy = (x - OX) / 11, (y - OY) / 9
  local rr = sqrt(dx * dx + dy * dy)
  local t = 1
  if rr > 0.62 then t = dx > 0.1 and 3 or 2 end
  if rr > 0.86 and dx > 0.35 and dy > -0.45 then t = 4 end
  if dy > 0.62 then t = abs(dx) < 0.5 and 3 or 2 end
  if dy < -0.5 then t = 1 end
  c:put(x, y, PIT[t], piT)
end)
-- top of the arch: 1 row of deep ink-violet shadow under the lip
hole:each(function(x, y) if not hole:has(x, y - 1) then c:put(x, y, PIT[1], piT) end end)
-- worn floor: lighter scuffed earth spilling out at the threshold
for x = OX - 9, OX + 9 do
  if hole:has(x, 46) then c:put(x, 46, abs(x - OX) < 6 and SOIL[3] or SOIL[2], soT) end
  if hole:has(x, 45) and abs(x - OX) < 4 then c:put(x, 45, PIT[4], piT) end
end
-- spoil heap: a small mound of dug earth at the right of the entrance
local spoil = A.ell(49, 47, 5, 3):cut(c:rect(0, 50, 63, 63))
local spn = A.dome(spoil, 3, 1, 1)
A.shade(c, spoil, spn, SOIL, { tok = A.tok("spoil"), amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
spoil:each(function(x, y) if not spoil:has(x, y - 1) and mound:has(x, y - 1) then c:put(x, y, SOIL[2], soT) end end)

-- pebbles: bevelled stones half sunk in the soil
local function pebble(cx, cy, rx, ry)
  local m = A.ell(cx, cy, rx, ry)
  local n = X.pillow(m, 1.5)
  local idx = A.shade(c, m, n, STN, { tok = stT, amb = 0.1, wrap = 0.2, cuts = { 0.3, 0.55, 0.8 } })
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y + 1, SOIL[1], soT) end end)
  return m
end
pebble(16, 46, 2, 1.2)
pebble(46, 33, 1.5, 1)
pebble(22, 30, 1.2, 1)
c:put(15, 45, STN[4], stT)

-- grass tufts on the crown: 3 px wide blades, lit left
local function blade(x0, y0, h, lean)
  for i = 0, h - 1 do
    local f = i / max(1, h - 1)
    local x = floor(x0 + lean * f * f + .5)
    local y = y0 - i
    local w = f < 0.5 and 3 or (f < 0.85 and 2 or 1)
    for dx = 0, w - 1 do
      local t = dx == 0 and 5 or (dx == w - 1 and (w == 1 and 4 or 2) or 3)
      if i == 0 then t = 1 end
      if f > 0.7 and dx == 0 then t = 5 end
      c:put(x + dx, y, GR[t], grT)
    end
  end
end
local function tuft(x, y, s)
  blade(x - 3, y, 5 * s, -2.5)
  blade(x + 1, y, 6 * s, 2)
  blade(x - 1, y, 8 * s, 0.6)
end
tuft(23, 28, 1.25)
tuft(42, 29, 1.0)
tuft(11, 40, 0.75)
-- contact: soil darkens under each tuft root
for _, p in ipairs({ { 21, 29 }, { 22, 29 }, { 25, 29 }, { 26, 29 }, { 38, 29 }, { 39, 29 }, { 42, 29 }, { 43, 29 } }) do
  if mound:has(p[1], p[2]) then c:put(p[1], p[2], SOIL[2], soT) end
end

-- quirk: earthworm curling out of the soil left of the entrance
local worm = { { 18, 46, 1 }, { 18, 45, 1 }, { 18, 44, 2 }, { 18, 43, 2 }, { 19, 42, 3 }, { 20, 41, 3 }, { 21, 41, 3 }, { 22, 42, 2 } }
for i, p in ipairs(worm) do
  c:put(p[1], p[2], WORM[p[3] + 1], wmT)
  c:put(p[1] + 1, p[2], WORM[max(1, p[3])], wmT)
end
c:put(19, 41, WORM[4], wmT) -- glossy back
c:put(23, 42, WORM[2], wmT) c:put(23, 43, WORM[1], wmT) -- head nub
c:put(18, 44, WORM[1], wmT) -- segment ring
c:put(17, 46, SOIL[1], soT) c:put(20, 46, SOIL[1], soT) -- soil ring where it emerges

A.save(c, "ico-hole")

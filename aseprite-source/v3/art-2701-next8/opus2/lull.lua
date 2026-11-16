-- lull (Opus second pass). Tag "lull" (Lull: it loses its next move = it dozes off). Keeps Haiku's sleeping crescent
-- moon + Zs, but the flat violet moon becomes a pale buttery moon with a 6-tone ramp, soft craters, a lit outer rim
-- and a cool shade on the inner curve; closed sleepy eye with lashes, a rosy cheek and a tiny open mouth. The Zs grow
-- as they float out of the crescent's mouth (cream with a dusk edge), plus one small star.
-- quirk: the moon wears a droopy striped nightcap with a pompom flopping over its top horn.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos
local c = O.new("lull")

local MOON = { "#5e4e8a", "#9a86b4", "#dcbe90", "#f2d898", "#fbeeb4", "#fffadc" }
local CAP  = { "#232052", "#35307a", "#4a48a8", "#6c74d0" }
local STR  = { "#b06a8a", "#e898b4", "#ffd0dc" }
local POM  = { "#d8c4b0", "#f2e6d0", "#fff4d6" }
local ZZ   = { "#35295f", "#c9b2f0", "#fff4d6" }
local INK  = "#2b1c26"

-- crescent: outer disc minus an offset disc (mouth opens to the upper right)
local OX, OY, OR = 28, 35, 19
local IX, IY, IR = 37, 29, 16
local moon = HP.mask()
local mn = {}
for y = OY - OR - 1, OY + OR + 1 do for x = OX - OR - 1, OX + OR + 1 do
  local dx, dy = x - OX, y - OY
  local q = (dx * dx + dy * dy) / ((OR + 0.4) ^ 2)
  local qi = ((x - IX) ^ 2 + (y - IY) ^ 2) / ((IR + 0.4) ^ 2)
  if q <= 1 and qi > 1 then
    moon:set(x, y)
    -- a fat crescent: normals of the outer sphere, bent outward near the inner edge
    local nx, ny = dx / OR, dy / OR
    local ex, ey = (x - IX) / IR, (y - IY) / IR
    local w = max(0, 1.35 - sqrt(qi)) * 1.2
    mn[K(x, y)] = { O.norm(nx * 0.8 + ex * w, ny * 0.8 + ey * w, sqrt(max(0.05, 1 - q)) + 0.25) }
  end
end end
local idx
do
  local tok = O.tok("moon")
  idx = O.shade(c, moon, mn, MOON, { tok = tok, amb = 0.12, wrap = 0.35 })
  -- soft craters (shallow dips: dark lower-right lip, lit upper-left lip)
  for _, cr in ipairs{ { 17, 44, 2 }, { 24, 50, 1.4 }, { 33, 50, 1.2 }, { 29, 46, 1 } } do
    local m = O.oval(cr[1], cr[2], cr[3], cr[3])
    m:each(function(x, y) if moon:has(x, y) then
      local d = (x - cr[1]) + (y - cr[2])
      O.step(c, idx, MOON, x, y, d < 0 and -1 or (d > 0 and 0 or -1), tok)
    end end)
    if moon:has(floor(cr[1] + cr[3] + 1), floor(cr[2] + 1)) and (idx[K(floor(cr[1] + cr[3] + 1), floor(cr[2] + 1))] or 0) >= 3 then O.step(c, idx, MOON, floor(cr[1] + cr[3] + 1), floor(cr[2] + 1), 1, tok) end
  end
  -- bright rim along the upper-left of the outer edge
  moon:each(function(x, y)
    local dx, dy = x - OX, y - OY
    if (not moon:has(x - 1, y) or not moon:has(x, y - 1)) and dx + dy < -12 and ((x - IX) ^ 2 + (y - IY) ^ 2) > (IR + 2) ^ 2 then
      O.set(c, idx, MOON, x, y, 6, tok)
    end
  end)
end

-- the sleepy face on the inner curve
do
  local tok = O.tok("face")
  -- closed eye: a downward arc with two lashes
  O.map(c, { "i...i", ".iii." }, 12, 30, { i = INK }, tok)
  c:put(11, 29, INK, tok) c:put(17, 29, INK, tok)
  -- cheek
  c:put(12, 34, STR[2], tok) c:put(13, 34, STR[2], tok) c:put(13, 35, STR[1], tok)
  -- small round 'o' mouth (snoring softly)
  O.map(c, { "m.m", ".m." }, 16, 36, { m = "#7a3a4a" }, tok)
end

-- quirk: droopy nightcap on the top horn, flopping to the right, pompom at its tip
do
  local tok = O.tok("cap")
  local capM, cn = O.tube({ { 22, 17 }, { 30, 9 }, { 40, 6 }, { 47, 13 } }, function(t) return 6.2 * (1 - t) ^ 0.9 + 0.8 end)
  -- clip the cap's brim so it sits on the horn, not floating
  local cidx = O.shade(c, capM, cn, CAP, { tok = tok, amb = 0.15 })
  -- stripes across the cap
  capM:each(function(x, y)
    local k = K(x, y)
    local t = nil
    -- distance along: approximate with x
    if ((x + floor(y * 0.6)) % 7) < 2 then
      local i = cidx[k] or 2
      c:put(x, y, STR[min(3, max(1, i - 1))], tok)
    end
  end)
  -- turned-up brim band where it meets the moon
  local brim = O.lmask(20, 20, -0.75, 12, function(u, v) return abs(u) <= 7.5 and v >= -1.2 and v <= 1.2 end)
  brim:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and POM[2] or POM[3], tok) end)
  brim:each(function(x, y) if not brim:has(x + 1, y + 1) then c:put(x, y, POM[1], tok) end end)
  -- pompom
  local pm, pn = O.oval(48, 15, 3, 3)
  O.shade(c, pm, pn, POM, { tok = tok, amb = 0.3, cuts = { 0.4, 0.75 } })
  c:put(46, 13, "#fff4d6", tok)
  for _, p in ipairs{ { 51, 15 }, { 48, 18 }, { 45, 16 } } do if pm:has(p[1], p[2]) then c:put(p[1], p[2], POM[1], tok) end end
end

-- Zs floating out of the crescent mouth, growing as they rise
do
  local tok = O.tok("zz")
  local function Z(x, y, s)
    for i = 0, s - 1 do c:put(x + i, y, ZZ[3], tok) c:put(x + i, y + s - 1, ZZ[3], tok) end
    for i = 1, s - 2 do c:put(x + s - 1 - i, y + i, ZZ[3], tok) end
    -- shade edge under the bottom bar
    c:put(x + s - 1, y + s - 1, ZZ[2], tok) c:put(x, y, ZZ[2], tok)
  end
  Z(38, 38, 5)
  Z(46, 27, 7)
  -- small star
  c:put(53, 42, ZZ[3], tok) c:put(52, 42, ZZ[2], tok) c:put(54, 42, ZZ[2], tok) c:put(53, 41, ZZ[2], tok) c:put(53, 43, ZZ[2], tok)
end

O.save(c, "lull")

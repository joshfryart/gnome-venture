-- cranberry (final, Opus single pass). A slim woody sprig running across the top with three small glossy
-- evergreen leaves; three oblong berries hang below it on thin hooked pedicels, with air between them.
-- Material: 6-tone per-pixel berry light (deep wine to coral), waxy bloom speckles, a cream specular and a
-- bright second glint (glossy), cool violet reflected light lower-right, dark dimple where each pedicel meets
-- its berry, blossom-end star on the front berry. Stem: 6-tone bark tube with nicks and a pale cut end.
-- Leaves: midrib + veins.
-- quirk: a dewdrop sits on the right leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = A.new("cranberry")
local BER  = { "#45102e", "#741634", "#a3203b", "#cc2f42", "#ea5a55", "#ff9884" }
local BLOOM, SPEC, BOUNCE = "#e9878a", "#fff1cf", "#7b4a8e"
local LEAF = { "#13302b", "#1d4735", "#28613c", "#3c7e41", "#5e9f49", "#93c766" }
local BARK = { "#331a22", "#53282a", "#763c30", "#9a5639", "#bf7a4e", "#e2a676" }
local PED = { "#4d3a2a", "#7d6a3e", "#a8a058" }

-- stem
local btok = { r = { name = "bark" } }
local sm, _, ST, SS, sidx = A.stem(c, { { 12, 15 }, { 22, 9 }, { 35, 12 }, { 50, 9 } },
  function(t) return 1.35 - 0.45 * t end, BARK, { tok = btok })
sm:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 3) < 0.09 and SS[k] > -0.3 then A.step(c, sidx, BARK, x, y, -2, btok) end end)
-- pale cut end
c:put(11, 15, BARK[6], btok) c:put(12, 16, BARK[5], btok) c:put(11, 16, BARK[4], btok)

-- leaves (after stem so their bases sit over it)
local ltok = { r = { name = "leaf" } }
A.leaf(c, 21, 9, 16, 6, 15, 1, 2.3, LEAF, { tok = ltok, vs = 2.6 })
A.leaf(c, 33, 11, 36, 5, 41, 2, 2.3, LEAF, { tok = ltok, vs = 2.6 })
local rl = A.leaf(c, 48, 10, 53, 6, 57, 7, 2.1, LEAF, { tok = ltok, vs = 2.6 })

-- pedicels: thin hooked stalks, 1 px, lit tone on the upper-left bend
local ptok = { r = { name = "ped" } }
local function ped(p)
  for i = 0, 50 do
    local t = i / 50
    local x, y = A.bez(p, t)
    local xi, yi = floor(x + .5), floor(y + .5)
    c:put(xi, yi, t < 0.5 and PED[3] or PED[2], ptok)
    if t < 0.12 then c:put(xi + 1, yi, PED[1], ptok) end
  end
end
ped{ { 20, 11 }, { 24, 16 }, { 18, 21 }, { 19, 28 } }
ped{ { 33, 13 }, { 38, 19 }, { 31, 27 }, { 33, 35 } }
ped{ { 45, 11 }, { 50, 15 }, { 46, 21 }, { 47, 26 } }

-- berries
local function berry(cx, cy, rx, ry, ang, star)
  local m, n = A.oval(cx, cy, rx, ry, ang, 0.9)
  local tok = { r = { name = "berry" .. cx } }
  local bias = {}
  local idx = A.shade(c, m, n, BER, { tok = tok, amb = 0.05, wrap = 0.2, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- waxy bloom speckles
  m:shrink(1):each(function(x, y)
    local i = idx[K(x, y)]
    if X.hash(x, y, 11) < 0.07 and i >= 3 and i <= 4 then c:put(x, y, BLOOM, tok) end end)
  -- cool reflected light
  local rim = X.rim(n)
  m:edge():each(function(x, y) local r = rim[K(x, y)]
    if r and r > 0.6 and x > cx and y > cy then c:put(x, y, BOUNCE, tok) end end)
  -- dimple where the pedicel meets
  local tx, ty = floor(cx + .5), floor(cy - ry + 0.5)
  c:put(tx, ty + 1, BER[1], tok) c:put(tx - 1, ty + 1, BER[2], tok) c:put(tx + 1, ty + 1, BER[2], tok)
  -- specular + second glint
  local sx, sy = A.specAt(m:shrink(2), n, 50)
  c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, BER[6], tok) c:put(sx, sy + 1, BER[6], tok)
  c:put(sx + 3, sy + 3, BER[6], tok)
  if star then
    local bx, by = floor(cx + 1.5), floor(cy + ry * 0.55)
    c:put(bx, by, BER[1], tok) c:put(bx - 1, by, BER[2], tok) c:put(bx + 1, by, BER[2], tok) c:put(bx, by + 1, BER[2], tok)
    c:put(bx, by - 1, BER[2], tok) c:put(bx - 1, by - 1, BER[5], tok)
  end
  return m
end
berry(19, 34, 5.5, 6.3, 0.15)
berry(33, 42, 6.2, 6.8, -0.1, true)
berry(47, 32, 5.3, 6.0, 0.2)

-- quirk: dewdrop on the right leaf
local dx, dy = 52, 6
c:put(dx, dy, "#fff1cf", ltok) c:put(dx + 1, dy, "#bfe6ee", ltok)
c:put(dx, dy + 1, "#8fcad8", ltok) c:put(dx + 1, dy + 1, "#3f7f8c", ltok)
A.save(c, "cranberry")

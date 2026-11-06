-- broken-silk-net (aB12_3, Opus single pass). A fine bug net: round bent-cane hoop strung with pale silk mesh,
-- brass collar, slim bamboo handle running to the lower-left.
-- Material: tube-lit cane hoop with a lit top arc and lashing wraps, silk as a bellied bag (sphere light) with a
-- diagonal weave, bamboo with raised nodes (dark groove + lit lip) and a pale cut end, AO where hoop meets collar.
-- broken: the hoop has snapped at the upper-right (gap, one end sprung outward), a ragged hole torn through the
-- silk with loose threads, and a cane chip flying off.
-- quirk: the moth it was meant to catch is fluttering out through the hole.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, cos, sin, atan = math.floor, math.sqrt, math.max, math.min, math.cos, math.sin, math.atan
local c = G.start(debug.getinfo(1, "S").source)
local CANE = G.WOOD
local BB, BR, SK = G.BAMBOO, G.BRASS, G.SILK

local HX, HY, R = 36, 24, 13.5
-- handle (bamboo) from the hoop's lower-left down to the lower-left
local btok = G.tok("bamboo")
local ax, ay, bx, by = 26.5, 34.5, 11, 52
local hm, HT, HS, hidx = G.cyl(c, ax, ay, bx, by, function(t) return 1.5 end, BB, { tok = btok })
local LEN = sqrt((bx - ax)^2 + (by - ay)^2)
hm:each(function(x, y) local k = K(x, y)
  local d = HT[k] * LEN
  for _, nd in ipairs{ 7.5, 15 } do
    if d > nd - 0.5 and d <= nd + 0.5 then c:put(x, y, BB[1], btok)
    elseif d > nd + 0.5 and d <= nd + 1.5 and HS[k] < 0.4 then c:put(x, y, BB[6], btok) end
  end
  if HS[k] > -0.6 and HS[k] < -0.2 and HT[k] > 0.25 and floor(d) % 3 ~= 0 then c:put(x, y, BB[5], btok) end
end)
-- pale cut end
c:put(11, 52, BB[6], btok) c:put(10, 52, BB[5], btok) c:put(11, 53, BB[4], btok)

-- silk bag (inside the hoop) -- bellied: sphere normals
local stok = G.tok("silk")
local sm = c:ellipse(HX, HY, R - 1.5, R - 1.5)
-- ragged hole torn in the upper-right of the silk
local hole = c:poly{ {37,15}, {41,13}, {44,15}, {48,14}, {46,19}, {42,23}, {43,26}, {39,24}, {38,21}, {35,20} }
sm:cut(hole)
local sn = X.sphere(HX - 2, HY - 2, R + 2, sm)
for _, v in pairs(sn) do v[1], v[2] = -v[1] * 0.6, -v[2] * 0.6 end   -- bag seen from inside: concave
local sidx = G.toneN(c, sm, sn, SK, { tok = stok, amb = 0.3, wrap = 0.4, cuts = { 0.2, 0.42, 0.6, 0.78, 0.92 } })
-- weave: diagonal mesh lines one tone darker
sm:each(function(x, y) local k = K(x, y)
  if (x + y) % 3 == 0 or (x - y) % 3 == 0 then c:put(x, y, SK[max(1, (sidx[k] or 3) - 1)], stok) end
  if (x + y) % 3 == 0 and (x - y) % 3 == 0 then c:put(x, y, SK[max(1, (sidx[k] or 3) - 2)], stok) end
end)
-- frayed edge: deeper rim around the hole + loose threads hanging into it
hole:grow(1):clip(sm):each(function(x, y) c:put(x, y, SK[2], stok) end)
G.pts(c, { {38,17}, {39,18}, {39,19} }, SK[5], stok)
G.pts(c, { {43,22}, {42,21} }, SK[5], stok)
G.pts(c, { {44,17}, {43,18} }, SK[4], stok)

-- cane hoop: ring tube, light per pixel from ring normals; gap where it snapped
local ctok = G.tok("cane")
local ring, rn, ang = HP.mask(), {}, {}
for y = HY - 17, HY + 17 do for x = HX - 17, HX + 17 do
  local dx, dy = x + .5 - HX, y + .5 - HY
  local d = sqrt(dx*dx + dy*dy)
  local a = atan(dy, dx)
  if d >= R - 1.6 and d <= R + 1.3 then
    ring:set(x, y)
    local s = (d - (R - 0.15)) / 1.6
    s = max(-0.95, min(0.95, s))
    local ox, oy = dx / d, dy / d
    rn[K(x, y)] = { ox * s, oy * s, sqrt(1 - s*s) }
    ang[K(x, y)] = a
  end
end end
-- snap gap at angle ~ -40deg
local GA = -0.72
ring:each(function(x, y) local k = K(x, y)
  local a = ang[k]
  if a > GA - 0.16 and a < GA + 0.2 then ring.s[k] = nil rn[k] = nil end end)
-- sprung end: the arc just counter-clockwise of the gap is pushed outward by 1px
local sprung, sn2 = HP.mask(), {}
ring:each(function(x, y) local k = K(x, y)
  local a = ang[k]
  if a < GA - 0.16 and a > GA - 0.5 then sprung:set(x, y) end end)
local moved = HP.mask()
sprung:each(function(x, y) local nx, ny = x + 1, y - 1 moved:set(nx, ny) sn2[K(nx, ny)] = rn[K(x, y)] ring.s[K(x, y)] = nil end)
ring:add(moved) for k, v in pairs(sn2) do rn[k] = v end
local cidx = G.toneN(c, ring, rn, CANE, { tok = ctok, amb = 0.1, wrap = 0.25 })
-- split ends: bright raw fibre
ring:each(function(x, y) local a = ang[K(x, y)]
  if a and ((a >= GA + 0.2 and a < GA + 0.3) or (a <= GA - 0.16 and a > GA - 0.24)) then c:put(x, y, CANE[6], ctok) end end)
moved:each(function(x, y) if not ring:has(x - 1, y + 1) or true then
  local ox, oy = x - 1, y + 1 local a = ang[K(ox, oy)]
  if a and a > GA - 0.26 then c:put(x, y, CANE[6], ctok) end end end)
-- lashing wraps at the top of the hoop (twine twist)
for _, a in ipairs{ -2.2, -1.9 } do
  for r = -1, 1 do
    local x, y = floor(HX + cos(a) * (R + r * 0.9 - 0.2)), floor(HY + sin(a) * (R + r * 0.9 - 0.2))
    if ring:has(x, y) then c:put(x, y, (r == -1) and BR[5] or BR[3], ctok) end
  end
end

-- brass collar where hoop meets the handle (over both), AO row on the hoop above it
local coltok = G.tok("collar")
local cm = G.cyl(c, 28.5, 32, 25, 36.5, function() return 2.3 end, BR, { tok = coltok })
c:put(27, 33, BR[6], coltok) c:put(26, 34, BR[6], coltok)
cm:each(function(x, y) if (x + y) == 61 then c:put(x, y, BR[2], coltok) end end)
for _, p in ipairs{ {29,30}, {30,31}, {28,30}, {30,32} } do
  if ring:has(p[1], p[2]) then c:put(p[1], p[2], CANE[1], ctok) end end

-- flying cane chip
local chip = c:poly{ {55,21}, {58,22}, {57,24}, {54,23} }
G.toneN(c, chip, X.pillow(chip, 1), CANE, { tok = G.tok("chip") })
c:put(55, 22, CANE[6])

-- specular on the hoop's top-left
c:put(27, 13, G.CREAM, ctok) c:put(28, 12, CANE[6], ctok)

-- quirk: moth fluttering out of the hole (cream wings, dusky body)
local MO = { w = "#f3e6c4", m = "#cdb88f", s = "#8f7a62", b = "#4a3a40" }
local mrows = {
  "ww.ww",
  "wmbmw",
  ".sbs.",
  "..b..",
}
for j, row in ipairs(mrows) do for i = 1, #row do local ch = row:sub(i, i)
  if MO[ch] then c:put(50 + i, 9 + j, MO[ch], G.tok("moth")) end end end

G.save(c)

-- cured-olives (final, Opus single pass). A slim glass preserving jar of cured olives in brine: green and purple
-- kalamata olives packed in a pale yellow-green brine, a bay leaf pressed against the glass, a meniscus line, air gap,
-- threaded glass lip, a speckled cork stopper and a twisted twine tie with a dangling end. Glass cues: bright broken
-- streak on the lit side, pale core, dark refracted right edge, thick pale base. Ground shadow (it stands).
-- quirk: one green olive floats up against the meniscus with its red pimento stuffing facing out.
local NAME = "cured-olives"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos = math.floor, math.abs, math.max, math.min, math.sin, math.cos
local c = A.new(NAME)

local BRINE = { "#4c5e34", "#6a7e40", "#8ea253", "#b2c272", "#d2dc98", "#ecf0c4" }
local AIR   = { "#3c5a72", "#5f86a0", "#8fb8c8", "#bcdcdf", "#e2f2ee", "#f6fbf2" }
local GRN   = { "#26341a", "#3f5320", "#5e7228", "#839636", "#a9b452", "#d6d888" }
local PUR   = { "#1f1226", "#391c3a", "#552850", "#743a64", "#9a567c", "#c88aa4" }
local BAY   = { "#24392a", "#355236", "#4d6d42", "#6c8a52", "#93a96a" }
local CORK  = { "#4a2c22", "#6e4430", "#97633f", "#bd8a56", "#dbb079", "#f0d29c" }
local TW    = { "#7a4a22", "#b97f38", "#e2b25c", "#f6dc96" }
local RED   = { "#7a1e2a", "#c8332e", "#f0644a" }

c:groundShadow(32, 55, 15, 1)

-- masks
local body  = c:rrect(19, 21, 44, 54, 6)
local shoul = c:rrect(21, 17, 42, 24, 4)
local lip   = c:rrect(22, 14, 41, 18, 1)
local glass = body:copy():add(shoul):add(lip)
local inner = body:copy():shrink(1):add(shoul:copy():shrink(1))
local cork  = c:poly{ {23, 7}, {40, 7}, {39, 14}, {24, 14} }:add(c:rrect(23, 6, 40, 9, 2))
local LIQ = 25                                     -- brine surface row

-- 1. back of the jar: brine (lit centre, dark edges) and air glass above
local nb = A.cylV(glass, 31.5, 12.5)
local vb = X.light(nb, { amb = 0.15, wrap = 0.4 })
glass:each(function(x, y) local k = K(x, y)
  local v = vb[k]
  local i = 1 + floor(v * 5.99)
  if y >= LIQ then c:put(x, y, BRINE[max(2, min(5, i))]) else c:put(x, y, AIR[max(2, min(5, i))]) end
end)

-- 2. olives (back to front), clipped to the inside of the brine
local olives = {
  { 25, 49, 3.4, 4.4, 0.3, PUR }, { 32, 50, 3.4, 4.4, -0.2, GRN }, { 39, 49, 3.4, 4.4, 0.4, PUR },
  { 28, 43, 3.4, 4.4, -0.5, GRN }, { 35, 42, 3.4, 4.4, 0.2, PUR }, { 41, 41, 3.2, 4.2, 0.1, GRN },
  { 24, 36, 3.2, 4.2, 0.2, PUR }, { 31, 35, 3.4, 4.4, 0.6, GRN }, { 39, 33, 3.3, 4.3, -0.3, PUR },
  { 27, 29, 3.4, 3.8, 1.3, GRN },                  -- the floater (pimento)
}
local liq = inner:copy():clip(c:rect(0, LIQ + 1, 63, 63))
local drawn = {}
for i, o in ipairs(olives) do
  local m, n = A.oval(o[1], o[2], o[3], o[4], o[5], 0.9)
  m:clip(i == #olives and inner or liq)
  local bias = {}
  -- olives in front of this one were not drawn yet; AO from those already drawn behind is not needed,
  -- but darken where the next olives will overlap (contact)
  for j = i + 1, #olives do local q = olives[j]
    local om = A.oval(q[1], q[2], q[3], q[4], q[5], 0.9)
    X.ao(bias, m, om, 1, -1) end
  local tok = { r = { name = "olive" .. i } }
  local idx = A.shade(c, m, n, o[6], { bias = bias, tok = tok, amb = 0.05, wrap = 0.2 })
  -- one glossy specular per olive, plus a cool bounce on the lower-right rim
  local sx, sy = A.specAt(m, n, 30)
  if sx then c:put(sx, sy, o[6][6], tok) if m:has(sx + 1, sy) then c:put(sx + 1, sy, o[6][5], tok) end end
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] and rim[k] > 0.55 and (idx[k] or 1) <= 2 then c:put(x, y, o[6] == GRN and "#4f6a52" or "#4a3a62", tok) end end)
  drawn[i] = m
  if i == #olives then
    -- quirk: pimento stuffing, a red disc with a lit edge at the olive's end facing the viewer
    local px, py = o[1] + 1, o[2]
    for _, q in ipairs{ {0, 0, 2}, {1, 0, 2}, {0, 1, 1}, {1, 1, 2}, {-1, 0, 3}, {0, -1, 3}, {1, -1, 2}, {-1, 1, 1}, {2, 0, 1} } do
      c:put(px + q[1], py + q[2], RED[q[3]], tok) end
    c:put(px - 1, py - 1, GRN[4], tok)
  end
end

-- 3. bay leaf pressed against the glass on the left (midrib + veins)
local bm, bn, BT, BS, blen = A.blade(23, 51, 21, 40, 26, 27, function(t)
  if t > 0.98 then return -1 end
  return math.max(0.4, 2.3 * math.sin(math.pi * math.min(1, t * 0.95 + 0.05)) ^ 0.7)
end, { fold = 0.35 })
bm:clip(inner)
local btok = { r = { name = "bay" } }
local bidx = A.shade(c, bm, bn, BAY, { tok = btok, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.12, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y)
  if abs(BS[k]) < 0.18 and BT[k] > 0.04 and BT[k] < 0.92 then c:put(x, y, BAY[5], btok)
  elseif abs(BS[k]) > 0.3 and BT[k] > 0.15 and BT[k] < 0.85 and ((BT[k] * blen - abs(BS[k]) * 3) % 3.4) < 0.8 then
    c:put(x, y, BAY[max(1, (bidx[k] or 3) - 1)], btok) end end)

-- 4. meniscus + air pocket
for x = 20, 43 do if inner:has(x, LIQ) and not drawn[#olives]:has(x, LIQ) then c:put(x, LIQ, x < 30 and BRINE[6] or BRINE[5]) end end
for x = 20, 43 do if inner:has(x, LIQ + 1) and not drawn[#olives]:has(x, LIQ + 1) and not bm:has(x, LIQ + 1) then
  if x > 36 then c:put(x, LIQ + 1, BRINE[3]) end end end

-- 5. glass skin: dark refracted right wall, pale left wall, broken highlight streak, thick base, threaded lip
glass:edge():each(function(x, y)
  if x >= 32 then c:put(x, y, y >= LIQ and "#2f4a3a" or AIR[1]) else c:put(x, y, y >= LIQ and "#c6dcb0" or AIR[4]) end end)
for y = 22, 50 do
  if not (y >= 37 and y <= 39) then
    c:put(21, y, y >= LIQ and "#f2f6dc" or AIR[6])
    if y > 23 and y < 34 then c:put(22, y, y >= LIQ and BRINE[6] or AIR[5]) end
  end
end
for _, y in ipairs{ 44, 45, 47 } do c:put(42, y, y >= LIQ and "#8ea27a" or AIR[3]) end   -- small far-side glint
-- thick base: two rows of pale glass with a bright lip line
for x = 21, 42 do
  if body:has(x, 53) then c:put(x, 53, x < 29 and AIR[5] or AIR[3]) end
  if body:has(x, 52) and x > 21 and x < 42 then c:put(x, 52, x < 26 and AIR[6] or AIR[4]) end
end
-- lip threads
lip:each(function(x, y)
  local base = (y == 15 or y == 17) and 4 or 3
  if x <= 23 then base = base + 1 elseif x >= 39 then base = base - 2 end
  c:put(x, y, AIR[max(1, min(6, base))])
end)
-- shoulder curve highlight
for _, p in ipairs{ {23, 19}, {24, 19}, {22, 20} } do c:put(p[1], p[2], AIR[6]) end

-- 6. twine: twisted cord round the neck + a dangling end with a frayed tip
local tws = {}
for x = 21, 42 do tws[#tws + 1] = { x, 16 } tws[#tws + 1] = { x, 17 } end
for _, p in ipairs(tws) do local x, y = p[1], p[2]
  local ph = (x + (y - 16) * 2) % 3
  local i = ph == 0 and 1 or (ph == 1 and 3 or 2)
  if x <= 23 then i = min(4, i + 1) elseif x >= 40 then i = max(1, i - 1) end
  c:put(x, y, TW[i], { r = { name = "twine" } })
end
local tend = { {43, 17, 2}, {44, 18, 3}, {44, 19, 1}, {45, 20, 2}, {45, 21, 3}, {46, 22, 2}, {45, 23, 1}, {47, 23, 3} }
for _, p in ipairs(tend) do c:put(p[1], p[2], TW[p[3]], { r = { name = "twine" } }) end

-- 7. cork: pillow-lit, pale top face, pores, ambient row where it sits in the lip
local ctok = { r = { name = "cork" } }
local cn = A.mix(X.pillow(cork, 3), A.cylV(cork, 31.5, 8.5), 0.5)
local cidx = A.shade(c, cork, cn, CORK, { tok = ctok, amb = 0.1, wrap = 0.3 })
for x = 24, 39 do c:put(x, 7, x < 33 and CORK[6] or CORK[5], ctok) end
for x = 24, 38 do c:put(x, 8, x < 30 and CORK[5] or CORK[4], ctok) end
cork:each(function(x, y) local h = X.hash(x, y, 7)
  if y > 8 and h < 0.16 then A.step(c, cidx, CORK, x, y, -2, ctok)
  elseif y > 8 and h > 0.93 then A.step(c, cidx, CORK, x, y, 1, ctok) end end)
for x = 24, 39 do if cork:has(x, 14) then c:put(x, 14, x < 28 and CORK[2] or CORK[1], ctok) end end
-- contact shadow of the cork on the lip
for x = 23, 40 do if lip:has(x, 15) and x > 24 then c:put(x, 15, AIR[1]) end end

A.save(c, NAME)

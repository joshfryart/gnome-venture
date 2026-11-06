-- ico-wave (final pass, Opus aR1_0). A curling breaker as one bold mass: back slope rises from the left, rolls over
-- the crest and curls down into a hooked lip over a hollow barrel (per-pixel pillow light, 6 sea tones, AO deepening the
-- concave face under the curl), flow lines following the curve, a cream foam crest, foam claws at the tip, a broken
-- foam line on the swell, one specular and a little spray.
-- quirk: a tiny paper boat is riding the swell, right under the curl.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
local c = A.new("ico-wave")

local SEA  = { "#1d2f5e", "#284a80", "#336fa8", "#4b97c6", "#72c2d8", "#b4eee2" }
local FOAM = { "#86aed0", "#cde6ee", "#fff4d6" }
local PAP  = { "#b9a68a", "#e8dcc0", "#fff4d6" }
local wtok, ftok, ptok = { r = { name = "water" } }, { r = { name = "foam" } }, { r = { name = "paper" } }

local BZ = {
  { { 7, 53 }, { 8, 30 }, { 18, 8.5 }, { 38, 8.5 } },
  { { 38, 8.5 }, { 52, 8.5 }, { 58.5, 21 }, { 53, 28.5 } },
  { { 53, 28.5 }, { 50, 35 }, { 41.5, 34 }, { 41.5, 27.5 } },
  { { 41.5, 27.5 }, { 36.5, 27 }, { 34.5, 35 }, { 40, 42 } },
  { { 40, 42 }, { 45, 47.5 }, { 52, 48.5 }, { 58, 49 } },
}
local pts = {}
for _, b in ipairs(BZ) do for i = 0, 24 do local x, y = A.bez(b, i / 24) pts[#pts + 1] = { x, y } end end
for x = 58, 7, -1 do pts[#pts + 1] = { x, 53.5 + sin(x * 0.42) * 0.9 } end
local wave = c:poly(pts)
-- the barrel pocket under the lip = the curl's inside (the concave face side)
local inner = HP.mask()
for _, i in ipairs{ 4, 5 } do for j = 0, 40 do local x, y = A.bez(BZ[i], j / 40) inner:set(floor(x), floor(y)) end end
for j = 0, 40 do local x, y = A.bez(BZ[3], j / 40) inner:set(floor(x), floor(y)) end
-- normals: pillowed mass, tilted so the face under the lip turns away from the light
local wn = X.pillow(wave, 6)
local bias = {}
X.ao(bias, wave, inner, 4, -1)
X.ao(bias, wave, inner, 2, -1)
local base = c:rect(0, 50, 63, 63)
wave:each(function(x, y) if y >= 50 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
local wi = A.shade(c, wave, wn, SEA, { tok = wtok, bias = bias, amb = 0.12, wrap = 0.3 })

-- flow lines: offsets of the outer curve, lighter on the back, darker on the face
local function flow(b, off, t0, t1, col, gap)
  for i = 0, 90 do local t = t0 + (t1 - t0) * i / 90
    local x, y = A.bez(b, t)
    local x2, y2 = A.bez(b, min(1, t + 0.01))
    local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local nx, ny = ty, -tx                 -- right-hand normal (points outward for the outer curve)
    local xi, yi = floor(x - nx * off + 0.5), floor(y - ny * off + 0.5)
    if wave:shrink(1):has(xi, yi) and (i % (gap or 11) ~= 0) then c:put(xi, yi, col, wtok) end
  end
end
flow(BZ[1], 4, 0.25, 1, SEA[6])
flow(BZ[2], 4, 0, 0.55, SEA[6])
flow(BZ[1], 9, 0.35, 1, SEA[5], 7)
flow(BZ[2], 9, 0, 0.3, SEA[5], 7)
flow(BZ[1], 15, 0.5, 1, SEA[3], 6)
flow(BZ[4], -3, 0.2, 1, SEA[2], 5)
flow(BZ[5], -3, 0, 0.5, SEA[2], 5)

-- foam crest along the top of the lip
local crest = HP.mask()
wave:each(function(x, y) if not wave:has(x, y - 1) and x > 24 and x < 57 and y < 26 then crest:set(x, y) end end)
crest:each(function(x, y)
  c:put(x, y, FOAM[3], ftok)
  if wave:has(x, y + 1) then c:put(x, y + 1, (x % 3 == 0) and FOAM[1] or FOAM[2], ftok) end
end)
wave:each(function(x, y) if not wave:has(x + 1, y) and y >= 18 and y <= 28 and x > 50 then c:put(x, y, FOAM[2], ftok) end end)
-- foam claws curling off the tip, into the pocket
local CL = {
  "ccp..",
  "cpfc.",
  ".f.cp",
  "...pf",
}
A.map(c, CL, 41, 29, { c = FOAM[3], p = FOAM[2], f = FOAM[1] }, ftok)
-- foam line where the swell meets, broken
for x = 8, 57 do
  local y = floor(50 + sin(x * 0.5) * 0.7)
  if wave:has(x, y) and x % 7 ~= 3 then
    c:put(x, y, (x % 4 == 0) and FOAM[2] or FOAM[3], ftok)
    if wave:has(x, y + 1) then c:put(x, y + 1, FOAM[1], ftok) end
  end
end
-- one specular on the back + spray off the crest
c:put(14, 30, FOAM[3], wtok) c:put(14, 31, SEA[6], wtok) c:put(15, 29, SEA[6], wtok)
A.map(c, { "c..", "..p" }, 55, 11, { c = FOAM[3], p = FOAM[2] }, ftok)

-- quirk: a paper boat riding the swell under the curl
local BOAT = {
  "...c....",
  "..cPc...",
  ".cPPpc..",
  "hhhhhhhh",
  ".hHHHHh.",
  "..dddd..",
}
A.map(c, BOAT, 44, 42, { c = PAP[3], P = PAP[2], p = PAP[1], h = PAP[3], H = PAP[2], d = PAP[1] }, ptok)

A.save(c, "ico-wave")

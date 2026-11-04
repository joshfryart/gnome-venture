-- healing-potion (final, Opus aC11_3). A round-bottomed glass flask on a slim neck: per-pixel sphere light on the
-- emerald tonic (6 tones, cool teal reflected light lower-right, bright meniscus line), glass cues (empty headspace
-- with a pale core, bright rim upper-left, darker teal wall lower-right, curved specular streak over the bulb, thick
-- flared lip with AO under it). Cork stopper with pores and a paler end grain; twisted twine wound round the neck
-- with a frayed loose end. Ground shadow (it stands). Small round bubbles rise in the tonic.
-- quirk: one of the rising bubbles is heart-shaped.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_3.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt, atan = math.max, math.min, math.floor, math.abs, math.sqrt, math.atan
local c = A.new("healing-potion")
local LIQ  = { "#163a3e", "#1c5d4a", "#27844f", "#43a955", "#7acb63", "#bfe98e" }
local GLS  = { "#3c6a80", "#6ea2b4", "#a6d4da", "#d2f0ec", "#f2fff8" }
local CORK = { "#4a2a24", "#6c4230", "#925f3e", "#b68250", "#d4a66c", "#efcf98" }
local TW   = { "#6e3f22", "#a96d30", "#d9a248", "#f4d27e" }
local COOL, SPEC = "#6cc4b4", "#fffbea"
local gt, lt, ct, tt = A.tok("glass"), A.tok("liquid"), A.tok("cork"), A.tok("twine")

c:groundShadow(32, 54, 10, 1)

-- bulb: glass wall + tonic + headspace
local CX, CY, R = 32, 40, 12
local bulb = c:ellipse(CX, CY, R, R)
local inner = bulb:shrink(1)
local wall = bulb:copy():cut(inner)
local MEN = 33
local liq = HP.mask() inner:each(function(x, y) if y >= MEN then liq:set(x, y) end end)
local head = inner:copy():cut(liq)
local sn = X.sphere(CX, CY, R, bulb)
local bias = {}
local _, v = A.shade(c, liq, sn, LIQ, { amb = 0.1, wrap = 0.3, bias = bias, tok = lt })
-- cool reflected light lower-right inside the tonic
local rim = X.rim(sn)
liq:each(function(x, y) local k = K(x, y)
  if not inner:shrink(1):has(x, y) and rim[k] > 0.62 then c:put(x, y, COOL, lt) end end)
-- meniscus: bright surface line, slightly curved up at the walls
for x = CX - R, CX + R do
  if liq:has(x, MEN) then c:put(x, MEN, (x < CX + 6) and LIQ[6] or LIQ[5], lt) end
  if liq:has(x, MEN + 1) and (x <= CX - R + 2 or x >= CX + R - 2) then c:put(x, MEN, LIQ[6], lt) end
end
-- headspace: pale core, darker toward the wall
head:each(function(x, y)
  local d = sqrt((x - CX)^2 + (y - CY)^2)
  c:put(x, y, (d < R - 3 and x < CX + 6) and GLS[4] or GLS[3], gt)
end)
-- glass wall: bright upper-left, mid, dark teal lower-right
wall:each(function(x, y) local k = K(x, y)
  local nn = sn[k]
  local d = -nn[1] * 0.7 - nn[2] * 0.7
  local col = d > 0.35 and GLS[5] or d > -0.2 and GLS[3] or d > -0.6 and GLS[2] or GLS[1]
  if y >= MEN and d <= -0.2 then col = d > -0.6 and LIQ[3] or LIQ[2] end
  c:put(x, y, col, gt)
end)
-- bubbles (round) + heart bubble (quirk)
for _, b in ipairs{ { 26, 45, 1 }, { 38, 48, 2 }, { 29, 37, 1 }, { 40, 41, 1 } } do
  local x, y, s = b[1], b[2], b[3]
  if s == 1 then c:put(x, y, LIQ[6], lt)
  else
    c:put(x, y, LIQ[6], lt) c:put(x + 1, y, LIQ[5], lt) c:put(x, y + 1, LIQ[5], lt) c:put(x + 1, y + 1, LIQ[4], lt)
  end
end
A.map(c, {
  ".ab.bc.",
  "abbbbbc",
  "bbbbbbc",
  ".bbbbd.",
  "..bdd..",
  "...d...",
}, 30, 40, { a = "#ffe2ec", b = "#ff9cba", c = "#e46a96", d = "#c24a7e" }, lt)
c:put(31, 41, "#ffe2ec", lt)
-- curved specular streak on the bulb, upper-left
for ang = 200, 246, 3 do
  local r = R - 2.6
  local x, y = floor(CX + r * math.cos(math.rad(ang)) + .5), floor(CY + r * math.sin(math.rad(ang)) + .5)
  if inner:has(x, y) then c:put(x, y, ang < 236 and SPEC or GLS[5], gt) end
end
c:put(25, 31, SPEC, gt)
-- neck
local NX0, NX1, NY0, NY1 = 29, 35, 15, 29
local neck = c:rect(NX0, NY0, NX1, NY1)
local ncol = { GLS[5], GLS[4], GLS[4], GLS[3], GLS[3], GLS[2], GLS[1] }
neck:each(function(x, y) c:put(x, y, ncol[x - NX0 + 1], gt) end)
for y = NY0 + 2, NY1 - 3 do if y % 5 ~= 0 then c:put(30, y, SPEC, gt) end end
-- shoulder AO where neck meets bulb
for x = NX0 - 1, NX1 + 1 do if bulb:has(x, NY1 + 1) and not neck:has(x, NY1 + 1) then c:put(x, NY1 + 1, x < CX and GLS[3] or GLS[2], gt) end end
c:put(NX0 - 1, NY1, GLS[2], gt) c:put(NX1 + 1, NY1, GLS[1], gt)
-- flared lip
local lip = c:rrect(27, 12, 37, 15, 1)
lip:each(function(x, y)
  local col = x <= 28 and GLS[5] or x <= 31 and GLS[4] or x <= 34 and GLS[3] or x <= 35 and GLS[2] or GLS[1]
  if y == 15 then col = (x <= 31) and GLS[2] or GLS[1] end
  if y == 12 and x > 28 and x < 35 then col = GLS[4] end
  c:put(x, y, col, gt)
end)
c:put(28, 13, SPEC, gt)
-- cork: tapered plug, top face paler (end grain), pores
local cork = c:rect(29, 8, 35, 11):add(c:rrect(28, 6, 36, 8, 1))
local cn = A.vcylN(cork, 28, 36)
local cb = {}
cork:each(function(x, y) local k = K(x, y)
  if y >= 9 and X.hash(x, y, 7) > 0.78 then cb[k] = -1 end
  if y == 11 then cb[k] = (cb[k] or 0) - 1 end
end)
A.shade(c, cork, cn, CORK, { amb = 0.12, wrap = 0.3, bias = cb, tok = ct })
for x = 29, 34 do c:put(x, 6, (x < 33) and CORK[6] or CORK[5], ct) end
c:put(30, 7, CORK[5], ct) c:put(33, 7, CORK[4], ct)
-- twine: twisted wraps round the neck + frayed loose end
for y = 19, 20 do for x = NX0, NX1 do
  local ph = (x + y) % 3
  local lit = (x <= 31) and 1 or 0
  local col = ph == 0 and TW[1 + lit] or ph == 1 and TW[2 + lit] or TW[3 + lit]
  if x == NX1 then col = TW[1] end
  c:put(x, y, col, tt)
end end
for x = NX0, NX1 do c:put(x, 21, GLS[1], gt) end -- AO under the twine
c:put(NX0, 21, GLS[3], gt)
for _, p in ipairs{ { 36, 20, 2 }, { 37, 21, 3 }, { 37, 22, 2 }, { 38, 23, 3 }, { 38, 24, 2 }, { 39, 25, 1 }, { 37, 25, 2 } } do
  c:put(p[1], p[2], TW[p[3]], tt)
end

A.save(c, "healing-potion")

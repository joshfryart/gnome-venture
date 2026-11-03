-- ico-soup-bowl (final, Opus single pass). Wide glazed bowl seen from 3/4 above on a short foot ring, filled to the
-- brim with pumpkin soup; a wooden spoon leans out to the right; one steam curl. Material: per-pixel ellipsoid light on
-- a 6-tone teal glaze with a vertical specular streak + cream glint, a cream glaze band round the belly, bevelled rim
-- (lit top lip, shaded inner wall at the back), deep AO under the rim overhang and on the foot; soup with carrot coins,
-- herb flecks and oil glints, darker meniscus at the wall; spoon with grain lines, paler end grain and a contact shadow
-- where it dips in. Ground shadow (stands). quirk: a drip of soup has run down the outside of the bowl.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.pi
local c = A.new("ico-soup-bowl")
local GL = { "#1d3350", "#24557a", "#2f7f9c", "#47a8b4", "#7fcfc6", "#c2f0e0" }
local BN = { "#7a5a48", "#a88468", "#cdb08a", "#e6cea4", "#f6e6c2", "#fff4d6" }
local SP = { "#6e2038", "#a83a2a", "#d8602a", "#f08a34", "#fbb04e", "#ffd47e" }
local WD = { "#51302b", "#864c33", "#b07040", "#cf9658", "#e8b982", "#f6d8aa" }
local gtok, stok, wtok, ftok = A.tok("glaze"), A.tok("soup"), A.tok("spoon"), A.tok("foot")
local CX, RY0 = 31.5, 27.5            -- rim centre
local RX, RYr = 23.5, 6.5             -- rim ellipse
local BY = 19                         -- bowl depth below rim centre

c:groundShadow(32, 52, 15, 1.2)

-- foot ring
local foot = A.fn(22, 45, 41, 49, function(x, y) return ((x - CX) / 10.5)^2 + ((y - 47) / 3)^2 <= 1 end)
local fbias = {}
foot:each(function(x, y) if y <= 46 then fbias[K(x, y)] = -2 end end)
A.pil(c, foot, 2, GL, { tok = ftok, bias = fbias, amb = 0.1 })

-- outer body: lower half-ellipsoid
local body = A.fn(4, 20, 60, 50, function(x, y)
  return y >= RY0 and ((x - CX) / (RX + 0.4))^2 + ((y - RY0) / (BY + 0.4))^2 <= 1 end)
local rim = A.ellM(CX, RY0, RX, RYr)
local inner = A.ellM(CX, RY0 + 0.3, RX - 2.6, RYr - 1.9)
local outer = body:copy():cut(rim)
local n, bias = {}, {}
outer:each(function(x, y)
  local k = K(x, y)
  local nx, ny = (x - CX) / (RX + 0.5), (y - RY0) / (BY + 0.5)
  local q = max(0.03, 1 - nx * nx - ny * ny)
  n[k] = { A.norm(nx, ny * 0.8, sqrt(q)) }
  -- AO under the rim overhang
  if rim:has(x, y - 1) or rim:has(x, y - 2) then bias[k] = -1 end
end)
local gidx = A.shade(c, outer, n, GL, { amb = 0.16, wrap = 0.4, bias = bias, tok = gtok, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
-- cream glaze band round the belly (follows the curve: 3 rows)
outer:each(function(x, y) local k = K(x, y)
  local dx = (x - CX) / RX
  local yc = RY0 + 7 + 3.2 * sqrt(max(0, 1 - dx * dx))
  local d = y - yc
  if d >= -1 and d <= 0 then
    local i = gidx[k]
    c:put(x, y, BN[max(1, min(6, i + (d == 0 and 0 or 1)))], gtok)
  end
end)
-- vertical specular streak + glint on the lit left of the belly
for y = RY0 + 2, RY0 + 13 do
  local x = 13 + floor((y - RY0) / 6)
  if outer:has(x, y) and (y < RY0 + 8 or y > RY0 + 10) then c:put(x, y, GL[6], gtok) if y < RY0 + 8 then c:put(x + 1, y, GL[5], gtok) end end
end
c:put(13, RY0 + 3, A.CREAM, gtok) c:put(13, RY0 + 4, A.CREAM, gtok)
-- cool reflected light on the lower-right underside
local rl = X.rim(n)
outer:edge():each(function(x, y) local k = K(x, y) if rl[k] > 0.62 and x > CX + 4 and y < 44 then c:put(x, y, "#5a9ac8", gtok) end end)
-- AO where body meets foot
foot:each(function(x, y) if outer:has(x, y - 1) and not outer:has(x, y) then c:put(x, y, GL[1], ftok) end end)

-- rim: bevelled lip (lit top edge, darker inner wall at the back)
local lip = rim:copy():cut(inner)
local ln = {}
lip:each(function(x, y)
  local dx, dy = (x - CX) / RX, (y - RY0) / RYr
  local front = dy > 0
  ln[K(x, y)] = { A.norm(dx * 0.6, front and 0.3 or -0.55, 1) }
end)
local lidx = A.shade(c, lip, ln, GL, { amb = 0.2, wrap = 0.35, tok = gtok, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
-- top of the lip: bright bevel line along the outer front edge and the back edge
lip:each(function(x, y)
  if not rim:has(x, y - 1) then c:put(x, y, (x < CX + 8) and GL[6] or GL[5], gtok) end
  if inner:has(x, y + 1) and y < RY0 then c:put(x, y, GL[2], gtok) end -- inner wall at the back, in shade
end)

-- soup surface (inner ellipse), lit gently from the left, darker meniscus ring at the wall
local soup = inner:copy()
local sn = {}
soup:each(function(x, y) local dx, dy = (x - CX) / RX, (y - RY0) / RYr sn[K(x, y)] = { A.norm(dx * 0.35, dy * 0.25 - 0.2, 1) } end)
local sidx = A.shade(c, soup, sn, SP, { amb = 0.25, wrap = 0.4, tok = stok, cuts = { 0.2, 0.42, 0.62, 0.8, 0.92 } })
soup:edge():each(function(x, y) A.step(c, sidx, SP, x, y, -1, stok) end)
-- back meniscus: shadow cast by the back wall
soup:each(function(x, y) if not soup:has(x, y - 1) or not soup:has(x, y - 2) then if y < RY0 then A.step(c, sidx, SP, x, y, -1, stok) end end end)
-- cream swirl, golden croutons, herb flecks, oil glints
local CR = { c = "#fff4d6", s = "#f2d8b0" }
A.map(c, {
  ".ccc..",
  "c...c.",
  "c.cc.s",
  ".s..s.",
  "..ss..",
}, 24, 25, CR, stok)
local CT = { h = "#ffe38a", b = "#f5b82e", d = "#b06a2a" }
for _, p in ipairs{ { 15, 27 }, { 36, 29 } } do A.map(c, { "hhb", "hbd", "bdd" }, p[1], p[2], CT, stok) end
local HB = { g = "#3f9150", G = "#7cc35a" }
for _, p in ipairs{ { 20, 25 }, { 33, 26 }, { 19, 30 }, { 41, 27 } } do A.map(c, { "Gg", ".g" }, p[1], p[2], HB, stok) end
for _, p in ipairs{ { 37, 25 }, { 22, 28 }, { 30, 30 } } do c:put(p[1], p[2], SP[6], stok) end
c:put(27, 25, A.CREAM, stok)

-- spoon: wooden, dipping in at the right, handle leaning out up-right
local sa, sb = { 39.5, 27 }, { 54, 9 }
local spm, spn, ST, SS = A.ctube({ sa, { 47, 18 }, sb }, function(t) return t > 0.94 and 1.9 or 1.45 end, 120)
spm:cut(soup:copy():cut(A.fn(0, 0, 63, 63, function(x, y) return y < RY0 - 1 end))) -- submerged part hidden
local wbias = {}
spm:each(function(x, y) local k = K(x, y) if lip:has(x, y) then wbias[k] = 0 end end)
local widx = A.shade(c, spm, spn, WD, { amb = 0.12, wrap = 0.3, tok = wtok, bias = wbias })
-- grain lines along the handle (a dark streak on the shade half every few px), pale end grain at the top
spm:each(function(x, y) local k = K(x, y)
  if SS[k] > 0.2 and SS[k] < 0.7 and floor(ST[k] * 22) % 3 ~= 0 then A.step(c, widx, WD, x, y, -1, wtok) end
  if ST[k] > 0.965 then c:put(x, y, WD[6], wtok) end
end)
-- contact shadow ring on the soup where the spoon goes in
for _, p in ipairs{ { 37, 27 }, { 38, 28 }, { 39, 29 }, { 41, 29 }, { 42, 28 } } do
  if soup:has(p[1], p[2]) and not spm:has(p[1], p[2]) then c:put(p[1], p[2], SP[2], stok) end end
-- shadow of the handle on the rim
for _, p in ipairs{ { 43, 23 }, { 44, 22 } } do if lip:has(p[1], p[2]) and not spm:has(p[1], p[2]) then c:put(p[1], p[2], GL[2], gtok) end end

-- steam curl above the left of the bowl (3 px, cream with sky shade)
local stm, stn, STT, STS = A.ctube({ { 19, 21 }, { 16.5, 16 }, { 19.5, 11 }, { 17, 6.5 } }, function(t) return 1.5 - t * 0.4 end, 80)
stm:cut(rim)
stm:each(function(x, y) local k = K(x, y) c:put(x, y, STS[k] > 0.25 and "#b9e2f5" or A.CREAM, A.tok("steam")) end)

-- quirk: soup drip running down the front-left of the bowl, ending in a fat drop
do
  local DR = { a = SP[5], b = SP[4], d = SP[3], e = SP[2] }
  A.map(c, {
    "abd",
    "abd",
    ".bd",
    ".bd",
    "abde",
    "bbde",
    ".de.",
  }, 21, 33, DR, stok)
end
A.save(c, "ico-soup-bowl")

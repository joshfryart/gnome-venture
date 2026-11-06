-- green-pea-soup (aC10_1, Opus single pass). A slim footed ceramic bowl in 3/4 view: cream glaze lit per pixel as
-- a curved shell (bright lip, specular on the left shoulder, cool bounce lower right), a hand-painted cobalt band
-- and pin line that follow the curve, a narrow foot in AO. Thick pea soup, domed and lumpy (dark and pale specks),
-- a cream swirl, three whole peas and a mint leaf; the inner back wall shows above the soup. A wooden spoon rests on
-- the back rim (grain dashes, pale end grain, a hang hole), with a meniscus ring where it enters the soup and a
-- contact shadow on the rim. Ground shadow under the foot.
-- quirk: one fat drip of soup has run down over the blue band.
local NAME = "green-pea-soup"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)

local CER  = { "#4c4668", "#716b8e", "#9d97b4", "#c9c3d4", "#eae4e2", "#fcf7ee" }
local BLUE = { "#1f2a58", "#2a4486", "#3864ae", "#558ccf", "#86b6e6", "#bcdcf6" }
local PEA  = { "#2e4a1c", "#43681f", "#5f8c27", "#80ad33", "#a6cb4a", "#d2e682" }
local PEAB = { "#2a5a24", "#3c7e2c", "#58a238", "#82c64a", "#b8e47a" }
local MINT = { "#163c34", "#1f5c42", "#2c7c4c", "#4aa058", "#7cc46c" }
local CRM  = { "#c9c39a", "#ebe4c2", "#fff8e8" }
local WOOD = { "#3e2522", "#5e3828", "#864c33", "#b07444", "#d49a62", "#efc690" }
local SPEC, BOUNCE = "#fffaf0", "#8fa0d4"
local CX, CY, RX, RY = 32, 27, 22.5, 7

c:groundShadow(32, 48.5, 15, 1.6)

-- body (outer shell) + foot
local function hw(y) local q = (y - CY) / 18.5 return 22.5 * max(0, 1 - q * q) ^ 0.55 end
local function yr(x) local q = (x - CX) / RX return CY + RY * sqrt(max(0, 1 - q * q)) end
local body = HP.mask()
for y = CY, 44 do local h = hw(y) for x = floor(CX - h + 0.5), floor(CX + h - 0.5) do body:set(x, y) end end
local foot = HP.mask()
for y = 44, 47 do local h = (y == 44) and 6 or 7 for x = CX - h, CX + h do foot:set(x, y) end end
foot:cut(body)
local btok = { r = { name = "bowl" } }
local bn = {}
body:each(function(x, y)
  local h = hw(y) + 0.6
  local nx = (x - CX) / h
  local ny = 0.15 + 0.85 * ((y - CY) / 18.5) ^ 1.3
  bn[K(x, y)] = { G.norm(nx * 0.95, ny, sqrt(max(0.06, 1 - nx * nx - ny * ny * 0.6))) }
end)
local bv = X.light(bn, { amb = 0.1, wrap = 0.3 })
local bias = {}
body:each(function(x, y) if y >= 42 and abs(x - CX) < 8 then bias[K(x, y)] = -1 end end)
local bidx = X.tone(c, body, bv, CER, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, bias = bias, tok = btok })
-- painted band + pin line, following the front rim curve
body:each(function(x, y) local k = K(x, y)
  local d = y - yr(x)
  if (d >= 3 and d < 5) or (d >= 6.5 and d < 7.5) then c:put(x, y, BLUE[min(6, bidx[k])], btok) end
end)
-- cool reflected light on the lower right rim of the shell
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > CY + 6 and x > CX + 4 then c:put(x, y, BOUNCE, btok) end end)
-- foot: dark, AO under the bowl
local ftok = { r = { name = "foot" } }
foot:each(function(x, y)
  local t = (x - (CX - 7)) / 14
  local i = t < 0.25 and 4 or t < 0.6 and 3 or t < 0.85 and 2 or 1
  if y == 44 or y == 45 then i = max(1, i - 1) end
  c:put(x, y, CER[i], ftok)
end)
c:put(CX - 6, 46, CER[5], ftok)

-- rim lip + inside
local E1 = c:ellipse(CX, CY, RX, RY)
local E2 = c:ellipse(CX, CY + 0.4, RX - 2.2, RY - 1.5)
local lip = E1:copy():cut(E2)
local rtok = { r = { name = "rim" } }
lip:each(function(x, y)
  local t = (x - (CX - RX)) / (2 * RX)
  local front = y >= CY
  local i = t < 0.3 and 6 or t < 0.65 and 5 or t < 0.88 and 4 or 3
  if front and t > 0.75 then i = i - 1 end
  c:put(x, y, CER[i], rtok)
end)
local soup = c:ellipse(CX, CY + 1.4, RX - 4, RY - 2.3):clip(E2)
local wall = E2:copy():cut(soup)
local wtok = { r = { name = "inner" } }
wall:each(function(x, y)
  local t = (x - (CX - RX)) / (2 * RX)
  local i = t < 0.35 and 2 or t < 0.7 and 3 or 4
  if not soup:has(x, y + 1) and not E2:has(x, y - 1) then i = max(1, i - 1) end
  if soup:has(x, y + 1) then i = max(1, i - 1) end
  c:put(x, y, CER[i], wtok)
end)

-- soup: domed, lumpy
local ptok = { r = { name = "soup" } }
local sn = X.pillow(soup, 3, 0.7)
local sv = X.light(sn, { amb = 0.2, wrap = 0.3 })
local sbias = {}
soup:each(function(x, y) local k = K(x, y)
  local hsh = X.hash(x, y, 5)
  if hsh > 0.86 then sbias[k] = -1 elseif hsh < 0.07 then sbias[k] = 1 end
end)
-- spoon (needed for AO on the soup)
local spts = { { 39, 29 }, { 44, 22 }, { 50, 15 }, { 55, 9 } }
local hm, hn, HT, HS = G.tube(spts, function(t) return 1.55 end)
X.ao(sbias, soup, hm, 1, -1)
G.cast(sbias, soup, hm, 1, 1, -1)
X.tone(c, soup, sv, PEA, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = sbias, tok = ptok })
-- cream swirl
for i = 0, 70 do
  local th = i / 70 * 2.6 * pi
  local r = 0.6 + th * 1.05
  local x, y = floor(26 + r * cos(th) + 0.5), floor(28.4 + r * sin(th) * 0.36 + 0.5)
  if soup:has(x, y) and not hm:has(x, y) then c:put(x, y, (y < 28) and CRM[3] or CRM[2], ptok) end
end
c:put(26, 28, CRM[1], ptok)
-- whole peas
local qtok = { r = { name = "peas" } }
for _, q in ipairs{ { 35, 29 }, { 37.5, 30 }, { 19, 28.5 } } do
  local m = c:ellipse(q[1], q[2], 1.3, 1.3)
  local n = X.sphere(q[1] - 0.3, q[2] - 0.3, 1.5, m)
  X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.2 }), PEAB, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = qtok })
  c:put(floor(q[1] + 1.5), floor(q[2] + 1.5), PEA[1], ptok)
end
c:put(34, 28, PEAB[5], qtok)
-- mint leaf floating at the back left
local mm, mn, MT, MS = G.blade(22, 26, 18, 25, 14, 26.5, function(t) if t > 0.97 then return -1 end return max(0.4, 1.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6) end, { fold = 0.3 })
mm:clip(E2)
local mtok = { r = { name = "mint" } }
G.toneN(c, mm, mn, MINT, { tok = mtok, cuts = { 0.25, 0.45, 0.65, 0.82 }, amb = 0.15, wrap = 0.3 })
mm:each(function(x, y) if abs(MS[K(x, y)]) < 0.15 and MT[K(x, y)] < 0.85 then c:put(x, y, MINT[5], mtok) end end)

-- wooden spoon handle resting on the back rim
local wtk = { r = { name = "spoon" } }
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local hidx = X.tone(c, hm, hv, WOOD, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = wtk })
hm:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
  -- grain dashes
  if abs(s - 0.3) < 0.2 and (t * 26) % 3 < 1.8 and t > 0.08 then c:put(x, y, WOOD[max(1, hidx[k] - 2)], wtk) end
  if s < -0.35 and t > 0.25 and t < 0.6 and (t * 26) % 4 < 1 then c:put(x, y, WOOD[max(1, hidx[k] - 1)], wtk) end
  -- pale end grain at the tip
  if t > 0.965 then c:put(x, y, s < 0.2 and WOOD[6] or WOOD[5], wtk) end
end)
c:put(53, 12, WOOD[1], wtk) c:put(54, 12, WOOD[2], wtk)   -- hang hole
c:put(42, 25, WOOD[6], wtk) c:put(43, 24, WOOD[6], wtk)   -- specular on the handle
-- contact shadow on the rim lip under the handle
hm:shift(1, 1):each(function(x, y) if lip:has(x, y) and not hm:has(x, y) then c:put(x, y, CER[2], rtok) end end)
-- meniscus ring where the handle meets the soup
for _, p in ipairs{ { 37, 29 }, { 38, 30 }, { 39, 31 }, { 40, 31 }, { 41, 30 } } do
  if soup:has(p[1], p[2]) and not hm:has(p[1], p[2]) then c:put(p[1], p[2], PEA[5], ptok) end
end

-- specular on the bowl shoulder
c:put(15, 30, SPEC, btok) c:put(16, 30, SPEC, btok) c:put(15, 31, CER[6], btok)

-- quirk: soup drip over the lip and band
local dtok = { r = { name = "drip" } }
local dx = 22
local y0 = floor(yr(dx))
for y = y0, y0 + 4 do c:put(dx, y, PEA[4], dtok) c:put(dx + 1, y, PEA[3], dtok) end
for _, p in ipairs{ { dx - 1, y0 + 5, 4 }, { dx, y0 + 5, 5 }, { dx + 1, y0 + 5, 3 }, { dx + 2, y0 + 5, 2 },
                     { dx - 1, y0 + 6, 3 }, { dx, y0 + 6, 3 }, { dx + 1, y0 + 6, 2 }, { dx + 2, y0 + 6, 2 },
                     { dx, y0 + 7, 2 }, { dx + 1, y0 + 7, 1 } } do c:put(p[1], p[2], PEA[p[3]], dtok) end
c:put(dx, y0 + 5, PEA[6], dtok)
c:put(dx, y0 - 1, PEA[4], dtok) c:put(dx + 1, y0 - 1, PEA[3], dtok)

G.save2(c, NAME)

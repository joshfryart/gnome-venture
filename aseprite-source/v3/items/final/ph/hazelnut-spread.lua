-- hazelnut-spread (final, Opus aC11_3). An open, slim glass jar of glossy chocolate-hazelnut spread, a butter knife
-- standing in it. Material: per-pixel cylinder light on the spread through the glass (6-tone cocoa, pale air streaks
-- against the glass), glass cues (bright left wall + rim, dark teal right wall, thick pale base, reflection streak),
-- spread surface inside the rim with the back rim's AO and a soft-serve swirl with one glossy specular. Cream paper
-- label wrapped round the middle (gold rules, a little hazelnut drawn on it), AO under the label edges. Knife: steel
-- blade with a bevel, bright edge and a smear of spread; wooden handle with grain, a paler end and a hanging hole.
-- Ground shadow (it stands).
-- quirk: a whole hazelnut sits on top of the swirl like a cherry on a sundae.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_3.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt = math.max, math.min, math.floor, math.abs, math.sqrt
local c = A.new("hazelnut-spread")
local CHOC = { "#24100f", "#3e1d16", "#5c2e20", "#7c432a", "#a05f38", "#c8864e" }
local GLS  = { "#3c6478", "#6e9cae", "#a4ccd2", "#d4ece8", "#f2fff8" }
local PAP  = { "#8a6c56", "#b89a7a", "#dac39a", "#efe0bc", "#fff4d6" }
local NUT  = { "#3a1f1c", "#5e3424", "#86502e", "#ad7240", "#d09a58", "#efc88c" }
local STEEL = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6", "#f8f6fa" }
local WOOD = { "#4c2c26", "#734430", "#9a6440", "#bf8652", "#deaa70", "#f2cf98" }
local GOLD = "#d98322"
local gt, st, pt, kt, wt, nt = A.tok("glass"), A.tok("spread"), A.tok("label"), A.tok("blade"), A.tok("handle"), A.tok("nut")

c:groundShadow(31.5, 54, 12, 1)

-- jar body
local X0, X1, Y0, Y1 = 21, 42, 23, 52
local body = c:rrect(X0, Y0, X1, Y1, 3)
local mouthO = c:ellipse(31.5, 23, 10.5, 2.5)
body:add(mouthO)
local mouthI = c:ellipse(31.5, 23, 8.5, 1.5)
local walls = HP.mask()
body:each(function(x, y) if x <= X0 or x >= X1 or y >= Y1 - 2 then walls:set(x, y) end end)
walls:add(body:edge())
local spread = body:copy():cut(walls):cut(mouthO)
-- spread through the glass
local sn = A.vcylN(spread, X0, X1)
local sb = {}
spread:each(function(x, y) local k = K(x, y)
  if y <= 27 then sb[k] = -1 end -- under the rim lip
  if X.hash(x, y, 3) > 0.94 then sb[k] = (sb[k] or 0) + 2 end
end)
A.shade(c, spread, sn, CHOC, { amb = 0.08, wrap = 0.25, bias = sb, tok = st })
-- pale air streaks pressed against the glass
for _, s in ipairs{ { 26, 29, 3 }, { 34, 47, 3 }, { 29, 48, 2 }, { 37, 30, 2 } } do
  for i = 0, s[3] - 1 do if spread:has(s[1] + i, s[2] - (i == s[3] - 1 and 1 or 0)) then c:put(s[1] + i, s[2] - (i == s[3] - 1 and 1 or 0), CHOC[5], st) end end
end
-- glass walls and base
walls:each(function(x, y)
  local col
  if y >= Y1 - 2 then col = (y == Y1 - 2) and GLS[3] or (y == Y1 - 1) and ((x < 32) and GLS[4] or GLS[2]) or GLS[1]
  elseif x <= X0 + 1 then col = GLS[5]
  elseif x >= X1 - 1 then col = GLS[1]
  else col = GLS[3] end
  c:put(x, y, col, gt)
end)
-- reflection streak on the glass over the spread
for y = 28, 48 do if spread:has(23, y) and (y < 32 or y > 45) then c:put(23, y, GLS[4], gt) end end
for y = 29, 31 do c:put(24, y, GLS[5], gt) end
for y = 46, 47 do c:put(24, y, GLS[4], gt) end
for y = 28, 48 do if spread:has(40, y) and (y < 32 or y > 45) and y % 3 ~= 0 then c:put(40, y, GLS[2], gt) end end
-- rim ring: back half paler, front half bright left / dark right
mouthO:copy():cut(mouthI):each(function(x, y)
  local col
  if y < 23 then col = GLS[3] else col = (x < 28) and GLS[5] or (x < 36) and GLS[4] or GLS[2] end
  c:put(x, y, col, gt)
end)
-- spread surface inside the rim (back rim casts AO)
mouthI:each(function(x, y)
  local col = (y <= 22) and CHOC[2] or (x < 30) and CHOC[4] or CHOC[3]
  c:put(x, y, col, st)
end)
-- soft-serve swirl mound
local mound = c:ellipse(30, 21, 5, 2.2):add(c:ellipse(30.5, 18.5, 3, 1.6))
local mn = X.sphere(30, 19.5, 5, mound)
local mb = {}
mound:each(function(x, y) local k = K(x, y)
  if y == 21 and x > 26 then mb[k] = -1 end      -- groove of the swirl
  if y == 19 and x > 28 then mb[k] = -1 end
end)
A.shade(c, mound, mn, CHOC, { amb = 0.15, wrap = 0.3, bias = mb, tok = st })
c:put(32, 17, CHOC[4], st) c:put(33, 17, CHOC[3], st) c:put(33, 16, CHOC[4], st) -- swirl tip curling right
c:put(27, 20, "#f0c89a", st) c:put(28, 20, CHOC[6], st)
-- quirk: a whole hazelnut on top
local nut = c:ellipse(29.5, 14.5, 2.5, 2.4):add(c:rect(29, 11, 30, 11))
local nn = X.sphere(29.5, 14, 2.6, nut)
local nb = {}
nut:each(function(x, y) if y >= 16 then nb[K(x, y)] = -1 end end)
A.shade(c, nut, nn, NUT, { amb = 0.12, wrap = 0.25, bias = nb, tok = nt })
for x = 28, 31 do if nut:has(x, 16) then c:put(x, 16, (x < 30) and "#c8b89a" or "#9a8a72", nt) end end -- pale basal scar
c:put(28, 13, NUT[6], nt) c:put(30, 15, NUT[3], nt) c:put(29, 11, NUT[3], nt)

-- label
local LY0, LY1 = 33, 44
local lab = c:rect(X0, LY0, X1, LY1)
local ln = A.vcylN(lab, X0, X1)
local lb = {}
lab:each(function(x, y) local k = K(x, y)
  if y == LY0 + 1 or y == LY1 - 1 then lb[k] = -9 end
end)
A.shade(c, lab, ln, PAP, { amb = 0.2, wrap = 0.35, cuts = { 0.22, 0.42, 0.62, 0.8 }, tok = pt })
for x = X0, X1 do
  c:put(x, LY0 + 1, (x % 3 ~= 2) and GOLD or PAP[3], pt)
  c:put(x, LY1 - 1, (x % 3 ~= 2) and GOLD or PAP[3], pt)
  if spread:has(x, LY1 + 1) then c:put(x, LY1 + 1, CHOC[1], st) end   -- AO under the label
end
c:put(X0, LY0, GLS[5], gt) c:put(X1, LY0, GLS[1], gt) c:put(X0, LY1, GLS[5], gt) c:put(X1, LY1, GLS[1], gt)
-- little hazelnut drawing on the label
A.map(c, {
  "..gg..",
  ".lggl.",
  "bnnnnb",
  "bhnnnb",
  "bnnnsb",
  ".bnsb.",
  "..bb..",
}, 28, 36, { g = "#5a9a48", l = "#82b956", b = "#5e3424", n = "#ad7240", h = "#efc88c", s = "#86502e" }, pt)

-- knife: steel blade out of the swirl, wooden handle
local blade = c:line({ { 35, 19 }, { 39, 15 } }, 3)
blade:cut(mound)
blade:each(function(x, y)
  local d = (x - 35) + (19 - y)          -- along
  local side = (x + y) - (35 + 19)       -- across: <0 upper-left
  local col = side < 0 and STEEL[5] or side == 0 and STEEL[3] or STEEL[2]
  if side < -1 then col = STEEL[4] end
  if d <= 1 then col = side < 0 and CHOC[5] or CHOC[3] end   -- smear of spread
  c:put(x, y, col, kt)
end)
c:put(36, 19, CHOC[4], kt)
local hm, hn, HT, HS = A.tube({ { 39, 15 }, { 42, 12 }, { 45, 9 }, { 48, 6 } }, function(t) return t > 0.86 and 1.55 or 1.15 end)
local hb = {}
hm:each(function(x, y) local k = K(x, y)
  if abs(HS[k]) < 0.3 and (HT[k] * 13) % 4 < 1.6 then hb[k] = -1 end   -- grain
  if HT[k] < 0.08 then hb[k] = -1 end                                   -- AO at the bolster
end)
A.shade(c, hm, hn, WOOD, { amb = 0.12, wrap = 0.3, bias = hb, tok = wt })
c:put(47, 7, WOOD[1], wt)       -- hanging hole
c:put(48, 5, WOOD[6], wt)       -- paler end grain

A.save(c, "hazelnut-spread")

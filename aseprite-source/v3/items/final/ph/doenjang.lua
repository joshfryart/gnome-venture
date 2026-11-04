-- doenjang (final, Opus single pass). A small onggi crock: dark glossy brown glaze on a revolved belly
-- (specular streak, cool reflected rim, finger-drawn wave band in relief), glaze stopping in drips above the
-- unglazed terracotta foot, rolled lip, a heaped mound of chunky soybean paste (bean bits, lit crown) with a
-- wooden paddle stuck in it (grain line, AO ring where it enters the paste), ground shadow.
-- quirk: a twisted straw geumjul rope round the neck with a dried red chili tucked into it.
local NAME = "doenjang"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local GLAZE = { "#2e1a18", "#45261c", "#623620", "#82492a", "#a6643a", "#cc8e5a" }
local TERRA = { "#5a3424", "#7e4a30", "#a0643e", "#bf7f50", "#d89c68", "#ecbe8c" }
local PASTE = { "#4a2a16", "#6e4020", "#93602c", "#b8823c", "#d4a456", "#ecc87a" }
local WOOD  = { "#4a2a1e", "#6e4028", "#965a34", "#c08850", "#deac72", "#f4d29c" }
local STRAW = { "#6a4a1c", "#9a7028", "#c89a3a", "#e8c25c", "#f8e08c" }
local CHILI = { "#5a1428", "#8e1e2a", "#c8302c", "#ee5234", "#ff8c5c", "#ffd0a0" }

c:groundShadow(32, 56, 13, 1.5)

-- crock body
local function bw(y)
  if y <= 25 then return 10.6 end
  local t = (y - 25) / 30
  local w = 10.2 + 3.4 * sin(pi * t ^ 0.85)
  if t > 0.9 then w = w - (t - 0.9) * 16 end
  return w
end
local bm, bn, BU = A.rev(32, 24, 55, bw)
local glz, foot, drip = HP.mask(), HP.mask(), {}
for x = 16, 48 do drip[x] = 50 + floor(X.hash(x, 0, 5) * 2.2) + ((x % 7 == 3) and 1 or 0) end
bm:each(function(x, y) if y >= drip[x] then foot:set(x, y) else glz:set(x, y) end end)
local gtok, ftok = { r = { name = "glaze" } }, { r = { name = "foot" } }
local gidx = A.shade(c, glz, bn, GLAZE, { tok = gtok, amb = 0.08, wrap = 0.3, cuts = { 0.3, 0.46, 0.62, 0.76, 0.9 } })
local fidx = A.shade(c, foot, bn, TERRA, { tok = ftok, amb = 0.1, wrap = 0.3 })
foot:each(function(x, y) if X.hash(x, y, 9) > 0.8 then A.step(c, fidx, TERRA, x, y, -1, ftok) end end)
-- glaze drip lip (darker pooled edge)
glz:each(function(x, y) if not glz:has(x, y + 1) and bm:has(x, y + 1) then A.step(c, gidx, GLAZE, x, y, -1, gtok) end end)
-- wave band in relief round the belly
for x = 17, 47 do
  local y = 39 + floor(1.6 * sin((x - 17) * 0.62) + 0.5)
  if glz:has(x, y) then A.step(c, gidx, GLAZE, x, y, -2, gtok) end
  if glz:has(x, y - 1) then A.step(c, gidx, GLAZE, x, y - 1, 1, gtok) end
end
-- specular streak + cool reflected rim
local sp = X.spec(bn, 22)
glz:each(function(x, y) local s = sp[K(x, y)] or 0
  if s > 0.82 and y > 27 and y < 46 then c:put(x, y, s > 0.93 and "#f2d6ae" or GLAZE[6], gtok) end end)
glz:edge():each(function(x, y) local u = BU[K(x, y)] or 0 if u > 0.5 and y > 30 and y < 48 then c:put(x, y, "#5a4a5e", gtok) end end)

-- lip (top ring) and paste mound
local ltok, ptok = { r = { name = "lip" } }, { r = { name = "paste" } }
local lip = c:ellipse(32, 23, 11.5, 2.6)
local mouth = c:ellipse(32, 23, 9.2, 1.6)
local lipR = lip:copy():cut(mouth)
local ln = {}
lipR:each(function(x, y) local u = (x + .5 - 32) / 12 ln[K(x, y)] = { A.norm(u, y <= 22 and -0.7 or 0.4, 0.8) } end)
A.shade(c, lipR, ln, GLAZE, { tok = ltok, amb = 0.1, wrap = 0.3 })
for x = 22, 30 do if lipR:has(x, 21) then c:put(x, 21, GLAZE[6], ltok) end end
for x = 21, 43 do if lipR:has(x, 25) then c:put(x, 25, GLAZE[1], ltok) end end
local mound = c:ellipse(32, 21, 8.4, 4.2)
local pm = HP.mask()
mound:each(function(x, y) if y <= 22 then pm:set(x, y) end end)
pm:add(mouth)
local pn = X.pillow(pm, 3.2)
local pidx = A.shade(c, pm, pn, PASTE, { tok = ptok, amb = 0.12, wrap = 0.3 })
pm:each(function(x, y) local h = X.hash(x, y, 13)
  if h > 0.82 then A.step(c, pidx, PASTE, x, y, 1, ptok) if pm:has(x + 1, y + 1) then A.step(c, pidx, PASTE, x + 1, y + 1, -1, ptok) end
  elseif h < 0.1 then A.step(c, pidx, PASTE, x, y, -1, ptok) end end)
-- ambient where the paste meets the lip
mouth:each(function(x, y) if y == 24 then A.step(c, pidx, PASTE, x, y, -1, ptok) end end)

-- wooden paddle stuck in the paste
local wtok = { r = { name = "paddle" } }
local hm, hn, HT, HS = A.tube({ { 35, 20 }, { 38, 15 }, { 41, 12 }, { 44, 8 } }, function(t) return 1.15 + (t < 0.15 and 0.4 or 0) end)
local hidx = A.shade(c, hm, hn, WOOD, { tok = wtok, amb = 0.14, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y) if abs(HS[k] + 0.1) < 0.18 and HT[k] > 0.2 and HT[k] < 0.9 then A.step(c, hidx, WOOD, x, y, -1, wtok) end end)
c:put(44, 8, WOOD[6], wtok)
hm:grow(1):cut(hm):each(function(x, y) if pm:has(x, y) and y >= 18 then A.step(c, pidx, PASTE, x, y, -2, ptok) end end)

-- quirk: straw rope round the neck, chili tucked in
local rtok = { r = { name = "rope" } }
local rope = HP.mask()
for x = 20, 44 do
  local u = (x + .5 - 32) / 12
  if abs(u) <= 1 then
    local y = 27 + floor(1.6 * (1 - u * u) + 0.5)
    rope:set(x, y) rope:set(x, y + 1)
  end
end
rope:clip(bm)
rope:each(function(x, y)
  local u = (x + .5 - 32) / 12
  local base = u < -0.3 and 4 or (u < 0.4 and 3 or 2)
  local q = (x + (rope:has(x, y - 1) and 1 or 0)) % 3
  c:put(x, y, STRAW[max(1, min(5, base + (q == 0 and 1 or (q == 2 and -1 or 0))))], rtok)
end)
rope:shift(0, 1):each(function(x, y) if glz:has(x, y) and not rope:has(x, y) then A.step(c, gidx, GLAZE, x, y, -1, gtok) end end)
-- chili hanging from the rope, front right
local ctok = { r = { name = "chili" } }
local cm, cn = A.tube({ { 37, 30 }, { 38, 35 }, { 41, 39 }, { 39, 44 } }, function(t) return 1.9 * (1 - t) ^ 0.7 + 0.2 end)
local cidx = A.shade(c, cm, cn, CHILI, { tok = ctok, amb = 0.1, wrap = 0.3 })
c:put(36, 32, CHILI[6], ctok) c:put(36, 33, CHILI[5], ctok)
A.dots(c, { { 36, 29 }, { 37, 29 }, { 38, 29 }, { 37, 28 } }, "#4a7a3a", ctok)
c:put(38, 28, "#7cb04e", ctok)
cm:shift(1, 1):each(function(x, y) if glz:has(x, y) and not cm:has(x, y) and not rope:has(x, y) then A.step(c, gidx, GLAZE, x, y, -1, gtok) end end)

A.save(c, NAME)

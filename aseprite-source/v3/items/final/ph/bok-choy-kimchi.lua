-- bok-choy-kimchi (Opus single pass, aR21_2). A slim glass jar packed with kimchi: chili-red brine, pale
-- bok choy stalk chunks coated in gochugaru, dark leaf folds, chili flakes and a scallion bit, all seen
-- through glass (cool tint, bright rim, pale streak on the lit side, violet shade side), an air gap under a
-- knurled tin lid with a bevel and specular, ambient shading under the lid, 2-tone ground shadow.
-- quirk: a fermentation bubble has squeezed out from under the lid.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new2("bok-choy-kimchi")
local RED   = { "#561424", "#842028", "#b2302a", "#d64c2e", "#ef7638", "#ffaa66" }
local CHUNK = { "#963826", "#c45c36", "#e58c4c", "#f4b470", "#ffd89a", "#fff0c8" }
local GRN   = { "#2a3a1e", "#3f5626", "#5e7a30" }
local GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fdcdc", "#c2f2e4", "#eefcf4" }
local TIN   = { "#4a2a24", "#7a4628", "#b07032", "#d99a3e", "#f2c462", "#fff0b0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
c:groundShadow(32, 55, 15, 2)
local bx0, bx1 = 19, 45
local body = HP.rrect(bx0, 22, bx1, 54, 4)
local neck = HP.rect(22, 19, 42, 22)
local jar = body:copy():add(neck)
local inner = body:shrink(2)
local fillTop = 27
-- glass base pass (vertical cylinder light)
local gn = {}
jar:each(function(x, y) local t = max(-.97, min(.97, ((x - bx0) / (bx1 - bx0)) * 2 - 1)) gn[K(x, y)] = { t, 0, math.sqrt(1 - t*t) } end)
local gv = X.light(gn, { amb = 0.15, wrap = 0.4 })
local gtok = { r = { name = "glass" } }
X.tone(c, jar, gv, { GLASS[2], GLASS[3], GLASS[4], GLASS[4], GLASS[5], GLASS[5] }, { cuts = CUTS, tok = gtok })
-- contents
local cont = HP.mask()
inner:each(function(x, y) if y >= fillTop then cont:set(x, y) end end)
local cn = {}
cont:each(function(x, y) local t = max(-.95, min(.95, ((x - bx0 - 2) / (bx1 - bx0 - 4)) * 2 - 1)) cn[K(x, y)] = { t * 0.8, 0, 0.7 } end)
local cv = X.light(cn, { amb = 0.1, wrap = 0.35 })
local ctok = { r = { name = "kimchi" } }
X.tone(c, cont, cv, RED, { cuts = { 0.15, 0.3, 0.5, 0.68, 0.86 }, tok = ctok })
-- stalk chunks: lit rounded slabs; leaf folds between them
local chunks = { {26, 31, 3.6, 2.0, 0.5}, {37, 30, 3.8, 1.8, -0.4}, {31, 37, 4.2, 2.0, 0.15}, {24, 43, 3.2, 2.1, -0.6},
                 {38, 42, 3.8, 2.0, 0.6}, {30, 48, 4.0, 1.9, -0.2}, {40, 49, 2.6, 1.7, 0.3} }
local folds = { {33, 33, 3, 1.2, 0.3}, {28, 41, 2.6, 1.1, -0.2}, {35, 46, 3, 1.1, 0.4}, {22, 49, 2.2, 1, 0.5} }
for _, f in ipairs(folds) do
  local fm = A.rell(f[1], f[2], math.cos(f[5]), math.sin(f[5]), f[3], f[4]):clip(cont)
  fm:each(function(x, y) c:put(x, y, (y <= f[2] - 1) and GRN[3] or GRN[2], ctok) end)
  fm:edge():each(function(x, y) if y > f[2] then c:put(x, y, GRN[1], ctok) end end)
end
for _, ch in ipairs(chunks) do
  local m, n = A.oval(ch[1], ch[2], ch[3], ch[4], ch[5], 0.6)
  m:clip(cont)
  local bias = {}
  local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), CHUNK, { cuts = CUTS, tok = ctok })
  -- coating: red gochugaru flecks, dark separation below
  m:each(function(x, y) local h = X.hash(x, y, 17)
    if h > 0.72 then c:put(x, y, RED[(h > 0.88) and 3 or 4], ctok) end end)
  A.ring(m):each(function(x, y) if cont:has(x, y) and y >= ch[2] then c:put(x, y, RED[1], ctok) end end)
end
-- chili flakes + scallion bit
for i = 1, 14 do local x, y = bx0 + 3 + floor(X.hash(i, 1, 41) * 21), fillTop + 2 + floor(X.hash(i, 2, 41) * 24)
  if cont:has(x, y) then c:put(x, y, (i % 3 == 0) and "#7a1420" or RED[5], ctok) end end
c:put(34, 40, "#9ccc52", ctok) c:put(35, 40, "#c4e07a", ctok) c:put(35, 41, "#6a9a3a", ctok)
-- brine surface: meniscus row + little bubbles
for x = bx0 + 2, bx1 - 2 do c:put(x, fillTop, (x < 30) and RED[6] or RED[5], ctok) end
c:put(29, fillTop + 1, GLASS[6], ctok) c:put(40, fillTop + 1, GLASS[5], ctok)
-- glass overlay: bright rim on the lit side, deep on the shade side, pale core streak, base thickness
local gl = { r = { name = "glass" } }
jar:edge():each(function(x, y)
  if x <= bx0 + 1 or y <= 19 then c:put(x, y, GLASS[6], gl)
  elseif x >= bx1 - 1 then c:put(x, y, GLASS[1], gl)
  else c:put(x, y, GLASS[3], gl) end end)
for y = 24, 51 do
  if y ~= 38 and y ~= 39 then c:put(bx0 + 3, y, GLASS[6], gl) end
  if y > 26 and y < 45 then c:put(bx0 + 4, y, GLASS[5], gl) end
end
for y = 28, 50 do c:put(bx1 - 2, y, (y % 7 == 0) and GLASS[3] or "#5a3a70", gl) end
for x = bx0 + 3, bx1 - 3 do c:put(x, 53, (x < 28) and GLASS[5] or GLASS[3], gl) end
c:put(bx0 + 3, 25, "#fff4d6", gl)
-- shoulder: glass step where the neck meets the body
for x = 22, 42 do c:put(x, 22, (x < 28) and GLASS[6] or GLASS[3], gl) end
-- tin lid: knurled band with bevel; AO on the neck below it
local lid = HP.rrect(21, 12, 43, 18, 1)
local lt = { r = { name = "lid" } }
local ln = {}
lid:each(function(x, y) local t = max(-.97, min(.97, ((x - 21) / 22) * 2 - 1)) ln[K(x, y)] = { t, (y == 12) and -0.8 or 0, 0.6 } end)
local lidx = X.tone(c, lid, X.light(ln, { amb = 0.1, wrap = 0.3 }), TIN, { cuts = CUTS, tok = lt })
lid:each(function(x, y) local k = K(x, y)
  if y >= 14 and y <= 17 and x % 2 == 0 then c:put(x, y, TIN[max(1, lidx[k] - 1)], lt) end
  if y == 13 then c:put(x, y, TIN[min(6, lidx[k] + 1)], lt) end
  if y == 18 then c:put(x, y, TIN[1], lt) end end)
c:put(25, 13, "#fff4d6", lt) c:put(26, 13, TIN[6], lt) c:put(27, 13, TIN[6], lt)
for x = 22, 42 do c:put(x, 19, GLASS[2], gl) end
-- quirk: fermentation bubble escaping from under the lid
local bub = c:ellipse(47, 12, 2, 2)
bub:each(function(x, y) c:put(x, y, GLASS[4], { r = { name = "bub" } }) end)
c:put(46, 11, GLASS[6]) c:put(48, 13, GLASS[2]) c:put(47, 12, GLASS[5])
c:put(45, 16, GLASS[5], { r = { name = "bub2" } })
A.save2(c, "bok-choy-kimchi")

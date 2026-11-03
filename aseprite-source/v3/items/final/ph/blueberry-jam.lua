-- blueberry-jam (final, Opus single pass). A slim glass jar of deep violet-blue jam: glass wall rim, tall specular
-- streak and cool reflected edge, whole berries suspended in the jam, a clear headspace with a lit meniscus. A cream
-- paper label wraps the cylinder (painted berry trio, sprig, handwritten line). A puffed gingham cloth cap is cinched
-- by twisted twine with a bow, the skirt flares in folds to a pinked hem. Two-tone ground shadow.
-- quirk: one glossy drip of jam has escaped under the cloth and is crawling down onto the label.
local NAME = "blueberry-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local norm = A.norm
local JAM = { "#170e2c", "#241645", "#352263", "#4a3284", "#6650aa", "#9884d8" }
local GLASS = { "#4e5a8a", "#7886b8", "#a8b6e0", "#d4def6", "#eef3ff" }
local PAPER = { "#8c7052", "#b89c74", "#dcc59b", "#f1e2ba", "#fff4d6" }
local BER = { "#1c2258", "#2e3a8c", "#4a5cc0", "#7c92e6" }
local GL = { { "#8a84b6", "#b6b2da", "#dcd8f2", "#f4f0fe" }, { "#55489a", "#7a6cc0", "#a196e6", "#c2b8f4" }, { "#2c2262", "#413588", "#5a4eae", "#7a6ecc" } }
local TW = { "#5e3c22", "#9a6a3e", "#cc9e60", "#f0d49a" }

-- vertical cylinder normals across x0..x1
local function vnorm(m, x0, x1, tilt)
  local n = {}
  m:each(function(x, y)
    local t = max(-0.95, min(0.95, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { norm(t, tilt and tilt(x, y) or 0, sqrt(1 - t*t)) }
  end)
  return n
end

c:groundShadow(32, 57, 15, 1.6)

-- glass body
local JX0, JX1 = 19, 44
local body = c:rrect(JX0, 25, JX1, 56, 5)
local inner = body:shrink(1)
local wall = body:copy():cut(inner)
local JTOP = 30                                          -- jam level
local jam = inner:copy() jam:each(function(x, y) if y < JTOP then jam.s[K(x, y)] = nil end end)
local head = inner:copy():cut(jam)
local gtok, jtok = { r = { name = "glass" } }, { r = { name = "jam" } }
local bn = vnorm(body, JX0, JX1, function(x, y) return y > 52 and 0.35 or (y < 28 and -0.3 or 0) end)
-- jam (seen through glass): cylinder light, darker overall
local jidx = A.shade(c, jam, bn, JAM, { tok = jtok, cuts = { 0.18, 0.4, 0.6, 0.78, 0.94 }, amb = 0.05, wrap = 0.2 })
-- jam surface meniscus
for x = JX0 + 1, JX1 - 1 do if jam:has(x, JTOP) then c:put(x, JTOP, x < 33 and JAM[6] or JAM[5], jtok) end end
-- headspace glass
A.shade(c, head, bn, GLASS, { tok = gtok, cuts = { 0.25, 0.5, 0.72, 0.9 }, amb = 0.2, wrap = 0.3 })
-- whole berries suspended in the jam
for i, b in ipairs{ { 24, 34 }, { 39, 33 }, { 26, 51 }, { 35, 52 }, { 41, 49 }, { 31, 33 } } do
  local bt = { r = { name = "berry" .. i } }
  local m = c:ellipse(b[1], b[2], 1.5, 1.5)
  m:clip(jam)
  m:each(function(x, y) local dx, dy = x - b[1], y - b[2]
    local i2 = (dx + dy < -0.5) and 3 or ((dx + dy > 0.5) and 1 or 2)
    if x > 36 then i2 = max(1, i2 - 1) end
    c:put(x, y, BER[i2], bt) end)
  if jam:has(b[1] - 1, b[2] - 1) and b[1] < 37 then c:put(b[1] - 1, b[2] - 1, BER[4], bt) end
  if jam:has(b[1], b[2] + 1) then c:put(b[1], b[2] + 1, JAM[1], bt) end       -- calyx pit
end
-- glass wall: bright left rim, cool right edge, thick base
wall:each(function(x, y)
  local col
  if x <= JX0 + 1 then col = GLASS[4] elseif x >= JX1 - 1 then col = GLASS[2]
  elseif y >= 55 then col = GLASS[2] elseif y <= 26 then col = GLASS[4] else col = GLASS[3] end
  if y >= 54 and x > JX0 + 1 and x < JX1 - 1 then col = (y == 54) and GLASS[3] or GLASS[2] end
  c:put(x, y, col, gtok)
end)
-- thick glass base band
for x = JX0 + 2, JX1 - 2 do c:put(x, 54, x < 33 and GLASS[3] or GLASS[2], gtok) end

-- label wraps the cylinder
local LX0, LX1, LY0, LY1 = JX0 + 1, JX1 - 1, 38, 47
local lab = c:rect(LX0, LY0, LX1, LY1)
-- deckled top/bottom edges
for x = LX0, LX1 do
  if X.hash(x, 1, 4) > 0.7 then lab.s[K(x, LY0)] = nil end
  if X.hash(x, 2, 4) > 0.7 then lab.s[K(x, LY1)] = nil end
end
local ltok = { r = { name = "label" } }
local lidx = A.shade(c, lab, bn, PAPER, { tok = ltok, cuts = { 0.14, 0.32, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
-- ambient dark row where label meets glass below
for x = LX0, LX1 do if lab:has(x, LY1) then A.step(c, lidx, PAPER, x, LY1, -1, ltok) end end
-- painted berry trio + sprig on the label
local art = {
  "......gg....",
  "..bb.gg.....",
  ".bBBb.g.bb..",
  ".bBbbb.bBBb.",
  ".bbdbBBbbdb.",
  "..bbbBbbbb..",
  "....bdbb....",
}
local AM = { b = BER[2], B = BER[3], d = BER[1], g = "#4f9a4c" }
for j, row in ipairs(art) do for i = 1, #row do local ch = row:sub(i, i)
  if AM[ch] then c:put(26 + i - 1, LY0 + 1 + j - 1, AM[ch], ltok) end end end
-- handwritten line
for _, x in ipairs{ 24, 25, 27, 28, 29, 31, 32, 34, 35, 36, 38 } do c:put(x, LY1 - 1, x > 36 and "#8a6c86" or "#6a4a6e", ltok) end

-- glass specular streaks (in front of everything glassy, not over the label)
for y = 28, 53 do if y < LY0 - 1 or y > LY1 + 1 then c:put(JX0 + 3, y, GLASS[5], gtok) if y % 7 < 4 then c:put(JX0 + 4, y, GLASS[4], gtok) end end end
for y = 31, 52 do if y < LY0 - 1 or y > LY1 + 1 then c:put(JX1 - 3, y, "#6f7cb8", gtok) end end

-- gingham cloth: puff over the lid, cinched by twine, skirt flaring to a pinked hem
local puff = c:rrect(18, 11, 45, 20, 4)
local skirt = c:poly{ { 21, 20 }, { 42, 20 }, { 48, 29 }, { 15, 29 } }
-- pinked hem (zigzag) on the skirt bottom
for x = 14, 49 do
  local z = (x % 3 == 0) and 0 or ((x % 3 == 1) and 1 or 2)
  for y = 29 - z + 1, 30 do skirt.s[K(x, y)] = nil end
end
local cloth = puff:copy():add(skirt)
local ctok = { r = { name = "cloth" } }
local pn = X.pillow(puff, 3.5)
local sn = vnorm(skirt, 15, 48, function() return 0.25 end)
local cn = {}
for k, v in pairs(sn) do cn[k] = v end
for k, v in pairs(pn) do cn[k] = v end
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
-- fold creases on the skirt (radiating from the tie)
local function crease(x, y)
  if not skirt:has(x, y) or puff:has(x, y) then return 0 end
  for _, f in ipairs{ { 24, -0.35 }, { 31, 0.0 }, { 38, 0.35 } } do
    local fx = f[1] + (y - 20) * (f[2] * 2.2)
    if abs(x - fx) < 0.6 then return -1 end
    if abs(x - fx - 1) < 0.6 then return 1 end
  end
  return 0
end
cloth:each(function(x, y) local k = K(x, y)
  local sx, sy = floor((x - 18) / 3) % 2 == 0, floor((y - 11) / 3) % 2 == 0
  local g = (sx and sy) and 3 or ((sx or sy) and 2 or 1)
  local v = cv[k] or 0.5
  local i = v > 0.78 and 4 or (v > 0.52 and 3 or (v > 0.3 and 2 or 1))
  if skirt:has(x, y) and not puff:has(x, y) and y <= 21 then i = 1 end   -- tucked under the tie
  i = max(1, min(4, i + crease(x, y)))
  c:put(x, y, GL[g][i], ctok)
end)
-- AO: puff underside row above tie
for x = 18, 45 do if puff:has(x, 20) then c:put(x, 20, GL[3][1], ctok) end end
-- shadow cast by the skirt onto the glass shoulder
for x = JX0, JX1 do for y = 30, 31 do if body:has(x, y) and not cloth:has(x, y) and (y == 30 or x % 2 == 0) then
  local k = K(x, y) if jam:has(x, y) then c:put(x, y, JAM[1], jtok) else c:put(x, y, GLASS[1], gtok) end end end end

-- twine: twisted band + bow on the right with dangling ends
local twtok = { r = { name = "twine" } }
for x = 20, 43 do for y = 20, 21 do
  local lit = x < 32
  local tw = (x + y * 2) % 3
  local i = tw == 0 and 1 or (tw == 1 and (lit and 3 or 2) or (lit and 4 or 3))
  c:put(x, y, TW[i], twtok)
end end
local bow = {
  ".TT...TT.",
  "TttT.TttT",
  "TtwtKttwT",
  ".TTtKtTT.",
  "....K....",
  "...t.t...",
  "..t...t..",
  "..t....t.",
  ".w.....w.",
}
local BM = { T = TW[2], t = TW[3], w = TW[4], K = TW[1] }
for j, row in ipairs(bow) do for i = 1, #row do local ch = row:sub(i, i)
  if BM[ch] then c:put(38 + i - 1, 17 + j - 1, BM[ch], twtok) end end end

-- quirk: jam drip escaping under the cloth, running down the glass onto the label top
local dtok = { r = { name = "drip" } }
for y = 29, 38 do c:put(26, y, JAM[3], dtok) c:put(27, y, y < 36 and JAM[4] or JAM[3], dtok) end
for _, q in ipairs{ { 25, 39, 3 }, { 26, 39, 4 }, { 27, 39, 3 }, { 28, 39, 2 }, { 25, 40, 2 }, { 26, 40, 3 }, { 27, 40, 2 }, { 26, 41, 2 } } do c:put(q[1], q[2], JAM[q[3]], dtok) end
c:put(26, 31, JAM[6], dtok) c:put(25, 39, JAM[6], dtok)
-- the drip's contact shadow on the label
c:put(28, 40, PAPER[2], ltok) c:put(27, 41, PAPER[2], ltok)

A.save(c, NAME)

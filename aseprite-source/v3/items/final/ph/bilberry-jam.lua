-- bilberry-jam (final, Opus single pass). A tall slim glass jar of deep blue-violet jam with a sage linen cover
-- tied on with twisted twine and a bow, and a paper label wrapped round the middle.
-- Material: per-pixel cylinder light. Glass: pale rim walls, bright vertical specular streak, cool edge rim,
-- headspace showing the pale glass core, a lit meniscus. Jam: 6-tone violet, berry-skin flecks. Linen: pillowed
-- puff with diagonal weave and pinked hem folds. Twine: 2-tone twist. Label: cream paper with a berry stamp.
-- AO where the cover meets the glass; 2-tone ground shadow.
-- quirk: a drip of jam has escaped from under the cover and is running down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("bilberry-jam")
local JAM   = { "#1c1236", "#2c1a58", "#432a80", "#5c3ea4", "#7f62c4", "#b49ae6" }
local GLASS = { "#4a6a8e", "#7ea6c2", "#b4d8e4", "#e4f6f4" }
local LIN   = { "#24443e", "#3a6650", "#56885e", "#78a870", "#a2c88a", "#d2e8b0" }
local TW    = { "#6e4a2a", "#b98a4e", "#e2bd7a" }
local PAP   = { "#8a6a52", "#c9a882", "#e8d2a6", "#fbeccc", "#fff4d6" }
local CX = 32
local x0, x1 = CX - 10, CX + 9      -- glass 20 px wide
c:groundShadow(CX, 54, 13, 3)
-- glass body (rounded bottom) + shoulder to neck
local glass = c:rrect(x0, 22, x1, 52, 3)
glass:add(c:rect(x0 + 1, 20, x1 - 1, 23)):add(c:rect(x0 + 2, 18, x1 - 2, 21))
local function cyl(m, xa, xb)
  local n = {}
  m:each(function(x, y) local s = max(-0.96, min(0.96, ((x + 0.5 - xa) / (xb + 1 - xa)) * 2 - 1))
    n[K(x, y)] = { s, 0, sqrt(1 - s * s) } end)
  return n
end
local gtok = { r = { name = "glass" } }
local gn = cyl(glass, x0, x1)
-- walls
local gv = X.light(gn, { amb = 0.2, wrap = 0.4 })
X.tone(c, glass, gv, GLASS, { cuts = { 0.35, 0.6, 0.85 }, tok = gtok })
-- jam inside
local jam = glass:copy():shrink(1)
local jt = HP.mask() jam:each(function(x, y) if y >= 28 then jt:set(x, y) end end) jam = jt
local jtok = { r = { name = "jam" } }
local jb = {}
jam:each(function(x, y) if y >= 50 then jb[K(x, y)] = -1 end end)
local jidx = A.tone(c, jam, gn, JAM, { amb = 0.05, wrap = 0.25, bias = jb, tok = jtok })
-- headspace: pale glass core
for y = 20, 27 do for x = x0 + 2, x1 - 2 do if glass:has(x, y) and not glass:edge():has(x, y) then
  c:put(x, y, y == 20 and GLASS[2] or GLASS[3], gtok) end end end
-- meniscus
for x = x0 + 1, x1 - 1 do if jam:has(x, 28) then c:put(x, 28, x < CX + 3 and JAM[5] or JAM[4], jtok) end end
-- berry-skin flecks in the jam
jam:each(function(x, y) if y > 30 and y < 49 and X.hash(x, y, 9) > 0.93 then local i = jidx[K(x, y)] or 3 c:put(x, y, JAM[max(1, i - 2)], jtok) end end)
-- label (wraps round the middle)
local lab = c:rect(x0, 32, x1, 41)
lab:clip(glass)
local ltok = { r = { name = "label" } }
local lv = X.light(cyl(lab, x0, x1), { amb = 0.15, wrap = 0.35 })
X.tone(c, lab, lv, PAP, { cuts = { 0.22, 0.42, 0.65, 0.88 }, tok = ltok })
for x = x0, x1 do if lab:has(x, 32) then c:put(x, 32, PAP[2], ltok) end if lab:has(x, 41) then c:put(x, 41, PAP[1], ltok) end end
-- berry stamp on the label + a written line
c:paint({ ".gg..", "..g..", ".BBB.", "BBbBB", "BBBBB", ".BBB." }, CX - 5, 33, { g = LIN[3], B = JAM[3], b = JAM[5] })
c:put(CX - 4, 36, JAM[6])
for x = CX + 1, CX + 6 do c:put(x, 36, x == CX + 4 and PAP[3] or PAP[1], ltok) end
for x = CX + 1, CX + 4 do c:put(x, 38, PAP[1], ltok) end
-- glass specular streak (broken by the label) + cool right rim
for y = 22, 50 do if not lab:has(x0 + 2, y) then
  c:put(x0 + 2, y, (y >= 26 and y <= 29) and A.CREAM or GLASS[4], gtok)
  if y >= 25 and y <= 30 or y >= 43 and y <= 46 then c:put(x0 + 3, y, GLASS[3], gtok) end
end end
for y = 24, 49 do if not lab:has(x1 - 1, y) and y % 7 ~= 0 then c:put(x1 - 1, y, GLASS[2], gtok) end end
-- bottom thick glass
for x = x0 + 2, x1 - 2 do c:put(x, 51, GLASS[2], gtok) c:put(x, 52, GLASS[1], gtok) end
c:put(x0 + 3, 51, GLASS[4], gtok)

-- linen cover: puffed cap + pinked skirt
local cap = c:ellipse(CX - 0.5, 15, 9.5, 6)
local cut = HP.mask() cap:each(function(x, y) if y > 17 then cut:set(x, y) end end) cap:cut(cut)
local skirt = HP.mask()
for y = 16, 24 do
  local hw = 9.5 + (y - 16) * 0.4
  for x = floor(CX - hw), floor(CX + hw - 1) do
    local hem = 22 + ((x % 3 == 0) and 2 or ((x % 3 == 1) and 1 or 0))   -- pinked zigzag
    if y <= hem then skirt:set(x, y) end
  end
end
local ctok = { r = { name = "linen" } }
local cn = X.pillow(cap, 3.5)
local cb = {}
local sn = cyl(skirt, CX - 11, CX + 10)
for k, v in pairs(sn) do
  local x = k % 1024 - 256
  local f = sin((x - CX) * 1.1) * 0.35
  sn[k] = { A.norm(v[1] + f, 0.15, v[3]) }
end
X.ao(cb, skirt, glass, 0, 0)
A.tone(c, skirt, sn, LIN, { amb = 0.1, wrap = 0.3, tok = ctok })
A.tone(c, cap, cn, LIN, { amb = 0.1, wrap = 0.3, tok = ctok })
-- diagonal weave on the cap and skirt
cap:copy():add(skirt):each(function(x, y) if (x + y) % 4 == 0 then
  local cur = c:get(x, y) for i = 2, 6 do if cur == LIN[i] then c:put(x, y, LIN[i - 1], ctok) end end end end)
-- AO line where the skirt hem lies on the glass
skirt:each(function(x, y) if not skirt:has(x, y + 1) then c:put(x, y, LIN[1], ctok) end end)
glass:each(function(x, y) if skirt:has(x, y - 1) and not skirt:has(x, y) then c:put(x, y, GLASS[1], gtok) end end)
-- twine band with twist
for x = CX - 10, CX + 9 do
  local hi = (x % 2 == 0)
  c:put(x, 17, hi and TW[3] or TW[2]) c:put(x, 18, hi and TW[2] or TW[1])
end
-- bow on the right
c:paint({ "aab.ba", "abbkbb", ".akka.", "..ak..", "..a.k.", ".a...k" }, CX + 6, 15,
  { a = TW[2], b = TW[3], k = TW[1] })
-- cap glint
c:put(CX - 5, 11, LIN[6], ctok) c:put(CX - 4, 11, LIN[6], ctok)

-- quirk: jam drip on the glass, left front
local drip = { {26, 25, 3}, {26, 26, 4}, {27, 26, 2}, {26, 27, 4}, {27, 27, 2}, {25, 28, 4}, {26, 28, 5}, {27, 28, 2}, {25, 29, 3}, {26, 29, 3}, {27, 29, 1}, {26, 30, 1} }
for x = 25, 27 do c:put(x, 24, JAM[2]) end
for _, d in ipairs(drip) do c:put(d[1], d[2], JAM[d[3]]) end
A.fin(c, "bilberry-jam")

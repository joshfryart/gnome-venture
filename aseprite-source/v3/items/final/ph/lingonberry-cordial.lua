-- lingonberry-cordial (Opus artist pass). A tall slim glass bottle (long neck, sloped shoulders) filled with deep
-- ruby cordial; light glows through the lower-right of the liquid, the empty neck shows pale glass. Glass cues: bright
-- left streak, beveled lip ring, cool reflected edge, thick base. Speckled cork stopper (pores, pale top). Twine
-- wound twice round the neck (twist). Kraft label with a three-berry motif. Ground shadow.
-- quirk: a little lingonberry sprig (two berries, two leaves) is tucked under the neck twine.
local NAME = "lingonberry-cordial"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_4.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = D.new(NAME)
local RUBY  = { "#3a0a20", "#5e1028", "#861834", "#b0243c", "#d8404a", "#f47a6c" }
local GLASS = { "#5a6a84", "#8ea4bc", "#bcd2e0", "#e2f0f4" }
local CORK  = { "#5e3e24", "#8a6038", "#b48650", "#d4aa72", "#ecd09a" }
local TW    = { "#5e3e24", "#8e6438", "#c09460", "#e6c690" }
local PAPER = { "#8e6a44", "#b48e60", "#d4b282", "#ecd4a6" }
local LEAF  = D.LEAF
local gt, kt, twt = D.tok("glass"), D.tok("cork"), D.tok("twine")

c:groundShadow(32, 57, 9, 1.3)
-- bottle silhouette
local btl = c:rrect(25, 34, 38, 56, 3)
btl:add(c:poly{ { 25, 37 }, { 27, 31 }, { 29, 28 }, { 34, 28 }, { 36, 31 }, { 38, 37 } })
btl:add(c:rect(29, 18, 34, 29))
D.tone(c, btl, D.vcylN(btl, 25, 38), GLASS, { amb = 0.2, wrap = 0.35, tok = gt })
-- lip ring (bevel)
local lip = c:rect(28, 15, 35, 17)
D.tone(c, lip, X.pillow(lip, 1.5), GLASS, { amb = 0.25, wrap = 0.35, tok = gt })
for x = 29, 34 do c:put(x, 18, GLASS[1], gt) end                                          -- AO under the lip
-- cordial
local fill = btl:copy():shrink(1)
do local cut = {} fill:each(function(x, y) if y < 30 or y > 54 then cut[#cut + 1] = K(x, y) end end) for _, k in ipairs(cut) do fill.s[k] = nil end end
local fb = {}
c:ellipse(34.5, 47, 2.5, 5):each(function(x, y) if fill:has(x, y) then fb[K(x, y)] = 2 end end)  -- glow through
fill:each(function(x, y) if y <= 33 then fb[K(x, y)] = (fb[K(x, y)] or 0) - 1 end end)
D.tone(c, fill, D.vcylN(fill, 26, 37), RUBY, { amb = 0.12, wrap = 0.35, bias = fb, tok = gt })
for x = 26, 37 do if fill:has(x, 30) then c:put(x, 30, x < 31 and RUBY[5] or RUBY[4], gt) end end  -- meniscus
-- thick base
for x = 26, 37 do if btl:has(x, 55) then c:put(x, 55, x < 30 and GLASS[4] or GLASS[3], gt) c:put(x, 54, GLASS[2], gt) end end
-- label (kraft) with berry motif
local lab = c:rect(25, 40, 38, 48)
D.tone(c, lab, D.vcylN(lab, 25, 38), PAPER, { amb = 0.3, wrap = 0.4, tok = D.tok("label") })
for x = 25, 38 do c:put(x, 49, RUBY[1], gt) end
local lt = D.tok("label")
for x = 26, 37 do if x % 2 == 0 then c:put(x, 41, PAPER[2], lt) c:put(x, 47, PAPER[2], lt) end end     -- deckled print border
for _, b in ipairs{ { 29, 45 }, { 32, 45 }, { 30.5, 43 } } do
  local bx, by = floor(b[1]), b[2]
  c:put(bx, by, RUBY[4], lt) c:put(bx + 1, by, RUBY[3], lt) c:put(bx, by - 1, RUBY[5], lt) c:put(bx + 1, by - 1, RUBY[4], lt)
end
c:put(33, 42, LEAF[4], lt) c:put(34, 42, LEAF[5], lt) c:put(34, 41, LEAF[3], lt)
-- glass streaks
for y = 35, 53 do if y < 40 or y > 49 then c:put(26, y, D.CREAM, gt) end end
for y = 20, 27 do c:put(30, y, GLASS[4], gt) end
for y = 33, 52 do if y < 40 or y > 49 then c:put(37, y, "#c8b8d8", gt) end end
c:put(27, 32, GLASS[4], gt) c:put(28, 30, GLASS[4], gt)                                    -- shoulder glint
-- cork
local cork = c:rect(29, 11, 34, 14)
cork:add(c:rect(28, 9, 35, 11))
D.tone(c, cork, D.vcylN(cork, 28, 35), CORK, { amb = 0.15, wrap = 0.3, tok = kt })
for x = 29, 34 do c:put(x, 9, x < 32 and CORK[5] or CORK[4], kt) end                        -- pale cut top
for _, p in ipairs{ { 30, 12 }, { 33, 11 }, { 31, 14 }, { 34, 13 }, { 29, 10 } } do c:put(p[1], p[2], CORK[1], kt) end   -- pores
for x = 29, 34 do c:put(x, 12, x == 30 and CORK[1] or c:get(x, 12), kt) end
-- twine wound round the neck (twist)
for _, y in ipairs{ 22, 24 } do
  for x = 29, 34 do c:put(x, y, (x + y) % 3 == 0 and TW[1] or ((x + y) % 3 == 1 and TW[3] or TW[2]), twt) end
end
for x = 29, 34 do c:put(x, 23, GLASS[1], gt) end
-- quirk: lingonberry sprig tucked under the twine
local st = D.tok("sprig")
D.line(c, { { 33, 23 }, { 37, 20 }, { 40, 16 } }, "#6e4a30", st)
local function lf(x0, y0, x1, y1, cx, cy)
  local m, n, T, S = G.blade(x0, y0, cx, cy, x1, y1, function(t) if t > 0.96 then return -1 end return max(0.4, 1.8 * math.sin(math.pi * min(1, t + 0.08)) ^ 0.6) end, { fold = 0.3 })
  m:cut(c:rect(29, 18, 34, 29))
  D.tone(c, m, n, LEAF, { amb = 0.14, wrap = 0.3, tok = st })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.2 and T[k] > 0.2 and T[k] < 0.8 then c:put(x, y, LEAF[6], st) end end)
end
lf(38, 18, 44, 13, 41, 14)
lf(39, 17, 37, 10, 37, 13)
local BER = { "#4a0c22", "#7a1430", "#a81e36", "#d02e3c", "#ec5248", "#ff8c72" }
for _, b in ipairs{ { 39.5, 22.5 }, { 42.5, 19 } } do
  local m, n, tok = D.berry(c, b[1], b[2], 2, BER, { tok = st })
  c:put(floor(b[1] - 0.7), floor(b[2] - 0.7), D.CREAM, st)
end
D.save(c, NAME)

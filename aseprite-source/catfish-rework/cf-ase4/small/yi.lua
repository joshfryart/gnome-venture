-- yi.lua: 15 Yarn panel icons 64x64 (names from the old PNGs), Hearth Pop: 1px ink, 6-tone ramps, upper-left light
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/sm.lua")
local H, L, part, px, sep = S.H, S.L, S.part, S.px, S.sep
local R = H.R
local PINK, GREEN, SISAL, CREAM, TERRA, GOLD, WOOD, BLUE, PLUM, ORANGE, RED, BROWN, STEEL, VIOLET, NAVY, TEAL, SILVER =
  H.PINK, H.GREEN, H.SISAL, H.CREAM, H.TERRA, H.GOLD, H.WOOD, H.BLUE, H.PLUM, H.ORANGE, H.RED, H.BROWN, H.STEEL, H.VIOLET, H.NAVY, H.TEAL, H.SILVER
local CAT = S.CAT
local SKIN = R("#8a4a3a", "#b8745a", "#e0a080", "#f0b898", "#f8d0b4", "#fff0e4")
local floor, sin, cos, abs, pi, min, max = S.floor, S.sin, S.cos, S.abs, S.pi, S.min, S.max
local N = function() return S.new(64, 64) end
local function lineIn(c, m, pts, col) L.line(pts):each(function(x, y) if m:has(x, y) then c:put(x, y, col, "detail") end end) end
local function line(c, pts, col) L.line(pts):each(function(x, y) c:put(x, y, col, "detail") end) end
local function stitch(c, m, col, mod)
  local inner = m:copy():cut(m:edge())
  inner:edge():each(function(x, y) if (x + y) % (mod or 4) < 2 then c:put(x, y, col, "detail") end end)
end
local fin = function(c, n) H.finish(c, n) end

-- BALLS -----------------------------------------------------------------------------------------------------
do
  local c = N()
  S.ball(c, 32, 19, 10.5, GOLD, { ph = 1 })
  local th = L.tube({ { 40, 13 }, { 47, 8 }, { 54, 10 }, { 52, 17 }, { 47, 16 } }, function() return 1 end)
  part(c, th, GOLD, 1, 1, { lift = -1 })
  S.ball(c, 20, 42, 12.5, PINK, { ph = 0 }) sep(c, L.ellipse(20, 42, 12.5, 12.5))
  S.ball(c, 44, 43, 12.5, GREEN, { ph = -1, offs = { -0.6, -0.05, 0.5 } }) sep(c, L.ellipse(44, 43, 12.5, 12.5))
  S.spark(c, 55, 28, 2, GOLD.L, GOLD.g)
  fin(c, "cf-yi-balls")
end

-- BIO: scroll with a pink cat stamp, teal quill, little yarn ball -----------------------------------------------
do
  local c = N()
  local paper = H.rrect(15, 14, 44, 51, 2) part(c, paper, CREAM, 2, 2)
  stitch(c, paper, CREAM.b, 8)
  for i, y in ipairs({ 31, 35, 39, 43 }) do for x = 20, 34 - (i % 2) * 4 do if x % 5 ~= 4 then c:put(x, y, SISAL.s, "detail") end end end
  local roll1 = H.rrect(11, 8, 48, 17, 3) part(c, roll1, SISAL, 2, 2) sep(c, roll1)
  local roll2 = H.rrect(11, 49, 48, 57, 3) part(c, roll2, SISAL, 2, 2) sep(c, roll2)
  for _, x in ipairs({ 14, 45 }) do c:put(x, 12, SISAL.g, "detail") c:put(x, 53, SISAL.g, "detail") end
  -- cat stamp
  local hd = L.ellipse(25.5, 24.5, 4.6, 3.6) part(c, hd, PINK, 1, 1)
  part(c, L.poly({ { 21, 24 }, { 21, 19 }, { 25, 22 } }), PINK, 1, 1) part(c, L.poly({ { 30, 24 }, { 30, 19 }, { 26, 22 } }), PINK, 1, 1)
  px(c, { { 23, 24, '#' }, { 28, 24, '#' }, { 25, 26, PINK.D }, { 26, 26, PINK.D } })
  -- quill
  local shaft = L.tube({ { 49, 22 }, { 40, 52 } }, function() return 0.8 end)
  local vane = L.poly({ { 50, 20 }, { 57, 14 }, { 58, 26 }, { 50, 40 }, { 44, 46 }, { 46, 34 } })
  local vn = L.poly({ { 51, 21 }, { 60, 12 }, { 62, 28 }, { 52, 40 }, { 45, 48 }, { 46, 33 } })
  part(c, vn, TEAL, 2, 2) sep(c, vn)
  lineIn(c, vn, { { 49, 24 }, { 42, 50 } }, TEAL.g)
  lineIn(c, vn, { { 52, 27 }, { 57, 21 } }, TEAL.D) lineIn(c, vn, { { 51, 33 }, { 58, 27 } }, TEAL.D) lineIn(c, vn, { { 49, 38 }, { 55, 34 } }, TEAL.D)
  px(c, { { 41, 51, '#' } })
  S.ball(c, 46, 52, 5.5, PINK, { offs = { 0 } }) sep(c, L.ellipse(46, 52, 5.5, 5.5))
  fin(c, "cf-yi-bio")
end

-- BUDDY: orange cat + grey cat, heart, red yarn ------------------------------------------------------------------
do
  local c = N()
  local tail = L.tube({ { 50, 56 }, { 58, 52 }, { 59, 44 } }, function() return 1.8 end) part(c, tail, CAT, 1, 1, { ramp = nil })
  S.cat(c, 42, 33, CAT, { big = true })
  local sw = L.tube({ { 44, 51 }, { 49, 56 } }, function() return 1 end)
  S.cat(c, 21, 30, ORANGE, { big = true, hw = 9.5, hh = 8 })
  px(c, { { 17, 27, ORANGE.s }, { 18, 26, ORANGE.s }, { 21, 25, ORANGE.s }, { 22, 26, ORANGE.s }, { 24, 25, ORANGE.s } })
  -- heart
  local hm = L.ellipse(28.5, 9.5, 4.2, 4):add(L.ellipse(35.5, 9.5, 4.2, 4)):add(L.poly({ { 24.4, 11 }, { 39.6, 11 }, { 32, 19 } }))
  part(c, hm, RED, 2, 2) c:put(27, 7, RED.g, "detail") c:put(28, 6, RED.g, "detail")
  S.ball(c, 31, 56, 4.5, RED, { offs = { 0 } }) sep(c, L.ellipse(31, 56, 4.5, 4.5))
  fin(c, "cf-yi-buddy")
end

-- BUNTING --------------------------------------------------------------------------------------------------------
do
  local c = N()
  local function sag(x) local t = (x - 6) / 52 return 12 + 14 * (1 - (2 * t - 1) ^ 2) * 0.9 + 0 end
  local rope = L.mask() for x = 6, 58 do rope:set(x, floor(sag(x) + 0.5)) rope:set(x, floor(sag(x) + 0.5) + 1) end
  rope:each(function(x, y) c:put(x, y, WOOD.m, "detail") end)
  rope:each(function(x, y) if not rope:has(x, y - 1) then c:put(x, y, WOOD.L, "detail") end end)
  local cols = { RED, BLUE, GREEN, VIOLET, ORANGE }
  local xs = { 12, 22, 32, 42, 52 }
  for i, x in ipairs(xs) do
    local y0 = floor(sag(x) + 0.5) + 1
    local pn = L.poly({ { x - 5, y0 }, { x + 5, y0 }, { x, y0 + 20 - abs(i - 3) * 2 } })
    pn = L.poly({ { x - 5.5, y0 }, { x + 5.5, y0 }, { x + 0.5, y0 + 21 - abs(i - 3) * 2 } })
    part(c, pn, cols[i], 2, 2) sep(c, pn)
    lineIn(c, pn, { { x - 3, y0 + 3 }, { x + 1, y0 + 12 - abs(i - 3) } }, cols[i].L)
  end
  for _, x in ipairs({ 6, 58 }) do
    local k = L.ellipse(x, 11, 3, 3) part(c, k, GOLD, 1, 1)
  end
  S.spark(c, 32, 6, 2, GOLD.L, GOLD.g)
  fin(c, "cf-yi-bunting")
end

-- CATNIP: hourglass with catnip sand and two leaves -------------------------------------------------------------
do
  local c = N()
  local top = L.poly({ { 18, 14 }, { 46, 14 }, { 35, 31 }, { 29, 31 } })
  local bot = L.poly({ { 29, 33 }, { 35, 33 }, { 46, 51 }, { 18, 51 } })
  local neck = L.rect(30, 30, 33, 34)
  local glass = top:copy():add(bot):add(neck)
  part(c, glass, BLUE, 2, 2, { lift = 1 })
  -- sand: remaining on top (bottom of top bulb) and heap below
  local sandT = top:filter(function(x, y) return y >= 24 end)
  local sandB = bot:filter(function(x, y) return y >= 43 or (y >= 36 and abs(x - 32) <= (y - 36) * 0.6 + 0.5 and false) end)
  local heap = L.poly({ { 32, 38 }, { 43, 51 }, { 21, 51 } }):clip(bot)
  part(c, sandT, GREEN, 1, 1) part(c, heap, GREEN, 2, 2)
  for y = 33, 36 do c:put(32, y, GREEN.l, "detail") end
  -- highlights on glass
  line(c, { { 21, 16 }, { 28, 27 } }, BLUE.g) line(c, { { 21, 52 - 8 }, { 24, 48 } }, BLUE.g)
  local pt = H.rrect(14, 8, 49, 13, 2) part(c, pt, WOOD, 1, 2) sep(c, pt)
  local pb = H.rrect(14, 52, 49, 57, 2) part(c, pb, WOOD, 2, 1) sep(c, pb)
  for _, x in ipairs({ 17, 46 }) do for _, y in ipairs({ 10, 54 }) do c:put(x, y, WOOD.g, "detail") end end
  sep(c, glass)
  -- catnip leaves on top
  local l1 = H.leaf({ { 30, 8 }, { 24, 3 }, { 17, 3 } }, 2.6) part(c, l1, GREEN, 1, 1)
  local l2 = H.leaf({ { 34, 8 }, { 40, 2 }, { 47, 3 } }, 2.6) part(c, l2, GREEN, 1, 1, { lift = -1 })
  S.spark(c, 56, 20, 2, GOLD.L, GOLD.g) S.spark(c, 58, 34, 1, GOLD.L, GOLD.g)
  fin(c, "cf-yi-catnip")
end

-- COLLAR: pink collar ring, bow, bell, buckle, two beads ---------------------------------------------------------
do
  local c = N()
  local outer = L.ellipse(31.5, 27, 23, 14)
  local inner = L.ellipse(31.5, 25, 17, 8)
  local ring = outer:copy():cut(inner)
  part(c, ring, PINK, 3, 3)
  -- inside back of the band visible above the hole
  local back = inner:copy():filter(function(x, y) return y <= 25 and y >= 20 end):cut(L.ellipse(31.5, 25.5, 14, 5.5))
  back:each(function(x, y) c:put(x, y, PINK.b, "detail") end)
  stitch(c, ring, PINK.L, 4)
  -- buckle
  local bk = H.rrect(50, 20, 56, 31, 1) part(c, bk, GOLD, 1, 1) sep(c, bk)
  L.rect(52, 23, 54, 28):each(function(x, y) c:put(x, y, GOLD.D, "detail") end) c:put(53, 25, GOLD.l, "detail")
  -- bow
  local b1 = L.poly({ { 17, 33 }, { 9, 30 }, { 7, 40 }, { 15, 40 } }) part(c, b1, PINK, 1, 1, { lift = 1 })
  local b2 = L.poly({ { 20, 34 }, { 28, 31 }, { 29, 41 }, { 21, 40 } }) part(c, b2, PINK, 1, 1, { lift = 1 })
  local t1 = L.poly({ { 14, 39 }, { 20, 39 }, { 17, 52 }, { 11, 50 } }) part(c, t1, PINK, 1, 1, { lift = -1 })
  local kn = H.rrect(16, 33, 21, 40, 1) part(c, kn, PINK, 1, 1, { lift = 2 })
  sep(c, kn)
  -- bell
  local bell = L.ellipse(33, 46, 6, 6) part(c, bell, GOLD, 2, 2) sep(c, bell)
  L.rect(28, 45, 38, 45):each(function(x, y) c:put(x, y, GOLD.D, "detail") end)
  px(c, { { 33, 48, '#' }, { 33, 49, '#' }, { 31, 42, GOLD.g }, { 30, 43, GOLD.g } })
  -- beads
  local be = L.ellipse(45, 50, 4.5, 4.5) part(c, be, GREEN, 2, 2) sep(c, be) c:put(43, 48, GREEN.g, "detail")
  local bb = L.ellipse(54, 44, 4, 4) part(c, bb, BLUE, 2, 2) sep(c, bb) c:put(52, 42, BLUE.g, "detail")
  fin(c, "cf-yi-collar")
end

-- HOLD: a sleepy grey cat loaf cupped in two hands with red cuffs -------------------------------------------------
do
  local c = N()
  local loaf = L.ellipse(32, 29, 17, 11) part(c, loaf, CAT, 3, 3)
  local hd = L.ellipse(25, 28, 9, 7.5)
  local e1 = L.poly({ { 17, 25 }, { 18, 17 }, { 24, 22 } }) local e2 = L.poly({ { 33, 25 }, { 32, 17 }, { 26, 22 } })
  part(c, e1, CAT, 1, 1) part(c, e2, CAT, 1, 1)
  part(c, hd, CAT, 2, 2) sep(c, hd)
  L.poly({ { 19, 24 }, { 19, 19 }, { 23, 22 } }):each(function(x, y) c:put(x, y, S.NOSE, "detail") end)
  L.poly({ { 31, 24 }, { 31, 19 }, { 27, 22 } }):each(function(x, y) c:put(x, y, S.NOSE, "detail") end)
  px(c, { { 20, 28, '#' }, { 21, 29, '#' }, { 22, 29, '#' }, { 28, 28, '#' }, { 29, 29, '#' }, { 27, 29, '#' }, { 24, 31, S.NOSE }, { 25, 31, S.NOSE }, { 19, 31, S.NOSE }, { 31, 31, S.NOSE } })
  -- tail + yarn ball in paws
  local tl = L.tube({ { 46, 34 }, { 52, 30 }, { 51, 23 } }, function() return 2 end) part(c, tl, CAT, 1, 1) sep(c, tl)
  S.ball(c, 46, 36, 4.5, RED, { offs = { 0 } }) sep(c, L.ellipse(46, 36, 4.5, 4.5))
  px(c, { { 49, 40, RED.m }, { 51, 43, RED.m }, { 54, 44, RED.m } })
  -- cupped hands
  local h1 = L.ellipse(18, 43, 14.5, 9.5):add(L.ellipse(7, 40, 4, 5)):add(L.rect(8, 44, 28, 52))
  local h2 = L.ellipse(46, 43, 14.5, 9.5):add(L.ellipse(57, 40, 4, 5)):add(L.rect(36, 44, 56, 52))
  part(c, h1, SKIN, 3, 2) sep(c, h1) part(c, h2, SKIN, 3, 2) sep(c, h2)
  for _, x in ipairs({ 13, 19, 25, 39, 45, 51 }) do line(c, { { x, 36 }, { x, 40 } }, SKIN.s) end
  local c1 = H.rrect(3, 52, 31, 58, 2) part(c, c1, RED, 2, 2) sep(c, c1)
  local c2 = H.rrect(33, 52, 61, 58, 2) part(c, c2, RED, 2, 2) sep(c, c2)
  for x = 7, 28, 6 do line(c, { { x, 53 }, { x, 57 } }, "#ffd0a8") end
  for x = 36, 58, 6 do line(c, { { x, 53 }, { x, 57 } }, "#ffd0a8") end
  fin(c, "cf-yi-hold")
end

-- KEEPSAKE: gold locket with a paw print, pink bow --------------------------------------------------------------
do
  local c = N()
  local chain = L.tube({ { 24, 18 }, { 28, 8 }, { 36, 8 }, { 40, 18 } }, function() return 0.8 end) part(c, chain, GOLD, 1, 1)
  local lk = L.ellipse(31.5, 38, 18.5, 20.5) part(c, lk, GOLD, 3, 3)
  local ins = L.ellipse(31.5, 38, 14, 16) part(c, ins, NAVY, 3, 3) sep(c, ins)
  stitch(c, ins, NAVY.L, 5)
  local pad = L.ellipse(31.5, 42, 6.5, 5) part(c, pad, CREAM, 1, 1)
  for _, t in ipairs({ { 23, 35, 2.2 }, { 28, 31, 2.4 }, { 35, 31, 2.4 }, { 40, 35, 2.2 } }) do
    part(c, L.ellipse(t[1], t[2], t[3], t[3] + 0.4), CREAM, 1, 1)
  end
  for d = 0, 3 do c:put(15 + d, 24 - d, GOLD.g, "detail") end
  px(c, { { 47, 53, GOLD.D }, { 46, 55, GOLD.D }, { 44, 57, GOLD.D } })
  local bow1 = L.poly({ { 30, 14 }, { 20, 8 }, { 18, 18 }, { 30, 18 } }) part(c, bow1, PINK, 1, 1, { lift = 1 })
  local bow2 = L.poly({ { 34, 14 }, { 44, 8 }, { 46, 18 }, { 34, 18 } }) part(c, bow2, PINK, 1, 1, { lift = 1 })
  local kn = H.rrect(29, 12, 35, 19, 1) part(c, kn, PINK, 1, 1, { lift = 2 }) sep(c, kn)
  S.spark(c, 54, 22, 2, GOLD.L, GOLD.g)
  fin(c, "cf-yi-keepsake")
end

-- SCARF -----------------------------------------------------------------------------------------------------------
do
  local c = N()
  local ring = L.ellipse(31.5, 19, 23, 11):cut(L.ellipse(31.5, 18, 15, 5.5))
  part(c, ring, RED, 3, 3)
  local back = L.ellipse(31.5, 18, 15, 5.5):filter(function(x, y) return y <= 18 end)
  back:each(function(x, y) c:put(x, y, RED.D, "detail") end)
  line(c, { { 14, 19 }, { 20, 26 } }, RED.s) line(c, { { 49, 19 }, { 43, 26 } }, RED.s)
  local t1 = L.poly({ { 15, 24 }, { 30, 28 }, { 28, 54 }, { 10, 52 } }) part(c, t1, RED, 2, 2) sep(c, t1)
  local t2 = L.poly({ { 33, 28 }, { 47, 25 }, { 54, 50 }, { 36, 54 } }) part(c, t2, RED, 2, 2, { lift = -1 }) sep(c, t2)
  for _, b in ipairs({ { 42, 47 }, { 49, 53 } }) do end
  local function band(m, ya, yb, col) m:each(function(x, y) local f = (y - ya) if f >= 0 and f < 3 then c:put(x, y, col, "detail") end end) end
  band(t1, 40, 43, "#fff0d8") band(t1, 46, 49, "#fff0d8")
  band(t2, 41, 44, "#fff0d8") band(t2, 47, 50, "#fff0d8")
  for _, f in ipairs({ { 10, 28, 53 }, { 14, 24, 54 }, { 18, 21, 55 }, { 22, 25, 56 }, { 26, 28, 56 } }) do end
  for x = 11, 27, 3 do line(c, { { x, 53 - ((x - 11) // 8) }, { x, 57 - ((x - 11) // 8) } }, RED.m) end
  for x = 37, 53, 3 do line(c, { { x, 53 - ((x - 37) // 8) }, { x, 57 - ((x - 37) // 8) } }, RED.m) end
  fin(c, "cf-yi-scarf")
end

-- SEASON: four-quarter shield: petals / sun / leaf / snow -------------------------------------------------------------
do
  local c = N()
  local disc = L.ellipse(31.5, 31.5, 28.5, 28.5) part(c, disc, WOOD, 3, 3)
  local fld = L.ellipse(31.5, 31.5, 24.5, 24.5)
  local function quad(f, ramp) local m = fld:filter(f) part(c, m, ramp, 2, 2) return m end
  local sp = quad(function(x, y) return x < 32 and y < 32 end, GREEN)
  local su = quad(function(x, y) return x >= 32 and y < 32 end, BLUE)
  local au = quad(function(x, y) return x >= 32 and y >= 32 end, BROWN)
  local wi = quad(function(x, y) return x < 32 and y >= 32 end, VIOLET)
  for i = 8, 55 do c:put(i, 31, '#', "detail") c:put(i, 32, '#', "detail") end
  L.rect(31, 8, 32, 55):each(function(x, y) if fld:has(x, y) then c:put(x, y, '#', "detail") end end)
  -- inner lighter fill so the symbols read
  local function sym(f, m, ramp, ps) m:each(function(x, y) end) end
  -- spring: pink blossom
  for _, p in ipairs({ { 19, 17 }, { 18, 18 }, { 20, 18 }, { 19, 19 }, { 19, 18 }, { 15, 22 }, { 14, 23 }, { 16, 23 }, { 15, 24 }, { 24, 23 }, { 23, 24 }, { 25, 24 }, { 24, 25 } }) do
    c:put(p[1], p[2], PINK.l, "detail") end
  for _, p in ipairs({ { 19, 18 }, { 15, 23 }, { 24, 24 } }) do c:put(p[1], p[2], GOLD.l, "detail") end
  for _, p in ipairs({ { 19, 16 }, { 19, 20 }, { 17, 17 }, { 21, 19 } }) do c:put(p[1], p[2], PINK.m, "detail") end
  -- summer sun
  local sun = L.ellipse(44, 20, 5.5, 5.5)
  for a = 0, 7 do local ax, ay = floor(44 + 8.5 * cos(a * pi / 4) + 0.5), floor(20 + 8.5 * sin(a * pi / 4) + 0.5) c:put(ax, ay, GOLD.L, "detail") c:put(ax + (ax > 44 and -1 or ax < 44 and 1 or 0), ay + (ay > 20 and -1 or ay < 20 and 1 or 0), GOLD.l, "detail") end
  part(c, sun, GOLD, 1, 1)
  -- autumn leaf
  local lf = H.leaf({ { 38, 50 }, { 44, 42 }, { 52, 38 } }, 4.5) part(c, lf, ORANGE, 1, 1)
  line(c, { { 40, 48 }, { 50, 40 } }, ORANGE.D)
  -- winter snowflake
  for d = -6, 6 do c:put(20 + d, 44, "#e4f6ff", "detail") c:put(20, 44 + d, "#e4f6ff", "detail") if abs(d) <= 4 then c:put(20 + d, 44 + d, "#c9b2f0", "detail") c:put(20 + d, 44 - d, "#c9b2f0", "detail") end end
  c:put(20, 44, "#ffffff", "detail")
  -- rim studs
  for i = 0, 15 do local a = i * pi / 8 + 0.2 c:put(floor(31.5 + 27 * cos(a) + 0.5), floor(31.5 + 27 * sin(a) + 0.5), WOOD.g, "detail") end
  sep(c, fld)
  fin(c, "cf-yi-season")
end

-- SHOW2: two teal rosettes, one with a cat face, pink bow -------------------------------------------------------------
do
  local c = N()
  local function ros(cx, cy, r, ramp)
    local m = L.ellipse(cx, cy, r, r)
    for i = 0, 11 do local a = i * pi / 6 m:add(L.ellipse(cx + (r + 0.5) * cos(a), cy + (r + 0.5) * sin(a), 2.8, 2.8)) end
    return m
  end
  local rb1 = L.poly({ { 12, 40 }, { 22, 38 }, { 24, 58 }, { 17, 53 }, { 10, 58 } }) part(c, rb1, TEAL, 1, 1, { lift = -1 })
  local rb2 = L.poly({ { 40, 38 }, { 52, 40 }, { 54, 58 }, { 47, 53 }, { 40, 58 } }) part(c, rb2, TEAL, 1, 1, { lift = -1 })
  local m1 = ros(17, 21, 10.5) part(c, m1, TEAL, 2, 2) sep(c, L.ellipse(17, 21, 8.5, 8.5))
  local g1 = L.ellipse(17, 21, 5.5, 5.5) part(c, g1, GOLD, 1, 1) sep(c, g1) c:put(15, 19, GOLD.g, "detail")
  local m2 = ros(44, 24, 12.5) sep(c, L.ellipse(44, 24, 12.5, 12.5)) part(c, m2, TEAL, 2, 2) sep(c, L.ellipse(44, 24, 10, 10))
  local f2 = L.ellipse(44, 24, 7.5, 7.5) part(c, f2, CREAM, 1, 1) sep(c, f2)
  local ear = L.poly({ { 38, 21 }, { 38, 15 }, { 43, 18 } }) part(c, ear, CREAM, 1, 1) ear = L.poly({ { 50, 21 }, { 50, 15 }, { 45, 18 } }) part(c, ear, CREAM, 1, 1)
  px(c, { { 41, 23, '#' }, { 41, 24, '#' }, { 47, 23, '#' }, { 47, 24, '#' }, { 44, 26, PINK.m }, { 43, 27, '#' }, { 45, 27, '#' } })
  local bw1 = L.poly({ { 27, 52 }, { 17, 46 }, { 17, 57 } }) local bw2 = L.poly({ { 29, 52 }, { 39, 46 }, { 39, 57 } })
  part(c, bw1, PINK, 1, 1) part(c, bw2, PINK, 1, 1) local bk = H.rrect(26, 49, 30, 55, 1) part(c, bk, PINK, 1, 1, { lift = 2 }) sep(c, bk)
  fin(c, "cf-yi-show2")
end

-- STAKE: binoculars ---------------------------------------------------------------------------------------------------
do
  local c = N()
  local strap = L.tube({ { 14, 16 }, { 18, 6 }, { 32, 3 }, { 46, 6 }, { 50, 16 } }, function() return 1.4 end) part(c, strap, PINK, 1, 1)
  local ep1 = H.rrect(11, 10, 24, 20, 2) local ep2 = H.rrect(40, 10, 53, 20, 2)
  part(c, ep1, TEAL, 2, 2, { lift = -1 }) part(c, ep2, TEAL, 2, 2, { lift = -1 }) sep(c, ep1) sep(c, ep2)
  local b1 = H.rrect(7, 20, 28, 55, 6) local b2 = H.rrect(36, 20, 57, 55, 6)
  local br = H.rrect(24, 28, 40, 38, 2)
  part(c, br, TEAL, 2, 2, { lift = -1 })
  part(c, b1, TEAL, 3, 3) part(c, b2, TEAL, 3, 3) sep(c, b1) sep(c, b2)
  local fk = H.rrect(28, 22, 36, 30, 1) part(c, fk, GOLD, 1, 1) sep(c, fk) line(c, { { 30, 23 }, { 30, 28 } }, GOLD.D) line(c, { { 33, 23 }, { 33, 28 } }, GOLD.D)
  for _, cx in ipairs({ 17.5, 46.5 }) do
    local ring = L.ellipse(cx, 42, 8.5, 8.5) part(c, ring, GOLD, 2, 2) sep(c, L.ellipse(cx, 42, 6.5, 6.5))
    local gl = L.ellipse(cx, 42, 6.5, 6.5) part(c, gl, BLUE, 2, 2)
    px(c, { { cx - 3, 39, BLUE.g }, { cx - 2, 38, BLUE.g }, { cx - 3, 40, BLUE.L }, { cx - 1, 38, BLUE.L } })
  end
  fin(c, "cf-yi-stake")
end

-- TITLES: pennant banner with a crowned cat on a gold rod ---------------------------------------------------------------
do
  local c = N()
  local ban = L.poly({ { 12, 13 }, { 52, 13 }, { 52, 55 }, { 32, 47 }, { 12, 55 } }) part(c, ban, NAVY, 3, 3)
  stitch(c, ban, GOLD.m, 4)
  local fc = L.ellipse(32, 31, 10.5, 8.5)
  local e1 = L.poly({ { 22, 30 }, { 23, 20 }, { 28, 25 } }) local e2 = L.poly({ { 42, 30 }, { 41, 20 }, { 36, 25 } })
  part(c, e1, CREAM, 1, 1) part(c, e2, CREAM, 1, 1) part(c, fc, CREAM, 2, 2) sep(c, fc)
  px(c, { { 27, 31, '#' }, { 27, 32, '#' }, { 36, 31, '#' }, { 36, 32, '#' }, { 31, 34, S.NOSE }, { 32, 34, S.NOSE }, { 30, 36, '#' }, { 31, 37, '#' }, { 32, 37, '#' }, { 33, 36, '#' }, { 24, 34, S.NOSE }, { 39, 34, S.NOSE } })
  local cr = L.poly({ { 24, 24 }, { 24, 15 }, { 28, 19 }, { 32, 13 }, { 36, 19 }, { 40, 15 }, { 40, 24 } }) part(c, cr, GOLD, 1, 1) sep(c, cr)
  px(c, { { 28, 21, RED.m }, { 32, 20, BLUE.m }, { 36, 21, RED.m } })
  local rod = H.rrect(6, 8, 58, 13, 2) part(c, rod, GOLD, 1, 1) sep(c, rod)
  for _, x in ipairs({ 6, 57 }) do local k = L.ellipse(x, 10.5, 3.2, 3.2) part(c, k, PINK, 1, 1) sep(c, k) end
  fin(c, "cf-yi-titles")
end

-- TREAT: heart cookie with a smile and a pink yarn ball -----------------------------------------------------------------
do
  local c = N()
  local hm = L.ellipse(22.5, 23.5, 13, 12.5):add(L.ellipse(41.5, 23.5, 13, 12.5)):add(L.poly({ { 10, 28 }, { 54, 28 }, { 32, 55 } }))
  part(c, hm, SISAL, 3, 3)
  hm:cut(hm:edge()):edge():each(function(x, y) if (x + y) % 4 == 0 then c:put(x, y, SISAL.D, "detail") end end)
  for _, p in ipairs({ { 16, 17 }, { 17, 16 }, { 18, 16 } }) do c:put(p[1], p[2], SISAL.g, "detail") end
  px(c, { { 24, 26, '#' }, { 24, 27, '#' }, { 25, 26, '#' }, { 25, 27, '#' }, { 36, 26, '#' }, { 36, 27, '#' }, { 37, 26, '#' }, { 37, 27, '#' },
    { 27, 33, '#' }, { 28, 34, '#' }, { 29, 34, '#' }, { 30, 34, '#' }, { 31, 34, '#' }, { 32, 34, '#' }, { 33, 34, '#' }, { 34, 33, '#' }, { 22, 31, SISAL.b }, { 23, 31, SISAL.b }, { 38, 31, SISAL.b }, { 39, 31, SISAL.b } })
  S.ball(c, 46, 46, 9.5, PINK, { ph = 0 }) sep(c, L.ellipse(46, 46, 9.5, 9.5))
  local th = L.tube({ { 38, 51 }, { 33, 56 }, { 26, 57 }, { 22, 54 } }, function() return 0.8 end) part(c, th, PINK, 1, 1)
  fin(c, "cf-yi-treat")
end

-- TUNE: rod with a red grip, teal reel, gold tip, sparkles ----------------------------------------------------------------
do
  local c = N()
  local grip = L.tube({ { 9, 55 }, { 19, 45 } }, function() return 3.4 end) part(c, grip, RED, 2, 2) sep(c, grip)
  local shaft = L.tube({ { 18, 46 }, { 50, 14 } }, function(t) return 2.6 - t * 1 end) part(c, shaft, WOOD, 1, 1)
  for _, p in ipairs({ { 28, 36 }, { 38, 26 } }) do line(c, { { p[1] - 2, p[2] + 2 }, { p[1] + 2, p[2] - 2 } }, WOOD.D) end
  local reel = L.ellipse(27, 33, 6.5, 6.5) part(c, reel, TEAL, 2, 2) sep(c, reel)
  local hub = L.ellipse(27, 33, 2.5, 2.5) part(c, hub, GOLD, 1, 1)
  px(c, { { 24, 29, TEAL.g }, { 23, 30, TEAL.L } })
  line(c, { { 31, 40 }, { 33, 47 } }, PINK.m) line(c, { { 33, 47 }, { 31, 54 }, { 36, 58 } }, PINK.m)
  local tip = L.ellipse(53, 11, 4, 4) part(c, tip, GOLD, 1, 1) sep(c, tip) c:put(51, 9, GOLD.g, "detail")
  local tw = L.tube({ { 56, 14 }, { 60, 20 }, { 57, 27 }, { 59, 33 } }, function() return 0.6 end) part(c, tw, PINK, 1, 1)
  S.spark(c, 14, 20, 3, GOLD.L, GOLD.g) S.spark(c, 56, 48, 2, GOLD.L, GOLD.g)
  fin(c, "cf-yi-tune")
end

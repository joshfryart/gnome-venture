-- folk-butterfly-1 portrait (80x100, folk F2_12, variant 1 gardener). Opus third pass (richness).
-- Same character as opus2 / the game picture: brown fuzzy butterfly gardener with sunny yellow rounded wings
-- (dark bands, dotted border, orange hind spots), straw hat with a green band and a leaf sprig, green
-- dungarees, a trowel, ink antennae with clubbed tips, locked eyes, pink cheeks, green backdrop disc.
-- Richness: 6-tone ramps built from the design colours; wings darken toward the body and carry staggered
-- wing-scale rows, veins with a lit side and a lit rim; fur is lit per pixel with short fur strokes and a
-- warm bounce from the wings under the jaw; straw hat has an over-under weave; dungarees have a twill
-- weave, a stitched pocket and gold buckles; trowel has a bevel, a centre ridge and a specular; the handle
-- has wood grain.
-- Fix (opus2 weakness: teddy-bear muzzle): the pale muzzle patch is gone. The face is the fur itself with a
-- small designed button nose and a clear smile, so it reads as an insect, not a bear.
-- Quirk (look closer): a ladybird has walked out onto the hat brim.
local NAME = "folk-butterfly-1"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local C = { W = { hi = "#fff09a", base = "#f7c843", shade = "#d98e3e", deep = "#8a4e5e" }, DK = "#4a3352", SP = "#fbe9c0", AC = "#ec7a3e",
  FUZ = { hi = "#c49a74", base = "#94684f", shade = "#664654", deep = "#432f45" },
  CL = { hi = "#b4dc72", base = "#72b24e", shade = "#43805a", deep = "#2f5250" },
  HAT = { hi = "#fcebb0", base = "#e9c274", shade = "#bb8a5c", deep = "#7c5856" },
  BOOT = { hi = "#a07a62", base = "#6e4e4c", shade = "#4c3446", deep = "#35253a" },
  PROP = { hi = "#e6eef0", base = "#a8b8c8", shade = "#6e7898", deep = "#4a4a6e" },
  WOOD = { hi = "#d9a066", base = "#a8703f", shade = "#764c44", deep = "#4e3240" },
  BG = { base = "#dbe596", shade = "#b9c676", deep = "#8e9c5a" } }
local W6, FUZ6, CL6, HAT6, PROP6, WOOD6, BOOT6 = Q.six(C.W), Q.six(C.FUZ), Q.six(C.CL), Q.six(C.HAT), Q.six(C.PROP), Q.six(C.WOOD), Q.six(C.BOOT)
W6[5] = "#fde070"
local WARMBOUNCE = "#b8845a"

local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R = math.max(rx, ry)
  for y = math.floor(cy - R - 1), math.ceil(cy + R + 1) do for x = math.floor(cx - R - 1), math.ceil(cx + R + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function fill(m, hex, tok) m:each(function(x, y) c:put(x, y, hex, tok) end) end
local function rows(x0, y0, rs, map) for j, r in ipairs(rs) do for i = 1, #r do local h = map[r:sub(i, i)] if h then c:put(x0 + i - 1, y0 + j - 1, h) end end end end
local function outerOf(m, ax, sg, d) local r = HP.mask() m:each(function(x, y) if (x + .5 - ax) * sg > d then r:set(x, y) end end) return r end
local function tok(n) return { r = { name = n } } end
local FC = { .26, .44, .62, .8, .93 } -- fur cuts: the flat interior stays on the base tone
local function furTex(seed) return function(x, y)
  local h = Q.hash(x, (y + (x % 3)) // 3, seed)
  if h < 0.09 then return -1 elseif h > 0.96 then return 1 end
end end
-- inner line on the pixels of m that touch mask other
local function sepLine(m, other, hex, t)
  m:each(function(x, y) for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    if other:has(x + d[1], y + d[2]) and not m:has(x + d[1], y + d[2]) then c:put(x, y, hex, t) break end end end)
end

-- wings: four real butterfly wings, root dark, scale rows, veins, dark band, dotted border
local function wingPaint(m, ax, ay, maxd, t)
  m:each(function(x, y)
    local d = math.sqrt((x - ax) ^ 2 + (y - ay) ^ 2) / maxd
    local i = 3 + math.floor(math.min(0.99, d) * 2.6)
    if not m:has(x + 2, y + 2) then i = i - 1 end
    if not m:has(x + 1, y + 1) then i = i - 1 end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then i = i + 1 end
    if y % 3 == 0 and (x + (y // 3 % 2) * 3) % 6 < 2 and i >= 3 and i <= 5 then i = i + 1 end
    c:put(x, y, W6[math.max(1, math.min(6, i))], t)
  end)
end
local ax, ay, s = 39.5, 72, 1.45
for _, sg in ipairs{ -1, 1 } do
  local fore = oval(ax + sg * 13 * s, ay - 11 * s, 11 * s, 9 * s, sg * -25)
  local hind = oval(ax + sg * 11 * s, ay + 8 * s, 8 * s, 7 * s, sg * 25)
  local tx, ty = ax + sg * 21 * s, ay - 17 * s
  local hc = { ax + sg * 13 * s, ay + 10 * s }
  local th, tf = tok("hind" .. sg), tok("fore" .. sg)
  wingPaint(hind, ax, ay, 22, th)
  wingPaint(fore, ax, ay, 34, tf)
  sepLine(fore, hind:copy():cut(fore), W6[1], tf)
  local inF, inH = fore:copy():shrink(1), hind:copy():shrink(1)
  local function vein(a, b, inner, t)
    local v = c:line({ a, b }, 1):clip(inner)
    v:each(function(x, y) c:put(x, y, W6[2], t) if inner:has(x, y - 1) and not v:has(x, y - 1) then c:put(x, y - 1, W6[6], t) end end)
  end
  for _, tt in ipairs{ { tx, ty }, { tx + sg * 4 * s, ty + 9 * s }, { tx - sg * 7 * s, ty - 1 * s } } do vein({ ax, ay }, tt, inF, tf) end
  vein({ ax, ay }, { hc[1] + sg * 4 * s, hc[2] + 4 * s }, inH, th)
  -- dark diagonal band (with a lit leading edge)
  local band = c:line({ { ax + sg * 9 * s, ay - 21 * s }, { ax + sg * 17 * s, ay - 5 * s } }, 3):clip(inF)
  fill(band, C.DK, tf)
  band:each(function(x, y) if not band:has(x - sg, y) and inF:has(x - sg, y) then c:put(x - sg, y, W6[2], tf) end end)
  -- orange hind spot with a lit top
  local sp = HP.ellipse(hc[1], hc[2], 1.8 * s, 1.8 * s):clip(inH)
  sp:each(function(x, y) c:put(x, y, sp:has(x, y - 1) and C.AC or "#ffa860", th) end)
  -- dark outer border with pale dots
  local bF = outerOf(fore:copy():cut(fore:copy():shrink(3)), ax, sg, 7 * s)
  local bH = outerOf(hind:copy():cut(hind:copy():shrink(3)), ax, sg, 7 * s)
  for _, pr in ipairs{ { bF, inF, tf }, { bH, inH, th } } do
    pr[1]:each(function(x, y)
      local dot = pr[2]:has(x, y) and (x * 7 + y * 3) % 5 == 0
      c:put(x, y, dot and C.SP or C.DK, pr[3])
    end)
  end
end

-- body fur
local body = c:ellipse(39.5, 101, 27, 29):clip(c:rect(0, 0, 79, 99))
Q.body(c, body, FUZ6, { R = 9, amb = 0.15, tok = tok("body"), tex = furTex(3), cuts = FC })
-- dungarees: bib, straps, buckles, stitched pocket; twill weave
local TW = function(x, y) if (x + y) % 4 == 0 then return -1 end end
local bib = c:rrect(28, 82, 51, 99, 3)
local bTok = tok("bib")
Q.body(c, bib, CL6, { R = 3, amb = 0.25, tok = bTok, tex = TW })
sepLine(bib, body, CL6[1], bTok)
for _, st in ipairs{ { { 31, 83 }, { 28, 73 } }, { { 48, 83 }, { 51, 73 } } } do
  local m = c:line(st, 3)
  local t = tok("strap" .. st[1][1])
  Q.body(c, m, CL6, { R = 1.5, amb = 0.3, tok = t })
  sepLine(m, body, CL6[1], t)
end
for _, bx in ipairs{ 29, 49 } do rows(bx, 82, { "hb", "bs" }, { h = "#ffe38a", b = "#f5b82e", s = "#d98322" }) end
-- pocket: a darker patch with a stitched hem (the one stitch line)
local pk = c:rrect(34, 89, 45, 95, 1)
Q.body(c, pk, CL6, { R = 1.5, amb = 0.1, tok = tok("pocket"), tex = function(x, y) return -1 end })
fill(c:rect(34, 89, 45, 89), CL6[2])
c:stitch{ { 35, 91 }, { 44, 91 } }
-- fur ruff collar
local ruff = c:ellipse(39.5, 70, 15, 4)
for _, q in ipairs{ { 26, 72 }, { 31, 73 }, { 37, 73.5 }, { 42, 73.5 }, { 48, 73 }, { 53, 72 } } do ruff:add(HP.ellipse(q[1], q[2], 2, 2)) end
Q.body(c, ruff, FUZ6, { R = 3, amb = 0.25, tok = tok("ruff"), tex = furTex(5), cuts = FC })
-- arms
local armL, armR = c:ellipse(18, 88, 4.5, 6), c:ellipse(61, 88, 4.5, 6)
for _, a in ipairs{ armL, armR } do
  local t = tok("arm")
  Q.body(c, a, FUZ6, { R = 3, amb = 0.2, tok = t, tex = furTex(7), cuts = FC, bounce = WARMBOUNCE })
  sepLine(a, body, FUZ6[1], t)
end
-- trowel: bevelled blade with a centre ridge and a specular, collar, wood handle with grain, hand over it
local blade = c:poly{ { 55.5, 77 }, { 67.5, 77 }, { 61.5, 62 } }
local blTok = tok("blade")
blade:each(function(x, y)
  local i = x < 61 and 5 or (x == 61 and 6 or 3)
  if not blade:has(x + 1, y) or not blade:has(x, y + 1) then i = 2 end
  if y >= 76 then i = math.max(1, i - 1) end
  c:put(x, y, PROP6[i], blTok)
end)
c:put(59, 73, "#f6fafa") c:put(60, 71, "#f6fafa") c:put(60, 70, PROP6[6]) c:put(58, 75, PROP6[6])
local fer = c:rect(59, 78, 64, 80)
Q.body(c, fer, PROP6, { R = 1, amb = 0.3, tok = tok("ferrule") })
local hdl = c:rrect(59, 81, 64, 93, 1)
local hTok = tok("handle")
Q.body(c, hdl, WOOD6, { R = 2, amb = 0.25, tok = hTok, tex = function(x, y) if x == 61 and y % 4 ~= 0 then return -1 end if x == 63 and y % 5 == 2 then return -1 end end })
local hand = c:ellipse(61.5, 87, 3.5, 2.5)
Q.body(c, hand, BOOT6, { R = 2, amb = 0.25, tok = tok("handR") })
local hand2 = c:ellipse(18, 92, 3, 2.5)
Q.body(c, hand2, BOOT6, { R = 2, amb = 0.25, tok = tok("handL") })

-- head: fuzzy, lit from the upper-left, warm wing bounce under the jaw
local head = c:ellipse(39.5, 48, 20, 17)
for _, a in ipairs{ 150, 165, 180, 195, 0, 15, 30, -15, 60, 75, 90, 105, 120 } do
  local r = math.rad(a)
  head:add(HP.ellipse(39.5 + math.cos(r) * 19.5, 48 + math.sin(r) * 16.5, 2, 2))
end
local hdTok = tok("head")
Q.body(c, head, FUZ6, { sphere = { 36, 44, 25 }, amb = 0.2, wrap = 0.5, tok = hdTok, tex = furTex(11), cuts = FC, bounce = WARMBOUNCE })
sepLine(head, ruff:copy():add(body), FUZ6[1], hdTok)
-- fur tuft strokes around the jaw (lit tip, dark root)
for _, st in ipairs{ { 23, 56, 24, 54 }, { 28, 60, 29, 58 }, { 50, 60, 51, 58 }, { 55, 56, 56, 54 }, { 34, 62, 35, 60 }, { 44, 62, 45, 60 }, { 21, 49, 22, 47 }, { 57, 49, 58, 47 } } do
  local l = c:line({ { st[1], st[2] }, { st[3], st[4] } }, 1):clip(head)
  l:each(function(x, y) c:put(x, y, FUZ6[2], hdTok) end)
  if head:has(st[3], st[4] - 1) then c:put(st[3], st[4] - 1, FUZ6[5], hdTok) end
end
-- lit lid line above each eye
for _, ex in ipairs{ 32, 47 } do for x = ex - 2, ex + 2 do c:put(x, 42, FUZ6[6]) end end
c:eyeLocked(30, 44) c:eyeLocked(45, 44)
-- designed button nose: lit tip, warm base, dark underside and nostril shadow (no muzzle patch)
rows(38, 51, { "hhb.", "bbbs", ".dd." }, { h = "#f2a4a0", b = "#c4646e", s = "#9a4658", d = "#6e3044" })
c:put(38, 51, "#ffd4cc")
-- smile with a philtrum and a little tongue
rows(35, 55, { "....i....", "i...i...i", ".iiiiiii.", "...tt...." }, { i = P.ink, t = "#e8607e" })
-- cheeks
rows(23, 53, { "kkk", "kkk" }, { k = "#f2949e" }) rows(54, 53, { "kkk", "kkk" }, { k = "#f2949e" })
c:put(23, 53, "#f8b8b0") c:put(54, 53, "#f8b8b0")

-- straw hat: brim and crown with an over-under weave, green band, leaf sprig
local WEAVE = function(x, y)
  local u = (x + (y % 2) * 2) % 4
  if u == 0 then return 1 elseif u == 2 then return -1 end
end
local brim = c:ellipse(39.5, 33, 28, 5.5)
local brTok = tok("brim")
Q.body(c, brim, HAT6, { R = 3, amb = 0.25, tok = brTok, tex = WEAVE, cuts = FC })
Q.side(brim, 0, 1):each(function(x, y) c:put(x, y, HAT6[1], brTok) end)
Q.side(brim, 0, -1):each(function(x, y) if x < 48 then c:put(x, y, HAT6[6], brTok) end end)
-- frayed straw ends along the brim edge
for _, x in ipairs{ 14, 22, 57, 64 } do if not brim:has(x, 39) and brim:has(x, 38) then c:put(x, 39, HAT6[3]) end end
local crown = c:rrect(28, 16, 51, 33, 6)
local crTok = tok("crown")
Q.body(c, crown, HAT6, { R = 5, amb = 0.22, tok = crTok, tex = WEAVE, cuts = FC })
sepLine(crown, brim, HAT6[2], crTok)
-- hat band: lit top row, base, shaded bottom row, a knot fold
fill(c:rect(28, 27, 51, 27):clip(crown), CL6[6], crTok)
fill(c:rect(28, 28, 51, 30):clip(crown), CL6[4], crTok)
fill(c:rect(28, 31, 51, 31):clip(crown), CL6[2], crTok)
fill(c:rect(46, 28, 46, 30), CL6[2], crTok) fill(c:rect(47, 28, 47, 30), CL6[5], crTok)
-- sprig: stem, three leaves with a midrib
fill(c:line({ { 48, 27 }, { 55, 13 } }, 1), CL6[1])
for _, lf in ipairs{ { oval(52, 19, 4, 1.7, -50), { 50, 19 } }, { oval(56, 14, 4, 1.7, 30), { 54, 13 } }, { oval(54, 9, 1.7, 3.6, 10), { 54, 8 } } } do
  local t = tok("leaf")
  Q.body(c, lf[1], CL6, { R = 1.5, amb = 0.3, tok = t })
  c:put(lf[2][1], lf[2][2], CL6[6])
end
c:put(53, 18, CL6[2]) c:put(56, 15, CL6[2])
-- quirk (look closer): a ladybird has walked out onto the brim
rows(58, 28, { ".rh", "krr", ".rs" }, { r = "#e8493b", h = "#ff8a5c", s = "#b52e3f", k = P.ink })
c:put(59, 29, "#2b1c26")
c:finish{ outline = true }
-- antennae (ink) with clubbed tips
for _, a in ipairs{ { { 33, 16 }, { 30, 10 }, { 26, 5 } }, { { 46, 16 }, { 49, 10 }, { 53, 5 } } } do
  c:fillMask(c:line(a, 1), P.ink)
  local tx, ty = a[3][1], a[3][2]
  fill(c:ellipse(tx + .5, ty - .5, 2, 2.5), C.DK)
  c:put(tx - 1, ty - 2, W6[4]) c:put(tx, ty - 2, W6[5]) c:put(tx + 1, ty + 1, "#2e2236")
end
-- backdrop disc (unchanged design: base, shade crescent lower-right, own darker ring)
local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and C.BG.base or C.BG.shade, "bg") end end)
disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then c:put(x, y, C.BG.deep, "bg") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")

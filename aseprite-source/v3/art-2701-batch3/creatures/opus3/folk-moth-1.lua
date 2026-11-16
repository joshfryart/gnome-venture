-- folk-moth-1 portrait (80x100, folk F2_5, variant 1). Opus third pass (richness).
-- Same character as opus2: luna-moth gardener, mint fur, violet compound-eye sockets round the locked eyes,
-- mint wings behind with a purple edge and gold eyespots, cream ruff, straw sun hat with a red ribbon and a
-- leaf sprig, feathered antennae, denim dungarees with gold buckles and a stitched pocket, a trowel.
-- Richness: 6-tone ramps from the design colours, all lit from the upper-left. Fur gets per-pixel light,
-- fur strokes and a cool lilac bounce under the jaw; the eye sockets are faceted like compound eyes; wings
-- carry wing-scale rows and veins, eyespots get a ring and a glint; the ruff is tufted; the hat is plaited
-- straw (chevron rows), the ribbon is satin with a fold; dungarees are denim twill; trowel steel has a
-- bevel and a specular, the handle has grain. The muzzle now has a tufted top edge so it reads as fur.
-- Quirk (look closer): a moth has nibbled a small hole in the dungaree bib, one thread hangs loose.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local NAME = "folk-moth-1"
local R = {
  fur = { hi = "#f1f4c8", base = "#d6e3a2", shade = "#9fb48c", deep = "#667f74" },
  body = { hi = "#e3f0b8", base = "#bcd694", shade = "#88a886", deep = "#587470" },
  ruff = { hi = "#fbf6dc", base = "#ece6bc", shade = "#c2c09e", deep = "#8a8c84" },
  wing = { hi = "#d2f2b8", base = "#98d69a", shade = "#62a894", deep = "#3e7076" },
  edge = "#9c7cb8",
  spot = { hi = "#f6d98a", base = "#e0a64a", shade = "#a86c44", deep = "#5e3a48" },
  socket = "#7c6a94",
  nose = { hi = "#f2c08a", base = "#c8784a", shade = "#94524a", deep = "#64384a" },
  ant = { hi = "#f6e2a8", base = "#d8b874", shade = "#a48058", deep = "#6c4e4a" },
  straw = { hi = "#f8de90", base = "#e2b65e", shade = "#b27e4a", deep = "#7c5046" },
  ribbon = { hi = "#ec8a62", base = "#cc5a4c", shade = "#923c4e", deep = "#602c46" },
  cloth = { hi = "#88a6d0", base = "#5c78ac", shade = "#435488", deep = "#2f3a62" },
  steel = { hi = "#e2e6ee", base = "#a8b2c4", shade = "#727c96", deep = "#4c526c" },
  wood = { hi = "#d8a070", base = "#a8704c", shade = "#7a4c44", deep = "#52343e" },
  leaf = { hi = "#b8e070", base = "#72b04c", shade = "#4a8048", deep = "#2e5440" },
  gold = { hi = "#f8e08a", base = "#e8b440", shade = "#b07a3c", deep = "#74503c" },
  bg = { base = "#b4dca4", shade = "#8cbc94", deep = "#679a86" },
}
local S6 = {}
for k, v in pairs(R) do if type(v) == "table" and v.hi then S6[k] = Q.six(v) end end
local BOUNCE = "#a8a8c4"
local FC = { .26, .44, .62, .8, .93 }

local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R0 = math.max(rx, ry)
  for y = math.floor(cy - R0 - 1), math.ceil(cy + R0 + 1) do for x = math.floor(cx - R0 - 1), math.ceil(cx + R0 + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function tok(n) return { r = { name = n } } end
local function fill(m, hex, t) m:each(function(x, y) c:put(x, y, hex, t) end) end
local function rows(x0, y0, rs, map) for j, r in ipairs(rs) do for i = 1, #r do local h = map[r:sub(i, i)] if h then c:put(x0 + i - 1, y0 + j - 1, h) end end end end
local function sepLine(m, other, hex, t)
  m:each(function(x, y) for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    if other:has(x + d[1], y + d[2]) and not m:has(x + d[1], y + d[2]) then c:put(x, y, hex, t) break end end end)
end
local function furTex(seed) return function(x, y)
  local h = Q.hash(x, (y + (x % 3)) // 3, seed)
  if h < 0.09 then return -1 elseif h > 0.96 then return 1 end
end end
-- lit body helper: o.R, o.tex, o.cuts, o.bounce
local function lit(m, key, name, o)
  o = o or {}
  local t = tok(name)
  Q.body(c, m, S6[key], { R = o.R or 3, sphere = o.sphere, amb = o.amb or 0.22, wrap = o.wrap or 0.35, tok = t, tex = o.tex, cuts = o.cuts or FC, bounce = o.bounce, bounceMinX = o.bmx })
  return t
end

-- feathered antenna (bipectinate) with lit barbs on the upper side
local function frond(x0, y0, x1, y1, w)
  local A = S6.ant
  c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), A[1])
  local sx, sy = x0 + (x1 - x0) * 0.3, y0 + (y1 - y0) * 0.3
  local dx, dy = x1 - sx, y1 - sy
  local len = math.sqrt(dx * dx + dy * dy)
  local m = oval((sx + x1) / 2, (sy + y1) / 2, len / 2, w, math.deg(math.atan(dy, dx)))
  local t = tok("frond" .. x0)
  local ux, uy = dx / len, dy / len
  m:each(function(x, y)
    local px, py = x + .5 - sx, y + .5 - sy
    local u, v = px * ux + py * uy, -px * uy + py * ux
    local col
    if math.abs(v) < 0.75 then col = A[1]
    elseif (math.floor(u) + (v > 0 and 0 or 1)) % 2 == 0 then col = v < 0 and A[3] or A[2]
    else col = (v < 0 and u < len * 0.7) and A[6] or A[4] end
    if not m:has(x + 1, y + 1) and col ~= A[1] then col = A[2] end
    c:put(x, y, col, t)
  end)
end

-- wings (behind): luna-moth mint with scale rows, veins, purple edge, gold eyespots and long tails
local w = c:poly{ { 30, 62 }, { 49, 62 }, { 73, 72 }, { 79, 99 }, { 0, 99 }, { 6, 72 } }
w:add(c:line({ { 4, 90 }, { 1, 99 } }, 4)) w:add(c:line({ { 75, 90 }, { 78, 99 } }, 4))
local wTok = tok("wing")
w:each(function(x, y)
  local d = math.abs(x - 39.5) / 40
  local i = 2 + math.floor(d * 2.6)
  if not w:has(x - 1, y) or not w:has(x, y - 1) then i = i + 2 end
  if not w:has(x + 1, y + 1) then i = i - 1 end
  if y % 3 == 1 and (x + (y // 3 % 2) * 3) % 6 < 2 and i <= 5 then i = i + 1 end
  c:put(x, y, S6.wing[math.max(1, math.min(6, i))], wTok)
end)
c:fillMask(c:line({ { 30, 62 }, { 6, 72 }, { 2, 88 } }, 1):clip(w), R.edge)
c:fillMask(c:line({ { 49, 62 }, { 73, 72 }, { 77, 88 } }, 1):clip(w), R.edge)
c:fillMask(c:line({ { 31, 63 }, { 7, 73 } }, 1):clip(w), "#c4aedc")
for _, v in ipairs{ { { 30, 66 }, { 8, 80 } }, { { 49, 66 }, { 71, 80 } }, { { 26, 70 }, { 14, 92 } }, { { 53, 70 }, { 65, 92 } } } do
  c:line(v, 1):clip(w:copy():shrink(1)):each(function(x, y) c:put(x, y, S6.wing[2], wTok) if w:has(x, y - 1) then c:put(x, y - 1, S6.wing[5], wTok) end end)
end
for _, ex in ipairs{ 10, 69 } do
  c:fillMask(c:ellipse(ex, 84, 4.5, 4.5):clip(w), R.edge)
  c:fillMask(c:ellipse(ex, 84, 3.5, 3.5), R.spot.base)
  c:fillMask(c:ellipse(ex, 84, 3.5, 3.5):cut(c:ellipse(ex, 84, 3.5, 3.5):shift(1, 1)), R.spot.shade)
  c:fillMask(c:ellipse(ex, 84, 1.5, 1.5), R.spot.deep)
  c:put(ex - 2, 82, R.spot.hi) c:put(ex - 1, 82, R.spot.hi) c:put(ex - 1, 83, "#fbf6dc")
end

-- body fur
local body = c:ellipse(39.5, 104, 29, 30):clip(c:rect(0, 72, 79, 99))
for _, q in ipairs{ { 12, 90 }, { 15, 84 }, { 20, 79 }, { 59, 79 }, { 64, 84 }, { 67, 90 } } do body:add(HP.ellipse(q[1], q[2], 2, 2)) end
local bT = lit(body, "body", "body", { sphere = { 36, 92, 34 }, tex = furTex(2), cuts = FC })
sepLine(body, w:copy():cut(body), S6.body[1], bT)
-- denim dungarees: twill diagonal, lit rim, straps, gold buckles, stitched pocket
local TW = function(x, y) if (x - y) % 3 == 0 then return -1 end end
local bib = c:rrect(28, 82, 51, 99, 3)
-- quirk: moth-nibbled hole in the bib
local hole = c:rect(46, 93, 47, 94) hole:set(45, 94)
bib:cut(hole)
local clT = lit(bib, "cloth", "bib", { R = 3, tex = TW })
sepLine(bib, body, S6.cloth[1], clT)
for _, st in ipairs{ { { 30, 83 }, { 25, 74 } }, { { 49, 83 }, { 54, 74 } } } do
  local m = c:line(st, 3)
  local t = lit(m, "cloth", "strap" .. st[1][1], { R = 1.5 })
  sepLine(m, body, S6.cloth[1], t)
end
for _, bx in ipairs{ 29, 48 } do rows(bx, 82, { "hhb", "hbs", "bss" }, { h = R.gold.hi, b = R.gold.base, s = R.gold.shade }) c:put(bx + 1, 83, R.gold.deep) end
local pk = c:rrect(33, 88, 46, 96, 2)
lit(pk, "cloth", "pocket", { R = 1.5, tex = function(x, y) if (x - y) % 3 == 0 then return -2 end return -1 end })
fill(c:rect(34, 88, 45, 88), S6.cloth[1])
c:stitch{ { 34, 89 }, { 45, 89 } }
-- the hole shows the dark fur behind, edges frayed, a loose thread
fill(hole, S6.body[1])
c:put(45, 93, S6.cloth[6]) c:put(48, 93, S6.cloth[2]) c:put(46, 95, S6.cloth[2]) c:put(47, 95, S6.cloth[5]) c:put(48, 96, S6.cloth[5])

-- ruff: tufted cream collar with fur strokes
local ruff = c:ellipse(39.5, 70, 17, 4)
for x = 24, 56, 4 do ruff:add(HP.ellipse(x, 73, 2.2, 2.2)) end
local rT = lit(ruff, "ruff", "ruff", { R = 3, tex = furTex(4) })
for x = 25, 55, 4 do c:put(x, 74, S6.ruff[2], rT) c:put(x - 1, 72, S6.ruff[6], rT) end

-- head fur with strokes and a lilac bounce under the jaw
local head = c:ellipse(39.5, 48, 20, 17)
for i = 0, 8 do local a = math.rad(195 + i * 18.75) head:add(HP.ellipse(39.5 + math.cos(a) * 19.5, 48 + math.sin(a) * 16.5, 2.5, 2.5)) end
local hT = lit(head, "fur", "head", { sphere = { 36, 44, 25 }, amb = 0.2, wrap = 0.5, tex = furTex(9), cuts = FC, bounce = BOUNCE, bmx = 30 })
sepLine(head, ruff, S6.fur[1], hT)
for _, s in ipairs{ { 28, 36, 29, 34 }, { 34, 33, 35, 31 }, { 44, 33, 45, 31 }, { 50, 36, 51, 34 }, { 24, 42, 25, 40 }, { 55, 42, 56, 40 }, { 22, 52, 23, 50 }, { 57, 52, 58, 50 } } do
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(head):each(function(x, y) c:put(x, y, S6.fur[2], hT) end)
  if head:has(s[3], s[4] - 1) then c:put(s[3], s[4] - 1, S6.fur[6], hT) end
end
-- compound-eye sockets: violet with a darker lower-right and pale facet dots
for _, ex in ipairs{ 32, 47 } do
  local so = c:ellipse(ex, 48, 4.5, 4)
  so:each(function(x, y)
    local col = R.socket
    if not so:has(x + 1, y + 1) then col = "#5a4a78" end
    if (x + (y % 2)) % 2 == 0 and (y % 2 == 0) and so:has(x - 1, y - 1) and so:has(x + 1, y + 1) then col = "#a492c0" end
    c:put(x, y, col)
  end)
end
c:eyeLocked(30, 46) c:eyeLocked(45, 46)
-- muzzle with a tufted top edge, button nose, smile
local mz = c:ellipse(39.5, 57, 6.5, 4)
for _, x in ipairs{ 35, 39, 43 } do mz:add(HP.ellipse(x, 53.5, 1.2, 1.2)) end
mz:clip(head)
local mT = lit(mz, "ruff", "muzzle", { R = 2.5, amb = 0.3 })
rows(38, 52, { ".hh.", "hbbb", "bbbs", ".dd." }, { h = R.nose.hi, b = R.nose.base, s = R.nose.shade, d = R.nose.deep })
c:put(39, 52, "#fde4c0")
rows(34, 56, { ".....i.....", "i....i....i", ".iiiiiiiii.", "...ttt....." }, { i = INK, t = "#e8607e" })
c:put(37, 59, "#ff9cb0") c:put(38, 59, "#ff9cb0")
c:cheek(24, 55) c:cheek(53, 55)
c:put(25, 54, "#ffc4d8")

-- straw sun hat: plaited chevron rows, satin ribbon, sprig
local PLAIT = function(x, y)
  local r = y % 3
  local v = (x + (r == 1 and 1 or 0)) % 3
  if r == 2 then return -1 end
  if v == 0 then return 1 end
end
local brim = c:ellipse(39.5, 36, 26, 6)
local brT = lit(brim, "straw", "brim", { R = 3, tex = PLAIT })
Q.side(brim, 0, 1):each(function(x, y) c:put(x, y, S6.straw[1], brT) end)
Q.side(brim, 0, -1):each(function(x, y) if x < 46 then c:put(x, y, S6.straw[6], brT) end end)
local cr = c:rrect(27, 19, 52, 36, 7)
local crT = lit(cr, "straw", "crown", { R = 5, tex = PLAIT })
sepLine(cr, brim, S6.straw[2], crT)
-- ribbon: lit top, base, shaded bottom, a fold and a tail
fill(c:rect(27, 30, 52, 30):clip(cr), S6.ribbon[6], crT)
fill(c:rect(27, 31, 52, 32):clip(cr), S6.ribbon[4], crT)
fill(c:rect(27, 33, 52, 33):clip(cr), S6.ribbon[2], crT)
fill(c:rect(33, 31, 33, 33), S6.ribbon[2], crT) fill(c:rect(34, 31, 34, 32), S6.ribbon[5], crT)
c:fillMask(c:line({ { 51, 31 }, { 57, 21 } }, 1), R.leaf.deep)
for _, q in ipairs{ { 57, 20 }, { 60, 24 }, { 54, 24 } } do
  local lf = c:ellipse(q[1], q[2], 2, 1.5)
  local t = lit(lf, "leaf", "leaf" .. q[1], { R = 1.5, amb = 0.3 })
  c:put(q[1] - 1, q[2] - 1, S6.leaf[6])
end
for _, a in ipairs{ { 35, 24, 21, 5, 3 }, { 44, 24, 58, 5, 3 } } do frond(a[1], a[2], a[3], a[4], a[5]) end

-- trowel in front: bevelled steel blade with ridge and specular, collar, grained handle, fuzzy hand
local bl = c:poly{ { 9, 84 }, { 21, 84 }, { 19, 74 }, { 15, 66 }, { 11, 74 } }
local blT = tok("blade")
bl:each(function(x, y)
  local i = x < 15 and 5 or (x == 15 and 6 or 3)
  if not bl:has(x + 1, y) or not bl:has(x, y + 1) then i = 2 end
  if not bl:has(x - 1, y) then i = 6 end
  c:put(x, y, S6.steel[i], blT)
end)
c:fillMask(c:line({ { 15, 69 }, { 15, 83 } }, 1), S6.steel[3])
c:put(13, 74, "#f6f8fa") c:put(13, 75, "#f6f8fa") c:put(12, 78, S6.steel[6])
c:put(15, 66, R.wood.deep) c:put(15, 67, R.wood.shade) c:put(14, 67, R.wood.shade) c:put(16, 68, R.wood.shade)
lit(c:rect(13, 84, 17, 86), "steel", "collar", { R = 1 })
lit(c:rrect(13, 87, 17, 99, 1), "wood", "handle", { R = 2, tex = function(x, y) if x == 15 and y % 4 ~= 1 then return -1 end end })
lit(c:ellipse(15, 92, 4.5, 3.5), "body", "hand", { R = 2.5, tex = furTex(6) })
c:finish{ outline = true }
-- backdrop disc (unchanged design)
local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and R.bg.base or R.bg.shade, "bg") end end)
disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then
  local dk = false
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + d[1], y + d[2]) == R.bg.shade then dk = true end end
  c:put(x, y, dk and R.bg.deep or R.bg.shade, "bg") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")

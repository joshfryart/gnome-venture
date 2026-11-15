-- folk-tortoise-1 portrait (80x100, folk F2_7, variant 1 gardener). Opus third pass (richness).
-- Same character as opus2: green tortoise villager, tall domed shell with a pale marginal rim and big
-- costal scutes, cream plastron, denim bib with a stitched pocket and gold buttons, straw sun hat with a
-- green band and a leaf sprig, heavy-lidded locked eyes, beak smile with a pale lower jaw, a trowel in the fist.
-- Fix (opus2 weakness: neck too long): the head and hat sit 7 px lower and the neck is shorter, so the head
-- now sits close to the shell opening.
-- Richness: 6-tone ramps from the design colours lit from the upper-left; the shell is lit as a dome, each
-- costal scute has concentric growth rings and a lit top-left, the marginal rim is ticked and scuffed; skin
-- is pebbled with small scales, the neck has deep folds with lit ridges; the head has crown plates and a lit
-- rim with a cool bounce line under the jaw; plastron has sutures; denim twill on the bib; woven straw hat;
-- the trowel has a bevel and specular, the handle wood grain.
-- Quirk (look closer): a tiny snail is riding on the tortoise's shell.
local NAME = "folk-tortoise-1"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local S = {
  skin = R("#bcc98c", "#93a666", "#667a52", "#434d4a"), shell = R("#e8b064", "#c07d3c", "#8a5236", "#57343c"),
  plas = R("#f4e2a4", "#dcbc72", "#a88654", "#6e5448"), nail = "#f2e6c4",
  cloth = R("#93b6d8", "#6188bc", "#465c92", "#323c66"), hat = R("#f8e6a4", "#e4c26c", "#b28c4e", "#765a42"),
  band = R("#b4dc74", "#78b04e", "#4a8048", "#33584a"), metal = R("#e4e8f0", "#adb4c6", "#747c98", "#4c4e68"),
  wood = R("#d89a5c", "#a8693c", "#734534", "#4e2e34"), btn = "#f2c75a", cheek = "#e8948c", cheekhi = "#f4b4a4",
  disc = R("#d4ecf4", "#a4cce4", "#74a2c8", "#4f78a4"),
}
local SK6, SH6, PL6, CL6, HT6, BD6, MT6, WD6 = Q.six(S.skin), Q.six(S.shell), Q.six(S.plas), Q.six(S.cloth), Q.six(S.hat), Q.six(S.band), Q.six(S.metal), Q.six(S.wood)
SH6[6] = "#f2c47a"
local BOUNCE = "#7fa08a"
local FC = { .26, .44, .62, .8, .93 }
local DY = 7 -- head and hat drop (neck fix)

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function tok(n) return { r = { name = n } } end
local function fill(m, hex, t) m:each(function(x, y) c:put(x, y, hex, t) end) end
local function pts(l, h) for _, q in ipairs(l) do c:put(q[1], q[2], h) end end
local function rows(x0, y0, rs, map) for j, r in ipairs(rs) do for i = 1, #r do local h = map[r:sub(i, i)] if h then c:put(x0 + i - 1, y0 + j - 1, h) end end end end
local function sepLine(m, other, hex, t)
  m:each(function(x, y) for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    if other:has(x + d[1], y + d[2]) and not m:has(x + d[1], y + d[2]) then c:put(x, y, hex, t) break end end end)
end
-- pebbled scales: a cell grid (offset every other row); cell borders one tone darker, cell centres lit
local function scales(x, y)
  local row = y // 4
  local u = (x + (row % 2) * 3) % 6
  local v = y % 4
  if (v == 3 and u > 0) or (u == 5 and v == 2) then return -1 end
end
local function speckle(x, y) local h = Q.hash(x, y, 13) if h < 0.06 then return -1 elseif h > 0.97 then return 1 end end

-- shell: a dome lit from the upper-left
local SCX, SCY, SRX, SRY = 39.5, 101, 40, 41
local sh = c:ellipse(SCX, SCY, SRX, SRY):clip(c:rect(0, 0, 79, 99))
local shT = tok("shell")
local shIdx = Q.body(c, sh, SH6, { sphere = { 32, 92, 46 }, amb = 0.25, wrap = 0.4, tok = shT })
do
  local inner = sh:copy():shrink(4)
  local rim = sh:copy():cut(inner)
  local function ang(x, y) return math.deg(math.atan(y + .5 - SCY, x + .5 - SCX)) end
  -- marginal scutes: pale band, dark ticks, the lower-right side in shade, a lit outer edge
  rim:each(function(x, y)
    local a = ang(x, y)
    local f = ((a + 180) % 14)
    local lit = (x + .5 < SCX + 6 and y < 90)
    local col = lit and PL6[5] or PL6[3]
    if f < 1.6 then col = SH6[1] elseif f < 2.6 then col = lit and PL6[6] or PL6[4] end
    if not sh:has(x - 1, y) or not sh:has(x, y - 1) then col = lit and PL6[6] or PL6[4] end
    if inner:has(x, y + 1) or inner:has(x + 1, y) then col = SH6[2] end
    c:put(x, y, col, shT)
  end)
  -- costal scutes: seams, concentric growth rings and a lit top-left inside each
  local seams = { -152, -124, -96, -84, -56, -28 }
  inner:each(function(x, y)
    local a = ang(x, y)
    local dx, dy = (x + .5 - SCX) / (SRX - 4), (y + .5 - SCY) / (SRY - 4)
    local r = math.sqrt(dx * dx + dy * dy)
    local base = shIdx[Q.X.K(x, y)] or 4
    local col
    if r > 0.985 then col = SH6[1] end
    for _, sa in ipairs(seams) do if math.abs(a - sa) * math.pi / 180 * r * SRX < 0.9 then col = SH6[1] end end
    if not col then
      local dmin = (1 - r) * SRX
      local nearSeam
      for _, sa in ipairs(seams) do local d = math.abs(a - sa) * math.pi / 180 * r * SRX if d < dmin then dmin, nearSeam = d, sa end end
      local i = base
      if math.floor(dmin) % 3 == 2 and dmin > 1.5 then i = i - 1 end                 -- growth rings
      if dmin <= 1.5 and (nearSeam == nil or a < nearSeam) and a < -60 then i = i + 1 end -- lit side of each seam
      if Q.hash(x, y, 21) < 0.03 then i = i - 1 end                                       -- wear speckle
      col = SH6[math.max(1, math.min(6, i))]
    end
    c:put(x, y, col, shT)
  end)
  -- scratches on the lit scute
  pts({ { 17, 82 }, { 18, 81 }, { 19, 80 } }, SH6[2]) pts({ { 18, 82 }, { 19, 81 } }, SH6[6])
  -- dark cavity where the neck leaves the shell
  fill(c:ellipse(39.5, 76, 15, 6):clip(sh), SH6[1], shT)
  fill(c:ellipse(39.5, 77, 12, 4):clip(sh), "#3e2430", shT)
end
-- quirk: a tiny snail riding on the shell (left), pink spiral shell, eye stalks
local snail = { ".....i.i", ".hpp.i.i", "hpdppbbb", "pdhdpbbe", "bbbbbbbb" }
local smask = HP.mask()
for j, r in ipairs(snail) do for i = 1, #r do if r:sub(i, i) ~= "." then smask:set(7 + i - 1, 77 + j - 1) end end end
smask:grow(1):cut(smask):clip(sh):each(function(x, y) c:put(x, y, SH6[1], shT) end)
rows(7, 77, snail, { i = INK, h = "#ffc4d8", p = "#f5809f", d = "#7d2c5e", b = "#d8d0c8", e = INK })
c:put(7, 81, "#ece6dc")

-- plastron chest with sutures and growth lines
local tor = c:ellipse(39.5, 110, 24, 30):clip(c:rect(0, 0, 79, 99))
local plT = tok("plastron")
Q.body(c, tor, PL6, { R = 6, amb = 0.25, tok = plT, tex = function(x, y) if (y % 4 == 0) then return -1 end end })
for _, y in ipairs{ 88, 96 } do for x = 16, 63 do if tor:has(x, y) and tor:has(x, y - 2) then c:put(x, y, PL6[2], plT) c:put(x, y - 1, PL6[5], plT) end end end
for y = 80, 99 do if tor:has(39, y) then c:put(39, y, PL6[2], plT) end end
sepLine(tor, sh, PL6[1], plT)
-- denim bib: twill, straps, gold buttons, stitched pocket
local TW = function(x, y) if (x - y) % 3 == 0 then return -1 end end
local bib = c:rrect(28, 83, 51, 99, 3)
local bT = tok("bib")
Q.body(c, bib, CL6, { R = 3, amb = 0.22, tok = bT, tex = TW })
for _, st in ipairs{ { { 30, 85 }, { 25, 77 } }, { { 49, 85 }, { 54, 77 } } } do
  local m = c:line(st, 3)
  local t = tok("strap")
  Q.body(c, m, CL6, { R = 1.5, amb = 0.3, tok = t })
  sepLine(m, tor:copy():add(sh), CL6[1], t)
end
local pk = c:rrect(34, 89, 45, 96, 1)
Q.body(c, pk, CL6, { R = 1.5, amb = 0.2, tok = tok("pocket"), tex = function(x, y) if (x - y) % 3 == 0 then return -2 end return -1 end })
c:stitch{ { 35, 90 }, { 44, 90 } }
for _, q in ipairs{ { 29, 85 }, { 49, 85 } } do rows(q[1], q[2], { "hb", "bs" }, { h = "#ffe8a0", b = S.btn, s = "#c8923a" }) end
pts({ { 31, 95 }, { 32, 95 }, { 31, 96 } }, S.band.base)

-- neck: shorter, rounded, scaly, with deep folds (dark crease, lit ridge above)
local nk = c:rrect(29, 56 + DY, 50, 82, 4)
local nT = tok("neck")
Q.body(c, nk, SK6, { R = 7, amb = 0.2, tok = nT, tex = scales })
for _, w in ipairs{ { 31, 37, 70 }, { 42, 48, 71 }, { 32, 38, 75 }, { 43, 47, 76 } } do
  for x = w[1], w[2] do local yy = w[3] + ((x == w[1] or x == w[2]) and -1 or 0) c:put(x, yy, SK6[2], nT) c:put(x, yy - 1, SK6[5], nT) end
end

-- head, hat and face are drawn DY px lower than in opus2: shift every put/get in this section
local put0, get0 = c.put, c.get
c.put = function(self, x, y, hex, owner) return put0(self, x, y + DY, hex, owner) end
c.get = function(self, x, y) return get0(self, x, y + DY) end

local hd = c:ellipse(39.5, 43.5, 20.5, 16.5)
hd:add(c:ellipse(39.5, 51, 14, 9))
local hT = tok("head")
Q.body(c, hd, SK6, { sphere = { 36, 42, 25 }, amb = 0.2, wrap = 0.5, cuts = FC, tok = hT, tex = speckle, bounce = BOUNCE, bounceMinX = 30 })
-- crown plates: dark seams with a lit pixel on the upper-left side
for _, l in ipairs{ { { 30, 30 }, { 33, 36 } }, { { 49, 30 }, { 46, 36 } }, { { 33, 36 }, { 46, 36 } }, { { 39, 28 }, { 39, 36 } }, { { 24, 36 }, { 30, 33 } }, { { 55, 36 }, { 49, 33 } } } do
  c:line(l, 1):clip(hd):each(function(x, y) c:put(x, y, SK6[2], hT) end) end
pts({ { 34, 32 }, { 35, 32 }, { 42, 31 }, { 43, 31 }, { 27, 36 } }, SK6[6])
-- jaw scales
for _, q in ipairs{ { 22, 47 }, { 23, 50 }, { 25, 53 }, { 21, 44 }, { 57, 47 }, { 56, 50 }, { 54, 53 }, { 58, 44 }, { 27, 57 }, { 52, 57 } } do
  c:put(q[1], q[2], SK6[2]) c:put(q[1] + 1, q[2], SK6[2]) c:put(q[1], q[2] - 1, SK6[6]) end
-- heavy lidded eyes
for x = 29, 35 do c:put(x, 40, SK6[1]) end for x = 44, 50 do c:put(x, 40, SK6[1]) end
for x = 30, 34 do c:put(x, 39, SK6[3]) c:put(x, 38, SK6[5]) end for x = 45, 49 do c:put(x, 39, SK6[3]) c:put(x, 38, SK6[5]) end
c:eyeLocked(30, 41) c:eyeLocked(45, 41)
pts({ { 31, 47 }, { 32, 47 }, { 33, 47 }, { 46, 47 }, { 47, 47 }, { 48, 47 } }, SK6[2])
-- beak ridge with a lit top, nostrils
pts({ { 38, 44 }, { 39, 44 }, { 40, 44 }, { 39, 45 }, { 40, 45 }, { 39, 46 } }, SK6[6])
pts({ { 41, 45 }, { 41, 46 }, { 40, 47 } }, SK6[3])
pts({ { 36, 49 }, { 37, 49 }, { 42, 49 }, { 43, 49 } }, SK6[1])
pts({ { 36, 48 }, { 42, 48 } }, SK6[5])
-- hooked beak smile with a pale lower jaw (lit left, shaded right)
for x = 31, 48 do c:put(x, 55, INK) end
pts({ { 29, 53 }, { 30, 54 }, { 49, 54 }, { 50, 53 }, { 39, 56 }, { 40, 56 } }, INK)
for x = 32, 47 do for y = 56, 59 do if hd:has(x, y) and not (y == 56 and (x == 39 or x == 40)) then
  c:put(x, y, (y == 59 or x > 44) and PL6[3] or (x < 36 and y == 56 and PL6[6] or PL6[5])) end end end
pts({ { 36, 54 }, { 37, 54 }, { 38, 54 } }, SK6[6])
for _, q in ipairs{ { 24, 50 }, { 52, 50 } } do for dx = 0, 2 do c:put(q[1] + dx, q[2], S.cheek) c:put(q[1] + dx, q[2] + 1, S.cheek) end end
c:put(24, 50, S.cheekhi) c:put(52, 50, S.cheekhi)

-- straw hat: woven brim and crown, band with a lit top, leaf sprig with midribs
local WEAVE = function(x, y)
  local u = (x + (y % 2) * 2) % 4
  if u == 0 then return 1 elseif u == 2 then return -1 end
end
local brim = c:ellipse(39.5, 31, 29, 6.5)
local brT = tok("brim")
Q.body(c, brim, HT6, { R = 3, amb = 0.25, tok = brT, tex = WEAVE, cuts = FC })
Q.side(brim, 0, 1):each(function(x, y) c:put(x, y, HT6[1], brT) end)
Q.side(brim, 0, -1):each(function(x, y) if x < 46 then c:put(x, y, HT6[6], brT) end end)
local cr = c:rrect(26, 11, 53, 31, 7)
local crT = tok("crown")
Q.body(c, cr, HT6, { R = 5, amb = 0.22, tok = crT, tex = WEAVE, cuts = FC })
sepLine(cr, brim, HT6[2], crT)
for x = 26, 53 do if cr:has(x, 24) then c:put(x, 24, BD6[6], crT) c:put(x, 25, BD6[4], crT) c:put(x, 26, x > 46 and BD6[3] or BD6[4], crT) c:put(x, 27, x > 44 and BD6[1] or BD6[2], crT) end end
for x = 27, 52 do c:put(x, 30, HT6[2], crT) end
c:fillMask(c:line({ { 52, 26 }, { 59, 15 } }, 1), BD6[1])
for _, lf in ipairs{ { c:ellipse(61.5, 14, 4, 2.5), { 59, 13 }, { { 58, 14 }, { 64, 14 } } }, { c:ellipse(56.5, 11, 2.5, 4), { 56, 9 }, { { 56, 9 }, { 56, 13 } } }, { c:ellipse(61, 21, 3.5, 2), { 59, 20 }, { { 59, 21 }, { 63, 21 } } } } do
  local t = tok("leaf")
  Q.body(c, lf[1], BD6, { R = 1.5, amb = 0.3, tok = t })
  c:line(lf[3], 1):clip(lf[1]:copy():shrink(1)):each(function(x, y) c:put(x, y, BD6[2], t) end)
  c:put(lf[2][1], lf[2][2], BD6[6])
end
c.put, c.get = put0, get0

-- trowel held up in the right fist: grained handle, bevelled blade with ridge and specular
Q.body(c, c:rect(59, 92, 63, 99), WD6, { R = 1.5, amb = 0.25, tok = tok("handle"), tex = function(x, y) if x == 61 and y % 3 ~= 0 then return -1 end end })
local fist = c:ellipse(61, 89, 5, 4.5)
Q.body(c, fist, SK6, { R = 3, amb = 0.22, tok = tok("fist"), tex = scales })
pts({ { 57, 87 }, { 57, 89 }, { 57, 91 } }, S.nail)
pts({ { 58, 87 }, { 58, 89 } }, "#c8bc9c")
pts({ { 59, 88 }, { 59, 90 } }, SK6[2])
Q.body(c, c:rect(59, 81, 63, 84), MT6, { R = 1, amb = 0.3, tok = tok("collar") })
local bl = c:poly{ { 55, 80 }, { 67, 80 }, { 66, 71 }, { 61, 62 }, { 56, 71 } }
local blT = tok("blade")
bl:each(function(x, y)
  local i = x < 60 and 5 or (x == 60 and 6 or (x == 61 and 2 or 3))
  if not bl:has(x + 1, y) or not bl:has(x, y + 1) then i = 2 end
  if not bl:has(x - 1, y) and x < 60 then i = 6 end
  c:put(x, y, MT6[i], blT)
end)
pts({ { 57, 74 }, { 58, 75 }, { 64, 72 } }, BD6[1]) -- soil
pts({ { 58, 70 }, { 58, 69 } }, "#f6f8fa")
c:finish{ outline = true }
-- backdrop disc (unchanged design)
local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and S.disc.base or S.disc.shade, "bg") end end)
disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then c:put(x, y, S.disc.deep, "bg") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")

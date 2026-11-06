-- folk-tortoise-1 portrait (folk F2_7) variant: 1
-- Generic rest-stop tortoise villager. gardener: straw sun hat with sprig, denim bib, trowel.
local NAME = "folk-tortoise-1"

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", P.cream
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function px(c, x, y, h) if x >= 0 and y >= 0 and x < c.w and y < c.h then c:put(x, y, h) end end
local function pts(c, l, h) for _, q in ipairs(l) do px(c, q[1], q[2], h) end end
local function onBase(c, m, from, to) local l = {} m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], to) end end
-- tortoise shell: marginal scutes on the rim, costal seams, per-variant scute markings
local function shellDeco(c, sh, cx, cy, rx, ry, S, nseg)
  local inner = sh:shrink(2)
  local rim = sh:copy():cut(inner)
  local l = {}
  rim:each(function(x, y) local a = math.atan(y + .5 - cy, x + .5 - cx) local s = (a / (2 * math.pi) + 1) * nseg
    local f = s - math.floor(s) l[#l + 1] = { x, y, f < 0.2 and S.shell.deep or S.shell.shade } end)
  local nc = nseg // 3
  local Rm = (rx + ry) / 2
  inner:each(function(x, y)
    local dx, dy = (x + .5 - cx) / rx, (y + .5 - cy) / ry
    local r = math.sqrt(dx * dx + dy * dy)
    local a = math.atan(dy, dx)
    local s = (a / (2 * math.pi) + 1) * nc + 0.5
    local f = s - math.floor(s)
    local Lg = 2 * math.pi * r * Rm / nc
    local col
    if r > 0.56 and r < 0.56 + 1.1 / ry then col = S.shell.deep
    elseif r > 0.56 and f * Lg < 1 then col = S.shell.deep
    elseif r > 0.6 then
      local du, dv = (f - 0.5) * Lg, (r - 0.79) * Rm
      if S.style == "rings" then local d = math.abs(du) + math.abs(dv)
        if d < 1.2 then col = S.shell.hi elseif d > 2.6 and d < 3.5 then col = S.shell.shade end
      elseif S.style == "blotch" then if math.abs(du) < Lg * 0.28 and math.abs(dv) < 2.2 then col = (du + dv > 1) and S.shell.base or S.shell.hi end
      elseif S.style == "star" then
        local rr = math.abs(du) + math.abs(dv)
        if rr < 1.3 then col = S.ray.hi
        elseif math.sqrt(du * du + dv * dv) < Lg * 0.45 and (math.abs(du) < .6 or math.abs(dv) < .6 or math.abs(du - dv) < .7 or math.abs(du + dv) < .7) then
          col = (du + dv > 0) and S.ray.base or S.ray.hi end
      end
    end
    if col then l[#l + 1] = { x, y, col } end
  end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end
end

local S = {
  skin = R("#bcc98c", "#93a666", "#667a52", "#434d4a"), shell = R("#e8b064", "#c07d3c", "#8a5236", "#57343c"),
  plas = R("#f4e2a4", "#dcbc72", "#a88654", "#6e5448"), style = "rings", nail = "#f2e6c4",
  cloth = R("#93b6d8", "#6188bc", "#465c92", "#323c66"), hat = R("#f8e6a4", "#e4c26c", "#b28c4e", "#765a42"),
  band = R("#b4dc74", "#78b04e", "#4a8048", "#33584a"), metal = R("#e4e8f0", "#adb4c6", "#747c98", "#4c4e68"),
  wood = R("#d89a5c", "#a8693c", "#734534", "#4e2e34"), btn = "#f2c75a", cheek = "#e8948c", cheekhi = "#f4b4a4",
  disc = R("#d4ecf4", "#a4cce4", "#74a2c8", "#4f78a4"),
}
local V = {}
V.clothes = function(c)
  local bib = c:rrect(28, 83, 51, 99, 3)
  c:part(bib, S.cloth, { band = 2, nopop = true })
  c:part(c:line({ { 30, 85 }, { 25, 77 } }, 3), S.cloth, { band = 1, nopop = true })
  c:part(c:line({ { 49, 85 }, { 54, 77 } }, 3), S.cloth, { band = 1, nopop = true })
  for y = 85, 99, 2 do c:put(28, y, S.cloth.hi) end
  local pk = c:rrect(34, 89, 45, 96, 1)
  c:part(pk, S.cloth, { band = 1, nopop = true })
  c:stitch{ { 35, 90 }, { 44, 90 } }
  for _, q in ipairs{ { 29, 85 }, { 49, 85 } } do c:part(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), R(S.btn, S.btn, "#c8923a", "#8a5a32"), { band = 1, nopop = true }) end
  pts(c, { { 31, 95 }, { 32, 95 }, { 31, 96 } }, S.band.base)
end
V.hat = function(c)
  local brim = c:ellipse(39.5, 31, 29, 6.5)
  c:part(brim, S.hat, { band = 2, pop = { x = 14, y = 29 } })
  brim:each(function(x, y) if (x + 2 * y) % 4 == 0 and c:get(x, y) == S.hat.base then c:put(x, y, S.hat.shade) end end)
  brim:each(function(x, y) if not brim:has(x, y + 1) then c:put(x, y, S.hat.deep) end end)
  local cr = c:rrect(26, 11, 53, 31, 7)
  c:part(cr, S.hat, { band = 3, pop = { x = 31, y = 14 } })
  cr:each(function(x, y) if (x + 2 * y) % 4 == 1 and y < 24 and c:get(x, y) == S.hat.base then c:put(x, y, S.hat.shade) end end)
  for x = 26, 53 do c:put(x, 24, S.band.hi) c:put(x, 25, S.band.base) c:put(x, 26, S.band.base) c:put(x, 27, x > 44 and S.band.deep or S.band.shade) end
  for x = 27, 52 do c:put(x, 30, S.hat.shade) end
  c:fillMask(c:line({ { 52, 26 }, { 59, 15 } }, 1), S.band.deep)
  c:part(c:ellipse(61.5, 14, 4, 2.5), S.band, { band = 1, nopop = true })
  c:part(c:ellipse(56.5, 11, 2.5, 4), S.band, { band = 1, nopop = true })
  c:part(c:ellipse(61, 21, 3.5, 2), S.band, { band = 1, nopop = true })
  pts(c, { { 59, 13 }, { 60, 13 }, { 56, 9 }, { 59, 20 } }, S.band.hi)
  c:fillMask(c:line({ { 58, 14 }, { 64, 14 } }, 1):clip(c:ellipse(61.5, 14, 3, 1.5)), S.band.shade)
end
V.prop = function(c) -- trowel held up in the right fist
  c:part(c:rect(59, 92, 63, 99), S.wood, { band = 1, nopop = true })
  local fist = c:ellipse(61, 89, 5, 4.5)
  c:part(fist, S.skin, { band = 2, nopop = true })
  pts(c, { { 57, 87 }, { 57, 89 }, { 57, 91 } }, S.nail)
  pts(c, { { 59, 88 }, { 59, 90 } }, S.skin.shade)
  c:part(c:rect(59, 81, 63, 84), S.metal, { band = 1, nopop = true })
  local bl = c:poly{ { 55, 80 }, { 67, 80 }, { 66, 71 }, { 61, 62 }, { 56, 71 } }
  c:part(bl, S.metal, { band = 2, nopop = true })
  c:fillMask(c:line({ { 60, 65 }, { 60, 79 } }, 1), S.metal.hi)
  c:fillMask(c:line({ { 61, 66 }, { 61, 79 } }, 1), S.metal.shade)
  pts(c, { { 57, 74 }, { 58, 75 }, { 64, 72 } }, S.band.deep)
  c:put(58, 70, S.metal.hi)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local p = { b = 0 }
if V.behind then V.behind(c) end
-- shell dome rising behind the shoulders
local sh = c:ellipse(39.5, 98, 38, 27):clip(c:rect(0, 0, 79, 99))
c:part(sh, S.shell, { band = 3, nopop = true })
shellDeco(c, sh, 39.5, 98.5, 38, 27, S, 24)
if V.onShell then V.onShell(c) end
-- plastron chest
local tor = c:ellipse(39.5, 110, 24, 30):clip(c:rect(0, 0, 79, 99))
c:part(tor, S.plas, { band = 2, nopop = true })
for _, y in ipairs{ 88, 96 } do for x = 16, 63 do if tor:has(x, y) and tor:has(x, y - 2) then c:put(x, y, S.plas.shade) end end end
for y = 80, 99 do if tor:has(39, y) then c:put(39, y, S.plas.shade) end end
if V.clothes then V.clothes(c) end
-- wrinkly neck
local nk = c:rrect(29, 56, 50, 82, 4)
c:part(nk, S.skin, { band = 2, nopop = true })
for _, w in ipairs{ { 31, 36, 66 }, { 43, 48, 66 }, { 33, 38, 71 }, { 42, 46, 72 }, { 31, 35, 76 }, { 44, 48, 77 } } do
  for x = w[1], w[2] do c:put(x, w[3] + ((x == w[1] or x == w[2]) and -1 or 0), S.skin.shade) end
  c:put(w[1] + 1, w[3] + 1, S.skin.hi)
end
if V.collar then V.collar(c) end
-- head: domed skull + blunt beak snout
local hd = c:ellipse(39.5, 43.5, 20.5, 16.5)
hd:add(c:ellipse(39.5, 51, 14, 9))
c:part(hd, S.skin, { band = 3, pop = { x = 26, y = 34 } })
-- head plates on the crown and scale flecks on the jaw
for _, l in ipairs{ { { 30, 30 }, { 33, 36 } }, { { 49, 30 }, { 46, 36 } }, { { 33, 36 }, { 46, 36 } }, { { 39, 28 }, { 39, 36 } }, { { 24, 36 }, { 30, 33 } }, { { 55, 36 }, { 49, 33 } } } do
  c:fillMask(c:line(l, 1):clip(hd), S.skin.shade) end
for _, q in ipairs{ { 22, 47 }, { 23, 50 }, { 25, 53 }, { 21, 44 }, { 57, 47 }, { 56, 50 }, { 54, 53 }, { 58, 44 }, { 27, 57 }, { 52, 57 } } do
  c:put(q[1], q[2], S.skin.shade) c:put(q[1] + 1, q[2], S.skin.shade) c:put(q[1], q[2] - 1, S.skin.hi) end
-- heavy lidded eyes
for x = 29, 35 do c:put(x, 40, S.skin.deep) end for x = 44, 50 do c:put(x, 40, S.skin.deep) end
for x = 30, 34 do c:put(x, 39, S.skin.shade) end for x = 45, 49 do c:put(x, 39, S.skin.shade) end
c:eyeLocked(30, 41) c:eyeLocked(45, 41)
pts(c, { { 31, 47 }, { 32, 47 }, { 33, 47 }, { 46, 47 }, { 47, 47 }, { 48, 47 } }, S.skin.shade)
-- beak ridge, nostrils
pts(c, { { 38, 44 }, { 39, 44 }, { 40, 44 }, { 39, 45 }, { 40, 45 }, { 39, 46 } }, S.skin.hi)
pts(c, { { 36, 49 }, { 37, 49 }, { 42, 49 }, { 43, 49 } }, S.skin.deep)
-- hooked beak smile with pale lower jaw
for x = 31, 48 do c:put(x, 55, INK) end
pts(c, { { 29, 53 }, { 30, 54 }, { 49, 54 }, { 50, 53 }, { 39, 56 }, { 40, 56 } }, INK)
for x = 32, 47 do for y = 56, 59 do if hd:has(x, y) and not (y == 56 and (x == 39 or x == 40)) then c:put(x, y, (y == 59 or x > 44) and S.plas.base or S.plas.hi) end end end
pts(c, { { 36, 54 }, { 37, 54 }, { 38, 54 } }, S.skin.hi)
for _, q in ipairs{ { 24, 50 }, { 52, 50 } } do for dx = 0, 2 do c:put(q[1] + dx, q[2], S.cheek) c:put(q[1] + dx, q[2] + 1, S.cheek) end end
c:put(24, 50, S.cheekhi) c:put(52, 50, S.cheekhi)
if V.hat then V.hat(c) end
if V.prop then V.prop(c) end
c:finish{ outline = true }
backdrop(S.disc)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")

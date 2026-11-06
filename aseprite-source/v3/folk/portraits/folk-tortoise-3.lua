-- folk-tortoise-3 portrait (folk F2_7) variant: 3
-- Generic rest-stop tortoise villager. cook: polka kerchief with bow, apron, soup ladle.
local NAME = "folk-tortoise-3"

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
  skin = R("#e6cc96", "#c4a068", "#8f6e50", "#5e4644"), shell = R("#86644c", "#5c4038", "#432e34", "#2f222c"),
  ray = R("#f2d26a", "#c89c44", "#8e6838", "#5c4038"),
  plas = R("#f4e4b4", "#d8be82", "#a88c62", "#6e5a52"), style = "star", nail = "#f6ead0",
  apron = R("#fbf3dc", "#ece0c4", "#c4b4b0", "#8c7c8c"), kerch = R("#f4a066", "#d6693e", "#9e4638", "#66303a"),
  rose = R("#f8b4bc", "#e2808e", "#b05a74", "#7a3e5c"), copper = R("#f8b484", "#d27a4c", "#984a40", "#62303a"),
  soup = R("#fbd27a", "#e8963e", "#b65e34", "#7e3c34"), steam = "#e6dcec",
  cheek = "#ec8c86", cheekhi = "#f8b0a0", disc = R("#fde0e2", "#f2aab2", "#d07c8e", "#a0566e"),
}
local V = {}
V.clothes = function(c)
  local ap = c:rrect(27, 80, 52, 99, 3)
  c:part(ap, S.apron, { band = 2, nopop = true })
  for y = 84, 99, 2 do c:put(33, y, S.apron.shade) c:put(46, y + 1, S.apron.shade) end
  local pk = c:rrect(34, 89, 45, 97, 2)
  c:part(pk, S.apron, { band = 1, nopop = true })
  c:stitch{ { 35, 90 }, { 44, 90 } }
  c:paint({ ".H.H.", "HHHHH", ".HHH.", "..H.." }, 37, 92, { H = "petal.base" })
  for x = 27, 52, 3 do c:put(x, 80, S.rose.base) end
end
V.collar = function(c)
  c:part(c:line({ { 29, 81 }, { 31, 71 } }, 2), S.rose, { band = 1, nopop = true })
  c:part(c:line({ { 50, 81 }, { 48, 71 } }, 2), S.rose, { band = 1, nopop = true })
end
V.hat = function(c)
  local k = c:ellipse(39.5, 42, 22, 17):clip(c:rect(0, 0, 79, 37))
  c:part(k, S.kerch, { band = 3, pop = { x = 25, y = 30 } })
  for x = 17, 62 do if k:has(x, 37) then c:put(x, 37, S.kerch.deep) c:put(x, 36, S.kerch.shade) end end
  local dots = {}
  for _, q in ipairs{ { 26, 31 }, { 33, 28 }, { 41, 27 }, { 49, 29 }, { 22, 35 }, { 30, 34 }, { 38, 33 }, { 46, 34 }, { 54, 33 }, { 57, 29 }, { 36, 30 } } do
    if k:has(q[1], q[2]) and k:has(q[1] + 1, q[2] + 1) then pts(c, { q, { q[1] + 1, q[2] }, { q[1], q[2] + 1 }, { q[1] + 1, q[2] + 1 } }, CREAM) c:put(q[1] + 1, q[2] + 1, S.apron.shade) end
  end
  local bow = c:ellipse(51, 19, 5, 3.5) bow:add(c:ellipse(60, 17, 4.5, 3.5))
  c:part(bow, S.kerch, { band = 2, nopop = true })
  pts(c, { { 49, 17 }, { 50, 17 }, { 59, 15 } }, S.kerch.hi)
  pts(c, { { 52, 20 }, { 61, 18 } }, CREAM)
  c:part(c:ellipse(55.5, 21, 2.5, 2.5), S.kerch, { band = 1, nopop = true })
end
V.prop = function(c) -- ladle of soup, steam curling
  c:part(c:line({ { 17, 96 }, { 14, 76 }, { 13, 67 } }, 3), S.copper, { band = 1, nopop = true })
  local fist = c:ellipse(17, 89, 5, 4.5)
  c:part(fist, S.skin, { band = 2, nopop = true })
  pts(c, { { 21, 87 }, { 21, 89 }, { 21, 91 } }, S.nail)
  local bowl = c:ellipse(13, 62, 7.5, 5)
  c:part(bowl, S.copper, { band = 2, nopop = true })
  for x = 7, 19 do for y = 59, 60 do if bowl:shrink(1):has(x, y) then c:put(x, y, y == 59 and S.soup.base or S.soup.shade) end end end
  pts(c, { { 9, 59 }, { 10, 59 }, { 12, 60 } }, S.soup.hi)
  pts(c, { { 8, 63 }, { 8, 64 } }, S.copper.hi)
  pts(c, { { 12, 56 }, { 11, 55 }, { 11, 54 }, { 12, 53 }, { 13, 52 }, { 13, 51 }, { 12, 50 }, { 16, 56 }, { 17, 55 }, { 17, 54 }, { 16, 53 } }, S.steam)
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

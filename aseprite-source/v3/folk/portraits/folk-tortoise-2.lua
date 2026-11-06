-- folk-tortoise-2 portrait (folk F2_7) variant: 2
-- Generic rest-stop tortoise villager. traveller: flat cap, scarf, bedroll on shell, satchel, lantern.
local NAME = "folk-tortoise-2"

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
  skin = R("#b4c8bc", "#86a096", "#5b7272", "#3c4a58"), shell = R("#a8a062", "#7a7442", "#544e3a", "#38323a"),
  plas = R("#e8dcb0", "#c8b884", "#988a68", "#665c58"), style = "blotch", nail = "#ece2c8",
  scarf = R("#f08478", "#cc4a4c", "#933446", "#5e2840"), cap = R("#c09ad0", "#8e64a4", "#634884", "#433460"),
  canvas = R("#e4cc9a", "#bd9d6a", "#8a6c50", "#5c4640"), leather = R("#c0845a", "#91583e", "#643a36", "#422630"),
  brass = R("#f6d670", "#d09c3c", "#956236", "#623c34"), glass = R("#fff2c4", "#ffd86e", "#f0a848", "#c06a3c"),
  cheek = "#e08a90", cheekhi = "#f0aeb0", disc = R("#ffe4a8", "#f2c262", "#d29a48", "#a86e40"),
}
local V = {}
V.onShell = function(c)
  local roll = c:rrect(4, 62, 75, 73, 5)
  c:part(roll, S.canvas, { band = 2, nopop = true })
  for x = 8, 71 do c:put(x, 63, S.canvas.hi) end
  for x = 8, 71, 5 do c:put(x, 67, S.canvas.shade) c:put(x + 1, 68, S.canvas.shade) end
  for _, e in ipairs{ { 6, 1 }, { 73, -1 } } do pts(c, { { e[1], 65 }, { e[1], 66 }, { e[1], 67 }, { e[1] + e[2], 68 }, { e[1] + 2 * e[2], 67 }, { e[1] + 2 * e[2], 66 } }, S.canvas.deep) end
  for _, sx in ipairs{ 15, 62 } do for y = 62, 73 do c:put(sx, y, S.leather.base) c:put(sx + 1, y, S.leather.base) c:put(sx + 2, y, S.leather.shade) end c:put(sx, 66, S.brass.base) end
end
V.clothes = function(c)
  c:part(c:line({ { 25, 80 }, { 54, 99 } }, 3), S.leather, { band = 1, nopop = true })
  c:stitch{ { 28, 81 }, { 50, 95 } }
end
V.collar = function(c)
  c:part(c:rrect(26, 67, 53, 78, 4), S.scarf, { band = 2, nopop = true })
  for x = 29, 50, 4 do c:fillMask(c:line({ { x, 70 }, { x + 2, 76 } }, 1), S.scarf.shade) end
  for x = 28, 50 do c:put(x, 68, S.scarf.hi) end
  local tail = c:poly{ { 29, 75 }, { 36, 75 }, { 34, 94 }, { 27, 94 } }
  c:part(tail, S.scarf, { band = 2, nopop = true })
  for x = 27, 34, 2 do c:put(x, 95, S.scarf.shade) c:put(x, 96, S.scarf.shade) end
  for y = 80, 92, 4 do for x = 28, 35 do if tail:has(x, y) then c:put(x, y, S.scarf.shade) end end end
end
V.hat = function(c)
  local cap = c:ellipse(38.5, 32, 21, 11):clip(c:rect(0, 0, 79, 34))
  c:part(cap, S.cap, { band = 3, pop = { x = 26, y = 25 } })
  for x = 17, 60 do if cap:has(x, 33) then c:put(x, 33, S.cap.shade) c:put(x, 34, S.cap.deep) end end
  c:fillMask(c:line({ { 27, 25 }, { 50, 23 } }, 1):clip(cap), S.cap.shade)
  c:fillMask(c:line({ { 27, 26 }, { 50, 24 } }, 1):clip(cap), S.cap.hi)
  local vis = c:ellipse(44, 35.5, 16, 3):clip(c:rect(0, 34, 79, 40))
  c:part(vis, S.cap, { band = 1, nopop = true })
  vis:each(function(x, y) if not vis:has(x, y + 1) then c:put(x, y, S.cap.deep) end end)
  for x = 30, 56 do if vis:has(x, 34) then c:put(x, 34, S.cap.hi) end end
  c:part(c:ellipse(38.5, 21, 2, 1.5), S.cap, { band = 1, nopop = true })
end
V.prop = function(c) -- lantern held up beside the face
  local fist = c:ellipse(13, 70, 4.5, 4)
  c:part(fist, S.skin, { band = 2, nopop = true })
  pts(c, { { 15, 73 }, { 17, 72 }, { 17, 70 } }, S.nail)
  pts(c, { { 12, 74 }, { 12, 75 }, { 13, 76 } }, INK)
  c:part(c:rrect(7, 77, 19, 80, 1), S.brass, { band = 1, pop = { x = 8, y = 77 } })
  local gl = c:rect(8, 81, 18, 91)
  c:part(gl, S.glass, { band = 3, nopop = true })
  for y = 81, 91 do c:put(8, y, S.brass.shade) c:put(18, y, S.brass.deep) c:put(13, y, S.brass.base) end
  pts(c, { { 10, 86 }, { 11, 85 }, { 11, 86 }, { 11, 87 }, { 10, 87 }, { 15, 85 }, { 15, 86 }, { 16, 86 }, { 15, 87 } }, S.glass.shade)
  pts(c, { { 10, 82 }, { 10, 83 }, { 15, 82 } }, S.glass.hi)
  c:part(c:rrect(7, 92, 19, 95, 1), S.brass, { band = 1, nopop = true })
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

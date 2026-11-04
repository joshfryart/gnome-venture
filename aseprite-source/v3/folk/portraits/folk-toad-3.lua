-- folk-toad-3 portrait (folk F2_9) variant: 3
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local GOLDI = "#dca23c"
local function R(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
local function hash(x, y, s) local n = math.sin(x * 12.9898 + y * 78.233 + s * 37.719) * 43758.5453 return n - math.floor(n) end
local function warts(c, m, r, seed, dens)
  local l = {}
  m:each(function(x, y) if hash(x, y, seed) < dens and m:has(x - 1, y - 1) and m:has(x + 2, y + 2) then l[#l + 1] = { x, y } end end)
  for _, p in ipairs(l) do
    local v = c:get(p[1], p[2])
    if v == r.base or v == r.shade then c:put(p[1], p[2], r.hi) c:put(p[1] + 1, p[2] + 1, r.deep) end
  end
end
local H = {}
local NAME = "folk-toad-3"
local S = R("#ec9a6c", "#bc5e44", "#86394c", "#542a46")
local B = R("#fcdcb4", "#eab890", "#bc8a84", "#7c5a6c")
local AP = R("#fff4dc", "#eedcb8", "#c4aa9a", "#8a748a")
local KS = R("#ffe27c", "#e8ba34", "#b07e36", "#704c3a")
local WD = R("#e0aa66", "#ac7240", "#744838", "#46283e")
local SOUP = "#f0a040"
local DISC = R("#ddccee", "#b89ad0", "#8e72b0", "#634e88")
H.clothes = function(c)
  c:part(c:rrect(27, 82, 52, 99, 3), AP, { band = 2, pop = { x = 29, y = 84 } })
  c:part(c:line({ { 30, 83 }, { 33, 73 } }, 2), AP, { band = 1, nopop = true })
  c:part(c:line({ { 49, 83 }, { 46, 73 } }, 2), AP, { band = 1, nopop = true })
  for x = 27, 52 do c:put(x, 86, KS.base) c:put(x, 87, KS.shade) end
  c:part(c:rrect(33, 90, 46, 98, 2), AP, { band = 1, nopop = true })
  c:stitch({ { 34, 91 }, { 45, 91 } })
  c:paint({ "r.r", "rrr", ".r." }, 38, 93, { r = "ember.base" })
end
H.top = function(c)
  local ks = c:ellipse(39.5, 42, 17, 9):clip(c:rect(0, 0, 79, 46))
  c:part(ks, KS, { band = 2, pop = { x = 28, y = 35 } })
  for _, q in ipairs({ { 31, 36 }, { 37, 34 }, { 43, 36 }, { 48, 35 }, { 26, 38 }, { 53, 38 }, { 40, 38 }, { 34, 39 }, { 46, 39 } }) do if ks:has(q[1], q[2]) then c:put(q[1], q[2], AP.hi) end end
  local bow = c:ellipse(39.5, 32, 2, 2)
  bow:add(c:ellipse(34.5, 31, 3.5, 2)) bow:add(c:ellipse(44.5, 31, 3.5, 2))
  c:part(bow, KS, { band = 1, pop = { x = 32, y = 30 } })
  c:put(39, 32, KS.deep) c:put(40, 32, KS.deep)
end
H.front = function(c)
  c:part(c:line({ { 64, 97 }, { 66, 74 }, { 67, 58 } }, 3), WD, { band = 1, nopop = true })
  c:part(c:ellipse(67.5, 53, 6, 4.5), WD, { band = 2, pop = { x = 63, y = 51 } })
  c:fillMask(c:ellipse(67.5, 51.5, 4, 1.8), SOUP)
  c:put(65, 51, "#ffd070") c:put(66, 51, "#ffd070")
  c:put(73, 55, SOUP) c:put(73, 56, SOUP)
  c:part(c:ellipse(64, 89, 4.5, 3.5), S, { band = 1, pop = { x = 62, y = 87 } })
  c:put(62, 92, S.deep) c:put(65, 92, S.deep)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
if H.back then H.back(c) end
local body = c:ellipse(39.5, 100, 30, 26):clip(c:rect(0, 0, 79, 99))
c:part(body, S, { band = 3, pop = { x = 17, y = 86 } })
warts(c, body, S, 5, 0.03)
c:part(c:ellipse(39.5, 96, 14, 12):clip(c:rect(0, 0, 79, 99)), B, { band = 1, nopop = true })
if H.clothes then H.clothes(c) end
local head = c:ellipse(39.5, 57, 19.5, 15)
head:add(c:ellipse(21.5, 53, 3, 2.5)) head:add(c:ellipse(57.5, 53, 3, 2.5))
c:part(head, S, { band = 3, pop = { x = 27, y = 47 } })
warts(c, head, S, 11, 0.035)
c:part(c:ellipse(39.5, 70, 13, 4):clip(head), B, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 58, 5, 3), S, { band = 1, pop = { x = 37, y = 56 } })
c:put(37, 59, S.deep) c:put(41, 59, S.deep)
c:fillMask(c:line({ { 22, 61 }, { 25, 64 }, { 31, 65 }, { 39, 66 }, { 40, 66 }, { 48, 65 }, { 54, 64 }, { 57, 61 } }, 1), INK)
for _, q in ipairs({ { 24, 60 }, { 25, 60 }, { 26, 60 }, { 52, 60 }, { 53, 60 }, { 54, 60 } }) do c:put(q[1], q[2], P.petal.base) end
if H.top then H.top(c) end
for _, ex in ipairs({ 30.5, 48.5 }) do
  c:part(c:ellipse(ex, 44, 7, 6), S, { band = 2, pop = { x = math.floor(ex) - 4, y = 40 } })
  c:fillMask(c:ellipse(ex, 43.5, 3.6, 3.6), GOLDI)
end
c:eyeLocked(28, 41) c:eyeLocked(46, 41)
for _, ex in ipairs({ 28, 46 }) do for i = 0, 4 do c:put(ex + i, 39, S.shade) end end
if H.front then H.front(c) end
c:finish{ outline = true }
backdrop(DISC)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")

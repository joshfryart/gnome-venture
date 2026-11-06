-- folk-toad-2 portrait (folk F2_9) variant: 2
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
local NAME = "folk-toad-2"
local S = R("#e2ba7a", "#b2884e", "#7c5c4c", "#4a3a50")
local B = R("#f6ecc0", "#e0cc94", "#ae9a7e", "#706070")
local SC = R("#86dcc8", "#3ca2a2", "#2c6c80", "#283e5c")
local PK = R("#8e94d4", "#5c60aa", "#40407c", "#2e2a54")
local RL = R("#e47e8c", "#b24c64", "#7c3252", "#4e2442")
local BR = R("#fff0a6", "#e8b244", "#aa723c", "#6a4436")
local DISC = R("#c4ece2", "#8ad0c0", "#5aa0a0", "#3a7280")
H.back = function(c)
  local rl = c:ellipse(39.5, 40, 27, 5.5)
  c:part(rl, RL, { band = 2, pop = { x = 16, y = 37 } })
  for _, x in ipairs({ 22, 23, 56, 57 }) do for y = 34, 46 do if rl:has(x, y) then c:put(x, y, (x == 22 or x == 56) and PK.base or PK.shade) end end end
  for _, q in ipairs({ { 13, 40 }, { 14, 39 }, { 15, 40 }, { 14, 41 }, { 64, 40 }, { 65, 39 }, { 66, 40 }, { 65, 41 } }) do c:put(q[1], q[2], RL.deep) end
end
H.clothes = function(c)
  c:part(c:line({ { 24, 76 }, { 21, 99 } }, 4), PK, { band = 1, nopop = true })
  c:part(c:line({ { 55, 76 }, { 58, 99 } }, 4), PK, { band = 1, nopop = true })
  c:part(c:rect(20, 88, 24, 90), BR, { band = 1, nopop = true })
  c:part(c:rect(55, 88, 59, 90), BR, { band = 1, nopop = true })
  c:part(c:rrect(20, 70, 59, 79, 4), SC, { band = 2, pop = { x = 23, y = 73 } })
  c:part(c:poly({ { 27, 77 }, { 34, 77 }, { 32, 95 }, { 25, 93 } }), SC, { band = 1, nopop = true })
  for _, q in ipairs({ { 25, 94 }, { 27, 95 }, { 29, 96 }, { 31, 96 } }) do c:put(q[1], q[2], SC.shade) end
  for x = 24, 56, 4 do c:put(x, 76, SC.shade) c:put(x, 77, SC.shade) end
end
H.top = function(c)
  for y = 42, 54 do c:put(39, y, "#f6de70") c:put(40, y, "#d8b04e") end
  for _, q in ipairs({ { 25, 52 }, { 27, 56 }, { 52, 52 }, { 50, 56 }, { 33, 50 }, { 45, 50 } }) do c:put(q[1], q[2], S.shade) c:put(q[1] + 1, q[2], S.shade) c:put(q[1], q[2] + 1, S.shade) end
end
H.front = function(c)
  c:fillMask(c:line({ { 57, 80 }, { 63, 82 } }, 1), BR.deep)
  c:part(c:ellipse(63.5, 83, 2, 1.5), BR, { band = 1, nopop = true })
  c:part(c:poly({ { 59, 88 }, { 68, 88 }, { 66, 85 }, { 61, 85 } }), BR, { band = 1, pop = { x = 61, y = 85 } })
  c:part(c:rect(59, 89, 68, 97), BR, { band = 1, nopop = true })
  for y = 90, 96 do for x = 60, 67 do c:put(x, y, (x == 63 or x == 64) and BR.shade or ((x < 63 and y < 93) and "#fff2bc" or "#ffd862")) end end
  c:part(c:rect(58, 98, 69, 99), BR, { band = 1, nopop = true })
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

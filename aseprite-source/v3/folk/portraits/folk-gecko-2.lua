-- folk-gecko-2 portrait (folk F2_11) variant: 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", "#f6ecd2"
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function dots(c, m, list, hex) for _, q in ipairs(list) do if m:has(q[1], q[2]) then c:px(q[1], q[2], hex) end end end
local function recol(c, m, from, to) local l = {} m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:px(q[1], q[2], to) end end
local function spike(c, cx, cy, rx, ry, deg, len)
  local a = math.rad(deg)
  local ex, ey = cx + math.cos(a) * rx, cy + math.sin(a) * ry
  local nx, ny = -math.sin(a), math.cos(a)
  return c:poly{ { ex + nx * 1.6, ey + ny * 1.6 }, { ex - nx * 1.6, ey - ny * 1.6 }, { ex + math.cos(a) * len, ey + math.sin(a) * len } }
end
local function noop() end
local S = R("#c6f286", "#72cc56", "#3c8c5c", "#265a5e")
local SPOT, MOUTH, PETAL = "#e8583e", "#2e4048", "#f08aa0"
local TUNIC = R("#f6aa6a", "#d26c3c", "#9c4442", "#642c44")
local SCARF = R("#f392c0", "#c84c8c", "#8c2e74", "#5a2054")
local CAP = R("#d8a874", "#a0704c", "#6c4a4a", "#46303e")
local CANVAS = R("#f0dca6", "#cfb07a", "#9a7c5e", "#66504c")
local ROLL = R("#a6bce0", "#6c88c0", "#4c5c96", "#323c6c")
local BRASS = R("#ffe28c", "#e0aa3c", "#a8703a", "#6c4434")
local GLOW = R("#fff4c0", "#ffd36a", "#eaa64a", "#b06a3a")
local BG = R("#f4c8e0", "#e7b4d2", "#c088b2", "#8e5c8c")
local ARM, BODY = TUNIC, TUNIC
local deco_pre = noop
local NAME = "folk-gecko-2"
local function back(c)
  c:part(c:rrect(6, 64, 23, 99, 3), CANVAS, { band = 2, pop = { x = 8, y = 70 } })
  c:part(c:rrect(6, 64, 23, 73, 2), R(CANVAS.base, CANVAS.shade, CANVAS.deep, CANVAS.deep), { band = 1, nopop = true })
  c:part(c:rect(13, 74, 16, 76), BRASS, { band = 1, nopop = true })
  c:part(c:ellipse(14.5, 61, 9.5, 4), ROLL, { band = 2, pop = { x = 9, y = 59 } })
  for y = 58, 64 do c:px(9, y, ROLL.deep) c:px(20, y, ROLL.deep) end
end
local function clothes(c, body)
  c:part(c:line({ { 27, 78 }, { 31, 99 } }, 3), CANVAS, { band = 1, nopop = true })
  c:part(c:rect(14, 93, 66, 95):clip(body), CAP, { band = 1, nopop = true })
  c:part(c:rect(38, 93, 41, 95), BRASS, { band = 1, nopop = true })
  local sc = c:ellipse(39.5, 73, 18, 5)
  c:part(sc, SCARF, { band = 2, pop = { x = 26, y = 71 } })
  local tail = c:poly{ { 44, 75 }, { 51, 75 }, { 52, 91 }, { 45, 89 } }
  c:part(tail, SCARF, { band = 1, nopop = true })
  for _, x in ipairs{ 46, 48, 50 } do c:px(x, 91, SCARF.shade) end
  for x = 30, 50, 4 do c:px(x, 74, SCARF.shade) c:px(x + 1, 75, SCARF.shade) end
  c:part(c:line({ { 57, 99 }, { 59, 90 } }, 5), TUNIC, { band = 1, nopop = true })
end
local function deco(c, head)
  dots(c, head, { { 25, 48 }, { 33, 46 }, { 46, 46 }, { 54, 49 }, { 39, 44 }, { 29, 51 }, { 50, 51 }, { 21, 52 }, { 58, 52 }, { 39, 48 } }, SPOT)
  for _, q in ipairs{ { 33, 46 }, { 46, 46 }, { 39, 44 } } do c:px(q[1] + 1, q[2], SPOT) c:px(q[1], q[2] + 1, SPOT) end
end
local function hat(c)
  local dome = c:ellipse(39.5, 36, 17, 10) dome:clip(c:rect(0, 0, 79, 36))
  c:part(dome, CAP, { band = 2, pop = { x = 30, y = 30 } })
  for y = 27, 36 do c:px(39, y, CAP.shade) end
  c:fillMask(c:line({ { 30, 34 }, { 33, 28 } }, 1), CAP.shade) c:fillMask(c:line({ { 49, 34 }, { 46, 28 } }, 1), CAP.deep)
  c:part(c:ellipse(39.5, 25.5, 2, 1.5), CAP, { band = 1, nopop = true })
  c:part(c:ellipse(39.5, 37, 16, 2), R(CAP.base, CAP.shade, CAP.deep, CAP.deep), { band = 1, nopop = true })
end
local function prop(c)
  c:fillMask(c:line({ { 54, 70 }, { 59, 65 }, { 64, 70 } }, 1), BRASS.deep)
  c:part(c:rect(54, 70, 64, 72), BRASS, { band = 1, pop = { x = 55, y = 70 } })
  local g = c:rect(55, 73, 63, 83)
  c:part(g, GLOW, { band = 2, pop = { x = 57, y = 75 } })
  c:px(57, 75, GLOW.hi) c:px(57, 76, GLOW.hi) c:px(58, 75, GLOW.hi)
  for y = 73, 83 do c:px(59, y, BRASS.shade) end
  for x = 55, 63 do c:px(x, 78, BRASS.shade) end
  c:part(c:rect(53, 84, 65, 86), BRASS, { band = 1, nopop = true })
  local h = c:ellipse(59, 88.5, 4, 2.5)
  for _, x in ipairs{ 55, 59, 63 } do h:add(c:rect(x, 86, x, 87)) end
  c:part(h, S, { band = 1, nopop = true })
  c:px(55, 86, S.hi) c:px(59, 86, S.hi) c:px(63, 86, S.hi)
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
back(c)
c:part(c:rect(30, 58, 49, 74), S, { band = 2, nopop = true })
local body = c:ellipse(39.5, 101, 30, 31) body:clip(c:rect(0, 0, 79, 99))
c:part(body, BODY, { band = 2, pop = { x = 22, y = 82 } })
clothes(c, body)
deco_pre(c)
local head = c:ellipse(39.5, 48, 20.5, 15)
head:add(c:ellipse(29, 41, 6.5, 6)) head:add(c:ellipse(50, 41, 6.5, 6))
c:part(head, S, { band = 3, pop = { x = 25, y = 37 } })
recol(c, c:ellipse(39.5, 54, 10, 3.5), S.base, S.hi)
deco(c, head)
for _, q in ipairs{ { 36, 51 }, { 37, 51 }, { 42, 51 }, { 43, 51 } } do c:px(q[1], q[2], S.deep) end
c:px(36, 50, S.shade) c:px(43, 50, S.shade)
c:fillMask(c:line({ { 25, 56 }, { 31, 59 }, { 39, 60 }, { 48, 59 }, { 54, 56 } }, 1), MOUTH)
c:px(24, 55, MOUTH) c:px(55, 55, MOUTH)
c:paint({ "ttt", ".t." }, 38, 60, { t = "petal.base" })
for _, q in ipairs{ { 21, 53 }, { 22, 53 }, { 21, 54 }, { 22, 54 }, { 57, 53 }, { 58, 53 }, { 57, 54 }, { 58, 54 } } do c:px(q[1], q[2], PETAL) end
for _, x in ipairs{ 27, 48 } do for i = 1, 3 do c:px(x + i, 38, S.deep) end end
c:eyeLocked(27, 39) c:eyeLocked(48, 39)
hat(c)
prop(c)
c:finish{ outline = true }
backdrop(c, BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")

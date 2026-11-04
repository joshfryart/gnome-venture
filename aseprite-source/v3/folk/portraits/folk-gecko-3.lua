-- folk-gecko-3 portrait (folk F2_11) variant: 3
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
local S = R("#f0d2e6", "#c29ccc", "#8a74a8", "#584e7e")
local SPOT, MOUTH, PETAL = "#f6e2c8", "#4a2850", "#f07890"
local SMOCK = R("#96d0f2", "#4e90d4", "#3a5ca6", "#283c74")
local APRON = R("#fbf0d4", "#ead9b2", "#bfae98", "#857a86")
local KERCH = R("#ff8a7a", "#e04c50", "#a83048", "#6c2040")
local COPPER = R("#ffc08a", "#e0804a", "#a8523e", "#6c3238")
local SOUP = R("#f8c868", "#d8963a", "#a8643a", "#6c3a38")
local BG = R("#c4e6f2", "#a8d8e8", "#7aaed0", "#5a7eaa")
local ARM, BODY = SMOCK, SMOCK
local NAME = "folk-gecko-3"
local function back(c) end
local function clothes(c, body)
  local ap = c:rrect(29, 82, 50, 99, 3)
  c:part(ap, APRON, { band = 2, pop = { x = 31, y = 84 } })
  c:part(c:line({ { 31, 83 }, { 34, 76 } }, 2), APRON, { band = 1, nopop = true })
  c:part(c:line({ { 48, 83 }, { 45, 76 } }, 2), APRON, { band = 1, nopop = true })
  for x = 34, 45 do c:px(x, 90, APRON.shade) end
  for y = 90, 96 do c:px(34, y, APRON.shade) c:px(45, y, APRON.shade) end
  for y = 90, 96 do c:px(39, y, APRON.shade) end
  c:part(c:line({ { 59, 99 }, { 60, 90 } }, 5), SMOCK, { band = 1, nopop = true })
end
local function deco_pre(c)
  local m = HP.mask()
  for a = 145, 215, 12 do m:add(spike(c, 39.5, 48, 20, 14.5, a, 4)) end
  for a = -35, 35, 12 do m:add(spike(c, 39.5, 48, 20, 14.5, a, 4)) end
  for _, a in ipairs{ 200, 230 } do m:add(spike(c, 29, 41, 6, 5.5, a, 3)) end
  for _, a in ipairs{ 310, 340 } do m:add(spike(c, 50, 41, 6, 5.5, a, 3)) end
  c:part(m, S, { band = 1, nopop = true })
end
local function deco(c, head)
  dots(c, head, { { 21, 46 }, { 20, 50 }, { 22, 54 }, { 58, 46 }, { 59, 50 }, { 57, 54 }, { 24, 43 }, { 55, 43 }, { 33, 47 }, { 46, 47 } }, SPOT)
end
local function hat(c)
  local k = c:ellipse(39.5, 37, 13, 7) k:clip(c:rect(0, 0, 79, 38))
  k:add(c:ellipse(53, 30, 3.5, 2.5)) k:add(c:ellipse(57.5, 27.5, 2.5, 2)) k:add(c:ellipse(56.5, 33, 2, 2.5))
  c:part(k, KERCH, { band = 2, pop = { x = 31, y = 32 } })
  dots(c, k, { { 32, 33 }, { 37, 31 }, { 42, 32 }, { 47, 33 }, { 35, 36 }, { 40, 35 }, { 45, 37 }, { 29, 37 }, { 57, 27 } }, SPOT)
end
local function prop(c)
  c:part(c:line({ { 60, 86 }, { 63, 67 } }, 2), COPPER, { band = 1, nopop = true })
  c:part(c:ellipse(64, 63, 5, 3.5), COPPER, { band = 2, pop = { x = 61, y = 61 } })
  c:part(c:ellipse(64, 62, 3.5, 1.5), SOUP, { band = 1, pop = { x = 62, y = 61 } })
  local h = c:ellipse(60, 87.5, 3.5, 2.5)
  for _, x in ipairs{ 57, 60, 63 } do h:add(c:rect(x, 85, x, 85)) end
  c:part(h, S, { band = 1, nopop = true })
  c:px(57, 85, S.hi) c:px(60, 85, S.hi) c:px(63, 85, S.hi)
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

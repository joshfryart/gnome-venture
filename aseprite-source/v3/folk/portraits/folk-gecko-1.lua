-- folk-gecko-1 portrait (folk F2_11) variant: 1
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
local S = R("#ffcf8e", "#f29a52", "#b8604c", "#7a3a4c")
local SPOT, MOUTH, PETAL = "#8a4058", "#5a2440", "#f58a8a"
local STRAW = R("#fbe9a6", "#e6c766", "#b48f56", "#7c5e4e")
local BAND = R("#f07a5a", "#d0463a", "#9a2e3e", "#621e36")
local OVR = R("#a6dc72", "#5fae4c", "#3d7c4c", "#285450")
local WOOD = R("#e0a870", "#b47448", "#80504a", "#523640")
local METAL = R("#e4ecf0", "#a8b8c8", "#7080a0", "#4a5070")
local LEAF = R("#b8e880", "#78c050", "#4a8848", "#2e5a44")
local GOLD = R("#ffe08a", "#f0b840", "#b87c3a", "#7a4c38")
local BG = R("#e8f2b0", "#d6e49a", "#adc070", "#7c9058")
local ARM, BODY = S, S
local deco_pre = noop
local NAME = "folk-gecko-1"
local function back(c) end
local function clothes(c, body)
  local ov = c:rrect(27, 82, 52, 99, 3)
  ov:add(c:line({ { 29, 83 }, { 26, 76 } }, 3)) ov:add(c:line({ { 50, 83 }, { 53, 76 } }, 3))
  ov:clip(body)
  c:part(ov, OVR, { band = 2, pop = { x = 29, y = 84 } })
  for x = 34, 45 do c:px(x, 89, OVR.shade) end
  for y = 89, 95 do c:px(34, y, OVR.shade) c:px(45, y, OVR.shade) end
  c:px(30, 85, GOLD.base) c:px(49, 85, GOLD.base) c:px(30, 84, GOLD.hi) c:px(49, 84, GOLD.hi)
  dots(c, body, { { 18, 88 }, { 22, 84 }, { 58, 86 }, { 62, 90 }, { 15, 94 }, { 56, 95 } }, SPOT)
  c:part(c:line({ { 24, 99 }, { 19, 88 } }, 5), S, { band = 1, nopop = true })
end
local function deco(c, head)
  dots(c, head, { { 24, 47 }, { 31, 46 }, { 47, 46 }, { 55, 48 }, { 22, 52 }, { 57, 52 }, { 33, 50 }, { 46, 50 }, { 39, 46 }, { 28, 52 }, { 51, 52 }, { 39, 42 } }, SPOT)
  for _, q in ipairs{ { 24, 47 }, { 31, 46 }, { 47, 46 }, { 55, 48 } } do if head:has(q[1] + 1, q[2]) then c:px(q[1] + 1, q[2], SPOT) end end
end
local function hat(c)
  local brim = c:ellipse(39.5, 33, 25, 5)
  c:part(brim, STRAW, { band = 2, pop = { x = 20, y = 31 } })
  for x = 16, 63, 3 do if brim:has(x, 35) then c:px(x, 35, STRAW.shade) end end
  local crown = c:rrect(28, 14, 51, 32, 6)
  c:part(crown, STRAW, { band = 2, pop = { x = 31, y = 17 } })
  for y = 17, 25, 2 do for x = 29 + (y % 4 == 3 and 1 or 0), 50, 3 do if crown:has(x, y) then c:px(x, y, STRAW.shade) end end end
  for x = 28, 51 do c:px(x, 33, STRAW.deep) end
  c:part(c:rect(28, 27, 51, 30), BAND, { band = 1, nopop = true })
  c:fillMask(c:line({ { 30, 28 }, { 26, 23 }, { 23, 20 } }, 1), LEAF.deep)
  c:part(c:ellipse(22, 19, 2.5, 1.8), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(27, 22, 2, 1.5), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(24, 25, 1.5, 1.2), LEAF, { band = 1, nopop = true })
  c:px(21, 18, LEAF.hi)
end
local function prop(c)
  c:part(c:rect(17, 75, 19, 85), WOOD, { band = 1, nopop = true })
  c:px(18, 78, WOOD.shade) c:px(18, 82, WOOD.shade)
  c:part(c:rect(15, 73, 21, 74), METAL, { band = 1, nopop = true })
  local bl = c:poly{ { 13, 72 }, { 23, 72 }, { 18, 60 } }
  c:part(bl, METAL, { band = 2, pop = { x = 16, y = 68 } })
  for y = 63, 71 do c:px(18, y, METAL.shade) end
  local h = c:ellipse(18.5, 86, 3.5, 2.5)
  for _, x in ipairs{ 15, 18, 21 } do h:add(c:rect(x, 88, x + 1, 89)) end
  c:part(h, S, { band = 1, nopop = true })
  c:px(15, 88, S.hi) c:px(18, 88, S.hi) c:px(21, 88, S.hi)
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

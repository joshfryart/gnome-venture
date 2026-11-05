-- folk-hedgehog-1 portrait (folk F1_0) variant: 1
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R4(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SKIN = R4("#f6dfb0", "#e0b986", "#b38469", "#7d5763")
local PAW = R4("#e9b89a", "#c98d78", "#9a6468", "#6a4458")
local NOSE, NOSEHI, BLUSH = "#4a2c3c", "#8a5a6a", "#e8968a"
local function rnd(v) return math.floor(v + 0.5) end
local function spiky(c, cx, cy, rx, ry, a0, a1, n, len, w)
  local m = c:ellipse(cx, cy, rx, ry)
  local tips = {}
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * (i + 0.5) / n)
    local ww = math.rad(w)
    local x1, y1 = cx + math.cos(a - ww) * rx * 0.92, cy + math.sin(a - ww) * ry * 0.92
    local x2, y2 = cx + math.cos(a + ww) * rx * 0.92, cy + math.sin(a + ww) * ry * 0.92
    local tx, ty = cx + math.cos(a) * (rx + len), cy + math.sin(a) * (ry + len)
    m:add(c:poly{ { rnd(x1), rnd(y1) }, { rnd(x2), rnd(y2) }, { rnd(tx), rnd(ty) } })
    tips[#tips + 1] = { rnd(tx), rnd(ty), a }
  end
  return m, tips
end
local function quills(c, m, R, cx, cy, rx, ry, tips)
  m:each(function(x, y) if (x * 7 + y * 13) % 17 == 0 and m:has(x, y + 1) and m:has(x + 1, y) then c:put(x, y, R.deep) end end)
  for _, t in ipairs(tips) do
    local a = t[3]
    local lit = math.cos(a) < 0.25 and math.sin(a) < 0.35
    local sx, sy = rnd(cx + math.cos(a) * rx * 0.55), rnd(cy + math.sin(a) * ry * 0.55)
    local ex, ey = rnd(cx + math.cos(a) * (rx + 1)), rnd(cy + math.sin(a) * (ry + 1))
    c:line({ { sx, sy }, { ex, ey } }, 1):clip(m):each(function(x, y) c:put(x, y, lit and R.hi or R.deep) end)
    if m:has(t[1], t[2]) then c:put(t[1], t[2], lit and R.hi or R.shade) end
  end
end
local function fill(m, hex, c) m:each(function(x, y) c:put(x, y, hex) end) end
local NAME = "folk-hedgehog-1"
local SP = R4("#c99a5e", "#8f5f3a", "#5e3a35", "#3d2532")
local SHIRT = R4("#f4c890", "#d89a5c", "#a0664c", "#6a4040")
local CLO = R4("#9cc46a", "#6a9a48", "#46704a", "#2f4a42")
local STRAW = R4("#f7df85", "#e0b453", "#b07f45", "#7a5040")
local RIB = R4("#9ad0f0", "#5a9ad0", "#3e6aa0", "#2c4470")
local LEAF = R4("#b8e07a", "#7cb84a", "#4e8a44", "#2f5a3e")
local METAL = R4("#e6ecee", "#a9b4c4", "#6f7894", "#474a68")
local WOOD = R4("#d39a5c", "#a5683c", "#714434", "#4a2c2e")
local BG = { base = "#a8c886", shade = "#7fa266", deep = "#5b7c50" }
local V = {}
function V.behind(c) end
function V.body(c, sh)
  c:part(sh, SHIRT, { band = 3, nopop = true })
  local d = c:rrect(28, 84, 51, 99, 2)
  d:add(c:line({ { 30, 85 }, { 25, 77 } }, 3)) d:add(c:line({ { 49, 85 }, { 54, 77 } }, 3))
  d:clip(sh)
  c:part(d, CLO, { band = 2, nopop = true })
  for x = 35, 44, 2 do c:put(x, 90, CLO.deep) end
  for y = 91, 95 do c:put(34, y, CLO.shade) c:put(45, y, CLO.shade) end
  for _, q in ipairs{ {30,86},{48,86} } do c:put(q[1], q[2], STRAW.hi) c:put(q[1]+1, q[2], STRAW.base) c:put(q[1], q[2]+1, STRAW.base) c:put(q[1]+1, q[2]+1, STRAW.shade) end
end
function V.hat(c)
  local hm = c:ellipse(39.5, 33, 24, 5.5)
  hm:add(c:rrect(29, 17, 50, 33, 5))
  c:part(hm, STRAW, { band = 3, nopop = true, inner = false })
  hm:each(function(x, yy) if (x + yy * 3) % 5 == 0 and c:get(x, yy) == STRAW.base then c:put(x, yy, STRAW.shade) end end)
  local br = c:ellipse(39.5, 33, 24, 5.5)
  br:each(function(x, yy) if not br:has(x, yy + 1) then c:put(x, yy, STRAW.deep) end end)
  for x = 32, 42 do c:put(x, 18, STRAW.hi) end
  c:part(c:rect(29, 27, 50, 30), RIB, { band = 1, nopop = true, inner = false })
  local l = c:ellipse(25.5, 26, 3.5, 2) l:add(c:ellipse(29, 22, 2, 3.5))
  c:part(l, LEAF, { band = 1, nopop = true, inner = false })
  for x = 23, 27 do c:put(x, 26, LEAF.shade) end for y = 20, 24 do c:put(29, y, LEAF.shade) end
end
function V.prop(c)
  c:part(c:rrect(60, 73, 64, 85, 1), WOOD, { band = 1, nopop = true, inner = false })
  for y = 75, 83, 3 do c:put(61, y, WOOD.shade) end
  c:part(c:rect(60, 70, 64, 72), METAL, { band = 1, nopop = true, inner = false })
  local bl = c:poly{ { 57, 69 }, { 67, 69 }, { 63, 56 }, { 61, 56 } }
  c:part(bl, METAL, { band = 2, nopop = true, inner = false })
  for y = 59, 68 do c:put(62, y, METAL.shade) end c:put(59, 66, METAL.hi) c:put(60, 63, METAL.hi) c:put(61, 60, METAL.hi)
  c:part(c:ellipse(62, 87, 4, 3.5), PAW, { band = 1, nopop = true, inner = false })
end

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local sh = c:ellipse(39.5, 104, 28, 25):clip(c:rect(0, 0, 79, 99))
V.behind(c)
local bm, bt = spiky(c, 39.5, 84, 27, 9, 165, 375, 12, 5, 7)
bm:clip(c:rect(0, 0, 79, 99))
c:part(bm, SP, { band = 2, nopop = true, inner = false })
HH.texture(c, bm, 39.5, 84, 27, 9, SP)
c:part(c:ellipse(39.5, 71, 13, 8), SKIN, { band = 2, nopop = true, inner = false })
V.body(c, sh)
HH.head(c, { cx = 39.5, cy = 49, s = 1.4, SP = SP, FACE = SKIN })
V.hat(c)
V.prop(c)
c:finish{ outline = true }
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")

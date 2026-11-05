-- folk-hedgehog-3 portrait (folk F1_0) variant: 3
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
local NAME = "folk-hedgehog-3"
local SP = R4("#a06a48", "#6a3f2e", "#46283a", "#3a2236")
local CLO = R4("#f2cb6a", "#d69c3a", "#a06a3a", "#6a4236")
local KER = R4("#f08a6e", "#d0503e", "#963648", "#5e2440")
local APR = R4("#fbf1d8", "#ecdcb8", "#c3aea0", "#8a7884")
local COP = R4("#f4b27c", "#cf7a48", "#9a4c40", "#64303a")
local SOUP, CARROT = "#f2b45a", "#e8703a"
local BG = { base = "#f0b88a", shade = "#d08c68", deep = "#a2644e" }
local V = { late = true, ry = -4 }
function V.behind(c) end
function V.body(c, sh)
  c:part(sh, CLO, { band = 3, nopop = true })
  local a = c:rrect(28, 80, 51, 99, 2)
  a:add(c:line({ { 30, 81 }, { 32, 73 } }, 2)) a:add(c:line({ { 49, 81 }, { 47, 73 } }, 2))
  c:part(a, APR, { band = 2, nopop = true, inner = false })
  for x = 33, 46 do c:put(x, 89, APR.shade) end for y = 90, 95 do c:put(33, y, APR.shade) c:put(46, y, APR.shade) end
  for y = 83, 98, 3 do c:put(43, y, APR.shade) end
end
function V.hat(c)
  local k = c:ellipse(39.5, 45, 17.5, 16.5):clip(c:rect(0, 0, 79, 36))
  c:part(k, KER, { band = 2, nopop = true, inner = false })
  k:each(function(x, y) if (x + 2 * y) % 7 == 0 and y % 3 == 0 and c:get(x, y) == KER.base then c:put(x, y, APR.hi) c:put(x+1, y, APR.base) end end)
  k:each(function(x, y) if not k:has(x, y + 1) then c:put(x, y, KER.deep) end end)
  local kn = c:ellipse(57, 33, 3, 2.5)
  kn:add(c:poly{ { 58, 34 }, { 65, 39 }, { 62, 42 }, { 57, 36 } })
  kn:add(c:poly{ { 58, 32 }, { 66, 28 }, { 66, 33 }, { 59, 35 } })
  c:part(kn, KER, { band = 1, nopop = true, inner = false })
end
function V.prop(c)
  c:part(c:line({ { 64, 88 }, { 62, 62 } }, 3), COP, { band = 1, nopop = true, inner = false })
  c:part(c:ellipse(63, 57, 6, 4), COP, { band = 2, nopop = true, inner = false })
  fill(c:ellipse(63, 56, 4, 2), SOUP, c)
  c:put(64, 56, CARROT) c:put(61, 55, CARROT)
  c:put(59, 55, COP.hi) c:put(60, 54, COP.hi)
  c:part(c:ellipse(64, 89, 4, 3.5), PAW, { band = 1, nopop = true, inner = false })
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

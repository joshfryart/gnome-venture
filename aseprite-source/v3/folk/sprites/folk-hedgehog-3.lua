-- folk-hedgehog-3 sprite (folk F1_0) variant: 3
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
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
local IDLE = { { b = 0 }, { b = 1, pd = 1, pl = -1 }, { b = 0 }, { b = 0, blink = true, tw = -1, sx = 1 } }
function V.behind(c, b, p) end
function V.body(c, b, p)
  local m = c:ellipse(32, 77 + b, 11, 9)
  m:add(c:rect(24, 78 + b, 40, 86))
  m:cut(c:rect(32, 84 + b, 32, 86))
  c:part(m, CLO, { band = 2, nopop = true })
  local a = c:poly{ { 27, 69 + b }, { 37, 69 + b }, { 38, 76 + b }, { 41, 86 }, { 23, 86 }, { 26, 76 + b } }
  c:part(a, APR, { band = 2, nopop = true, inner = false })
  for x = 23, 41 do if a:has(x, 76 + b) then c:put(x, 76 + b, APR.shade) end end
  for x = 29, 35 do c:put(x, 80 + b, APR.shade) end c:put(29, 81 + b, APR.shade) c:put(35, 81 + b, APR.shade)
  c:put(24, 77 + b, APR.base) c:put(23, 78 + b, APR.shade)
  c:put(28, 68 + b, APR.shade) c:put(36, 68 + b, APR.shade)
end
function V.hat(c, b, p)
  local y = b
  local k = c:ellipse(32, 46 + y, 15, 13):clip(c:rect(0, 0, 63, 40 + y))
  c:part(k, KER, { band = 2, nopop = true, inner = false })
  k:each(function(x, yy) if (x + 2 * yy) % 6 == 0 and yy % 3 == 0 and c:get(x, yy) == KER.base then c:put(x, yy, APR.hi) end end)
  k:each(function(x, yy) if not k:has(x, yy + 1) then c:put(x, yy, KER.deep) end end)
  local t = p.tw or 0
  local kn = c:ellipse(47, 37 + y, 2, 2)
  kn:add(c:poly{ { 48, 38 + y }, { 52, 41 + y + t }, { 51, 43 + y + t }, { 47, 40 + y } })
  kn:add(c:poly{ { 48, 36 + y }, { 53, 34 + y - t }, { 53, 37 + y - t }, { 48, 38 + y } })
  c:part(kn, KER, { band = 1, nopop = true, inner = false })
end
function V.prop(c, b, p)
  local y = b + (p.pl or 0)
  local tw = p.tw or 0
  c:part(c:line({ { 45, 70 + b }, { 47, 58 + y } }, 2), COP, { band = 1, nopop = true, inner = false })
  local bw = c:ellipse(48.5 + tw, 54 + y, 4, 3)
  c:part(bw, COP, { band = 1, nopop = true, inner = false })
  fill(c:ellipse(48.5 + tw, 53 + y, 2.5, 1.5), SOUP, c)
  c:put(49 + tw, 53 + y, CARROT)
  c:part(c:ellipse(43.5, 70 + b, 2.5, 2.5), PAW, { band = 1, nopop = true, inner = false })
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b
  c:groundShadow(32, 89.5, 13, 3)
  V.behind(c, b, p)
  local bk, bt = spiky(c, 32, 69 + b, 13, 10, 150, 390, 12, 4, 8)
  c:part(bk, SP, { band = 1, nopop = true, inner = false })
  quills(c, bk, SP, 32, 69 + b, 13, 10, bt)
  for _, x in ipairs{ 27, 37 } do
    c:part(c:ellipse(x, 88.5, 3.5, 2), PAW, { band = 1, nopop = true, inner = false })
    c:put(x - 2, 88, PAW.hi)
  end
  c:part(c:ellipse(32, 66 + b, 8, 4), SKIN, { band = 1, nopop = true, inner = false })
  V.body(c, b, p)
  if not V.late then V.prop(c, b, p) end
  c:part(c:ellipse(20.5, 74 + b + (V.ly or 0), 2.5, 2.5), PAW, { band = 1, nopop = true, inner = false })
  c:part(c:ellipse(43.5, 74 + b + (V.ry or 0), 2.5, 2.5), PAW, { band = 1, nopop = true, inner = false })
  -- head: spiny dome seen from above-front
  local hm, ht = spiky(c, 32, 46 + b, 16, 13, 145, 395, 15, 5, 7)
  c:part(hm, SP, { band = 2, nopop = true, inner = false })
  quills(c, hm, SP, 32, 46 + b, 16, 13, ht)
  for _, x in ipairs{ 21.5, 42.5 } do
    c:part(c:ellipse(x, 49 + b, 2.5, 2.5), SKIN, { band = 1, nopop = true, inner = false })
    c:put(math.floor(x) + (x < 32 and 0 or 1), 50 + b, PAW.shade)
  end
  local f = c:ellipse(32, 55 + b, 10, 6.5)
  f:add(c:poly{ { 23, 56 + b }, { 41, 56 + b }, { 35, 63 + b }, { 29, 63 + b } })
  f:add(c:ellipse(32, 63 + b, 3, 2.5))
  c:part(f, SKIN, { band = 2, nopop = true, inner = false })
  fill(c:poly{ { 29, 48 + b }, { 35, 48 + b }, { 32, 51 + b } }, SP.shade, c)
  for x = 31, 33 do c:put(x, 63 + b, NOSE) end c:put(32, 64 + b, NOSE) c:put(31, 63 + b, NOSEHI)
  c:put(24, 59 + b, BLUSH) c:put(25, 59 + b, BLUSH) c:put(39, 59 + b, BLUSH) c:put(40, 59 + b, BLUSH)
  for _, x in ipairs{ 26, 37 } do
    if p.blink then c:put(x, 56 + b, INK) c:put(x + 1, 56 + b, INK)
    else c:put(x, 55 + b, P.cream) c:put(x + 1, 55 + b, INK) c:put(x, 56 + b, INK) c:put(x + 1, 56 + b, INK) end
  end
  V.hat(c, b, p)
  if V.late then V.prop(c, b, p) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", scale = 1 }
local pc = app.pixelColor
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do
    im:putPixel(i % 64, i // 64, pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255))
  end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")

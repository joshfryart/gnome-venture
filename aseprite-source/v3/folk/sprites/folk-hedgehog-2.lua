-- folk-hedgehog-2 sprite (folk F1_0) variant: 2
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
local NAME = "folk-hedgehog-2"
local SP = R4("#b8a48c", "#7f6a5e", "#54465a", "#372c40")
local CLO = R4("#8fa6d0", "#5d74a8", "#414f80", "#2e3458")
local CAP = R4("#d67a9c", "#a84a78", "#74345e", "#4a2448")
local SCARF = R4("#7fd0c4", "#3f9e9c", "#2e6c78", "#234a5a")
local PACK = R4("#d19a62", "#9c6640", "#6a4238", "#45293a")
local ROLL = R4("#efd9a8", "#cdb07e", "#9a8070", "#6a5866")
local BRASS = R4("#f2d27a", "#c99a3e", "#8a6034", "#5a3a30")
local GL1, GL2, GL3 = "#fff0a8", "#f7c75a", "#e8913f"
local BG = { base = "#a4c4dc", shade = "#7898bc", deep = "#56709a" }
local V = {}
local IDLE = { { b = 0 }, { b = 1, pd = 1, pl = -1 }, { b = 0 }, { b = 0, blink = true, tw = -1, sx = 1 } }
function V.behind(c, b, p)
  local pk = c:rrect(9, 61 + b, 21, 80 + b, 3)
  c:part(pk, PACK, { band = 2, nopop = true, inner = false })
  local fl = c:rrect(9, 61 + b, 21, 67 + b, 2)
  c:part(fl, PACK, { band = 1, nopop = true, inner = false })
  fl:each(function(x, y) if not fl:has(x, y + 1) then c:put(x, y, PACK.deep) end end)
  c:put(15, 68 + b, BRASS.base) c:put(15, 69 + b, BRASS.shade)
  local pd = p.pd or 0
  local r = c:ellipse(15, 59 + b + pd, 7, 3)
  c:part(r, ROLL, { band = 1, nopop = true, inner = false })
  for yy = 55, 63 do for _, x in ipairs{ 12, 18 } do if r:has(x, yy + b + pd) then c:put(x, yy + b + pd, PACK.shade) end end end
end
function V.body(c, b, p)
  local m = c:ellipse(32, 77 + b, 11, 9)
  m:add(c:rect(24, 78 + b, 40, 86))
  m:cut(c:rect(32, 83 + b, 32, 86))
  c:part(m, CLO, { band = 2, nopop = true })
  local st = c:line({ { 23, 68 + b }, { 40, 82 + b } }, 2):clip(m)
  fill(st, PACK.base, c)
  st:each(function(x, y) if not st:has(x, y + 1) then c:put(x, y, PACK.deep) end end)
  for _, yy in ipairs{ 72, 77 } do c:put(29, yy + b, BRASS.base) end
  local s = c:rrect(22, 62 + b, 42, 67 + b, 2)
  c:part(s, SCARF, { band = 1, nopop = true, inner = false })
  for x = 24, 40, 4 do for yy = 63, 66 do if s:has(x, yy + b) then c:put(x, yy + b, SCARF.shade) end end end
  local t = c:poly{ { 35, 66 + b }, { 39, 66 + b }, { 40, 76 + b }, { 36, 76 + b } }
  c:part(t, SCARF, { band = 1, nopop = true, inner = false })
  for x = 36, 40, 2 do c:put(x, 77 + b, SCARF.shade) end
end
function V.hat(c, b, p)
  local y = b
  local cm = c:ellipse(32, 38 + y, 12, 8):clip(c:rect(0, 0, 63, 37 + y))
  c:part(cm, CAP, { band = 2, nopop = true, inner = false })
  for x = 24, 40, 3 do for yy = 31, 37 do if cm:has(x, yy + y) and c:get(x, yy + y) == CAP.base then c:put(x, yy + y, CAP.shade) end end end
  local cu = c:rrect(20, 36 + y, 44, 40 + y, 2)
  c:part(cu, CAP, { band = 1, nopop = true, inner = false })
  for x = 21, 43, 2 do for yy = 37, 39 do if cu:has(x, yy + y) then c:put(x, yy + y, CAP.shade) end end end
  local pm = c:ellipse(37 + (p.tw or 0), 29 + y + (p.pd or 0), 3, 3)
  c:part(pm, ROLL, { band = 1, nopop = true, inner = false })
end
function V.prop(c, b, p)
  local y = b + (p.pl or 0)
  local x0 = 42 + (p.sx or 0)
  c:put(44, 76 + b, BRASS.deep) c:put(44, 77 + b, BRASS.deep)
  local L = c:rect(x0, 78 + y, x0 + 5, 85 + y)
  L:add(c:rect(x0 + 1, 77 + y, x0 + 4, 77 + y))
  c:part(L, BRASS, { band = 1, nopop = true, inner = false })
  fill(c:rect(x0 + 1, 80 + y, x0 + 4, 83 + y), GL2, c)
  c:put(x0 + 1, 80 + y, GL1) c:put(x0 + 2, 81 + y, GL1) c:put(x0 + 2, 82 + y, GL1)
  c:put(x0 + 4, 83 + y, GL3) c:put(x0 + 4, 82 + y, GL3)
  for x = x0, x0 + 5 do c:put(x, 79 + y, BRASS.shade) c:put(x, 84 + y, BRASS.shade) end
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

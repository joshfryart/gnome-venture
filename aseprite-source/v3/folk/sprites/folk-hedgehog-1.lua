-- folk-hedgehog-1 sprite (folk F1_0) variant: 1
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
local IDLE = { { b = 0 }, { b = 1, pd = 1, pl = -1 }, { b = 0 }, { b = 0, blink = true, tw = -1, sx = 1 } }
function V.behind(c, b, p) end
function V.body(c, b, p)
  local m = c:ellipse(32, 77 + b, 11, 9)
  m:add(c:rect(24, 78 + b, 40, 86))
  c:part(m, SHIRT, { band = 2, nopop = true, inner = false })
  local d = m:copy():clip(c:rect(0, 78 + b, 63, 95))
  d:add(c:rrect(27, 69 + b, 37, 78 + b, 1))
  d:cut(c:rect(32, 83 + b, 32, 86))
  c:part(d, CLO, { band = 2, nopop = true })
  for x = 29, 35, 2 do c:put(x, 74 + b, CLO.deep) end
  c:put(28, 70 + b, STRAW.hi) c:put(36, 70 + b, STRAW.hi)
end
function V.hat(c, b, p)
  local y = b
  local hm = c:ellipse(32, 39 + y, 17, 4.5)
  hm:add(c:rrect(24, 28 + y, 40, 38 + y, 4))
  c:part(hm, STRAW, { band = 2, nopop = true, inner = false })
  hm:each(function(x, yy) if (x + yy * 3) % 5 == 0 and c:get(x, yy) == STRAW.base then c:put(x, yy, STRAW.shade) end end)
  local br = c:ellipse(32, 39 + y, 17, 4.5)
  br:each(function(x, yy) if not br:has(x, yy + 1) then c:put(x, yy, STRAW.deep) end end)
  for x = 27, 33 do c:put(x, 29 + y, STRAW.hi) end
  c:part(c:rect(24, 35 + y, 40, 37 + y), RIB, { band = 1, nopop = true, inner = false })
  local t = p.tw or 0
  local l = c:ellipse(21.5, 34 + y + t, 2.5, 1.5) l:add(c:ellipse(24, 31 + y + t, 1.5, 2.5))
  c:part(l, LEAF, { band = 1, nopop = true, inner = false })
  c:put(21, 34 + y + t, LEAF.deep) c:put(24, 31 + y + t, LEAF.deep)
end
function V.prop(c, b, p)
  local y = b
  c:part(c:rect(43, 67 + y, 44, 72 + y), WOOD, { band = 1, nopop = true, inner = false })
  c:part(c:rect(43, 76 + y, 44, 77 + y), METAL, { band = 1, nopop = true, inner = false })
  local bl = c:poly{ { 41, 78 + y }, { 46, 78 + y }, { 45, 84 + y }, { 44, 85 + y }, { 43, 85 + y }, { 42, 84 + y } }
  c:part(bl, METAL, { band = 1, nopop = true, inner = false })
  c:put(42, 79 + y, METAL.hi) c:put(42, 80 + y, METAL.hi)
  for yy = 79, 83 do c:put(44, yy + y, METAL.shade) end
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b
  c:groundShadow(32, 89.5, 13, 3)
  V.behind(c, b, p)
  local bk, bt = spiky(c, 32, 69 + b, 13, 10, 150, 390, 12, 4, 8)
  c:part(bk, SP, { band = 1, nopop = true, inner = false })
  HH.texture(c, bk, 32, 69 + b, 13, 10, SP)
  for _, x in ipairs{ 27, 37 } do
    c:part(c:ellipse(x, 88.5, 3.5, 2), PAW, { band = 1, nopop = true, inner = false })
    c:put(x - 2, 88, PAW.hi)
  end
  c:part(c:ellipse(32, 66 + b, 8, 4), SKIN, { band = 1, nopop = true, inner = false })
  V.body(c, b, p)
  if not V.late then V.prop(c, b, p) end
  c:part(c:ellipse(20.5, 74 + b + (V.ly or 0), 2.5, 2.5), PAW, { band = 1, nopop = true, inner = false })
  c:part(c:ellipse(43.5, 74 + b + (V.ry or 0), 2.5, 2.5), PAW, { band = 1, nopop = true, inner = false })
  HH.head(c, { cx = 32, cy = 51 + b, s = 1, SP = SP, FACE = SKIN, blink = p.blink })
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

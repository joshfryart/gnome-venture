-- folk-snail-1 sprite (folk F2_6) variant: 1
-- garden snail: amber globe shell with a seedling sprouting from it, straw hat pierced by the eye stalks, green check neckerchief, trowel. 64x96 cell, feet baseline y=90, idle 4f strip.
local NAME = "folk-snail-1"

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK, CREAM = P.ink, P.cream
local function R(h, b, s, d) return { hi = h, base = b, shade = s, deep = d } end
local function part(c, m, r, band) c:part(m, r, { band = band or 2, nopop = true }) return m end
local function under(c, m, r) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, r.deep, r) end end) end
local function texture(c, m, r)
  m:each(function(x, y) if y % 3 == 0 and (x * 5 + y) % 7 == 0 and c:get(x, y) == r.base then c:put(x, y, r.shade, r) end end)
end
local function spiral(c, m, cx, cy, Rr, turns, sy, hex, owner, w, start)
  local inn = m:shrink(1)
  for i = 0, 700 do
    local t = i / 700
    local th = start + t * turns * 2 * math.pi
    local r = Rr * (1 - t) + 0.6
    local x = math.floor(cx + math.cos(th) * r + 0.5)
    local y = math.floor(cy + math.sin(th) * r * sy + 0.5)
    if inn:has(x, y) then c:put(x, y, hex, owner) end
    if w == 2 and inn:has(x, y + 1) then c:put(x, y + 1, hex, owner) end
  end
end
local STL = R("#e6e2d6", "#a8acb8", "#6e7088", "#474660")
local WD = R("#d08e4c", "#9c6038", "#6a3e34", "#432a34")

local SK = R("#d2cb94", "#a09e6e", "#726c60", "#4a4256")
local SH = R("#f6c86e", "#d48e3e", "#9e5c3c", "#5e3446")
local ST = R("#f6de8e", "#dab65c", "#a8824a", "#6e5040")
local GR = R("#a2d870", "#5ca24c", "#3c6e4e", "#2e4448")
local ARM = SK
local BG = R("#cfe3a0", "#a8c87c", "#7e9e64", "#5c7a54")

local function shellS(c, b, p)
  local sh = c:ellipse(44, 52 + b, 13, 13)
  part(c, sh, SH, 3)
  spiral(c, sh, 46, 52 + b, 12, 2.6, 1, SH.deep, SH, 1, 3.6)
  for _, q in ipairs{ {36,46},{37,44},{38,43},{36,47},{40,41} } do c:put(q[1], q[2] + b, SH.hi, SH) end
  local d = b + (p.pd or 0)
  part(c, c:rect(47, 35 + d, 47, 40 + b), GR, 1)
  part(c, c:ellipse(44.5, 34.5 + d, 2.5, 1.5), GR, 1)
  part(c, c:ellipse(50, 33.5 + d, 2.5, 1.5), GR, 1)
end
local function clothesS(c, b, p)
  local nk = c:poly{ {21,56 + b},{43,56 + b},{33,68 + b},{31,68 + b} }
  part(c, nk, GR, 2)
  for y = 57, 64, 2 do for x = 23, 41, 3 do if nk:has(x, y + b) and c:get(x, y + b) == GR.base then c:put(x, y + b, GR.hi, GR) end end end
  part(c, c:ellipse(32, 57.5 + b, 2.5, 2), GR, 1)
end
local function hatS(c, b, p)
  local h = b + (p.pd or 0)
  local brim = c:ellipse(32, 37 + h, 16, 4)
  part(c, brim, ST, 2) under(c, brim, ST)
  local cr = c:rrect(27, 29 + h, 37, 36 + h, 3)
  part(c, cr, ST, 2)
  for x = 27, 37 do c:put(x, 34 + h, GR.base, GR) c:put(x, 35 + h, GR.shade, GR) end
  brim:add(cr):each(function(x, y) if (x + y * 2) % 4 == 0 and c:get(x, y) == ST.base then c:put(x, y, ST.shade, ST) end end)
  c:put(28, 30 + h, ST.hi, ST) c:put(29, 30 + h, ST.hi, ST) c:put(19, 36 + h, ST.hi, ST)
end
local function propS(c, b, p)
  local hd = c:rect(19, 66 + b, 20, 76 + b) part(c, hd, WD, 1)
  local bl = c:poly{ {16,65 + b},{23,65 + b},{20,55 + b},{19,55 + b} }
  part(c, bl, STL, 1)
  c:put(18, 62 + b, STL.hi, STL) c:put(19, 59 + b, STL.hi, STL)
  part(c, c:ellipse(19.5, 70 + b, 3, 2.5), SK, 1)
end

local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK, "eye") end return end
  c:put(x + 1, y, INK, "eye") c:put(x + 2, y, INK, "eye")
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], CREAM, "eye") end
  c:put(x + 1, y + 1, CREAM, "eye") c:put(x + 2, y + 1, INK, "eye") c:put(x + 1, y + 2, INK, "eye") c:put(x + 2, y + 2, INK, "eye")
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw = p.bob or 0, p.tw or 0
  c:groundShadow(32, 89.5, 17, 3)
  shellS(c, b, p)
  -- foot skirt with a tail out back-right (fixed)
  local foot = c:ellipse(32, 87, 15, 3.5)
  foot:add(c:poly{ {42,85},{52,86},{56 + (p.tail or 0),89},{46,90} })
  part(c, foot, SK, 1) under(c, foot, SK)
  for x = 19, 45, 3 do if foot:has(x, 88) then c:put(x, 88, SK.shade, SK) end end
  -- soft body column
  local body = c:ellipse(32, 72 + b, 11, 13)
  body:add(c:rect(22, 74 + b, 42, 86))
  part(c, body, SK, 3) texture(c, body, SK)
  clothesS(c, b, p)
  -- tiny nub arms
  for _, a in ipairs{ {19.5, 0}, {44.5, 1} } do
    local m = c:ellipse(a[1], 68 + b, 3, 4)
    part(c, m, ARM, 1) under(c, m, ARM)
    local h = c:ellipse(a[1], 72 + b, 2, 1.5) part(c, h, SK, 1)
  end
  -- head
  local head = c:ellipse(32, 46 + b, 13, 11)
  part(c, head, SK, 3) texture(c, head, SK)
  for _, s in ipairs{ -1, 1 } do local t = c:line({ {32 + s * 5, 52 + b}, {32 + s * 7, 55 + b} }, 2) part(c, t, SK, 1) end
  local mz = c:ellipse(32, 52 + b, 5, 2.5)
  mz:each(function(x, y) c:put(x, y, mz:has(x, y + 1) and SK.hi or SK.base, SK) end)
  for _, q in ipairs{ {29,53},{30,54},{31,54},{32,54},{33,54},{34,53} } do c:put(q[1], q[2] + b, INK, "m") end
  c:put(31, 53 + b, "#e0727e", "m") c:put(32, 53 + b, "#e0727e", "m")
  c:cheek(21, 49 + b) c:cheek(40, 49 + b)
  hatS(c, b, p)
  -- eye stalks with eyes at the tips
  local sd = p.sd or 0
  local st = c:line({ {28,41 + b},{25,31 + b},{23,23 + b + sd} }, 3)
  st:add(c:line({ {36,41 + b},{39,31 + b},{41 + tw,23 + b + sd} }, 3))
  part(c, st, SK, 1)
  for _, e in ipairs{ {23.5, 0}, {41.5 + tw, 0} } do
    local bl = c:ellipse(e[1], 20.5 + b + sd, 3.5, 3.5)
    part(c, bl, SK, 1)
    c:put(math.floor(e[1]) - 2, 18 + b + sd, SK.hi, SK)
    eye(c, math.floor(e[1]) - 2, 18 + b + sd, p.blink)
  end
  propS(c, b, p)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, pd = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = 1, tail = 1 } } do frames[#frames + 1] = frame(p) end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
local W, H = 64, 96
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0,0,0,0))
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0,0,0,0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) strip:putPixel((f - 1) * W + i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 2 or f == 4) and 0.35 or 0.45
end
spr.layers[1].name = "body"
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * 4, H, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " sprite ok")

-- folk-snail-2 sprite (folk F2_6) variant: 2
-- wandering trader snail: pink banded shell carrying a strapped pack and bedroll, blue cap, red striped scarf, brass lantern. 64x96 cell, feet baseline y=90, idle 4f strip.
local NAME = "folk-snail-2"

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

local SK = R("#dacad2", "#aa98aa", "#7c6a8a", "#4e4060")
local SH = R("#fde8c6", "#efbe9c", "#c2827a", "#7a4a5e")
local BAND = "#5c3249"
local RD = R("#ff9c6c", "#d84c3c", "#9c3042", "#5e1e3a")
local LT = R("#dca26a", "#aa6a40", "#76443e", "#48283a")
local CP = R("#8cc8e2", "#4c88b2", "#345c8a", "#283a5e")
local BR = R("#ffe08c", "#e2a83c", "#aa6c36", "#6a3e34")
local GL = R("#fff2b2", "#ffd46c", "#e2983c", "#9c5c36")
local BL = R("#e8e0a8", "#b8b47a", "#86826c", "#5a5262")
local ARM = SK
local BG = R("#b6d6ea", "#92b6d6", "#7090ba", "#566c9a")

local function shellS(c, b, p)
  local sh = c:ellipse(43, 54 + b, 13, 12)
  part(c, sh, SH, 3)
  spiral(c, sh, 45, 55 + b, 11.5, 2.2, 0.95, BAND, SH, 2, 3.4)
  c:put(35, 49 + b, SH.hi, SH) c:put(36, 47 + b, SH.hi, SH)
  local d = b + (p.pd or 0)
  local pk = c:rrect(39, 33 + b, 55, 46 + b, 2)
  part(c, pk, LT, 2) under(c, pk, LT)
  local fl = c:rrect(39, 33 + b, 55, 37 + b, 2) part(c, fl, LT, 1)
  for x = 39, 55 do if fl:has(x, 37 + b) then c:put(x, 37 + b, LT.deep, LT) end end
  part(c, c:rect(46, 37 + b, 48, 39 + b), BR, 1)
  local roll = c:ellipse(47, 30.5 + d, 9, 3)
  part(c, roll, BL, 2)
  for _, x in ipairs{ 43, 51 } do for y = 28, 33 do if roll:has(x, y + d) then c:put(x, y + d, RD.base, RD) end end end
end
local function clothesS(c, b, p)
  part(c, c:line({ {25,60 + b},{24,78 + b} }, 2), LT, 1)
  part(c, c:line({ {39,60 + b},{40,78 + b} }, 2), LT, 1)
  local sc = c:rrect(21, 55 + b, 43, 60 + b, 2)
  part(c, sc, RD, 2)
  for x = 22, 42, 4 do c:put(x, 57 + b, RD.hi, RD) c:put(x + 1, 57 + b, RD.hi, RD) end
  local d = b + (p.pd or 0)
  local tl = c:poly{ {34,58 + b},{39,58 + b},{40,69 + d},{35,69 + d} }
  part(c, tl, RD, 1)
  for x = 35, 40, 2 do c:put(x, 69 + d, RD.deep, RD) end
  for x = 35, 39 do if tl:has(x, 63 + b) then c:put(x, 63 + b, RD.hi, RD) end end
end
local function hatS(c, b, p)
  local cap = c:ellipse(32, 37 + b, 8, 4.5)
  cap:add(c:rect(24, 37 + b, 40, 39 + b))
  part(c, cap, CP, 2)
  local pk = c:ellipse(29, 40 + b, 8, 1.5) part(c, pk, CP, 1) under(c, pk, CP)
  part(c, c:ellipse(32, 33 + b, 1.5, 1.2), RD, 1)
  c:put(27, 35 + b, CP.hi, CP) c:put(28, 34 + b, CP.hi, CP)
end
local function propS(c, b, p)
  local d = b + (p.pd or 0) local lx = p.tw or 0
  part(c, c:line({ {46,70 + b},{47 + lx,74 + d} }, 1), BR, 1)
  part(c, c:rect(44 + lx, 74 + d, 50 + lx, 75 + d), BR, 1)
  local g = c:rrect(44 + lx, 76 + d, 50 + lx, 81 + d, 1)
  part(c, g, GL, 1)
  c:put(47 + lx, 78 + d, GL.hi, GL) c:put(47 + lx, 79 + d, GL.hi, GL) c:put(45 + lx, 77 + d, CREAM, GL)
  part(c, c:rect(43 + lx, 82 + d, 51 + lx, 83 + d), BR, 1)
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

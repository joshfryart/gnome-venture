-- folk-snail-3 sprite (folk F2_6) variant: 3
-- cook snail: flat chestnut ramshorn shell, teal smock with cream apron, mustard polka kerchief, copper ladle with a soup drip. 64x96 cell, feet baseline y=90, idle 4f strip.
local NAME = "folk-snail-3"

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

local SK = R("#f6d0a2", "#dca272", "#a8705e", "#6e4458")
local SH = R("#d88c74", "#9e504e", "#6e3448", "#452238")
local STRIPE = "#f0c690"
local AP = R("#fbf0d4", "#ecdab2", "#bca690", "#7e6a72")
local TL = R("#8cdcc2", "#3caa90", "#2c7878", "#234a58")
local MU = R("#ffd86c", "#e2aa3c", "#a8743e", "#6a4440")
local CU = R("#ffc28c", "#d87c4c", "#9c4c40", "#5e2e36")
local SOUP = R("#d6e07a", "#9cb444", "#6c8040", "#46523e")
local ARM = TL
local BODYR = TL
local BG = R("#f2b6a8", "#e09a94", "#bc7880", "#925c72")

local function shellS(c, b, p)
  local sh = c:ellipse(45, 55 + b, 15.5, 9.5)
  part(c, sh, SH, 3)
  spiral(c, sh, 47, 55 + b, 14, 3, 0.6, SH.deep, SH, 1, 3.2)
  spiral(c, sh, 47, 55 + b, 12.5, 2.6, 0.6, STRIPE, SH, 1, 3.2)
  c:put(33, 52 + b, SH.hi, SH) c:put(34, 50 + b, SH.hi, SH)
end
local function clothesS(c, b, p)
  local yk = c:rrect(21, 56 + b, 43, 65 + b, 3) part(c, yk, TL, 2)
  local ap = c:rrect(24, 61 + b, 40, 86, 2) part(c, ap, AP, 2)
  part(c, c:line({ {25,61 + b},{27,56 + b} }, 1), AP, 1) part(c, c:line({ {39,61 + b},{37,56 + b} }, 1), AP, 1)
  for x = 24, 40 do if ap:has(x, 66 + b) then c:put(x, 66 + b, AP.shade, AP) end end
  local pkt = c:rrect(28, 73 + b, 36, 78 + b, 1)
  pkt:edge():each(function(x, y) c:put(x, y, AP.shade, AP) end)
  c:put(30, 72 + b, WD.base, WD) c:put(30, 71 + b, WD.hi, WD)
end
local function hatS(c, b, p)
  local hd = c:ellipse(32, 46 + b, 13.5, 11.5):clip(c:rect(0, 0, 63, 40 + b))
  part(c, hd, MU, 2) under(c, hd, MU)
  for _, q in ipairs{ {26,37},{31,36},{36,37},{29,39},{34,39},{39,39},{24,39} } do if hd:has(q[1], q[2] + b) then c:put(q[1], q[2] + b, AP.hi, AP) end end
  local d = b + (p.pd or 0)
  part(c, c:ellipse(46.5, 39 + b, 2, 2), MU, 1)
  part(c, c:poly{ {47,39 + b},{51,36 + d},{52,41 + d} }, MU, 1)
  part(c, c:poly{ {47,40 + b},{50,44 + d},{47,45 + d} }, MU, 1)
end
local function propS(c, b, p)
  local d = b + (p.pd or 0)
  part(c, c:line({ {19,73 + b},{17,60 + b},{15,52 + b} }, 2), CU, 1)
  local bw = c:ellipse(14, 48.5 + b, 4.5, 3)
  part(c, bw, CU, 1)
  local so = c:ellipse(14, 48 + b, 3, 1.5) part(c, so, SOUP, 1)
  c:put(13, 47 + b, SOUP.hi, SOUP)
  c:put(9, 52 + d, SOUP.base, SOUP) c:put(9, 53 + d, SOUP.shade, SOUP)
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

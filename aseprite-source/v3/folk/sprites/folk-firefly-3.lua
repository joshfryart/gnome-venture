-- folk-firefly-3 sprite (folk F2_13) variant: 3
-- Firefly villager, 64x96 cell, 3/4 top-down, feet baseline y=90 centre x=32, idle x4 (base, breath, base, blink+twitch+glow pulse).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local V = 3
local NAME = "folk-firefly-" .. V
local function rp(h, b, s, d) return { hi = h, base = b, shade = s, deep = d } end
-- v1 gardener (straw hat, neckerchief, trowel) / v2 traveller (denim cap, striped scarf, pack + bedroll)
-- v3 cook (polka kerchief, apron, copper ladle). All: lampyrid pronotum hood with pale margin + dark spot,
-- wing-case coat with pale edges, segmented belly whose last plates are the glowing lantern.
local VR = {
  { pro = rp("#ffc27e", "#f08a4c", "#c45c4a", "#8a3e4e"), ely = rp("#7e8c6c", "#56644f", "#404b47", "#30353f"),
    trim = "#f2d87a", trim2 = "#ffe08a", head = rp("#fbe6a2", "#e7c36a", "#c3944f", "#8d6449"),
    cloth = rp("#a8dc78", "#6eb454", "#4a8a4c", "#33604a"), prop = rp("#e4e6ee", "#aeb4c8", "#7a7c9a", "#54506c"),
    prop2 = rp("#e0a670", "#b07650", "#80544a", "#583c42"), bg = rp("#c4e48c", "#9cc46a", "#78a05a", "#58784e") },
  { pro = rp("#ffa89c", "#e46c6c", "#b04c64", "#7a3452"), ely = rp("#a67c5c", "#7c5844", "#5c4242", "#3e2e3a"),
    trim = "#f0c870", trim2 = "#ffd48a", head = rp("#94bcec", "#5c86c8", "#47599a", "#363f72"),
    cloth = rp("#92e2d2", "#46b0a6", "#307e86", "#285468"), prop = rp("#ead29a", "#c8a46a", "#987656", "#6a5048"),
    prop2 = rp("#f0a070", "#c8683e", "#984a40", "#6a343c"), bg = rp("#a8c4f0", "#7ea0d8", "#6480b8", "#4c5f94") },
  { pro = rp("#fff0a0", "#f4c24a", "#d08a3e", "#9a5a40"), ely = rp("#a46c9e", "#7a4a7e", "#5a3a66", "#3e2c50"),
    trim = "#f4b8c8", trim2 = "#fdf2d4", head = rp("#ff9a88", "#e05a50", "#b03e4c", "#7a2c44"),
    cloth = rp("#fdf2d4", "#f0dcb4", "#c8b0a0", "#94808a"), prop = rp("#ffc48a", "#d88a54", "#a85a48", "#723e44"),
    prop2 = rp("#ffc48a", "#d88a54", "#a85a48", "#723e44"), bg = rp("#f8c49a", "#f0a878", "#d08060", "#a0604e") },
}
local R = VR[V]
R.face = rp("#6c5c7c", "#4d405e", "#3b3049", "#30263c")
R.dome = rp("#8a7a9c", "#6c5c7c", "#5a4b6a", "#4d405e")
R.belly = rp("#f3ddb2", "#dcb98c", "#b48c76", "#806272")
R.glow = rp("#fbf6b4", "#e6ef72", "#b5d64c", "#7ba63e")
R.glow2 = rp("#fdfbd0", "#f4f8a0", "#d4ea66", "#98c048")

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, ho = p.bob or 0, p.hb or 0
  local function pt(m, r, bd) c:part(m, r, { band = bd or 2, nopop = true }) return m end
  local function E(cx, cy, rx, ry, o) return c:ellipse(cx, cy + (o or b), rx, ry) end
  local function put(x, y, hex, r) if x >= 0 and y >= 0 and x < 64 and y < 96 then c:put(x, y, hex, r) end end
  local function gl(m, x, y, r) if m:has(x, y) then put(x, y, r.hi, r) end end
  c:groundShadow(32, 88.5, 14, 3.5)
  local erx = V == 3 and 14 or (V == 2 and 12 or 13)
  if V == 2 then -- pack behind the right shoulder, bedroll on top
    local pk = c:rrect(36, 50 + b, 51, 77 + b, 4) pt(pk, R.prop, 3)
    for y = 56, 76 do if pk:has(48, y + b) then put(48, y + b, R.prop.shade, R.prop) end end
    pt(c:rrect(38, 51 + b, 51, 57 + b, 2), R.prop, 1)
    local roll = E(44, 48, 8, 3.5) pt(roll, R.prop2, 1) gl(roll, 40, 46 + b, R.prop2)
    for _, x in ipairs{ 40, 48 } do for y = 44, 53 do if roll:has(x, y + b) then put(x, y + b, R.prop2.deep, R.prop2) end end end
  end
  for _, fx in ipairs{ 27, 37 } do -- legs + round feet (never move)
    pt(c:line({ { fx + (fx < 32 and 1 or -1), 79 }, { fx, 86 } }, 2), R.face, 1)
    local f = c:ellipse(fx, 87.5, 3.5, 2) pt(f, R.face, 1) gl(f, fx - 2, 86, R.face)
  end
  -- wing-case coat with pale lateral margins
  local ely = E(32, 69, erx, 15) pt(ely, R.ely, 3) gl(ely, 23, 61 + b, R.ely) gl(ely, 24, 60 + b, R.ely)
  ely:edge():each(function(x, y) if (x < 26 or x > 37) and y < 81 + b and y > 56 + b then put(x, y, R.trim, R.ely) end end)
  -- segmented belly, last plates glow
  local bel = E(32, 71, 8, 12) pt(bel, R.belly, 2)
  for _, y in ipairs{ 64, 68, 72, 76 } do for x = 23, 41 do
    if bel:has(x, y + b) and bel:has(x, y + b - 1) and bel:has(x, y + b + 1) then put(x, y + b, R.belly.shade, R.belly) end end end
  local G = p.lit and R.glow2 or R.glow
  local lo = bel:copy():clip(c:rect(0, 78 + b, 63, 95)) pt(lo, G, 1)
  for x = 23, 41 do if lo:has(x, 80 + b) and lo:has(x, 81 + b) then put(x, 80 + b, G.shade, G) end end
  gl(lo, 29, 79 + b, G) gl(lo, 30, 79 + b, G)
  if V == 1 then -- neckerchief
    local nk = c:poly{ { 23, 53 + b }, { 41, 53 + b }, { 32, 63 + b } } pt(nk, R.cloth, 2)
    for _, q in ipairs{ { 28, 55 }, { 35, 55 }, { 31, 58 } } do put(q[1], q[2] + b, R.cloth.hi, R.cloth) end
  elseif V == 2 then
    pt(c:line({ { 25, 56 + b }, { 29, 77 + b } }, 2), R.prop, 1) -- pack strap
  else -- apron
    local ap = c:rrect(23, 64 + b, 41, 77 + b, 3) ap:add(c:rrect(27, 57 + b, 37, 66 + b, 2)) pt(ap, R.cloth, 2)
    c:rect(29, 69 + b, 35, 74 + b):edge():each(function(x, y) put(x, y, R.cloth.shade, R.cloth) end)
    pt(c:line({ { 28, 57 + b }, { 25, 53 + b } }, 1), R.cloth, 1) pt(c:line({ { 36, 57 + b }, { 39, 53 + b } }, 1), R.cloth, 1)
    for x = 25, 39, 3 do put(x, 76 + b, R.cloth.shade, R.cloth) end
  end
  local lx, rx = 32 - erx - 2, 32 + erx + 2
  if V == 1 then -- trowel
    pt(c:rect(rx - 1, 62 + b, rx + 1, 68 + b), R.prop2, 1)
    local bl = c:poly{ { rx - 3, 70 + b }, { rx + 3, 70 + b }, { rx + 2, 75 + b }, { rx, 78 + b }, { rx - 2, 75 + b } }
    pt(bl, R.prop, 2) for y = 71, 76 do if bl:has(rx, y + b) then put(rx, y + b, R.prop.shade, R.prop) end end
    gl(bl, rx - 2, 71 + b, R.prop) put(rx + 1, 77 + b, R.prop2.shade, R.prop2) -- soil crumb on the tip
  elseif V == 3 then -- ladle held up
    pt(c:line({ { rx, 49 + b }, { rx, 73 + b } }, 2), R.prop, 1)
    local bw = E(rx, 46, 4, 2.5) pt(bw, R.prop, 2) c:fillMask(E(rx, 45.5, 2.5, 1), R.prop.deep) gl(bw, rx - 3, 45 + b, R.prop)
  end
  local la = E(lx + 0.5, 66, 2.5, 4) pt(la, R.face, 1) gl(la, lx - 1, 64 + b, R.face)
  pt(E(rx - 0.5, 66, 2.5, 4), R.face, 1)
  if V ~= 2 then pt(E(rx, 69, 2, 2), R.face, 1) end
  -- head: dark face under the pronotum hood
  local face = E(32, 46, 11, 8) pt(face, R.face, 2)
  local pro = E(32, 33, 14.5, 11) pt(pro, R.pro, 3) gl(pro, 24, 28 + b, R.pro) gl(pro, 25, 27 + b, R.pro)
  pro:edge():each(function(x, y) if y < 41 + b then put(x, y, R.trim2, R.pro) end end)
  c:fillMask(E(32, V == 1 and 34 or 31, 4, 2.5), R.face.shade)
  face:each(function(x, y) if pro:has(x, y - 1) and not pro:has(x, y) then put(x, y, R.face.deep, R.face) end end)
  pt(E(26, 46, 3.5, 3.5), R.dome, 1) pt(E(38, 46, 3.5, 3.5), R.dome, 1)
  pt(E(32, 51, 3, 1.5), R.belly, 1)
  for _, q in ipairs{ { 29, 52 }, { 30, 53 }, { 31, 53 }, { 32, 53 }, { 33, 53 }, { 34, 52 } } do put(q[1], q[2] + b, P.ink) end
  local function eye(x, y)
    put(x + 1, y, P.ink) put(x + 2, y, P.ink)
    for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } } do put(x + q[1], y + q[2], P.cream) end
    put(x + 1, y + 1, P.cream) put(x + 2, y + 1, P.ink) put(x + 1, y + 2, P.ink) put(x + 2, y + 2, P.ink)
  end
  if p.blink then for _, x in ipairs{ 24, 36 } do for i = 0, 3 do put(x + i, 46 + b, P.ink) end end
  else eye(24, 44 + b) eye(36, 44 + b) end
  c:cheek(22, 49 + b) c:cheek(40, 49 + b)
  local ant
  local tw = p.tw or 0
  if V == 1 then -- straw hat, antennae poke through
    local brim = E(32, 25, 18, 4.5, ho)
    pro:each(function(x, y) if brim:has(x, y - 1) and not brim:has(x, y) then put(x, y, R.pro.shade, R.pro) end end)
    pt(brim, R.head, 2) gl(brim, 17, 24 + ho, R.head)
    brim:each(function(x, y) if (x + 2 * y) % 5 == 0 and c:get(x, y) == R.head.base then put(x, y, R.head.shade, R.head) end end)
    local cr = c:rrect(24, 15 + ho, 39, 25 + ho, 4) pt(cr, R.head, 3) gl(cr, 26, 16 + ho, R.head)
    cr:each(function(x, y) if (x + y) % 4 == 0 and c:get(x, y) == R.head.base then put(x, y, R.head.shade, R.head) end end)
    pt(c:rect(24, 22 + ho, 39, 23 + ho), R.cloth, 1)
    pt(c:poly{ { 35, 22 + ho }, { 40, 17 + ho }, { 41, 19 + ho }, { 37, 22 + ho } }, R.cloth, 1)
    ant = { { { 28, 16 + ho }, { 25, 11 + ho }, { 22, 7 } }, { { 35, 16 + ho }, { 38, 11 + ho }, { 41 + tw, 7 } } }
  elseif V == 2 then -- denim cap, brim cocked forward-left
    local dome = E(33, 26, 10, 7, ho):clip(c:rect(0, 0, 63, 26 + ho)) pt(dome, R.head, 3) gl(dome, 27, 21 + ho, R.head)
    for y = 19, 26 do if dome:has(33, y + ho) then put(33, y + ho, R.head.shade, R.head) end end
    local br = E(26, 27, 9, 2.5, ho) pt(br, R.head, 1)
    pt(E(33, 19, 1.5, 1.5, ho), R.head, 1)
    ant = { { { 29, 21 + ho }, { 24, 14 + ho }, { 19, 9 }, { 16, 7 } }, { { 37, 21 + ho }, { 42, 14 + ho }, { 46, 9 }, { 48 + tw, 7 } } }
  else -- polka kerchief tied at the right
    local kc = pro:copy():clip(c:rect(0, 0, 63, 29 + b)) pt(kc, R.head, 2)
    kc:each(function(x, y) if x % 4 == 1 and y % 3 == 0 then put(x, y, R.cloth.hi, R.head) end end)
    for x = 17, 47 do if kc:has(x, 29 + b) then put(x, 29 + b, R.head.shade, R.head) end end
    pt(c:poly{ { 45, 28 + ho }, { 52, 23 + ho }, { 51, 29 + ho } }, R.head, 1)
    pt(c:poly{ { 45, 30 + ho }, { 51, 34 + ho }, { 47, 35 + ho } }, R.head, 1)
    pt(E(45.5, 29.5, 2, 2, ho), R.head, 1)
    ant = { { { 28, 23 + b }, { 26, 17 + b }, { 22, 12 } }, { { 36, 23 + b }, { 38, 17 + b }, { 42 + tw, 12 } } }
  end
  c:finish{ outline = true }
  for _, a in ipairs(ant) do c:fillMask(c:line(a, 1), P.ink) local t = a[#a] put(t[1], t[2] + 1, P.ink) end
  HP.assertClean(c)
  return c
end
local FR = { { bob = 0 }, { bob = 1, hb = 0 }, { bob = 0 }, { bob = 0, blink = true, tw = 1, lit = true } }
local frames = {}
for _, p in ipairs(FR) do frames[#frames + 1] = frame(p) end
local W, H, pc = 64, 96, app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, #frames do spr:newEmptyFrame() end
local strip = Image(W * #frames, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) strip:putPixel((f - 1) * W + i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 4) and 0.22 or 0.32
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, #frames) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * #frames, H, ColorMode.RGB) s2.cels[1].image = strip s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " sprite ok")

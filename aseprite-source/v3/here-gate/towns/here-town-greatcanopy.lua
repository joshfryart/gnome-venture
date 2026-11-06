-- here-town-greatcanopy.lua : Gnome Venture "Hearth Pop" v3 gate-view town, The Greatcanopy
-- (West and Central African rainforest region). 480x270 native, VP (240,112), horizon 112.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local NAME = "here-town-greatcanopy"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos

---------------------------------------------------------------- colour helpers
local function hash(x, y, s)
  local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function hex(r, g, b)
  r, g, b = max(0, min(255, floor(r + .5))), max(0, min(255, floor(g + .5))), max(0, min(255, floor(b + .5)))
  if r == g and g == b and (r == 0 or r == 255) then r = (r == 0) and 3 or 250 end
  return string.format("#%02x%02x%02x", r, g, b)
end
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  return hex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end
local function tint(x, y, col, t) local cur = c:get(x, y) if cur then c:put(x, y, mix(cur, col, t)) end end

local R = {
  earth  = {"#7a3a2a","#a85a3e","#c47448","#d88e5c","#e8a872"},
  lawn   = {"#2f5a2e","#4e8a3c","#6aa646","#86c055","#a8d86a"},
  moss   = {"#264a2c","#3a6a3a","#4f8040","#689a4c","#86b45a"},
  thatch = {"#6e4a22","#9c7034","#c49a4a","#ddb862","#efd384"},
  mud    = {"#7c4a2a","#b0703e","#d0905a","#e4ac74","#f2c690"},
  indigo = {"#2e3466","#4a5598","#6474b8","#8494d0","#a8b6e4"},
  bark   = {"#5c4040","#8a6660","#a8847a","#c2a092","#d8baa8"},
  hib    = {"#6a1a2e","#9a2a40","#c43c52","#de5c6a","#f08890"},
  wood   = {"#3e2218","#5e3624","#7e4a2e","#9e6440","#be8458"},
  board  = {"#6a3410","#a8561e","#d0782e","#e8964a","#f6b86a"},
  trunk  = {"#3a2a2a","#5e4438","#7e5e4a","#9c7a5e","#b89676"},
  canopy = {"#1e4a32","#2e6a3e","#428a44","#62a84c","#8cc85a"},
  jungle = {"#163a2a","#22553a","#2f7046","#4a9050","#74b45a"},
  gold   = {"#7a4a10","#b87a1a","#e0a830","#f0c44a","#f8dc78"},
  teal   = {"#1a4a4a","#2a6e6a","#3a8e86","#5aaea0","#88cabc"},
  skin   = {"#9a7a50","#c8a878","#e6cfa0","#f2e2bc","#faf0d6"},
  olive  = {"#3e4a1a","#5e6e2a","#7e8e3a","#9eae4e","#c0cc6a"},
  cloud  = {"#c9a0a0","#e2b9a6","#f4dcc4","#fbf1dc","#fff8ea"},
  rain   = {"#4e5a76","#6e7c98","#909cb4","#b4bed0","#d0d8e4"},
  glow   = {"#8a4a1a","#c8701e","#f0a030","#f8c860","#fce8a0"},
  stone  = {"#5e4a52","#86707a","#a8949a","#c4b2b2","#ddd0c8"},
}
local CREAM, VIOLET, WARM = "#f6ecd2", "#4a3a6e", "#f4b85a"

---------------------------------------------------------------- painters
local function tone(m, RR, o)
  o = o or {}
  local lw, sw = o.lw or 2, o.sw or 3
  m:each(function(x, y)
    local t = 3
    if not (m:has(x + sw, y + sw) and m:has(x + sw, y) and m:has(x, y + sw)) then t = 2 end
    if not (m:has(x - lw, y - lw) and m:has(x - lw, y) and m:has(x, y - lw)) then t = 4 end
    if o.tex then t = o.tex(x, y, t) end
    c:put(x, y, RR[max(1, min(5, t))])
  end)
  if o.edge ~= false then c:edgeIn(m, o.edgeCol or RR[1]) end
  return m
end
local function chain(...) local fs = {...} return function(x, y, t) for _, f in ipairs(fs) do t = f(x, y, t) end return t end end
local function nz(p, s) return function(x, y, t) local h = hash(x, y, s or 3) if h > 1 - p then return t - 1 elseif h < p * .6 then return t + 1 end return t end end
local function thatchTex(y0) return function(x, y, t)
  if (y - y0) % 7 == 6 then t = t - 1 end
  local v = hash(x, floor((y - y0) / 3), 12)
  if v > .8 then t = t + 1 elseif v < .16 then t = t - 1 end
  return t end end
local function barkTex(x, y, t)
  local v = hash(floor((x + floor(sin(y / 6) * 1.5)) / 2), floor(y / 7), 21)
  if v > .78 then t = t + 1 elseif v < .2 then t = t - 1 end
  if hash(x, y, 22) > .95 then t = t - 1 end
  return t end
local function brickTex(x, y, t)
  local row = floor(y / 5)
  if y % 5 == 0 then return t - 1 end
  if (x + (row % 2) * 5) % 10 == 0 then return t - 1 end
  if hash(x, y, 6) > .94 then t = t - 1 elseif hash(x, y, 7) > .95 then t = t + 1 end
  return t end
local function plasterTex(x, y, t)
  if hash(floor(x / 3), floor(y / 2), 8) > .86 then t = t - 1 end
  if hash(x, y, 9) > .95 then t = t + 1 end
  return t end
local function cyl(cx, hw) return function(x, y, t)
  local u = (x - cx) / hw
  if u < -.55 then t = t + 1 elseif u > .78 then t = t - 2 elseif u > .4 then t = t - 1 end
  return t end end
local function leafTex(s) return function(x, y, t)
  local gy = floor(y / 6) local off = (gy % 2) * 4
  local gx = floor((x + off) / 8)
  local cx = gx * 8 - off + 4 + floor(hash(gx, gy, s) * 3) - 1
  local cy = gy * 6 + 3
  local dx, dy = x - cx, y - cy
  if dy <= -2 and dx <= 1 then t = t + 1 elseif dy >= 2 then t = t - 1 end
  if hash(x, y, s + 1) > .97 then t = t + 1 end
  return t end end
local function grainH(x, y, t) local v = hash(floor(x / 6), y, 31) if v > .8 then t = t + 1 elseif v < .18 then t = t - 1 end return t end
local function grainV(x, y, t) local v = hash(x, floor(y / 6), 32) if v > .8 then t = t + 1 elseif v < .18 then t = t - 1 end return t end
local function shadow(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  local inner = c:ellipse(cx, cy, floor(rx * .72), max(1, floor(ry * .6)))
  m:each(function(x, y) tint(x, y, VIOLET, inner:has(x, y) and .42 or .26) end)
end
local function fern(bx, by, s, seed)
  local n = 7
  for i = 1, n do
    local a = -math.pi / 2 + (i - (n + 1) / 2) * .36 + (hash(i, seed, 1) - .5) * .2
    local L = s * (.7 + .3 * hash(i, seed, 2))
    local px, py = -sin(a), cos(a)
    for k = 0, floor(L) do
      local tt = k / L
      local x = bx + cos(a) * k
      local y = by + sin(a) * k + tt * tt * L * .5
      local lw = floor((1 - tt) * 3.2) + 1
      for j = 1, lw do
        c:put(floor(x + px * j + .5), floor(y + py * j - j * .4 + .5), (k % 3 == 0) and R.jungle[3] or R.jungle[4])
        c:put(floor(x - px * j + .5), floor(y - py * j - j * .4 + .5), (k % 3 == 0) and R.jungle[2] or R.jungle[3])
      end
      c:put(floor(x + .5), floor(y + .5), R.jungle[1])
    end
  end
end
local function poly(p) return c:poly(p) end

---------------------------------------------------------------- 1. sky + clouds
c:stripes(0, 111, {"#8ec4d6","#a8d2d0","#c6dec4","#e2e2b0","#f2d8a0","#f6c48c"}, {3,3,3,3,2,2})
local function cloud(x, y, w)
  local m = c:cloud(x, y, w, R.cloud[4], R.cloud[2])
  tone(m, R.cloud, {lw = 2, sw = 2, edgeCol = R.cloud[2]})
  for xx = x, x + w - 1 do if m:has(xx, y) then c:put(xx, y, R.cloud[1]) end end
end
cloud(92, 62, 46) cloud(146, 38, 30) cloud(300, 64, 50) cloud(350, 40, 34) cloud(196, 30, 28) cloud(258, 28, 30)

---------------------------------------------------------------- 2. far forest ridges (misty)
c:terrain(function(x) return 82 + 8 * sin(x / 41) + 4 * sin(x / 13 + 2) end, "#a4c2a4", 111)
for i = 0, 11 do
  local cx = 14 + i * 42 + floor(hash(i, 1, 61) * 14)
  local cy = 80 + 8 * sin(cx / 41) + 4 * sin(cx / 13 + 2) - 2
  c:fillMask(c:ellipse(cx, cy, 11, 6):add(c:ellipse(cx + 8, cy + 2, 8, 5)), "#a4c2a4")
  c:fillMask(c:ellipse(cx - 2, cy - 2, 6, 2), "#b6cfb0")
end
c:terrain(function(x) return 96 + 5 * sin(x / 23 + 1) + 3 * sin(x / 7) end, "#86ac8c", 111)
for i = 0, 15 do
  local cx = 6 + i * 31 + floor(hash(i, 2, 62) * 10)
  local cy = 94 + 5 * sin(cx / 23 + 1)
  c:fillMask(c:ellipse(cx, cy, 8, 5), "#86ac8c")
  c:fillMask(c:ellipse(cx - 2, cy - 2, 4, 2), "#9cbe9a")
end
c:terrain(function(x) return 105 + 3 * sin(x / 17) end, "#6a9472", 111)

---------------------------------------------------------------- 3. ground (laterite street + mossy verges)
for y = 112, H - 1 do
  local d = (y - 112) / 157
  local half = (y - 112) * 1.25
  for x = 0, W - 1 do
    local ej = (hash(floor(x / 3), floor(y / 2), 51) - .5) * 3
    local col
    if abs(x - 240) > half + ej then
      local t = 3
      local h = hash(x, y, 52)
      if h > .88 then t = 4 elseif h < .1 then t = 2 end
      if abs(x - 240) < half + ej + 2 then t = 2 end
      col = R.moss[t]
    else
      local t = 3
      local sz = 2 + floor(d * 5)
      local hp = hash(floor(x / (sz * 2)), floor(y / sz), 54)
      if hp > .9 then t = 4 if y % sz == sz - 1 then t = 2 end end
      local h = hash(x, y, 53)
      if h > .96 then t = 2 elseif h < .03 then t = 4 end
      col = R.earth[t]
    end
    if d < .2 then col = mix(col, "#b8c8a0", (.2 - d) * 2.2) end
    c:put(x, y, col)
  end
end
for _, s in ipairs{-.95, -.5, .5, .95} do
  for y = 120, H - 1 do
    local x = floor(240 + s * (y - 112) + .5)
    tint(x, y, R.earth[1], .35)
    if y > 190 then tint(x + (s > 0 and 1 or -1), y, R.earth[1], .25) end
  end
end

---------------------------------------------------------------- 4. STORY TREE (s2) box [184,24,296,140]
shadow(240, 137, 62, 5)
local trunk = poly{{228,66},{252,66},{256,96},{262,116},{280,132},{290,138},{262,138},{256,131},{250,138},{232,138},{226,131},{220,138},{190,138},{200,132},{218,116},{224,96}}
tone(trunk, R.trunk, {tex = chain(barkTex, cyl(240, 18))})
for _, L in ipairs{ {{226,104},{208,134}}, {{233,112},{226,136}}, {{254,104},{272,134}}, {{248,112},{255,136}} } do
  c:fillMask(c:line(L, 1), R.trunk[2])
  c:fillMask(c:line(L, 1):shift(-1, 0), R.trunk[4])
end
for _, L in ipairs{ {{232,72},{216,52},{204,44}}, {{248,72},{264,52},{278,44}}, {{240,70},{240,40}} } do
  tone(c:line(L, 4), R.trunk, {lw = 1, sw = 1, tex = barkTex})
end
-- rope ladder climbing into the canopy (quirk: some gnomes never saw the sky)
for y = 70, 132 do c:put(245, y, "#d8b878") c:put(251, y, "#a88850") end
for y = 72, 130, 5 do for x = 246, 250 do c:put(x, y, "#c8a060") end end
local cm = c:ellipse(240, 52, 44, 18):add(c:ellipse(204, 60, 22, 13)):add(c:ellipse(276, 60, 22, 13))
  :add(c:ellipse(222, 40, 22, 13)):add(c:ellipse(260, 39, 24, 13)):add(c:ellipse(240, 32, 18, 8))
  :clip(c:rect(184, 24, 296, 76))
tone(cm, R.canopy, {tex = chain(leafTex(70), function(x, y, t) if not cm:has(x, y + 4) then return t - 1 end return t end)})
-- speech-bubble sign hung from the left bough
for y = 72, 78 do c:put(198, y, R.wood[1]) c:put(210, y, R.wood[1]) end
local bub = c:rrect(193, 78, 215, 90, 4):add(poly{{197,89},{203,89},{195,96}})
tone(bub, R.skin, {lw = 1, sw = 2, edgeCol = R.wood[2]})
for _, x in ipairs{198, 203, 208} do c:fillMask(c:rect(x, 83, x + 1, 84), R.indigo[2]) end
-- ring of carved seats
local function stool(cx, yb, w, RR)
  local hw = floor(w / 2)
  shadow(cx + 1, yb, hw + 1, 2)
  tone(c:rect(cx - floor(hw / 2), yb - 5, cx + floor(hw / 2), yb), RR, {lw = 1, sw = 1})
  tone(c:rect(cx - hw, yb - 8, cx + hw, yb - 6), RR, {lw = 1, sw = 1})
end
stool(198, 140, 12, R.hib) stool(214, 139, 12, R.gold) stool(266, 139, 12, R.teal) stool(282, 140, 12, R.indigo)
-- Grandmother Tortoise's high-backed seat with a shell pattern (quirk)
shadow(241, 140, 12, 2)
local back = c:rrect(232, 116, 248, 134, 4)
tone(back, R.olive, {lw = 1, sw = 2})
back:shrink(1):each(function(x, y)
  local r = floor((y - 116) / 5)
  if (y - 116) % 5 == 0 or (x + (r % 2) * 3) % 6 == 0 then c:put(x, y, R.gold[3]) end
end)
tone(c:rect(229, 132, 251, 135), R.olive, {lw = 1, sw = 1})
tone(c:rect(231, 136, 234, 140), R.wood, {lw = 1, sw = 1}) tone(c:rect(246, 136, 249, 140), R.wood, {lw = 1, sw = 1})

---------------------------------------------------------------- 5. LIBRARY box [100,50,172,138]
shadow(136, 137, 40, 4)
local wall = HP.mask()
for x = 106, 166 do local u = (x - 136) / 30 local yb = 134 + floor(2 * (1 - u * u) + .5) for y = 96, yb do wall:set(x, y) end end
tone(wall, R.indigo, {tex = chain(cyl(136, 30), plasterTex)})
for x = 107, 165 do
  local yy = 102 + abs((x % 8) - 4)
  local cc = x > 156 and R.indigo[4] or CREAM
  c:put(x, yy, cc) c:put(x, yy + 1, cc)
  local k = x % 10 local th = 5 - abs(k - 5)
  for y = 130 - th, 130 do c:put(x, y, x > 156 and R.gold[2] or R.gold[3]) end
end
for x = 106, 166 do c:put(x, 96, R.indigo[1]) c:put(x, 97, R.indigo[2]) end
local function booksIn(m, y0)
  local cols = {R.hib[3], R.gold[3], R.teal[3], R.olive[4], R.board[3], R.indigo[4]}
  m:each(function(x, y)
    local col = cols[(x + floor((y - y0) / 6)) % #cols + 1]
    if (y - y0) % 6 == 5 then col = R.wood[2] end
    if (y - y0) % 6 == 0 and hash(x, y, 81) > .5 then col = WARM end
    c:put(x, y, col)
  end)
end
local door = c:rrect(128, 110, 144, 142, 7):clip(c:rect(128, 110, 144, 135))
tone(door, R.wood, {lw = 1, sw = 1})
booksIn(door:shrink(2), 113)
for _, wx in ipairs{112, 150} do
  local win = c:rrect(wx, 106, wx + 10, 117, 3)
  tone(win, R.wood, {lw = 1, sw = 1})
  booksIn(win:shrink(2), 108)
end
local roof = poly{{100,100},{172,100},{136,58}}
for x = 100, 172 do if hash(x, 0, 83) > .5 or x % 4 == 0 then roof:set(x, 101) end end
tone(roof, R.thatch, {tex = chain(thatchTex(58), cyl(136, 36))})
tone(c:rect(134, 52, 138, 58), R.mud, {lw = 1, sw = 1}) tone(c:rect(135, 50, 137, 51), R.mud, {lw = 1, sw = 1})
-- big open-book sign
local cover = poly{{118,74},{136,78},{154,74},{154,90},{136,94},{118,90}}
tone(cover, R.hib, {lw = 1, sw = 2})
local pl = poly{{120,76},{135,80},{135,91},{120,88}} local pr = poly{{137,80},{152,76},{152,88},{137,91}}
tone(pl, R.skin, {lw = 1, sw = 1, edgeCol = R.skin[2]}) tone(pr, R.skin, {lw = 1, sw = 2, edgeCol = R.skin[2]})
for i = 0, 3 do
  c:fillMask(c:line({{122, 80 + i * 2 + 1}, {133, 83 + i * 2 + 1}}, 1), R.skin[2])
  c:fillMask(c:line({{139, 83 + i * 2 + 1}, {150, 80 + i * 2 + 1}}, 1), R.skin[2])
end
for y = 79, 92 do c:put(136, y, R.hib[1]) end
-- quirk: a ribbon bookmark so long it dangles down to the doorway
for y = 91, 109 do local x = 141 + floor(sin(y / 3) * 1.5 + .5) c:put(x, y, R.gold[3]) c:put(x + 1, y, R.gold[2]) end
c:put(140, 110, R.gold[2]) c:put(143, 110, R.gold[2])

---------------------------------------------------------------- 6. SHOPS (seed shop) box [308,50,390,138]
shadow(349, 137, 42, 4)
local swall = HP.mask()
for x = 318, 380 do local u = (x - 349) / 31 local yb = 134 + floor(2 * (1 - u * u) + .5) for y = 92, yb do swall:set(x, y) end end
tone(swall, R.mud, {tex = chain(cyl(349, 31), brickTex)})
local sroof = poly{{310,94},{388,94},{349,54}}
for x = 310, 388 do if hash(x, 1, 84) > .5 or x % 4 == 1 then sroof:set(x, 95) end end
tone(sroof, R.thatch, {tex = chain(thatchTex(54), cyl(349, 39))})
tone(c:rect(347, 50, 351, 55), R.hib, {lw = 1, sw = 1})
-- seed sign: sprout on a board
local sb = c:rect(338, 72, 360, 89)
tone(sb, R.skin, {lw = 1, sw = 2, edgeCol = R.wood[2]})
for y = 78, 86 do c:put(349, y, R.jungle[2]) end
tone(poly{{349,80},{341,75},{343,82}}, R.jungle, {lw = 1, sw = 1})
tone(poly{{349,79},{357,74},{355,81}}, R.jungle, {lw = 1, sw = 1})
tone(c:rrect(345, 85, 353, 88, 1), R.board, {lw = 1, sw = 1})
-- kente-striped stall awning with scalloped valance
local aw = poly{{310,98},{388,98},{390,108},{308,108}}
local kc = {R.gold, R.jungle, R.hib, R.gold, R.indigo}
aw:each(function(x, y)
  local k = floor((x - 308) / 6) % #kc + 1
  local t = (y >= 106) and 2 or ((y <= 99) and 4 or 3)
  if (x - 308) % 6 == 0 then t = t - 1 end
  c:put(x, y, kc[k][t])
end)
c:edgeIn(aw, R.wood[1])
for x = 309, 389 do local k = (x - 308) % 6 local th = 3 - abs(k - 3) for y = 109, 109 + th do c:put(x, y, kc[floor((x - 308) / 6) % #kc + 1][2]) end end
tone(c:rect(311, 109, 313, 134), R.wood, {lw = 1, sw = 1}) tone(c:rect(385, 109, 387, 134), R.wood, {lw = 1, sw = 1})
local counter = c:rect(316, 119, 382, 134)
tone(counter, R.thatch, {tex = function(x, y, t) if ((x // 2) + (y // 2)) % 2 == 0 then return t - 1 end return t end})
tone(c:rect(314, 117, 384, 119), R.wood, {lw = 1, sw = 1})
local seeds = {R.hib, R.gold, R.skin, R.olive}
for i, cx in ipairs{325, 341, 357, 373} do
  local bowl = c:ellipse(cx, 116, 7, 4):clip(c:rect(cx - 8, 115, cx + 8, 120))
  local pile = c:ellipse(cx, 115, 6, 3):clip(c:rect(cx - 7, 111, cx + 7, 115))
  tone(pile, seeds[i], {lw = 1, sw = 1, tex = nz(.25, 90 + i)})
  if i == 3 then pile:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.wood[1]) end end) end
  tone(bowl, R.wood, {lw = 1, sw = 1, tex = grainH})
end

---------------------------------------------------------------- 7. WILD TRAIL box [402,56,456,142]
shadow(429, 141, 28, 3)
local outer = c:rrect(404, 58, 454, 150, 20):clip(c:rect(404, 58, 454, 140))
local inner = c:rrect(412, 68, 446, 160, 15):clip(c:rect(412, 68, 446, 140))
inner:each(function(x, y)
  local dd = (y - 68) / 72
  local col = (dd < .5) and R.jungle[1] or R.jungle[2]
  if hash(x, floor(y / 3), 101) > .85 then col = R.jungle[3] end
  c:put(x, y, col)
end)
c:fillMask(c:rect(426, 88, 432, 100), "#c8e8a0") c:fillMask(c:rect(427, 86, 431, 87), "#c8e8a0")
local tpath = poly{{414,140},{444,140},{433,101},{427,101}}
tone(tpath, R.earth, {lw = 1, sw = 2, tex = function(x, y, t) if y < 116 then return t - 1 end return t end})
local band = outer:copy():cut(inner)
tone(band, R.moss, {tex = leafTex(102)})
for x = 404, 412 do for y = 104, 140 do if band:has(x, y) then c:put(x, y, ((x + floor(y / 4)) % 5 == 0) and R.wood[2] or R.wood[3]) end end end
for x = 446, 454 do for y = 104, 140 do if band:has(x, y) then c:put(x, y, ((x + floor(y / 4)) % 5 == 0) and R.wood[1] or R.wood[2]) end end end
c:edgeIn(band, R.jungle[1])
for _, vx in ipairs{418, 425, 437, 443} do
  local len = 8 + floor(hash(vx, 0, 103) * 10)
  for y = 68, 68 + len do c:put(vx, y, R.moss[4]) if y % 3 == 0 then c:put(vx - 1, y, R.moss[5]) c:put(vx + 1, y + 1, R.moss[3]) end end
end
for _, f in ipairs{{"#e8705a", 410, 74}, {"#f0c44a", 448, 80}, {"#e8705a", 452, 98}, {"#f08890", 406, 92}} do
  c:fillMask(c:rect(f[2], f[3], f[2] + 2, f[3] + 1), f[1]) c:put(f[2] + 1, f[3] - 1, f[1])
end
-- signpost pointing into the wild
tone(c:rect(440, 116, 442, 140), R.wood, {lw = 1, sw = 1})
local arrow = poly{{426,117},{450,117},{455,122},{450,127},{426,127}}
tone(arrow, R.board, {lw = 1, sw = 2})
tone(poly{{432,122},{438,119},{444,121},{438,125}}, R.jungle, {lw = 1, sw = 1})

---------------------------------------------------------------- 8. NOTICE BOARD box [30,40,88,124]
shadow(59, 124, 32, 3)
tone(c:rect(36, 50, 40, 124), R.wood, {lw = 1, sw = 2, tex = grainV}) tone(c:rect(76, 50, 80, 124), R.wood, {lw = 1, sw = 2, tex = grainV})
tone(poly{{30,58},{88,58},{80,44},{38,44}}, R.thatch, {tex = thatchTex(44)})
tone(c:rect(38, 42, 80, 44), R.wood, {lw = 1, sw = 1})
tone(c:rect(38, 60, 78, 108), R.board, {tex = chain(grainH, nz(.08, 110))})
local papers = {
  {42,64,55,78,CREAM}, {59,63,71,74,"#f4e48a"}, {74,66,76,79,"#bcd8ec"}, {43,82,57,96,"#f2bcc4"},
  {61,78,74,90,CREAM}, {62,94,75,104,"#c4e8c0"}, {42,99,55,105,"#f4e48a"},
}
for i, p in ipairs(papers) do
  local m = c:rect(p[1], p[2], p[3], p[4])
  c:fillMask(m, p[5])
  for x = p[1], p[3] do c:put(x, p[4], mix(p[5], VIOLET, .25)) end
  for y = p[2], p[4] do c:put(p[3], y, mix(p[5], VIOLET, .25)) end
  for y = p[2] + 4, p[4] - 2, 3 do for x = p[1] + 2, p[3] - 2 do if hash(x, y, 120 + i) > .3 then c:put(x, y, mix(p[5], R.indigo[2], .45)) end end end
  local px = floor((p[1] + p[3]) / 2)
  c:fillMask(c:rect(px, p[2], px + 1, p[2] + 1), R.hib[3])
end
-- a picture note: a drawn leaf; a curled corner
tone(poly{{64,82},{70,80},{72,84},{66,87}}, R.lawn, {lw = 1, sw = 1})
c:put(55, 64, R.board[2]) c:put(54, 64, R.skin[2]) c:put(55, 65, R.skin[2])
-- pinned papers spill down: a little banner of pins on the post
for y = 110, 120, 5 do c:fillMask(c:rect(76, y, 80, y + 2), "#f4e48a") c:put(78, y, R.hib[3]) end

---------------------------------------------------------------- 9. THE BAOBAB BAR (tea) box [24,140,136,226]
shadow(80, 223, 58, 5)
local tr = HP.mask()
for y = 150, 222 do local t = (y - 150) / 72 local hw = floor(14 + 18 * sqrt(t) + .5) for x = 66 - hw, 66 + hw do tr:set(x, y) end end
for _, L in ipairs{ {{60,158},{50,150},{38,148}}, {{66,156},{66,146}}, {{72,158},{88,150},{112,148}} } do tr:add(c:line(L, 6)) end
tone(tr, R.bark, {tex = chain(barkTex, cyl(66, 26))})
for _, e in ipairs{{36,146,8,4}, {66,145,7,4}, {114,145,8,4}} do
  tone(c:ellipse(e[1], e[2], e[3], e[4]):add(c:ellipse(e[1] + 5, e[2] + 1, 5, 3)), R.canopy, {lw = 1, sw = 2, tex = leafTex(130)})
end
-- painted band round the trunk
for x = 38, 96 do if tr:has(x, 188) then
  local k = x % 8 local th = 3 - abs(k - 4) // 1
  for y = 186, 190 do c:put(x, y, R.hib[3]) end
  for y = 189 - max(0, th), 189 do c:put(x, y, CREAM) end
  c:put(x, 185, R.bark[1]) c:put(x, 191, R.bark[1])
end end
local tdoor = c:rrect(56, 194, 76, 230, 9):clip(c:rect(56, 194, 76, 222))
tone(tdoor, R.wood, {lw = 1, sw = 1})
tdoor:shrink(2):each(function(x, y) c:put(x, y, (y > 210 and (x + y) % 2 == 0) and R.glow[3] or WARM) end)
for x = 59, 73 do c:put(x, 206, R.wood[2]) end
for _, jx in ipairs{60, 65, 70} do c:fillMask(c:rect(jx, 202, jx + 2, 205), R.hib[3]) end
local twin = c:rrect(40, 170, 52, 182, 4)
tone(twin, R.wood, {lw = 1, sw = 1})
twin:shrink(2):each(function(x, y) c:put(x, y, (x == 46 or y == 176) and R.wood[2] or WARM) end)
-- porch: thatch lean-to, red counter, teapot, cups
tone(poly{{92,170},{134,174},{136,184},{90,180}}, R.thatch, {tex = thatchTex(170)})
tone(c:rect(130, 184, 133, 222), R.wood, {lw = 1, sw = 1})
local tc = c:rect(94, 203, 128, 222)
tone(tc, R.hib, {tex = nz(.06, 131)})
for x = 96, 126 do local yy = 211 + abs((x % 6) - 3) c:put(x, yy, CREAM) end
tone(c:rect(92, 200, 134, 202), R.wood, {lw = 1, sw = 1, tex = grainH})
tone(c:rrect(100, 191, 110, 199, 3), R.teal, {lw = 1, sw = 1})
c:fillMask(c:line({{110,195},{114,191}}, 1), R.teal[1])
tone(c:rect(103, 189, 107, 190), R.teal, {lw = 1, sw = 1}) c:put(105, 188, R.teal[1])
for _, cx in ipairs{117, 123} do tone(c:rect(cx, 195, cx + 3, 199), R.skin, {lw = 1, sw = 1}) c:put(cx + 1, 195, R.hib[2]) c:put(cx + 2, 195, R.hib[2]) end
c:put(114, 188, CREAM) c:put(115, 186, CREAM) c:put(114, 184, CREAM)
-- sign: hibiscus-red board with a teacup
for y = 150, 153 do c:put(104, y, R.wood[1]) c:put(120, y, R.wood[1]) end
tone(c:rect(100, 154, 124, 168), R.hib, {lw = 1, sw = 2})
tone(poly{{105,159},{115,159},{114,164},{106,164}}, R.skin, {lw = 1, sw = 1})
c:put(116, 160, R.skin[4]) c:put(117, 161, R.skin[4]) c:put(116, 162, R.skin[4])
for x = 104, 117 do c:put(x, 165, R.skin[3]) end
c:put(108, 157, CREAM) c:put(109, 156, CREAM) c:put(111, 157, CREAM) c:put(112, 156, CREAM)
-- quirk: a teapot hung from a branch as a lantern, steaming
for y = 150, 155 do c:put(42, y, R.wood[1]) end
local tp = c:rrect(36, 156, 48, 164, 3)
tone(tp, R.gold, {lw = 1, sw = 1})
c:put(40, 160, R.glow[5]) c:put(44, 159, R.glow[5]) c:put(42, 161, R.glow[5])
c:fillMask(c:line({{48,159},{52,156}}, 1), R.gold[1])
c:put(53, 154, CREAM) c:put(54, 152, CREAM) c:put(53, 150, CREAM)

---------------------------------------------------------------- 10. THE SHADY GREEN box [148,146,332,226]
local lawn = poly{{182,150},{298,150},{328,222},{152,222}}
for _, p in ipairs{{182,150},{298,150},{328,222},{152,222}} do
  for dy = -3, 3 do for dx = -4, 4 do local x, y = p[1] + dx, p[2] + dy
    if lawn:has(x, y) and abs(dx) + abs(dy) <= 4 and not lawn:has(x + (dx > 0 and 2 or -2), y + (dy > 0 and 2 or -2)) then lawn.s[(y + 256) * 1024 + x + 256] = nil end
  end end
end
local ring = lawn:grow(2):cut(lawn)
local rc = {R.hib[3], R.gold[3], CREAM, R.indigo[4]}
ring:each(function(x, y)
  local k = floor((x + y * 2) / 7) % 4 + 1
  local col = rc[k]
  if (x + y * 2) % 7 == 0 then col = R.stone[1] elseif not ring:has(x, y + 1) or not ring:has(x + 1, y) then col = mix(col, VIOLET, .3) end
  c:put(x, y, col)
end)
lawn:each(function(x, y)
  local stripe = floor((x - 240) / (y - 100) * 5) % 2
  local t = 3 + stripe
  if not (lawn:has(x + 3, y + 3) and lawn:has(x, y + 3)) then t = 2 end
  local h = hash(x, y, 140)
  if h > .93 then t = t + 1 elseif h < .07 then t = t - 1 end
  if (y % 4 == 0) and hash(floor(x / 3), y, 141) > .8 then t = 2 c:put(x, y - 1, R.lawn[5]) end
  c:put(x, y, R.lawn[max(1, min(5, t))])
end)
c:edgeIn(lawn, R.lawn[1])
-- flowers along the edges (kept off the centre stand point)
lawn:shrink(3):each(function(x, y)
  local dx, dy = (x - 240) / 60, (y - 186) / 30
  if dx * dx + dy * dy > 1 and hash(x, y, 142) > .985 then
    local col = (hash(x, y, 143) > .5) and R.hib[4] or R.gold[4]
    c:put(x, y, col) c:put(x - 1, y, col) c:put(x, y - 1, R.glow[5])
  end
end)
fern(158, 221, 14, 1) fern(322, 221, 14, 2) fern(186, 153, 10, 3) fern(294, 153, 10, 4)
-- green sign: a gold pennant with a leaf
tone(c:rect(164, 192, 165, 218), R.wood, {lw = 1, sw = 1, edge = false})
local pen = poly{{166,192},{186,192},{181,198},{186,204},{166,204}}
tone(pen, R.gold, {lw = 1, sw = 2})
tone(poly{{169,198},{175,194},{180,197},{174,201}}, R.jungle, {lw = 1, sw = 1})
for x = 170, 178 do c:put(x, 198, R.jungle[4]) end
-- quirk: a giant leaf parasol over a tiny bench
shadow(311, 210, 14, 3)
tone(c:rect(304, 204, 320, 206), R.wood, {lw = 1, sw = 1}) tone(c:rect(305, 207, 306, 210), R.wood, {lw = 1, sw = 1}) tone(c:rect(318, 207, 319, 210), R.wood, {lw = 1, sw = 1})
c:fillMask(c:line({{313,212},{311,176}}, 2), R.wood[2])
local leaf = poly{{290,178},{302,167},{320,164},{332,170},{326,180},{306,182}}
tone(leaf, R.jungle, {tex = function(x, y, t) if (x + y) % 6 == 0 then return t - 1 end return t end})
c:fillMask(c:line({{292,178},{306,170},{330,170}}, 1), R.jungle[5])

---------------------------------------------------------------- 11. DRUM CIRCLE (s1) box [344,146,456,226]
local mat = poly{{352,198},{450,198},{455,224},{347,224}}
tone(mat, R.thatch, {tex = function(x, y, t)
  if y <= 200 or y >= 222 then return 2 end
  if ((x // 2) + (y // 2)) % 2 == 0 then return t - 1 end return t end})
mat:each(function(x, y) if y == 201 or y == 221 then c:put(x, y, R.hib[3]) end end)
local function drum(cx, yt, w, h, RR)
  local hw = floor(w / 2)
  shadow(cx + 3, yt + h, hw + 4, 3)
  local wy = yt + floor(h * .62)
  local body = poly{{cx - hw, yt + 3}, {cx + hw, yt + 3}, {cx + floor(hw * .42), wy}, {cx + floor(hw * .7), yt + h}, {cx - floor(hw * .7), yt + h}, {cx - floor(hw * .42), wy}}
  tone(body, RR, {tex = chain(cyl(cx, hw), grainV)})
  local y1 = yt + floor(h * .48)
  local tops, bots = {}, {}
  for k = -2, 2 do tops[#tops + 1] = cx + floor(k * hw * .4) bots[#bots + 1] = cx + floor((k + .5) * hw * .26) end
  for i = 1, #tops do
    c:fillMask(c:line({{tops[i], yt + 4}, {bots[i], y1}}, 1):clip(body), R.skin[4])
    if i < #tops then c:fillMask(c:line({{tops[i + 1], yt + 4}, {bots[i], y1}}, 1):clip(body), R.skin[3]) end
  end
  for x = cx - hw, cx + hw do if body:has(x, y1) then c:put(x, y1, R.skin[2]) c:put(x, y1 + 1, R.skin[3]) end end
  for x = cx - hw, cx + hw do if body:has(x, yt + h - 3) and (x % 3 ~= 0) then c:put(x, yt + h - 3, R.gold[4]) end end
  local head = c:rect(cx - hw - 1, yt, cx + hw + 1, yt + 3)
  tone(head, R.skin, {lw = 1, sw = 1, edgeCol = R.wood[2]})
end
drum(366, 178, 20, 40, R.teal) drum(392, 168, 28, 50, R.hib) drum(420, 176, 22, 42, R.gold) drum(444, 186, 16, 32, R.indigo)
-- drumsticks on the mat
c:fillMask(c:line({{400,216},{410,221}}, 1), R.wood[2]) c:fillMask(c:line({{402,220},{412,217},{413,214}}, 1), R.wood[3])
-- quirk: the drummers have played a little rain in over the big drum
local rc2 = c:cloud(380, 161, 24, R.rain[4], R.rain[2])
tone(rc2, R.rain, {lw = 2, sw = 2, edgeCol = R.rain[2]})
for i, x in ipairs{383, 387, 391, 395, 399} do local y0 = 163 + (i % 2) * 2 c:put(x, y0, "#7aa8d8") c:put(x, y0 + 1, "#7aa8d8") end
-- sign: a pole with a red flag showing a drum
tone(c:rect(349, 160, 350, 199), R.wood, {lw = 1, sw = 1, edge = false})
tone(c:rect(351, 160, 365, 171), R.hib, {lw = 1, sw = 2})
c:fillMask(poly{{354,163},{362,163},{360,166},{361,169},{355,169},{356,166}}, CREAM)
for x = 354, 362 do c:put(x, 163, R.skin[2]) end

---------------------------------------------------------------- 12. side ferns near the horizon verges
fern(94, 138, 9, 5) fern(178, 140, 8, 6) fern(300, 140, 8, 7) fern(396, 140, 8, 8) fern(30, 226, 12, 9) fern(142, 224, 9, 10) fern(338, 224, 9, 11)

---------------------------------------------------------------- 13. overhead canopy + lianas
local cl = c:ellipse(40, 18, 46, 16):add(c:ellipse(98, 12, 38, 10)):add(c:ellipse(12, 38, 18, 14))
local cr = c:ellipse(440, 18, 46, 16):add(c:ellipse(382, 12, 38, 10)):add(c:ellipse(468, 38, 18, 14))
tone(cl, R.canopy, {tex = leafTex(150)}) tone(cr, R.canopy, {tex = leafTex(151)})
for _, lx in ipairs{118, 364} do
  for y = 18, 62 do
    local x = lx + floor(sin(y / 5) * 1.5 + .5)
    c:put(x, y, R.jungle[2])
    if y % 7 == 0 then c:put(x + 1, y, R.jungle[4]) c:put(x + 2, y + 1, R.jungle[3]) end
    if y % 7 == 3 then c:put(x - 1, y, R.jungle[4]) c:put(x - 2, y + 1, R.jungle[3]) end
  end
  tone(poly{{lx - 1, 62}, {lx + 3, 64}, {lx + 1, 70}, {lx - 2, 66}}, R.jungle, {lw = 1, sw = 1})
end

---------------------------------------------------------------- 14. shafts of green light (from upper left)
for _, s in ipairs{{96, 10}, {262, 14}, {330, 8}} do
  for y = 20, 236 do
    local x0 = floor(s[1] + (y - 20) * .55)
    local str = (y < 120) and .16 or .09
    for x = x0, x0 + s[2] do if x >= 22 and x < 458 then tint(x, y, "#eaf6b0", str) end end
  end
end

---------------------------------------------------------------- 15. the gate frame (carved iroko, painted)
local function post(x0, x1)
  local m = c:rect(x0, 14, x1, H - 1)
  tone(m, R.wood, {tex = grainV})
  local mx = floor((x0 + x1) / 2)
  for _, py in ipairs{40, 104, 168, 232} do
    for y = py, py + 28 do for x = x0 + 3, x1 - 3 do
      local k = abs(x - mx) + abs(y - (py + 14))
      if k % 6 == 0 then c:put(x, y, R.gold[3]) elseif k % 6 == 3 then c:put(x, y, R.hib[3]) elseif k % 6 == 1 and k < 8 then c:put(x, y, CREAM) end
    end end
    for x = x0 + 1, x1 - 1 do c:put(x, py - 2, R.wood[1]) c:put(x, py + 30, R.wood[1]) c:put(x, py - 1, R.wood[4]) end
  end
end
post(0, 21) post(458, 479)
tone(c:rect(0, 0, W - 1, 13), R.wood, {tex = grainH})
for x = 2, W - 3 do
  local k = x % 12 local th = 6 - abs(k - 6)
  local col = ({R.gold[3], R.hib[3], R.indigo[4]})[floor(x / 12) % 3 + 1]
  for y = 10 - floor(th * .9), 10 do c:put(x, y, col) end
  c:put(x, 3, R.wood[1]) c:put(x, 11, R.wood[1])
end
local fringe = HP.mask()
for x = 0, W - 1 do for y = 14, 17 + floor(hash(floor(x / 3), 0, 41) * 5) do fringe:set(x, y) end end
tone(fringe, R.thatch, {lw = 1, sw = 2, tex = thatchTex(14)})
tone(c:rect(0, 14, 25, 21), R.wood, {lw = 1, sw = 2}) tone(c:rect(454, 14, 479, 21), R.wood, {lw = 1, sw = 2})
tone(c:rect(0, 254, 25, 269), R.stone, {tex = nz(.1, 160)})
-- bunting
for x = 22, 457 do local u = (x - 240) / 218 c:put(x, 22 + floor(14 * (1 - u * u)), R.wood[2]) end
local bc = {R.gold, R.lawn, R.hib, R.indigo, R.skin}
local bi = 0
for xf = 28, 452, 12 do
  bi = bi + 1
  local u = (xf - 240) / 218 local yr = 22 + floor(14 * (1 - u * u))
  local RR = bc[bi % #bc + 1]
  for r = 0, 7 do local hw = floor((7 - r) * 3 / 7 + .5) for dx = -hw, hw do c:put(xf + dx, yr + 1 + r, dx > 0 and RR[2] or RR[3]) end end
  c:put(xf - 1, yr + 2, RR[5])
end
-- hanging calabash lanterns with warm glow
local function lantern(cx)
  for dy = -30, 30 do for dx = -30, 30 do
    local d = abs(dx) + abs(dy)
    local x, y = cx + dx, 32 + dy
    if d <= 30 and x >= 22 and x < 458 and y > 13 then tint(x, y, "#ffd27a", d <= 14 and .22 or .1) end
  end end
  for y = 14, 21 do c:put(cx, y, R.wood[1]) end
  tone(c:rect(cx - 4, 21, cx + 4, 23), R.wood, {lw = 1, sw = 1})
  local body = c:ellipse(cx, 32, 6, 8)
  tone(body, R.glow, {lw = 2, sw = 2})
  body:shrink(2):each(function(x, y) if (x + y) % 4 == 0 and y % 3 ~= 0 then c:put(x, y, "#fff2b8") end end)
  tone(c:rect(cx - 2, 41, cx + 2, 42), R.wood, {lw = 1, sw = 1})
  for y = 43, 46 do c:put(cx, y, R.hib[3]) c:put(cx - 1, y + 1, R.hib[2]) end
end
lantern(56) lantern(424)

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

---------------------------------------------------------------- layout
local spots = {
  {"green", "The Shady Green", {148,146,332,226}},
  {"tea", "The Baobab Bar", {24,140,136,226}},
  {"board", "Notice Board", {30,40,88,124}},
  {"library", "Library", {100,50,172,138}},
  {"s1", "Drum Circle", {344,146,456,226}},
  {"s2", "Story Tree", {184,24,296,140}},
  {"shops", "Shops", {308,50,390,138}},
  {"wild", "Wild Trail", {402,56,456,142}},
}
local stand = {{70,248},{140,248},{210,248},{280,248},{350,248},{240,186}}
local parts = {}
for _, s in ipairs(spots) do
  local b = s[3]
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], (b[1] + b[3]) // 2, (b[2] + b[4]) // 2, b[1], b[2], b[3], b[4])
end
local sp = {}
for _, p in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write('{"w":480,"h":270,"horizon":112,"view":"gate","spots":[' .. table.concat(parts, ",") .. '],"stand":[' .. table.concat(sp, ",") .. '],"compass_clear":[380,230,480,270]}\n')
f:close()

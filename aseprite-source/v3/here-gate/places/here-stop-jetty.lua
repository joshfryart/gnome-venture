-- Gnome Venture "Hearth Pop" v3: here-stop-jetty (gate view, hero scale, 480x270 native)
-- Lakeside jetty rest stop at golden evening. Spots: do (fishing jetty), people (campfire),
-- stop (notice board + stamp box), homes (two stilt huts), wild (driftwood arch, right edge).
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params["out"]) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-jetty"
local W, H, VX, VY = 480, 270, 240, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, max, min, abs = math.floor, math.sin, math.max, math.min, math.abs

-------------------------------------------------------------- colour helpers
local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function hex(r,g,b)
  local function cl(v) return max(6, min(250, floor(v + .5))) end
  return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b))
end
local function mix(a, b, t) local r1,g1,b1 = rgb(a) local r2,g2,b2 = rgb(b) return hex(r1+(r2-r1)*t, g1+(g2-g1)*t, b1+(b2-b1)*t) end
local SH, LT = "#2e2148", "#fff0c0"
local function dk(a, t) return mix(a, SH, t) end
local function lt(a, t) return mix(a, LT, t) end
local function Hs(x, y, s) local n = sin(x*12.9898 + y*78.233 + (s or 0)*37.719) * 43758.5453 return n - floor(n) end
local function put(x, y, h) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, h) end end
local function fillF(m, f) m:each(function(x, y) local h = f(x, y) if h then put(x, y, h) end end) end
local function rect(x0,y0,x1,y1) return c:rect(x0,y0,x1,y1) end
local function poly(p) return c:poly(p) end
-- solid object: dark rim of own colour, then lit/shaded body (light upper-left)
local function solid(m, base, o)
  o = o or {}
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return m end
  if o.rim ~= false then c:rim(m, o.edge or dk(base, .62)) end
  local w, h = max(1, x1 - x0), max(1, y1 - y0)
  fillF(m, function(x, y)
    local fx, fy = (x - x0) / w, (y - y0) / h
    local col = base
    if fx > (o.shadeAt or .74) then col = dk(base, .22) end
    if fy > .86 and not o.noBottom then col = dk(col, .14) end
    if (x - x0) < 2 or (y - y0) < 1 then col = lt(base, .22) end
    if o.tex then col = o.tex(x, y, col) end
    return col
  end)
  return m
end
local function shadow(cx, cy, rx, ry, col) fillF(c:ellipse(cx, cy, rx, ry), function() return col end) end

-------------------------------------------------------------- sky (golden evening)
c:stripes(0, 111, { "#58488a", "#6c579b", "#8a64a6", "#a970a6", "#c97f9f", "#e29690", "#f1ae88", "#f7c78c", "#fbdba2" },
  { 3, 3, 3, 2.5, 2.5, 2, 2, 1.6, 1.2 })
-- glowing streaks near the horizon
for i, s in ipairs({ {150, 330, 88}, {120, 360, 93}, {180, 300, 84} }) do
  for x = s[1], s[2] do if Hs(x // 5, i, 2) > .3 then put(x, s[3], "#fde6b0") end end
end
c:cloud(48, 62, 64, "#f6cdb0", "#c98a9f")
c:cloud(118, 40, 38, "#f3c4b2", "#bf86a6")
c:cloud(318, 52, 78, "#f7d2b2", "#cd8c9c")
c:cloud(400, 30, 40, "#eebbb6", "#b582a8")

-------------------------------------------------------------- far hills + treeline
for x = 0, W - 1 do
  local t = floor(90 + 6*sin(x/37) + 3*sin(x/11 + 2))
  for y = t, 111 do put(x, y, y == t and "#a58bb4" or "#8a74a8") end
end
for x = 0, W - 1 do
  local t = floor(101 + 4*sin(x/29 + 1) + 2*sin(x/7))
  for y = t, 111 do put(x, y, y == t and "#8193b4" or (Hs(x, y, 4) > .85 and "#5f7096" or "#6a7aa0")) end
end
-- pines on both far shores
local function pine(x, base, hgt)
  local m = poly{ {x - hgt*.35, base}, {x + hgt*.35, base}, {x, base - hgt} }
  fillF(m, function(px, py) return px < x and "#4f6b78" or "#3f5666" end)
end
for i = 0, 14 do local x = 22 + i * 12 + floor(Hs(i, 1, 5) * 6) pine(x, 111, 7 + floor(Hs(i, 2, 5) * 7)) end
for i = 0, 12 do local x = 300 + i * 13 + floor(Hs(i, 3, 5) * 6) pine(x, 111, 6 + floor(Hs(i, 4, 5) * 8)) end

-------------------------------------------------------------- beacon (lighthouse-like post) far end of the jetty
do
  local tower = poly{ {232, 112}, {248, 112}, {245, 47}, {235, 47} }
  c:rim(tower, "#5a2430")
  fillF(tower, function(x, y)
    local band = ((y - 47) // 9) % 2 == 0
    local col = band and "#c8463c" or "#f1e2c4"
    if x >= 243 then col = dk(col, .25) elseif x <= 235 then col = lt(col, .2) end
    return col
  end)
  local gal = rect(229, 44, 251, 46) c:rim(gal, "#2e2230") solid(gal, "#5c4a52", { rim = false })
  local room = rect(232, 31, 248, 43) c:rim(room, "#2e2230")
  fillF(room, function(x, y)
    if x == 236 or x == 240 or x == 244 then return "#3e3040" end
    if y <= 33 then return "#f9cf6a" end
    return (x > 236 and x < 244) and "#fff1b8" or "#ffd97a"
  end)
  local roof = poly{ {228, 31}, {252, 31}, {240, 20} } c:rim(roof, "#5a2430")
  fillF(roof, function(x, y) return x < 240 and "#d65a48" or "#a83c36" end)
  for y = 15, 19 do put(240, y, "#3e3040") end put(240, 14, "#f6c66a")
  -- light beams (dashed)
  for x = 196, 228 do if (x // 3) % 2 == 0 then put(x, 36, "#fde6a0") put(x + 2, 38, "#fbe0b0") end end
  for x = 252, 288 do if (x // 3) % 2 == 0 then put(x, 36, "#fde6a0") put(x - 2, 38, "#fbe0b0") end end
end

-------------------------------------------------------------- water (still lake, reflects sky)
local function shoreY(x) return 174 + floor(2 * sin(x / 17)) end
local water = HP.mask()
for x = 0, W - 1 do for y = 112, shoreY(x) do water:set(x, y) end end
local function waterAt(y) return mix("#6c93aa", "#3a6886", (y - 112) / 64) end
fillF(water, function(x, y)
  local src = c:get(x, 223 - y) or "#f7c78c"
  local col = mix(src, waterAt(y), .42 + .32 * (y - 112) / 64)
  if y % 3 == 0 and Hs(x // 7, y, 3) > .78 then col = mix(col, "#dbe8e2", .45)
  elseif y % 4 == 1 and Hs(x // 9, y, 6) > .82 then col = dk(col, .18) end
  return col
end)

-------------------------------------------------------------- beacon islet
do
  local isl = poly{ {216, 121}, {223, 113}, {232, 109}, {249, 109}, {257, 113}, {264, 121} }
  c:rim(isl, "#3c3450")
  fillF(isl, function(x, y)
    local col = "#7d7290"
    if x < 236 and y < 116 then col = "#9d92aa" elseif x > 250 then col = "#5f5675" end
    if Hs(x // 3, y // 2, 8) > .8 then col = dk(col, .2) end
    return col
  end)
end

-------------------------------------------------------------- hut reflections need huts first: draw homes
local HOMES = { 292, 58, 416, 164 }
do
  -- platform deck + stilts
  local function hut(x0, x1, y0, y1, wall, roofCol, peakY, eaveOut)
    local roof = poly{ {x0 - eaveOut, y0 + 2}, {x1 + eaveOut, y0 + 2}, {(x0 + x1) / 2, peakY} }
    local body = rect(x0, y0, x1, y1)
    c:rim(body, dk(wall, .65))
    fillF(body, function(x, y)
      local col = wall
      if (x - x0) % 6 == 0 then col = dk(wall, .3) end
      if x > x1 - 7 then col = dk(col, .2) elseif x < x0 + 3 then col = lt(col, .18) end
      if y > y1 - 3 then col = dk(col, .2) end
      if Hs(x, y // 3, 9) > .9 then col = dk(col, .12) end
      return col
    end)
    -- eave shadow under roof
    for x = x0, x1 do put(x, y0, dk(wall, .4)) put(x, y0 + 1, dk(wall, .25)) end
    c:rim(roof, dk(roofCol, .65))
    local cx = (x0 + x1) / 2
    fillF(roof, function(x, y)
      local col = roofCol
      if (y - peakY) % 5 == 4 then col = dk(roofCol, .32)
      elseif ((x + ((y - peakY) // 5) * 3) % 6) == 0 then col = dk(roofCol, .2) end
      if x > cx + 2 then col = dk(col, .18) elseif x < cx - 6 and (y - peakY) % 5 == 0 then col = lt(col, .25) end
      return col
    end)
    return roof, body
  end
  -- platform
  local deck = rect(292, 140, 416, 145)
  c:rim(deck, "#4a2f22")
  fillF(deck, function(x, y)
    local col = (x // 9) % 2 == 0 and "#a8774c" or "#9a6c44"
    if y == 140 then col = lt(col, .25) elseif y >= 144 then col = dk(col, .3) end
    if x % 9 == 0 then col = "#5e3e2a" end
    return col
  end)
  -- hut 1 (blue boards, rust roof) + chimney
  local chim = rect(304, 78, 311, 92) solid(chim, "#9a8a92")
  for y = 80, 90, 4 do for x = 304, 311 do put(x, y, "#6f6070") end end
  hut(300, 346, 98, 139, "#5d88aa", "#c0563e", 72, 6)
  -- smoke puffs (soft squarish wisps)
  for i, p in ipairs({ {306, 70, 5}, {311, 62, 6}, {304, 52, 7} }) do
    local m = c:rrect(p[1] - p[3], p[2] - 3, p[1] + p[3], p[2] + 3, 2)
    fillF(m, function(x, y) return y < p[2] - 1 and "#d9c8d4" or "#bba9c2" end)
  end
  -- door + window
  local door = rect(317, 116, 329, 139) c:rim(door, "#3a2418")
  fillF(door, function(x, y) if x == 323 then return "#f7c86a" end return (x - 317) % 4 == 0 and "#5a3624" or "#7a4a30" end)
  put(327, 128, "#f2c45a")
  local win = rect(304, 107, 313, 116) c:rim(win, "#2e3a50")
  fillF(win, function(x, y) if x == 308 or y == 111 then return "#3e3040" end return (x < 308 and y < 111) and "#fff1b8" or "#f9cf6a" end)
  -- drying net on right wall
  for y = 104, 136 do for x = 333, 345 do
    if (x + y) % 5 == 0 or (x - y) % 5 == 0 then put(x, y, "#d9c08a") end
  end end
  for x = 332, 346 do put(x, 103, "#8a6a3e") end
  -- fish weathervane (quirk)
  for y = 60, 72 do put(323, y, "#3e3040") end
  local fish = poly{ {315, 58}, {326, 55}, {331, 58}, {326, 61} }
  c:rim(fish, "#7a3a1e") fillF(fish, function(x, y) return y < 58 and "#f6a24a" or "#e07a34" end)
  local tail = poly{ {311, 54}, {316, 58}, {311, 62} } c:rim(tail, "#7a3a1e") fillF(tail, function() return "#e07a34" end)
  put(328, 57, "#3e3040")
  -- hut 2 (green boards, violet slate roof)
  hut(366, 410, 106, 139, "#6f9a5e", "#6f63a0", 84, 5)
  local d2 = rect(382, 120, 392, 139) c:rim(d2, "#3a2418")
  fillF(d2, function(x, y) return (x - 382) % 3 == 0 and "#6a3f2a" or "#8a5634" end)
  local w2 = rect(396, 114, 404, 122) c:rim(w2, "#2e3a50")
  fillF(w2, function(x, y) if x == 400 then return "#3e3040" end return y < 118 and "#fff1b8" or "#f9cf6a" end)
  local box = rect(394, 124, 406, 127) solid(box, "#a8673e")
  for _, x in ipairs({ 396, 400, 404 }) do put(x, 122, "#e86a8a") put(x, 123, "#5f8a3c") end
  put(371, 112, "#f6c66a") put(372, 112, "#f6c66a")
end
-- hut reflections in the water under the platform
for x = 292, 416 do
  for y = 149, shoreY(x) do
    if water:has(x, y) then
      local src = c:get(x, 2 * 147 - y)
      if src and y % 3 ~= 0 then put(x, y, mix(src, waterAt(y), .55)) end
    end
  end
end
-- stilts
for x = 296, 412, 14 do
  local s = rect(x, 146, x + 2, 160)
  fillF(s, function(px, py) if py > 156 then return "#3a2a26" end return px == x and "#7a5a40" or "#4a3328" end)
  for xx = x - 2, x + 4 do if (xx % 2) == 0 then put(xx, 161, "#d8e6e0") end end
end

-------------------------------------------------------------- ground (sand beach + grass edges)
local ground = HP.mask()
for x = 0, W - 1 do for y = shoreY(x) + 1, H - 1 do ground:set(x, y) end end
fillF(ground, function(x, y)
  local d = y - shoreY(x)
  local col = "#dcbc85"
  if d <= 3 then col = "#b99a70" elseif d <= 5 then col = "#cdae7c" end
  local n = Hs(x, y, 11)
  if n > .93 then col = dk(col, .12) elseif n < .05 then col = lt(col, .25) end
  if (x < 24 or x > 456) and Hs(x // 3, y // 3, 12) > .35 then col = (Hs(x, y, 13) > .5) and "#86a650" or "#6e8e44" end
  return col
end)
-- foam at the waterline
for x = 14, 465 do if Hs(x // 4, 1, 14) > .35 then put(x, shoreY(x), "#eef0dc") end end

-------------------------------------------------------------- boardwalk path + central jetty to the beacon
local function halfW(y) return 75 * (y - VY) / 158 end
local function plankId(y) return floor(3000 / (y - 110)) end
local path = HP.mask()
for y = 118, H - 1 do
  local hw = halfW(y)
  for x = floor(VX - hw + .5), floor(VX + hw - .5) do path:set(x, y) end
end
c:rim(path, "#5a3a26")
fillF(path, function(x, y)
  local id = plankId(y)
  local col = id % 2 == 0 and "#c8925c" or "#bb8552"
  if plankId(y + 1) ~= id then col = "#6e4630" elseif plankId(y - 1) ~= id then col = lt(col, .22) end
  local hw = halfW(y)
  if x < VX - hw + 2 then col = lt(col, .15) elseif x > VX + hw - 3 then col = dk(col, .2) end
  if Hs(x // 4, id, 15) > .86 then col = dk(col, .15) end
  -- nail pairs
  if y > 190 and plankId(y - 1) ~= id and (abs(x - (VX - hw + 4)) < 1 or abs(x - (VX + hw - 5)) < 1) then col = "#5e4a50" end
  return col
end)
-- jetty side face + posts over the water
for y = 118, shoreY(VX) do
  local hw = halfW(y)
  local th = max(1, floor(hw / 7))
  for k = 1, th do
    local xl, xr = floor(VX - hw + .5) - 1, floor(VX + hw - .5) + 1
    if water:has(xl, y + k) then put(xl, y + k, "#4a2f22") end
    if water:has(xr, y + k) then put(xr, y + k, "#4a2f22") end
  end
end
for _, py in ipairs({ 124, 134, 148, 164 }) do
  local hw = halfW(py)
  local len = floor(3 + hw / 3)
  for _, sx in ipairs({ floor(VX - hw), floor(VX + hw) }) do
    for y = py, py + len do put(sx, y, "#3a2a26") if hw > 10 then put(sx + (sx < VX and 1 or -1), y, "#5a4032") end end
    put(sx, py + len + 1, "#d8e6e0")
  end
end
-- jetty lanterns on posts (near the shore)
local function lanternPost(x, ybase, hgt, glass)
  local post = rect(x, ybase - hgt, x + 2, ybase) c:rim(post, "#3a2418")
  fillF(post, function(px) return px == x and "#8a6040" or "#5e3e2a" end)
  local top = ybase - hgt
  local cage = rect(x - 3, top - 9, x + 5, top - 1) c:rim(cage, "#2e2230")
  fillF(cage, function(px, py)
    if px == x - 3 or px == x + 5 or py == top - 9 then return "#3e3040" end
    return (px <= x + 1 and py <= top - 5) and "#fff1b8" or (glass or "#f9c860")
  end)
  local cap = poly{ {x - 5, top - 9}, {x + 7, top - 9}, {x + 1, top - 14} } c:rim(cap, "#2e2230")
  fillF(cap, function(px) return px < x + 1 and "#4e4258" or "#3a3046" end)
  for _, d in ipairs({ {-6, -5}, {8, -5}, {1, 1}, {1, -17} }) do put(x + d[1], top + d[2], "#fde6a0") end
end
lanternPost(206, 170, 20)
lanternPost(272, 170, 20)
-- warm glow ripples under the lanterns
for _, gx in ipairs({ 207, 273 }) do for k = 0, 3 do for x = gx - 3 + k, gx + 3 - k do if (x + k) % 2 == 0 then put(x, 160 + k * 3, "#f6d88a") end end end end

-------------------------------------------------------------- floating quirks: rowboat with flowerpot + bottle with note
do
  local hull = poly{ {164, 150}, {206, 150}, {200, 160}, {170, 160} }
  c:rim(hull, "#5a2418")
  fillF(hull, function(x, y)
    if y <= 151 then return "#f0d8a8" end
    local col = "#d4683c"
    if y >= 157 then col = "#a84a2e" end
    if y == 154 then col = "#f0d8a8" end
    if x > 196 then col = dk(col, .2) end
    return col
  end)
  local inner = rect(170, 148, 200, 150) fillF(inner, function(x) return x % 5 == 0 and "#5a3a26" or "#7a4e32" end)
  -- flowerpot planted in the boat
  local pot = poly{ {181, 140}, {191, 140}, {189, 149}, {183, 149} } c:rim(pot, "#6a2e1e")
  fillF(pot, function(x, y) return x < 186 and "#d9774a" or "#b65a36" end)
  for _, p in ipairs({ {183, 136}, {186, 133}, {189, 135}, {185, 138} }) do
    put(p[1], p[2], "#e8508a") put(p[1] + 1, p[2], "#f27aa2") put(p[1], p[2] + 1, "#c23c70")
  end
  for y = 137, 139 do put(186, y, "#5f8a3c") put(184, y + 1, "#5f8a3c") end
  for x = 166, 204 do if x % 3 ~= 0 then put(x, 162, mix("#a84a2e", "#3a6886", .55)) end end
  -- oar
  for i = 0, 14 do put(198 + i, 147 + floor(i / 2), "#c8a070") end
  -- bottle with note
  local bot = poly{ {282, 164}, {292, 161}, {293, 164}, {283, 167} } c:rim(bot, "#2e5a4a")
  fillF(bot, function(x, y) if x >= 285 and x <= 288 then return "#f0e2c0" end return y < 164 and "#8fd0b0" or "#5aa08a" end)
  put(294, 161, "#9a6a40") put(295, 161, "#9a6a40")
  for x = 280, 297 do if x % 2 == 0 then put(x, 169, "#d8e6e0") end end
end

-------------------------------------------------------------- DO: the fishing jetty (left)
local DO = { 14, 84, 166, 182 }
do
  local deckP = { {38, 178}, {152, 178}, {158, 128}, {102, 128} }
  local deck = poly(deckP)
  -- side faces + posts into the water
  local side = poly{ {38, 178}, {102, 128}, {102, 132}, {38, 183} }
  side:add(rect(38, 179, 152, 182))
  fillF(side, function(x, y) return (x % 7 == 0) and "#3e2a20" or "#5e4232" end)
  for i = 0, 4 do
    local t = i / 4
    local px, py = floor(38 + 64 * t), floor(178 - 50 * t)
    for y = py + 2, py + 12 do put(px, y, "#3a2a26") put(px + 1, y, "#5a4032") end
    put(px, py + 13, "#d8e6e0") put(px + 2, py + 13, "#d8e6e0")
  end
  for x = 108, 156, 12 do for y = 128, 136 do put(x, y, "#3a2a26") end end
  c:rim(deck, "#3e2a20")
  fillF(deck, function(x, y)
    local id = plankId(y + 20)
    local col = id % 2 == 0 and "#a99a86" or "#9d8e7c"
    if plankId(y + 21) ~= id then col = "#5e5048" elseif plankId(y + 19) ~= id then col = lt(col, .2) end
    if x > 150 - (178 - y) * 0 and x > 146 + (178 - y) * .12 then col = dk(col, .2) end
    if Hs(x // 5, id, 16) > .85 then col = dk(col, .14) end
    return col
  end)
  -- rope tie + small rowboat moored at the left
  local hull = poly{ {18, 138}, {64, 138}, {58, 148}, {24, 148} } c:rim(hull, "#20384a")
  fillF(hull, function(x, y)
    if y <= 139 then return "#e8dcc0" end
    local col = y >= 145 and "#2f6f8c" or "#3f8fae"
    if y == 142 then col = "#e8dcc0" end
    if x > 54 then col = dk(col, .2) end
    return col
  end)
  local inn = rect(24, 136, 58, 138) fillF(inn, function(x) return x % 6 == 0 and "#4a3022" or "#6a4430" end)
  for x = 20, 62 do if x % 3 ~= 1 then put(x, 150, mix("#2f6f8c", "#3a6886", .5)) end end
  for i = 0, 10 do put(64 + i * 2, 140 - floor(i * .4), "#c8a070") end
  -- lantern post on far-left corner of the deck
  lanternPost(104, 130, 26)
  -- fishing rods leaning out over the water (+ lines), boot caught on one (quirk)
  local function rod(x0, y0, x1, y1, lx, ly)
    c:fillMask(c:line({ {x0, y0}, {x1, y1} }, 2), "#6a4228")
    c:fillMask(c:line({ {x0, y0}, {(x0 + x1) / 2, (y0 + y1) / 2} }, 1), "#a06a3e")
    for y = y1, ly do put(x1 + floor((y - y1) * (lx - x1) / max(1, ly - y1)), y, "#efe2c4") end
    local reel = rect(x0 - 3, y0 - 4, x0, y0 - 1) fillF(reel, function() return "#c9a24a" end)
  end
  rod(126, 132, 84, 92, 80, 122)
  rod(144, 134, 116, 86, 112, 108)
  -- red-white float on line 1
  put(80, 121, "#d8463c") put(81, 121, "#d8463c") put(80, 122, "#f0e2c4") put(81, 122, "#f0e2c4")
  local boot = poly{ {108, 108}, {114, 108}, {114, 116}, {120, 116}, {120, 120}, {108, 120} }
  c:rim(boot, "#3a2418") fillF(boot, function(x, y) return y >= 119 and "#3e2a20" or (x < 111 and "#8a5a36" or "#6e4428") end)
  for x = 108, 120 do if x % 3 == 0 then put(x, 121, "#5aa0c0") end end
  -- rod holder posts
  for _, p in ipairs({ {126, 132}, {144, 134} }) do for y = p[2], p[2] + 6 do put(p[1], y, "#3e2a20") put(p[1] + 1, y, "#5e4232") end end
  -- bait barrel
  shadow(132, 176, 14, 3, "#6e6258")
  local bar = c:rrect(120, 148, 144, 175, 4)
  solid(bar, "#a0563a", { edge = "#4a2418", tex = function(x, y, col)
    if y == 154 or y == 155 or y == 168 or y == 169 then return x < 126 and "#8a8494" or "#5e5a6a" end
    if (x - 120) % 5 == 0 then return dk(col, .2) end
    return col
  end })
  local lid = poly{ {118, 147}, {140, 141}, {142, 145}, {121, 150} } c:rim(lid, "#4a2418")
  fillF(lid, function(x, y) return y < 145 and "#c98a5a" or "#9a6440" end)
  local fl = rect(130, 137, 133, 140) fillF(fl, function(x, y) return y < 139 and "#d8463c" or "#f0e2c4" end)
  -- tackle crate (green)
  shadow(74, 176, 16, 3, "#6e6258")
  local crate = rect(60, 158, 88, 174)
  solid(crate, "#4f8a5a", { edge = "#1e3a28", tex = function(x, y, col)
    if y == 165 or y == 166 then return dk(col, .3) end
    if x == 60 or x == 88 then return dk(col, .35) end
    return col
  end })
  local hook = rect(70, 162, 77, 169) fillF(hook, function(x, y) return (x == 73 or (y == 169 and x >= 70) or (x == 70 and y >= 167)) and "#e8e0c8" or nil end)
  -- bucket
  local buck = poly{ {94, 162}, {106, 162}, {104, 174}, {96, 174} } c:rim(buck, "#2e3a50")
  solid(buck, "#8a9ab4", { rim = false })
  for x = 94, 106 do put(x, 162, "#5e6a80") end
end

-------------------------------------------------------------- PEOPLE: campfire, bench, table, tripod pot
local PEOPLE = { 24, 190, 152, 254 }
do
  -- warm glow on sand
  fillF(c:ellipse(86, 238, 34, 10), function(x, y) return Hs(x, y, 17) > .5 and "#ead09a" or "#e6c88e" end)
  shadow(48, 230, 22, 4, "#b8986c")
  -- bench log on stumps
  for _, sx in ipairs({ 32, 58 }) do local s = rect(sx, 220, sx + 7, 230) solid(s, "#7a5236", { edge = "#3a2418" }) end
  local log = c:rrect(26, 208, 70, 220, 3)
  solid(log, "#8a5a38", { edge = "#3a2418", tex = function(x, y, col)
    if (y == 211 or y == 216) and Hs(x // 4, y, 18) > .3 then return dk(col, .3) end
    if y == 209 then return lt(col, .3) end
    return col
  end })
  local cut = c:rrect(26, 208, 32, 220, 2) c:rim(cut, "#3a2418")
  fillF(cut, function(x, y) if x == 29 and y >= 212 and y <= 216 then return "#a8744a" end return "#e0b880" end)
  -- fire stones
  for i, p in ipairs({ {66, 238}, {72, 245}, {84, 248}, {98, 246}, {106, 239}, {98, 232}, {74, 231} }) do
    local s = c:rrect(p[1] - 4, p[2] - 3, p[1] + 3, p[2] + 2, 1) c:rim(s, "#3c3450")
    fillF(s, function(x, y) return (y < p[2] - 1 and x < p[1]) and "#b4aac2" or (x > p[1] + 1 and "#6e6684" or "#8f86a2") end)
  end
  -- logs crossed
  c:fillMask(c:line({ {74, 244}, {98, 236} }, 3), "#6a4228")
  c:fillMask(c:line({ {74, 236}, {98, 244} }, 3), "#7e5232")
  -- flame
  local fo = poly{ {76, 240}, {96, 240}, {94, 228}, {90, 232}, {87, 218}, {83, 230}, {79, 224} }
  c:rim(fo, "#a83a1e") fillF(fo, function() return "#e8662c" end)
  local fm = poly{ {80, 240}, {93, 240}, {91, 230}, {87, 223}, {83, 233} } fillF(fm, function() return "#f59a3a" end)
  local fi = poly{ {83, 240}, {90, 240}, {88, 232}, {86, 228} } fillF(fi, function() return "#fbd35a" end)
  for _, p in ipairs({ {84, 212}, {92, 208}, {80, 204} }) do put(p[1], p[2], "#fbd35a") end
  -- tripod + hanging pot
  c:fillMask(c:line({ {66, 246}, {86, 198} }, 2), "#5e3e2a")
  c:fillMask(c:line({ {108, 246}, {86, 198} }, 2), "#4a3022")
  for y = 199, 208 do put(86, y, "#3e3040") end
  local pot = c:rrect(79, 208, 94, 218, 3)
  solid(pot, "#4e5a72", { edge = "#1e2434" })
  for x = 79, 94 do put(x, 208, "#7a86a0") end
  for _, p in ipairs({ {84, 205}, {89, 202} }) do put(p[1], p[2], "#e6dcea") put(p[1] + 1, p[2] - 1, "#d0c4dc") end
  -- table with kettle and mugs
  shadow(127, 234, 24, 4, "#b8986c")
  for _, lx in ipairs({ 108, 142 }) do local l = rect(lx, 210, lx + 3, 232) solid(l, "#7a4e32", { edge = "#3a2418" }) end
  local top = poly{ {102, 204}, {150, 204}, {152, 211}, {104, 211} }
  solid(top, "#b47a4a", { edge = "#4a2a18", tex = function(x, y, col) if y == 207 then return dk(col, .25) end return col end })
  local kettle = c:rrect(110, 192, 124, 203, 3) solid(kettle, "#3f9a94", { edge = "#18403e" })
  c:fillMask(c:line({ {124, 196}, {129, 193} }, 1), "#18403e")
  for x = 113, 121 do put(x, 190, "#18403e") end put(112, 191, "#18403e") put(122, 191, "#18403e")
  for i, mx in ipairs({ 132, 141 }) do
    local m = rect(mx, 196, mx + 5, 203) solid(m, i == 1 and "#e2a23c" or "#d8607a", { edge = "#4a2418" })
    put(mx + 6, 199, "#4a2418") put(mx + 6, 200, "#4a2418")
  end
end

-------------------------------------------------------------- STOP: notice board + stamp box
local STOP = { 334, 168, 406, 228 }
do
  shadow(370, 226, 30, 3, "#b8986c")
  for _, px in ipairs({ 344, 386 }) do local p = rect(px, 182, px + 3, 226) solid(p, "#6a4228", { edge = "#2e1a10" }) end
  local board = rect(340, 180, 392, 206)
  solid(board, "#5e3a24", { edge = "#2e1a10" })
  local cork = rect(343, 183, 389, 203)
  fillF(cork, function(x, y) local col = "#c08a52" if Hs(x, y, 19) > .8 then col = "#a87444" end return col end)
  -- pinned papers (no text, just marks)
  local function note(x0, y0, x1, y1, col, pin)
    local m = rect(x0, y0, x1, y1) c:rim(m, dk(col, .55))
    fillF(m, function(x, y)
      if y > y0 + 2 and (y - y0) % 3 == 0 and x > x0 + 1 and x < x1 - 1 and Hs(x // 3, y, 20) > .25 then return dk(col, .4) end
      return x > x1 - 2 and dk(col, .12) or col
    end)
    put(floor((x0 + x1) / 2), y0, pin)
  end
  note(346, 185, 358, 199, "#f2e6c8", "#d8463c")
  note(362, 184, 372, 194, "#f2a8b8", "#3f8fae")
  -- map note with dotted trail
  local map = rect(375, 185, 387, 200) c:rim(map, "#3a5a6a")
  fillF(map, function(x, y) return (x + y) % 7 == 0 and "#8fc0d0" or "#b6dce4" end)
  for i = 0, 5 do put(377 + i * 2, 198 - i * 2, "#c84a3c") end
  put(386, 186, "#c84a3c") put(385, 187, "#c84a3c")
  -- big red stamp mark on the cream note
  local st = rect(349, 191, 355, 197) fillF(st, function(x, y) return ((x + y) % 2 == 0 or x == 349 or x == 355 or y == 191 or y == 197) and "#c83a40" or nil end)
  note(361, 197, 372, 203, "#e8d07a", "#4f8a5a")
  -- little roof
  local roof = poly{ {335, 181}, {397, 181}, {388, 171}, {344, 171} }
  c:rim(roof, "#1e4a48")
  fillF(roof, function(x, y)
    local col = "#3f8f88"
    if (y - 171) % 3 == 2 then col = "#2e6e6a" end
    if x < 352 then col = lt(col, .15) elseif x > 382 then col = dk(col, .18) end
    return col
  end)
  -- stamp box on the right post (brass, with red seal)
  local sb = rect(392, 208, 404, 220)
  solid(sb, "#c9a24a", { edge = "#5a4418" })
  local seal = poly{ {398, 210}, {402, 214}, {398, 218}, {394, 214} } fillF(seal, function(x, y) return x < 398 and "#e05a4a" or "#b83a36" end)
  for x = 392, 404 do put(x, 208, "#e8c86a") end
  -- hanging stamp on a string
  for y = 207, 212 do put(338, y, "#e8dcc0") end
  local stp = rect(335, 213, 341, 220) solid(stp, "#8a4a9a", { edge = "#3a1a40" })
  for x = 335, 341 do put(x, 221, "#c83a40") end
end

-------------------------------------------------------------- WILD: driftwood arch + signpost leaving right
local WILD = { 418, 148, 466, 228 }
do
  -- trail of darker sand to the right edge
  fillF(poly{ {424, 228}, {466, 214}, {466, 226}, {440, 232} }, function(x, y) return Hs(x, y, 21) > .7 and "#c4a26e" or "#cfae7a" end)
  -- reed / grass clumps
  local function reeds(x0, n, ybase, hgt)
    for i = 0, n - 1 do
      local x = x0 + i * 2
      local h2 = hgt - floor(Hs(i, x, 22) * 8)
      for y = ybase - h2, ybase do put(x, y, (i % 2 == 0) and "#6e8e44" or "#86a650") end
      if i % 3 == 0 then for y = ybase - h2 - 4, ybase - h2 do put(x, y, "#8a5a36") end end
    end
  end
  reeds(420, 5, 226, 20)
  reeds(452, 6, 222, 22)
  -- arch posts
  local lp = poly{ {420, 226}, {427, 226}, {428, 168}, {422, 166} }
  local rp = poly{ {455, 224}, {462, 224}, {461, 162}, {455, 162} }
  local beam = c:line({ {423, 168}, {430, 158}, {440, 153}, {450, 154}, {458, 162} }, 5)
  local arch = HP.mask():add(lp):add(rp):add(beam)
  c:rim(arch, "#3e3430")
  fillF(arch, function(x, y)
    local col = "#a8988a"
    if Hs(x // 2, y // 5, 23) > .7 then col = "#8a7a6e" end
    if (x == 421 or x == 456) or y <= 154 then col = lt(col, .2) end
    if x == 426 or x == 461 then col = dk(col, .25) end
    return col
  end)
  -- vine leaves on the arch
  for _, p in ipairs({ {426, 160}, {433, 155}, {446, 152}, {455, 157}, {424, 180}, {460, 176}, {459, 194} }) do
    put(p[1], p[2], "#5f8a3c") put(p[1] + 1, p[2], "#86b050") put(p[1], p[2] + 1, "#4a6e30") put(p[1] - 1, p[2] + 1, "#86b050")
  end
  put(440, 151, "#e8508a") put(441, 151, "#f27aa2") put(451, 153, "#f6c66a")
  -- signpost with arrow pointing out right, leaf icon
  local post = rect(436, 192, 438, 226) solid(post, "#6a4228", { edge = "#2e1a10" })
  local arrow = poly{ {428, 188}, {452, 188}, {460, 195}, {452, 202}, {428, 202} }
  c:rim(arrow, "#1e3a20")
  fillF(arrow, function(x, y) local col = "#5a9a4e" if y <= 189 then col = lt(col, .25) elseif y >= 200 or x > 452 then col = dk(col, .2) end return col end)
  local leaf = poly{ {436, 195}, {442, 191}, {448, 195}, {442, 199} } fillF(leaf, function(x, y) return y <= 195 and "#e2f0b0" or "#c4dc90" end)
  for x = 437, 447 do put(x, 195, "#3e7a3a") end
end

-------------------------------------------------------------- a few tufts + pebbles on the beach (away from stand points)
local STAND = { {200, 244}, {292, 240}, {245, 200}, {182, 208}, {305, 196}, {330, 262} }
local function clearOfStands(x, y) for _, s in ipairs(STAND) do if (x - s[1])^2 + (y - s[2])^2 < 34^2 then return false end end return true end
for i = 0, 40 do
  local x, y = 20 + floor(Hs(i, 1, 24) * 440), 182 + floor(Hs(i, 2, 24) * 84)
  local boxes = { DO, PEOPLE, STOP, WILD }
  local ok = clearOfStands(x, y) and not path:has(x, y) and not (x >= 380 and y >= 230)
  for _, b in ipairs(boxes) do if x >= b[1] - 2 and x <= b[3] + 2 and y >= b[2] - 2 and y <= b[4] + 2 then ok = false end end
  if ok then
    if i % 3 == 0 then put(x, y, "#a89aa8") put(x + 1, y, "#8a7c94") put(x, y - 1, "#c4b8c4")
    else for k = 0, 2 do put(x + k * 2 - 2, y - 2 - (k % 2), "#6e8e44") put(x + k * 2 - 2, y - 1, "#86a650") put(x + k * 2 - 2, y, "#5f7e3c") end end
  end
end

-------------------------------------------------------------- GATE FRAME: driftwood posts, beam, net, lanterns, charm
do
  local function wood(m, base)
    local x0, y0, x1, y1 = m:bbox()
    c:rim(m, "#2e2420")
    fillF(m, function(x, y)
      local col = base
      local vertical = (x1 - x0) < (y1 - y0)
      local u = vertical and (x - x0) or (y - y0)
      local span = vertical and (x1 - x0) or (y1 - y0)
      if u <= 1 then col = lt(base, .22) elseif u >= span - 2 then col = dk(base, .3) end
      if vertical and Hs(x, y // 7, 25) > .82 then col = dk(col, .18) end
      if not vertical and Hs(x // 7, y, 26) > .82 then col = dk(col, .18) end
      return col
    end)
  end
  local lp, rp = rect(0, 0, 13, 269), rect(466, 0, 479, 269)
  wood(lp, "#8e7a66") wood(rp, "#8e7a66")
  -- rope wraps
  for _, yy in ipairs({ 60, 150 }) do
    for _, x0 in ipairs({ 0, 466 }) do
      local r = rect(x0, yy, x0 + 13, yy + 9)
      fillF(r, function(x, y) return ((x + y) % 4 < 2) and "#d8bf8a" or "#a88a5a" end)
      for x = x0, x0 + 13 do put(x, yy - 1, "#5a4428") put(x, yy + 10, "#5a4428") end
    end
  end
  local beam = rect(0, 0, 479, 12)
  wood(beam, "#7e6a58")
  for x = 20, 460, 46 do put(x, 6, "#3e3030") put(x + 1, 6, "#5e4a40") end
  -- drying net draped from the beam in scallops (left and right of centre)
  local function net(x0, x1)
    for x = x0, x1 do
      local depth = 13 + floor(9 * abs(sin((x - x0) / (x1 - x0) * math.pi * 2)))
      for y = 13, depth do if (x + y) % 5 == 0 or (x - y) % 5 == 0 then put(x, y, "#d9c08a") end end
      put(x, depth + 1, "#a88a5a")
    end
    for _, fx in ipairs({ x0 + (x1 - x0) // 4, x0 + 3 * (x1 - x0) // 4 }) do
      local f = rect(fx - 2, 22, fx + 2, 26) c:rim(f, "#5a2418") fillF(f, function(x, y) return y < 24 and "#e8a04a" or "#c87a36" end)
    end
  end
  net(18, 150)
  net(330, 462)
  -- hanging lantern (left)
  for y = 13, 26 do put(40, y, "#3e3040") end
  local cap = poly{ {33, 27}, {47, 27}, {40, 22} } c:rim(cap, "#2e2230") fillF(cap, function(x) return x < 40 and "#4e4258" or "#3a3046" end)
  local body = rect(34, 28, 46, 42) c:rim(body, "#2e2230")
  fillF(body, function(x, y)
    if x == 34 or x == 46 or y == 28 or y == 42 or x == 40 then return "#3e3040" end
    return (x < 40 and y < 35) and "#fff1b8" or "#f9c860"
  end)
  for _, p in ipairs({ {30, 35}, {50, 35}, {40, 46} }) do put(p[1], p[2], "#fde6a0") end
  -- teapot lantern (right, quirk)
  for y = 13, 26 do put(440, y, "#3e3040") end
  local pot = c:rrect(432, 28, 448, 40, 4) c:rim(pot, "#18403e")
  fillF(pot, function(x, y)
    if y >= 31 and y <= 36 and x >= 436 and x <= 444 then return (x < 440) and "#fff1b8" or "#f9c860" end
    return x < 438 and "#5ab0a8" or "#3f8a84"
  end)
  local lid = rect(437, 25, 443, 27) c:rim(lid, "#18403e") fillF(lid, function() return "#5ab0a8" end)
  c:fillMask(c:line({ {449, 32}, {454, 28}, {455, 26} }, 2), "#3f8a84")
  c:fillMask(c:line({ {431, 31}, {428, 34}, {431, 37} }, 1), "#18403e")
  for _, p in ipairs({ {426, 34}, {458, 36}, {440, 44} }) do put(p[1], p[2], "#fde6a0") end
  -- charm: cork float + shell hanging near centre-left
  for y = 13, 30 do put(170, y, "#e8dcc0") end
  local fl = c:rrect(166, 31, 174, 41, 2) c:rim(fl, "#5a2418")
  fillF(fl, function(x, y) if y >= 35 and y <= 36 then return "#f0e2c4" end return x < 170 and "#e05a4a" or "#b83a36" end)
  local shell = poly{ {166, 44}, {174, 44}, {170, 50} } c:rim(shell, "#8a5a4a")
  fillF(shell, function(x, y) return (x % 2 == 0) and "#f2c0a8" or "#e8a08a" end)
  for y = 41, 43 do put(170, y, "#e8dcc0") end
end

-------------------------------------------------------------- v2.5.40 polish: net, buoys, plank stack, driftwood, shells, layered fire
do
  -- fishing net heaped over the jetty's left end: diamond mesh in two tones
  local net = c:rrect(40, 156, 60, 168, 4)
  c:rim(net, dk("#c8b48a", .6))
  fillF(net, function(x, y)
    if (x + y) % 4 == 0 or (x - y) % 4 == 0 then return "#e8d6a8" end
    return (x + y) % 2 == 0 and "#b89c6e" or "#8a7250"
  end)
  put(44, 156, "#e8d6a8"); put(56, 160, "#e8d6a8")
  -- two buoys (red, striped) on a rope along the jetty edge
  for _, b in ipairs({ { 104, 170, "#e8493b" }, { 112, 172, "#f5b82e" } }) do
    local m = c:ellipse(b[1], b[2], 4, 4)
    solid(m, b[3], { edge = dk(b[3], .65) })
    for x = b[1] - 4, b[1] + 4 do put(x, b[2], "#f6f0e4") end
    put(b[1] - 2, b[2] - 2, "#fff6e0")
  end
  c:fillMask(c:line({ { 100, 168 }, { 108, 175 }, { 116, 173 } }, 1), "#a8804a")
  -- a short stack of planks leaning at the jetty head
  for i, col in ipairs({ "#9a6a44", "#b88054", "#8a5a38" }) do
    local m = rect(112, 150 - i * 3, 130, 152 - i * 3)
    solid(m, col, { edge = "#3a2418" })
  end
  put(114, 148, "#e0b880"); put(122, 145, "#e0b880")
  -- fish crate with a silver catch, beside the barrel
  local cr = rect(146, 168, 162, 180)
  solid(cr, "#a07044", { edge = "#3a2418", tex = function(x, y, col) if (y - 168) % 4 == 0 then return "#6e4a30" end return col end })
  for x = 148, 160, 3 do put(x, 167, "#c8d6e0"); put(x + 1, 166, "#8aa0b8"); put(x + 2, 167, "#e8f0f6") end
  -- driftwood, shells and a starfish on the sand (outside every spot box and clear of the stand points)
  fillF(c:line({ { 168, 192 }, { 178, 189 }, { 188, 191 } }, 2), function(x, y) return Hs(x, y, 5) > .7 and "#c8b8a8" or "#a89684" end)
  put(170, 190, "#e8dccc"); put(178, 187, "#e8dccc")
  for _, sh in ipairs({ { 160, 196, "#f6c8b8" }, { 164, 200, "#f2e0c8" }, { 352, 240, "#f6c8b8" }, { 360, 236, "#f2e0c8" } }) do
    put(sh[1], sh[2], sh[3]); put(sh[1] + 1, sh[2], sh[3]); put(sh[1], sh[2] + 1, dk(sh[3], .3)); put(sh[1] + 1, sh[2] + 1, dk(sh[3], .45))
  end
  for _, st in ipairs({ { 340, 244 } }) do
    for _, d in ipairs({ { 0, -2 }, { -2, 0 }, { 2, 0 }, { 0, 2 }, { 0, 0 } }) do put(st[1] + d[1], st[2] + d[2], "#e8704a") end
    put(st[1], st[2], "#f5a070")
  end
  -- beach grass clumps (spiky, 3 tones) at the water line and by the arch
  for _, g in ipairs({ { 168, 184 }, { 396, 232 }, { 462, 232 }, { 318, 232 } }) do
    for k = -3, 3 do
      local hgt = 4 + (k % 2 == 0 and 2 or 0) - abs(k) // 2
      for y = 0, hgt do put(g[1] + k, g[2] - y, y > hgt - 2 and "#c4d870" or (y > 1 and "#86a650" or "#5f7e3c")) end
    end
  end
  -- fire: layered flame tongues over the old flame, with sparks
  local function tongue(cx, by, h, w, lean)
    local m = HP.mask()
    for y = by, by - h, -1 do
      local t = (by - y) / h
      local hw = w * sin(math.pi * min(1, t * 0.92 + 0.08) ^ 0.75) * (1 - t * 0.35)
      local off = lean * t * t
      for x = floor(cx + off - hw + 0.5), floor(cx + off + hw + 0.5) do m:set(x, y) end
    end
    return m
  end
  local function flame(cx, by, h, w, lean)
    local m = tongue(cx, by, h, w, lean)
    c:rim(m, "#a83a1e")
    fillF(m, function() return "#e8662c" end)
    for i, col in ipairs({ "#f2802e", "#f59a3a", "#fbd35a", "#fff2c0" }) do
      local mm = m:shrink(i * 2)
      if mm:count() > 0 then fillF(mm, function() return col end) end
    end
  end
  flame(86, 240, 24, 8, 0); flame(79, 240, 14, 5, -3); flame(94, 240, 16, 5, 3)
  for _, p in ipairs({ { 78, 208 }, { 96, 206 }, { 74, 198 }, { 100, 200 }, { 86, 190 } }) do put(p[1], p[2], "#fbd35a"); put(p[1] + 1, p[2], "#f59a3a") end
end

-------------------------------------------------------------- finish, check, save, layout
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local function spot(k, name, b) return string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', k, name, (b[1] + b[3]) // 2, (b[2] + b[4]) // 2, b[1], b[2], b[3], b[4]) end
local spots = {
  spot("do", "Fishing Jetty", DO),
  spot("people", "Campfire Circle", PEOPLE),
  spot("stop", "Jetty Notice Post", STOP),
  spot("homes", "Stilt Huts", HOMES),
  spot("wild", "Reed Trail", WILD),
}
local st = {}
for _, s in ipairs(STAND) do st[#st + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local json = string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}',
  VY, table.concat(spots, ","), table.concat(st, ","))
local f = io.open(OUT .. NAME .. ".layout.json", "w") f:write(json) f:close()
print("ok " .. NAME)

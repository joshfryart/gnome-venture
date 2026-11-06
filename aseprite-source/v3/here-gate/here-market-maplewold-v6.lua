-- Maplewold Market v6 (v5 + Beaver Pond front on the knoll behind the Herbalist) : gate view, hero-scale toy diorama, 480x270 native.
-- Run: AppRun -b --script-param out=<dir>/ --script here-market-maplewold-v6.lua
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/here-gate/")
local NAME = "here-market-maplewold-v6"
local W, H = 480, 270
local VX, VY = 240, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, max, min, abs, sin, cos, sqrt, PI = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi

---------------------------------------------------------------- utils
local function hash(x, y, s)
  x, y, s = floor(x), floor(y), floor(s or 0)
  local n = (x * 374761393 + y * 668265263 + s * 1013904223) & 0xffffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0xffffffff
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65535
end
local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function hx(r, g, b)
  local function q(v) return floor(max(6, min(250, v)) + .5) end
  return string.format("#%02x%02x%02x", q(r), q(g), q(b))
end
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  return hx(r1 + (r2-r1)*t, g1 + (g2-g1)*t, b1 + (b2-b1)*t)
end
local function tint(x, y, col, t) local cur = c:get(x, y) if cur then c:put(x, y, mix(cur, col, t)) end end
local SHADE, WARM = "#2c2052", "#ffd27a"
local function shadeMask(m, t, col) m:each(function(x, y) tint(x, y, col or SHADE, t) end) end
local function glow(cx, cy, r, col, amt)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = sqrt((x-cx)^2 + ((y-cy)*1.15)^2) / r
    if d < 1 then tint(x, y, col, amt * floor((1-d)*3 + .999) / 3) end
  end end
end
local function tex(m, f) m:each(function(x, y) local col = f(x, y) if col then c:put(x, y, col) end end) end
local function R(r, i) return r[max(1, min(6, floor(i)))] end
local function P(t) local o = {} for i, p in ipairs(t) do o[i] = { floor(p[1] + .5), floor(p[2] + .5) } end return o end
local function poly(t) return c:poly(P(t)) end
local function rect(x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
local function fill(m, col) c:fillMask(m, col) return m end
local function lerpVP(x, y, s) return x + (VX - x) * s, y + (VY - y) * s end

---------------------------------------------------------------- ramps (dark -> light)
local TIMB   = {"#2a1a22","#46282a","#643a30","#845236","#a46e44","#c48e5a"}
local OAK    = {"#30202a","#4e3230","#70483a","#946244","#b88058","#d8a474"}
local CREAM  = {"#5e4658","#8e7476","#bca290","#dcc4a6","#eed9b8","#f8eacc"}
local ROSE   = {"#4e2840","#7c4458","#aa6670","#cc8a88","#e6ae9e","#f6d0bc"}
local MUST   = {"#4a3020","#7a5228","#a87a32","#cc9e40","#e4bc5a","#f4d88a"}
local GREEN  = {"#1c3434","#2a5240","#3a704a","#529054","#78b064","#a8d080"}
local SBLUE  = {"#20264a","#323e6a","#46598a","#6076a4","#7e94bc","#a8b8d4"}
local BARN   = {"#38181e","#5c2428","#843230","#a6483a","#c66648","#e08c62"}
local SLATE  = {"#1e2240","#30385a","#464f76","#606c92","#8090ae","#a8b4cc"}
local REDR   = {"#3e1424","#6a2230","#983234","#c04a3c","#de6e4c","#f49a68"}
local TEAL   = {"#14303a","#1e4a52","#2c686a","#408a84","#64aa9a","#94c8b2"}
local BROWNR = {"#2e1a1e","#4c2a26","#6e3e2c","#905634","#b07444","#cc9a62"}
local COPPER = {"#1c3a3a","#2a5650","#3c7664","#56967a","#7cb690","#a8d4ac"}
local STONE  = {"#382e40","#5a4e5c","#7a6e76","#9a8e90","#b8aca6","#d6cabc"}
local WSTONE = {"#3c3038","#5e4c50","#806a66","#a08a7e","#bea896","#dac6ae"}
local SYRUP  = {"#4e220e","#803e14","#b0621c","#d68a2a","#eeb04a","#fcd88a"}
local MAPLE  = {"#521a26","#8a2a2a","#b8402c","#dc6a2c","#f09a38","#ffc860"}
local ORANGE = {"#5a2416","#8a3a1a","#c45a1e","#e47e2a","#f4a040","#fcc86a"}
local GOLDL  = {"#5a3a14","#8a5a1a","#bc8420","#e0aa2c","#f4cc4a","#fce67c"}
local LEAFG  = {"#26341c","#3a5222","#557228","#7a922e","#a4b444","#d0cc6a"}
local GRASS  = {"#4a3428","#6a502e","#8a6a34","#a8863c","#c2a04a","#d8b862"}
local COB    = {"#4a3a4a","#6c5c68","#8c7e86","#ac9e9c","#c6b8ae","#ded2c2"}
local COBW   = {"#4c3836","#74564e","#967668","#b6967e","#d0b494","#e6ceae"}
local IRON   = {"#24202e","#3a3446","#545066","#727088","#9696a8","#bcbccc"}
local PUMP   = ORANGE

---------------------------------------------------------------- texture painters
local function planks(m, r, o)
  o = o or {}
  local w, base, s, ox = o.w or 6, o.base or 4, o.seed or 1, o.ox or 0
  local vert = o.vert ~= false
  tex(m, function(x, y)
    local a, b = vert and x or y, vert and y or x
    local k = floor((a - ox) / w) local p = (a - ox) - k * w
    local i = base + ((hash(k, 0, s) < .33) and -1 or 0) + ((hash(k, 5, s) > .85) and 1 or 0)
    if p == 0 then i = base - 2 elseif p == 1 then i = i + 1 end
    if p > 1 and hash(a, floor(b / (3 + floor(hash(k, 1, s) * 4))), s + 7) < .13 then i = i - 1 end
    if p > 0 and ((b + floor(hash(k, 2, s) * 40)) % 29) == 0 then i = base - 2 end
    return R(r, i)
  end)
end
local function plaster(m, r, o)
  o = o or {}
  local base, s = o.base or 4, o.seed or 3
  tex(m, function(x, y)
    local i, h = base, hash(x, y, s)
    if h < .07 then i = base - 1 elseif h > .95 then i = base + 1 end
    if hash(floor(x / 5), floor(y / 4), s + 1) < .1 and h < .5 then i = i - 1 end
    return R(r, i)
  end)
end
local function shingles(m, r, o)
  o = o or {}
  local rh, w, base, s, oy = o.rh or 4, o.w or 5, o.base or 4, o.seed or 5, o.oy or 0
  tex(m, function(x, y)
    local row = floor((y - oy) / rh) local py = (y - oy) - row * rh
    local off = (row % 2) * floor(w / 2) local px = (x + off) % w
    local i = base + (hash(floor((x + off) / w), row, s) < .3 and -1 or 0)
    if py == rh - 1 then i = base - 2 elseif py == 0 then i = i + 1 end
    if px == 0 and py < rh - 1 then i = i - 1 end
    return R(r, i)
  end)
end
local function stones(m, r, o)
  o = o or {}
  local bh, bw, base, s, oy, ox = o.bh or 5, o.bw or 8, o.base or 4, o.seed or 9, o.oy or 0, o.ox or 0
  tex(m, function(x, y)
    local row = floor((y - oy) / bh) local py = (y - oy) - row * bh
    local off = (row % 2) * floor(bw / 2) local col = floor((x - ox + off) / bw) local px = (x - ox + off) - col * bw
    if py == bh - 1 or px == bw - 1 then return R(r, base - 2) end
    local i = base + (hash(col, row, s) < .35 and -1 or 0) + (hash(col, row, s + 1) > .8 and 1 or 0)
    if py == 0 and px < bw - 2 then i = i + 1 end
    return R(r, i)
  end)
end
local function beam(x0, y0, x1, y1, r)
  r = r or TIMB
  local m = rect(x0, y0, x1, y1)
  planks(m, r, { vert = (y1 - y0) > (x1 - x0), w = 40, base = 3, seed = x0 + y0 })
  if (y1 - y0) <= (x1 - x0) then for x = x0, x1 do c:put(x, y0, R(r, 5)) c:put(x, y1, R(r, 1)) end
  else for y = y0, y1 do c:put(x0, y, R(r, 5)) c:put(x1, y, R(r, 1)) end end
  return m
end
local function dbeam(x0, y0, x1, y1, r)
  r = r or TIMB
  local m = c:line(P{{x0, y0}, {x1, y1}}, 3) fill(m, R(r, 3))
  m:each(function(x, y) if not m:has(x, y - 1) then c:put(x, y, R(r, 4)) elseif not m:has(x, y + 1) then c:put(x, y, R(r, 1)) end end)
  return m
end

---------------------------------------------------------------- small props
local function window(x0, y0, x1, y1, o)
  o = o or {}
  local fr = o.frame or TIMB[2]
  fill(rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1), fr)
  if o.shut then
    local sw = o.sw or 4
    planks(rect(x0 - 2 - sw, y0 - 1, x0 - 2, y1 + 1), o.shut, { w = 2, base = 4, ox = x0 })
    planks(rect(x1 + 2, y0 - 1, x1 + 2 + sw, y1 + 1), o.shut, { w = 2, base = 3, ox = x1 })
    c:edgeIn(rect(x0 - 2 - sw, y0 - 1, x0 - 2, y1 + 1), o.shut[1]) c:edgeIn(rect(x1 + 2, y0 - 1, x1 + 2 + sw, y1 + 1), o.shut[1])
  end
  for y = y0, y1 do for x = x0, x1 do
    local t = (y - y0) / max(1, y1 - y0)
    local col = t < .34 and "#ffeaa6" or (t < .7 and "#ffcc6a" or "#ec9e46")
    if o.dark then col = t < .5 and "#5e6c9c" or "#404c7c" end
    c:put(x, y, col)
  end end
  local mx, my = floor((x0 + x1) / 2), floor((y0 + y1) / 2)
  if x1 - x0 >= 6 then for y = y0, y1 do c:put(mx, y, fr) end end
  if y1 - y0 >= 6 then for x = x0, x1 do c:put(x, my, fr) end end
  c:put(x0 + 1, y0 + 1, "#fff6dc") c:put(x0 + 2, y0 + 1, "#fff6dc")
  if o.sill ~= false then
    fill(rect(x0 - 2, y1 + 2, x1 + 2, y1 + 2), o.sillc or TIMB[5])
    fill(rect(x0 - 2, y1 + 3, x1 + 2, y1 + 3), TIMB[2])
  end
end
local function door(x0, y0, x1, y1, r, o)
  o = o or {}
  fill(rect(x0 - 1, y0 - 1, x1 + 1, y1), TIMB[1])
  planks(rect(x0, y0, x1, y1), r, { w = 3, base = 4, ox = x0, seed = x0 })
  if o.zbrace then dbeam(x0 + 1, y1 - 2, x1 - 1, y0 + 2, TIMB) end
  c:put(x1 - 2, floor((y0 + y1) / 2) + 1, "#f0c040") c:put(x1 - 2, floor((y0 + y1) / 2), "#fce67c")
end
local function puff(cx, cy, rx, ry)
  local m = c:ellipse(floor(cx), floor(cy), rx, ry)
  m:add(c:ellipse(floor(cx - rx * .6), floor(cy + ry * .3), floor(rx * .6), floor(ry * .6)))
  m:add(c:ellipse(floor(cx + rx * .6), floor(cy + ry * .35), floor(rx * .55), floor(ry * .55)))
  tex(m, function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    if u + v < -.6 then return "#fdf4f0" elseif u + v > .7 then return "#c8b4cc" end
    return "#ecdde4"
  end)
  m:edge():each(function(x, y) if not m:has(x, y + 1) or not m:has(x + 1, y) then c:put(x, y, "#a090b0") end end)
  return m
end
local function wisp(x, y, len, seed)
  for i = 0, len do
    local xx = x + floor(2.2 * sin(i * .55 + seed))
    c:put(xx, y - i, (i % 5 == 0) and "#fdf4f0" or "#e8dce6")
    if i % 3 == 0 then c:put(xx + 1, y - i, "#d0c2d8") end
  end
end
local function barrel(x0, y0, x1, y1, r, o)
  o = o or {}
  local cx, hw = (x0 + x1) / 2, (x1 - x0 + 1) / 2
  local m = HP.mask()
  for y = y0, y1 do
    local t = (y - y0) / (y1 - y0) local w = hw * (.84 + .16 * sin(PI * t))
    for x = floor(cx - w + .5), floor(cx + w - .5) do m:set(x, y) end
  end
  tex(m, function(x, y)
    local u = (x - (cx - hw)) / (2 * hw) local t = (y - y0) / (y1 - y0)
    if abs(t - .2) < .055 or abs(t - .8) < .055 then return u < .35 and IRON[5] or (u < .7 and IRON[4] or IRON[2]) end
    local i = u < .28 and 5 or (u < .62 and 4 or 3) if u > .86 then i = 2 end
    if floor(x - x0) % 4 == 0 then i = i - 1 end
    return R(r, i)
  end)
  local top = rect(floor(cx - hw * .84) + 1, y0, floor(cx + hw * .84) - 1, y0 + 1)
  fill(top, R(r, 5)) for x = floor(cx - hw * .84) + 1, floor(cx + hw * .84) - 1 do c:put(x, y0 + 1, R(r, 3)) end
  if o.syrup then fill(rect(floor(cx - hw * .5), y0, floor(cx + hw * .5), y0), SYRUP[4]) end
  c:edgeIn(m, R(r, 1))
  c:put(floor(cx - hw * .5), floor(y0 + (y1 - y0) * .35), "#fde8b0")
  return m
end
local LEAF = { "...X...", ".X.X.X.", ".XXXXX.", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }
local LEAF2 = { ".....X.....", "..X..X..X..", "..XX.X.XX..", ".XXXXXXXXX.", "X.XXXXXXX.X", "XXXXXXXXXXX",
  ".XXXXXXXXX.", "..XXXXXXX..", "....XXX....", ".....X.....", ".....X....." }
local function leafMask(pat, x, y, flip)
  local m = HP.mask()
  for j, row in ipairs(pat) do for i = 1, #row do
    if row:sub(i, i) == "X" then m:set(x + i - 1, flip and (y + #pat - j) or (y + j - 1)) end
  end end
  return m
end
local function leaf(pat, x, y, r, o)
  o = o or {}
  local m = leafMask(pat, x, y, o.flip)
  if o.rim ~= false then fill(m:grow(1):cut(m), R(r, 1)) end
  local n = #pat
  tex(m, function(px, py)
    local u, v = px - x, py - y
    local s = u + v
    local i = s < n * .7 and 5 or (s > n * 1.25 and 3 or 4)
    if u == floor(n / 2) and v > 1 then i = 3 end
    return R(r, i)
  end)
  c:put(x + floor(n / 2) - 1, y + floor(n / 2) - 1, R(r, 6))
  return m
end
local function pumpkin(x0, y0, x1, y1, o)
  o = o or {}
  local m = c:rrect(x0, y0, x1, y1, max(2, floor((y1 - y0) / 3)))
  local w = x1 - x0
  tex(m, function(x, y)
    local u, v = (x - x0) / w, (y - y0) / (y1 - y0)
    local i = (u < .3 and v < .5) and 5 or ((u > .7 or v > .75) and 3 or 4)
    local rib = floor((x - x0) * 4 / w + .5)
    if abs((x - x0) - rib * w / 4) < .5 and rib > 0 and rib < 4 and v > .1 then i = i - 1 end
    return R(PUMP, i)
  end)
  c:edgeIn(m, PUMP[1])
  c:put(x0 + 2, y0 + 2, PUMP[6])
  local sx = floor((x0 + x1) / 2)
  fill(rect(sx, y0 - 3, sx + 1, y0), LEAFG[2]) c:put(sx, y0 - 3, LEAFG[4])
  if o.hat then -- tiny top hat, the quirk
    local hx0 = sx - 4
    fill(rect(hx0, y0 - 2, hx0 + 9, y0 - 1), IRON[1])
    fill(rect(hx0 + 2, y0 - 10, hx0 + 7, y0 - 3), IRON[2])
    for y = y0 - 10, y0 - 3 do c:put(hx0 + 2, y, IRON[4]) c:put(hx0 + 7, y, IRON[1]) end
    fill(rect(hx0 + 2, y0 - 5, hx0 + 7, y0 - 4), REDR[4])
    fill(rect(hx0 + 2, y0 - 10, hx0 + 7, y0 - 10), IRON[1])
    c:put(hx0 + 3, y0 - 9, IRON[5])
  end
  return m
end
local function castShadow(x0, x1, b, dx, dy, amt)
  local m = poly{ {x0 + 2, b}, {x1 + 2, b}, {x1 + 2 + dx, b + dy}, {x0 + 2 + dx, b + dy} }
  shadeMask(m, amt or .38)
end

---------------------------------------------------------------- layout (spots + stands)
local SPOTS = {
  { k = "sugar_shack",   name = "Sugar Shack",   box = { 20, 160, 126, 258 } },
  { k = "pie_bakery",    name = "Pie Bakery",    box = { 20, 54, 112, 146 } },
  { k = "tavern",        name = "Tavern",        box = { 370, 44, 460, 136 } },
  { k = "town_hall",     name = "Town Hall",     box = { 192, 14, 288, 130 } },
  { k = "maple_stalls",  name = "Maple Stalls",  box = { 262, 220, 372, 268 } },
  { k = "general_store", name = "General Store", box = { 298, 88, 358, 138 } },
  { k = "herbalist",     name = "Herbalist",     box = { 122, 90, 180, 138 } },
  { k = "market_square", name = "Market Square", box = { 188, 142, 292, 216 } },
  { k = "notice_board",  name = "Notice Board",  box = { 136, 146, 178, 214 } },
  { k = "orchard_path",  name = "Orchard Path",  box = { 376, 148, 458, 222 } },
  { k = "beaver_pond",   name = "Beaver Pond",   box = { 124, 22, 180, 78 } },
}
local STANDS = { {182,240}, {232,228}, {226,258}, {318,158}, {330,186}, {342,210} }
local function nearStand(x, y, pad)
  for _, s in ipairs(STANDS) do if abs(x - s[1]) <= 15 + (pad or 0) and abs(y - s[2]) <= 6 + (pad or 0) then return true end end
  return false
end
local function inCompass(x, y) return x >= 378 and y >= 228 end

---------------------------------------------------------------- 1. sky
local SKY = { {12,"#3a3a7a"}, {28,"#5a4c92"}, {44,"#8a5c9e"}, {60,"#c06c96"}, {74,"#ec8a7a"}, {88,"#fbac68"}, {100,"#ffcc7a"}, {112,"#ffe09a"} }
for y = 0, VY do
  local yy = floor(y / 4) * 4
  local col = SKY[1][2]
  for i = 1, #SKY - 1 do
    local a, b = SKY[i], SKY[i + 1]
    if yy >= a[1] and yy <= b[1] then col = mix(a[2], b[2], (yy - a[1]) / (b[1] - a[1])) end
  end
  if yy > 112 then col = SKY[#SKY][2] end
  for x = 0, W - 1 do c:put(x, y, col) end
end
-- sunset glow behind the maples (stepped halo)
for y = 20, VY do for x = 60, 420 do
  local d = sqrt(((x - 240) / 170)^2 + ((y - 100) / 72)^2)
  if d < 1 then tint(x, y, "#fff0b8", .5 * floor((1 - d) * 4 + .999) / 4) end
end end
-- god-rays: faint warm wedges fanning up from behind the hall
for k = -3, 3 do
  local ang = -PI / 2 + k * .32
  for r = 30, 160 do
    local x, y = floor(240 + cos(ang) * r), floor(96 + sin(ang) * r * .7)
    for w = -1, 1 do if y < VY and y > 12 then tint(x + w, y, "#fff4c8", .12) end end
  end
end
-- clouds (lit from the sunset: warm tops, violet undersides)
local function cloud(x, y, w, seed)
  local m = HP.mask()
  m:add(c:rrect(x, y - floor(w * .14), x + w, y, 3))
  local n = 4
  for i = 1, n do
    local cx = x + floor(w * (i - .5) / n)
    local r = floor(w * (.12 + hash(i, seed, 3) * .12))
    m:add(c:ellipse(cx, y - floor(w * .12) - floor(r * .5), r, floor(r * .8)))
  end
  m:clip(rect(x - 30, 0, x + w + 30, y))
  tex(m, function(px, py)
    local up = m:has(px, py - 2) local lf = m:has(px - 2, py)
    local t = (py - (y - w * .4)) / (w * .4)
    if not up then return "#fff2d6" end
    if not lf and t < .7 then return "#fde2c0" end
    if py >= y - 1 then return "#b888a8" end
    if t > .78 then return "#d8a2b2" end
    if hash(px, py, seed) < .05 then return "#f2c4b6" end
    return "#f8d4bc"
  end)
  return m
end
cloud(22, 50, 70, 1) cloud(104, 66, 58, 2) cloud(116, 34, 44, 3) cloud(300, 38, 74, 4)
cloud(352, 66, 62, 5) cloud(400, 34, 50, 6) cloud(176, 22, 40, 7)

---------------------------------------------------------------- 2. layered hazy hills
local function hills(f, colTop, colBot, ybot, seed, treeAmp)
  for x = 0, W - 1 do
    local top = floor(f(x) + .5)
    for y = top, ybot do
      local t = (y - top) / max(1, ybot - top)
      local col = mix(colTop, colBot, t)
      local dx = abs(x - 240) / 240
      col = mix(col, "#ffe0b0", max(0, .35 - dx * .5))
      if treeAmp and hash(floor(x / 4), floor(y / 3), seed) < .25 then col = mix(col, colBot, .5) end
      if y == top then col = mix(col, "#ffe8b8", .5) end
      c:put(x, y, col)
    end
  end
end
hills(function(x) return 74 + 7 * sin(x / 41 + 1) + 4 * sin(x / 15) end, "#c8a0c0", "#d8b2bc", VY, 1)
hills(function(x) return 86 + 6 * sin(x / 29 + 2) + 3 * sin(x / 9) - 2 * abs(sin(x / 3.1)) end, "#a47ca8", "#bc90a8", VY, 2, true)
hills(function(x) return 97 + 4 * sin(x / 19 + 4) - 3 * abs(sin(x / 3.7)) - 2 * abs(sin(x / 2.3)) end, "#a8607a", "#c07c78", VY, 3, true)
hills(function(x) return 105 + 3 * sin(x / 13) - 3 * abs(sin(x / 2.9)) end, "#b45a4c", "#c8784e", VY, 4, true)

---------------------------------------------------------------- 3. giant maple behind the hall
do
  local blobs = { {240,40,62,26}, {194,58,40,24}, {286,58,40,24}, {218,24,30,14}, {264,26,30,14},
    {240,70,74,22}, {172,78,22,16}, {308,78,22,16}, {240,18,18,8} }
  local function val(x, y)
    local v = -1
    for _, b in ipairs(blobs) do v = max(v, 1 - ((x - b[1]) / b[3])^2 - ((y - b[2]) / b[4])^2) end
    return v + (hash(floor(x / 3), floor(y / 3), 11) - .5) * .4
  end
  local m = HP.mask()
  for y = 8, 100 do for x = 140, 340 do if val(x, y) > 0 then m:set(x, y) end end end
  -- trunk + limbs
  local tr = poly{ {232,100}, {248,100}, {246,70}, {258,52}, {254,50}, {242,62}, {238,62}, {226,50}, {222,52}, {234,70} }
  tex(tr, function(x, y) return (x < 238) and OAK[3] or OAK[2] end)
  tex(m, function(x, y)
    local cx, cy = floor(x / 7), floor((y + (floor(x / 7) % 2) * 3) / 6)
    local u, v = x - cx * 7, (y + (cx % 2) * 3) - cy * 6
    local L = .62 - (y - 10) / 90 * .55 - (x - 240) / 300
    if u + v < 4 then L = L + .22 elseif u + v > 9 then L = L - .22 end
    if hash(cx, cy, 12) < .2 then L = L - .15 end
    if hash(x, y, 13) < .05 then L = L + .2 end
    local i = 1 + floor(max(0, min(.999, L)) * 6)
    return R(MAPLE, i)
  end)
  m:edge():each(function(x, y)
    if not m:has(x, y - 1) or not m:has(x - 1, y) then c:put(x, y, "#ffd870") else c:put(x, y, MAPLE[1]) end
  end)
  -- gold specks of light leaves
  for i = 1, 60 do
    local x, y = 150 + floor(hash(i, 1, 14) * 180), 14 + floor(hash(i, 2, 14) * 80)
    if m:has(x, y) and m:has(x + 1, y + 1) then c:put(x, y, GOLDL[6]) c:put(x + 1, y, GOLDL[5]) end
  end
end

---------------------------------------------------------------- 3b. BEAVER POND on the knoll behind the Herbalist (special2 front, v6)
do
  local INK = "#2b1c26"
  local HAZE = "#c890a8"
  -- knoll: a grassy rise behind the rooftops (mid-far layer, a touch hazed)
  local knoll = poly{ {104,98}, {106,80}, {110,68}, {116,59}, {124,51}, {136,48}, {152,47}, {170,48}, {182,50}, {190,57}, {196,66}, {200,80}, {202,98} }
  tex(knoll, function(x, y)
    local t = (y - 49) / 49
    local i = 4 - floor(t * 2.2)
    if x > 186 - (y - 50) * .2 then i = i - 1 end            -- shaded right shoulder
    if hash(floor(x / 3), floor(y / 2), 201) < .18 then i = i - 1 end
    if hash(x, y, 202) < .05 then i = i + 1 end
    local col = (hash(floor(x / 6), floor(y / 4), 203) < .45) and R(LEAFG, i) or R(GRASS, i + 1)
    return mix(col, HAZE, .14 + t * .1)
  end)
  knoll:edge():each(function(x, y)
    if not knoll:has(x, y - 1) then c:put(x, y, (x < 170) and "#e8d088" or LEAFG[4]) end
  end)
  -- worn footpath zig-zagging down the knoll toward the Herbalist
  for _, p in ipairs({ {118,72}, {120,74}, {122,76}, {124,77}, {127,79}, {130,80}, {128,82}, {125,84}, {123,86} }) do
    c:put(p[1], p[2], GRASS[5]) c:put(p[1] + 1, p[2], GRASS[6])
  end

  -- pond water (reflects the sunset sky: warm far rows, violet-blue middle, teal near the dam)
  local pond = c:ellipse(156, 61, 28, 8)
  pond:clip(knoll:shrink(2))
  tex(pond, function(x, y)
    local col
    if y <= 55 then col = "#f2bc98" elseif y <= 58 then col = "#d8a2b2" elseif y <= 62 then col = SBLUE[5]
    elseif y <= 65 then col = SBLUE[4] elseif y <= 67 then col = TEAL[4] else col = TEAL[3] end
    -- ripple glints (deliberate short dashes, not noise)
    if (y == 57 or y == 61 or y == 64) and hash(floor(x / 5), y, 210) < .3 then col = (y == 57) and "#fbe0c0" or SBLUE[5] end
    return col
  end)
  -- bank lip: dark mud line at the near (lower) water edge, light grass lip on the far side
  pond:edge():each(function(x, y)
    if not pond:has(x, y + 1) then c:put(x, y, BROWNR[2]) elseif not pond:has(x, y - 1) then c:put(x, y, "#f4c49a") end
  end)
  c:rim(pond, INK, rect(0, 0, W - 1, 58))

  -- lodge: a dome of criss-crossed sticks and mud, left of the pond (against the violet sky)
  local lodge = c:ellipse(136, 62, 12, 12):clip(rect(0, 0, W - 1, 62))
  local ldg = lodge:copy()
  -- a few long sticks poking out of the silhouette
  for _, s in ipairs({ { {127,53}, {122,47} }, { {137,51}, {138,44} }, { {145,54}, {151,49} }, { {132,52}, {128,46} } }) do
    ldg:add(c:line(P(s), 1))
  end
  tex(ldg, function(x, y)
    local u, v = x - 136, y - 62
    -- two crossing stick directions, 3 px pitch
    local a = (x + y * 2) % 7 local b = (x * 2 - y + 40) % 6
    local L = .55 - (u / 12) * .22 - (v / 12) * .12              -- key light upper left
    if a == 0 then L = L + .18 elseif a == 1 then L = L - .12 end
    if b == 0 then L = L + .1 elseif b == 3 then L = L - .08 end
    if hash(floor(x / 4), floor(y / 3), 220) < .22 then L = L - .2 end -- mud packing
    if not lodge:has(x, y) then L = .45 + (x < 136 and .15 or -.1) end
    return R(BROWNR, 1 + floor(max(0, min(.999, L)) * 6))
  end)
  -- mud cap smoothed on top, moss on the shaded north-east side
  for x = 131, 141 do for y = 50, 52 do if lodge:has(x, y) and hash(x, y, 221) < .55 then c:put(x, y, (x < 136) and WSTONE[4] or WSTONE[3]) end end end
  for _, p in ipairs({ {145,54}, {146,55}, {147,57}, {148,59}, {144,53}, {146,58} }) do c:put(p[1], p[2], LEAFG[3]) end
  c:put(146, 56, LEAFG[4])
  -- shade the right half (cool violet)
  lodge:each(function(x, y) if x > 138 + (62 - y) * .25 then tint(x, y, SHADE, .22) end end)
  c:rim(ldg, INK, rect(0, 0, W - 1, 61))
  -- warm rim light on the upper-left sticks
  ldg:edge():each(function(x, y) if (not ldg:has(x - 1, y) or not ldg:has(x, y - 1)) and x < 137 and y < 60 then c:put(x, y, BROWNR[6]) end end)
  -- lodge reflection (mirrored, darker, broken by ripples)
  for y = 63, 68 do for x = 124, 150 do
    local my = 62 - (y - 62) * 2
    if lodge:has(x, my) and pond:has(x, y) and (y + floor(x / 3)) % 4 ~= 0 then c:put(x, y, (x < 136) and BROWNR[3] or BROWNR[2]) end
  end end
  -- food cache: floating twig pile in front of the lodge
  for _, s in ipairs({ { {150,62}, {157,60} }, { {151,60}, {156,63} }, { {153,59}, {154,63} } }) do
    local m = c:line(P(s), 1) tex(m, function(x, y) return (y < 61) and BROWNR[5] or BROWNR[3] end)
  end
  c:put(152, 59, LEAFG[5]) c:put(156, 61, LEAFG[4])

  -- lily pads (notched, two greens) + one pink flower
  for i, p in ipairs({ {162,57}, {170,60}, {160,64}, {175,63}, {167,65} }) do
    local m = c:ellipse(p[1], p[2], 3, 1)
    tex(m, function(x, y) return (x < p[1]) and GREEN[5] or GREEN[4] end)
    c:put(p[1] + 1, p[2], GREEN[2]) c:put(p[1] + 2, p[2], GREEN[2])
    fill(m:grow(1):cut(m):clip(rect(0, p[2] + 1, W - 1, p[2] + 2)), TEAL[1])
  end
  c:put(169, 59, ROSE[5]) c:put(170, 59, ROSE[6]) c:put(171, 59, ROSE[4]) c:put(170, 58, ROSE[5])
  -- floating maple leaves
  c:put(158, 56, MAPLE[5]) c:put(159, 56, MAPLE[4]) c:put(178, 59, GOLDL[5]) c:put(179, 59, GOLDL[4])

  -- the dam: a low wall of laid logs + sticks along the near bank, with a spill gap
  local dam = poly{ {124,69}, {134,70}, {150,72}, {168,72}, {182,69}, {186,66}, {187,70}, {184,74}, {168,77}, {150,77}, {132,75}, {122,73} }
  tex(dam, function(x, y)
    local logRow = (y + floor(x / 9)) % 3
    local i = (logRow == 0) and 5 or (logRow == 1 and 4 or 2)
    if (x + y * 3) % 9 == 0 then i = 3 end                       -- log ends / cross sticks
    if hash(floor(x / 5), y, 230) < .18 then i = i - 1 end
    if x > 168 then i = i - 1 end
    return R(OAK, i)
  end)
  -- log end-grain rounds on the face of the dam
  for _, p in ipairs({ {129,73}, {140,74}, {160,75}, {176,73} }) do
    c:put(p[1], p[2], OAK[6]) c:put(p[1] + 1, p[2], OAK[5]) c:put(p[1], p[2] + 1, OAK[4])
  end
  -- moss tufts on the dam top
  for _, x in ipairs({ 127, 136, 158, 171, 180 }) do c:put(x, 70 + (x > 170 and -1 or 0), LEAFG[4]) c:put(x + 1, 70 + (x > 170 and -1 or 0), LEAFG[3]) end
  c:rim(dam, INK)
  -- spill: water tumbling over a notch in the dam and down the knoll (falls behind the pipe)
  local spill = rect(144, 71, 147, 92)
  tex(spill, function(x, y)
    local k = (y * 2 + x) % 5
    if x == 144 then return "#a8c4d8" end
    return (k == 0) and "#e4eef0" or ((k < 3) and "#94b4cc" or SBLUE[5])
  end)
  for y = 72, 92 do c:put(143, y, INK) c:put(148, y, (y % 3 == 0) and SBLUE[3] or INK) end
  -- splash foam at the dam foot
  for _, p in ipairs({ {142,78}, {149,79}, {141,81}, {150,82}, {145,93}, {143,92}, {148,92} }) do c:put(p[1], p[2], "#e4eef0") end

  -- plank walk: a boardwalk on posts reaching out from the right shore
  local walk = poly{ {166,58}, {188,55}, {189,58}, {167,61} }
  tex(walk, function(x, y)
    local seam = (x - 166) % 4 == 0
    local i = seam and 2 or ((y <= 57 + floor((166 - x) / 7)) and 6 or 5)
    if x > 182 then i = i - 1 end
    return R(OAK, i)
  end)
  c:rim(walk, INK)
  for _, x in ipairs({ 168, 175, 183 }) do
    local yb = 61 - floor((x - 166) / 8)
    for y = yb, yb + 3 do c:put(x, y, OAK[2]) end
    c:put(x, yb + 4, OAK[4]) c:put(x, yb + 5, TEAL[1])                    -- reflection stub
  end
  -- lantern post at the walk's end + coiled rope
  for y = 47, 57 do c:put(167, y, OAK[2]) c:put(168, y, OAK[4]) end
  fill(rect(169, 47, 171, 47), IRON[2])
  local lt = rect(170, 48, 172, 51) tex(lt, function(x, y) return (y < 50) and "#fff0b0" or "#ffc860" end)
  c:rim(lt, IRON[1])
  glow(171, 50, 8, "#ffd890", .3)
  c:put(184, 55, MUST[4]) c:put(185, 55, MUST[5]) c:put(186, 55, MUST[3]) c:put(185, 54, MUST[4])

  -- cattails (brown velvet heads on tall stems), clumps at both ends
  for _, ct in ipairs({ {125,66,12}, {127,67,15}, {123,68,10}, {180,64,13}, {182,65,16}, {178,66,11}, {185,63,12} }) do
    local x, yb, h = ct[1], ct[2], ct[3]
    for y = yb - h, yb do c:put(x, y, (y < yb - h + 6) and LEAFG[3] or LEAFG[2]) end
    fill(rect(x - 1, yb - h + 2, x, yb - h + 6), BROWNR[3])
    c:put(x - 1, yb - h + 2, BROWNR[5]) c:put(x - 1, yb - h + 3, BROWNR[4])
    c:put(x, yb - h, LEAFG[5])
  end
  -- reed blades + ferny clumps along the far bank
  for i = 0, 9 do
    local x = 128 + i * 6 + floor(hash(i, 1, 240) * 3)
    if x < 129 or x > 156 then
      local y = 53 - (x > 160 and 0 or 1)
      c:put(x, y, LEAFG[4]) c:put(x, y - 1, LEAFG[5]) c:put(x + 1, y - 2, LEAFG[5])
    end
  end
  -- golden aspen sapling on the far right bank (third flora kind)
  for y = 36, 53 do c:put(188, y, (y % 4 == 0) and CREAM[5] or CREAM[6]) c:put(189, y, CREAM[3]) end
  c:put(188, 44, INK) c:put(189, 48, INK)
  local crown = c:ellipse(188, 38, 6, 7)
  tex(crown, function(x, y)
    local i = ((x - 182) + (y - 31) < 7) and 6 or ((x > 190) and 3 or 4)
    if (x + y * 2) % 5 == 0 then i = i - 1 end
    return R(GOLDL, i)
  end)
  c:rim(crown, INK)
  -- gnawed stump + wood chips (a beaver was here) on the left shoulder
  local stump = rect(112, 60, 117, 64)
  tex(stump, function(x, y) return (y == 60) and CREAM[6] or ((x < 115) and OAK[5] or OAK[3]) end)
  c:put(113, 59, CREAM[5]) c:put(114, 58, CREAM[6]) c:put(115, 59, CREAM[5])   -- chewed point
  c:rim(stump:copy():add(rect(113, 59, 115, 59)):add(rect(114, 58, 114, 58)), INK)
  c:put(114, 61, OAK[3]) c:put(115, 62, OAK[3])
  for _, p in ipairs({ {110,65}, {119,66}, {121,64}, {111,67}, {118,63} }) do c:put(p[1], p[2], CREAM[5]) end
  -- felled log with teeth marks, half rolled toward the dam
  local lg = rect(116, 67, 124, 69)
  tex(lg, function(x, y) return (y == 67) and OAK[5] or ((y == 68) and OAK[4] or OAK[2]) end)
  c:rim(lg, INK)
  c:put(117, 68, CREAM[5]) c:put(120, 67, OAK[6])
  -- cast shadows: lodge, sapling and post fall to the lower right on the far bank
  shadeMask(rect(152, 53, 160, 54):clip(knoll):cut(pond), .25)
end
---------------------------------------------------------------- 4. ground + cobbles
local road = poly{ {VX - 1, VY}, {VX + 1, VY}, {336, 270}, {144, 270} }
local plaza = poly{ {150, 142}, {330, 142}, {366, 224}, {116, 224} }
local apron = poly{ {200, 127}, {280, 127}, {330, 143}, {150, 143} }
local cob = road:copy():add(plaza):add(apron):clip(rect(0, VY + 1, W - 1, H - 1))
for y = VY + 1, H - 1 do for x = 0, W - 1 do
  if not cob:has(x, y) then
    local depth = (y - VY) / (H - VY)
    local i = 3 + (depth > .45 and 1 or 0)
    local h = hash(x, floor(y / 2), 21)
    if h < .1 then i = i - 1 elseif h > .93 then i = i + 1 end
    if hash(floor(x / 9), floor(y / 5), 22) < .2 then i = i - 1 end
    local col = R(GRASS, i)
    if y < 150 then col = mix(col, "#e0b098", (150 - y) / 38 * .45) end
    c:put(x, y, col)
  end
end end
-- grass tufts and fallen leaves on the verges
for i = 1, 900 do
  local x, y = floor(hash(i, 1, 23) * W), VY + 2 + floor(hash(i, 2, 23) * (H - VY - 3))
  if not cob:has(x, y) and not inCompass(x, y) then
    local depth = (y - VY) / (H - VY)
    if hash(i, 3, 23) < .5 then
      for k = 0, floor(1 + depth * 3) do c:put(x, y - k, GRASS[2]) end
      c:put(x + 1, y, GRASS[5])
    elseif depth > .25 then
      local r = ({ MAPLE, ORANGE, GOLDL })[1 + floor(hash(i, 4, 23) * 3)]
      c:put(x, y, R(r, 4)) c:put(x + 1, y, R(r, 5)) c:put(x, y + 1, R(r, 3))
    end
  end
end
-- cobble rows (perspective running bond, joints converge on the vanishing point)
local rows = {}
do local y, idx = VY + 1, 0
  while y < H do
    local h = max(2, floor((y - 104) * .078 + .5))
    for yy = y, min(H - 1, y + h - 1) do rows[yy] = { top = y, h = h, i = idx } end
    y, idx = y + h, idx + 1
  end
end
tex(cob, function(x, y)
  local r = rows[y] local yr = r.top + r.h / 2
  local sw = max(2.5, .13 * (yr - 104))
  local u = (x - 240) / sw * (1 + (yr - 104) / 900) + (r.i % 2) * .5
  local col = floor(u) local fu = u - col
  local ramp = (hash(col, r.i, 31) < .4) and COBW or COB
  if y == r.top or fu * sw < 1 then return mix(COB[1], "#6a5060", .4) end
  local i = 4 + (hash(col, r.i, 32) < .3 and -1 or 0) + (hash(col, r.i, 33) > .85 and 1 or 0)
  local fv = (y - r.top) / r.h
  if fv < .4 and fu * sw < sw * .6 then i = i + 1 end
  if y == r.top + r.h - 1 or (1 - fu) * sw < 1.6 then i = i - 1 end
  if y == r.top + 1 and fu * sw >= 1 and fu * sw < 3 and r.h >= 5 then i = i + 1 end
  local cc = R(ramp, i)
  if y < 172 then cc = mix(cc, "#e4bca4", (172 - y) / 60 * .45) end
  return cc
end)
-- kerb: dark lip + light curb stone along every cobble edge
cob:edge():each(function(x, y) c:put(x, y, "#5a4656") end)
cob:shrink(1):edge():each(function(x, y) if y > 118 then c:put(x, y, (y % 6 < 3) and COB[5] or COB[4]) end end)
-- fallen leaves on the cobbles (never on stand spots)
for i = 1, 70 do
  local x, y = floor(hash(i, 1, 41) * W), 130 + floor(hash(i, 2, 41) * 138)
  if cob:has(x, y) and not nearStand(x, y, 6) and not inCompass(x, y) then
    local r = ({ MAPLE, ORANGE, GOLDL })[1 + floor(hash(i, 3, 41) * 3)]
    if y > 200 then leaf(LEAF, x, y, r) else c:put(x, y, R(r, 4)) c:put(x + 1, y, R(r, 5)) c:put(x, y + 1, R(r, 2)) end
  end
end

---------------------------------------------------------------- 5. house builder
-- gable-front house; o.left = on the left of the street (side wall on its right, toward the VP)
local function house(o)
  local x0, x1, top, base, apex, s = o.x0, o.x1, o.top, o.base, o.apex, o.s
  local mx = floor((x0 + x1) / 2)
  local inner = o.left and x1 or x0
  local sg = o.left and 1 or -1
  local ovh = o.ovh or 3
  local ax2, ay2 = lerpVP(inner, top, s) local bx2, by2 = lerpVP(inner, base, s)
  local side = poly{ {inner, top}, {ax2, ay2}, {bx2, by2}, {inner, base} }
  local ex, ey = inner + sg * ovh, top + 2
  local ex2, ey2 = lerpVP(ex, ey, s) local px2, py2 = lerpVP(mx, apex, s)
  local roofSide = poly{ {mx, apex}, {px2, py2}, {ex2, ey2}, {ex, ey} }
  local front = rect(x0, top, x1, base):add(poly{ {x0, top + 1}, {x1 + 1, top + 1}, {mx + .5, apex} })
  if o.shadow ~= false then castShadow(x0, max(x1, bx2), base, o.sdx or 12, o.sdy or 7) end
  -- side wall
  local wb = o.wallBase or 4
  local sideBase = o.left and wb - 1 or wb + 1
  if o.wallTex == "planks" then planks(side, o.wallR, { w = o.pw or 5, base = sideBase, seed = 3 })
  elseif o.wallTex == "stone" then stones(side, o.wallR, { base = sideBase })
  else plaster(side, o.wallR, { base = sideBase }) end
  if o.left then shadeMask(side, .22) end
  c:edgeIn(side, R(o.wallR, 1))
  -- roof side plane
  shingles(roofSide, o.roofR, { rh = o.rh or 4, w = o.rw or 6, base = o.left and 4 or 5, oy = apex })
  c:edgeIn(roofSide, R(o.roofR, 1))
  -- front
  if o.wallTex == "planks" then planks(front, o.wallR, { w = o.pw or 5, base = wb, ox = x0 })
  elseif o.wallTex == "stone" then stones(front, o.wallR, { base = wb, oy = top })
  else plaster(front, o.wallR, { base = wb }) end
  -- light from upper-left on the front: subtle cool falloff to the lower-right
  front:each(function(x, y) local t = ((x - x0) / max(1, x1 - x0) + (y - apex) / max(1, base - apex)) / 2 if t > .62 then tint(x, y, SHADE, (t - .62) * .45) end end)
  -- AO under the roof edge
  front:each(function(x, y)
    local ys = top + 1 - floor((mx - abs(x - mx)) / max(1, mx - x0) * (top + 1 - apex))
    if y - ys >= 0 and y - ys <= 3 then tint(x, y, SHADE, .3 - (y - ys) * .07) end
  end)
  -- roof front edge (thick bargeboard band)
  local rt = o.rt or 5
  local band = c:line(P{ {x0 - ovh, top + 3}, {mx, apex}, {x1 + ovh, top + 3} }, rt)
  tex(band, function(x, y)
    if not band:has(x, y - 1) then return R(o.roofR, 6) end
    if not band:has(x, y + 1) then return R(o.roofR, 1) end
    return R(o.roofR, (hash(floor(x / 3), y, 51) < .3) and 3 or 4)
  end)
  c:edgeIn(front, R(o.wallR, 1))
  for x = x0, x1 do c:put(x, base, R(o.wallR, 1)) end
  local sil = front:copy():add(side):add(roofSide):add(band)
  return { front = front, side = side, roof = roofSide, band = band, sil = sil, mx = mx, ax2 = ax2, ay2 = ay2, bx2 = bx2, by2 = by2 }
end
local function frameTimber(x0, x1, ys, r)
  for _, y in ipairs(ys) do beam(x0, y, x1, y + 2, r) end
end

---------------------------------------------------------------- 6. TOWN HALL (far end)
do
  castShadow(196, 284, 130, 14, 6, .3)
  -- leaning turret (behind the roof on the right)
  local lt = poly{ {262, 70}, {276, 70}, {284, 36}, {270, 36} }
  stones(lt, WSTONE, { bh = 4, bw = 6, base = 4, oy = 36 })
  lt:each(function(x, y) if x > 274 + (70 - y) * .24 then tint(x, y, SHADE, .3) end end)
  c:edgeIn(lt, WSTONE[1])
  window(274, 44, 277, 50, { sill = false })
  local ltc = poly{ {266, 38}, {289, 38}, {283, 18} }
  shingles(ltc, REDR, { rh = 3, w = 4, oy = 18 }) c:edgeIn(ltc, REDR[1])
  fill(rect(283, 13, 284, 18), IRON[2]) c:put(285, 13, REDR[5]) c:put(286, 14, REDR[4])
  -- hall body
  local front = rect(202, 76, 278, 130)
  plaster(front, CREAM, { base = 4 })
  front:each(function(x, y) if x > 250 then tint(x, y, SHADE, (x - 250) / 28 * .18) end end)
  stones(rect(202, 116, 278, 130), STONE, { bh = 4, bw = 8, base = 4, oy = 116 })
  stones(rect(202, 76, 207, 116), STONE, { bh = 4, bw = 6, base = 5, oy = 76 })
  stones(rect(273, 76, 278, 116), STONE, { bh = 4, bw = 6, base = 3, oy = 76 })
  beam(208, 94, 272, 96, OAK)
  c:edgeIn(front, CREAM[1])
  -- roof
  local roof = poly{ {194, 79}, {287, 79}, {272, 58}, {208, 58} }
  shingles(roof, SLATE, { rh = 4, w = 6, base = 4, oy = 58 })
  roof:each(function(x, y) if x > 250 then tint(x, y, SHADE, .15) end end)
  c:edgeIn(roof, SLATE[1])
  for x = 195, 286 do c:put(x, 78, SLATE[6]) c:put(x, 79, SLATE[1]) end
  for y = 80, 82 do for x = 202, 278 do tint(x, y, SHADE, .3) end end
  -- clock tower
  local tw = rect(228, 34, 252, 70)
  plaster(tw, CREAM, { base = 5 })
  for y = 34, 70 do for x = 247, 252 do tint(x, y, SHADE, .28) end end
  stones(rect(228, 34, 231, 70), STONE, { bh = 4, bw = 4, base = 5, oy = 34 })
  stones(rect(249, 34, 252, 70), STONE, { bh = 4, bw = 4, base = 3, oy = 34 })
  c:edgeIn(tw, CREAM[1])
  -- belfry arch with bell
  fill(rect(235, 58, 245, 68), OAK[1]) fill(rect(237, 60, 243, 64), GOLDL[4]) fill(rect(236, 64, 244, 65), GOLDL[3]) c:put(238, 61, GOLDL[6])
  -- square clock face (no circles)
  local cf = c:rrect(232, 38, 248, 54, 3)
  fill(cf:grow(1):cut(cf), GOLDL[2]) fill(cf, "#f6ecd2")
  for y = 38, 54 do for x = 232, 248 do if cf:has(x, y) and x + y > 287 + 6 then tint(x, y, SHADE, .18) end end end
  for _, d in ipairs({ {240,39}, {240,53}, {233,46}, {247,46} }) do c:put(d[1], d[2], GOLDL[2]) end
  fill(rect(240, 41, 240, 46), IRON[1]) fill(rect(241, 46, 245, 46), IRON[1]) c:put(240, 46, REDR[4])
  -- cap
  local cap = poly{ {223, 35}, {258, 35}, {240.5, 12} }
  shingles(cap, COPPER, { rh = 3, w = 4, oy = 12 })
  cap:each(function(x, y) if x > 241 then tint(x, y, SHADE, .25) end end)
  c:edgeIn(cap, COPPER[1])
  fill(rect(240, 6, 241, 12), GOLDL[3]) leaf(LEAF, 237, 1, GOLDL)
  -- big doorway (warm lit)
  local dw = c:rrect(225, 97, 255, 131, 8)
  stones(dw:copy():cut(c:rrect(229, 101, 251, 131, 6)), STONE, { bh = 3, bw = 5, base = 5, oy = 97 })
  c:edgeIn(dw, STONE[1])
  local din = c:rrect(229, 101, 251, 131, 6)
  tex(din, function(x, y) local t = (y - 101) / 30 return t < .4 and "#ffe8a0" or (t < .75 and "#ffc860" or "#f09a40") end)
  planks(rect(229, 108, 233, 130), REDR, { w = 2, base = 4, ox = 229 }) planks(rect(247, 108, 251, 130), REDR, { w = 2, base = 3, ox = 247 })
  for x = 222, 258 do c:put(x, 130, STONE[5]) end
  fill(rect(224, 131, 256, 132), STONE[4])
  leaf(LEAF, 237, 88, MAPLE)
  -- windows
  window(210, 82, 220, 104, { frame = OAK[2] }) window(260, 82, 270, 104, { frame = OAK[2] })
  window(212, 100, 218, 112, { frame = OAK[2], sill = false })
  window(262, 100, 268, 112, { frame = OAK[2], sill = false })
  -- door lanterns
  for _, lx in ipairs({ 220, 260 }) do
    fill(rect(lx - 1, 108, lx + 1, 109), IRON[2]) fill(rect(lx - 2, 110, lx + 2, 116), "#ffd870")
    for y = 110, 116 do c:put(lx - 2, y, IRON[1]) c:put(lx + 2, y, IRON[1]) end
    c:put(lx - 1, 111, "#fff4d0")
    fill(rect(lx - 2, 117, lx + 2, 117), IRON[1])
  end
  -- blue-gold banners on the hall
  for _, bx in ipairs({ 204, 274 }) do
    local bn = poly{ {bx - 1, 98}, {bx + 4, 98}, {bx + 4, 112}, {bx + 1.5, 109}, {bx - 1, 112} }
    fill(bn, SBLUE[3]) c:edgeIn(bn, SBLUE[1]) fill(rect(bx + 1, 101, bx + 2, 103), GOLDL[5])
  end
end

---------------------------------------------------------------- 7. HERBALIST (far left)
do
  local h = house{ left = true, x0 = 125, x1 = 165, top = 108, base = 138, apex = 90, s = .18, ovh = 3,
    wallR = GREEN, wallTex = "planks", pw = 4, roofR = BROWNR, rt = 4, rh = 3, rw = 5 }
  window(130, 114, 144, 126, { frame = GREEN[1], shut = TEAL, sw = 3, sillc = OAK[5] })
  door(150, 119, 160, 137, OAK)
  -- herb drying rail + hanging bundles
  beam(124, 110, 166, 111, OAK)
  local hc = { LEAFG, GREEN, { "#2e2040","#4a305a","#6a4a7a","#8a68a0","#ac8cc0","#d0b4dc" }, LEAFG, GOLDL, GREEN, LEAFG }
  for i = 0, 6 do
    local x = 127 + i * 6 local len = 5 + (i % 3)
    c:put(x + 1, 112, TIMB[3])
    local bm = poly{ {x - 1, 113}, {x + 3, 113}, {x + 2, 113 + len}, {x + 1, 115 + len}, {x, 113 + len} }
    tex(bm, function(px, py) return (px <= x) and R(hc[i + 1], 5) or ((px >= x + 2) and R(hc[i + 1], 3) or R(hc[i + 1], 4)) end)
    c:edgeIn(bm, R(hc[i + 1], 1)) c:put(x + 1, 113, "#d8b060")
  end
  -- potted plants
  for _, p in ipairs({ { 124, 130, 1 }, { 140, 131, 2 }, { 168, 128, 3 } }) do
    local x, y = p[1], p[2]
    local pot = poly{ {x, y}, {x + 8, y}, {x + 7, y + 7}, {x + 1, y + 7} }
    tex(pot, function(px, py) return px < x + 3 and ORANGE[4] or ORANGE[3] end) c:edgeIn(pot, ORANGE[1])
    fill(rect(x - 1, y, x + 9, y + 1), ORANGE[5]) for xx = x - 1, x + 9 do c:put(xx, y + 1, ORANGE[2]) end
    for k = 0, 4 do
      local lx = x + 1 + k * 1.6 local ly = y - 3 - (k % 2) * 3 - (k == 2 and 2 or 0)
      local lm = c:line(P{ {x + 4, y}, {lx, ly} }, 2)
      fill(lm, (k % 2 == 0) and GREEN[5] or GREEN[4])
      c:put(floor(lx), floor(ly), GREEN[6])
    end
  end
  -- mortar-and-leaf sign (no text)
  fill(rect(128, 99, 140, 106), OAK[4]) c:edgeIn(rect(128, 99, 140, 106), OAK[1])
  leaf(LEAF, 131, 100, GREEN, { rim = false })
end

---------------------------------------------------------------- 8. GENERAL STORE (far right)
do
  local h = house{ x0 = 312, x1 = 356, top = 106, base = 138, apex = 88, s = .18, ovh = 3,
    wallR = SBLUE, wallTex = "planks", pw = 4, roofR = MUST, rt = 4, rh = 3, rw = 5, sdx = 10, sdy = 5 }
  window(316, 114, 336, 128, { frame = SBLUE[1], sill = false })
  -- striped awning
  local aw = poly{ {313, 108}, {340, 108}, {342, 114}, {311, 114} }
  tex(aw, function(x, y) local s = floor((x - 311) / 4) % 2 == 0 return s and (y < 111 and LEAFG[5] or LEAFG[4]) or (y < 111 and CREAM[6] or CREAM[5]) end)
  for x = 311, 342, 2 do c:put(x, 115, LEAFG[3]) end
  c:edgeIn(aw, LEAFG[1])
  door(342, 117, 352, 137, MUST)
  -- crates and a barrel
  for _, b in ipairs({ { 300, 126, 311, 137 }, { 314, 127, 324, 137 }, { 302, 116, 310, 125 } }) do
    local m = rect(b[1], b[2], b[3], b[4])
    planks(m, OAK, { w = 3, vert = false, base = 4, ox = b[2], seed = b[1] })
    dbeam(b[1] + 1, b[4] - 1, b[3] - 1, b[2] + 1, OAK)
    c:edgeIn(m, OAK[1])
  end
  barrel(326, 125, 336, 138, TIMB)
  -- apples spilling from the crate
  for _, a in ipairs({ { 316, 125 }, { 319, 124 }, { 322, 125 } }) do fill(rect(a[1], a[2], a[1] + 1, a[2] + 1), REDR[4]) c:put(a[1], a[2], REDR[6]) end
  -- gable emblem: tin can
  fill(rect(331, 96, 337, 103), IRON[4]) fill(rect(331, 98, 337, 100), REDR[4]) c:edgeIn(rect(331, 96, 337, 103), IRON[1])
end

---------------------------------------------------------------- 9. PIE BAKERY (mid left)
do
  local h = house{ left = true, x0 = 22, x1 = 94, top = 82, base = 146, apex = 56, s = .10, ovh = 3,
    wallR = ROSE, wallTex = "plaster", roofR = TEAL, rt = 6, rh = 4, rw = 6, sdx = 14, sdy = 8 }
  -- timber framing
  frameTimber(22, 94, { 82, 112 }, TIMB)
  for _, x in ipairs({ 22, 46, 70, 92 }) do beam(x, 84, x + 2, 145, TIMB) end
  dbeam(25, 110, 45, 86) dbeam(71, 86, 91, 110)
  -- gable window + chimney
  window(53, 66, 63, 76, { frame = TIMB[2], sill = false })
  local ch = rect(74, 50, 84, 72)
  stones(ch, WSTONE, { bh = 3, bw = 5, base = 4, oy = 50 }) c:edgeIn(ch, WSTONE[1])
  fill(rect(73, 48, 85, 50), WSTONE[5]) c:edgeIn(rect(73, 48, 85, 50), WSTONE[1])
  puff(80, 40, 6, 4) puff(86, 31, 5, 4)
  -- upper windows with flower boxes
  window(28, 88, 40, 102, { frame = TIMB[1], sill = false }) window(76, 88, 88, 102, { frame = TIMB[1], sill = false })
  for _, x in ipairs({ 27, 75 }) do
    fill(rect(x, 104, x + 14, 107), OAK[4]) c:edgeIn(rect(x, 104, x + 14, 107), OAK[1])
    for k = 0, 4 do fill(rect(x + 1 + k * 3, 102, x + 2 + k * 3, 103), (k % 2 == 0) and MAPLE[5] or ROSE[6]) end
  end
  -- BIG PIE SIGN (side-view pie on a bracket board)
  local brd = rect(46, 98, 72, 116)
  planks(brd, OAK, { w = 3, vert = false, base = 5, ox = 98 }) c:edgeIn(brd, OAK[1])
  fill(rect(56, 94, 57, 97), IRON[2]) fill(rect(61, 94, 62, 97), IRON[2])
  local dish = poly{ {48, 108}, {70, 108}, {67, 114}, {51, 114} }
  tex(dish, function(x, y) return y < 110 and SBLUE[5] or SBLUE[3] end) c:edgeIn(dish, SBLUE[1])
  local crust = poly{ {48, 108}, {50, 103}, {54, 101}, {64, 101}, {68, 103}, {70, 108} }
  tex(crust, function(x, y)
    local i = (x + y) % 6 == 0 and 3 or ((x - y) % 6 == 0 and 3 or 5)
    if y <= 102 and x < 60 then i = 6 end
    return R(GOLDL, i)
  end)
  c:edgeIn(crust, ORANGE[1])
  -- slice missing (quirk), shows filling
  local cut = poly{ {64, 101}, {68, 103}, {70, 108}, {62, 108} }
  fill(cut, MAPLE[3]) for x = 62, 70 do c:put(x, 107, MAPLE[2]) end c:put(65, 104, MAPLE[5])
  -- big shop window with windowsill pies
  window(26, 118, 64, 134, { frame = TIMB[1], sill = false })
  fill(rect(23, 135, 67, 137), OAK[5]) for x = 23, 67 do c:put(x, 138, OAK[2]) end c:edgeIn(rect(23, 135, 67, 137), OAK[1])
  for _, px in ipairs({ 27, 41, 55 }) do
    local d = poly{ {px, 131}, {px + 10, 131}, {px + 9, 134}, {px + 1, 134} }
    fill(d, SBLUE[4]) c:edgeIn(d, SBLUE[1])
    local cr = poly{ {px, 131}, {px + 2, 127}, {px + 8, 127}, {px + 10, 131} }
    tex(cr, function(x, y) return ((x + y) % 4 == 0) and ORANGE[4] or (y < 129 and GOLDL[6] or GOLDL[5]) end)
    c:edgeIn(cr, ORANGE[2])
    wisp(px + 3, 125, 12, px) wisp(px + 7, 124, 9, px + 2)
  end
  door(72, 118, 86, 145, REDR)
  fill(rect(70, 116, 88, 117), TIMB[2])
  -- pumpkins by the door
  pumpkin(88, 139, 96, 145) pumpkin(97, 140, 104, 145)
end

---------------------------------------------------------------- 10. TAVERN (mid right)
do
  local h = house{ x0 = 386, x1 = 460, top = 72, base = 136, apex = 46, s = .08, ovh = 3,
    wallR = MUST, wallTex = "plaster", roofR = REDR, rt = 6, rh = 4, rw = 6, sdx = 4, sdy = 6 }
  frameTimber(386, 460, { 72, 102 }, OAK)
  for _, x in ipairs({ 386, 410, 434, 458 }) do beam(x, 74, x + 2, 135, OAK) end
  dbeam(389, 100, 407, 76, OAK) dbeam(437, 76, 455, 100, OAK)
  window(414, 80, 430, 96, { frame = OAK[1], sill = false })
  window(418, 54, 426, 64, { frame = OAK[1], sill = false })
  -- ground floor: big lit window + door
  window(390, 110, 406, 126, { frame = OAK[1], shut = REDR, sw = 3 })
  local dr = c:rrect(426, 108, 444, 136, 5)
  fill(dr:grow(1):cut(dr), OAK[1])
  planks(dr, OAK, { w = 3, base = 4, ox = 426 }) c:put(441, 122, GOLDL[5])
  window(448, 110, 456, 124, { frame = OAK[1], sill = false })
  -- barrels outside
  barrel(446, 125, 458, 138, TIMB) barrel(410, 126, 421, 138, TIMB)
  -- BIG MUG SIGN on a bracket projecting toward the street
  beam(364, 76, 388, 78, IRON)
  fill(rect(366, 79, 366, 82), IRON[2]) fill(rect(384, 79, 384, 82), IRON[2])
  local mug = rect(366, 86, 382, 106)
  tex(mug, function(x, y) local u = (x - 366) / 16 local i = u < .3 and 5 or (u < .7 and 4 or 3) if (x - 366) % 5 == 0 then i = i - 1 end return R(GOLDL, i) end)
  fill(rect(366, 90, 382, 91), OAK[2]) fill(rect(366, 101, 382, 102), OAK[2])
  c:edgeIn(mug, ORANGE[1])
  local hd = rect(383, 90, 388, 102):cut(rect(384, 92, 386, 100))
  fill(hd, OAK[3]) c:edgeIn(hd, OAK[1])
  local foam = c:rrect(364, 81, 384, 88, 3):add(c:rrect(368, 79, 376, 85, 3))
  tex(foam, function(x, y) return y < 83 and CREAM[6] or (x > 378 and CREAM[4] or CREAM[5]) end)
  c:edgeIn(foam, CREAM[2])
  fill(rect(383, 86, 384, 92), CREAM[5]) c:put(384, 93, CREAM[4])
  c:put(368, 92, "#fff2d0") c:put(368, 93, "#fff2d0")
  -- door lantern
  fill(rect(421, 108, 423, 110), IRON[2]) fill(rect(420, 111, 424, 118), "#ffd870")
  for y = 111, 118 do c:put(420, y, IRON[1]) c:put(424, y, IRON[1]) end
  fill(rect(420, 119, 424, 119), IRON[1])
end

---------------------------------------------------------------- 11. syrup pipeline across the rooftops (quirk)
local pipePts = { {88, 74}, {100, 82}, {124, 86}, {145, 86}, {170, 94}, {186, 102}, {208, 118}, {226, 130}, {234, 135} }
do
  -- trestle legs
  for _, l in ipairs({ { 186, 104, 140 }, { 212, 122, 134 } }) do
    beam(l[1], l[2], l[1] + 2, l[3], OAK)
    dbeam(l[1] - 5, l[3], l[1], l[3] - 7, OAK)
  end
  local pm = c:line(P(pipePts), 4)
  pm:add(c:line(P{ {234, 135}, {237, 137}, {238, 140} }, 4))
  c:rim(pm, "#3a1c1a")
  tex(pm, function(x, y)
    if not pm:has(x, y - 1) then return "#f4c08a" end
    if not pm:has(x, y - 2) then return "#dc8c56" end
    if not pm:has(x, y + 1) then return "#6a2e22" end
    return "#b8603a"
  end)
  -- flanged joints + a drip
  for i = 2, #pipePts - 1 do local p = pipePts[i]
    fill(rect(p[1] - 1, p[2] - 2, p[1] + 1, p[2] + 3), "#8a4430") c:put(p[1] - 1, p[2] - 2, "#f4c08a")
  end
  fill(rect(146, 89, 146, 92), SYRUP[4]) c:put(146, 93, SYRUP[5])
  -- tap valve wheel at the bakery end
  fill(rect(86, 68, 92, 70), REDR[4]) fill(rect(88, 70, 90, 73), IRON[2]) c:edgeIn(rect(86, 68, 92, 70), REDR[1])
end

---------------------------------------------------------------- 12. MARKET SQUARE: giant syrup fountain
do
  castShadow(192, 290, 214, 16, 7, .32)
  -- basin
  local top = poly{ {188, 196}, {204, 187}, {276, 187}, {292, 196}, {276, 205}, {204, 205} }
  local body = poly{ {188, 196}, {204, 205}, {276, 205}, {292, 196}, {292, 207}, {276, 216}, {204, 216}, {188, 207} }
  local fl = poly{ {188, 196}, {204, 205}, {204, 216}, {188, 207} }
  local fm = rect(204, 205, 276, 216)
  local fr = poly{ {276, 205}, {292, 196}, {292, 207}, {276, 216} }
  stones(fl, WSTONE, { bh = 4, bw = 6, base = 5, oy = 196 })
  stones(fm, WSTONE, { bh = 4, bw = 9, base = 4, oy = 205 })
  stones(fr, WSTONE, { bh = 4, bw = 6, base = 3, oy = 196 })
  shadeMask(fr, .18)
  fill(top, WSTONE[5])
  top:edge():each(function(x, y) c:put(x, y, (y < 196) and WSTONE[6] or WSTONE[4]) end)
  local water = poly{ {193, 196}, {206, 190}, {274, 190}, {287, 196}, {274, 202}, {206, 202} }
  tex(water, function(x, y)
    local i = 4
    if (y + floor(x / 9)) % 4 == 0 then i = 5 end
    if y < 193 then i = 3 end
    if hash(floor(x / 3), y, 61) < .06 then i = 6 end
    return R(SYRUP, i)
  end)
  c:edgeIn(water, SYRUP[2])
  for x = 206, 274 do c:put(x, 203, WSTONE[3]) end
  c:edgeIn(body:copy():add(top), WSTONE[1])
  -- column
  local col = rect(234, 172, 246, 194)
  stones(col, STONE, { bh = 3, bw = 13, base = 5, oy = 172 })
  for y = 172, 194 do c:put(244, y, STONE[3]) c:put(245, y, STONE[2]) c:put(235, y, STONE[6]) end
  c:edgeIn(col, STONE[1])
  -- upper bowl
  local bt = poly{ {212, 172}, {222, 167}, {258, 167}, {268, 172}, {258, 177}, {222, 177} }
  local bb = poly{ {212, 172}, {268, 172}, {258, 182}, {222, 182} }
  stones(bb, WSTONE, { bh = 3, bw = 7, base = 4, oy = 172 })
  bb:each(function(x, y) if x > 250 then tint(x, y, SHADE, .2) end end)
  fill(bt, WSTONE[5])
  local bw = poly{ {216, 172}, {224, 169}, {256, 169}, {264, 172}, {256, 175}, {224, 175} }
  tex(bw, function(x, y) return (y < 171) and SYRUP[3] or ((x + y) % 7 == 0 and SYRUP[6] or SYRUP[4]) end)
  c:edgeIn(bb:copy():add(bt), WSTONE[1])
  -- overflow syrup ribbons into the basin
  for _, sx in ipairs({ 214, 266 }) do
    for y = 173, 195 do
      local dx = floor((y - 173) * (sx < 240 and -.18 or .18))
      c:put(sx + dx, y, SYRUP[5]) c:put(sx + dx + 1, y, SYRUP[4]) c:put(sx + dx + (sx < 240 and -1 or 2), y, SYRUP[2])
    end
    fill(rect(sx - 8 + (sx < 240 and -2 or 6), 194, sx + 2 + (sx < 240 and -2 or 6), 195), SYRUP[6])
  end
  -- giant syrup barrel on top
  barrel(225, 145, 255, 168, OAK, { syrup = true })
  leaf(LEAF, 237, 152, MAPLE)
  -- spigot pouring into the bowl
  fill(rect(244, 163, 249, 165), IRON[3]) c:put(244, 163, IRON[5]) c:edgeIn(rect(244, 163, 249, 165), IRON[1])
  for y = 166, 172 do c:put(248, y, SYRUP[5]) c:put(249, y, SYRUP[3]) end
  -- syrup stream from the rooftop pipe into the barrel
  for y = 141, 146 do c:put(238, y, SYRUP[5]) c:put(239, y, SYRUP[4]) end
  fill(rect(236, 146, 241, 146), SYRUP[6])
end

---------------------------------------------------------------- 13. NOTICE BOARD (towering, no text)
do
  castShadow(140, 176, 214, 10, 5, .32)
  for _, x in ipairs({ 141, 170 }) do
    local p = rect(x, 154, x + 3, 214)
    planks(p, OAK, { w = 4, base = 4, ox = x }) c:edgeIn(p, OAK[1]) for y = 154, 214 do c:put(x + 1, y, OAK[5]) end
  end
  local cap = poly{ {134, 156}, {140, 147}, {174, 147}, {180, 156} }
  shingles(cap, REDR, { rh = 3, w = 5, oy = 147 }) c:edgeIn(cap, REDR[1])
  local bd = rect(137, 157, 177, 196)
  planks(bd, OAK, { w = 5, vert = false, base = 3, ox = 157 })
  c:edgeIn(bd, OAK[1]) for x = 138, 176 do c:put(x, 158, OAK[5]) end
  -- pinned notes with pictograms (no text)
  local notes = { { 140, 160, 151, 173, CREAM }, { 154, 159, 165, 170, ROSE }, { 166, 162, 175, 175, CREAM },
                  { 140, 176, 150, 192, SBLUE }, { 153, 173, 165, 186, CREAM }, { 167, 178, 175, 193, GOLDL } }
  for i, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    tex(m, function(x, y) return (x + y < n[1] + n[2] + 6) and R(n[5], 6) or R(n[5], 5) end)
    for x = n[1] + 1, n[3] do c:put(x, n[4] + 1, OAK[1]) end
    c:put(floor((n[1] + n[3]) / 2), n[2], REDR[4])
  end
  leaf(LEAF, 142, 164, MAPLE, { rim = false })
  pumpkin(156, 163, 163, 168)
  fill(poly{ {167, 170}, {170, 166}, {174, 170} }, GOLDL[4]) fill(rect(167, 170, 174, 172), SBLUE[3])
  barrel(142, 180, 148, 189, TIMB)
  fill(rect(155, 177, 163, 178), IRON[4]) fill(rect(155, 180, 161, 181), IRON[4]) fill(rect(155, 183, 162, 184), IRON[4])
  fill(rect(169, 182, 173, 188), MAPLE[3]) fill(rect(172, 180, 173, 181), MAPLE[3])
  -- pinned lantern hook + leaf pile at the foot
  for i = 0, 5 do leaf(LEAF, 136 + i * 7, 208 + (i % 2) * 2, ({ MAPLE, ORANGE, GOLDL })[i % 3 + 1]) end
end

---------------------------------------------------------------- 14. ORCHARD PATH (right, mid-near)
do
  -- dirt path through the arch
  local path = poly{ {402, 222}, {432, 222}, {446, 186}, {452, 172}, {420, 172} }
  tex(path, function(x, y) local h = hash(x, y, 71) return h < .1 and BROWNR[4] or (h > .92 and BROWNR[6] or BROWNR[5]) end)
  castShadow(380, 456, 220, 8, 3, .3)
  -- apple trees (autumn: gold-green crowns, red apples)
  local function tree(cx, cy, rx, ry, seed)
    local tr = rect(cx - 2, cy + ry - 6, cx + 2, 220)
    planks(tr, OAK, { w = 2, base = 3, ox = cx }) c:edgeIn(tr, OAK[1])
    local m = HP.mask()
    for y = cy - ry - 2, cy + ry + 2 do for x = cx - rx - 2, cx + rx + 2 do
      local v = 1 - ((x - cx) / rx)^2 - ((y - cy) / ry)^2 + (hash(floor(x / 3), floor(y / 3), seed) - .5) * .5
      if v > 0 then m:set(x, y) end
    end end
    tex(m, function(x, y)
      local cx2, cy2 = floor(x / 5), floor((y + (floor(x / 5) % 2) * 2) / 4)
      local u, v = x - cx2 * 5, (y + (cx2 % 2) * 2) - cy2 * 4
      local L = .6 - (y - cy) / ry * .3 - (x - cx) / rx * .25
      if u + v < 3 then L = L + .2 elseif u + v > 6 then L = L - .2 end
      return R(LEAFG, 1 + floor(max(0, min(.999, L)) * 6))
    end)
    c:edgeIn(m, LEAFG[1])
    for i = 1, 9 do
      local x, y = cx - rx + 2 + floor(hash(i, 1, seed) * (2 * rx - 4)), cy - ry + 3 + floor(hash(i, 2, seed) * (2 * ry - 4))
      if m:has(x, y) and m:has(x + 2, y + 2) then fill(rect(x, y, x + 2, y + 2), REDR[4]) c:put(x, y, REDR[6]) c:put(x + 2, y + 2, REDR[2]) end
    end
  end
  tree(388, 168, 12, 15, 81) tree(446, 166, 11, 15, 82)
  -- big wooden arch gate
  for _, x in ipairs({ 400, 430 }) do
    local p = rect(x, 172, x + 4, 221)
    planks(p, OAK, { w = 5, base = 4, ox = x }) c:edgeIn(p, OAK[1])
    for y = 172, 221 do c:put(x + 1, y, OAK[5]) end
  end
  local arch = c:line(P{ {398, 178}, {404, 166}, {416, 160}, {428, 166}, {436, 178} }, 5)
  tex(arch, function(x, y) if not arch:has(x, y - 1) then return OAK[6] elseif not arch:has(x, y + 1) then return OAK[1] end return OAK[4] end)
  beam(398, 180, 436, 182, OAK)
  -- vine leaves + apples on the arch
  for i, p in ipairs({ { 400, 160 }, { 408, 154 }, { 420, 154 }, { 428, 160 }, { 396, 172 }, { 432, 172 } }) do
    leaf(LEAF, p[1], p[2], (i % 2 == 0) and ORANGE or LEAFG)
  end
  fill(rect(416, 183, 418, 186), REDR[4]) c:put(416, 183, REDR[6])
  -- basket of apples at the foot of the arch
  local bk = poly{ {408, 212}, {424, 212}, {422, 221}, {410, 221} }
  planks(bk, MUST, { w = 2, vert = false, base = 4, ox = 212 }) c:edgeIn(bk, MUST[1])
  for k = 0, 4 do fill(rect(409 + k * 3, 209 + (k % 2), 410 + k * 3, 211), REDR[4]) c:put(409 + k * 3, 209 + (k % 2), REDR[6]) end
end

---------------------------------------------------------------- 15. SUGAR SHACK (near left)
do
  local h = house{ left = true, x0 = 22, x1 = 108, top = 196, base = 258, apex = 168, s = .12, ovh = 4,
    wallR = BARN, wallTex = "planks", pw = 6, roofR = SLATE, rt = 6, rh = 5, rw = 7, sdx = 16, sdy = 8 }
  -- loft window
  window(56, 178, 74, 190, { frame = BARN[1], sill = false })
  -- double barn door with Z braces
  local dm = rect(46, 216, 84, 257)
  fill(rect(45, 215, 85, 257), TIMB[1])
  planks(rect(46, 216, 64, 257), OAK, { w = 4, base = 4, ox = 46 }) planks(rect(66, 216, 84, 257), OAK, { w = 4, base = 3, ox = 66 })
  for _, d in ipairs({ { 46, 64 }, { 66, 84 } }) do
    beam(d[1], 217, d[2], 219, TIMB) beam(d[1], 236, d[2], 238, TIMB) beam(d[1], 254, d[2], 256, TIMB)
    dbeam(d[1] + 1, 235, d[2] - 1, 220, TIMB) dbeam(d[1] + 1, 253, d[2] - 1, 239, TIMB)
  end
  fill(rect(65, 216, 65, 257), TIMB[1])
  fill(rect(62, 236, 63, 240), GOLDL[4]) fill(rect(67, 236, 68, 240), GOLDL[4])
  -- warm crack of light between the doors
  for y = 221, 252 do c:put(65, y, (y % 3 == 0) and "#ffd870" or "#f0a040") end
  -- side window on the shaded wall
  window(112, 214, 117, 224, { frame = BARN[1], sill = false })
  -- chimney on the roof + big steam billows
  local ch = rect(34, 162, 44, 188)
  stones(ch, WSTONE, { bh = 3, bw = 5, base = 4, oy = 162 }) c:edgeIn(ch, WSTONE[1])
  for y = 162, 188 do tint(43, y, SHADE, .3) tint(44, y, SHADE, .3) end
  fill(rect(32, 160, 46, 162), WSTONE[5]) c:edgeIn(rect(32, 160, 46, 162), WSTONE[1])
  puff(40, 153, 7, 4) puff(52, 151, 6, 3)
  -- maple-leaf emblem on the gable
  leaf(LEAF2, 60, 200, MAPLE)
  -- steaming boiler (copper kettle on a brick firebox)
  local fb = rect(86, 244, 112, 257)
  stones(fb, BARN, { bh = 3, bw = 5, base = 3, oy = 244 }) c:edgeIn(fb, BARN[1])
  fill(rect(94, 248, 104, 255), "#3a1c1a") fill(rect(96, 250, 102, 255), "#ffb040") fill(rect(97, 252, 101, 255), "#ffe080")
  local bo = c:rrect(84, 226, 114, 245, 5)
  tex(bo, function(x, y)
    local u, v = (x - 84) / 30, (y - 226) / 19
    if (x - 84) % 8 == 0 and v > .1 then return "#6a2e22" end
    if u < .25 and v < .5 then return "#f4c08a" elseif u > .7 or v > .8 then return "#8a3e26" end
    return "#c0683a"
  end)
  c:edgeIn(bo, "#3a1c1a")
  fill(rect(86, 228, 88, 229), "#fde0b8")
  fill(rect(97, 220, 102, 226), "#a85432") c:edgeIn(rect(97, 220, 102, 226), "#3a1c1a")
  -- pipe from boiler into the shack wall
  local bp = c:line(P{ {84, 232}, {78, 232}, {76, 226} }, 3) fill(bp, "#b8603a")
  puff(100, 211, 7, 4) puff(110, 202, 6, 4) puff(94, 198, 5, 3)
  -- syrup barrels
  barrel(24, 240, 38, 258, OAK, { syrup = true }) barrel(28, 223, 40, 239, OAK, { syrup = true })
  barrel(40, 243, 46, 258, OAK)
  -- syrup buckets on taps (maple sap)
  fill(rect(112, 234, 118, 240), IRON[4]) c:edgeIn(rect(112, 234, 118, 240), IRON[1]) fill(rect(113, 234, 117, 234), SYRUP[4])
end

---------------------------------------------------------------- 16. sign pointing both ways (quirk)
do
  local p = rect(144, 222, 147, 262)
  planks(p, OAK, { w = 4, base = 4, ox = 144 }) c:edgeIn(p, OAK[1])
  castShadow(144, 148, 262, 6, 3, .3)
  local s1 = poly{ {124, 230}, {131, 223}, {160, 223}, {167, 230}, {160, 237}, {131, 237} }
  planks(s1, OAK, { w = 3, vert = false, base = 5, ox = 223 })
  c:edgeIn(s1, OAK[1])
  for x = 132, 159 do c:put(x, 224, OAK[6]) end
  -- painted arrows at both ends (pictograms, no text)
  fill(poly{ {128, 230}, {134, 226}, {134, 234} }, REDR[4]) fill(poly{ {163, 230}, {157, 226}, {157, 234} }, REDR[4])
  fill(rect(134, 229, 157, 231), CREAM[5])
  fill(rect(145, 226, 146, 227), IRON[2])
end

---------------------------------------------------------------- 17. MAPLE STALLS (near right)
do
  castShadow(266, 370, 266, 6, 3, .3)
  -- posts
  for _, x in ipairs({ 266, 365 }) do
    local p = rect(x, 232, x + 3, 266)
    planks(p, OAK, { w = 4, base = 4, ox = x }) c:edgeIn(p, OAK[1]) for y = 232, 266 do c:put(x + 1, y, OAK[5]) end
  end
  -- back wall shade under the awning
  fill(rect(270, 236, 364, 251), OAK[2])
  for x = 270, 364, 6 do for y = 236, 251 do c:put(x, y, OAK[1]) end end
  -- goods on the counter: syrup tins, jars, pumpkins
  for i = 0, 6 do
    local x = 273 + i * 8 local y0 = 241 + (i % 2)
    local tn = rect(x, y0, x + 5, 251)
    tex(tn, function(px, py) local u = px - x return (py > y0 + 2 and py < y0 + 6) and (u < 2 and MAPLE[5] or MAPLE[3]) or (u < 2 and IRON[6] or (u < 4 and IRON[5] or IRON[3])) end)
    c:edgeIn(tn, IRON[1]) fill(rect(x + 1, y0 - 1, x + 4, y0 - 1), IRON[2])
    leaf(LEAF, x - 1, y0 + 1, GOLDL, { rim = false })
    fill(rect(x, y0 + 2, x + 5, y0 + 2), MAPLE[4]) fill(rect(x, y0 + 6, x + 5, y0 + 6), MAPLE[2])
  end
  for i = 0, 1 do
    local x = 330 + i * 7
    local j = c:rrect(x, 242, x + 5, 251, 1)
    tex(j, function(px, py) return py < 244 and CREAM[5] or ((px == x + 1) and SYRUP[6] or SYRUP[4]) end)
    c:edgeIn(j, SYRUP[1])
  end
  pumpkin(346, 241, 362, 251, { hat = true })
  -- counter
  local ct = rect(268, 251, 367, 266)
  planks(ct, OAK, { w = 4, vert = false, base = 4, ox = 251 })
  fill(rect(266, 251, 369, 253), OAK[5]) for x = 266, 369 do c:put(x, 253, OAK[2]) end
  c:edgeIn(ct, OAK[1])
  fill(rect(280, 256, 354, 263), REDR[4]) c:edgeIn(rect(280, 256, 354, 263), REDR[1])
  for k = 0, 5 do leaf(LEAF, 283 + k * 12, 256, (k % 2 == 0) and GOLDL or CREAM, { rim = false }) end
  -- pumpkins at the stall foot
  pumpkin(270, 258, 280, 266) pumpkin(353, 257, 364, 266)
  -- striped awning with scallops
  local aw = poly{ {262, 236}, {372, 236}, {366, 220}, {268, 220} }
  tex(aw, function(x, y)
    local s = floor((x - 240 - (x - 317) * (236 - y) / 100) / 9) % 2 == 0
    local lit = y < 226
    if s then return lit and REDR[5] or REDR[4] end
    return lit and CREAM[6] or CREAM[5]
  end)
  for x = 262, 372 do
    local s = floor((x - 240) / 9) % 2 == 0
    local k = (x - 262) % 9
    local d = (k >= 1 and k <= 7) and ((k >= 2 and k <= 6) and 3 or 2) or 0
    for y = 237, 236 + d do c:put(x, y, s and REDR[3] or CREAM[4]) end
    c:put(x, 237 + d, REDR[1])
  end
  for x = 268, 366 do c:put(x, 220, REDR[6]) end
  c:edgeIn(aw, REDR[1])
  -- shadow under the awning onto the goods
  for y = 238, 240 do for x = 270, 364 do tint(x, y, SHADE, .3) end end
  -- awning finial leaves
  leaf(LEAF, 314, 212, MAPLE)
end

---------------------------------------------------------------- 18. mitten-and-leaf bunting (quirk)
local function bunting(xa, ya, xb, yb, sag, seed)
  local n = floor((xb - xa) / 13)
  local function yat(t) return ya + (yb - ya) * t + sag * 4 * t * (1 - t) end
  local prev
  for x = xa, xb do local t = (x - xa) / (xb - xa) local y = floor(yat(t) + .5)
    c:put(x, y, "#4a3030") if prev and abs(prev - y) > 1 then for yy = min(prev, y), max(prev, y) do c:put(x, yy, "#4a3030") end end prev = y end
  local cols = { REDR, ORANGE, GOLDL, TEAL, MAPLE, SBLUE }
  for i = 1, n - 1 do
    local t = i / n local fx = floor(xa + (xb - xa) * t) local fy = floor(yat(t) + .5)
    local r = cols[(i + seed) % #cols + 1]
    if i % 2 == 0 then
      leaf(LEAF2, fx - 5, fy + 1, (i % 4 == 0) and MAPLE or GOLDL, { flip = true })
    else
      -- knitted mitten: cuff at the top, thumb out to the side
      local m = rect(fx - 4, fy + 1, fx + 3, fy + 12):cut(rect(fx - 4, fy + 12, fx - 4, fy + 12)):cut(rect(fx + 3, fy + 12, fx + 3, fy + 12))
      m:add(rect(fx + 4, fy + 6, fx + 5, fy + 9))
      fill(m:grow(1):cut(m), R(r, 1))
      tex(m, function(x, y)
        if y <= fy + 3 then return ((x + y) % 2 == 0) and CREAM[6] or CREAM[5] end
        if y == fy + 7 then return CREAM[5] end
        return (x < fx) and R(r, 5) or R(r, 4)
      end)
      c:put(fx - 3, fy + 5, R(r, 6))
    end
  end
end
bunting(40, 14, 196, 22, 16, 0)
bunting(284, 22, 440, 14, 16, 3)

---------------------------------------------------------------- 19. gate frame (timber + stone), foliage, lanterns
do
  -- stone pillars
  local lp, rp = rect(0, 0, 17, 269), rect(462, 0, 479, 269)
  stones(lp, STONE, { bh = 7, bw = 12, base = 4 }) stones(rp, STONE, { bh = 7, bw = 12, base = 4, ox = 2 })
  for y = 0, 269 do
    for x = 13, 17 do tint(x, y, SHADE, .32) end
    for x = 462, 465 do tint(x, y, "#ffe0a0", .15) end
    for x = 474, 479 do tint(x, y, SHADE, .2) end
    c:put(17, y, STONE[1]) c:put(462, y, STONE[1])
  end
  stones(rect(0, 252, 20, 269), STONE, { bh = 6, bw = 10, base = 5, oy = 252 }) c:edgeIn(rect(0, 252, 20, 269), STONE[1])
  stones(rect(459, 252, 479, 269), STONE, { bh = 6, bw = 10, base = 4, oy = 252 }) c:edgeIn(rect(459, 252, 479, 269), STONE[1])
  -- top beam
  local tb = rect(0, 0, 479, 11)
  planks(tb, TIMB, { vert = false, w = 4, base = 4, ox = 0 })
  for x = 0, 479 do c:put(x, 11, TIMB[1]) c:put(x, 10, TIMB[2]) c:put(x, 0, TIMB[5]) end
  for x = 30, 460, 60 do fill(rect(x, 4, x + 2, 6), IRON[3]) c:put(x, 4, IRON[5]) end
  -- knee braces
  for _, b in ipairs({ { 18, 38, 40, 12 }, { 461, 38, 439, 12 } }) do
    local m = c:line(P{ {b[1], b[2]}, {b[3], b[4]} }, 5)
    tex(m, function(x, y) if not m:has(x, y - 1) then return TIMB[5] elseif not m:has(x, y + 1) then return TIMB[1] end return TIMB[3] end)
    c:edgeIn(m, TIMB[1])
  end
  -- carved maple plaque in the middle of the beam
  local pq = c:rrect(226, 0, 254, 14, 3)
  planks(pq, OAK, { w = 3, vert = false, base = 5, ox = 0 }) c:edgeIn(pq, OAK[1])
  leaf(LEAF2, 235, 2, MAPLE)
  -- foliage spilling over both corners (drawn over the beam so it stays visible)
  local function cluster(x0, x1, y0, y1, n, seed, droop)
    for i = 1, n do
      local u = hash(i, 1, seed) local x = floor(x0 + (x1 - x0) * u)
      local yl = y1 - floor((y1 - y0) * (droop and u or (1 - u)))
      local y = y0 + floor(hash(i, 2, seed) * max(1, yl - y0))
      local r = ({ MAPLE, ORANGE, GOLDL, MAPLE, REDR })[1 + floor(hash(i, 3, seed) * 5)]
      if hash(i, 4, seed) < .6 then leaf(LEAF2, x, y, r) else leaf(LEAF, x, y, r) end
    end
  end
  cluster(-4, 74, -4, 30, 34, 91, false) cluster(-4, 30, 20, 52, 10, 92, false)
  cluster(406, 482, -4, 30, 34, 93, true) cluster(452, 482, 20, 52, 10, 94, true)
  cluster(140, 180, -3, 8, 6, 95, false) cluster(300, 340, -3, 8, 6, 96, true)
  -- hanging vines with leaves
  for _, v in ipairs({ { 24, 12, 58 }, { 70, 12, 30 }, { 455, 12, 58 }, { 410, 12, 30 } }) do
    for y = v[2], v[3] do c:put(v[1] + floor(sin(y / 4) * 1.5), y, LEAFG[2]) end
    for y = v[2] + 6, v[3] - 4, 8 do leaf(LEAF, v[1] - 3 + ((y / 8) % 2 == 0 and -2 or 2), y, ({ MAPLE, ORANGE, GOLDL })[(y % 3) + 1]) end
  end
  -- lanterns
  for _, lx in ipairs({ 40, 440 }) do
    for y = 12, 19 do c:put(lx, y, (y % 2 == 0) and IRON[4] or IRON[2]) end
    local capm = poly{ {lx - 6, 24}, {lx - 3, 20}, {lx + 4, 20}, {lx + 7, 24} }
    fill(capm, IRON[3]) c:edgeIn(capm, IRON[1]) for x = lx - 3, lx + 3 do c:put(x, 20, IRON[5]) end
    local body = rect(lx - 5, 25, lx + 5, 38)
    tex(body, function(x, y) local t = (y - 25) / 13 return t < .35 and "#fff0b0" or (t < .7 and "#ffd06a" or "#f4a040") end)
    for y = 25, 38 do c:put(lx - 5, y, IRON[2]) c:put(lx + 5, y, IRON[1]) c:put(lx, y, IRON[2]) end
    fill(rect(lx - 6, 39, lx + 6, 41), IRON[3]) c:edgeIn(rect(lx - 6, 39, lx + 6, 41), IRON[1])
    c:put(lx - 3, 27, "#fff8e0") c:put(lx - 3, 28, "#fff8e0")
    fill(rect(lx - 1, 42, lx + 1, 43), IRON[2])
  end
end

---------------------------------------------------------------- 20. light: glows + falling leaves
glow(40, 32, 30, "#ffd890", .38) glow(440, 32, 30, "#ffd890", .38)
glow(422, 115, 16, "#ffd890", .3) glow(220, 113, 12, "#ffd890", .25) glow(260, 113, 12, "#ffd890", .25)
glow(240, 118, 22, "#ffe0a0", .22) glow(99, 252, 18, "#ffb860", .28)
glow(45, 126, 26, "#ffd890", .16)
for i = 1, 26 do
  local x, y = 30 + floor(hash(i, 1, 101) * 420), 40 + floor(hash(i, 2, 101) * 160)
  local r = ({ MAPLE, ORANGE, GOLDL })[1 + floor(hash(i, 3, 101) * 3)]
  if not nearStand(x, y, 8) then
    if hash(i, 4, 101) < .4 then leaf(LEAF, x, y, r) else c:put(x, y, R(r, 5)) c:put(x + 1, y, R(r, 4)) c:put(x + 1, y + 1, R(r, 2)) end
  end
end

---------------------------------------------------------------- finish, check, save
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local function jstr(s) return '"' .. s .. '"' end
local parts = {}
for _, s in ipairs(SPOTS) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":%s,"name":%s,"x":%d,"y":%d,"box":[%d,%d,%d,%d]}',
    jstr(s.k), jstr(s.name), floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, s in ipairs(STANDS) do st[#st + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local json = string.format('{"w":%d,"h":%d,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}',
  W, H, VY, table.concat(parts, ","), table.concat(st, ","))
local f = io.open(OUT .. NAME .. ".layout.json", "w") f:write(json) f:close()
print("saved " .. NAME)

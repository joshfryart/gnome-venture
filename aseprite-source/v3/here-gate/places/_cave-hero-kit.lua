-- _cave-hero-kit.lua : shared hero-scale gate view for here-delve and here-lair (480x270 native).
-- Built from the Maplewold v5 helpers. Caller sets KIT_VARIANT ("delve" | "lair") and KIT_NAME, then dofile()s this.
-- Layout JSON is NOT written here: the existing places/<name>.layout.json is the contract and stays unchanged.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/here-gate/places/")
local NAME = KIT_NAME
local V = KIT_VARIANT
local LAIR = (V == "lair")
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

---------------------------------------------------------------- extra ramps (dark -> light)
local ROCK   = {"#231b33","#372a48","#4d3f5e","#685674","#86748c","#a694a4"}
local BAS    = {"#1a1424","#2a2036","#3c3048","#54445c","#6e5e72","#8c7c88"}
local MOSS   = {"#1c2e2a","#2a4634","#3c6040","#56804a","#7aa05a","#a4c070"}
local MEAD   = {"#3a3a2c","#4e5232","#686c3a","#868842","#a4a250","#c2ba66"}
local DGR    = {"#3a2a2a","#56402e","#745834","#90703c","#ac8a4a","#c4a462"}
local GRAV   = {"#3e3440","#5a4e58","#766a70","#948688","#b0a29e","#cabeb4"}
local INR    = {"#1c1626","#30223a","#4a2e3e","#6e403e","#9a5c42","#c8864a"}
local INF    = {"#221a20","#3a2a26","#5a3e2c","#80582e","#aa7838","#d8a050"}
local EMBER  = {"#2e0c16","#5a1618","#922a1c","#c84c1e","#ec7e2a","#ffbc58"}
local AMETH  = {"#2e1a4a","#4a2a6e","#6a3e94","#8e5cb4","#b282d0","#d6b0ea"}
local BONE   = {"#4a3a3a","#76645a","#a08c78","#c4b29a","#dccfb6","#efe6d0"}
local BIRCH  = {"#3a3440","#5e5662","#8c8488","#b8b0aa","#d8d0c4","#eee8dc"}
local PINE   = {"#16262c","#203a36","#2c503e","#3e6a46","#5a8852","#7ea866"}
local SACK   = {"#4a3a30","#6e5640","#927452","#b49668","#d0b482","#e6d0a0"}
local GROUND = LAIR and DGR or MEAD
local RK = LAIR and BAS or ROCK

local STANDS
if LAIR then STANDS = { {200,205}, {285,205}, {240,178}, {240,245}, {140,248}, {340,248} }
else STANDS = { {178,178}, {302,178}, {150,214}, {330,214}, {165,252}, {325,252} } end
local function nearStand(x, y, pad)
  for _, s in ipairs(STANDS) do if abs(x - s[1]) <= 15 + (pad or 0) and abs(y - s[2]) <= 6 + (pad or 0) then return true end end
  return false
end
local function inCompass(x, y) return x >= 378 and y >= 228 end
local function outl(m, col) c:rim(m, col or "#2b1c26") end
local INK = "#2b1c26"

---------------------------------------------------------------- chunky rock texture (cells, lit upper-left)
local function rockTex(m, r, o)
  o = o or {}
  local cw, ch, s, base = o.cw or 16, o.ch or 11, o.seed or 1, o.base or 4
  local cache = {}
  local function pt(i, j)
    local k = i * 4096 + j
    local p = cache[k]
    if not p then p = { (i + .2 + hash(i, j, s) * .6) * cw, (j + .2 + hash(i, j, s + 1) * .6) * ch } cache[k] = p end
    return p
  end
  tex(m, function(x, y)
    local gi, gj = floor(x / cw), floor(y / ch)
    local d1, d2, bi, bj, bp = 1e9, 1e9, 0, 0, nil
    for j = gj - 1, gj + 1 do for i = gi - 1, gi + 1 do
      local p = pt(i, j) local d = ((x - p[1]) / cw)^2 + ((y - p[2]) / ch)^2
      if d < d1 then d2 = d1 d1 = d bi, bj, bp = i, j, p elseif d < d2 then d2 = d end
    end end
    local gap = sqrt(d2) - sqrt(d1)
    local L = base + (o.light and o.light(x, y) or 0)
    if gap < .06 then return R(r, L - 2) end
    L = L + (hash(bi, bj, s + 2) < .3 and -1 or 0)
    local dx, dy = (x - bp[1]) / cw, (y - bp[2]) / ch
    local lit = -(dx + dy * 1.25)
    if lit > .2 then L = L + 1 elseif lit < -.25 then L = L - 1 end
    if gap < .14 and lit < 0 then L = L - 1 end
    if hash(x, y, s + 3) < .02 then L = L + 1 end
    return R(r, L)
  end)
end

---------------------------------------------------------------- 1. sky (golden hour)
local SKY = { {0,"#4a4a8a"}, {20,"#6a5a9c"}, {40,"#9a68a2"}, {58,"#cc7a96"}, {74,"#f09878"}, {90,"#fdb46a"}, {104,"#ffd27e"}, {112,"#ffe4a0"} }
if LAIR then SKY = { {0,"#463e7c"}, {20,"#644c8e"}, {40,"#94588e"}, {58,"#c4687e"}, {74,"#e88466"}, {90,"#f8a05a"}, {104,"#ffc06c"}, {112,"#ffd890"} } end
for y = 0, VY do
  local yy = floor(y / 4) * 4
  local col = SKY[1][2]
  for i = 1, #SKY - 1 do
    local a, b = SKY[i], SKY[i + 1]
    if yy >= a[1] and yy <= b[1] then col = mix(a[2], b[2], (yy - a[1]) / (b[1] - a[1])) end
  end
  for x = 0, W - 1 do
    local cc = col
    if (x + y) % 2 == 0 and y % 4 == 3 then cc = mix(col, SKY[min(#SKY, 1 + floor(y / 14) + 1)][2], .5) end
    c:put(x, y, cc)
  end
end
-- low sun halo, left of centre (key light upper left)
for y = 20, VY do for x = 0, 300 do
  local d = sqrt(((x - 110) / 140)^2 + ((y - 92) / 60)^2)
  if d < 1 then tint(x, y, "#fff0b8", .45 * floor((1 - d) * 4 + .999) / 4) end
end end
local function cloud(x, y, w, seed)
  local m = HP.mask()
  m:add(c:rrect(x, y - floor(w * .14), x + w, y, 3))
  for i = 1, 4 do
    local cx = x + floor(w * (i - .5) / 4)
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
end
cloud(30, 46, 64, 1) cloud(110, 28, 44, 3) cloud(338, 40, 70, 4) cloud(410, 62, 48, 5) cloud(70, 74, 40, 6)
if LAIR then -- a few birds-free smoke streaks, high and thin
  for i = 0, 60 do c:put(300 + i, 20 + floor(i / 12), "#a48aa8") c:put(150 + i, 30 + floor(i / 15), "#b494a8") end
end

---------------------------------------------------------------- 2. far hills (cool, hazy)
local function hills(f, colTop, colBot, seed, treeAmp)
  for x = 0, W - 1 do
    local top = floor(f(x) + .5)
    for y = top, VY do
      local t = (y - top) / max(1, VY - top)
      local col = mix(colTop, colBot, t)
      if treeAmp and hash(floor(x / 4), floor(y / 3), seed) < .25 then col = mix(col, colBot, .5) end
      if y == top then col = mix(col, "#ffe8b8", .45) end
      c:put(x, y, col)
    end
  end
end
hills(function(x) return 70 + 8 * sin(x / 43 + 1) + 4 * sin(x / 15) end, "#c4a0c4", "#d2b2c0", 1)
hills(function(x) return 84 + 6 * sin(x / 31 + 2) + 3 * sin(x / 9) - 2 * abs(sin(x / 3.1)) end, "#9a7ca8", "#b090ac", 2, true)
hills(function(x) return 98 + 4 * sin(x / 19 + 4) - 3 * abs(sin(x / 3.7)) - 2 * abs(sin(x / 2.3)) end,
  LAIR and "#7a5a7c" or "#6e7a8c", LAIR and "#94707c" or "#8a8c90", 3, true)
-- far pine silhouettes on the last ridge
for i = 1, 46 do
  local x = floor(hash(i, 1, 5) * W)
  local top = 98 + 4 * sin(x / 19 + 4)
  local h = 5 + floor(hash(i, 2, 5) * 7)
  local col = LAIR and "#5e4664" or "#4e5e74"
  for k = 0, h do
    local w = floor(k / 3)
    for xx = x - w, x + w do c:put(xx, floor(top) - h + k, col) end
  end
end

---------------------------------------------------------------- 3. ground
for y = VY + 1, H - 1 do for x = 0, W - 1 do
  local depth = (y - VY) / (H - VY)
  local i = 3 + (depth > .5 and 1 or 0)
  local h = hash(x, floor(y / 2), 21)
  if h < .1 then i = i - 1 elseif h > .93 then i = i + 1 end
  if hash(floor(x / 11), floor(y / 6), 22) < .22 then i = i - 1 end
  if hash(floor(x / 17), floor(y / 7), 24) > .84 then i = i + 1 end
  local col = R(GROUND, i)
  if y < 140 then col = mix(col, "#d8b0a0", (140 - y) / 28 * .4) end
  c:put(x, y, col)
end end

---------------------------------------------------------------- 4. cliff mass (mid layer, cool violet stone)
local function cliffTop(x)
  local k = (x > 240) and 1.32 or 1.08
  local t = 22 + ((x - 240) * k / 185)^2 * 72 + 5 * sin(x / 13 + 1) + 3 * sin(x / 5.3)
  if LAIR then
    t = 30 + ((x - 240) * k / 180)^2 * 66 + 5 * sin(x / 11) + 3 * abs(sin(x / 4.3)) * 2
    t = t - 30 * max(0, 1 - abs(x - 146) / 15) - 34 * max(0, 1 - abs(x - 334) / 13)
  end
  return t
end
local CB = 154
local cliff = HP.mask()
local TOP = {}
for x = 0, W - 1 do
  local t = floor(cliffTop(x) + .5)
  TOP[x] = t
  local b = CB + floor(2 * sin(x / 9))
  if t < b then for y = max(0, t), b do cliff:set(x, y) end end
end
rockTex(cliff, RK, { cw = 22, ch = 14, seed = 3, base = 4, light = function(x, y)
  local l = 0
  if x > 250 then l = l - 1 end
  if x < 120 then l = l + 1 end
  if y > CB - 10 then l = l - 1 end
  return l
end })
-- warm sun on the upper-left faces, cool violet shade lower right
cliff:each(function(x, y)
  if y < TOP[x] + 10 and x < 240 then tint(x, y, "#ffd09a", .22) end
  if x > 300 or y > 140 then tint(x, y, SHADE, .18) end
end)
-- strata lines (2-3 deliberate breaks)
for _, s in ipairs({ { 30, 200, 128, 1 }, { 300, 440, 132, 2 }, { 60, 170, 104, 3 } }) do
  for x = s[1], s[2] do
    local y = s[3] + floor(3 * sin(x / 17 + s[4]))
    if cliff:has(x, y) and hash(x, 1, s[4]) > .12 then c:put(x, y, R(RK, 1)) c:put(x, y - 1, R(RK, 5)) end
  end
end
-- moss / lichen cap along the ridge, drips on the north (top) faces
for x = 0, W - 1 do
  local t = TOP[x]
  if t < CB then
    local d = 3 + floor(hash(x, 2, 7) * 3)
    if hash(floor(x / 5), 3, 7) < .25 then d = d + 4 + floor(hash(x, 4, 7) * 6) end
    for y = t, t + d do
      local i = (y == t) and 6 or ((y < t + 2) and 5 or 4)
      if y == t + d then i = 2 elseif hash(x, y, 8) < .2 then i = i - 1 end
      if LAIR then c:put(x, y, R(MOSS, max(1, i - 2))) else c:put(x, y, R(MOSS, i)) end
    end
  end
end
-- ridge flora: pines and round shrubs (silhouettes, mid layer)
local function pine(cx, by, h, r, seed)
  local m = HP.mask()
  local n = max(2, floor(h / 7))
  for i = 0, n - 1 do
    local ly = by - floor(h * i / n)
    local w = floor(h * .34 * (1 - i / (n + .5))) + 2
    m:add(poly{ {cx, ly - floor(h / n) - 4}, {cx + w, ly}, {cx - w, ly} })
  end
  fill(rect(cx - 1, by, cx + 1, by + 3), OAK[2])
  tex(m, function(x, y)
    local i = (x <= cx) and 4 or 3
    if hash(x, y, seed) < .15 then i = i - 1 end
    if (y % 4 == 0) and x < cx and hash(x, y, seed + 1) < .5 then i = i + 1 end
    return R(r, i)
  end)
  c:edgeIn(m, R(r, 1))
  return m
end
local function shrub(cx, cy, rx, ry, r, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  m:add(c:ellipse(cx - floor(rx * .6), cy + 1, floor(rx * .6), floor(ry * .7)))
  m:add(c:ellipse(cx + floor(rx * .6), cy + 2, floor(rx * .55), floor(ry * .65)))
  tex(m, function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    local i = 4
    if u + v < -.5 then i = 5 elseif u + v > .6 then i = 2 elseif u + v > .1 then i = 3 end
    if hash(floor(x / 2), floor(y / 2), seed) < .18 then i = i - 1 end
    if hash(x, y, seed + 1) < .04 then i = 6 end
    return R(r, i)
  end)
  c:edgeIn(m, R(r, 1))
  return m
end
if not LAIR then
  for _, p in ipairs({ {96, 0, 22}, {118, 0, 16}, {362, 0, 24}, {346, 0, 15}, {150, 0, 14}, {58, 0, 18} }) do
    pine(p[1], TOP[p[1]] + 3, p[3], PINE, p[1])
  end
  for _, p in ipairs({ {136, 6, 4}, {200, 7, 4}, {286, 8, 4}, {330, 6, 4}, {76, 6, 4} }) do shrub(p[1], TOP[p[1]] + 1, p[2], p[3], MOSS, p[1]) end
else
  -- dead snags on the lair ridge
  for _, p in ipairs({ {104, 20}, {196, 14}, {300, 16}, {380, 18} }) do
    local bx, by = p[1], TOP[p[1]] + 2
    local m = c:line(P{ {bx, by}, {bx + 1, by - p[2]} }, 2)
    m:add(c:line(P{ {bx, by - floor(p[2] * .5)}, {bx - 6, by - p[2] + 2} }, 1))
    m:add(c:line(P{ {bx + 1, by - floor(p[2] * .7)}, {bx + 6, by - p[2] - 1} }, 1))
    fill(m, "#3a2a34")
  end
end

---------------------------------------------------------------- 5. the mouth
local OX0, OX1, OY0, OY1 = 198, 282, 60, 152
if LAIR then OX0, OX1, OY0, OY1 = 192, 288, 54, 152 end
-- opening mask
local open
if LAIR then
  open = poly{ {188,153}, {182,122}, {186,94}, {196,72}, {212,56}, {240,48}, {268,56}, {284,70}, {296,94}, {300,122}, {294,153} }
else
  open = poly{ {198,153}, {198,68}, {206,60}, {274,60}, {282,68}, {282,153} }
end

-- carved stone surround
if not LAIR then
  local outer = c:ellipse(240, 106, 76, 80):clip(rect(0, 0, W - 1, 156))
  local inner = c:ellipse(240, 106, 61, 65)
  local ring = outer:copy():cut(inner)
  tex(ring, function(x, y)
    local a = math.atan(y - 106, x - 240)
    local seg = (a + PI) / (PI / 13)
    local k = floor(seg) local f = seg - k
    local rr = sqrt(((x - 240) / 76)^2 + ((y - 106) / 80)^2)
    if f < .08 then return WSTONE[1] end
    if rr > .985 then return WSTONE[2] end
    local i = 4 + (hash(k, 0, 51) < .35 and -1 or 0)
    if x < 240 then i = i + 1 end
    if rr < .84 then i = i - 1 end
    if f < .22 and rr > .9 then i = i + 1 end
    if hash(x, y, 52) < .03 then i = i - 1 end
    return R(WSTONE, i)
  end)
  outl(ring)
  -- keystone with a crystal
  local ks = poly{ {228, 22}, {252, 22}, {248, 44}, {232, 44} }
  stones(ks, WSTONE, { bh = 30, bw = 40, base = 5 }) outl(ks)
  local cr = poly{ {240, 25}, {245, 32}, {240, 41}, {235, 32} }
  tex(cr, function(x, y) if x < 240 then return y < 32 and TEAL[6] or TEAL[5] end return y < 33 and TEAL[4] or TEAL[3] end)
  c:edgeIn(cr, TEAL[1]) c:put(238, 29, "#f0fff4")
  -- recess between arch and timbers: deep cool shadow rock
  local rec = inner:copy():clip(rect(0, 0, W - 1, 156)):cut(open)
  rockTex(rec, ROCK, { cw = 9, ch = 7, seed = 61, base = 2 })
  rec:each(function(x, y) if y < 70 then tint(x, y, SHADE, .3) end end)
else
  -- rough basalt jaw: big teeth-like blocks around the maw, ember-lit inner edge
  local outer = poly{ {164,155}, {160,118}, {166,86}, {180,60}, {204,40}, {240,30}, {276,40}, {300,58}, {314,86}, {320,118}, {316,155} }
  local ring = outer:copy():cut(open)
  rockTex(ring, BAS, { cw = 12, ch = 10, seed = 71, base = 4, light = function(x, y) return (x < 236) and 1 or 0 end })
  outl(outer)
  -- ember rim light on the jaw edge
  open:grow(2):cut(open):each(function(x, y) if ring:has(x, y) then tint(x, y, EMBER[5], .45) end end)
  -- claw scratches on the jaw
  for _, s in ipairs({ {170, 96}, {304, 100} }) do
    for k = 0, 2 do
      for t = 0, 14 do c:put(s[1] + k * 4 + floor(t * .35), s[2] + t, BAS[1]) c:put(s[1] + k * 4 + floor(t * .35) + 1, s[2] + t, BAS[6]) end
    end
  end
  -- carved horned brow over the maw
  for _, sgn in ipairs({ -1, 1 }) do
    local hm = poly{ {240 + sgn * 20, 36}, {240 + sgn * 44, 22}, {240 + sgn * 64, 8}, {240 + sgn * 54, 24}, {240 + sgn * 34, 42} }
    tex(hm, function(x, y) local i = 5 - floor(abs(x - 240) / 18) if sgn > 0 then i = i - 1 end return R(BONE, i) end)
    outl(hm)
    for k = 0, 3 do local x = 240 + sgn * (30 + k * 8) c:put(x, 30 - k * 3, BONE[2]) c:put(x, 31 - k * 3, BONE[2]) end
  end
end

-- tunnel interior: one-point perspective toward (VX,VY)
local SB = LAIR and .74 or .8
local function depthAt(x, y)
  local sl = (x - OX0) / (VX - OX0) local sr = (OX1 - x) / (OX1 - VX)
  local st = (y - OY0) / (VY - OY0) local sb = (OY1 - y) / (OY1 - VY)
  local s, w = sl, "l"
  if sr < s then s, w = sr, "r" end
  if st < s then s, w = st, "t" end
  if sb < s then s, w = sb, "b" end
  return s, w
end
tex(open, function(x, y)
  local s, w = depthAt(x, y)
  if s >= SB then
    local d = sqrt(((x - VX) / 9)^2 + ((y - (VY + 2)) / 7)^2)
    if LAIR then return d < .6 and "#ffe6a0" or (d < 1.1 and GOLDL[5] or EMBER[6]) end
    return d < .6 and "#fff3c8" or (d < 1.1 and "#ffe4a0" or "#ffd27a")
  end
  local r = LAIR and EMBER or ((w == "b") and INF or INR)
  if LAIR and w == "b" then r = INF end
  local L = 1 + floor(max(0, s) * 6.2)
  if w == "t" then L = L - 1 end
  if w == "r" then L = L - 1 end
  if hash(floor(x / 3), floor(y / 3), 81) < .14 then L = L - 1 end
  if w == "b" and (floor(y) % 3 == 0) and hash(x, y, 82) < .3 then L = L - 1 end
  if hash(x, y, 83) < .02 then L = L + 1 end
  return R(r, L)
end)

if not LAIR then
  -- timber rings receding into the glow, each with a tiny lantern
  for _, sr in ipairs({ .64, .48, .32, .16 }) do
    local xa, xb = floor(OX0 + (VX - OX0) * sr + .5), floor(OX1 - (OX1 - VX) * sr + .5)
    local ya, yb = floor(OY0 + (VY - OY0) * sr + .5), floor(OY1 - (OY1 - VY) * sr + .5)
    local b = max(1, floor(8 * (1 - sr) + .5))
    local fr = rect(xa, ya, xb, yb):cut(rect(xa + b, ya + b, xb - b, yb))
    local lit = floor(1 + sr * 4)
    tex(fr, function(x, y)
      local i = lit + 1
      if x < xa + b and x == xa + b - 1 then i = i + 1 end
      if x > xb - b and x == xb - b + 1 then i = i + 1 end
      if y <= ya + b and y == ya + b then i = i + 1 end
      if b > 3 and hash(x, floor(y / 4), 85) < .1 then i = i - 1 end
      return R(TIMB, i)
    end)
    c:edgeIn(fr, R(TIMB, max(1, lit - 1)))
    local ls = max(2, floor(6 * (1 - sr)))
    local ly = ya + b + 1
    for y = ly, ly + floor(ls / 2) do c:put(VX, y, IRON[2]) end
    local lb = rect(VX - floor(ls / 2), ly + floor(ls / 2) + 1, VX + floor(ls / 2), ly + floor(ls / 2) + ls)
    fill(lb, "#ffe08a") c:put(VX - floor(ls / 2), ly + floor(ls / 2) + 1, "#fff6d0")
    outl(lb, IRON[1])
    glow(VX, ly + ls, 6 + floor(10 * (1 - sr)), "#ffd27a", .3)
  end
else
  -- stalactite fangs at two depths across the maw (depth layering), and a gold hoard glinting at the back
  for _, sr in ipairs({ .55, .3 }) do
    local ya = floor(OY0 + (VY - OY0) * sr + .5)
    local xa, xb = floor(OX0 + (VX - OX0) * sr), floor(OX1 - (OX1 - VX) * sr)
    local n = sr > .5 and 5 or 7
    for k = 0, n - 1 do
      local fx = xa + 4 + floor((xb - xa - 8) * (k + .5) / n)
      local fl = floor((6 + hash(k, 1, sr * 10) * 10) * (1 - sr))
      local fw = max(1, floor(4 * (1 - sr)))
      local fm = poly{ {fx - fw, ya - 2}, {fx + fw, ya - 2}, {fx, ya + fl} }
      fill(fm, sr > .5 and EMBER[2] or BAS[2])
      c:put(fx - 1, ya, sr > .5 and EMBER[4] or EMBER[3])
    end
  end
  local hoard = c:ellipse(VX, 121, 22, 6):clip(rect(0, 112, W - 1, 125))
  tex(hoard, function(x, y)
    local i = 5 - floor((y - 115) / 3)
    if hash(x, y, 91) < .25 then i = i + 1 elseif hash(x, y, 92) < .2 then i = i - 1 end
    return R(GOLDL, i)
  end)
  for i = 1, 12 do local x, y = VX - 18 + floor(hash(i, 1, 93) * 36), 114 + floor(hash(i, 2, 93) * 8) if hoard:has(x, y) then c:put(x, y, "#fff6d0") end end
  -- a chest silhouette on the hoard
  local ch = rect(VX - 5, 110, VX + 5, 116) fill(ch, EMBER[2]) fill(rect(VX - 5, 110, VX + 5, 111), GOLDL[4]) c:put(VX, 113, GOLDL[6])
  -- the raised portcullis (spikes down) inside the top of the maw
  local pc = rect(200, 60, 280, 66):clip(open)
  tex(pc, function(x, y) if (x - 200) % 6 == 0 then return IRON[4] end if y == 63 then return IRON[3] end return IRON[1] end)
  for x = 203, 278, 6 do if open:has(x, 70) then
    local sp = poly{ {x - 2, 66}, {x + 2, 66}, {x, 72} } fill(sp, IRON[3]) c:put(x - 1, 67, IRON[5])
  end end
  -- fangs on the rim (top) and tusks (bottom corners)
  for _, f in ipairs({ {206, 62, 8}, {222, 52, 11}, {258, 52, 11}, {274, 62, 8} }) do
    local fm = poly{ {f[1] - 4, f[2] - 2}, {f[1] + 4, f[2] - 2}, {f[1] + 1, f[2] + f[3]} }
    tex(fm, function(x, y) return (x < f[1]) and BONE[5] or BONE[3] end) outl(fm)
  end
  for _, f in ipairs({ {194, 152, 1}, {286, 152, -1} }) do
    local fm = poly{ {f[1] - 5, f[2]}, {f[1] + 5, f[2]}, {f[1] + f[3] * 4, f[2] - 18} }
    tex(fm, function(x, y) return (x < f[1]) and BONE[5] or BONE[3] end) outl(fm)
  end
end

-- mine timber frame (delve) / stone gateposts with chains (lair)
if not LAIR then
  for _, p in ipairs({ {186, 197}, {283, 294} }) do
    local pm = rect(p[1], 52, p[2], 156)
    planks(pm, TIMB, { w = 4, base = 4, ox = p[1], seed = p[1] })
    for y = 52, 156 do c:put(p[1], y, TIMB[5]) c:put(p[1] + 1, y, TIMB[5]) c:put(p[2], y, TIMB[1]) end
    outl(pm)
    for _, yy in ipairs({ 76, 128 }) do
      fill(rect(p[1], yy, p[2], yy + 2), IRON[3]) for x = p[1], p[2] do c:put(x, yy, IRON[5]) end
      c:put(p[1] + 3, yy + 1, IRON[6]) c:put(p[2] - 3, yy + 1, IRON[6])
    end
  end
  -- knee braces
  for _, b in ipairs({ { 198, 82, 214, 59 }, { 282, 82, 266, 59 } }) do
    local m = c:line(P{ {b[1], b[2]}, {b[3], b[4]} }, 5)
    tex(m, function(x, y) if not m:has(x, y - 1) then return TIMB[5] elseif not m:has(x, y + 1) then return TIMB[1] end return TIMB[3] end)
    outl(m)
  end
  -- lintel
  local lm = rect(174, 44, 306, 58)
  planks(lm, TIMB, { vert = false, w = 5, base = 4, ox = 44 })
  for x = 174, 306 do c:put(x, 44, TIMB[6]) c:put(x, 45, TIMB[5]) c:put(x, 58, TIMB[1]) end
  for x = 180, 300, 3 do if hash(x, 1, 95) < .35 then c:put(x, 50, TIMB[2]) c:put(x + 1, 50, TIMB[2]) end end
  outl(lm)
  for _, x in ipairs({ 191, 289 }) do fill(rect(x - 1, 49, x + 1, 51), IRON[4]) c:put(x - 1, 49, IRON[6]) end
  -- sign board (pick and shovel crossed), hung by two chains
  for _, x in ipairs({ 220, 260 }) do for y = 40, 43 do c:put(x, y, (y % 2 == 0) and IRON[4] or IRON[2]) end end
  local sb = c:rrect(212, 28, 268, 41, 2)
  planks(sb, OAK, { vert = false, w = 4, base = 5, ox = 28 }) outl(sb)
  c:line(P{ {226, 38}, {250, 31} }, 1):each(function(x, y) c:put(x, y, OAK[2]) end)
  c:line(P{ {226, 31}, {250, 38} }, 1):each(function(x, y) c:put(x, y, OAK[2]) end)
  local ph = poly{ {244, 29}, {252, 31}, {256, 35}, {250, 33}, {244, 32} } fill(ph, IRON[4]) c:put(251, 31, IRON[6])
  local sh = c:rrect(222, 34, 228, 39, 2) fill(sh, IRON[3]) c:put(223, 35, IRON[5])
  -- rubble at the post feet
  for _, r in ipairs({ {170, 148, 14, 7, 1}, {310, 149, 13, 6, 2}, {204, 154, 6, 3, 3} }) do
    local m = c:ellipse(r[1], r[2], r[3], r[4]):clip(rect(0, 0, W - 1, r[2] + 2))
    rockTex(m, WSTONE, { cw = 5, ch = 4, seed = 100 + r[5], base = 4 }) outl(m)
  end
else
  -- chains from the jaw to iron rings
  for _, ch in ipairs({ { 200, 64, 172, 104 }, { 280, 64, 308, 104 } }) do
    local n = max(abs(ch[3] - ch[1]), abs(ch[4] - ch[2]))
    for t = 0, n do
      local x = floor(ch[1] + (ch[3] - ch[1]) * t / n + .5)
      local y = floor(ch[2] + (ch[4] - ch[2]) * t / n + 3 * sin(PI * t / n) + .5)
      local col = (floor(t / 2) % 2 == 0) and IRON[5] or IRON[2]
      c:put(x, y, col) c:put(x + 1, y, IRON[1])
    end
    local ring = c:ellipse(ch[3], ch[4] + 3, 3, 3):cut(c:ellipse(ch[3], ch[4] + 3, 1, 1))
    fill(ring, IRON[4]) c:put(ch[3] - 2, ch[4] + 1, IRON[6])
  end
  -- wall torches on the jaw
  for _, tx in ipairs({ 174, 306 }) do
    fill(rect(tx - 1, 78, tx + 1, 92), OAK[3]) outl(rect(tx - 1, 78, tx + 1, 92))
    fill(rect(tx - 2, 76, tx + 2, 78), IRON[3])
    local fl = poly{ {tx - 3, 76}, {tx + 3, 76}, {tx + 1, 68}, {tx, 64}, {tx - 2, 70} }
    tex(fl, function(x, y) if y > 73 then return EMBER[5] elseif y > 69 then return EMBER[6] end return "#fff0b0" end)
    c:rim(fl, EMBER[3])
    glow(tx, 74, 22, "#ffb860", .35)
  end
  -- rubble and boulders at the maw feet
  for _, r in ipairs({ {176, 150, 13, 7, 1}, {306, 151, 13, 6, 2} }) do
    local m = c:ellipse(r[1], r[2], r[3], r[4]):clip(rect(0, 0, W - 1, r[2] + 2))
    rockTex(m, BAS, { cw = 6, ch = 4, seed = 110 + r[5], base = 4 }) outl(m)
  end
end

-- hanging roots from the cliff over the mouth (both pictures)
local function root(x, y, len, seed, col)
  local px = x
  for i = 0, len do
    local xx = x + floor(2 * sin(i / 5 + seed) + i * .04 * (hash(seed, 1, 3) - .5) * 10)
    c:put(xx, y + i, col or OAK[2])
    if i < len * .5 then c:put(xx + 1, y + i, OAK[3]) end
    if hash(i, seed, 4) < .08 and i > 4 then c:put(xx - 1, y + i, OAK[2]) c:put(xx - 2, y + i + 1, OAK[2]) end
    px = xx
  end
  c:put(px, y + len + 1, OAK[1])
end
if not LAIR then
  for _, r in ipairs({ {166, 40, 34, 1}, {172, 34, 22, 2}, {310, 38, 30, 3}, {316, 42, 18, 4}, {300, 30, 12, 5}, {180, 30, 14, 6} }) do
    root(r[1], r[2], r[3], r[4])
  end
  -- thick gnarled root crawling over the arch top
  local gr = c:line(P{ {150, 32}, {176, 24}, {206, 20}, {226, 22} }, 4)
  gr:add(c:line(P{ {254, 22}, {280, 18}, {312, 26}, {334, 36} }, 4))
  tex(gr, function(x, y) if not gr:has(x, y - 1) then return OAK[5] elseif not gr:has(x, y + 1) then return OAK[1] end return (hash(x, y, 7) < .2) and OAK[2] or OAK[3] end)
  outl(gr)
else
  for _, r in ipairs({ {160, 70, 24, 1}, {320, 66, 28, 3}, {150, 92, 14, 2} }) do root(r[1], r[2], r[3], r[4], "#3a2a34") end
end

---------------------------------------------------------------- 6. path (+ rails for the delve)
local path
if LAIR then
  path = poly{ {186, 153}, {294, 153}, {376, 270}, {104, 270} }
  rockTex(path, WSTONE, { cw = 18, ch = 9, seed = 120, base = 4, light = function(x, y) return (y < 170) and -1 or 0 end })
  -- warm ember spill near the maw + scorch streaks radiating out
  path:each(function(x, y)
    if y < 190 then local d = sqrt(((x - 240) / 70)^2 + ((y - 152) / 38)^2) if d < 1 then tint(x, y, "#ff9a50", .3 * floor((1 - d) * 3 + .999) / 3) end end
  end)
  for k = -4, 4 do
    local a = PI / 2 + k * .17
    for r = 6, 70 + floor(hash(k, 1, 121) * 40) do
      local x, y = floor(240 + cos(a) * r * 1.6), floor(150 + sin(a) * r)
      if hash(r, k, 122) < .55 and not nearStand(x, y, -2) then tint(x, y, "#2a1a24", .45) end
    end
  end
  outl(path, "#4a3640")
else
  path = poly{ {198, 153}, {282, 153}, {350, 270}, {130, 270} }
  tex(path, function(x, y)
    local i = 4
    local h = hash(x, y, 130)
    if h < .12 then i = 3 elseif h > .9 then i = 5 end
    if hash(floor(x / 3), floor(y / 2), 131) < .12 then i = i - 1 end
    local cc = R(GRAV, i)
    if y < 172 then cc = mix(cc, "#e0c0a0", (172 - y) / 40 * .3) end
    return cc
  end)
  outl(path, "#4e4250")
  -- warm light spilling from the mine onto the gravel
  path:each(function(x, y)
    local d = sqrt(((x - 240) / 56)^2 + ((y - 152) / 30)^2)
    if d < 1 then tint(x, y, "#ffc070", .32 * floor((1 - d) * 3 + .999) / 3) end
  end)
  -- sleepers (perspective spaced) and rails converging on the vanishing point
  local function railX(xb, y) return VX + (xb - VX) * (y - VY) / (H - VY) end
  local z = 1
  while true do
    local y = floor(VY + 158 / z + .5)
    if y < 121 then break end
    local th = max(1, floor((y - VY) / 26))
    local xa, xb = floor(railX(198, y)), floor(railX(282, y) + .5)
    local sl = rect(xa, y - th, xb, y)
    tex(sl, function(x, yy) local i = (yy == y - th) and 5 or 3 if hash(x, yy, z * 10) < .15 then i = 2 end return R(OAK, i) end)
    if th > 1 then c:edgeIn(sl, OAK[1]) end
    z = z + .38
  end
  for _, xb in ipairs({ 208, 272 }) do
    for y = 121, H - 1 do
      local x = floor(railX(xb, y) + .5)
      local w = 1 + floor((y - VY) / 55)
      for k = 0, w - 1 do c:put(x + k, y, (k == 0) and IRON[6] or IRON[4]) end
      c:put(x + w, y, IRON[1])
    end
  end
  -- light tint on rails nearest the glow
  for y = 121, 160 do for x = 226, 254 do if c:get(x, y) == IRON[6] then c:put(x, y, "#fff0c0") end end end
end

---------------------------------------------------------------- 7. wild trail (right)
local function fern(x, y, s, r, seed)
  for k = -3, 3 do
    local a = -PI / 2 + k * .38
    local len = s - abs(k)
    for t = 0, len do
      local xx = floor(x + cos(a) * t + (k * t * t) * .02)
      local yy = floor(y + sin(a) * t * .9 + t * t * .04)
      c:put(xx, yy, (t < len * .4) and R(r, 3) or R(r, 5))
      if t % 2 == 0 and t > 1 then c:put(xx + (k >= 0 and 1 or -1), yy + 1, R(r, 4)) end
    end
  end
end
local function birch(x, by, h, seed)
  local tm = rect(x, by - h, x + 3, by)
  tex(tm, function(xx, yy)
    if hash(floor(yy / 3), seed, 1) < .2 and xx < x + 3 then return BIRCH[2] end
    return xx == x and BIRCH[6] or (xx == x + 3 and BIRCH[3] or BIRCH[5])
  end)
  outl(tm)
  for k = 1, 3 do local yy = by - floor(h * (.3 + k * .18)) for t = 0, 5 do c:put(x + 4 + t, yy - floor(t / 2), BIRCH[3]) end end
end
local function trailPoly(pts) local m = poly(pts) return m end
if not LAIR then
  -- forest edge behind the trail (layered, cooler further)
  shrub(440, 96, 28, 18, PINE, 201) shrub(400, 108, 18, 12, PINE, 202)
  local gl = c:ellipse(431, 116, 10, 12):clip(rect(0, 0, W - 1, 127))
  tex(gl, function(x, y) if y > 118 and abs(x - 431) < 4 and hash(x, y, 9) < .5 then return "#e8c27e" end return (y < 112) and PINE[1] or PINE[2] end)
  outl(gl, PINE[1])
  pine(472, 124, 74, PINE, 203)
  pine(412, 120, 58, PINE, 204)
  shrub(452, 70, 12, 9, LEAFG, 207) birch(450, 150, 76, 205)
  pine(388, 124, 40, PINE, 206)
  -- trail: worn dirt winding from the gravel up into the trees
  local tr = trailPoly{ {286, 200}, {316, 196}, {362, 168}, {404, 142}, {426, 128}, {438, 126}, {420, 140}, {380, 168}, {336, 198}, {318, 208} }
  tex(tr, function(x, y)
    local i = 4 + (hash(x, floor(y / 2), 210) < .15 and -1 or 0)
    if hash(x, y, 211) > .94 then i = 5 end
    return R(SACK, i)
  end)
  -- dark glade opening at the end of the trail with warm shafts beyond
  -- log steps across the trail
  for _, s in ipairs({ {350, 178, 14}, {378, 160, 11}, {404, 145, 8} }) do
    local lg = rect(s[1], s[2], s[1] + s[3], s[2] + 2) fill(lg, OAK[4]) for x = s[1], s[1] + s[3] do c:put(x, s[2], OAK[5]) end outl(lg)
    c:put(s[1] + s[3], s[2] + 1, OAK[6])
  end
  -- signpost with an arrow (no text)
  local post = rect(392, 128, 395, 166) planks(post, OAK, { w = 2, base = 4, ox = 392 }) outl(post)
  local ar = poly{ {380, 120}, {414, 120}, {422, 126}, {414, 132}, {380, 132} }
  planks(ar, OAK, { vert = false, w = 3, base = 5, ox = 120 }) outl(ar)
  leaf(LEAF, 394, 123, LEAFG)
  local ar2 = poly{ {404, 136}, {378, 136}, {372, 141}, {378, 146}, {404, 146} }
  planks(ar2, OAK, { vert = false, w = 3, base = 4, ox = 136 }) outl(ar2)
  for x = 382, 398, 4 do c:put(x, 141, OAK[2]) c:put(x + 1, 141, OAK[2]) end
  -- ferns and flowers along the trail
  fern(440, 160, 9, MOSS, 1) fern(372, 186, 8, MOSS, 2) fern(456, 140, 7, MOSS, 3) fern(410, 168, 7, MOSS, 4)
  for i = 1, 20 do
    local x, y = 360 + floor(hash(i, 1, 220) * 100), 150 + floor(hash(i, 2, 220) * 40)
    if not tr:has(x, y) and not inCompass(x, y) then c:put(x, y, ({ "#f6d0e0", "#ffe080", "#d8e8ff" })[1 + i % 3]) c:put(x, y + 1, MOSS[3]) end
  end
else
  -- thorny dark wood beyond the lair's right shoulder
  shrub(452, 112, 26, 18, PINE, 301) shrub(420, 124, 16, 12, PINE, 302)
  local gl = c:ellipse(451, 122, 9, 11):clip(rect(0, 0, W - 1, 131))
  tex(gl, function(x, y) if y > 124 and abs(x - 451) < 3 and hash(x, y, 9) < .5 then return "#e8c27e" end return PINE[1] end)
  pine(472, 136, 70, PINE, 303)
  pine(426, 128, 50, PINE, 304)
  local tr = trailPoly{ {300, 206}, {330, 200}, {380, 176}, {420, 150}, {444, 132}, {456, 130}, {440, 148}, {398, 180}, {350, 206}, {320, 214} }
  tex(tr, function(x, y)
    local i = 4 + (hash(x, floor(y / 2), 310) < .15 and -1 or 0)
    return R(SACK, i - 1)
  end)
  -- bramble arches with thorns
  for _, b in ipairs({ {404, 150, 22}, {440, 176, 24}, {414, 200, 16} }) do
    for t = 0, 30 do
      local a = PI + PI * t / 30
      local x, y = floor(b[1] + cos(a) * b[3] + .5), floor(b[2] + sin(a) * b[3] * .6 + .5)
      c:put(x, y, "#3a2a34") c:put(x, y - 1, "#5a3e3c")
      if t % 4 == 0 then c:put(x, y - 2, "#8a5a4a") c:put(x + 1, y - 1, MOSS[3]) end
      if t % 7 == 3 then c:put(x, y - 2, REDR[4]) c:put(x + 1, y - 2, REDR[5]) end
    end
  end
  -- signpost (arrow to the trail, no text)
  local post = rect(412, 156, 415, 200) planks(post, OAK, { w = 2, base = 3, ox = 412 }) outl(post)
  local ar = poly{ {402, 158}, {436, 158}, {444, 164}, {436, 170}, {402, 170} }
  planks(ar, OAK, { vert = false, w = 3, base = 4, ox = 158 }) outl(ar)
  leaf(LEAF, 416, 161, LEAFG)
  fern(446, 202, 8, MOSS, 5) fern(468, 180, 7, MOSS, 6) fern(426, 210, 6, MOSS, 7)
end

---------------------------------------------------------------- 8. props
local function crate(x0, y0, x1, y1, r)
  local m = rect(x0, y0, x1, y1)
  planks(m, r or OAK, { vert = false, w = 4, base = 4, ox = y0, seed = x0 })
  for x = x0, x1 do c:put(x, y0, R(r or OAK, 6)) end
  local b = 2
  fill(rect(x0, y0, x0 + b, y1), R(r or OAK, 3)) fill(rect(x1 - b, y0, x1, y1), R(r or OAK, 2))
  dbeam(x0 + b, y1 - 1, x1 - b, y0 + 1, r or OAK)
  outl(m)
  return m
end
local function sack(x0, y0, x1, y1)
  local m = c:rrect(x0, y0, x1, y1, max(2, floor((x1 - x0) / 3)))
  m:add(poly{ {floor((x0 + x1) / 2) - 3, y0 + 2}, {floor((x0 + x1) / 2) + 3, y0 + 2}, {floor((x0 + x1) / 2) + 2, y0 - 4}, {floor((x0 + x1) / 2) - 2, y0 - 4} })
  tex(m, function(x, y)
    local u, v = (x - x0) / (x1 - x0), (y - y0) / (y1 - y0)
    local i = (u < .35) and 5 or ((u > .72 or v > .8) and 3 or 4)
    if (x + y) % 3 == 0 and hash(x, y, 7) < .4 then i = i - 1 end
    return R(SACK, i)
  end)
  outl(m)
  local tx = floor((x0 + x1) / 2)
  fill(rect(tx - 3, y0 + 1, tx + 3, y0 + 2), REDR[3])
  return m
end
local function shroom(x, by, h, cw, r, o)
  o = o or {}
  local st = rect(x - max(1, floor(cw / 6)), by - h, x + max(1, floor(cw / 6)), by)
  tex(st, function(xx, yy) return xx <= x and CREAM[5] or CREAM[3] end) outl(st)
  local ry = max(3, floor(cw / 3))
  local cap = c:ellipse(x, by - h, floor(cw / 2), ry):clip(rect(0, 0, W - 1, by - h + 1))
  tex(cap, function(xx, yy)
    local u, v = (xx - x) / (cw / 2), (yy - (by - h)) / ry
    local i = (u + v < -.7) and 6 or ((u + v < .1) and 5 or 4)
    if yy == by - h + 1 then i = 2 end
    return R(r, i)
  end)
  outl(cap)
  if o.spots then for k = 1, 4 do
    local sx, sy = x - floor(cw / 3) + floor(hash(k, x, 1) * cw * .66), by - h - floor(hash(k, x, 2) * ry * .7) - 1
    if cap:has(sx, sy) and cap:has(sx + 1, sy) then c:put(sx, sy, CREAM[6]) c:put(sx + 1, sy, CREAM[5]) end
  end end
  if o.glow then glow(x, by - h, floor(cw * .9) + 4, r[6], .28) end
  return cap
end
local function crystals(x, by, s, r)
  for k = -1, 1 do
    local hh = floor(s * (1 - abs(k) * .35))
    local cx = x + k * floor(s * .4)
    local m = poly{ {cx - 3, by}, {cx + 3, by}, {cx + 3 + k * 2, by - hh + 3}, {cx + k * 3, by - hh}, {cx - 3 + k * 2, by - hh + 3} }
    tex(m, function(xx, yy) return xx <= cx + k * 2 and R(r, 5) or R(r, 3) end)
    outl(m)
    c:put(cx - 1 + k * 2, by - hh + 4, R(r, 6)) c:put(cx - 1 + k * 2, by - hh + 5, R(r, 6))
  end
  glow(x, by - floor(s / 2), s + 6, R(r, 6), .22)
end
local function pickaxe(x, y, len)
  local hd = c:line(P{ {x, y}, {x + len, y - len} }, 2) fill(hd, OAK[4]) outl(hd)
  local hm = c:line(P{ {x + len - 9, y - len - 2}, {x + len - 3, y - len - 5}, {x + len + 3, y - len - 4}, {x + len + 8, y - len + 2} }, 2)
  fill(hm, IRON[4]) outl(hm)
  c:put(x + len - 3, y - len - 5, IRON[6])
end
local function shovel(x, y, len)
  local hd = rect(x, y - len, x + 1, y) fill(hd, OAK[4]) c:put(x, y - len, OAK[6])
  local gr = rect(x - 2, y - len - 3, x + 3, y - len - 1) fill(gr, OAK[3]) outl(gr)
  local bl = c:rrect(x - 4, y, x + 5, y + 10, 3) tex(bl, function(xx, yy) return xx < x and IRON[5] or IRON[3] end) outl(bl)
  outl(hd)
end
local function lantern(lx, y0, sz, chain)
  for y = y0, y0 + chain do c:put(lx, y, (y % 2 == 0) and IRON[4] or IRON[2]) end
  local t = y0 + chain + 1
  local capm = poly{ {lx - sz - 1, t + 4}, {lx - sz + 2, t}, {lx + sz - 1, t}, {lx + sz + 2, t + 4} }
  fill(capm, IRON[3]) c:edgeIn(capm, IRON[1])
  local body = rect(lx - sz, t + 5, lx + sz, t + 5 + sz * 2 + 2)
  tex(body, function(x, y) local f = (y - t - 5) / (sz * 2 + 2) return f < .35 and "#fff0b0" or (f < .7 and "#ffd06a" or "#f4a040") end)
  for y = t + 5, t + 5 + sz * 2 + 2 do c:put(lx - sz, y, IRON[2]) c:put(lx + sz, y, IRON[1]) c:put(lx, y, IRON[2]) end
  local bt = rect(lx - sz - 1, t + 6 + sz * 2 + 2, lx + sz + 1, t + 7 + sz * 2 + 2)
  fill(bt, IRON[3]) c:edgeIn(bt, IRON[1])
  c:put(lx - sz + 2, t + 7, "#fff8e0")
  glow(lx, t + 6 + sz, 10 + sz * 3, "#ffd890", .34)
end

if not LAIR then
  -- [crates + powder barrel] behind the cart
  castShadow(70, 130, 166, 10, 6, .3)
  crate(98, 140, 130, 166) crate(102, 120, 126, 140)
  barrel(72, 132, 96, 166, OAK)
  fill(rect(73, 146, 95, 148), REDR[4]) for x = 74, 94 do c:put(x, 146, REDR[5]) end
  -- [tool rack] pick, shovel, coiled rope, miner's helmet with candle
  local p1, p2 = rect(134, 100, 137, 158), rect(162, 100, 165, 158)
  planks(p1, TIMB, { w = 2, base = 4, ox = 134 }) planks(p2, TIMB, { w = 2, base = 3, ox = 162 }) outl(p1) outl(p2)
  local cb = rect(132, 108, 167, 111) planks(cb, TIMB, { vert = false, w = 2, base = 4, ox = 108 }) outl(cb)
  pickaxe(140, 150, 16)
  shovel(156, 128, 16)
  local rope = c:ellipse(149, 120, 5, 7):cut(c:ellipse(149, 120, 2, 4))
  tex(rope, function(x, y) return ((x + y) % 3 == 0) and SACK[3] or SACK[5] end) outl(rope)
  local hel = c:ellipse(135, 98, 6, 4):clip(rect(0, 0, W - 1, 99)) fill(hel, MUST[4]) c:edgeIn(hel, MUST[2]) fill(rect(128, 99, 142, 100), MUST[3]) outl(hel:add(rect(128, 99, 142, 100)))
  fill(rect(134, 90, 136, 94), CREAM[5]) c:put(135, 88, "#fff0b0") c:put(135, 89, "#ffd06a") glow(135, 90, 8, "#ffd890", .3)
  -- [hero mine cart] full of ore and crystals on a short spur
  castShadow(26, 120, 242, 12, 6, .35)
  for _, ry in ipairs({ 240 }) do
    fill(rect(14, ry, 128, ry + 1), IRON[4]) for x = 14, 128 do c:put(x, ry, IRON[6]) c:put(x, ry + 2, IRON[1]) end
    for x = 18, 126, 14 do local sl = rect(x, ry + 2, x + 7, ry + 4) fill(sl, OAK[3]) c:edgeIn(sl, OAK[1]) end
  end
  local ore = c:ellipse(72, 186, 42, 14):clip(rect(0, 0, W - 1, 190))
  rockTex(ore, ROCK, { cw = 7, ch = 5, seed = 401, base = 4 }) outl(ore)
  for i = 1, 22 do
    local x, y = 36 + floor(hash(i, 1, 402) * 72), 174 + floor(hash(i, 2, 402) * 14)
    if ore:has(x, y) and ore:has(x + 1, y + 1) then
      if i % 3 == 0 then c:put(x, y, GOLDL[6]) c:put(x + 1, y, GOLDL[4]) c:put(x, y + 1, GOLDL[3]) else c:put(x, y, R(ROCK, 6)) end
    end
  end
  crystals(60, 182, 16, TEAL) crystals(90, 184, 12, AMETH)
  local body = poly{ {26, 186}, {120, 186}, {112, 230}, {34, 230} }
  tex(body, function(x, y)
    local i = 4
    if y < 190 then i = 6 elseif (y - 186) % 11 < 2 then i = 3 end
    if x < 44 then i = i + 1 elseif x > 100 then i = i - 1 end
    if hash(x, floor(y / 3), 403) < .06 then i = i - 1 end
    return R(BARN, i)
  end)
  outl(body)
  for _, yy in ipairs({ 195, 220 }) do
    local band = poly{ {26 + floor((yy - 186) * 8 / 44), yy}, {120 - floor((yy - 186) * 8 / 44), yy}, {120 - floor((yy - 186) * 8 / 44), yy + 2}, {26 + floor((yy - 186) * 8 / 44), yy + 2} }
    fill(band, IRON[3]) for x = 30, 116, 9 do if band:has(x, yy + 1) then c:put(x, yy + 1, IRON[6]) end end
  end
  -- a handle bar and a hanging lantern hook on the cart
  local hb = c:line(P{ {120, 196}, {130, 192}, {132, 200} }, 2) fill(hb, IRON[4]) outl(hb)
  for _, wx in ipairs({ 48, 98 }) do
    local wh = c:ellipse(wx, 232, 9, 9)
    tex(wh, function(x, y) local d = sqrt((x - wx)^2 + (y - 232)^2) if d > 7 then return IRON[2] elseif d < 2.5 then return IRON[5] end
      if (x == wx or y == 232 or abs(x - wx) == abs(y - 232)) then return IRON[4] end return IRON[1] end)
    outl(wh) c:put(wx - 5, 226, IRON[6])
  end
  -- [loose ore chunks + spare pick by the cart]
  for _, r in ipairs({ {128, 230, 5, 3}, {16, 246, 4, 3} }) do local m = c:ellipse(r[1], r[2], r[3], r[4]) rockTex(m, ROCK, { cw = 3, ch = 3, seed = r[1], base = 4 }) outl(m) end
  -- [hoist] A-frame winch right of the mouth, rope down to a bucket of ore
  castShadow(318, 368, 158, 12, 5, .3)
  for _, l in ipairs({ { 322, 158, 342, 66 }, { 366, 158, 346, 66 } }) do
    local m = c:line(P{ {l[1], l[2]}, {l[3], l[4]} }, 4)
    tex(m, function(x, y) if not m:has(x - 1, y) then return TIMB[5] elseif not m:has(x + 1, y) then return TIMB[1] end return TIMB[3] end)
    outl(m)
  end
  local xb = rect(326, 128, 362, 131) planks(xb, TIMB, { vert = false, w = 2, base = 4, ox = 128 }) outl(xb)
  local pw = c:ellipse(344, 68, 6, 6) tex(pw, function(x, y) local d = sqrt((x - 344)^2 + (y - 68)^2) return d < 2 and IRON[5] or (d > 4.5 and IRON[2] or IRON[4]) end) outl(pw)
  for y = 74, 104 do c:put(350, y, SACK[4]) end
  local bk = poly{ {342, 104}, {358, 104}, {356, 118}, {344, 118} }
  planks(bk, OAK, { w = 3, base = 4, ox = 342 }) outl(bk)
  fill(rect(343, 108, 357, 109), IRON[3])
  for x = 344, 356, 3 do c:put(x, 103, R(ROCK, 5)) c:put(x + 1, 102, R(ROCK, 3)) end c:put(348, 102, TEAL[6])
  local crank = c:ellipse(370, 112, 5, 5):cut(c:ellipse(370, 112, 3, 3)) fill(crank, IRON[4]) outl(crank)
  fill(rect(369, 111, 371, 113), IRON[5])
  -- [ore sacks + pick stuck in the ground] right foreground
  castShadow(348, 380, 226, 10, 4, .3)
  sack(350, 196, 368, 226) sack(364, 204, 378, 226)
  pickaxe(338, 196, 14)
  -- crystals sprouting from the cliff
  crystals(112, 94, 14, TEAL) crystals(76, 116, 10, AMETH) crystals(360, 140, 10, TEAL)
  -- mushrooms: red spotted, glowing teal, brown cluster
  shroom(30, 258, 14, 22, REDR, { spots = true }) shroom(48, 260, 8, 14, REDR, { spots = true })
  shroom(160, 158, 7, 10, TEAL, { glow = true }) shroom(170, 159, 5, 7, TEAL, { glow = true })
  shroom(356, 176, 6, 10, BROWNR) shroom(364, 178, 4, 7, BROWNR) shroom(346, 178, 3, 6, BROWNR)
  shroom(118, 166, 5, 8, AMETH, { glow = true })
else
  -- [dead tree] behind left
  local function branch(x, y, a, len, w, d)
    local x2, y2 = x + cos(a) * len, y + sin(a) * len
    local m = c:line(P{ {x, y}, {x2, y2} }, w)
    tex(m, function(xx, yy) if not m:has(xx - 1, yy) then return "#7a6070" end return "#3e2c38" end)
    if d > 0 then
      branch(x2, y2, a - .45 - hash(d, x, 1) * .2, len * .68, max(1, w - 1), d - 1)
      branch(x2, y2, a + .4 + hash(d, y, 2) * .2, len * .62, max(1, w - 1), d - 1)
    end
  end
  branch(76, 156, -PI / 2, 40, 6, 4)
  branch(78, 140, -PI / 2 + .8, 22, 3, 2)
  -- [skull totem] with ragged banner
  local pole = rect(138, 112, 141, 176) planks(pole, OAK, { w = 2, base = 3, ox = 138 }) outl(pole)
  local bn = poly{ {142, 124}, {160, 126}, {158, 138}, {162, 150}, {154, 146}, {148, 152}, {142, 146} }
  tex(bn, function(x, y) return (x < 150) and REDR[4] or REDR[3] end) outl(bn)
  for y = 128, 144, 4 do c:put(150, y, REDR[5]) end
  local sk = c:rrect(132, 100, 148, 114, 5) tex(sk, function(x, y) return x < 140 and BONE[5] or BONE[4] end) outl(sk)
  fill(rect(135, 105, 137, 107), INK) fill(rect(142, 105, 144, 107), INK) c:put(140, 110, BONE[2])
  for _, s in ipairs({ -1, 1 }) do local hm = c:line(P{ {140 + s * 7, 103}, {140 + s * 14, 96}, {140 + s * 13, 88} }, 2) fill(hm, BONE[5]) outl(hm) end
  -- [giant ribs + skull bone pile] left foreground
  castShadow(24, 116, 236, 12, 6, .35)
  for k = 0, 3 do
    local x0 = 30 + k * 18
    local m = HP.mask()
    for t = 0, 24 do
      local a = PI + PI * .9 * t / 24
      local x, y = floor(x0 + 14 + cos(a) * 14), floor(234 + sin(a) * (34 - k * 4))
      m:add(c:line(P{ {x, y} }, 3))
    end
    tex(m, function(x, y) if not m:has(x, y - 1) then return BONE[6] elseif not m:has(x, y + 1) then return BONE[2] end return BONE[4] end)
    outl(m)
  end
  local bp = c:ellipse(76, 232, 44, 6):clip(rect(0, 0, W - 1, 236))
  tex(bp, function(x, y) return R(BONE, 3 + floor(hash(floor(x / 3), y, 501) * 3)) end) outl(bp)
  local sk2 = c:rrect(86, 206, 112, 228, 7) tex(sk2, function(x, y) return (x < 96) and BONE[5] or BONE[4] end) outl(sk2)
  fill(c:ellipse(93, 215, 3, 3), INK) fill(c:ellipse(105, 215, 3, 3), INK)
  for x = 92, 106, 3 do fill(rect(x, 226, x + 1, 230), BONE[6]) c:put(x, 231, BONE[2]) end
  -- [sword stuck in the ground + broken shield]
  local bl = rect(116, 152, 118, 186) tex(bl, function(x, y) return x == 116 and IRON[6] or IRON[4] end) outl(bl)
  local gd = rect(110, 150, 124, 152) fill(gd, MUST[4]) outl(gd)
  fill(rect(116, 140, 118, 149), OAK[3]) fill(c:ellipse(117, 138, 2, 2), MUST[5])
  local shd = c:ellipse(98, 178, 11, 13):cut(poly{ {98, 160}, {112, 168}, {104, 176} })
  tex(shd, function(x, y) local d = sqrt((x - 98)^2 + (y - 178)^2) if d > 10 then return IRON[3] end return (x < 98) and SBLUE[4] or SBLUE[3] end)
  outl(shd) fill(c:ellipse(98, 178, 2, 2), IRON[5])
  -- [claw-marked boulder] right
  castShadow(330, 398, 172, 14, 6, .35)
  local bd = c:ellipse(362, 146, 34, 26):add(c:ellipse(386, 158, 16, 14)):clip(rect(0, 0, W - 1, 172))
  rockTex(bd, BAS, { cw = 14, ch = 11, seed = 510, base = 4, light = function(x, y) return (x < 356 and y < 150) and 1 or 0 end }) outl(bd)
  for k = 0, 3 do for t = 0, 18 do
    local x, y = 344 + k * 6 + floor(t * .5), 130 + t
    c:put(x, y, BAS[1]) c:put(x + 1, y, "#c4a4a4")
  end end
  crystals(392, 140, 10, AMETH)
  -- [treasure chest] half open, coins spilling (warm gold accent)
  castShadow(336, 380, 226, 10, 4, .3)
  local cbx = rect(338, 204, 376, 226) planks(cbx, OAK, { vert = false, w = 4, base = 4, ox = 204 }) outl(cbx)
  for _, x in ipairs({ 340, 356, 372 }) do fill(rect(x, 204, x + 2, 226), MUST[4]) c:put(x, 205, MUST[6]) end
  local lid = poly{ {336, 204}, {378, 204}, {372, 188}, {342, 188} }
  planks(lid, OAK, { w = 4, base = 5, ox = 336 }) outl(lid)
  local gold = c:ellipse(357, 204, 17, 4):clip(rect(0, 0, W - 1, 204)) tex(gold, function(x, y) return R(GOLDL, 4 + floor(hash(x, y, 520) * 3)) end)
  fill(rect(355, 210, 359, 214), MUST[5]) c:put(357, 212, INK)
  for i = 1, 30 do
    local x, y = 318 + floor(hash(i, 1, 521) * 60), 180 + floor(hash(i, 2, 521) * 46)
    if not nearStand(x, y, 2) and not cbx:has(x, y) and not lid:has(x, y) and not inCompass(x, y) then c:put(x, y, GOLDL[5]) c:put(x + 1, y, GOLDL[3]) end
  end
  glow(357, 200, 22, "#ffd27a", .25)
  -- smoke curling from the maw top
  -- mushrooms: purple glowing, red spotted, pale cluster
  shroom(330, 176, 7, 11, AMETH, { glow = true }) shroom(318, 178, 4, 7, AMETH, { glow = true })
  shroom(28, 258, 12, 20, REDR, { spots = true }) shroom(44, 260, 7, 12, REDR, { spots = true })
  shroom(156, 170, 5, 8, CREAM) shroom(164, 172, 3, 6, CREAM)
end

-- grass tufts & small flora everywhere off-path (never on stands / compass)
for i = 1, 1600 do
  local x, y = floor(hash(i, 1, 23) * W), VY + 44 + floor(hash(i, 2, 23) * (H - VY - 46))
  local cc = c:get(x, y)
  local GSET = {} for _, g in ipairs(GROUND) do GSET[g] = true end
  local onGround = (not path:has(x, y)) and (not cliff:has(x, y) or y > CB) and GSET[cc] and GSET[c:get(x + 1, y) or ""] and GSET[c:get(x, y - 3) or ""]
  if onGround and not nearStand(x, y, 2) and not inCompass(x, y) and x > 18 and x < 461 then
    local depth = (y - VY) / (H - VY)
    if hash(i, 3, 23) < .35 then
      local r0 = hash(i, 5, 23) < .5 and 2 or 5
      for k = -2, 2 do c:put(x + k, y, R(GROUND, r0 + ((k + i) % 2))) end
      c:put(x, y - 1, R(GROUND, r0))
    elseif hash(i, 3, 23) < .8 then
      for k = 0, floor(1 + depth * 3) do c:put(x, y - k, R(GROUND, 2)) end
      c:put(x + 1, y - 1, R(GROUND, 5)) c:put(x - 1, y, R(GROUND, 4))
    elseif hash(i, 4, 23) < .5 then
      c:put(x, y, ({ "#f6d0e0", "#ffe080", "#e8e0ff" })[1 + i % 3]) c:put(x, y + 1, MOSS[3])
    end
  end
end

---------------------------------------------------------------- 9. foreground gate frame
do
  local lpx1, rpx0 = 17, 462
  if LAIR then rpx0 = 467 end
  local lp, rp = rect(0, 0, lpx1, 269), rect(rpx0, 0, 479, 269)
  stones(lp, STONE, { bh = 7, bw = 12, base = 4 }) stones(rp, STONE, { bh = 7, bw = 12, base = 4, ox = 2 })
  for y = 0, 269 do
    for x = lpx1 - 4, lpx1 do tint(x, y, SHADE, .32) end
    for x = rpx0, rpx0 + 3 do tint(x, y, "#ffe0a0", .15) end
    c:put(lpx1, y, STONE[1]) c:put(rpx0, y, STONE[1])
  end
  -- moss on the north-facing tops of stones (2-3 deliberate patches)
  for _, m in ipairs({ {2, 60, 12}, {4, 150, 10}, {rpx0 + 2, 90, 9}, {rpx0 + 3, 200, 8} }) do
    for x = m[1], m[1] + m[3] do c:put(x, m[2] + floor(hash(x, 1, 31) * 2), MOSS[4]) c:put(x, m[2] + 2, MOSS[2]) end
  end
  local tb = rect(0, 0, 479, 11)
  planks(tb, TIMB, { vert = false, w = 4, base = LAIR and 3 or 4, ox = 0 })
  for x = 0, 479 do c:put(x, 11, TIMB[1]) c:put(x, 10, TIMB[2]) c:put(x, 0, TIMB[5]) end
  for x = 30, 460, 60 do fill(rect(x, 4, x + 2, 6), IRON[3]) c:put(x, 4, IRON[5]) end
  if LAIR then for x = 60, 440, 37 do fill(rect(x, 2, x + 5, 8), "#2e2228") end end -- scorch knots
  for _, b in ipairs({ { lpx1 + 1, 38, 40, 12 }, { rpx0 - 1, 38, rpx0 - 23, 12 } }) do
    local m = c:line(P{ {b[1], b[2]}, {b[3], b[4]} }, 5)
    tex(m, function(x, y) if not m:has(x, y - 1) then return TIMB[5] elseif not m:has(x, y + 1) then return TIMB[1] end return TIMB[3] end)
    c:edgeIn(m, TIMB[1])
  end
  -- ivy / hanging roots and leaves over both top corners
  local LR = LAIR and { MOSS, PINE, MOSS } or { MOSS, LEAFG, PINE }
  local function cluster(x0, x1, y0, y1, n, seed)
    for i = 1, n do
      local x = floor(x0 + (x1 - x0) * hash(i, 1, seed))
      local y = floor(y0 + (y1 - y0) * hash(i, 2, seed))
      local r = LR[1 + floor(hash(i, 3, seed) * 3)]
      if hash(i, 4, seed) < .5 then leaf(LEAF2, x, y, r) else leaf(LEAF, x, y, r) end
    end
  end
  cluster(-4, 70, -4, 22, 26, 91) cluster(-4, 26, 16, 50, 8, 92)
  cluster(410, 482, -4, 22, 26, 93) cluster(456, 482, 16, 50, 8, 94)
  for _, v in ipairs({ { 24, 12, 64 }, { 66, 12, 30 }, { 456, 12, 60 }, { 414, 12, 34 }, { 120, 12, 22 }, { 360, 12, 20 } }) do
    for y = v[2], v[3] do c:put(v[1] + floor(sin(y / 4) * 1.5), y, MOSS[2]) end
    for y = v[2] + 6, v[3] - 4, 8 do leaf(LEAF, v[1] - 3 + ((y / 8) % 2 == 0 and -2 or 2), y, LR[(y % 3) + 1]) end
  end
  -- hanging lanterns on the beam
  lantern(40, 12, 5, 8) lantern(440, 12, 5, 8)
  if not LAIR then
    -- lanterns under the mine lintel ends
    lantern(178, 59, 3, 3) lantern(302, 59, 3, 3)
  end
  -- ferns + red/brown mushrooms at the pillar feet
  fern(22, 252, 10, MOSS, 11) fern(458, 222, 9, MOSS, 12)
end

---------------------------------------------------------------- 10. light: mouth glow spill
glow(240, 112, 30, LAIR and "#ff9a50" or "#ffd27a", .18)

---------------------------------------------------------------- finish, check, save (layout json untouched)
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
print("saved " .. NAME)

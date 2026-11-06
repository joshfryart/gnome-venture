-- Village (here-village) : gate view, hero-scale toy diorama, golden-hour calm day. 480x270 native.
-- Run: AppRun -b --script-param out=<dir>/ --script here-village.lua
-- Spots (layout json is the contract, not rewritten here): do=Village Green & Well, people=Bench & Noticeboard,
-- stop=Village Signpost, homes=Cottages, garden=Your Garden, wild=Wild Trail.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/here-gate/places/")
local NAME = "here-village"
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

---------------------------------------------------------------- village ramps
local GRS    = {"#24402e","#335a34","#4a7638","#66903e","#88aa4a","#b0c45e"}
local DIRT   = {"#4a3026","#6c4a34","#8c6840","#aa864e","#c6a464","#dec088"}
local THATCH = {"#4a3020","#73502a","#9c7434","#c49a44","#dcbc5c","#f0d886"}
local LEAFS  = {"#1a3430","#24503a","#346c40","#4e8a44","#74a84e","#a4c866"}
local LEAFD  = {"#141e2a","#1a2e34","#22403a","#2e5640","#406e46","#5c8a4e"}
local PINK   = {"#4e2034","#7c3450","#aa5070","#d07890","#eca2b0","#f8ccd0"}
local PURP   = {"#2e2040","#4a305a","#6a4a7a","#8a68a0","#ac8cc0","#d0b4dc"}
local INK    = "#2b1c26"

---------------------------------------------------------------- layout (contract: unchanged)
local STANDS = { {70,152}, {246,152}, {158,228}, {262,210}, {214,252}, {280,254} }
local function nearStand(x, y, pad)
  for _, s in ipairs(STANDS) do if abs(x - s[1]) <= 15 + (pad or 0) and abs(y - s[2]) <= 6 + (pad or 0) then return true end end
  return false
end
local function inCompass(x, y) return x >= 378 and y >= 228 end
local function lx(y) return 236 - (y - VY) * 66 / 158 end
local function rx(y) return 244 + (y - VY) * 90 / 158 end
local function onRoad(x, y) return y > VY and x >= lx(y) - 1 and x <= rx(y) + 1 end
local function inkd(m) c:edgeIn(m, INK) return m end

local function canopy(blobs, r, seed, bx0, by0, bx1, by1, o)
  o = o or {}
  local function val(x, y)
    local v = -1
    for _, b in ipairs(blobs) do v = max(v, 1 - ((x - b[1]) / b[3])^2 - ((y - b[2]) / b[4])^2) end
    return v + (hash(floor(x / 3), floor(y / 3), seed) - .5) * .45
  end
  local m = HP.mask()
  for y = by0, by1 do for x = bx0, bx1 do if val(x, y) > 0 then m:set(x, y) end end end
  tex(m, function(x, y)
    local jx = x + floor(hash(floor(y / 5), 3, seed) * 6)
    local cx = floor(jx / 6)
    local jy = y + floor(hash(cx, 4, seed) * 5)
    local cy = floor(jy / 5)
    local u, v = jx - cx * 6, jy - cy * 5
    local L = .66 - (y - by0) / (by1 - by0) * .5 - (x - bx0) / (bx1 - bx0) * .28 + (o.lift or 0)
    if u + v < 3 + floor(hash(cx, cy, seed + 3) * 2) then L = L + .22 elseif u + v > 7 then L = L - .22 end
    if hash(cx, cy, seed + 5) < .12 then L = L + .12 end
    if hash(cx, cy, seed + 1) < .2 then L = L - .15 end
    if hash(x, y, seed + 2) < .04 then L = L + .2 end
    return R(r, 1 + floor(max(0, min(.999, L)) * 6))
  end)
  m:edge():each(function(x, y)
    if not m:has(x, y - 1) or not m:has(x - 1, y) then c:put(x, y, R(r, 6)) else c:put(x, y, o.ink and INK or R(r, 1)) end
  end)
  return m
end
local function trunk(pts, r, seed)
  local m = poly(pts)
  local x0, _, x1 = m:bbox()
  tex(m, function(x, y)
    local u = (x - x0) / max(1, x1 - x0)
    local i = u < .3 and 5 or (u < .65 and 4 or 3)
    if (x + floor(y / 7) + floor(hash(floor(x / 3), floor(y / 9), seed) * 3)) % 4 == 0 then i = i - 1 end
    if hash(x, floor(y / 3), seed + 1) < .06 then i = i - 1 end
    return R(r, i)
  end)
  inkd(m)
  return m
end
local function flower(x, y, r) c:put(x, y, R(r, 5)) c:put(x + 1, y, R(r, 4)) c:put(x, y - 1, R(r, 6)) c:put(x + 1, y + 1, R(r, 2)) end
local function tuft(x, y, n, r)
  r = r or GRS
  for k = 0, n do c:put(x, y - k, R(r, 2)) end
  c:put(x - 1, y, R(r, 3)) c:put(x + 1, y - 1, R(r, 5)) c:put(x + 1, y, R(r, 4))
end
local function fern(x, y, s, seed)
  for k = -3, 3 do
    local ex, ey = x + k * s * .9, y - s * (1.6 - abs(k) * .35)
    local ln = c:line(P{ {x, y}, {ex, ey} }, 1)
    ln:each(function(px, py) c:put(px, py, (k < 0) and LEAFS[5] or LEAFS[3]) if hash(px, py, seed) < .5 then c:put(px + 1, py, LEAFS[4]) end end)
    c:put(floor(ex), floor(ey), LEAFS[6])
  end
end
local function mushroom(x, y, s)
  fill(rect(x, y - s, x + 1, y), CREAM[5]) c:put(x + 1, y - 1, CREAM[3])
  local cap = c:rrect(x - s + 1, y - s - 2, x + s, y - s + 1, 1)
  tex(cap, function(px, py) return (py <= y - s - 1 and px < x + 1) and REDR[5] or REDR[4] end)
  c:put(x - 1, y - s - 1, CREAM[6]) c:put(x + 2, y - s, CREAM[6])
  c:rim(cap, INK)
end

---------------------------------------------------------------- 1. sky: golden-hour calm
local SKY = { {0,"#6a8cc4"}, {24,"#86a2cc"}, {44,"#a8b6d2"}, {60,"#cec6cc"}, {76,"#ecceb4"}, {90,"#fbd89e"}, {104,"#ffe2a6"}, {112,"#ffeab8"} }
for y = 0, VY do
  local yy = floor(y / 4) * 4
  local col = SKY[1][2]
  for i = 1, #SKY - 1 do
    local a, b = SKY[i], SKY[i + 1]
    if yy >= a[1] and yy <= b[1] then col = mix(a[2], b[2], (yy - a[1]) / (b[1] - a[1])) end
  end
  for x = 0, W - 1 do c:put(x, y, col) end
end
-- low sun upper-left: stepped halo
for y = 0, VY do for x = 0, 330 do
  local d = sqrt(((x - 104) / 170)^2 + ((y - 64) / 86)^2)
  if d < 1 then tint(x, y, "#fff0bc", .5 * floor((1 - d) * 4 + .999) / 4) end
end end
for k = -2, 4 do
  local ang = k * .26 - .2
  for r = 16, 220 do
    local x, y = floor(104 + cos(ang) * r), floor(64 + sin(ang) * r * .5)
    if y < VY and y > 12 and x < W then tint(x, y, "#fff4c8", .1) tint(x, y + 1, "#fff4c8", .1) end
  end
end
do
  local sun = c:ellipse(104, 64, 9, 9)
  fill(sun, "#fff6d6")
  sun:edge():each(function(x, y) c:put(x, y, "#ffe6a0") end)
  c:ellipse(104, 64, 5, 5):each(function(x, y) c:put(x, y, "#fffae8") end)
end
local function dcloud(x, y, w, seed)
  local m = HP.mask()
  m:add(c:rrect(x, y - floor(w * .14), x + w, y, 3))
  for i = 1, 4 do
    local cx = x + floor(w * (i - .5) / 4)
    local r = floor(w * (.12 + hash(i, seed, 3) * .12))
    m:add(c:ellipse(cx, y - floor(w * .12) - floor(r * .5), r, floor(r * .8)))
  end
  m:clip(rect(x - 30, 0, x + w + 30, y))
  tex(m, function(px, py)
    local up, lf = m:has(px, py - 2), m:has(px - 2, py)
    local t = (py - (y - w * .4)) / (w * .4)
    if not up then return "#fff6e2" end
    if not lf and t < .7 then return "#fdecd2" end
    if py >= y - 1 then return "#b4aecc" end
    if t > .78 then return "#d2c8da" end
    if hash(px, py, seed) < .05 then return "#eadcdc" end
    return "#f4e8e2"
  end)
end
dcloud(214, 40, 52, 1) dcloud(268, 28, 66, 2) dcloud(300, 62, 56, 3) dcloud(196, 70, 34, 4) dcloud(150, 30, 36, 5)

---------------------------------------------------------------- 2. hazy hills, windmill, chapel at the vanishing point
local function hills(f, colTop, colBot, ybot, seed, treeAmp)
  for x = 0, W - 1 do
    local top = floor(f(x) + .5)
    for y = top, ybot do
      local t = (y - top) / max(1, ybot - top)
      local col = mix(colTop, colBot, t)
      col = mix(col, "#ffe4b4", max(0, .3 - abs(x - 200) / 240 * .4))
      if treeAmp and hash(floor(x / 4), floor(y / 3), seed) < .25 then col = mix(col, colBot, .5) end
      if y == top then col = mix(col, "#ffeac0", .5) end
      c:put(x, y, col)
    end
  end
end
hills(function(x) return 80 + 6 * sin(x / 47 + 1) + 3 * sin(x / 17) end, "#b2b6d2", "#c4c2d2", VY, 1)
hills(function(x) return 92 + 5 * sin(x / 31 + 2) + 2 * sin(x / 11) - abs(sin(x / 3.3)) end, "#92a6b2", "#a6b6b2", VY, 2, true)
-- far windmill on the second ridge
do
  local tw = poly{ {320, 98}, {330, 98}, {328, 82}, {322, 82} }
  fill(tw, "#a6a2bc") for y = 82, 98 do c:put(328 - floor((y - 82) / 8), y, "#928eac") end
  fill(poly{ {320, 83}, {325, 77}, {330, 83} }, "#8a84a4")
  for _, d in ipairs({ {1, 1}, {-1, 1}, {1, -1}, {-1, -1} }) do
    for k = 1, 10 do c:put(325 + d[1] * k, 80 + d[2] * k, "#847ea0") if k > 3 then c:put(325 + d[1] * k + d[1], 80 + d[2] * k, "#bab4cc") end end
  end
  c:put(325, 80, "#6e6890")
end
hills(function(x) return 101 + 3 * sin(x / 21 + 4) - 3 * abs(sin(x / 3.7)) - 2 * abs(sin(x / 2.3)) end, "#7c9a7c", "#8aa47c", VY, 3, true)
hills(function(x) return 107 + 2 * sin(x / 13) - 3 * abs(sin(x / 2.9)) end, "#6a8c58", "#78985a", VY, 4, true)
-- chapel at the end of the lane (hazy, the eye's resting point)
do
  local HZ = "#6a5c7c"
  for _, t in ipairs({ {222, 104, 6, 6}, {258, 103, 7, 7}, {214, 108, 5, 4} }) do
    local m = c:ellipse(t[1], t[2], t[3], t[4]) tex(m, function(x, y) return (x + y < t[1] + t[2]) and "#8aa080" or "#6e8870" end)
  end
  local body = rect(230, 98, 250, 112) tex(body, function(x, y) return x > 244 and "#c8b8bc" or "#e6d6c6" end) c:edgeIn(body, HZ)
  local roof = poly{ {227, 99}, {253, 99}, {248, 91}, {232, 91} } tex(roof, function(x, y) return x > 244 and "#7a6c90" or "#9284a6" end) c:edgeIn(roof, HZ)
  local tw = rect(236, 78, 244, 98) tex(tw, function(x, y) return x > 241 and "#cab8b8" or "#eadacc" end) c:edgeIn(tw, HZ)
  local sp = poly{ {234, 79}, {246, 79}, {240, 62} } tex(sp, function(x, y) return x > 240 and "#7a6c90" or "#9a8cae" end) c:edgeIn(sp, HZ)
  fill(rect(239, 58, 240, 62), "#c8a050") fill(rect(238, 59, 241, 59), "#c8a050")
  fill(rect(239, 84, 241, 89), "#ffd890") c:put(240, 83, "#ffd890")
  fill(rect(238, 104, 242, 112), "#f2c070") fill(rect(232, 102, 234, 106), "#ffd890") fill(rect(246, 102, 248, 106), "#e0b070")
end

---------------------------------------------------------------- 3. ground: meadow + dirt lane + flagstones
for y = VY + 1, H - 1 do for x = 0, W - 1 do
  local depth = (y - VY) / (H - VY)
  local i = 3 + (depth > .4 and 1 or 0)
  local h = hash(x, floor(y / 2), 21)
  if h < .1 then i = i - 1 elseif h > .93 then i = i + 1 end
  if hash(floor(x / 9), floor(y / 5), 22) < .2 then i = i - 1 end
  if hash(floor(x / 14), floor(y / 7), 24) > .85 then i = i + 1 end
  local col = R(GRS, i)
  if y < 152 then col = mix(col, "#f0d8a0", (152 - y) / 40 * .42) end
  c:put(x, y, col)
end end
local road = poly{ {236, VY}, {244, VY}, {334, 270}, {170, 270} }
tex(road, function(x, y)
  local l, r = lx(y), rx(y) local u = (x - l) / max(1, r - l)
  local i = 4
  if abs(u - .26) < .05 or abs(u - .74) < .05 then i = 3 end
  if abs(u - .5) < .1 then i = 5 end
  local h = hash(x, y, 31)
  if h < .06 then i = i - 1 elseif h > .95 then i = i + 1 end
  if hash(floor(x / 4), floor(y / 3), 32) < .08 then i = i - 1 end
  local col = R(DIRT, i)
  if y < 172 then col = mix(col, "#f4dcae", (172 - y) / 60 * .42) end
  return col
end)
road:edge():each(function(x, y) if hash(x, y, 33) < .5 then c:put(x, y, R(GRS, 3)) else c:put(x, y, R(DIRT, 2)) end end)
-- worn flagstones down the middle of the lane
do
  local y = 118
  while y < 268 do
    local hgt = max(2, floor((y - 104) * .075))
    local cx = (lx(y) + rx(y)) / 2 local hw = (rx(y) - lx(y)) * .11
    local off = (floor(y / 3) % 2 == 0) and hw * .5 or -hw * .4
    local m = c:rrect(floor(cx - hw + off), y, floor(cx + hw + off), min(269, y + hgt), hgt > 4 and 2 or 0)
    tex(m, function(px, py) local i = (py == y) and 6 or ((px < cx + off - hw * .3) and 5 or 4) if hash(px, py, 35) < .08 then i = i - 1 end
      local col = R(WSTONE, i) if py < 172 then col = mix(col, "#f4dcae", (172 - py) / 60 * .4) end return col end)
    m:each(function(px, py) if not m:has(px, py + 1) or not m:has(px + 1, py) then c:put(px, py, R(WSTONE, 2)) end end)
    y = y + hgt + max(2, floor(hgt * .7))
  end
end
for i = 1, 170 do
  local y = VY + 8 + floor(hash(i, 1, 34) * (H - VY - 9))
  local x = floor(lx(y) + hash(i, 2, 34) * (rx(y) - lx(y)))
  if road:has(x, y) and not inCompass(x, y) and not nearStand(x, y, 2) then
    if (y - VY) / (H - VY) > .35 and hash(i, 3, 34) < .5 then fill(rect(x, y, x + 1, y), DIRT[6]) c:put(x, y + 1, DIRT[2]) else c:put(x, y, DIRT[5]) end
  end
end
-- meadow scatter: tufts, clover, wildflowers
for i = 1, 1100 do
  local x, y = floor(hash(i, 1, 23) * W), VY + 3 + floor(hash(i, 2, 23) * (H - VY - 4))
  if not road:has(x, y) and not road:has(x + 1, y) and not inCompass(x, y) and not nearStand(x, y, 1) then
    local depth = (y - VY) / (H - VY)
    local k = hash(i, 3, 23)
    if k < .55 then tuft(x, y, floor(1 + depth * 3))
    elseif k < .8 and depth > .2 then flower(x, y, ({ GOLDL, PINK, CREAM, PURP, SBLUE })[1 + floor(hash(i, 4, 23) * 5)])
    elseif depth > .3 then c:put(x, y, GRS[5]) c:put(x + 1, y, GRS[6]) c:put(x, y + 1, GRS[3]) end
  end
end

---------------------------------------------------------------- 4. back oak + far cottages + hedgerows
do
  trunk({ {180, 122}, {190, 122}, {188, 96}, {194, 80}, {190, 78}, {185, 88}, {182, 76}, {178, 78}, {182, 96} }, OAK, 3)
  canopy({ {150, 58, 30, 20}, {184, 68, 26, 20}, {128, 48, 20, 14}, {166, 40, 24, 14}, {200, 84, 12, 9} }, LEAFS, 41, 100, 22, 220, 100, { lift = -.05 })
end
local function hedge(x0, x1, yt, yb, seed, r)
  local m = HP.mask()
  for x = x0, x1 do
    local top = yt + floor(2 * sin(x / 3.3 + seed) + hash(x, 0, seed) * 2)
    for y = top, yb do m:set(x, y) end
  end
  tex(m, function(x, y)
    local cx, cy = floor(x / 4), floor((y + (floor(x / 4) % 2) * 2) / 3)
    local u, v = x - cx * 4, (y + (cx % 2) * 2) - cy * 3
    local i = 4
    if u + v < 2 then i = 5 elseif u + v > 4 then i = 3 end
    if y > yb - 2 then i = 2 end
    if hash(cx, cy, seed) < .15 then i = i - 1 end
    return R(r, i)
  end)
  m:edge():each(function(x, y) if not m:has(x, y - 1) then c:put(x, y, R(r, 6)) end end)
  return m
end
do
  local a = house{ left = true, x0 = 206, x1 = 224, top = 106, base = 119, apex = 98, s = .3, ovh = 2,
    wallR = CREAM, wallTex = "plaster", roofR = THATCH, rt = 3, rh = 2, rw = 3, shadow = false }
  window(210, 109, 214, 113, { sill = false })
  shadeMask(a.sil, .28, "#f2dcc0")
  local b = house{ x0 = 256, x1 = 278, top = 104, base = 120, apex = 94, s = .3, ovh = 2,
    wallR = ROSE, wallTex = "plaster", roofR = SLATE, rt = 3, rh = 2, rw = 3, shadow = false }
  window(266, 108, 271, 113, { sill = false })
  shadeMask(b.sil, .28, "#f2dcc0")
  hedge(190, 230, 115, 121, 2, GREEN) hedge(250, 292, 116, 123, 4, GREEN)
end

---------------------------------------------------------------- 5. right cottage (behind the noticeboard)
do
  local h = house{ x0 = 306, x1 = 364, top = 94, base = 126, apex = 66, s = .16, ovh = 3,
    wallR = ROSE, wallTex = "plaster", roofR = SLATE, rt = 5, rh = 4, rw = 5, sdx = 8, sdy = 4 }
  frameTimber(306, 364, { 94 }, TIMB)
  for _, x in ipairs({ 306, 334, 362 }) do beam(x, 96, x + 2, 125, TIMB) end
  window(312, 102, 326, 114, { frame = TIMB[2], shut = TEAL, sw = 3 })
  window(344, 102, 356, 114, { frame = TIMB[2] })
  window(330, 74, 338, 84, { frame = TIMB[2], sill = false })
  local ch = rect(350, 58, 358, 80) stones(ch, WSTONE, { bh = 3, bw = 4, base = 4, oy = 58 }) inkd(ch)
  fill(rect(349, 56, 359, 58), WSTONE[5]) inkd(rect(349, 56, 359, 58))
  wisp(354, 54, 14, 2) wisp(357, 50, 10, 5)
  hedge(286, 388, 116, 130, 7, GREEN)
  for i = 1, 14 do local x, y = 290 + floor(hash(i, 1, 51) * 94), 119 + floor(hash(i, 2, 51) * 9) flower(x, y, (i % 2 == 0) and PINK or CREAM) end
end

---------------------------------------------------------------- 6. COTTAGES (homes): thatched cottage + stone cottage
local function thatchify(m, seed)
  tex(m, function(x, y)
    local cur = c:get(x, y)
    if hash(x, floor(y / 3), seed) < .18 then return THATCH[3] end
    if hash(x, floor(y / 2), seed + 1) > .9 then return THATCH[6] end
    return cur
  end)
end
do
  -- stone cottage first (it sits behind the thatched one's side wall)
  local b = house{ left = true, x0 = 116, x1 = 164, top = 100, base = 138, apex = 74, s = .12, ovh = 3,
    wallR = WSTONE, wallTex = "stone", roofR = REDR, rt = 5, rh = 4, rw = 5, sdx = 12, sdy = 5 }
  -- moss on the shaded side of the roof
  for i = 1, 40 do
    local x, y = 116 + floor(hash(i, 1, 61) * 60), 72 + floor(hash(i, 2, 61) * 30)
    if b.roof:has(x, y) or b.band:has(x, y) then c:put(x, y, LEAFG[3]) if hash(i, 3, 61) < .5 then c:put(x + 1, y, LEAFG[4]) end end
  end
  door(134, 116, 146, 137, GREEN)
  fill(rect(132, 114, 148, 115), OAK[2])
  window(120, 106, 129, 116, { frame = OAK[1], shut = GREEN, sw = 2 })
  window(152, 106, 160, 116, { frame = OAK[1] })
  window(136, 86, 144, 94, { frame = OAK[1], sill = false })
  for _, x in ipairs({ 118, 150 }) do
    fill(rect(x, 119, x + 12, 121), OAK[4]) inkd(rect(x, 119, x + 12, 121))
    for k = 0, 3 do flower(x + 2 + k * 3, 118, (k % 2 == 0) and GOLDL or PURP) end
  end
  -- lantern by the green door
  fill(rect(149, 120, 151, 121), IRON[2]) fill(rect(149, 122, 152, 127), "#ffd870") c:rim(rect(149, 122, 152, 127), IRON[1])
  -- potted geranium on the step
  local pot = poly{ {126, 130}, {133, 130}, {132, 137}, {127, 137} } fill(pot, ORANGE[3]) inkd(pot)
  for k = 0, 3 do fill(rect(125 + k * 2, 126 + (k % 2), 126 + k * 2, 128 + (k % 2)), (k % 2 == 0) and REDR[5] or GREEN[4]) end

  -- thatched cottage (hero of the homes box)
  local a = house{ left = true, x0 = 28, x1 = 98, top = 94, base = 140, apex = 60, s = .10, ovh = 5,
    wallR = CREAM, wallTex = "plaster", roofR = THATCH, rt = 8, rh = 3, rw = 3, sdx = 14, sdy = 6 }
  thatchify(a.roof, 3) thatchify(a.band, 4)
  -- thatch drip fringe
  a.band:each(function(x, y) if not a.band:has(x, y + 1) and hash(x, 0, 5) < .5 then c:put(x, y + 1, THATCH[2]) if hash(x, 1, 5) < .4 then c:put(x, y + 2, THATCH[1]) end end end)
  -- timber framing
  frameTimber(28, 98, { 94 }, TIMB)
  for _, x in ipairs({ 28, 60, 96 }) do beam(x, 96, x + 2, 139, TIMB) end
  dbeam(31, 124, 44, 98, TIMB)
  -- chimney on the near slope + smoke
  local ch = rect(36, 52, 46, 82) stones(ch, WSTONE, { bh = 3, bw = 5, base = 4, oy = 52 })
  for y = 52, 82 do tint(45, y, SHADE, .25) tint(46, y, SHADE, .25) end inkd(ch)
  fill(rect(34, 50, 48, 52), WSTONE[5]) inkd(rect(34, 50, 48, 52))
  wisp(41, 47, 18, 1) wisp(44, 44, 12, 3)
  -- gable window
  window(58, 70, 68, 82, { frame = TIMB[1], sill = false })
  -- big front window with blue shutters + flower box
  window(38, 104, 54, 120, { frame = TIMB[1], shut = SBLUE, sw = 4 })
  fill(rect(31, 123, 61, 127), OAK[4]) inkd(rect(31, 123, 61, 127))
  for k = 0, 9 do flower(33 + k * 3, 122 - (k % 2), ({ PINK, GOLDL, REDR, CREAM })[k % 4 + 1]) c:put(33 + k * 3, 123, GREEN[4]) end
  -- round-top red door
  local dr = c:rrect(68, 110, 86, 139, 7)
  fill(dr:grow(1):cut(dr), TIMB[1])
  planks(dr, REDR, { w = 3, base = 4, ox = 68 })
  fill(rect(73, 116, 81, 120), "#ffd870") c:rim(rect(73, 116, 81, 120), TIMB[1]) c:put(77, 116, TIMB[1]) c:put(77, 117, TIMB[1])
  c:put(83, 126, GOLDL[6]) c:put(83, 127, GOLDL[4])
  fill(rect(64, 139, 90, 140), STONE[5]) for x = 64, 90 do c:put(x, 141, STONE[2]) end
  -- climbing rose up the left wall
  for y = 98, 139 do local x = 30 + floor(sin(y / 5) * 1.5) c:put(x, y, LEAFS[2]) if y % 4 == 0 then c:put(x + 1, y, LEAFS[4]) c:put(x - 1, y - 1, LEAFS[5]) end end
  for _, p in ipairs({ {31, 100}, {29, 108}, {32, 116}, {30, 130}, {33, 124}, {29, 136} }) do flower(p[1], p[2], PINK) end
  -- lantern beside the door
  fill(rect(90, 112, 92, 113), IRON[2]) fill(rect(89, 114, 93, 121), "#ffd870") c:rim(rect(89, 114, 93, 121), IRON[1]) c:put(90, 115, "#fff4d0")
  -- log stack against the side wall
  for row = 0, 2 do for k = 0, 3 - row do
    local x, y = 99 + k * 5 + row * 2, 135 - row * 5
    local lg = c:rrect(x, y, x + 4, y + 4, 1)
    tex(lg, function(px, py) return (px == x + 2 and py == y + 2) and OAK[3] or ((px + py < x + y + 4) and OAK[6] or OAK[5]) end)
    c:rim(lg, INK)
  end end
  -- house sign plaque (pictogram: tiny house)
  fill(rect(62, 98, 74, 106), OAK[5]) inkd(rect(62, 98, 74, 106))
  fill(poly{ {65, 102}, {68, 99}, {71, 102} }, REDR[4]) fill(rect(66, 102, 70, 104), CREAM[6])
end

---------------------------------------------------------------- 7. washing line (story prop)
do
  beam(196, 98, 198, 124, OAK) inkd(rect(196, 98, 198, 124))
  local pts = {}
  for x = 172, 196 do local t = (x - 172) / 24 local y = floor(104 + (98 - 104) * t + 6 * 4 * t * (1 - t) / 4 * 2 + .5) pts[#pts + 1] = { x, y } c:put(x, y, CREAM[2]) end
  local cloths = { {175, 6, 9, SBLUE}, {183, 5, 7, PINK}, {190, 4, 10, CREAM} }
  for _, cl in ipairs(cloths) do
    local x, w, hgt, r = cl[1], cl[2], cl[3], cl[4]
    local y = pts[x - 172 + 1][2]
    local m = rect(x, y + 1, x + w, y + hgt)
    tex(m, function(px, py) return (px - x) % 3 == 1 and R(r, 4) or R(r, 5) end) c:rim(m, INK)
    c:put(x + 1, y, OAK[5]) c:put(x + w - 1, y, OAK[5])
  end
end

---------------------------------------------------------------- 8. VILLAGE GREEN & WELL
do
  local g = c:ellipse(170, 194, 46, 15)
  local gm = HP.mask() g:each(function(x, y) if not onRoad(x, y) then gm:set(x, y) end end)
  tex(gm, function(x, y)
    local s = floor((x - 170 + (y - 194) * .6) / 7) % 2 == 0
    local i = s and 5 or 4
    if hash(x, y, 71) < .06 then i = i - 1 end
    return R(GRS, i)
  end)
  gm:edge():each(function(x, y) if y > 194 then c:put(x, y, GRS[2]) else c:put(x, y, GRS[6]) end end)
  for i = 1, 26 do
    local x, y = 128 + floor(hash(i, 1, 72) * 84), 182 + floor(hash(i, 2, 72) * 24)
    if gm:has(x, y) and not (x > 140 and x < 200 and y < 210) then c:put(x, y, CREAM[6]) c:put(x, y + 1, GOLDL[5]) end
  end
  castShadow(146, 198, 207, 16, 6, .36)
  -- stone barrel of the well
  local body = rect(148, 184, 192, 207)
  stones(body, WSTONE, { bh = 4, bw = 8, base = 4, oy = 184, ox = 148 })
  body:each(function(x, y) if x > 182 then tint(x, y, SHADE, .22) elseif x < 154 then tint(x, y, "#fff0c0", .15) end end)
  for i = 1, 14 do local x, y = 149 + floor(hash(i, 1, 73) * 12), 196 + floor(hash(i, 2, 73) * 11) c:put(x, y, LEAFG[4]) c:put(x + 1, y, LEAFG[3]) end
  inkd(body)
  -- lip
  local lip = c:rrect(144, 177, 196, 186, 3)
  stones(lip, WSTONE, { bh = 3, bw = 7, base = 5, oy = 177, ox = 144 })
  inkd(lip)
  local hole = c:rrect(150, 179, 190, 183, 2)
  tex(hole, function(x, y) if y == 179 then return "#1e2238" end return ((x + y) % 9 == 0) and "#6a8ac0" or "#2e3e64" end)
  -- posts
  for _, px in ipairs({ 150, 186 }) do
    local p = rect(px, 152, px + 4, 178) planks(p, OAK, { w = 5, base = 4, ox = px })
    for y = 152, 178 do c:put(px + 1, y, OAK[6]) c:put(px + 4, y, OAK[2]) end inkd(p)
  end
  -- windlass + crank
  local ax = rect(149, 161, 191, 164) planks(ax, OAK, { vert = false, w = 4, base = 4, ox = 161 }) inkd(ax)
  local cr = c:line(P{ {191, 162}, {196, 162}, {196, 169}, {199, 169} }, 2) fill(cr, IRON[3]) c:rim(cr, INK)
  fill(rect(166, 164, 174, 166), DIRT[5]) for x = 166, 174, 2 do c:put(x, 165, DIRT[3]) end
  -- rope + bucket
  for y = 166, 170 do c:put(170, y, DIRT[5]) end
  local bk = poly{ {163, 170}, {177, 170}, {176, 178}, {164, 178} }
  planks(bk, OAK, { w = 3, base = 4, ox = 163 })
  fill(rect(164, 172, 176, 172), IRON[4]) fill(rect(164, 176, 176, 176), IRON[3]) inkd(bk)
  local hd = c:line(P{ {164, 170}, {170, 167}, {176, 170} }, 1) fill(hd, IRON[2])
  -- tiled roof (ridge horizontal)
  local roof = poly{ {138, 156}, {202, 156}, {190, 144}, {150, 144} }
  shingles(roof, REDR, { rh = 3, w = 5, base = 4, oy = 144 })
  roof:each(function(x, y) if x > 182 then tint(x, y, SHADE, .2) elseif x < 152 then tint(x, y, "#ffe0a0", .15) end end)
  for i = 1, 16 do local x, y = 150 + floor(hash(i, 1, 74) * 40), 146 + floor(hash(i, 2, 74) * 9) if roof:has(x, y) then c:put(x, y, LEAFG[4]) end end
  inkd(roof)
  for x = 151, 189 do c:put(x, 145, REDR[6]) end
  fill(rect(138, 157, 202, 158), TIMB[3]) for x = 138, 202 do c:put(x, 157, TIMB[5]) c:put(x, 159, INK) end
  for y = 159, 162 do for x = 150, 190 do tint(x, y, SHADE, .3) end end
  -- spare bucket + daisies at the foot
  local b2 = poly{ {132, 199}, {142, 199}, {141, 207}, {133, 207} }
  planks(b2, TEAL, { w = 2, base = 4, ox = 132 }) fill(rect(133, 201, 141, 201), IRON[3]) inkd(b2)
  fill(rect(134, 199, 140, 200), "#3e5e8c") c:put(135, 199, "#8aaee0")
  for k = 0, 7 do flower(146 + k * 7, 210 - (k % 2), (k % 2 == 0) and CREAM or GOLDL) end
end

---------------------------------------------------------------- 9. BENCH & NOTICEBOARD
do
  castShadow(292, 380, 192, 12, 5, .34)
  -- noticeboard
  for _, x in ipairs({ 342, 375 }) do
    local p = rect(x, 138, x + 3, 192)
    planks(p, OAK, { w = 4, base = 4, ox = x }) for y = 138, 192 do c:put(x + 1, y, OAK[5]) end inkd(p)
  end
  local bd = rect(338, 140, 382, 178)
  planks(bd, OAK, { w = 5, vert = false, base = 3, ox = 140 })
  for x = 339, 381 do c:put(x, 141, OAK[5]) end inkd(bd)
  local cap = poly{ {334, 141}, {341, 129}, {379, 129}, {386, 141} }
  shingles(cap, REDR, { rh = 3, w = 5, oy = 129 })
  cap:each(function(x, y) if x > 372 then tint(x, y, SHADE, .2) end end) inkd(cap)
  for x = 342, 378 do c:put(x, 130, REDR[6]) end
  for y = 142, 144 do for x = 339, 381 do tint(x, y, SHADE, .3) end end
  -- pinned notes with pictograms (no text)
  local notes = { {341, 146, 352, 159, CREAM}, {355, 145, 366, 157, GOLDL}, {369, 147, 379, 160, CREAM},
                  {341, 162, 351, 175, SBLUE}, {354, 160, 366, 175, CREAM}, {369, 163, 379, 175, PINK} }
  for _, n in ipairs(notes) do
    local m = rect(n[1], n[2], n[3], n[4])
    tex(m, function(x, y) return (x + y < n[1] + n[2] + 6) and R(n[5], 6) or R(n[5], 5) end)
    for x = n[1] + 1, n[3] + 1 do c:put(x, n[4] + 1, OAK[1]) end for y = n[2] + 1, n[4] do c:put(n[3] + 1, y, OAK[2]) end
    c:put(floor((n[1] + n[3]) / 2), n[2], REDR[4]) c:put(floor((n[1] + n[3]) / 2), n[2] + 1, REDR[2])
  end
  -- pie
  fill(poly{ {343, 155}, {345, 151}, {349, 151}, {351, 155} }, GOLDL[5]) fill(rect(343, 155, 351, 156), SBLUE[3]) c:put(346, 152, GOLDL[6])
  -- sun
  fill(c:ellipse(360, 151, 3, 3), GOLDL[4]) c:put(360, 147, ORANGE[4]) c:put(356, 151, ORANGE[4]) c:put(364, 151, ORANGE[4]) c:put(360, 155, ORANGE[4])
  -- tiny house
  fill(poly{ {370, 154}, {374, 149}, {378, 154} }, REDR[4]) fill(rect(371, 154, 377, 158), CREAM[3]) c:put(374, 156, OAK[2]) c:put(374, 157, OAK[2])
  -- map squiggle
  local sq = c:line(P{ {343, 172}, {345, 166}, {348, 170}, {350, 164} }, 1) fill(sq, REDR[3]) c:put(350, 164, REDR[5])
  -- flower
  fill(rect(359, 166, 361, 168), PINK[4]) c:put(360, 165, PINK[5]) c:put(358, 167, PINK[5]) c:put(362, 167, PINK[5]) fill(rect(360, 169, 360, 173), GREEN[3])
  -- three lines of pictogram dashes
  for k = 0, 2 do fill(rect(371, 166 + k * 3, 377 - k * 2, 166 + k * 3), IRON[3]) end
  -- bench
  for _, x in ipairs({ 296, 330 }) do local p = rect(x, 164, x + 3, 192) planks(p, OAK, { w = 4, base = 3, ox = x }) c:put(x + 1, 165, OAK[6]) inkd(p) end
  for _, y in ipairs({ 166, 172 }) do local s = rect(294, y, 336, y + 3) planks(s, OAK, { vert = false, w = 4, base = 5, ox = y }) for x = 295, 335 do c:put(x, y, OAK[6]) end inkd(s) end
  local seat = rect(290, 180, 340, 184) planks(seat, OAK, { vert = false, w = 5, base = 5, ox = 180 }) for x = 291, 339 do c:put(x, 180, OAK[6]) end inkd(seat)
  for y = 185, 186 do for x = 292, 338 do tint(x, y, SHADE, .35) end end
  for _, x in ipairs({ 292, 335 }) do local l = rect(x, 185, x + 2, 193) fill(l, OAK[3]) inkd(l) end
  -- basket of bread on the bench
  local bs = poly{ {300, 172}, {316, 172}, {314, 180}, {302, 180} }
  planks(bs, MUST, { w = 2, vert = false, base = 4, ox = 172 }) inkd(bs)
  local hd = c:line(P{ {301, 172}, {308, 165}, {315, 172} }, 1) fill(hd, MUST[2])
  for k = 0, 2 do local lf = c:rrect(302 + k * 4, 169, 306 + k * 4, 172, 1) tex(lf, function(x, y) return y == 169 and GOLDL[6] or ORANGE[4] end) c:rim(lf, ORANGE[1]) end
  -- teacup + saucer
  fill(rect(322, 176, 326, 179), CREAM[6]) c:put(327, 177, CREAM[5]) fill(rect(320, 179, 328, 179), CREAM[4]) c:rim(rect(322, 176, 326, 179), INK)
  wisp(324, 174, 5, 9)
  -- flower pail at the board foot
  local pl = poly{ {360, 184}, {370, 184}, {369, 192}, {361, 192} } fill(pl, IRON[4]) fill(rect(361, 186, 369, 186), IRON[2]) inkd(pl)
  for k = 0, 4 do fill(rect(360 + k * 2, 179 + (k % 2) * 2, 361 + k * 2, 183), (k % 2 == 0) and PURP[5] or GOLDL[5]) end
end

---------------------------------------------------------------- 10. WILD TRAIL: old-tree arch into the woods
do
  canopy({ {424, 64, 54, 30}, {392, 90, 22, 16}, {458, 92, 26, 22}, {428, 104, 30, 10}, {376, 62, 18, 14} }, LEAFS, 81, 350, 20, 479, 118, { ink = true })
  -- dark woods tunnel
  local tun = poly{ {408, 214}, {446, 214}, {448, 118}, {408, 118} }
  tex(tun, function(x, y)
    local d = abs(x - 428) / 20
    local i = 3 + floor(d * 2) - ((y < 150) and 1 or 0)
    if hash(floor(x / 3), floor(y / 3), 82) < .2 then i = i + 1 end
    return R(LEAFD, i)
  end)
  -- far bright clearing
  local cl = c:rrect(420, 140, 436, 162, 4)
  tex(cl, function(x, y) local t = (y - 140) / 22 if (x + y) % 2 == 0 and t > .7 then return "#a8c070" end return t < .5 and "#f4e6a8" or "#d8d488" end)
  for _, s in ipairs({ {417, 148}, {438, 152}, {425, 136} }) do c:put(s[1], s[2], "#f0e09a") end
  -- trail
  local tr = poly{ {406, 216}, {450, 216}, {438, 186}, {432, 162}, {424, 162}, {418, 186} }
  tex(tr, function(x, y) local i = (y < 180) and 4 or 5 local h = hash(x, y, 83) if h < .1 then i = i - 1 elseif h > .93 then i = i + 1 end
    local col = R(DIRT, i) if y < 186 then col = mix(col, LEAFD[3], (186 - y) / 24 * .5) end return col end)
  for _, s in ipairs({ {418, 206, 430, 211}, {424, 194, 433, 198}, {427, 184, 434, 187}, {429, 176, 434, 178} }) do
    local m = c:rrect(s[1], s[2], s[3], s[4], 1) tex(m, function(x, y) return y == s[2] and WSTONE[6] or WSTONE[4] end) c:rim(m, WSTONE[1])
  end
  -- gnarled trunks leaning into an arch
  trunk({ {390, 218}, {414, 218}, {410, 196}, {410, 160}, {414, 132}, {422, 114}, {432, 104}, {426, 100}, {414, 108}, {404, 128}, {398, 160}, {396, 196} }, BROWNR, 84)
  trunk({ {442, 218}, {462, 218}, {460, 196}, {460, 160}, {456, 128}, {446, 108}, {432, 100}, {428, 104}, {440, 114}, {448, 132}, {450, 160}, {448, 196} }, BROWNR, 85)
  -- roots
  for _, r in ipairs({ { {386, 218}, {394, 210}, {398, 212} }, { {414, 218}, {410, 210} }, { {440, 218}, {446, 208} }, { {462, 210}, {468, 218} } }) do
    local m = c:line(P(r), 3) tex(m, function(x, y) return (y % 2 == 0) and BROWNR[4] or BROWNR[3] end) c:rim(m, INK)
  end
  -- knot hole + moss
  fill(c:rrect(400, 150, 404, 156, 1), BROWNR[1]) c:put(401, 151, BROWNR[3])
  for i = 1, 20 do local y = 120 + floor(hash(i, 1, 86) * 90) c:put(410 - floor((y - 120) / 30), y, LEAFG[4]) c:put(459 - floor((y - 120) / 40), y, LEAFG[3]) end
  -- leafy crown on the arch + hanging vines
  for i, p in ipairs({ {404, 104}, {414, 96}, {426, 94}, {438, 96}, {448, 104}, {398, 116}, {454, 116} }) do leaf(LEAF2, p[1], p[2], (i % 3 == 0) and LEAFG or LEAFS) end
  for _, v in ipairs({ {416, 112, 134}, {438, 110, 128}, {426, 106, 120} }) do
    for y = v[2], v[3] do c:put(v[1] + floor(sin(y / 4) * 1.5), y, LEAFS[3]) end
    for y = v[2] + 4, v[3], 6 do leaf(LEAF, v[1] - 3 + ((y / 6) % 2 == 0 and -2 or 2), y, LEAFS, { rim = false }) end
  end
  -- hanging trail sign (leaf + arrow pictogram) on chains from the arch
  for y = 108, 120 do c:put(422, y, (y % 2 == 0) and IRON[4] or IRON[2]) c:put(436, y, (y % 2 == 0) and IRON[4] or IRON[2]) end
  local sg = rect(416, 121, 442, 132)
  planks(sg, OAK, { vert = false, w = 4, base = 5, ox = 121 }) inkd(sg)
  leaf(LEAF, 419, 123, LEAFG, { rim = false })
  fill(rect(428, 126, 436, 127), CREAM[6]) fill(poly{ {436, 123}, {440, 126.5}, {436, 130} }, CREAM[6])
  -- ferns, mushrooms, brambles at the feet
  fern(388, 214, 5, 1) fern(404, 216, 4, 2) fern(466, 214, 5, 3) fern(452, 216, 4, 4)
  mushroom(396, 214, 3) mushroom(401, 216, 2) mushroom(455, 213, 3)
  for i = 1, 10 do local x, y = 444 + floor(hash(i, 1, 87) * 18), 196 + floor(hash(i, 2, 87) * 16)
    c:put(x, y, LEAFS[3]) c:put(x + 1, y, LEAFS[4]) if i % 3 == 0 then fill(rect(x, y - 1, x + 1, y), PURP[2]) c:put(x, y - 1, PURP[5]) end end
  castShadow(396, 462, 218, 12, 4, .3)
end

---------------------------------------------------------------- 11. YOUR GARDEN (fenced veg plot)
do
  -- bean trellis + sunflowers at the back
  for i = 0, 7 do
    local x = 40 + i * 11
    local p = c:line(P{ {x, 186}, {x + 1, 168} }, 1) fill(p, OAK[4]) c:put(x + 1, 167, OAK[6])
  end
  for x = 40, 118 do c:put(x, 170, OAK[3]) end
  for i = 0, 6 do
    for y = 170, 186 do local x = 42 + i * 11 + floor(sin(y / 2 + i) * 2) c:put(x, y, LEAFS[4]) if y % 3 == 0 then leaf(LEAF, x - 3, y - 3, LEAFS, { rim = false }) end end
    fill(rect(46 + i * 11, 176, 46 + i * 11, 180), LEAFG[5]) fill(rect(39 + i * 11, 180, 39 + i * 11, 183), LEAFG[5])
  end
  for _, s in ipairs({ {32, 166}, {122, 168} }) do
    for y = s[2] + 6, 190 do c:put(s[1], y, LEAFS[3]) c:put(s[1] + 1, y, LEAFS[2]) end
    leaf(LEAF, s[1] - 7, s[2] + 12, LEAFS) leaf(LEAF, s[1] + 2, s[2] + 16, LEAFS)
    local hd = c:ellipse(s[1], s[2] + 1, 5, 5)
    tex(hd, function(x, y) local d = abs(x - s[1]) + abs(y - s[2] - 1) if d <= 2 then return OAK[2] end return (x + y < s[1] + s[2] + 1) and GOLDL[6] or GOLDL[4] end)
    c:rim(hd, ORANGE[1]) c:put(s[1] - 1, s[2], OAK[4])
  end
  -- soil bed
  local bed = poly{ {34, 188}, {120, 188}, {124, 248}, {30, 248} }
  local rowsY = { 188, 199, 211, 224, 238, 249 }
  tex(bed, function(x, y)
    local k = 1 for j = 1, #rowsY - 1 do if y >= rowsY[j] then k = j end end
    local t = (y - rowsY[k]) / (rowsY[k + 1] - rowsY[k])
    local i = t < .25 and 5 or (t < .7 and 4 or 2)
    if hash(x, y, 91) < .08 then i = i - 1 end
    return R(BROWNR, i)
  end)
  inkd(bed)
  -- crops per furrow
  for k = 0, 8 do -- lettuces
    local x, y = 38 + k * 9, 193
    local m = c:ellipse(x, y, 3, 2) tex(m, function(px, py) return (px < x) and LEAFG[6] or LEAFG[4] end) c:rim(m, LEAFG[1]) c:put(x, y - 1, LEAFG[6])
  end
  for k = 0, 13 do -- carrots: feathery tops + orange shoulders
    local x, y = 37 + k * 6, 206
    fill(rect(x, y, x + 2, y + 1), ORANGE[4]) c:put(x, y, ORANGE[6])
    for j = 0, 2 do c:put(x - 1 + j * 2, y - 2 - (j % 2), LEAFG[5]) c:put(x + j, y - 1, LEAFG[3]) end
    c:put(x + 1, y - 4, LEAFG[6])
  end
  for k = 0, 6 do -- cabbages
    local x, y = 40 + k * 12, 218
    local m = c:ellipse(x, y, 5, 4)
    tex(m, function(px, py) local u = (px - x) + (py - y) if u < -3 then return TEAL[6] elseif u > 3 then return TEAL[3] end return ((px - x) % 3 == 0) and TEAL[4] or TEAL[5] end)
    c:rim(m, TEAL[1]) c:put(x - 1, y - 1, "#d8ecd0")
  end
  for k = 0, 3 do -- pumpkins row (front-left)
    local x = 36 + k * 14
    pumpkin(x, 229 + (k % 2), x + 10, 237 + (k % 2))
    for j = 0, 2 do leaf(LEAF, x + 9 + j, 232 - j * 2, LEAFS, { rim = false }) end
  end
  -- watering can on the soil (front-right)
  do
    local cb = c:rrect(98, 230, 112, 243, 2)
    tex(cb, function(x, y) local u = (x - 98) / 14 return u < .3 and TEAL[5] or (u < .75 and TEAL[4] or TEAL[3]) end)
    fill(rect(98, 233, 112, 233), TEAL[2]) c:put(100, 232, TEAL[6]) c:rim(cb, INK)
    local sp = c:line(P{ {98, 240}, {91, 232}, {89, 231} }, 2) fill(sp, TEAL[4]) c:rim(sp, INK)
    fill(rect(87, 229, 90, 232), TEAL[5]) c:rim(rect(87, 229, 90, 232), INK)
    local hd = c:line(P{ {101, 230}, {103, 226}, {109, 226}, {111, 230} }, 1) fill(hd, TEAL[2])
  end
  -- row markers (seed-packet flags)
  for _, m in ipairs({ {35, 197, GOLDL}, {35, 210, ORANGE}, {35, 222, TEAL} }) do
    fill(rect(m[1], m[2] - 4, m[1], m[2] + 2), OAK[4]) fill(rect(m[1] - 3, m[2] - 6, m[1] + 1, m[2] - 3), R(m[3], 5)) c:rim(rect(m[1] - 3, m[2] - 6, m[1] + 1, m[2] - 3), INK)
  end
  -- hand trowel stuck in the soil
  fill(rect(118, 222, 119, 230), OAK[4]) fill(poly{ {116, 231}, {121, 231}, {119, 237}, {118, 237} }, IRON[5]) c:put(117, 232, IRON[6])
  -- picket fence across the front with an open gate
  local function picket(x, y0, y1, r)
    local m = rect(x, y0 + 2, x + 3, y1):add(rect(x + 1, y0, x + 2, y0 + 1))
    tex(m, function(px, py) return px == x and R(r, 6) or (px == x + 3 and R(r, 3) or R(r, 5)) end)
    inkd(m)
  end
  for x = 28, 126, 6 do if x < 64 or x > 90 then picket(x, 246, 263, CREAM) end end
  for _, y in ipairs({ 250, 258 }) do
    for _, seg in ipairs({ {28, 66}, {90, 128} }) do local rl = rect(seg[1], y, seg[2], y + 1) fill(rl, CREAM[4]) for x = seg[1], seg[2] do c:put(x, y + 2, INK) end end
  end
  -- side fence receding along the right edge
  for k = 0, 6 do local y = 194 + k * 8 local x = 121 + floor(k * .6) picket(x, y - 8, y + 2, CREAM) end
  -- open gate swung inward
  for k = 0, 3 do picket(68 + k * 4, 241 + k, 256 + k, CREAM) end
  fill(rect(68, 247, 84, 248), CREAM[3])
  castShadow(28, 126, 263, 6, 3, .3)
end

---------------------------------------------------------------- 12. wheelbarrow beside the plot
do
  local tray = poly{ {128, 244}, {152, 244}, {148, 254}, {132, 254} }
  planks(tray, GREEN, { vert = false, w = 3, base = 4, ox = 244 }) inkd(tray)
  fill(rect(130, 241, 150, 244), BROWNR[4]) for x = 132, 148, 3 do c:put(x, 241, BROWNR[6]) end
  fill(rect(138, 238, 139, 241), LEAFG[4]) c:put(137, 238, LEAFG[6]) c:put(140, 239, LEAFG[5])
  local wh = c:ellipse(146, 257, 4, 4) tex(wh, function(x, y) return (x == 146 or y == 257) and IRON[2] or IRON[4] end) c:rim(wh, INK) c:put(146, 257, IRON[6])
  local hd = c:line(P{ {130, 252}, {124, 258} }, 2) fill(hd, OAK[4]) c:rim(hd, INK)
  fill(rect(132, 255, 133, 262), OAK[3])
end

---------------------------------------------------------------- 13. VILLAGE SIGNPOST
do
  castShadow(328, 340, 250, 12, 4, .34)
  local base = c:rrect(322, 242, 346, 250, 2)
  stones(base, WSTONE, { bh = 3, bw = 6, base = 4, oy = 242, ox = 322 }) inkd(base)
  local post = rect(331, 200, 335, 243)
  planks(post, OAK, { w = 6, base = 4, ox = 331 }) for y = 200, 243 do c:put(332, y, OAK[6]) c:put(335, y, OAK[2]) end inkd(post)
  fill(poly{ {329, 201}, {333, 196}, {337, 201} }, REDR[4]) c:rim(poly{ {329, 201}, {333, 196}, {337, 201} }, INK)
  local function board(pts, r, oy)
    local m = poly(pts)
    planks(m, r, { vert = false, w = 3, base = 5, ox = oy })
    m:each(function(x, y) if not m:has(x, y - 1) then c:put(x, y, R(r, 6)) end end)
    inkd(m)
    return m
  end
  board({ {311, 209}, {317, 203}, {346, 203}, {346, 214}, {317, 214} }, OAK, 203)
  board({ {320, 218}, {350, 218}, {357, 224}, {350, 230}, {320, 230} }, TEAL, 218)
  board({ {313, 237}, {319, 232}, {343, 232}, {343, 241}, {319, 241} }, REDR, 232)
  -- pictograms: home, woods, well
  fill(poly{ {321, 209}, {325, 205}, {329, 209} }, REDR[4]) fill(rect(322, 209, 328, 212), CREAM[6]) c:put(325, 211, OAK[2])
  fill(rect(338, 208, 341, 208), OAK[2]) fill(rect(338, 210, 343, 210), OAK[2])
  fill(c:ellipse(342, 222, 3, 3), LEAFS[5]) fill(rect(342, 225, 342, 228), OAK[2]) c:put(341, 221, LEAFS[6])
  fill(rect(325, 223, 336, 224), CREAM[6]) fill(poly{ {336, 221}, {339, 223.5}, {336, 226} }, CREAM[6])
  fill(rect(323, 236, 329, 239), CREAM[5]) fill(rect(322, 234, 330, 234), CREAM[6]) fill(rect(324, 235, 328, 235), "#3e5e8c")
  for _, n in ipairs({ {333, 208}, {333, 223}, {333, 236} }) do c:put(n[1], n[2], IRON[5]) end
  -- flowers around the plinth
  for k = 0, 6 do flower(318 + k * 5, 246 + (k % 2) * 2, ({ GOLDL, PINK, PURP })[k % 3 + 1]) tuft(320 + k * 5, 249, 2) end
end

---------------------------------------------------------------- 14. gate frame (timber + stone), summer foliage, bunting, lanterns
local function bunting(xa, ya, xb, yb, sag, seed)
  local n = floor((xb - xa) / 11)
  local function yat(t) return ya + (yb - ya) * t + sag * 4 * t * (1 - t) end
  local prev
  for x = xa, xb do local t = (x - xa) / (xb - xa) local y = floor(yat(t) + .5)
    c:put(x, y, "#4a3030") if prev and abs(prev - y) > 1 then for yy = min(prev, y), max(prev, y) do c:put(x, yy, "#4a3030") end end prev = y end
  local cols = { REDR, GOLDL, TEAL, PINK, SBLUE, CREAM }
  for i = 1, n - 1 do
    local t = i / n local fx = floor(xa + (xb - xa) * t) local fy = floor(yat(t) + .5)
    local r = cols[(i + seed) % #cols + 1]
    local m = poly{ {fx - 4, fy + 1}, {fx + 4, fy + 1}, {fx, fy + 10} }
    tex(m, function(x, y) return (x < fx) and R(r, 5) or R(r, 4) end)
    c:rim(m, R(r, 1)) c:put(fx - 2, fy + 2, R(r, 6))
  end
end
bunting(18, 13, 200, 24, 14, 0)
bunting(280, 24, 462, 13, 14, 3)
do
  local lp, rp = rect(0, 0, 17, 269), rect(462, 0, 479, 269)
  stones(lp, STONE, { bh = 7, bw = 12, base = 4 }) stones(rp, STONE, { bh = 7, bw = 12, base = 4, ox = 2 })
  for y = 0, 269 do
    for x = 13, 17 do tint(x, y, SHADE, .32) end
    for x = 462, 465 do tint(x, y, "#ffe0a0", .15) end
    for x = 474, 479 do tint(x, y, SHADE, .2) end
    c:put(17, y, INK) c:put(462, y, INK)
  end
  for i = 1, 30 do local x, y = floor(hash(i, 1, 95) * 12), 40 + floor(hash(i, 2, 95) * 200) c:put(x, y, LEAFG[3]) c:put(x + 1, y, LEAFG[4]) end
  stones(rect(0, 252, 20, 269), STONE, { bh = 6, bw = 10, base = 5, oy = 252 }) inkd(rect(0, 252, 20, 269))
  stones(rect(459, 252, 479, 269), STONE, { bh = 6, bw = 10, base = 4, oy = 252 }) inkd(rect(459, 252, 479, 269))
  local tb = rect(0, 0, 479, 11)
  planks(tb, TIMB, { vert = false, w = 4, base = 4, ox = 0 })
  for x = 0, 479 do c:put(x, 11, INK) c:put(x, 10, TIMB[2]) c:put(x, 0, TIMB[5]) end
  for x = 30, 460, 60 do fill(rect(x, 4, x + 2, 6), IRON[3]) c:put(x, 4, IRON[5]) end
  for _, b in ipairs({ { 18, 38, 40, 12 }, { 461, 38, 439, 12 } }) do
    local m = c:line(P{ {b[1], b[2]}, {b[3], b[4]} }, 5)
    tex(m, function(x, y) if not m:has(x, y - 1) then return TIMB[5] elseif not m:has(x, y + 1) then return TIMB[1] end return TIMB[3] end)
    inkd(m)
  end
  -- carved plaque: little cottage
  local pq = c:rrect(224, 0, 256, 15, 3)
  planks(pq, OAK, { w = 3, vert = false, base = 5, ox = 0 }) inkd(pq)
  fill(poly{ {232, 8}, {240, 2}, {248, 8} }, REDR[4]) fill(rect(234, 8, 246, 13), CREAM[5]) fill(rect(239, 10, 241, 13), OAK[2]) c:put(236, 10, "#ffd870")
  -- summer foliage + roses spilling over the corners
  local function cluster(x0, x1, y0, y1, n, seed, droop)
    for i = 1, n do
      local u = hash(i, 1, seed) local x = floor(x0 + (x1 - x0) * u)
      local yl = y1 - floor((y1 - y0) * (droop and u or (1 - u)))
      local y = y0 + floor(hash(i, 2, seed) * max(1, yl - y0))
      local r = ({ LEAFS, LEAFG, LEAFS, GREEN })[1 + floor(hash(i, 3, seed) * 4)]
      if hash(i, 4, seed) < .6 then leaf(LEAF2, x, y, r) else leaf(LEAF, x, y, r) end
      if hash(i, 5, seed) < .3 then local fx, fy = x + 3, y + 3 fill(rect(fx, fy, fx + 2, fy + 2), PINK[5]) c:put(fx, fy, PINK[6]) c:put(fx + 2, fy + 2, PINK[3]) end
    end
  end
  cluster(-4, 70, -4, 30, 34, 91, false) cluster(-4, 26, 20, 50, 10, 92, false)
  cluster(410, 482, -4, 30, 34, 93, true) cluster(454, 482, 20, 50, 10, 94, true)
  cluster(140, 180, -3, 8, 6, 95, false) cluster(300, 340, -3, 8, 6, 96, true)
  for _, v in ipairs({ { 24, 12, 52 }, { 66, 12, 30 }, { 455, 12, 52 }, { 414, 12, 30 } }) do
    for y = v[2], v[3] do c:put(v[1] + floor(sin(y / 4) * 1.5), y, LEAFS[2]) end
    for y = v[2] + 6, v[3] - 4, 8 do leaf(LEAF, v[1] - 3 + ((y / 8) % 2 == 0 and -2 or 2), y, LEAFS) end
  end
  for _, lx0 in ipairs({ 40, 440 }) do
    for y = 12, 19 do c:put(lx0, y, (y % 2 == 0) and IRON[4] or IRON[2]) end
    local capm = poly{ {lx0 - 6, 24}, {lx0 - 3, 20}, {lx0 + 4, 20}, {lx0 + 7, 24} }
    fill(capm, IRON[3]) inkd(capm) for x = lx0 - 3, lx0 + 3 do c:put(x, 20, IRON[5]) end
    local body = rect(lx0 - 5, 25, lx0 + 5, 38)
    tex(body, function(x, y) local t = (y - 25) / 13 return t < .35 and "#fff0b0" or (t < .7 and "#ffd06a" or "#f4a040") end)
    for y = 25, 38 do c:put(lx0 - 5, y, IRON[2]) c:put(lx0 + 5, y, INK) c:put(lx0, y, IRON[2]) end
    fill(rect(lx0 - 6, 39, lx0 + 6, 41), IRON[3]) inkd(rect(lx0 - 6, 39, lx0 + 6, 41))
    c:put(lx0 - 3, 27, "#fff8e0") c:put(lx0 - 3, 28, "#fff8e0")
    fill(rect(lx0 - 1, 42, lx0 + 1, 43), IRON[2])
  end
end

---------------------------------------------------------------- 15. light
glow(40, 32, 26, "#ffd890", .3) glow(440, 32, 26, "#ffd890", .3)
glow(91, 117, 12, "#ffd890", .22) glow(150, 124, 10, "#ffd890", .2)
glow(46, 112, 18, "#ffe0a0", .12) glow(77, 118, 12, "#ffe0a0", .14)
glow(428, 151, 14, "#f8e8a8", .2)
-- golden rim light on the sun-facing (left) edges of the main props
local function rimLight(x0, y0, x1, y1)
  for y = y0, y1 do for x = x0, x1 do
    local cur, lft = c:get(x, y), c:get(x - 1, y)
    if lft == INK and cur and cur ~= INK and hash(x, y, 99) < .7 then tint(x, y, "#ffe8a0", .35) end
  end end
end
rimLight(130, 143, 218, 212) rimLight(288, 128, 382, 194) rimLight(310, 198, 358, 250) rimLight(28, 160, 126, 264)

---------------------------------------------------------------- finish, check, save (layout json is the unchanged contract file)
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
print("saved " .. NAME)

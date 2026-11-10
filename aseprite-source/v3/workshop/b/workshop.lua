-- Workshop mockup B: "Seven nooks" - a gnome-built hall seen as a doll's-house cutaway.
-- Upper gallery: pantry | hearth | tools | potting.  Ground floor: cauldron | building yard | loom + paint table.
-- Everything is painted into a Lua buffer (hard pixels), lit by a stepped lamp pass, then put on an HP canvas.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local W, H = 480, 270
local floor, ceil, max, min, sin, abs, sqrt, pi = math.floor, math.ceil, math.max, math.min, math.sin, math.abs, math.sqrt, math.pi

local INK = "#2b1c26"
local TIMB   = {"#2a1a22","#46282a","#643a30","#845236","#a46e44","#c48e5a"}
local OAK    = {"#30202a","#4e3230","#70483a","#946244","#b88058","#d8a474"}
local CREAM  = {"#5e4658","#8e7476","#bca290","#dcc4a6","#eed9b8","#f8eacc"}
local ROSE   = {"#4e2840","#7c4458","#aa6670","#cc8a88","#e6ae9e","#f6d0bc"}
local GREEN  = {"#1c3434","#2a5240","#3a704a","#529054","#78b064","#a8d080"}
local LEAF   = {"#26341c","#3a5222","#557228","#7a922e","#a4b444","#d0cc6a"}
local SBLUE  = {"#20264a","#323e6a","#46598a","#6076a4","#7e94bc","#a8b8d4"}
local BARN   = {"#38181e","#5c2428","#843230","#a6483a","#c66648","#e08c62"}
local GOLD   = {"#5a3a14","#8a5a1a","#bc8420","#e0aa2c","#f4cc4a","#fce67c"}
local STONE  = {"#382e40","#5a4e5c","#7a6e76","#9a8e90","#b8aca6","#d6cabc"}
local TEAL   = {"#14303a","#1e4a52","#2c686a","#408a84","#64aa9a","#94c8b2"}
local VIOLET = {"#2c2052","#443478","#5e4c9a","#7e68b8","#a290d0","#c8b8ec"}
local PINK   = {"#4e2840","#7c3c5c","#a85478","#d07494","#ec9ab4","#fac4d4"}
local DIRT   = {"#4a3428","#6a502e","#8a6a34","#a8863c","#c2a04a","#d8b862"}
local IRON   = {"#24202e","#3a3446","#545066","#727088","#9696a8","#bcbccc"}
local COPPER = {"#4a2018","#7a3420","#a85230","#cc7444","#e89a5c","#f8c888"}
local BREW   = {"#2a7a52","#3a9a62","#58c07a","#7ad88c","#a8f0a0","#d8fcd0"}
local BURLAP = {"#4a3428","#6e5238","#927048","#b08e60","#c8a878","#dcc294"}

local function hash(x, y, s)
  x, y, s = floor(x), floor(y), floor(s or 0)
  local n = (x * 374761393 + y * 668265263 + s * 1013904223) & 0xffffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0xffffffff
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65535
end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local mixc = {}
local function mix(a, b, t)
  local k = a .. b .. t
  local v = mixc[k]
  if v then return v end
  local r1, g1, b1 = rgb(a); local r2, g2, b2 = rgb(b)
  v = string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
  mixc[k] = v
  return v
end

---------------------------------------------------------------- buffer + primitives
local buf, emit = {}, {}
local emitOn = false
local function P(x, y, col)
  if x >= 0 and x < W and y >= 0 and y < H and col then local k = y * W + x; buf[k] = col; emit[k] = emitOn or nil end
end
local function G(x, y) return buf[y * W + x] end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function EM(f) emitOn = true; f(); emitOn = false end
local function dk(x0, y0, x1, y1, t, col)  -- darken an area (wall / contact shadow)
  for y = y0, y1 do for x = x0, x1 do local c = G(x, y); if c then P(x, y, mix(c, col or "#2b1c36", t or .22)) end end end
end
local function shadow(cx, cy, rx, ry, t)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    if ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 then local c = G(x, y); if c then P(x, y, mix(c, "#2b1c36", t or .34)) end end
  end end
end
-- filled shape from a predicate, with a 1px dark edge
local function blob(x0, y0, x1, y1, inside, shade, ink)
  local m = {}
  for y = y0, y1 do for x = x0, x1 do if inside(x, y) then m[y * 1000 + x] = true end end end
  for y = y0, y1 do for x = x0, x1 do if m[y * 1000 + x] then
    local edge = not (m[y * 1000 + x - 1] and m[y * 1000 + x + 1] and m[(y - 1) * 1000 + x] and m[(y + 1) * 1000 + x])
    P(x, y, edge and (ink or INK) or shade(x, y))
  end end end
end
local function box(x0, y0, x1, y1, ramp, b, o)
  o = o or {}; b = b or 4
  local ink = o.ink or INK
  for y = y0, y1 do for x = x0, x1 do
    local col
    if x == x0 or x == x1 or y == y0 or y == y1 then col = ink
    else
      local lit = (y - y0 <= (o.lit or 1)) or (x == x0 + 1)
      local sh = (y1 - y <= (o.shade or 1)) or (x1 - x <= 1)
      if sh then col = ramp[max(1, b - 1)] elseif lit then col = ramp[min(6, b + 1)] else col = ramp[b] end
    end
    P(x, y, col)
  end end
end
local function grain(x0, y0, x1, y1, col, vert, seed, dens)
  for y = y0, y1 do for x = x0, x1 do
    local a, b = vert and x or y, vert and y or x
    if hash(a, b // 5, seed) > (dens or .86) then P(x, y, col) end
  end end
end
local function ell(cx, cy, rx, ry, ramp, o)
  o = o or {}
  blob(floor(cx - rx), floor(cy - ry), ceil(cx + rx), ceil(cy + ry),
    function(x, y) return ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 end,
    function(x, y)
      local nx, ny = (x - cx) / rx, (y - cy) / ry
      local v = .5 - .5 * (nx * .6 + ny * .8)
      return ramp[max(1, min(6, floor(v * 5) + 1 + (o.off or 0)))]
    end, o.ink or ramp[1])
end
local function pip(pts, x, y)
  local inside = false
  local j = #pts
  for i = 1, #pts do
    local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
    if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then inside = not inside end
    j = i
  end
  return inside
end
local function poly(pts, shade, ink)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0 = min(x0, p[1]); x1 = max(x1, p[1]); y0 = min(y0, p[2]); y1 = max(y1, p[2]) end
  blob(floor(x0), floor(y0), ceil(x1), ceil(y1), function(x, y) return pip(pts, x + .5, y + .5) end,
    type(shade) == "function" and shade or function() return shade end, ink)
end
local function line(x0, y0, x1, y1, col)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n; P(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), col) end
end
local function planks(x0, y0, x1, y1, ramp, o)
  o = o or {}
  local w, base, vert, s = o.w or 8, o.base or 4, o.vert ~= false, o.seed or 1
  for y = y0, y1 do for x = x0, x1 do
    local a, b = vert and x or y, vert and y or x
    local k = a // w; local p = a - k * w
    local tone = base + ((hash(k, 0, s) > .5) and 0 or -1)
    local col = ramp[tone]
    if p == 0 then col = ramp[max(1, tone - 2)]
    elseif p == 1 then col = ramp[min(6, tone + 1)]
    elseif hash(a, b // 6, s + 3) > .9 then col = ramp[max(1, tone - 1)] end
    P(x, y, col)
  end end
end
local function plaster(x0, y0, x1, y1, cols, seed)
  for y = y0, y1 do for x = x0, x1 do
    local v = hash(x // 4, y // 2, seed)
    P(x, y, v > .93 and cols[3] or (v < .05 and cols[1] or cols[2]))
  end end
end
local function stonewall(x0, y0, x1, y1, ramp, b, seed, rh, bw)
  for y = y0, y1 do
    local row = (y - y0) // rh; local ry = (y - y0) % rh
    for x = x0, x1 do
      local off = (row % 2) * (bw // 2) + floor(hash(row, 0, seed) * 4)
      local k = (x + off) // bw; local px = (x + off) % bw
      local t = b + ((hash(k, row, seed) > .6) and 1 or 0) - ((hash(k, row, seed + 1) > .75) and 1 or 0)
      local col
      if ry == 0 or px == 0 then col = ramp[max(1, b - 2)]
      elseif ry == 1 then col = ramp[min(6, t + 1)]
      else col = ramp[t]; if hash(x // 2, y, seed + 2) > .95 then col = ramp[max(1, t - 1)] end end
      P(x, y, col)
    end
  end
end

local lamps = {}
local function lamp(x, y, r, s, ky, clip) lamps[#lamps + 1] = { x = x, y = y, r = r, s = s, ky = ky or 1, clip = clip } end

---------------------------------------------------------------- small reusable things
local function lantern(x, y0, chain)
  for y = y0, y0 + chain - 1 do P(x, y, (y % 2 == 0) and INK or IRON[4]) end
  local t = y0 + chain
  R(x - 2, t, x + 2, t, INK); R(x - 4, t + 1, x + 4, t + 2, INK); R(x - 3, t + 1, x + 3, t + 1, IRON[5])
  R(x - 4, t + 3, x + 4, t + 10, INK)
  EM(function()
    R(x - 3, t + 3, x + 3, t + 10, "#f4bc50")
    R(x - 2, t + 4, x + 2, t + 10, "#fcdc80")
    R(x - 1, t + 5, x + 1, t + 9, "#fff4c4")
  end)
  R(x - 4, t + 11, x + 4, t + 12, INK); R(x - 3, t + 11, x + 3, t + 11, IRON[4]); R(x - 1, t + 13, x + 1, t + 13, INK)
end
local function herb(x, y0, ramp, tie)
  R(x, y0, x, y0 + 2, INK)
  for i = -3, 3 do
    local h = 11 - abs(i) - floor(hash(x, i, 7) * 3)
    R(x + i, y0 + 5, x + i, y0 + 5 + h, (i % 2 == 0) and ramp[4] or ramp[5])
    P(x + i, y0 + 6 + h, ramp[2])
  end
  R(x - 4, y0 + 6, x - 4, y0 + 10, ramp[2]); R(x + 4, y0 + 6, x + 4, y0 + 10, ramp[2])
  R(x - 2, y0 + 3, x + 2, y0 + 5, tie or ROSE[4]); R(x - 2, y0 + 3, x + 2, y0 + 3, INK)
end
local function jar(x, yb, w, h, ramp, lid)
  local y0 = yb - h + 1
  blob(x, y0 + 3, x + w - 1, yb,
    function(px, py) return not ((px == x or px == x + w - 1) and py == y0 + 3) end,
    function(px, py)
      if py <= y0 + 5 then return ramp[6] end
      if px <= x + 2 then return ramp[6] end
      if px >= x + w - 3 or py >= yb - 1 then return ramp[3] end
      return ramp[4]
    end, ramp[1])
  R(x + 4, y0 + 8, x + w - 4, y0 + 10, CREAM[5])
  box(x + 1, y0, x + w - 2, y0 + 3, lid or OAK, 5, { lit = 1, shade = 0 })
end
local function bottle(x, yb, w, h, ramp)
  local cx = x + w // 2; local y0 = yb - h + 1
  R(cx - 2, y0 + 2, cx + 2, y0 + 6, ramp[1]); R(cx - 1, y0 + 2, cx + 1, y0 + 6, ramp[5])
  R(cx - 1, y0, cx + 1, y0 + 1, OAK[5]); P(cx - 1, y0, OAK[6])
  blob(x, y0 + 6, x + w - 1, yb,
    function(px, py) local e = (px == x or px == x + w - 1); return not (e and (py <= y0 + 7)) end,
    function(px, py)
      if px <= x + 2 and py > y0 + 7 then return ramp[6] end
      if py <= y0 + 8 then return ramp[5] end
      if px >= x + w - 3 or py >= yb - 1 then return ramp[3] end
      return ramp[4]
    end, ramp[1])
end
local function flask(cx, yb, r, ramp)
  R(cx - 2, yb - 2 * r - 5, cx + 2, yb - 2 * r + 1, ramp[1]); R(cx - 1, yb - 2 * r - 5, cx + 1, yb - 2 * r + 1, ramp[5])
  R(cx - 1, yb - 2 * r - 7, cx + 1, yb - 2 * r - 6, OAK[5])
  ell(cx, yb - r, r, r, ramp)
  R(cx - r + 2, yb - r - 2, cx - r + 3, yb - r, ramp[6])
end
local function tpot(x, yb, w, h, ramp)
  local y0 = yb - h + 1
  blob(x + 1, y0 + 2, x + w - 2, yb,
    function(px, py) local ins = floor((py - y0) / h * 2.4); return px >= x + 1 + ins and px <= x + w - 2 - ins end,
    function(px, py) if px <= x + 3 then return ramp[6] end; if px >= x + w - 5 then return ramp[3] end; return ramp[5] end, ramp[1])
  box(x, y0, x + w - 1, y0 + 3, ramp, 5, { lit = 1, shade = 0, ink = ramp[1] })
end
local function sprout(x, yb, h)
  R(x, yb - h + 1, x + 1, yb, GREEN[4])
  R(x - 3, yb - h, x - 1, yb - h + 1, GREEN[5]); P(x - 3, yb - h - 1, GREEN[6]); P(x - 2, yb - h - 1, GREEN[6])
  R(x + 2, yb - h - 1, x + 4, yb - h, GREEN[5]); P(x + 4, yb - h - 2, GREEN[6]); P(x + 3, yb - h - 2, GREEN[6])
  P(x - 3, yb - h + 2, GREEN[2]); P(x + 4, yb - h + 1, GREEN[2])
end

---------------------------------------------------------------- geometry of the house
local UB = { { 8, 115 }, { 126, 233 }, { 244, 351 }, { 362, 471 } }   -- upper bays (x0, x1)
local LB = { { 8, 153 }, { 166, 313 }, { 326, 471 } }                  -- lower bays
local UT, UF = 10, 111      -- upper storey interior rows
local LT, LF = 124, 222     -- lower storey wall rows; floor is 223..269

---------------------------------------------------------------- back walls
plaster(8, UT, 115, UF, { CREAM[4], CREAM[5], CREAM[6] }, 1)
plaster(126, UT, 233, UF, { CREAM[3], CREAM[4], CREAM[5] }, 2)
planks(244, UT, 351, UF, OAK, { w = 9, base = 4, seed = 3 })
plaster(362, UT, 471, UF, { "#b4ba94", "#c8cca6", "#d8dab6" }, 4)
R(8, 108, 115, UF, TIMB[4]); R(8, 108, 115, 108, TIMB[2]); R(8, 109, 115, 109, TIMB[5])
R(362, 108, 471, UF, TIMB[4]); R(362, 108, 471, 108, TIMB[2]); R(362, 109, 471, 109, TIMB[5])
stonewall(8, LT, 153, LF, STONE, 4, 5, 9, 18)
local SLATE = {"#2e2a3a","#444a5a","#59636e","#6e7c82","#84938f","#9aa89e"}
planks(166, LT, 313, LF, SLATE, { w = 11, base = 5, vert = false, seed = 6 })
plaster(326, LT, 471, LF, { "#d6b29a", "#e6c6aa", "#f0d6ba" }, 6)
planks(326, 194, 471, LF, OAK, { w = 8, base = 4, seed = 8 })
R(326, 191, 471, 193, TIMB[4]); R(326, 191, 471, 191, TIMB[6]); R(326, 193, 471, 193, INK)

---------------------------------------------------------------- floor: wide boards in rough perspective
local rows = { 223, 229, 236, 244, 253, 263, 270 }
for r = 1, #rows - 1 do
  for y = rows[r], rows[r + 1] - 1 do
    local ry = y - rows[r]
    local pw = 44 + r * 12
    for x = 0, W - 1 do
      local off = (r * 37) % pw
      local k = (x + off) // pw; local px = (x + off) % pw
      local tone = 4 + ((hash(k, r, 11) > .6) and 1 or 0)
      local col
      if ry == 0 then col = OAK[2]
      elseif px == 0 then col = OAK[2]
      elseif ry == 1 then col = OAK[tone + 1]
      else col = OAK[tone]; if hash(x // 7, y, 14 + r) > .93 then col = OAK[tone - 1] end end
      P(x, y, col)
    end
  end
end
R(0, 223, W - 1, 223, INK)

---------------------------------------------------------------- timber frame
-- roof beam
R(0, 0, W - 1, 9, TIMB[5]); grain(0, 2, W - 1, 6, TIMB[4], false, 21, .8)
R(0, 0, W - 1, 0, TIMB[3]); R(0, 1, W - 1, 1, TIMB[6])
for x = 0, W - 1 do local s = x % 8; P(x, 7, s < 5 and TIMB[4] or TIMB[2]); P(x, 8, (s >= 1 and s < 4) and TIMB[4] or TIMB[2]) end
R(0, 9, W - 1, 9, INK)
-- gallery beam with joist ends
R(0, 112, W - 1, 123, TIMB[4]); grain(0, 114, W - 1, 120, TIMB[3], false, 22, .8)
R(0, 112, W - 1, 112, TIMB[6]); R(0, 113, W - 1, 113, TIMB[5]); R(0, 121, W - 1, 122, TIMB[2]); R(0, 123, W - 1, 123, INK)
for x = 20, W - 20, 24 do box(x, 114, x + 6, 120, TIMB, 5, { lit = 1, shade = 1 }); R(x + 3, 117, x + 3, 117, TIMB[2]) end

local function post(x0, x1, y0, y1, seed)
  for y = y0, y1 do for x = x0, x1 do
    local col
    if x == x0 or x == x1 then col = INK
    elseif x == x0 + 1 then col = TIMB[6]
    elseif x >= x1 - 2 then col = TIMB[3]
    else col = TIMB[(x == x0 + 2) and 5 or 4]; if hash(x, y // 6, seed) > .8 then col = TIMB[3] end end
    P(x, y, col)
  end end
  box(x0 - 2, y0, x1 + 2, y0 + 5, TIMB, 5, { lit = 1, shade = 1 })      -- carved cap
  R(x0, y0 + 6, x1, y0 + 6, INK); R(x0 + 1, y0 + 7, x1 - 1, y0 + 7, TIMB[2])
  box(x0 - 2, y1 - 5, x1 + 2, y1, TIMB, 4, { lit = 1, shade = 1 })      -- foot
  for _, py in ipairs{ y0 + 11, y1 - 10 } do                              -- pegs
    local cx = (x0 + x1) // 2
    R(cx, py, cx + 1, py + 1, TIMB[2]); P(cx, py, TIMB[6])
  end
end
local function mushcarve(cx, cy)   -- little mushroom relief
  R(cx - 1, cy - 4, cx + 2, cy - 4, TIMB[6]); R(cx - 3, cy - 3, cx + 4, cy - 3, TIMB[6]); R(cx - 4, cy - 2, cx + 5, cy - 1, TIMB[6])
  R(cx + 3, cy - 2, cx + 5, cy - 1, TIMB[5]); R(cx - 4, cy, cx + 5, cy, TIMB[2])
  R(cx - 1, cy + 1, cx + 2, cy + 5, TIMB[6]); R(cx + 2, cy + 1, cx + 2, cy + 5, TIMB[5]); R(cx - 2, cy + 6, cx + 3, cy + 6, TIMB[2])
  R(cx - 2, cy - 2, cx - 1, cy - 2, TIMB[3]); R(cx + 1, cy - 3, cx + 2, cy - 3, TIMB[3])
end
local function acorn(cx, cy)
  R(cx - 2, cy, cx + 3, cy + 1, TIMB[2]); R(cx - 1, cy - 1, cx + 2, cy - 1, TIMB[2]); R(cx, cy - 3, cx + 1, cy - 2, TIMB[2])
  R(cx - 2, cy + 2, cx + 3, cy + 5, TIMB[6]); R(cx + 2, cy + 2, cx + 3, cy + 5, TIMB[5]); R(cx - 1, cy + 6, cx + 2, cy + 6, TIMB[6]); R(cx, cy + 7, cx + 1, cy + 7, TIMB[2])
end
local function brace(cx0, cy0, r, dir)
  local x0, x1 = cx0 - 1, cx0 + r
  if dir < 0 then x0, x1 = cx0 - r, cx0 + 1 end
  blob(x0, cy0 - 1, x1, cy0 + r,
    function(x, y) local u, v = (x - cx0) * dir, y - cy0; return u >= -1 and u <= r and v >= -1 and v <= r and ((u - r) ^ 2 + (v - r) ^ 2 > r * r) end,
    function(x, y) local u, v = (x - cx0) * dir, y - cy0
      local dd = sqrt((u - r) ^ 2 + (v - r) ^ 2) - r
      if dd < 2 then return TIMB[3] end
      if dir > 0 and u <= 0 then return TIMB[6] end
      return (u + v < r * .7) and TIMB[5] or TIMB[4] end)
  local px, py = cx0 + 3 * dir, cy0 + 2
  R(min(px, px + dir), py, max(px, px + dir), py + 1, TIMB[2]); P(px, py, TIMB[6])
end

for _, p in ipairs{ { 0, 7 }, { 116, 125 }, { 234, 243 }, { 352, 361 }, { 472, 479 } } do post(p[1], p[2], UT, UF, p[1]) end
for _, p in ipairs{ { 0, 7 }, { 154, 165 }, { 314, 325 }, { 472, 479 } } do post(p[1], p[2], LT, LF, p[1] + 5) end
for _, b in ipairs(UB) do brace(b[1], UT, 13, 1); brace(b[2], UT, 13, -1) end
for _, b in ipairs(LB) do brace(b[1], LT, 16, 1); brace(b[2], LT, 16, -1) end
mushcarve(120, 62); mushcarve(356, 62)
acorn(159, 166); acorn(319, 166)
acorn(159, 114); acorn(319, 114)

---------------------------------------------------------------- 1 PANTRY (upper bay 1)
dk(26, 36, 103, 107, .2)
R(24, 37, 96, 110, "#4e2c32")
box(22, 36, 26, UF, TIMB, 4); box(94, 36, 98, UF, TIMB, 4)
box(20, 30, 100, 36, TIMB, 5, { lit = 1, shade = 2 })
for x = 28, 90, 8 do R(x, 37, x + 5, 38, TIMB[4]); R(x + 1, 39, x + 4, 39, TIMB[4]); R(x, 40, x + 5, 40, "#3a2028") end
mushcarve(60, 34 - 0 + 0); R(55, 31, 66, 35, TIMB[5]); R(21, 31, 99, 31, TIMB[6])
-- carved cap on the cornice: small acorn pair
for _, ax in ipairs{ 30, 90 } do R(ax - 1, 32, ax + 2, 34, TIMB[3]); P(ax, 33, TIMB[6]) end
R(57, 32, 64, 34, TIMB[6]); R(59, 33, 62, 33, TIMB[3])
local shelves = { 59, 80, 101 }
local rowsP = {
  { { "j", 11, 15, ROSE, CREAM }, { "j", 12, 13, GOLD, OAK }, { "j", 10, 16, GREEN, CREAM }, { "j", 13, 12, BARN, OAK }, { "j", 11, 15, VIOLET, CREAM } },
  { { "j", 12, 14, TEAL, OAK }, { "c", 16, 9 }, { "b", 7, 17, GREEN }, { "b", 7, 15, BARN }, { "j", 13, 13, LEAF, CREAM } },
  { { "j", 14, 16, GOLD, CREAM }, { "s", 16, 15 }, { "j", 12, 12, ROSE, OAK }, { "j", 14, 15, SBLUE, CREAM } },
}
for si, sy in ipairs(shelves) do
  local x = 28 + (si == 3 and 1 or 0)
  for _, it in ipairs(rowsP[si]) do
    local k, w, h = it[1], it[2], it[3]
    local yb = sy - 1
    if k == "j" then jar(x, yb, w, h, it[4], it[5])
    elseif k == "b" then bottle(x, yb, w, h, it[4])
    elseif k == "c" then
      box(x, yb - h + 1, x + w - 1, yb, GOLD, 5, { lit = 2, shade = 2, ink = GOLD[1] })
      poly({ { x + w - 6, yb - h + 1 }, { x + w, yb - h + 1 }, { x + w, yb - 3 } }, "#4e2c32", GOLD[1])
      R(x + 3, yb - 4, x + 4, yb - 3, GOLD[3]); R(x + 7, yb - 6, x + 8, yb - 5, GOLD[3])
    elseif k == "s" then
      blob(x, yb - h + 1, x + w - 1, yb,
        function(px, py) local t = (py - (yb - h + 1)); local ins = t < 3 and 5 or (t < 5 and 3 or (t < 7 and 1 or 0)); return px >= x + ins and px <= x + w - 1 - ins end,
        function(px, py) if px <= x + 3 then return BURLAP[6] end; if px >= x + w - 4 or py >= yb - 1 then return BURLAP[3] end; return ((px + py) % 4 == 0) and BURLAP[4] or BURLAP[5] end, BURLAP[1])
      R(x + 5, yb - h + 4, x + w - 6, yb - h + 5, BARN[4])
    end
    x = x + w + 2
  end
  box(26, sy, 94, sy + 2, OAK, 5, { lit = 1, shade = 0 })
end
box(27, 103, 60, 110, TIMB, 4, { lit = 1, shade = 1 }); box(60, 103, 93, 110, TIMB, 4, { lit = 1, shade = 1 })
R(42, 106, 45, 107, GOLD[5]); R(75, 106, 78, 107, GOLD[5]); R(42, 108, 45, 108, INK); R(75, 108, 78, 108, INK)
-- onion string on the dresser side
R(103, 38, 105, 40, TIMB[2]); R(104, 40, 104, 74, DIRT[3])
for k = 0, 3 do ell(104, 47 + k * 8, 3.6, 3.6, (k % 2 == 0) and GOLD or PINK) end
herb(34, UT, GREEN); herb(86, UT, LEAF, GOLD[4])
lantern(60, UT, 3)

---------------------------------------------------------------- 2 COOKING hearth (upper bay 2)
dk(209, 12, 213, 46, .22); dk(225, 56, 229, 106, .22)
stonewall(152, UT, 207, 47, STONE, 5, 11, 8, 14)
R(151, UT, 151, 47, INK); R(208, UT, 208, 47, INK); R(152, UT, 152, 47, STONE[6]); dk(203, UT, 207, 47, .25)
stonewall(136, 54, 223, 107, STONE, 5, 12, 9, 16)
R(135, 54, 135, 107, INK); R(224, 54, 224, 107, INK); R(136, 54, 136, 107, STONE[6]); dk(219, 54, 223, 107, .25)
local function arch(x, y, hw, top, k)
  local dx = x - 180
  if abs(dx) > hw or y > 107 then return false end
  return y >= top + (hw - sqrt(max(0, hw * hw - dx * dx))) * k
end
blob(140, 54, 220, 107, function(x, y) return arch(x, y, 38, 56, .75) end,
  function(x, y)
    local a = math.atan(y - 88, x - 180)
    if y < 88 then if (a * 11 / pi) % 1 < .14 then return STONE[3] end
    elseif (y % 7) == 0 then return STONE[3] end
    return (y < 70 or x < 180) and STONE[6] or STONE[5]
  end)
blob(148, 60, 212, 107, function(x, y) return arch(x, y, 32, 62, .75) end,
  function(x, y)
    if y % 6 == 0 or ((x + (y // 6) * 5) % 10 == 0) then return "#4a221e" end
    return y < 76 and "#5a2a22" or (y < 92 and "#743420" or "#8c4222")
  end)
box(175, 53, 185, 62, STONE, 6, { lit = 1, shade = 1 })   -- keystone
R(179, 56, 181, 56, STONE[3]); R(178, 57, 182, 57, STONE[3]); R(180, 58, 180, 59, STONE[3])
-- crane, logs, fire, pot
R(151, 76, 153, 107, INK); R(152, 77, 152, 106, IRON[5])
R(151, 76, 182, 78, INK); R(152, 77, 181, 77, IRON[5])
box(162, 102, 186, 107, TIMB, 3, { lit = 1 }); box(176, 99, 200, 104, TIMB, 4, { lit = 1 })
EM(function()
  R(160, 106, 200, 107, "#c0481e")
  for x = 163, 197 do
    local t = (x - 163) / 34
    local h = floor(6 + 9 * sin(t * pi) + 3 * sin(x * 1.3))
    R(x, 105 - h, x, 105, "#e0622a")
    local h2 = floor(h * .62); R(x, 105 - h2, x, 105, "#f49a34")
    if x > 169 and x < 191 then local h3 = floor(h * .34); R(x, 105 - h3, x, 105, "#fcd864") end
  end
  R(177, 102, 183, 105, "#fff0b0")
end)
line(169, 84, 180, 79, INK); line(191, 84, 180, 79, INK); R(180, 78, 180, 80, INK)
ell(180, 91, 12, 7, IRON)
R(167, 83, 193, 86, INK); R(168, 84, 192, 85, IRON[5]); R(170, 84, 190, 84, "#c9703a"); R(173, 84, 178, 84, "#eaa860")
for x = 172, 188 do P(x, 96, "#b0502c") end; for x = 175, 185 do P(x, 97, "#d8742c") end
R(184, 71, 187, 73, "#b89488"); R(186, 68, 189, 70, "#b89488"); R(174, 70, 176, 72, "#a88478"); R(176, 66, 178, 68, "#a88478")
-- mantel beam and hearth slab
box(131, 47, 228, 54, TIMB, 5, { lit = 1, shade = 2 })
for x = 137, 221, 7 do R(x, 51, x + 3, 52, TIMB[3]) end
box(131, 107, 228, UF, STONE, 5, { lit = 1, shade = 1 })
-- things on the mantel and the stack
ell(142, 41, 6, 5, COPPER); R(139, 35, 145, 36, INK); R(140, 35, 144, 35, COPPER[5]); R(141, 33, 143, 34, COPPER[3])
line(135, 39, 133, 36, INK); line(136, 40, 134, 37, COPPER[5]); line(136, 41, 133, 38, INK)
ell(214, 40, 4, 6, CREAM, { off = 1 }); ell(221, 40, 4, 6, CREAM, { off = 1 }); R(213, 39, 215, 41, SBLUE[5]); R(220, 39, 222, 41, ROSE[4])
R(164, UT, 167, 23, INK); R(165, UT, 166, 22, IRON[5]); ell(165.5, 30, 7, 7, COPPER); R(162, 27, 163, 29, COPPER[6])
R(179, UT, 182, 30, INK); R(180, UT, 181, 29, IRON[5]); ell(180.5, 33, 4, 3.4, IRON, { off = 1 })
R(193, UT, 196, 22, INK); R(194, UT, 195, 21, IRON[5]); ell(194.5, 27, 5, 5, COPPER); P(192, 25, COPPER[6]); P(193, 25, COPPER[6])
herb(141, UT, GREEN)

---------------------------------------------------------------- 3 TOOLS (upper bay 3)
dk(258, 33, 342, 68, .22)
box(255, 29, 339, 65, OAK, 5, { lit = 1, shade = 1 })
grain(257, 32, 337, 62, OAK[4], false, 31, .88)
-- hammer
R(262, 40, 268, 61, INK); R(263, 40, 267, 60, TIMB[6]); R(266, 40, 267, 60, TIMB[5])
box(258, 32, 274, 40, IRON, 4, { lit = 2, shade = 1 }); R(258, 32, 261, 34, OAK[5]); R(258, 35, 261, 35, INK); R(261, 32, 261, 35, INK)
-- saw
for x = 289, 319 do
  local t = (x - 289) / 30
  local y0, y1 = floor(37 + 3 * t), floor(50 - 4 * t)
  P(x, y0 - 1, INK)
  for y = y0, y1 do P(x, y, y == y0 and IRON[6] or (y >= y1 - 1 and IRON[4] or IRON[5])) end
  P(x, y1 + 1, INK); if x % 3 ~= 0 then P(x, y1 + 2, INK) end
end
R(320, 40, 320, 47, INK)
box(279, 35, 289, 51, TIMB, 5, { lit = 1, shade = 2 }); R(282, 40, 285, 46, OAK[2])
-- chisels
for i = 0, 2 do
  local x = 323 + i * 5
  R(x - 1, 33, x + 3, 58, INK); R(x, 34, x + 2, 44, ({ GOLD, BARN, TEAL })[i + 1][4]); R(x, 34, x, 44, ({ GOLD, BARN, TEAL })[i + 1][6])
  R(x, 45, x + 2, 57, IRON[5]); R(x, 45, x, 57, IRON[6]); R(x, 56, x + 2, 57, IRON[6])
end
-- try square
box(285, 56, 316, 61, IRON, 5, { lit = 1, shade = 1 }); box(279, 54, 287, 63, TIMB, 5, { lit = 1 })
for x = 291, 313, 5 do P(x, 59, IRON[3]) end
-- bench
dk(264, 93, 331, UF, .32)
box(270, 98, 297, UF, BARN, 4, { lit = 1, shade = 2 }); R(271, 103, 296, 103, BARN[2]); R(282, 101, 285, 105, GOLD[5]); R(282, 106, 285, 106, INK)
R(277, 94, 290, 95, INK); R(277, 96, 278, 97, INK); R(289, 96, 290, 97, INK)
blob(303, 99, 319, UF, function(x, y) local ins = floor((y - 99) / 6); return x >= 303 + ins and x <= 319 - ins end,
  function(x, y) if y % 5 == 1 then return IRON[3] end; return x < 308 and OAK[6] or (x > 314 and OAK[3] or OAK[5]) end)
R(305, 98, 317, 99, INK); for x = 306, 316, 2 do P(x, 98, IRON[6]) end
box(251, 82, 343, 88, OAK, 5, { lit = 1, shade = 2 }); grain(253, 84, 341, 85, OAK[4], false, 33, .85)
box(255, 88, 339, 92, OAK, 4, { lit = 0, shade = 1 })
box(256, 92, 263, UF, OAK, 4, { lit = 0, shade = 1 }); box(332, 92, 339, UF, OAK, 4, { lit = 0, shade = 1 })
-- vice with a peg of wood
box(261, 69, 266, 76, OAK, 6, { lit = 1 })
box(256, 67, 261, 76, IRON, 4, { lit = 1 }); box(266, 67, 271, 76, IRON, 4, { lit = 1 })
box(254, 75, 273, 82, IRON, 3, { lit = 1, shade = 1 })
R(273, 77, 280, 79, INK); R(274, 78, 279, 78, IRON[6]); R(280, 73, 282, 83, INK); R(281, 74, 281, 82, IRON[6])
-- plank, plane, shavings
box(286, 78, 320, 82, OAK, 6, { lit = 1, shade = 0 })
box(292, 71, 309, 78, TIMB, 5, { lit = 1, shade = 2 }); box(305, 66, 309, 72, TIMB, 6, { lit = 1 }); box(293, 67, 297, 72, TIMB, 4, { lit = 1 })
R(299, 77, 302, 77, IRON[6])
for _, s in ipairs{ { 311, 75 }, { 315, 74 }, { 313, 71 } } do
  R(s[1], s[2], s[1] + 2, s[2], CREAM[6]); P(s[1] + 3, s[2] + 1, CREAM[6]); R(s[1] + 1, s[2] + 2, s[1] + 3, s[2] + 2, OAK[6]); P(s[1], s[2] + 1, OAK[6])
end
-- half-built birdhouse (quirk)
box(324, 69, 337, 82, OAK, 6, { lit = 1, shade = 1 })
blob(320, 60, 341, 70, function(x, y) return abs(x - 330.5) <= (y - 60) + 1.5 and y <= 70 end,
  function(x, y) return x < 330 and BARN[5] or BARN[3] end)
R(329, 73, 332, 76, INK); R(330, 79, 331, 79, TIMB[2])
lantern(298, UT, 3)

---------------------------------------------------------------- 4 GARDEN potting bay (upper bay 4)
local function inwin(x, y, g)
  local hw = 17 + g; local dx = x - 395
  if abs(dx) > hw or y > 64 + g then return false end
  if y >= 39 then return true end
  return dx * dx + (y - 39) ^ 2 <= hw * hw + hw
end
dk(376, 22, 418, 72, .18)
blob(374, 18, 416, 68, function(x, y) return inwin(x, y, 3) end, function(x, y) return (x < 380 or y < 24) and TIMB[6] or TIMB[5] end)
EM(function()
  blob(377, 21, 413, 65, function(x, y) return inwin(x, y, 0) end,
    function(x, y)
      local hill = 58 + floor(2.5 * sin(x / 5))
      if y >= hill then return "#463e5c" end
      if y >= hill - 3 - floor(2 * sin(x / 9 + 2)) then return "#7a5a80" end
      return y < 29 and "#5c4c8c" or (y < 36 and "#8a5a98" or (y < 43 and "#c46c8c" or (y < 50 and "#ec8e6c" or "#f8b868")))
    end)
  ell(405, 31, 3.6, 3.6, { "#fff0c0", "#fff0c0", "#fff0c0", "#fff0c0", "#fff0c0", "#fff0c0" }, { ink = "#fff0c0" })
  R(385, 27, 386, 28, "#fff0c0"); R(389, 34, 389, 34, "#f8d8b0")
end)
EM(function() for y = 26, 33 do for x = 404, 410 do if ((x - 407) / 3.2) ^ 2 + ((y - 29.6) / 3.2) ^ 2 <= 1 then P(x, y, y < 29 and "#5c4c8c" or "#8a5a98") end end end end)
R(394, 22, 395, 64, TIMB[4]); R(378, 44, 412, 45, TIMB[4]); R(394, 22, 394, 64, TIMB[6]); R(378, 44, 412, 44, TIMB[6])
box(373, 65, 417, 70, TIMB, 5, { lit = 1, shade = 1 })
tpot(381, 64, 10, 8, BARN); sprout(385, 57, 6)
-- trowel + fork on a peg rail
box(440, 37, 463, 41, TIMB, 5, { lit = 1 })
R(444, 41, 448, 49, INK); R(445, 42, 447, 48, GOLD[4]); R(445, 42, 445, 48, GOLD[6])
blob(442, 49, 450, 62, function(x, y) return abs(x - 446) <= min(4, (63 - y) * .55 + .5) end, function(x, y) return x < 446 and IRON[6] or IRON[4] end)
R(454, 41, 458, 49, INK); R(455, 42, 457, 48, BARN[4]); R(455, 42, 455, 48, BARN[6])
R(453, 49, 459, 51, INK); R(454, 50, 458, 50, IRON[5])
for _, fx in ipairs{ 453, 456, 459 } do R(fx - 1, 51, fx + 1, 61, INK); R(fx, 52, fx, 60, IRON[6]) end
lantern(430, UT, 3)
-- under the bench
dk(381, 90, 451, UF, .3)
blob(382, 91, 406, UF, function(x, y) local t = y - 91; local ins = t < 2 and 3 or (t < 5 and 1 or 0); return x >= 382 + ins and x <= 406 - ins end,
  function(x, y) if x <= 385 then return BURLAP[6] end; if x >= 403 then return BURLAP[3] end; return ((x + y) % 4 == 0) and BURLAP[4] or BURLAP[5] end, BURLAP[1])
R(385, 92, 403, 94, "#3a2820"); R(388, 91, 400, 91, "#523828"); R(390, 92, 392, 92, LEAF[3]); R(397, 93, 398, 93, DIRT[3])
R(390, 100, 398, 104, GREEN[4]); R(393, 98, 395, 106, GREEN[4]); R(393, 101, 395, 103, GREEN[6])   -- leaf stamp
tpot(411, UF, 13, 9, BARN); box(411, 99, 423, 102, BARN, 5, { lit = 1, shade = 0, ink = BARN[1] }); box(412, 96, 422, 99, BARN, 5, { lit = 1, shade = 0, ink = BARN[1] })
box(428, 98, 450, UF, OAK, 4, { lit = 1, shade = 1 }); R(429, 104, 449, 104, OAK[2]); R(439, 99, 439, 110, OAK[2])
ell(439, 96, 10, 3.5, { LEAF[1], LEAF[2], DIRT[2], LEAF[3], DIRT[3], LEAF[4] })
-- bench
box(369, 80, 463, 86, OAK, 5, { lit = 1, shade = 2 }); grain(371, 82, 461, 83, OAK[4], false, 41, .85)
box(373, 86, 459, 90, OAK, 4, { lit = 0, shade = 1 })
box(374, 90, 380, UF, OAK, 4, { lit = 0, shade = 1 }); box(452, 90, 458, UF, OAK, 4, { lit = 0, shade = 1 })
-- seed tray
box(372, 73, 402, 80, OAK, 4, { lit = 1, shade = 1 }); R(374, 74, 400, 75, "#4a3428")
for i = 0, 5 do
  local x = 376 + i * 4; local t = 71 - (i % 2)
  R(x, t, x + 1, 74, GREEN[5]); P(x - 1, t, GREEN[6]); P(x + 2, t - 1, GREEN[6]); P(x + 1, t - 1, GREEN[5])
end
tpot(406, 79, 10, 9, BARN); R(408, 70, 413, 70, "#4a3428"); R(410, 67, 411, 69, GREEN[5]); P(409, 67, GREEN[6]); P(412, 66, GREEN[6])
tpot(419, 79, 15, 13, BARN); R(421, 66, 431, 66, "#4a3428")
R(426, 52, 427, 66, GREEN[4])
ell(421.5, 58, 4, 2.4, GREEN, { off = 1 }); ell(431.5, 54, 4, 2.4, GREEN, { off = 1 }); ell(424, 50, 3, 2, LEAF, { off = 1 })
-- watering can
R(436, 68, 440, 70, INK); R(436, 68, 438, 78, INK); R(436, 76, 440, 78, INK); R(437, 69, 437, 77, TEAL[5])
box(440, 66, 454, 80, TEAL, 4, { lit = 1, shade = 2 }); R(443, 70, 444, 76, TEAL[6]); R(442, 66, 452, 66, TEAL[2])
poly({ { 454, 72 }, { 454, 77 }, { 458, 73 }, { 464, 66 }, { 461, 63 }, { 457, 68 } }, TEAL[4])
R(461, 61, 465, 62, INK); R(462, 62, 464, 63, TEAL[6])

---------------------------------------------------------------- 5 POTIONS (lower bay 1)
dk(22, 160, 78, 168, .22)
flask(27, 157, 5, VIOLET); bottle(35, 157, 9, 15, SBLUE); flask(51, 157, 4, GREEN); bottle(58, 157, 7, 13, PINK); bottle(67, 157, 7, 16, GOLD)
box(19, 158, 76, 161, OAK, 5, { lit = 1, shade = 0 })
poly({ { 23, 162 }, { 28, 162 }, { 23, 168 } }, TIMB[4]); poly({ { 67, 162 }, { 72, 162 }, { 72, 168 } }, TIMB[4])
-- tiled pad
for y = 221, 229 do
  local rt = (y - 221) // 3
  local x0, x1 = 34 - (y - 221), 138 + (y - 221)
  for x = x0, x1 do
    local t = ((x - 30 + rt * 7) // 14 + rt) % 2
    local col = t == 0 and SBLUE[5] or CREAM[5]
    if (y - 221) % 3 == 0 then col = t == 0 and SBLUE[6] or CREAM[6] end
    if (x - 30 + rt * 7) % 14 == 0 then col = STONE[3] end
    if x == x0 or x == x1 or y == 229 then col = STONE[2] end
    P(x, y, col)
  end
end
R(34, 220, 138, 220, INK)
shadow(86, 225, 40, 3, .3)
box(60, 212, 66, 226, IRON, 3, { lit = 1 }); box(106, 212, 112, 226, IRON, 3, { lit = 1 })
box(68, 222, 104, 226, TIMB, 3, { lit = 1 })
ell(86, 197, 34, 23, IRON)
for y = 176, 220 do for x = 52, 120 do
  local c = G(x, y)
  for i = 2, 6 do if c == IRON[i] then
    if y > 207 then P(x, y, mix(c, "#e0622a", y > 213 and .5 or .3)) elseif y < 187 then P(x, y, mix(c, "#7ad88c", .22)) end
  end end
end end
EM(function()
  for x = 69, 103 do
    local h = floor(4 + 5 * sin((x - 69) / 34 * pi) + 2 * sin(x * 1.7))
    R(x, 224 - h, x, 224, "#e0622a"); R(x, 224 - floor(h * .6), x, 224, "#f49a34")
    if x > 76 and x < 96 then R(x, 224 - floor(h * .3), x, 224, "#fcd864") end
  end
end)
box(46, 184, 52, 191, IRON, 4, { lit = 1 }); box(120, 184, 126, 191, IRON, 4, { lit = 1 })
blob(49, 168, 123, 178, function(x, y) local e = (x <= 50 or x >= 122); return not (e and (y <= 169 or y >= 177)) end,
  function(x, y) return y <= 170 and IRON[6] or (y >= 176 and IRON[3] or IRON[5]) end)
for x = 56, 116, 8 do P(x, 181, IRON[6]); P(x + 1, 181, IRON[6]); P(x, 182, IRON[2]); P(x + 1, 182, IRON[2]) end
EM(function()
  ell(86, 172, 32, 3.4, { BREW[1], BREW[3], BREW[3], BREW[3], BREW[4], BREW[5] }, { ink = BREW[1] })
  R(64, 171, 74, 171, BREW[5]); R(92, 173, 104, 173, BREW[2]); R(80, 172, 86, 172, BREW[6])
end)
-- stirring paddle
poly({ { 107, 173 }, { 111, 173 }, { 122, 150 }, { 118, 150 } }, TIMB[6])
EM(function()
  ell(72, 168, 3, 3, BREW); ell(97, 166, 4, 4, BREW); ell(84, 158, 2.6, 2.6, BREW); ell(101, 153, 2, 2, BREW)
end)
-- bottles standing on the pad
bottle(38, 227, 9, 14, TEAL); flask(131, 227, 6, VIOLET)

---------------------------------------------------------------- 6 BUILDING yard corner (lower bay 2)
-- leaning beams
dk(186, 142, 208, 190, .2)
poly({ { 183, 139 }, { 192, 139 }, { 189, 200 }, { 180, 200 } }, function(x, y) return (x + y // 16) % 7 < 2 and OAK[6] or OAK[5] end)
poly({ { 195, 145 }, { 203, 145 }, { 202, 200 }, { 194, 200 } }, function(x, y) return x % 7 < 3 and TIMB[6] or TIMB[5] end)
-- rope coil on a peg
dk(211, 152, 236, 182, .2)
blob(207, 147, 233, 177, function(x, y)
    local a = ((x - 220) / 12.5) ^ 2 + ((y - 162) / 14.5) ^ 2; local b = ((x - 220) / 5) ^ 2 + ((y - 162) / 7) ^ 2
    return a <= 1 and b > 1 end,
  function(x, y) local s = ((x + y) // 2) % 2 == 0; if x + y > 392 then return s and DIRT[3] or DIRT[4] end; return s and DIRT[5] or DIRT[6] end, DIRT[1])
box(217, 143, 223, 149, TIMB, 6, { lit = 1 })
R(226, 174, 229, 181, DIRT[1]); R(227, 174, 228, 180, DIRT[5]); for y = 175, 180, 3 do P(227, y, DIRT[3]) end
-- building plan pinned to the wall (no letters, just a tiny house sketch)
dk(250, 152, 276, 173, .2)
box(248, 149, 274, 171, CREAM, 5, { ink = OAK[2], lit = 0, shade = 0 })
line(254, 159, 261, 153, SBLUE[3]); line(261, 153, 268, 159, SBLUE[3]); R(254, 159, 254, 167, SBLUE[3]); R(268, 159, 268, 167, SBLUE[3])
R(254, 167, 268, 167, SBLUE[3]); R(260, 162, 262, 167, SBLUE[4]); R(251, 169, 271, 169, CREAM[3])
R(250, 150, 251, 151, BARN[5]); R(271, 150, 272, 151, BARN[5])
-- timber stack
shadow(208, 227, 36, 3); shadow(254, 229, 18, 2); shadow(288, 227, 22, 3)
for i = 0, 4 do
  local y1 = 226 - i * 9; local y0 = y1 - 9
  local x0 = 177 + (i % 2) * 4 + (i >= 3 and 5 or 0)
  local x1 = 238 - ((i + 1) % 2) * 5 - (i >= 3 and 10 or 0)
  box(x0, y0, x1, y1, OAK, (i % 2 == 0) and 5 or 4, { lit = 1, shade = 2 })
  grain(x0 + 2, y0 + 3, x1 - 11, y1 - 3, OAK[(i % 2 == 0) and 4 or 3], false, 50 + i, .82)
  box(x1 - 9, y0, x1, y1, OAK, 6, { lit = 1, shade = 0 }); R(x1 - 7, y0 + 3, x1 - 2, y0 + 6, OAK[5]); R(x1 - 6, y0 + 4, x1 - 3, y0 + 5, OAK[3])
end
-- bricks
local bricks = { { 240, 0 }, { 251, 0 }, { 245, 1 }, { 256, 1 }, { 240, 2 }, { 251, 2 }, { 245, 3 } }
for bi, b in ipairs(bricks) do
  local y0 = 223 - b[2] * 5
  box(b[1], y0, b[1] + 11, y0 + 5, BARN, (bi % 3 == 0) and 4 or 5, { lit = 1, shade = 1 })
end
-- stone blocks
local function sblock(x0, y0, x1, y1, s)
  box(x0, y0, x1, y1, STONE, 5, { lit = 2, shade = 2 })
  for y = y0 + 4, y1 - 3 do for x = x0 + 3, x1 - 3 do if hash(x // 2, y // 2, s) > .86 then P(x, y, STONE[4]) end end end
end
sblock(271, 207, 288, 226, 61); sblock(288, 207, 305, 226, 62); sblock(278, 188, 298, 207, 63)
-- mason's mallet lying on the top block
R(288, 182, 302, 186, INK); R(289, 183, 301, 185, TIMB[6]); R(289, 185, 301, 185, TIMB[4])
box(280, 178, 289, 188, TIMB, 5, { lit = 1, shade = 2 })
lantern(240, LT, 6)

---------------------------------------------------------------- 7 DECOR loom + paint table (lower bay 3)
dk(344, 150, 394, 222, .16)
for y = 152, 183 do for x = 344, 381 do P(x, y, ((x - 344) % 3 == 2) and "#a07c74" or CREAM[5 + ((x - 344) % 3 == 0 and 1 or 0)]) end end
local bands = { ROSE, CREAM, TEAL, GOLD, PINK, VIOLET }
for y = 184, 212 do for x = 344, 381 do
  local b = (y - 184) // 5; local r = (y - 184) % 5
  local ramp = bands[b % #bands + 1]
  local z = (r < 3) and r or 4 - r
  local col = ((x + z * 2) % 8 < 3) and ramp[5] or ramp[4]
  if r == 4 then col = ramp[3] end
  P(x, y, col)
end end
R(344, 183, 381, 183, INK)
box(333, 222, 348, 227, TIMB, 4, { lit = 1 }); box(377, 222, 392, 227, TIMB, 4, { lit = 1 })
box(337, 146, 343, 224, TIMB, 5, { lit = 0, shade = 1 }); box(382, 146, 388, 224, TIMB, 5, { lit = 0, shade = 1 })
box(341, 173, 384, 178, TIMB, 6, { lit = 1, shade = 1 })
box(341, 212, 384, 218, TIMB, 4, { lit = 1, shade = 1 }); R(346, 213, 379, 216, ROSE[4]); R(346, 213, 379, 213, ROSE[5])
box(334, 143, 391, 151, TIMB, 5, { lit = 1, shade = 2 })
mushcarve(362, 148); for _, px in ipairs{ 339, 385 } do R(px, 146, px + 1, 147, TIMB[2]); P(px, 146, TIMB[6]) end
-- shelf with bolts of cloth (rolls with a spiral end)
local function roll(x0, y0, x1, y1, ramp, pat)
  box(x0 + 3, y0, x1, y1, ramp, 4, { lit = 1, shade = 2, ink = ramp[1] })
  for x = x0 + 9, x1 - 3, 5 do
    if pat == 1 then R(x, y0 + 2, x + 1, y1 - 3, ramp[6]) else R(x, y0 + 3, x + 1, y0 + 4, ramp[6]); R(x + 2, y1 - 4, x + 3, y1 - 3, ramp[6]) end
  end
  local cy = (y0 + y1) / 2
  ell(x0 + 3.5, cy, 3.5, (y1 - y0) / 2, { ramp[1], ramp[5], ramp[6], ramp[6], ramp[6], ramp[6] }, { ink = ramp[1] })
  R(x0 + 3, floor(cy) - 1, x0 + 4, floor(cy) + 1, ramp[2])
end
dk(406, 144, 454, 170, .2)
roll(403, 150, 426, 159, VIOLET, 1); roll(427, 150, 450, 159, GOLD, 2); roll(414, 141, 438, 150, TEAL, 2)
-- a length of cloth hanging off the shelf end
box(440, 159, 450, 176, ROSE, 4, { lit = 0, shade = 1, ink = ROSE[1] })
for y = 162, 174, 4 do R(442, y, 448, y, ROSE[6]) end
for x = 440, 450 do if x % 4 < 2 then P(x, 177, ROSE[1]); P(x, 176, ROSE[4]) end end
box(402, 160, 439, 163, OAK, 5, { lit = 1, shade = 0 })
poly({ { 406, 164 }, { 411, 164 }, { 406, 170 } }, TIMB[4]); poly({ { 430, 164 }, { 435, 164 }, { 435, 170 } }, TIMB[4])
lantern(396, LT, 6)
-- table, rolls under it
shadow(432, 227, 34, 3); shadow(362, 228, 32, 2)
dk(411, 197, 453, 222, .2)
roll(412, 217, 452, 226, PINK, 1); roll(416, 208, 449, 217, SBLUE, 2); roll(421, 199, 446, 208, GREEN, 1)
box(400, 190, 464, 196, OAK, 5, { lit = 1, shade = 2 }); grain(402, 192, 462, 193, OAK[4], false, 71, .85)
box(404, 196, 410, 226, OAK, 4, { lit = 0, shade = 1 }); box(454, 196, 460, 226, OAK, 4, { lit = 0, shade = 1 })
local function ppot(x, ramp)
  box(x, 179, x + 10, 190, ramp, 4, { lit = 0, shade = 2, ink = ramp[1] })
  R(x, 179, x + 10, 181, ramp[1]); R(x + 1, 180, x + 9, 180, ramp[6])
  R(x + 2, 182, x + 3, 187, ramp[6]); R(x + 6, 182, x + 7, 184, ramp[6])
end
ppot(402, BARN); ppot(414, TEAL); ppot(426, GOLD)
-- brushes in the third pot
R(428, 168, 430, 179, INK); R(429, 169, 429, 178, TIMB[6]); R(427, 164, 431, 168, INK); R(428, 165, 430, 167, PINK[4])
line(435, 178, 438, 168, INK); line(434, 178, 437, 168, TIMB[6]); line(433, 178, 436, 168, INK); R(435, 163, 439, 167, INK); R(436, 164, 438, 166, SBLUE[5])
-- half-painted toadstool ornament (quirk)
box(448, 180, 456, 190, CREAM, 5, { lit = 0, shade = 1 })
blob(441, 171, 463, 181, function(x, y) return ((x - 452) / 11) ^ 2 + ((y - 181) / 10) ^ 2 <= 1 and y <= 181 end,
  function(x, y)
    if x > 455 + (y % 3) then return (x > 459) and OAK[5] or OAK[6] end
    return (y < 175 and x < 452) and BARN[5] or BARN[4]
  end)
R(445, 176, 446, 177, CREAM[6]); R(449, 173, 451, 174, CREAM[6]); R(452, 177, 453, 178, CREAM[6])

---------------------------------------------------------------- strung things, hat, little door
local FLAGS = { ROSE, GOLD, TEAL, CREAM, VIOLET, BARN }
local function bunt(xa, xb, y, sag, seed)
  local function yy(x) local t = (x - xa) / (xb - xa); return floor(y + sag * 4 * t * (1 - t) + .5) end
  for x = xa, xb do P(x, yy(x), "#5a3a3e") end
  local i = seed
  for x = xa + 5, xb - 9, 10 do
    local ramp = FLAGS[i % #FLAGS + 1]; i = i + 1
    local ty = yy(x + 3) + 1
    for r = 0, 6 do
      local ins = (r + 1) // 2
      for fx = x + ins, x + 6 - ins do P(fx, ty + r, (fx == x + 6 - ins and r > 0) and ramp[3] or (fx == x + ins and ramp[6] or ramp[5])) end
    end
  end
end
bunt(20, 141, 126, 5, 0)
bunt(180, 236, 126, 4, 2); bunt(244, 300, 126, 4, 4)
bunt(340, 392, 126, 4, 1); bunt(400, 458, 126, 4, 3)
-- gnome hat on a peg (quirk)
R(238, 34, 239, 36, TIMB[2])
blob(232, 36, 245, 52, function(x, y) return abs(x - 238.5) <= (y - 36) * .42 + .6 and y <= 52 end,
  function(x, y) if y >= 50 then return BARN[3] end; return x < 238 and BARN[5] or BARN[4] end)
P(239, 35, BARN[5])
-- tiny round-topped door in the post foot (quirk)
blob(155, 207, 164, 217, function(x, y) return y >= 211 or (x - 159.5) ^ 2 + (y - 211) ^ 2 <= 22 end,
  function(x, y) return (x == 159) and GREEN[2] or (x < 159 and GREEN[5] or GREEN[4]) end)
R(162, 212, 162, 213, GOLD[6])

---------------------------------------------------------------- foreground props (left and centre only)
-- braided rug
shadow(238, 254, 50, 10, .18)
blob(190, 243, 284, 263, function(x, y) return ((x - 237) / 47) ^ 2 + ((y - 253) / 10) ^ 2 <= 1 end,
  function(x, y)
    local q = sqrt(((x - 237) / 47) ^ 2 + ((y - 253) / 10) ^ 2)
    if q > .86 then return ROSE[3] end
    if q > .68 then return ((x // 3) % 2 == 0) and CREAM[5] or CREAM[4] end
    if q > .46 then return TEAL[4] end
    if q > .26 then return ((x // 3) % 2 == 0) and GOLD[4] or GOLD[5] end
    return ROSE[4]
  end, ROSE[1])
-- stool with a mug
shadow(160, 257, 13, 3)
box(151, 244, 155, 257, OAK, 4, { lit = 0 }); box(165, 244, 169, 257, OAK, 4, { lit = 0 })
box(148, 239, 172, 245, OAK, 5, { lit = 1, shade = 2 })
box(155, 230, 164, 239, TEAL, 4, { lit = 1, shade = 1 }); R(164, 232, 167, 233, INK); R(166, 233, 167, 236, INK); R(164, 236, 167, 237, INK)
R(156, 230, 163, 230, TEAL[2]); R(157, 231, 162, 231, "#7a4a34")
-- yarn basket
shadow(350, 259, 18, 3)
ell(342, 240, 5, 5, PINK); ell(352, 238, 6, 6, TEAL); ell(361, 241, 5, 5, GOLD)
line(339, 238, 344, 242, PINK[6]); line(349, 235, 355, 240, TEAL[6]); line(359, 239, 363, 243, GOLD[6])
blob(334, 243, 368, 259, function(x, y) local ins = floor((y - 243) / 5); return x >= 334 + ins and x <= 368 - ins end,
  function(x, y) local w = ((x // 3) + (y // 2)) % 2 == 0; if x > 360 then return w and BURLAP[3] or BURLAP[2] end; return w and BURLAP[5] or BURLAP[4] end, BURLAP[1])
R(334, 243, 368, 245, BURLAP[1]); R(335, 244, 367, 244, BURLAP[6])
-- wooden bucket
shadow(28, 259, 14, 3)
blob(16, 240, 40, 259, function(x, y) local ins = floor((y - 240) / 7); return x >= 16 + ins and x <= 40 - ins end,
  function(x, y) if y % 8 == 5 or y % 8 == 6 then return x < 24 and IRON[6] or IRON[4] end
    if x % 5 == 0 then return OAK[3] end; return x < 24 and OAK[6] or (x > 34 and OAK[3] or OAK[5]) end)
R(18, 241, 38, 242, SBLUE[5]); R(22, 241, 28, 241, SBLUE[6])

---------------------------------------------------------------- lamps and the stepped light pass
lamp(60, 22, 92, 1, .7, { 0, 0, 120, 117 })
lamp(180, 98, 88, 1.15, 1, { 121, 0, 238, 117 })
lamp(298, 22, 92, 1, .7, { 239, 0, 356, 117 })
lamp(430, 22, 92, 1, .7, { 357, 0, 479, 117 }); lamp(395, 44, 55, .5, 1, { 357, 0, 479, 117 })
lamp(86, 172, 84, 1, .9, { 0, 118, 159, 222 }); lamp(86, 216, 50, .8, 1, { 0, 118, 159, 269 })
lamp(86, 238, 84, .95, 2.3, { 0, 223, 162, 269 })
lamp(240, 137, 104, 1, .75, { 160, 118, 319, 222 }); lamp(240, 240, 90, .95, 2.3, { 150, 223, 330, 269 })
lamp(396, 137, 104, 1, .75, { 320, 118, 479, 222 }); lamp(396, 238, 88, .95, 2.3, { 318, 223, 479, 269 })
for y = 0, H - 1 do for x = 0, W - 1 do
  local k = y * W + x
  local c = buf[k]
  if c and not emit[k] then
    local L = .06
    for _, l in ipairs(lamps) do
      local cl = l.clip
      if x >= cl[1] and x <= cl[3] and y >= cl[2] and y <= cl[4] then
        local dd = sqrt((x - l.x) ^ 2 + ((y - l.y) * l.ky) ^ 2) / l.r
        if dd < 1 then L = L + l.s * (1 - dd) end
      end
    end
    if L >= .72 then c = mix(c, "#ffd884", .24)
    elseif L >= .5 then c = mix(c, "#ffd884", .12)
    elseif L >= .3 then
    elseif L >= .15 then c = mix(c, "#3a2248", .24)
    else c = mix(c, "#3a2248", .42) end
    buf[k] = c
  end
end end
-- green breath over the brew
for y = 140, 178 do for x = 46, 126 do
  local k = y * W + x
  if buf[k] and not emit[k] then
    local dd = sqrt((x - 86) ^ 2 + ((y - 172) * 1.3) ^ 2) / 42
    if dd < 1 then buf[k] = mix(buf[k], "#8ee08a", .2 * floor((1 - dd) * 3 + .999) / 3) end
  end
end end

---------------------------------------------------------------- out
local c = HP.canvas{ w = W, h = H, scale = 1, name = "craft-workshop" }
for y = 0, H - 1 do for x = 0, W - 1 do
  local col = buf[y * W + x] or "#ff00ff"
  if col == "#000000" then col = INK elseif col == "#ffffff" then col = "#fff8e8" end
  c:put(x, y, col)
end end
c:save{ aseprite = d .. "/craft-workshop.aseprite", png = d .. "/craft-workshop.png", scale = 1 }

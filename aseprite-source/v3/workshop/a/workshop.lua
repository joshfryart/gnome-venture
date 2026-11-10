-- Workshop picture, direction A: "Same room, made rich". 480 x 270, Hearth Pop v3.
-- One script: base picture + "ready" anim layers + layout.json. Deterministic (hash noise only).
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "craft-workshop" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin, cos, abs, sqrt = math.floor, math.max, math.min, math.sin, math.cos, math.abs, math.sqrt
local INK = "#2b1c26"
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON, SBLUE, DIRT =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON, S.SBLUE, S.DIRT
local COPPER = {"#4a2028","#7a3a2c","#a85a34","#cf7e42","#eca860","#fcd89a"}
local PINE   = {"#5a3a2c","#8a5e3c","#b4844e","#d6a866","#eac888","#f8e2ac"}
local GL     = {"#8fb0a8","#bcd6cc","#e6f2e4"}
local hash = S.hash

---------------------------------------------------------------- own pixel buffer (switchable target)
local base = {}
local buf = base
local emis = {}
local function P(x, y, col) if x >= 0 and x < W and y >= 0 and y < H then buf[y * W + x] = col end end
local function G(x, y) if x >= 0 and x < W and y >= 0 and y < H then return buf[y * W + x] end end
local function E(x, y, col) P(x, y, col); if buf == base then emis[y * W + x] = true end end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local rgbc = {}
local function rgb(h)
  local t = rgbc[h]
  if not t then t = { tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) }; rgbc[h] = t end
  return t[1], t[2], t[3]
end
local function mix(a, b, t)
  local r1,g1,b1 = rgb(a); local r2,g2,b2 = rgb(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
end
local function tint(x, y, col, t) local cur = G(x, y); if cur then P(x, y, mix(cur, col, t)) end end
local SHADE = "#33224a"

-- masks
local function Mask() return { s = {}, x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9 } end
local function mset(m, x, y)
  m.s[y * 1024 + x] = true
  if x < m.x0 then m.x0 = x end; if x > m.x1 then m.x1 = x end
  if y < m.y0 then m.y0 = y end; if y > m.y1 then m.y1 = y end
end
local function mhas(m, x, y) return m.s[y * 1024 + x] end
local function meach(m, f) for y = m.y0, m.y1 do for x = m.x0, m.x1 do if m.s[y * 1024 + x] then f(x, y) end end end end
local function mfrom(x0, y0, x1, y1, fn)
  local m = Mask()
  for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do if fn(x, y) then mset(m, x, y) end end end
  return m
end
local function mrect(x0, y0, x1, y1) return mfrom(x0, y0, x1, y1, function() return true end) end
local function mell(cx, cy, rx, ry)
  return mfrom(cx - rx, cy - ry, cx + rx, cy + ry, function(x, y) return ((x - cx) / (rx + .3)) ^ 2 + ((y - cy) / (ry + .3)) ^ 2 <= 1 end)
end
local function mrr(x0, y0, x1, y1, r)
  r = r or 1
  return mfrom(x0, y0, x1, y1, function(x, y)
    local dx = (x < x0 + r) and (x0 + r - x) or ((x > x1 - r) and (x - (x1 - r)) or 0)
    local dy = (y < y0 + r) and (y0 + r - y) or ((y > y1 - r) and (y - (y1 - r)) or 0)
    return dx + dy <= r
  end)
end
local function mpoly(pts)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0 = min(x0, p[1]); x1 = max(x1, p[1]); y0 = min(y0, p[2]); y1 = max(y1, p[2]) end
  return mfrom(x0, y0, x1, y1, function(x, y)
    local inside = false
    local j = #pts
    for i = 1, #pts do
      local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
      if ((yi > y + .01) ~= (yj > y + .01)) and (x < (xj - xi) * (y + .01 - yi) / (yj - yi) + xi + .5) then inside = not inside end
      j = i
    end
    return inside
  end)
end
local function munion(a, b) meach(b, function(x, y) mset(a, x, y) end); return a end
local function mrim(m, col)
  col = col or INK
  meach(m, function(x, y)
    if not mhas(m, x - 1, y) then P(x - 1, y, col) end
    if not mhas(m, x + 1, y) then P(x + 1, y, col) end
    if not mhas(m, x, y - 1) then P(x, y - 1, col) end
    if not mhas(m, x, y + 1) then P(x, y + 1, col) end
  end)
end
local function mfill(m, f) meach(m, function(x, y) local col = type(f) == "string" and f or f(x, y); if col then P(x, y, col) end end) end
-- chunky object: lit top/left, shaded bottom/right, ink rim
local function obj(m, ramp, o)
  o = o or {}
  local b = o.base or 4
  mrim(m, o.rim or INK)
  meach(m, function(x, y)
    local lit = (y - m.y0 < (o.lit or 2)) or (x - m.x0 < 1)
    local sh = (m.y1 - y < (o.shade or 2)) or (m.x1 - x < (o.sr or 2))
    local col = ramp[b]
    if sh then col = ramp[max(1, b - 1)] elseif lit then col = ramp[min(6, b + 1)] end
    P(x, y, col)
  end)
  return m
end
local function box(x0, y0, x1, y1, ramp, b, o) o = o or {}; o.base = b or 4; return obj(mrect(x0, y0, x1, y1), ramp, o) end
-- round object lit upper-left
local function sph(m, ramp, o)
  o = o or {}
  local cx, cy = (m.x0 + m.x1) / 2, (m.y0 + m.y1) / 2
  local rx, ry = (m.x1 - m.x0) / 2 + .5, (m.y1 - m.y0) / 2 + .5
  local lx, ly = o.lx or -.6, o.ly or -.7
  if not o.norim then mrim(m, o.rim or INK) end
  meach(m, function(x, y)
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local v = .52 + .5 * (nx * lx + ny * ly) + (o.bias or 0)
    local i = max(o.lo or 1, min(o.hi or 6, floor(v * 6) + 1))
    P(x, y, ramp[i])
  end)
  return m
end
-- vertical cylinder shading by x
local function cyl(m, ramp, o)
  o = o or {}
  if not o.norim then mrim(m, INK) end
  local w = m.x1 - m.x0 + 1
  meach(m, function(x, y)
    local t = (x - m.x0) / max(1, w - 1)
    local i
    if t < .08 then i = 4 elseif t < .3 then i = 6 elseif t < .6 then i = 5 elseif t < .82 then i = 4 else i = 3 end
    i = i + (o.bias or 0)
    if y == m.y1 then i = i - 1 end
    P(x, y, ramp[max(1, min(6, i))])
  end)
  return m
end
local function line(x0, y0, x1, y1, col, th)
  th = th or 1
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    for a = 0, th - 1 do for b = 0, th - 1 do P(x + a, y + b, col) end end
  end
end
local function shadow(cx, cy, rx, ry, a)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    if ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 and not emis[y * W + x] then tint(x, y, SHADE, a or .38) end
  end end
end
local function shadeRect(x0, y0, x1, y1, a) for y = y0, y1 do for x = x0, x1 do tint(x, y, SHADE, a or .35) end end end
-- stone block texture
local function stone(m, seed, bh, bw, o)
  o = o or {}
  mrim(m, INK)
  meach(m, function(x, y)
    local r = floor((y - m.y0) / bh); local py = (y - m.y0) % bh
    local off = floor(hash(r, seed, 1) * bw)
    local k = floor((x + off) / bw); local px = (x + off) % bw
    local tone = 4 + (hash(k, r, seed) > .68 and 1 or 0) - (hash(k, r, seed + 1) > .72 and 1 or 0) + (o.bias or 0)
    local col
    if py == bh - 1 or px == bw - 1 then col = STONE[2]
    elseif py == 0 or px == 0 then col = STONE[min(6, tone + 1)]
    elseif py == bh - 2 or px == bw - 2 then col = STONE[max(1, tone - 1)]
    else col = STONE[tone]; if hash(x // 2, y // 2, seed + 5) > .93 then col = STONE[tone - 1] end end
    P(x, y, col)
  end)
end
local function woodH(x0, y0, x1, y1, ramp, b, seed)  -- horizontal timber with grain
  for y = y0, y1 do for x = x0, x1 do
    local col = ramp[b]
    if y == y0 then col = ramp[min(6, b + 1)] elseif y == y1 then col = ramp[b - 1]
    elseif hash(x // 7, y, seed) > .82 then col = ramp[b - 1] end
    P(x, y, col)
  end end
end
local function woodV(x0, y0, x1, y1, ramp, b, seed)
  for y = y0, y1 do for x = x0, x1 do
    local col = ramp[b]
    if x == x0 then col = ramp[min(6, b + 1)] elseif x == x1 then col = ramp[b - 1]
    elseif hash(x, y // 7, seed) > .82 then col = ramp[b - 1] end
    P(x, y, col)
  end end
end
local function star(x, y, col, big)   -- 4-point glint
  R(x, y - (big and 3 or 2), x, y + (big and 3 or 2), col); R(x - (big and 3 or 2), y, x + (big and 3 or 2), y, col)
  if big then R(x - 1, y - 1, x + 1, y + 1, col) end
end

local FL = 150
---------------------------------------------------------------- wall: warm plaster
for y = 0, FL do for x = 0, W - 1 do
  local col = CREAM[5]
  local b = hash(x // 14, y // 9, 5)
  if b > .8 then col = CREAM[4] end
  if y > 98 then col = CREAM[4] end
  local hx = hash(x // 5, y, 9)
  if hx > .955 then col = (col == CREAM[4]) and CREAM[3] or CREAM[4] end
  P(x, y, col)
end end
-- window halo on plaster (hard steps)
for y = 15, 110 do for x = 200, 336 do
  local dx = max(232 - x, 0, x - 304); local dy = max(16 - y, 0, y - 90)
  local dd = sqrt(dx * dx + dy * dy)
  if dd < 12 then P(x, y, CREAM[6]) elseif dd < 22 and G(x, y) == CREAM[4] then P(x, y, CREAM[5]) end
end end
-- exposed brick patch (right wall)
for y = 24, 52 do for x = 438, 468 do
  local e = abs(x - 453) / 15 + abs(y - 38) / 14 + (hash(x // 3, y // 3, 77) - .5) * .5
  if e < .95 then
    local r = (y - 24) // 5; local px = (x + (r % 2) * 5) % 10
    local col = BARN[4 + (hash((x + (r % 2) * 5) // 10, r, 3) > .6 and 1 or 0)]
    if (y - 24) % 5 == 4 or px == 9 then col = CREAM[3] end
    P(x, y, col)
  elseif e < 1.08 then P(x, y, CREAM[3]) end
end end
-- wainscot
for y = 108, FL do for x = 0, W - 1 do
  local k = x // 10; local px = x % 10
  local tone = 3 + (hash(k, 0, 7) > .5 and 1 or 0)
  local col = TIMB[tone]
  if px == 0 then col = TIMB[2] elseif px == 1 then col = TIMB[tone + 1]
  elseif hash(x, y // 6, 8) > .9 then col = TIMB[tone - 1] end
  P(x, y, col)
end end
R(0, 106, W - 1, 106, INK); R(0, 107, W - 1, 107, TIMB[6]); R(0, 108, W - 1, 109, TIMB[5]); R(0, 110, W - 1, 110, TIMB[2])
R(0, 142, W - 1, 142, INK); R(0, 143, W - 1, 143, TIMB[5]); R(0, 144, W - 1, FL - 1, TIMB[4]); R(0, FL, W - 1, FL, INK)

---------------------------------------------------------------- floor planks (rows grow toward the viewer)
do
  local y = FL + 1
  local hs = { 8, 9, 10, 12, 13, 15, 17, 19, 21 }
  for row, hh in ipairs(hs) do
    for yy = y, min(H - 1, y + hh - 1) do
      local rp = yy - y
      for x = 0, W - 1 do
        local bw = 70 + row * 8
        local off = floor(hash(row, 1, 31) * bw)
        local k = (x + off) // bw; local px = (x + off) % bw
        local FT = { "#a06e4c", "#aa7650", "#b27e56" }
        local tone = 2 + ((hash(k, row, 11) > .62) and 1 or 0) - ((hash(k, row, 12) > .7) and 1 or 0)
        local col = FT[tone]
        if rp == 0 then col = "#80543e"
        elseif px == 0 then col = "#8a5c44"
        elseif rp == 1 then col = "#bc8a60"
        elseif hash(x // 12, yy, 14 + row) > .965 then col = "#96664a" end
        P(x, yy, col)
      end
    end
    y = y + hh
  end
end
-- wall-foot shade on the floor
for y = FL + 1, FL + 3 do for x = 0, W - 1 do tint(x, y, SHADE, .3) end end

-- rug
do
  local x0, y0, x1, y1 = 192, 166, 252, 192
  for y = y0 + 2, y1 + 2 do for x = x0 + 2, x1 + 2 do tint(x, y, SHADE, .3) end end
  local m = mrr(x0, y0, x1, y1, 1); mrim(m, ROSE[1])
  meach(m, function(x, y)
    local ex, ey = min(x - x0, x1 - x), min(y - y0, y1 - y)
    local e = min(ex, ey)
    local col = ROSE[4]
    if e <= 1 then col = TEAL[3] elseif e <= 3 then col = CREAM[5] elseif e == 4 then col = ROSE[3] end
    if e > 4 then
      local u = (x - x0 - 10) % 14; local v = abs((y - (y0 + y1) / 2))
      if abs(u - 7) + v <= 5 then col = GOLD[4] end
      if abs(u - 7) + v <= 2 then col = TEAL[4] end
      if (y - y0) % 2 == 0 and col == ROSE[4] then col = ROSE[5] end
    end
    P(x, y, col)
  end)
  for y = y0 + 1, y1 - 1, 2 do P(x0 - 2, y, CREAM[5]); P(x0 - 3, y, CREAM[4]); P(x1 + 2, y, CREAM[5]); P(x1 + 3, y, CREAM[4]) end
end
-- sun patch on the floor (through the window, with the mullion cross shadow)
local function sunEdges(y) local dy = y - 156; return 206 - dy * .85, 268 - dy * .4 end
for y = 157, 214 do
  local xl, xr = sunEdges(y)
  for x = floor(xl), floor(xr) do
    local u = (x - xl) / (xr - xl); local dy = y - 157
    if not (u > .47 and u < .54) and not (dy >= 25 and dy <= 28) then tint(x, y, "#ffe9a0", .5) else tint(x, y, "#ffe9a0", .12) end
  end
end
-- hearth glow on floor
for y = FL + 1, 215 do for x = 20, 175 do
  local dd = sqrt(((x - 89) / 78) ^ 2 + ((y - 158) / 46) ^ 2)
  if dd < .55 then tint(x, y, "#ff9c48", .3) elseif dd < 1 then tint(x, y, "#ff9c48", .14) end
end end

---------------------------------------------------------------- ceiling beam + posts
for y = 15, 19 do for x = 0, W - 1 do tint(x, y, SHADE, y < 18 and .4 or .2) end end
woodH(0, 0, W - 1, 13, TIMB, 4, 2)
for x = 0, W - 1 do if x % 96 == 40 then R(x, 0, x, 13, TIMB[2]); R(x + 1, 1, x + 1, 12, TIMB[5]) end end
R(0, 12, W - 1, 13, TIMB[2]); R(0, 14, W - 1, 14, INK)
local function post(px, w)
  R(px - 1, 15, px - 1, FL + 2, INK); R(px + w, 15, px + w, FL + 2, INK); R(px, FL + 3, px + w - 1, FL + 3, INK)
  woodV(px, 15, px + w - 1, FL + 2, TIMB, 4, px)
  R(px, 15, px + w - 1, 17, TIMB[2])
  R(px - 1, FL - 3, px + w, FL - 3, INK); R(px, FL - 2, px + w - 1, FL + 2, TIMB[3]); R(px, FL - 2, px + w - 1, FL - 2, TIMB[5])
end
local function brace(px, dir)
  for k = 0, 13 do
    local x = px + dir * k
    R(x, 15 + 13 - k - 1, x, 15 + 13 - k + 3, TIMB[4]); P(x, 15 + 13 - k - 2, INK); P(x, 15 + 13 - k + 4, INK)
    P(x, 15 + 13 - k - 1, TIMB[5])
  end
end
post(0, 8); post(137, 9); post(347, 9); post(472, 8)
brace(9, 1); brace(147, 1); brace(135, -1); brace(357, 1); brace(345, -1); brace(470, -1)

---------------------------------------------------------------- window
do
  local x0, y0, x1, y1 = 238, 22, 298, 80
  box(x0 - 5, y0 - 5, x1 + 5, y1 + 4, TIMB, 4, { lit = 2, shade = 2 })
  R(x0 - 1, y0 - 1, x1 + 1, y1 + 1, INK)
  for y = y0, y1 do for x = x0, x1 do
    local t = (y - y0) / (y1 - y0)
    local col = t < .22 and "#fbf2c0" or (t < .48 and "#f8e4a0" or (t < .7 and "#f4d088" or "#eebc74"))
    E(x, y, col)
  end end
  -- sun glare band, hills, tree
  for x = x0, x1 do
    local h1 = 40 + floor(4 * sin(x / 9) + 2 * sin(x / 4 + 1))
    for y = y0 + h1, y1 do E(x, y, "#c8a868") end
    local h2 = 47 + floor(3 * sin(x / 6 + 2))
    for y = y0 + h2, y1 do E(x, y, "#9aa85c") end
  end
  for y = y0, y0 + 26 do for x = x1 - 22, x1 do
    local e = ((x - (x1 - 4)) / 20) ^ 2 + ((y - (y0 + 8)) / 16) ^ 2
    if e < 1 and hash(x // 2, y // 2, 8) > .25 then E(x, y, hash(x // 2, y // 2, 9) > .5 and "#86a850" or "#a8c468") end
  end end
  R(x0 + 6, y0 + 12, x0 + 20, y0 + 14, "#fff8d8"); R(x0 + 10, y0 + 10, x0 + 16, y0 + 16, "#fff8d8")
  for y = y0 + 10, y0 + 16 do for x = x0 + 6, x0 + 20 do emis[y * W + x] = true end end
  -- mullions
  R(x0 + 28, y0, x0 + 32, y1, INK); R(x0 + 29, y0, x0 + 31, y1, TIMB[4]); R(x0 + 29, y0, x0 + 29, y1, TIMB[6])
  R(x0, y0 + 26, x1, y0 + 30, INK); R(x0, y0 + 27, x1, y0 + 29, TIMB[4]); R(x0, y0 + 27, x1, y0 + 27, TIMB[6])
  -- gingham valance
  for x = x0, x1 do
    local dip = ((x - x0) % 10 < 5) and ((x - x0) % 10) or (9 - (x - x0) % 10)
    for y = y0, y0 + 5 + dip // 2 do
      local chk = ((x // 3) + (y // 3)) % 2 == 0
      P(x, y, chk and ROSE[4] or CREAM[6])
    end
    P(x, y0 + 6 + dip // 2, ROSE[2])
  end
  -- sill
  box(x0 - 9, y1 + 5, x1 + 9, y1 + 9, TIMB, 5, { lit = 2, shade = 1 })
  for x = x0 - 7, x1 + 9 do tint(x, y1 + 11, SHADE, .3); tint(x, y1 + 12, SHADE, .3) end
  -- QUIRK: pie cooling on the sill
  local pm = mpoly({ {246, y1 + 4}, {243, y1 - 1}, {267, y1 - 1}, {264, y1 + 4} }); mrim(pm); mfill(pm, COPPER[3])
  local cr = mfrom(244, y1 - 7, 266, y1 - 2, function(x, y) return ((x - 255) / 12) ^ 2 + ((y - (y1 - 1)) / 6.5) ^ 2 <= 1 end)
  mrim(cr); mfill(cr, function(x, y) return (y < y1 - 5) and GOLD[6] or ((x + y) % 4 == 0 and GOLD[3] or GOLD[5]) end)
  R(244, y1 - 2, 266, y1 - 2, GOLD[4]); P(252, y1 - 5, BARN[3]); P(253, y1 - 5, BARN[3]); P(258, y1 - 4, BARN[3]); P(259, y1 - 4, BARN[3])
  -- little pot plant
  local pt = mpoly({ {280, y1 - 5}, {292, y1 - 5}, {290, y1 + 4}, {282, y1 + 4} }); mrim(pt)
  mfill(pt, function(x, y) return y <= y1 - 4 and BARN[6] or (x < 284 and BARN[5] or (x > 288 and BARN[3] or BARN[4])) end)
  for i = 0, 4 do
    local lx = 281 + i * 2 + (i % 2)
    R(lx, y1 - 13 + (i * 3) % 4, lx + 1, y1 - 6, i % 2 == 0 and GREEN[4] or GREEN[5])
  end
  R(283, y1 - 16, 285, y1 - 14, PINK[5]); P(284, y1 - 15, GOLD[5]); R(288, y1 - 14, 290, y1 - 12, PINK[6]); P(289, y1 - 13, GOLD[5])
end

---------------------------------------------------------------- hanging things from the beam
local function herbs(hx, len, ramp, tip)
  R(hx, 15, hx, 19, INK)
  local m = mfrom(hx - 5, 20, hx + 5, 22 + len, function(x, y)
    local i = abs(x - hx); local t = (y - 20) / len
    return i <= 1 + t * 3.5 and y <= 21 + len - (i % 2) * 2 - (hash(x, 1, hx) > .5 and 1 or 0)
  end)
  mrim(m)
  meach(m, function(x, y)
    local col = ramp[((x - hx) % 2 == 0) and 4 or 3]
    if x < hx - 1 then col = ramp[5] end
    if tip and y > 20 + len * .55 then col = (x % 2 == 0) and tip[5] or tip[4] end
    P(x, y, col)
  end)
  R(hx - 1, 20, hx + 1, 21, ROSE[3])
end
herbs(22, 20, GREEN); herbs(36, 16, LEAF, VIOLET)
herbs(162, 18, LEAF); herbs(176, 22, GREEN, PINK); herbs(224, 15, GREEN)
herbs(374, 22, GREEN); herbs(390, 17, LEAF, GOLD); herbs(408, 21, GREEN, VIOLET)
-- lantern
do
  local lx = 198
  for y = 15, 25 do P(lx, y, (y % 2 == 0) and INK or IRON[4]) end
  for y = 14, 62 do for x = lx - 24, lx + 24 do
    local dd = sqrt((x - lx) ^ 2 + ((y - 36) * 1.1) ^ 2)
    if G(x, y) == CREAM[5] or G(x, y) == CREAM[4] or G(x, y) == CREAM[3] then
      if dd < 13 then tint(x, y, "#ffe08a", .5) elseif dd < 22 then tint(x, y, "#ffe08a", .25) end
    end
  end end
  local cap = mpoly({ {lx - 2, 25}, {lx + 2, 25}, {lx + 7, 29}, {lx - 7, 29} }); mrim(cap); mfill(cap, function(x, y) return x < lx and IRON[5] or IRON[3] end)
  R(lx - 6, 30, lx + 6, 44, INK)
  for y = 31, 43 do for x = lx - 5, lx + 5 do
    local dd = abs(x - lx) + abs(y - 38) * .8
    E(x, y, dd < 2.5 and "#fff6cc" or (dd < 5 and "#fbe08a" or "#f0b850"))
  end end
  R(lx - 2, 31, lx - 2, 43, IRON[2]); R(lx + 2, 31, lx + 2, 43, IRON[2])
  box(lx - 7, 44, lx + 7, 46, IRON, 4, { lit = 1, shade = 1 })
end
-- garlic / onion braid on the post
for k = 0, 4 do
  local gx, gy = 139 + (k % 2) * 3, 44 + k * 7
  local m = mell(gx + 1, gy + 3, 3, 3); mrim(m); mfill(m, function(x, y) return (x <= gx and y <= gy + 3) and CREAM[6] or (k % 2 == 0 and CREAM[5] or ROSE[5]) end)
  P(gx + 1, gy - 1, DIRT[3])
end
R(141, 34, 141, 43, DIRT[3]); P(141, 33, INK)

-- peg rail with tools + QUIRK gnome hat
do
  box(304, 30, 344, 33, OAK, 5, { lit = 1, shade = 1 })
  for _, px in ipairs{ 310, 322, 336 } do R(px, 32, px + 1, 35, INK); P(px, 33, OAK[6]) end
  -- shears
  line(308, 36, 313, 50, INK, 2); line(313, 36, 308, 50, INK, 2); line(309, 37, 312, 47, IRON[5], 1); line(312, 37, 309, 47, IRON[6], 1)
  local h1 = mell(307, 54, 3, 4); mrim(h1); mfill(h1, BARN[4]); R(306, 52, 308, 56, CREAM[5])
  local h2 = mell(314, 54, 3, 4); mrim(h2); mfill(h2, BARN[4]); R(313, 52, 315, 56, CREAM[5])
  -- twine coil
  local tw = mell(323, 46, 7, 9); mrim(tw)
  mfill(tw, function(x, y) local dd = ((x - 323) / 7) ^ 2 + ((y - 46) / 9) ^ 2
    if dd < .16 then return CREAM[5] end
    return ((x + y) % 3 == 0) and DIRT[3] or ((x < 322) and DIRT[6] or DIRT[5]) end)
  local hole = mell(323, 46, 2, 3); mrim(hole, DIRT[2])
  -- gnome hat
  local hat = mpoly({ {330, 56}, {344, 56}, {342, 48}, {339, 40}, {335, 36}, {334, 42}, {332, 49} }); mrim(hat)
  mfill(hat, function(x, y) return (x - 330) < (y - 34) * .28 and "#e06a4c" or ((x > 339) and BARN[3] or "#c8463a") end)
  R(329, 54, 345, 56, CREAM[5]); R(329, 56, 345, 56, CREAM[3]); R(328, 57, 346, 57, INK); P(328, 55, INK); P(346, 55, INK)
end
-- framed mushroom picture + tiny skirting door (QUIRKS, right wall)
do
  box(442, 66, 464, 90, OAK, 5, { lit = 2, shade = 2 })
  R(445, 69, 461, 87, INK); R(446, 70, 460, 86, SBLUE[6]); R(446, 82, 460, 86, GREEN[5])
  R(452, 77, 454, 84, CREAM[6]); R(451, 84, 455, 84, CREAM[4])
  local cap = mfrom(447, 71, 459, 78, function(x, y) return ((x - 453) / 6.4) ^ 2 + ((y - 78) / 6.4) ^ 2 <= 1 end)
  mfill(cap, function(x, y) return y < 74 and "#e06a4c" or "#c8463a" end); P(450, 75, CREAM[6]); P(451, 75, CREAM[6]); P(455, 73, CREAM[6]); P(456, 76, CREAM[6]); P(457, 76, CREAM[6])
  R(453, 62, 453, 65, INK)
  -- tiny door
  local dm = mfrom(446, 128, 458, 149, function(x, y) return y >= 134 or ((x - 452) / 6.4) ^ 2 + ((y - 134) / 6.4) ^ 2 <= 1 end)
  mrim(dm); mfill(dm, function(x, y) return x == 446 and BARN[5] or ((x == 450 or x == 454) and BARN[3] or (x > 456 and BARN[3] or BARN[4])) end)
  R(455, 139, 456, 140, GOLD[5]); R(446, 136, 458, 136, IRON[3]); R(446, 145, 458, 145, IRON[3])
  R(444, 152, 460, 154, GREEN[4]); R(444, 152, 460, 152, GREEN[5]); for x = 444, 460, 3 do P(x, 154, GREEN[2]) end
end
-- left wall shelf with mugs
do
  for x = 13, 45 do tint(x, 103, SHADE, .3); tint(x, 104, SHADE, .3) end
  box(12, 98, 44, 101, OAK, 5, { lit = 1, shade = 1 })
  R(16, 102, 17, 105, INK); R(39, 102, 40, 105, INK)
  local m1 = mrect(15, 87, 23, 97); cyl(m1, TEAL); R(24, 90, 26, 90, INK); R(26, 91, 26, 94, INK); R(24, 95, 26, 95, INK); R(15, 89, 23, 89, CREAM[5])
  local jug = munion(mell(34, 91, 6, 6), mrect(31, 80, 37, 86)); sph(jug, COPPER); R(30, 79, 38, 80, INK); R(31, 80, 37, 80, COPPER[6])
  line(40, 84, 42, 88, INK, 1); line(42, 88, 40, 93, INK, 1)
end

---------------------------------------------------------------- firewood (left of hearth)
shadow(27, 158, 18, 3)
for _, lg in ipairs{ {18, 152}, {29, 152}, {40, 153}, {23, 142}, {34, 142}, {28, 132} } do
  local m = mell(lg[1], lg[2], 5, 5); mrim(m)
  mfill(m, function(x, y)
    local dd = sqrt((x - lg[1]) ^ 2 + (y - lg[2]) ^ 2)
    if dd > 4.2 then return TIMB[3] end
    if dd < 1 then return OAK[3] end
    if dd > 2 and dd < 3 then return OAK[4] end
    return (x <= lg[1] and y <= lg[2]) and OAK[6] or OAK[5]
  end)
end

---------------------------------------------------------------- 1 COOKING: stone hearth  box 44,56..134,164
do
  -- chimney breast
  stone(mrect(58, 15, 120, 69), 3, 9, 17)
  for y = 15, 20 do for x = 58, 120 do tint(x, y, SHADE, .35) end end
  for y = 15, 69 do tint(119, y, SHADE, .3); tint(120, y, SHADE, .3) end
  -- hanging copper pans
  for _, pn in ipairs{ {74, 40, 9}, {99, 37, 7} } do
    local cx, cy, r = pn[1], pn[2], pn[3]
    R(cx, 22, cx, cy - r, INK); R(cx - 1, 21, cx + 1, 22, IRON[5]); R(cx - 1, 24, cx + 1, cy - r - 1, IRON[3]); R(cx, 24, cx, cy - r - 1, IRON[5])
    for y = cy - r + 2, cy + r + 3 do for x = cx - r + 2, cx + r + 3 do if ((x - cx - 2) / r) ^ 2 + ((y - cy - 2) / r) ^ 2 <= 1 then tint(x, y, SHADE, .4) end end end
    local m = mell(cx, cy, r, r); sph(m, COPPER, { bias = .05 })
    local inn = mell(cx, cy, r - 3, r - 3); sph(inn, COPPER, { norim = true, lx = .6, ly = .7, lo = 3, hi = 5 })
    P(cx - r + 2, cy - 2, COPPER[6]); P(cx - r + 3, cy - 4, COPPER[6])
  end
  -- fireplace body
  stone(mrect(48, 79, 130, 157), 11, 10, 18)
  -- arch ring + opening
  local function inArch(x, y, g) return (y >= 110 and y <= 157 and x >= 64 - g and x <= 114 + g) or (y < 110 and ((x - 89) / (25.4 + g)) ^ 2 + ((y - 110) / (15 + g)) ^ 2 <= 1) end
  local ring = mfrom(56, 86, 122, 157, function(x, y) return inArch(x, y, 6) and not inArch(x, y, 0) end)
  mrim(ring)
  mfill(ring, function(x, y)
    local col = STONE[5]
    if y >= 110 then
      if (y - 110) % 12 == 11 then col = STONE[2] elseif (y - 110) % 12 == 0 then col = STONE[6] end
      if x == 58 or x == 115 then col = STONE[6] end
    else
      local a = math.atan(110 - y, x - 89)
      local seg = (a / math.pi * 9) % 1
      if seg < .1 then col = STONE[2] elseif seg < .22 then col = STONE[6] end
      if not inArch(x, y + 1, 6) or not inArch(x, y - 1, 6) then col = STONE[6] end
    end
    if x > 114 and y > 110 then col = (col == STONE[2]) and STONE[2] or STONE[4] end
    return col
  end)
  local op = mfrom(64, 94, 114, 157, function(x, y) return inArch(x, y, 0) end)
  mrim(op)
  mfill(op, function(x, y)
    local dd = sqrt(((x - 89) / 30) ^ 2 + ((y - 150) / 34) ^ 2)
    if dd < .45 then return "#a84a26" elseif dd < .75 then return "#7a3222" elseif dd < 1.05 then return "#50232a" end
    return "#3a1e2a"
  end)
  -- back bricks hint
  for y = 100, 150, 6 do for x = 68, 110, 12 do local xx = x + ((y // 6) % 2) * 6; if mhas(op, xx, y) and mhas(op, xx + 5, y) then for i = 0, 5 do tint(xx + i, y, INK, .35) end end end end
  -- logs
  local l1 = mrr(70, 150, 96, 156, 2); obj(l1, TIMB, { base = 3, lit = 1, shade = 2 })
  local l2 = mrr(84, 147, 110, 153, 2); obj(l2, TIMB, { base = 3, lit = 1, shade = 2 })
  for _, e in ipairs{ {70, 153}, {110, 150} } do R(e[1] - 1, e[2] - 2, e[1] + 1, e[2] + 2, OAK[5]); P(e[1], e[2], OAK[3]) end
  -- fire
  local function flame(cx, by, w, h, seed, tgt)
    for x = cx - w, cx + w do
      local dx = (x - cx) / w
      local hx = h * (1 - dx * dx) * (.55 + .45 * sin(x * 1.1 + seed) ^ 2)
      for y = floor(by - hx), by do
        local t = (by - y) / max(1, hx); local a = abs(dx)
        local col = "#d8542a"
        if t < .3 and a < .45 then col = "#fff0a8" elseif t < .55 and a < .65 then col = "#fbc44c" elseif t < .8 and a < .85 then col = "#f08a30" end
        E(x, y, col)
      end
    end
  end
  flame(89, 150, 20, 16, 1); flame(76, 151, 8, 13, 2); flame(103, 149, 8, 14, 4)
  for _, s in ipairs{ {72, 128}, {106, 124}, {98, 116} } do E(s[1], s[2], "#fbc44c") ; E(s[1] + 1, s[2], "#f08a30") end
  -- copper cook pot hanging on a chain
  for y = 95, 108 do P(89, y, (y % 2 == 0) and IRON[5] or IRON[2]) end
  line(76, 119, 89, 108, IRON[2], 1); line(102, 119, 89, 108, IRON[2], 1); line(77, 119, 89, 109, IRON[4], 1)
  local pot = mfrom(74, 120, 104, 140, function(x, y) return ((x - 89) / 15.3) ^ 2 + ((y - 125) / 15.3) ^ 2 <= 1 and y >= 121 end)
  sph(pot, COPPER, { bias = .04 })
  meach(pot, function(x, y) if y >= 136 and abs(x - 89) < 10 then P(x, y, "#f08a30") end; if y == 139 or (y >= 137 and abs(x - 89) < 5) then P(x, y, "#fbc44c") end end)
  local rimm = mrr(72, 117, 106, 121, 1); mrim(rimm); mfill(rimm, function(x, y) return y == 117 and COPPER[6] or (x < 84 and COPPER[5] or (x > 98 and COPPER[3] or COPPER[4])) end)
  R(76, 118, 102, 119, "#b4582e"); R(79, 118, 86, 118, "#e09a58"); R(94, 119, 99, 119, "#8a3c24")
  line(97, 117, 103, 109, INK, 2); line(97, 116, 102, 110, OAK[6], 1)   -- spoon handle
  R(78, 123, 79, 129, COPPER[6]); P(80, 122, COPPER[6])
  -- mantel beam + things on it
  for x = 46, 132 do tint(x, 80, SHADE, .4); tint(x, 81, SHADE, .4); tint(x, 82, SHADE, .25) end
  local mb = mrect(44, 71, 134, 78); mrim(mb); woodH(44, 71, 134, 78, TIMB, 5, 21); R(44, 71, 134, 71, TIMB[6])
  R(50, 79, 54, 82, INK); R(51, 79, 53, 81, TIMB[3]); R(124, 79, 128, 82, INK); R(125, 79, 127, 81, TIMB[3])
  -- copper kettle-pot
  local kp = munion(mell(57, 63, 8, 6), mrect(51, 57, 63, 60)); sph(kp, COPPER); R(50, 56, 64, 57, INK); R(51, 57, 63, 57, COPPER[6])
  line(65, 61, 69, 58, INK, 2); P(57, 54, INK); R(56, 55, 58, 55, COPPER[4])
  -- plate standing, candle, salt crock
  local pl = mell(79, 62, 7, 8); sph(pl, CREAM, { lo = 4 }); local pi = mell(79, 62, 4, 5); mrim(pi, SBLUE[4]); mfill(pi, CREAM[6])
  local cr = mrr(92, 60, 101, 70, 1); cyl(cr, CREAM, { bias = 0 }); R(92, 64, 101, 65, SBLUE[4]); R(93, 59, 100, 59, INK); P(94, 62, "#fffbe6"); P(94, 63, "#fffbe6")
  R(109, 62, 112, 70, INK); R(110, 63, 111, 70, CREAM[6]); P(111, 66, CREAM[4]); R(108, 70, 113, 70, IRON[4])
  E(110, 59, "#fbc44c"); E(110, 60, "#fff0a8"); E(111, 60, "#f08a30"); E(110, 61, "#f08a30"); E(110, 58, "#f08a30")
  -- ladle + fork hanging under mantel (right)
  R(121, 83, 121, 97, INK); R(122, 83, 122, 97, COPPER[5]); local ld = mell(122, 101, 3, 3); sph(ld, COPPER)
  -- hearth slab
  shadow(89, 166, 52, 3)
  local sl = mrect(42, 158, 136, 164); mrim(sl)
  mfill(sl, function(x, y) if y <= 159 then return STONE[6] end; if y == 164 then return STONE[2] end; return ((x - 42) % 24 == 23) and STONE[2] or STONE[4] end)
  for x = 60, 118 do if G(x, 158) == STONE[6] then P(x, 158, "#f4c890"); P(x, 159, "#e8b480") end end
  -- warm light on arch inner stones
  meach(ring, function(x, y) if inArch(x, y, 2) and y > 104 then tint(x, y, "#ff9c48", .35) end end)
end

---------------------------------------------------------------- 2 PANTRY  box 150,58..230,148
do
  local x0, y0, x1, y1 = 150, 58, 230, 148
  for y = y1 + 1, y1 + 5 do for x = x0 + 2, x1 + 3 do tint(x, y, SHADE, .38) end end
  for y = y0 + 6, y1 do tint(x1 + 1, y, SHADE, .35); tint(x1 + 2, y, SHADE, .35); tint(x1 + 3, y, SHADE, .2) end
  box(x0 + 2, y0 + 4, x1 - 2, y1, TIMB, 4, { lit = 0, shade = 0, sr = 0 })
  woodV(x0 + 2, y0 + 4, x0 + 5, y1, OAK, 4, 41); woodV(x1 - 5, y0 + 4, x1 - 2, y1, OAK, 3, 42)
  local cm = mrect(x0, y0, x1, y0 + 4); mrim(cm); woodH(x0, y0, x1, y0 + 4, OAK, 5, 43); R(x0, y0, x1, y0, OAK[6])
  -- back
  for y = y0 + 6, 138 do for x = x0 + 6, x1 - 6 do
    local col = ((x - x0) % 12 == 0) and "#33202c" or "#46293a"
    P(x, y, col)
  end end
  R(x0 + 6, y0 + 5, x1 - 6, y0 + 5, INK); R(x0 + 6, y0 + 6, x1 - 6, y0 + 8, "#33202c")
  local function jar(x, by, w, h, ramp, lid, label)
    local top = by - h + 1
    local m = mrr(x, top + 3, x + w - 1, by, 1); mrim(m)
    meach(m, function(px, py)
      local rx = px - x; local col
      if py <= top + 5 then col = (rx >= 1 and rx <= 2) and GL[3] or (rx >= w - 2 and GL[1] or GL[2])
      elseif rx == 0 then col = ramp[4]
      elseif rx <= 2 then col = ramp[6]
      elseif rx >= w - 2 then col = ramp[3]
      else col = ramp[5] end
      if py == by and py > top + 5 then col = ramp[3] end
      P(px, py, col)
    end)
    R(x + 1, top + 6, x + w - 2, top + 6, ramp[6])
    local lm = mrect(x + 1, top, x + w - 2, top + 2); mrim(lm)
    if lid == "cloth" then
      mfill(lm, function(px, py) return ((px + py) % 2 == 0) and ROSE[4] or CREAM[6] end); P(x, top + 3, ROSE[3]); P(x + w - 1, top + 3, ROSE[3]); R(x + 1, top + 3, x + w - 2, top + 3, DIRT[3])
    elseif lid == "cork" then mfill(lm, function(px, py) return py == top and DIRT[6] or DIRT[4] end)
    else mfill(lm, function(px, py) return py == top and IRON[6] or IRON[4] end) end
    if label then R(x + 4, by - 8, x + w - 3, by - 4, CREAM[6]); R(x + 4, by - 4, x + w - 3, by - 4, CREAM[4]); R(x + 5, by - 7, x + 6, by - 6, label) end
  end
  local function crock(x, by, w, h, band)
    local m = mrr(x, by - h + 1, x + w - 1, by, 2); cyl(m, CREAM)
    R(x + 1, by - h + 5, x + w - 2, by - h + 6, band); R(x + 1, by - 4, x + w - 2, by - 4, band)
    R(x + 2, by - h + 3, x + 3, by - h + 4, "#fffbe6"); R(x + 2, by - h + 8, x + 2, by - 6, "#fffbe6")
    R(x + 2, by - h, x + w - 3, by - h, INK); R(x + 3, by - h - 1, x + w - 4, by - h - 1, INK); R(x + 3, by - h, x + w - 4, by - h, DIRT[5])
  end
  local shelves = { 84, 111, 138 }
  for _, sy in ipairs(shelves) do
    local sm = mrect(x0 + 6, sy, x1 - 6, sy + 2); mrim(sm); mfill(sm, function(x, y) return y == sy and OAK[6] or (y == sy + 1 and OAK[5] or OAK[3]) end)
    for x = x0 + 6, x1 - 6 do tint(x, sy + 4, INK, .4) end
  end
  -- row 1
  jar(158, 83, 12, 17, BARN, "cloth", BARN[4]); jar(172, 83, 11, 14, GOLD, "tin"); crock(185, 83, 13, 16, SBLUE[4])
  jar(200, 83, 9, 19, VIOLET, "cork");
  -- QUIRK: cheese wedge with a bite out
  local ch = mpoly({ {211, 83}, {224, 83}, {224, 73}, {211, 79} }); mrim(ch)
  mfill(ch, function(x, y) return (y - 73 < (224 - x) * .46 + 2) and GOLD[6] or GOLD[5] end)
  local bite = mell(224, 77, 3, 3); mfill(bite, "#46293a"); P(220, 76, INK); P(220, 77, INK); P(221, 78, INK); P(221, 75, INK); R(222, 81, 224, 81, INK); P(221, 80, INK); P(221, 79, INK)
  P(214, 80, GOLD[3]); P(215, 80, GOLD[3]); P(218, 81, GOLD[3])
  -- row 2
  jar(157, 110, 13, 19, GREEN, "tin", GREEN[3]); P(162, 96, GREEN[3]); P(165, 99, GREEN[3]); P(163, 101, GREEN[6])
  local sk = mfrom(172, 92, 186, 110, function(x, y) return ((x - 179) / 7.4) ^ 2 + ((y - 102) / 9) ^ 2 <= 1 or (y > 102 and x >= 172 and x <= 186) or (y < 96 and abs(x - 179) < 4 and y >= 91) end)
  sph(sk, CREAM, { lo = 3 }); R(175, 95, 183, 95, DIRT[3]); R(177, 101, 181, 105, ROSE[3]); R(178, 102, 180, 104, ROSE[5])
  jar(189, 110, 11, 15, TEAL, "cloth"); jar(202, 110, 12, 18, ROSE, "cork", ROSE[3]); jar(216, 110, 9, 13, GOLD, "tin")
  -- row 3
  crock(157, 137, 15, 19, BARN[4]); jar(174, 137, 12, 16, VIOLET, "tin", VIOLET[3]); jar(188, 137, 11, 20, LEAF, "cork")
  local pk = mell(209, 130, 9, 7); sph(pk, {"#5a2a1c","#8a431e","#b4601e","#dc8228","#f4a63c","#fcd070"}); R(204, 125, 204, 135, "#b4601e"); R(214, 125, 214, 135, "#b4601e"); R(208, 120, 210, 122, GREEN[3]); P(209, 119, INK)
  jar(220, 137, 6, 11, BARN, "cork")
  -- drawers
  for i = 0, 1 do
    local dx0 = x0 + 6 + i * 35
    box(dx0, 141, dx0 + 32, 147, OAK, 4, { lit = 1, shade = 1 }); R(dx0 + 14, 143, dx0 + 18, 145, INK); R(dx0 + 15, 143, dx0 + 17, 144, GOLD[5])
  end
end

---------------------------------------------------------------- 3 TOOLS  box 256,94..344,158
do
  shadow(300, 160, 46, 3)
  -- under-bench darkness
  for y = 137, 157 do for x = 262, 338 do tint(x, y, SHADE, .5) end end
  -- tool board
  box(262, 94, 338, 126, OAK, 5, { lit = 1, shade = 1 })
  for y = 95, 125 do for x = 263, 337 do if (x - 263) % 19 == 18 then P(x, y, OAK[3]) end end end
  -- saw (big, across the board)
  local bl = mpoly({ {277, 97}, {314, 100}, {314, 105}, {277, 110} }); mrim(bl)
  mfill(bl, function(x, y) return y <= 99 and IRON[6] or (y <= 103 and IRON[5] or IRON[4]) end)
  R(281, 100, 306, 100, "#e2e2ec")
  for x = 278, 313, 3 do local ty = 111 - floor((x - 277) * 5 / 37); P(x, ty, INK); P(x + 1, ty, INK); P(x, ty - 1, IRON[3]) end
  local sh = mrr(264, 95, 277, 111, 2); obj(sh, BARN, { base = 4, lit = 2, shade = 2 }); R(268, 100, 273, 106, INK); R(269, 101, 272, 105, OAK[4])
  P(275, 98, GOLD[5]); P(275, 108, GOLD[5])
  -- legs, lower shelf, drawer
  box(260, 137, 268, 157, OAK, 3, { lit = 0, shade = 1 }); box(332, 137, 340, 157, OAK, 3, { lit = 0, shade = 1 })
  box(269, 147, 331, 150, OAK, 3, { lit = 1, shade = 1 })
  -- toolbox + paint tin on lower shelf
  box(274, 139, 298, 146, BARN, 4, { lit = 2, shade = 1 }); R(282, 137, 290, 138, INK); R(283, 137, 289, 137, IRON[5]); R(285, 142, 287, 143, GOLD[5])
  local tin = mrect(308, 139, 318, 146); cyl(tin, IRON); R(308, 141, 318, 143, SBLUE[4]); R(309, 141, 310, 143, SBLUE[6])
  -- bench top
  local bt = mrect(256, 128, 344, 136); mrim(bt)
  mfill(bt, function(x, y)
    if y <= 129 then return ((x // 11) % 2 == 0) and PINE[5] or PINE[6] end
    if y == 130 then return PINE[4] end
    if y == 136 then return OAK[2] end
    return (hash(x // 8, y, 51) > .8) and OAK[3] or OAK[4]
  end)
  -- iron vice
  local vb = mrect(258, 121, 280, 127); obj(vb, IRON, { base = 3, lit = 1, shade = 1 })
  local j1 = mrect(260, 111, 266, 120); obj(j1, IRON, { base = 4, lit = 2, shade = 0 })
  local j2 = mrect(270, 111, 276, 120); obj(j2, IRON, { base = 4, lit = 2, shade = 0 })
  R(267, 114, 269, 119, IRON[1])
  R(277, 114, 284, 116, INK); R(277, 115, 283, 115, IRON[6])
  R(284, 108, 286, 124, INK); R(285, 109, 285, 123, IRON[5]); local k1 = mell(285, 108, 2, 2); mrim(k1); mfill(k1, IRON[6]); local k2 = mell(285, 124, 2, 2); mrim(k2); mfill(k2, IRON[4])
  -- hammer lying on the bench + shavings
  for x = 289, 311 do tint(x, 128, SHADE, .35) end
  R(289, 122, 305, 126, INK); R(290, 123, 304, 125, PINE[5]); R(290, 123, 304, 123, PINE[6])
  local hh = mrect(304, 116, 310, 127); obj(hh, IRON, { base = 4, lit = 2, shade = 2 }); R(305, 117, 305, 124, IRON[6])
  for _, s in ipairs{ {338, 126} } do R(s[1], s[2], s[1] + 2, s[2] + 1, PINE[6]); P(s[1] + 1, s[2] + 1, PINE[4]); P(s[1] + 3, s[2] + 2, INK) end
  -- QUIRK: half-built birdhouse
  local bh = mrect(316, 114, 332, 127); obj(bh, PINE, { base = 4, lit = 1, shade = 1 })
  local eh = mell(324, 120, 3, 3); mrim(eh, OAK[3]); mfill(eh, "#46293a")
  R(323, 125, 325, 125, OAK[3]); R(324, 124, 324, 124, OAK[6])
  local rf = mpoly({ {313, 114}, {324, 105}, {335, 114}, {335, 116}, {313, 116} }); mrim(rf)
  mfill(rf, function(x, y) return (x < 324) and BARN[5] or BARN[3] end); R(323, 106, 325, 107, BARN[6])
  -- sawdust on the floor
  for i = 0, 22 do
    local sx = 276 + floor(hash(i, 1, 60) * 60); local sy = 160 + floor(hash(i, 2, 60) * 9)
    R(sx, sy, sx + 1, sy, PINE[6])
  end
  local sd = mfrom(318, 157, 336, 163, function(x, y) return ((x - 327) / 9) ^ 2 + ((y - 163) / 6) ^ 2 <= 1 end)
  mrim(sd, OAK[2]); mfill(sd, function(x, y) return (x < 326 and y < 161) and PINE[6] or PINE[5] end)
end

---------------------------------------------------------------- 4 GARDEN  box 358,66..440,158
do
  shadow(399, 159, 42, 2)
  for y = 126, 157 do for x = 364, 434 do tint(x, y, SHADE, .5) end end
  -- uprights + upper shelf
  box(362, 78, 365, 117, OAK, 4, { lit = 0, shade = 0 }); box(433, 78, 436, 117, OAK, 3, { lit = 0, shade = 0 })
  for x = 362, 436 do tint(x, 98, SHADE, .35); tint(x, 99, SHADE, .35) end
  box(359, 92, 439, 96, OAK, 5, { lit = 2, shade = 1 })
  local function tpot(x, by, w, h)
    local m = mpoly({ {x, by - h + 4}, {x + w, by - h + 4}, {x + w - 2, by}, {x + 2, by} })
    mrim(m); mfill(m, function(px, py) local t = (px - x) / w; return t < .2 and BARN[6] or (t < .6 and BARN[5] or (t < .8 and BARN[4] or BARN[3])) end)
    local r = mrect(x - 1, by - h + 1, x + w + 1, by - h + 3); mrim(r); mfill(r, function(px, py) return py == by - h + 1 and "#f0aa80" or (px > x + w * .7 and BARN[4] or BARN[6]) end)
  end
  -- herb 1 (tall), bush 2, QUIRK boot with a sprout
  for i = 0, 3 do local lx = 371 + i * 3; R(lx, 67 + (i * 5) % 7, lx + 1, 80, i % 2 == 0 and GREEN[4] or GREEN[5]); R(lx - 1, 70 + (i * 5) % 7, lx - 1, 72 + (i * 5) % 7, GREEN[5]) end
  for i = 0, 3 do local lx = 371 + i * 3; P(lx, 66 + (i * 5) % 7, VIOLET[5]); P(lx + 1, 66 + (i * 5) % 7, VIOLET[6]) end
  tpot(369, 91, 13, 13)
  local bu = mell(395, 76, 8, 6); sph(bu, GREEN, { lo = 3 }); P(391, 73, PINK[6]); P(392, 73, PINK[5]); P(397, 76, PINK[6]); P(398, 76, PINK[5]); P(394, 78, PINK[5]); P(400, 72, PINK[6])
  tpot(389, 91, 12, 11)
  local boot = munion(mrr(408, 78, 416, 91, 1), mrr(408, 85, 423, 91, 2)); mrim(boot)
  mfill(boot, function(x, y) if y >= 90 then return TIMB[2] end; if y <= 79 then return DIRT[2] end; return x <= 409 and DIRT[6] or ((x > 414 and y < 86) and DIRT[3] or ((x > 420) and DIRT[3] or DIRT[4])) end)
  R(411, 82, 414, 82, CREAM[5]); R(411, 85, 414, 85, CREAM[5])
  R(412, 70, 413, 78, GREEN[5]); R(409, 71, 411, 72, GREEN[5]); P(408, 70, GREEN[6]); R(414, 68, 416, 69, GREEN[4]); P(417, 67, GREEN[6]); P(412, 69, GREEN[6])
  -- bench legs, lower shelf
  box(362, 126, 368, 157, OAK, 3, { lit = 0, shade = 1 }); box(430, 126, 436, 157, OAK, 3, { lit = 0, shade = 1 })
  box(369, 144, 429, 147, OAK, 3, { lit = 1, shade = 1 })
  -- compost sack
  local sack = mfrom(370, 124, 396, 143, function(x, y) return (((x - 383) / 13.4) ^ 2 + ((y - 134) / 10) ^ 2 <= 1) or (y > 134 and y <= 143) end)
  sph(sack, DIRT, { lo = 2, bias = .05 })
  R(374, 125, 392, 127, "#3a2a26"); R(376, 124, 390, 124, "#3a2a26"); P(379, 125, DIRT[2]); P(385, 126, DIRT[2]); P(388, 125, GREEN[4])
  local lf = mpoly({ {379, 137}, {383, 131}, {388, 133}, {387, 138}, {382, 140} }); mfill(lf, GREEN[3]); line(380, 139, 387, 133, GREEN[5], 1)
  -- stack of pots on their side
  for i = 2, 0, -1 do
    local px = 402 + i * 8
    local m = mpoly({ {px, 131}, {px + 12, 133}, {px + 12, 141}, {px, 143} }); mrim(m)
    mfill(m, function(x, y) return y < 135 and BARN[5] or (y > 140 and BARN[3] or BARN[4]) end)
    R(px, 131, px + 1, 143, BARN[6]); R(px, 131, px, 143, INK)
  end
  -- bench top
  local bt = mrect(358, 118, 440, 125); mrim(bt)
  mfill(bt, function(x, y)
    if y <= 119 then return ((x // 13) % 2 == 0) and OAK[6] or PINE[5] end
    if y == 120 then return OAK[5] end
    if y == 125 then return OAK[2] end
    return (hash(x // 8, y, 52) > .8) and OAK[3] or OAK[4]
  end)
  -- seed tray with sprouts
  box(364, 110, 394, 117, PINE, 3, { lit = 1, shade = 2 }); R(366, 109, 392, 110, "#3a2a26"); R(366, 109, 392, 109, DIRT[1])
  R(364, 108, 364, 109, INK); R(394, 108, 394, 109, INK)
  for i = 0, 4 do
    local sx = 368 + i * 6; local hgt = 4 + (i * 3) % 4
    R(sx, 109 - hgt, sx + 1, 109, GREEN[5]); R(sx - 2, 108 - hgt, sx - 1, 109 - hgt, GREEN[6]); R(sx + 2, 107 - hgt, sx + 3, 108 - hgt, GREEN[4])
  end
  -- spilled soil + trowel
  local soil = mfrom(396, 113, 406, 117, function(x, y) return ((x - 401) / 5.4) ^ 2 + ((y - 117) / 4.4) ^ 2 <= 1 end); mrim(soil, "#2e2024"); mfill(soil, function(x, y) return y < 115 and DIRT[2] or "#3a2a26" end)
  -- watering can
  line(410, 111, 400, 101, INK, 4); line(411, 112, 401, 102, TEAL[5], 2)
  local rose = mpoly({ {396, 102}, {400, 97}, {404, 100}, {400, 105} }); mrim(rose); mfill(rose, function(x, y) return y < 101 and TEAL[6] or TEAL[4] end)
  local hd = mfrom(424, 99, 436, 116, function(x, y) local dd = ((x - 427) / 8) ^ 2 + ((y - 107) / 8) ^ 2; return dd <= 1 and dd >= .5 and x >= 427 end)
  mrim(hd); mfill(hd, TEAL[4])
  local th = mfrom(410, 93, 426, 101, function(x, y) local dd = ((x - 418) / 7) ^ 2 + ((y - 101) / 7) ^ 2; return dd <= 1 and dd >= .5 end)
  mrim(th); mfill(th, TEAL[5])
  local cb = mrr(408, 100, 427, 117, 1); cyl(cb, TEAL); R(408, 103, 427, 103, TEAL[2]); R(408, 114, 427, 114, TEAL[2]); R(410, 100, 425, 100, TEAL[6])
  R(411, 105, 412, 111, "#d4ecd8")
  -- soil spill + tiny mushroom on the floor
  R(424, 159, 432, 160, "#5a4034"); R(426, 158, 430, 158, "#5a4034")
end

-- sun beam in the air (one soft step), from the window down to the floor patch
for y = 92, 156 do
  local t = (y - 92) / 64
  local xl, xr = 236 + (206 - 236) * t, 300 + (268 - 300) * t
  for x = floor(xl), floor(xr) do if not emis[y * W + x] then tint(x, y, "#ffe9a0", .13) end end
end
for i = 0, 9 do
  local mx = 214 + floor(hash(i, 3, 90) * 60); local my = 96 + floor(hash(i, 4, 90) * 56)
  R(mx, my, mx + 1, my, "#fff4c4")
end

---------------------------------------------------------------- 5 POTIONS: cauldron  box 94,172..188,247
do
  shadow(138, 246, 44, 6); shadow(180, 247, 12, 3)
  -- legs
  for _, lx in ipairs{ 114, 153 } do
    local lg = mpoly({ {lx, 230}, {lx + 6, 230}, {lx + 5 + (lx > 130 and 2 or -2), 246}, {lx + 1 + (lx > 130 and 2 or -2), 246} }); mrim(lg); mfill(lg, function(x, y) return x <= lx + 2 and IRON[4] or IRON[2] end)
  end
  -- embers
  for x = 124, 150 do
    local h = 2 + floor(4 * sin(x / 2.3) ^ 2)
    for y = 245 - h, 246 do E(x, y, (245 - y) < 2 and "#fbc44c" or ((x % 5 < 2) and "#f08a30" or "#d8542a")) end
  end
  R(122, 246, 152, 247, "#5a2a2a"); P(127, 246, "#f08a30"); P(140, 247, "#f08a30"); P(147, 246, "#fbc44c")
  -- body
  local body = mfrom(108, 190, 166, 240, function(x, y) return ((x - 137) / 29.4) ^ 2 + ((y - 214) / 25.4) ^ 2 <= 1 and y >= 194 end)
  sph(body, IRON, { bias = -.02 })
  meach(body, function(x, y)
    local dd = ((x - 137) / 29.4) ^ 2 + ((y - 214) / 25.4) ^ 2
    if y > 228 and dd > .62 and abs(x - 137) < 20 then P(x, y, dd > .86 and "#f08a30" or "#8a4a3e") end   -- ember underglow
    if y == 207 and (x % 6 == 0) then P(x, y, IRON[6]); P(x + 1, y, IRON[6]) end                       -- rivets
    if y == 208 and (x % 6 == 0) then P(x, y, IRON[1]) end
  end)
  R(117, 200, 119, 212, IRON[6]); R(120, 198, 121, 201, IRON[6]); R(116, 214, 117, 219, IRON[5])
  -- handles
  for _, hx in ipairs{ 103, 166 } do local hm = mfrom(hx, 202, hx + 7, 213, function(x, y) local dd = ((x - hx - 3.5) / 4) ^ 2 + ((y - 207.5) / 6) ^ 2; return dd <= 1 and dd > .3 end); mrim(hm); mfill(hm, IRON[4]) end
  -- stirring stick (behind rim)
  line(131, 192, 118, 173, INK, 4); line(132, 192, 119, 174, OAK[5], 2); line(132, 192, 119, 174, OAK[6], 1)
  -- rim + brew
  local rimm = mell(137, 193, 31, 6); mrim(rimm)
  mfill(rimm, function(x, y) return y <= 189 and IRON[6] or (x < 120 and IRON[5] or (x > 156 and IRON[3] or IRON[4])) end)
  local brew = mell(137, 192, 27, 4); mrim(brew, IRON[1])
  meach(brew, function(x, y)
    local col = "#58c07a"
    if y <= 189 then col = "#2f8a5e" elseif y >= 195 then col = "#8ce29a" end
    E(x, y, col)
  end)
  for _, b in ipairs{ {124, 192, 2}, {137, 191, 3}, {149, 193, 2}, {143, 194, 1}, {130, 195, 1} } do
    local m = mell(b[1], b[2], b[3], b[3]); mrim(m, "#2f8a5e"); meach(m, function(x, y) E(x, y, (x <= b[1] and y <= b[2]) and "#e4ffd8" or "#a8f0a0") end)
  end
  for x = 112, 162 do if G(x, 199) and not emis[199 * W + x] and x % 3 ~= 0 then tint(x, 199, "#8ce29a", .35) end end
  -- bottles
  local function bottle(x, by, w, h, ramp, round)
    local top = by - h + 1
    local m
    if round then m = munion(mell(x + w // 2, by - w // 2, w // 2, w // 2), mrect(x + w // 2 - 1, top + 2, x + w // 2 + 1, by - w + 1))
    else m = munion(mrr(x, top + 6, x + w - 1, by, 1), mrect(x + w // 2 - 1, top + 2, x + w // 2 + 1, top + 6)) end
    mrim(m)
    local lvl = round and (by - w + 3) or (top + 9)
    meach(m, function(px, py)
      local rx = px - x; local col
      if py < lvl then col = (rx == 1 or rx == 2) and GL[3] or GL[2]
      elseif rx <= 0 then col = ramp[4] elseif rx <= 2 then col = ramp[6] elseif rx >= w - 2 then col = ramp[3] else col = ramp[5] end
      if py == lvl then col = ramp[6] end
      P(px, py, col)
    end)
    local ck = mrect(x + w // 2 - 1, top, x + w // 2 + 1, top + 1); mrim(ck); mfill(ck, DIRT[5])
  end
  -- stool with bottles
  box(169, 224, 189, 227, OAK, 5, { lit = 1, shade = 1 }); box(171, 228, 174, 246, OAK, 3, { lit = 0, shade = 1 }); box(184, 228, 187, 246, OAK, 3, { lit = 0, shade = 1 })
  R(175, 236, 183, 237, OAK[3]); R(175, 235, 183, 235, INK)
  bottle(170, 223, 8, 22, SBLUE); bottle(180, 223, 9, 17, VIOLET, true)
  bottle(94, 246, 9, 20, ROSE); bottle(104, 246, 7, 13, GOLD, true)
  star(183, 213, "#f4eaff")   -- QUIRK: a little star twinkling inside the violet flask
end

---------------------------------------------------------------- 6 BUILDING  box 238,202..330,248
do
  shadow(284, 248, 50, 5)
  -- timber stack (back)
  for i = 0, 2 do
    local y = 234 - i * 8
    local xa, xb = 246 + (i % 2) * 5, 322 - ((i + 1) % 2) * 6
    local m = mrect(xa, y, xb, y + 7); mrim(m)
    mfill(m, function(x, yy)
      if x >= xb - 6 then  -- end grain
        return (yy == y) and PINE[6] or (((x + yy) % 3 == 0) and PINE[3] or PINE[5])
      end
      if x == xb - 7 then return OAK[2] end
      if yy <= y + 1 then return PINE[6] end
      if yy == y + 7 then return PINE[2] end
      return (hash(x // 10, yy, 70 + i) > .75) and PINE[3] or PINE[4]
    end)
  end
  -- rope coil on top
  local rc = mfrom(266, 200, 296, 217, function(x, y) return ((x - 281) / 14.4) ^ 2 + ((y - 210) / 7.4) ^ 2 <= 1 end)
  mrim(rc)
  mfill(rc, function(x, y)
    local dd = sqrt(((x - 281) / 14.4) ^ 2 + ((y - 210) / 7.4) ^ 2)
    if dd < .28 then return "#4a3428" end
    local ring = floor(dd * 4.2)
    local col = (ring % 2 == 0) and DIRT[5] or DIRT[4]
    if (x + y * 2 + ring) % 4 == 0 then col = DIRT[2] end
    if y < 207 and col ~= DIRT[2] then col = DIRT[6] end
    return col
  end)
  line(294, 212, 302, 218, INK, 3); line(295, 212, 302, 217, DIRT[5], 1); R(301, 217, 304, 220, INK); R(302, 218, 303, 219, DIRT[6])
  -- stone blocks (front left)
  local function blockS(x0, y0, x1, y1, s)
    local m = mrr(x0, y0, x1, y1, 1); mrim(m)
    mfill(m, function(x, y)
      if y <= y0 + 2 then return STONE[6] end
      if y >= y1 - 1 then return STONE[3] end
      if x <= x0 + 1 then return STONE[6] end
      if x >= x1 - 1 then return STONE[3] end
      return (hash(x // 2, y // 2, s) > .86) and STONE[4] or STONE[5]
    end)
  end
  blockS(238, 232, 262, 247, 81); blockS(260, 236, 278, 247, 82); blockS(243, 218, 262, 231, 83)
  line(248, 222, 252, 226, STONE[3], 1); P(254, 240, STONE[3]); P(255, 241, STONE[3]); P(246, 238, STONE[3])
  -- bricks (front right), stepped pile
  for row = 0, 3 do
    local n = 3 - (row >= 2 and 1 or 0) - (row >= 3 and 1 or 0)
    for col = 0, n - 1 do
      local x = 292 + col * 13 + (row % 2) * 6
      local y = 241 - row * 7
      local t = 4 + (hash(row, col, 3) > .55 and 1 or 0)
      local m = mrect(x, y, x + 11, y + 5); mrim(m)
      mfill(m, function(px, py) return py == y and BARN[min(6, t + 1)] or ((py == y + 5 or px == x + 11) and BARN[t - 1] or BARN[t]) end)
    end
  end
  -- trowel resting on the bricks
  line(309, 219, 316, 213, INK, 3); line(310, 219, 316, 214, OAK[5], 1)
  local tb = mpoly({ {300, 226}, {310, 219}, {312, 222}, {304, 227} }); mrim(tb); mfill(tb, function(x, y) return y < 223 and IRON[6] or IRON[4] end)
end

---------------------------------------------------------------- 7 DECOR: upright floor loom + yarn basket  box 343,170..431,229
do
  for y = 228, 229 do for x = 344, 430 do if (x < 408 or x > 409) then tint(x, y, SHADE, .38) end end end
  -- see-through dark behind the warp
  for y = 179, 222 do for x = 355, 395 do tint(x, y, SHADE, .5) end end
  -- warp roll
  local wr = mrect(355, 180, 395, 185); mrim(wr); mfill(wr, function(x, y) return (x % 2 == 0) and CREAM[6] or (y > 183 and CREAM[3] or CREAM[4]) end)
  -- warp threads
  for y = 186, 201 do for x = 357, 393, 2 do P(x, y, y < 188 and CREAM[4] or CREAM[6]) end end
  -- heddle bar
  local hb = mrect(353, 190, 397, 192); mrim(hb); mfill(hb, function(x, y) return y == 190 and OAK[6] or OAK[4] end)
  -- woven cloth
  local cl = mrect(356, 202, 394, 219); mrim(cl)
  local stripes = { ROSE, ROSE, CREAM, TEAL, TEAL, GOLD, ROSE, ROSE, CREAM, VIOLET, VIOLET, GOLD, TEAL, TEAL, CREAM, ROSE, ROSE, ROSE }
  mfill(cl, function(x, y)
    local ramp = stripes[y - 201]
    local b = (ramp == CREAM) and 5 or 4
    local col = ramp[((x + y) % 2 == 0) and b or b + 1]
    if (y - 202) % 9 == 4 and ((x - 356) % 8 < 2) then col = ramp[6] end
    if x <= 357 then col = ramp[min(6, b + 2)] end
    if x >= 393 then col = ramp[b - 1] end
    return col
  end)
  -- beater at the fell
  local be = mrect(353, 198, 397, 201); mrim(be); mfill(be, function(x, y) return y == 198 and PINE[6] or (y == 201 and PINE[3] or PINE[4]) end)
  -- cloth beam
  local cb = mrect(353, 220, 397, 223); mrim(cb); mfill(cb, function(x, y) return y == 220 and TIMB[6] or (y == 223 and TIMB[3] or TIMB[4]) end)
  -- frame
  local function upr(x0)
    local m = mrect(x0, 173, x0 + 6, 223); mrim(m); woodV(x0, 173, x0 + 6, 223, TIMB, 5, x0)
    local ft = mrr(x0 - 3, 222, x0 + 9, 227, 1); mrim(ft); mfill(ft, function(x, y) return y == 222 and TIMB[6] or (y >= 226 and TIMB[3] or TIMB[4]) end)
    R(x0 + 2, 187, x0 + 4, 188, INK); R(x0 + 2, 187, x0 + 3, 187, GOLD[4]); R(x0 + 2, 210, x0 + 4, 211, INK); R(x0 + 2, 210, x0 + 3, 210, GOLD[4])
  end
  upr(348); upr(396)
  local tbm = mrect(345, 172, 405, 178); mrim(tbm); woodH(345, 172, 405, 178, TIMB, 5, 91); R(345, 172, 405, 173, TIMB[6])
  -- draped finished scarf over the top beam (QUIRK: tassels)
  local sc = mrect(360, 172, 371, 191); mrim(sc)
  mfill(sc, function(x, y) local ramp = ((y - 171) // 4 % 2 == 0) and GOLD or TEAL; return ramp[(x <= 362) and 6 or ((x >= 370) and 3 or (((x + y) % 2 == 0) and 4 or 5))] end)
  for x = 360, 371, 2 do P(x, 193, GOLD[5]); P(x, 194, GOLD[3]) end
  -- yarn basket
  local function yarn(cx, cy, r, ramp)
    local m = mell(cx, cy, r, r); mrim(m)
    mfill(m, function(x, y)
      local col = ((x - cx) + (y - cy) < -1) and ramp[5] or ramp[4]
      if (x + y) % 3 == 0 then col = ramp[3] end
      if (x - cx) + (y - cy) < -r + 1 then col = ramp[6] end
      return col
    end)
  end
  yarn(416, 210, 5, ROSE); yarn(425, 211, 4, TEAL); yarn(420, 206, 4, GOLD)
  local bk = mpoly({ {410, 213}, {430, 213}, {428, 227}, {412, 227} }); mrim(bk)
  mfill(bk, function(x, y)
    local col = (((x // 3) + (y // 2)) % 2 == 0) and DIRT[5] or DIRT[4]
    if x <= 412 then col = DIRT[6] elseif x >= 427 then col = DIRT[3] end
    if y >= 226 then col = DIRT[3] end
    return col
  end)
  R(409, 212, 431, 214, INK); R(410, 213, 430, 213, DIRT[6])
  line(410, 222, 406, 226, ROSE[4], 1)
end

---------------------------------------------------------------- foreground props (bottom-left, in cool shade)
do
  shadow(44, 259, 40, 5)
  -- barrel
  local bm = mfrom(10, 206, 52, 258, function(x, y) local t = (y - 232) / 26; return abs(x - 31) <= 21 - 3.5 * t * t end)
  mrim(bm)
  mfill(bm, function(x, y)
    local t = (x - 10) / 42
    local col = t < .12 and OAK[4] or (t < .4 and OAK[5] or (t < .7 and OAK[4] or OAK[3]))
    if (x - 10) % 7 == 3 then col = OAK[2] end
    if t > .9 then col = OAK[2] end
    return col
  end)
  for _, hy in ipairs{ 213, 246 } do
    for x = 9, 53 do if mhas(bm, x, hy) then P(x, hy - 1, INK); P(x, hy, IRON[6]); P(x, hy + 1, IRON[4]); P(x, hy + 2, IRON[3]); P(x, hy + 3, INK) end end
    P(20, hy + 1, IRON[6]); P(40, hy + 1, IRON[2])
  end
  R(11, 205, 51, 206, INK); R(12, 205, 50, 205, OAK[6])
  -- candle + mug on the barrel (QUIRK: stub of candle in a saucer, melted)
  local sa = mrect(15, 202, 29, 204); mrim(sa); mfill(sa, function(x, y) return y == 202 and COPPER[6] or COPPER[4] end)
  local cd = mrect(19, 192, 24, 201); mrim(cd); mfill(cd, function(x, y) return x <= 20 and "#fff4d4" or (x >= 24 and CREAM[4] or CREAM[6]) end)
  P(25, 195, CREAM[6]); P(25, 196, CREAM[6]); P(26, 196, INK); P(25, 197, INK); P(18, 199, CREAM[6]); P(18, 200, CREAM[6])
  P(21, 190, INK); P(21, 191, INK)
  E(21, 186, "#f08a30"); E(21, 187, "#fbc44c"); E(22, 187, "#f08a30"); E(21, 188, "#fff0a8"); E(22, 188, "#fbc44c"); E(21, 189, "#fbc44c"); E(20, 188, "#f08a30")
  local mg = mrect(34, 193, 43, 204); cyl(mg, ROSE); R(34, 195, 43, 195, CREAM[6]); R(35, 192, 42, 192, INK); R(36, 193, 41, 193, TIMB[2])
  local mh = mfrom(44, 195, 48, 202, function(x, y) local dd = ((x - 44) / 4) ^ 2 + ((y - 198.5) / 3.6) ^ 2; return dd <= 1 and dd > .25 end); mrim(mh); mfill(mh, ROSE[3])
  -- grain sack with a patch
  local sk = mfrom(54, 230, 86, 260, function(x, y) return ((x - 70) / 16.4) ^ 2 + ((y - 246) / 14) ^ 2 <= 1 or (y > 248 and y <= 260 and x >= 55 and x <= 85) or (y >= 228 and y < 236 and abs(x - 70) < 6) end)
  sph(sk, CREAM, { lo = 2, bias = -.04 })
  R(64, 234, 76, 235, DIRT[3]); R(64, 233, 76, 233, INK)
  R(64, 245, 72, 252, INK); R(65, 246, 71, 251, TEAL[4]); P(65, 246, TEAL[6]); P(71, 246, TEAL[6]); P(65, 251, TEAL[6]); P(71, 251, TEAL[6]); R(67, 248, 69, 249, TEAL[5])
end
-- a floor mushroom in the right-hand corner behind the loom? no: keep bottom-right plain.

---------------------------------------------------------------- light pass: cool violet corners, warm hearth
for y = 0, H - 1 do for x = 0, W - 1 do
  local k = y * W + x
  if not emis[k] then
    local a = 0
    local hd = sqrt(((x - 89) / 95) ^ 2 + ((y - 140) / 70) ^ 2)
    if y <= FL then      -- wall: straight architectural shade (under the beam, beside the end posts)
      if y < 28 then a = a + .12 end
      if x < 10 or x > 469 then a = a + .14 end
      if x > 356 and y < 28 then a = a + .06 end
    else                 -- floor: pooled light, cool violet toward the front corners
      local dd = sqrt(((x - 250) / 300) ^ 2 + ((y - 150) / 135) ^ 2)
      if dd > 1.0 then a = .2 elseif dd > .8 then a = .12 elseif dd > .6 then a = .06 end
      if hd < 1 then a = max(0, a - .1) end
    end
    if a > 0 then base[k] = mix(base[k], SHADE, a) end
    if hd < .5 and y < 158 and x > 44 and x < 136 then base[k] = mix(base[k], "#ff9c48", .1) end
  end
end end

---------------------------------------------------------------- flush + save base
for y = 0, H - 1 do for x = 0, W - 1 do c:put(x, y, base[y * W + x] or INK) end end
c:save{ aseprite = d .. "/craft-workshop.aseprite", png = d .. "/craft-workshop.png", scale = 1 }

---------------------------------------------------------------- "ready" anim layers
local anims = {}
local function layer(name, sect, fx, draw)
  buf = {}
  draw()
  local x0, y0, x1, y1 = 1e9, 1e9, -1, -1
  for k in pairs(buf) do
    local x, y = k % W, k // W
    x0 = min(x0, x); x1 = max(x1, x); y0 = min(y0, y); y1 = max(y1, y)
  end
  local w, h = x1 - x0 + 1, y1 - y0 + 1
  local a = HP.canvas{ w = w, h = h, scale = 1, name = "craft-anim-" .. name }
  for k, col in pairs(buf) do a:put(k % W - x0, k // W - y0, col) end
  a:save{ png = d .. "/craft-anim-" .. name .. ".png", scale = 1 }
  anims[#anims + 1] = string.format('{"k":"%s","for":"%s","fx":"%s","x":%d,"y":%d,"w":%d,"h":%d}', name, sect, fx, x0, y0, w, h)
  buf = base
end
local function puff(cx, cy, r)
  local m = mell(cx, cy, r, r - 1); mrim(m, "#b8a8a8")
  mfill(m, function(x, y) return (y > cy + 1) and "#e0d2c4" or "#fbf4e2" end)
end
local function bubble(cx, cy, r)
  local m = mell(cx, cy, r, r); mrim(m, "#2f8a5e")
  mfill(m, function(x, y) return (x <= cx and y <= cy) and "#f0ffe4" or ((x > cx + r - 2 or y > cy + r - 2) and "#6ad08a" or "#a8f0a0") end)
end

-- cooking: taller flames licking up round the pot (flicker) + steam puffs (bob)
layer("cooking", "cooking", "flicker", function()
  local function tongue(cx, by, w, h, seed)
    for x = cx - w, cx + w do
      local dx = (x - cx) / w
      local hx = h * (1 - dx * dx) * (.6 + .4 * sin(x * 1.3 + seed) ^ 2)
      for y = floor(by - hx), by do
        local t = (by - y) / max(1, hx); local a = abs(dx)
        local col = "#e0602c"
        if t < .35 and a < .45 then col = "#fff0a8" elseif t < .6 and a < .65 then col = "#fbc44c" elseif t < .82 and a < .85 then col = "#f08a30" end
        P(x, y, col)
      end
    end
  end
  tongue(70, 150, 5, 38, 1); tongue(108, 150, 5, 40, 3); tongue(79, 150, 5, 14, 5); tongue(99, 150, 5, 14, 6); tongue(89, 151, 8, 12, 2)
  for _, s in ipairs{ {67, 104}, {111, 102}, {74, 100}, {104, 98} } do R(s[1], s[2], s[1] + 1, s[2] + 1, "#fbc44c") end
end)
layer("cooking2", "cooking", "bob", function() puff(84, 108, 5); puff(93, 103, 4); puff(88, 99, 3) end)
-- pantry: glints on the jars (twinkle)
layer("pantry", "pantry", "twinkle", function()
  star(161, 74, "#fff8dc", true); star(204, 70, "#fff8dc"); star(176, 76, "#fff8dc"); star(160, 99, "#fff8dc"); star(205, 98, "#fff8dc", true)
  star(191, 101, "#fff8dc"); star(177, 127, "#fff8dc", true); star(190, 123, "#fff8dc"); star(218, 102, "#fff8dc"); star(213, 127, "#fff8dc")
end)
-- tools: sparks and glints at the vice and saw (twinkle) + sawdust puff and chips hopping off the bench (bob)
layer("tools", "tools", "twinkle", function()
  star(268, 107, "#fff0a8", true); star(280, 111, "#fbc44c"); star(259, 115, "#fff8dc"); star(295, 101, "#fff8dc", true); star(309, 113, "#fff0a8")
  R(274, 104, 275, 104, "#fbc44c"); R(263, 109, 264, 109, "#fbc44c")
end)
layer("tools2", "tools", "bob", function()
  puff(296, 115, 4); puff(290, 111, 2)
  R(300, 108, 302, 109, PINE[6]); P(303, 110, INK); R(285, 116, 286, 117, PINE[6]); R(306, 111, 307, 111, PINE[5])
end)
-- garden: a tall sprout with a bud nodding in the seed tray (sway) + drips from the can (bob)
layer("garden", "garden", "sway", function()
  local st = mrect(379, 92, 380, 109); mrim(st, GREEN[1]); mfill(st, GREEN[5])
  local l1 = mpoly({ {379, 103}, {374, 99}, {371, 100}, {373, 104}, {378, 106} }); mrim(l1, GREEN[1]); mfill(l1, function(x, y) return y < 102 and GREEN[6] or GREEN[4] end)
  local l2 = mpoly({ {381, 100}, {386, 95}, {389, 96}, {387, 101}, {382, 103} }); mrim(l2, GREEN[1]); mfill(l2, function(x, y) return y < 98 and GREEN[6] or GREEN[4] end)
  local bd = mell(380, 88, 4, 4); mrim(bd); mfill(bd, function(x, y) return (x < 380 and y < 88) and PINK[6] or ((x > 381 or y > 90) and PINK[4] or PINK[5]) end)
  R(379, 87, 381, 89, GOLD[5]); P(380, 88, GOLD[6])
end)
layer("garden2", "garden", "bob", function()
  for _, dp in ipairs{ {397, 107}, {393, 104}, {399, 111} } do
    R(dp[1], dp[2], dp[1] + 1, dp[2] + 2, SBLUE[5]); P(dp[1], dp[2] - 1, SBLUE[6]); P(dp[1], dp[2], "#e4f0fa"); P(dp[1] + 1, dp[2] + 3, SBLUE[3])
  end
end)
-- potions: rising bubbles (bob) + bright brew glow (pulse)
layer("potions", "potions", "bob", function()
  bubble(126, 181, 4); bubble(141, 174, 5); bubble(153, 183, 3); bubble(133, 166, 3); bubble(149, 163, 2); bubble(120, 170, 2)
end)
layer("potions2", "potions", "pulse", function()
  local m = mell(137, 192, 25, 3)
  mfill(m, function(x, y) local dd = ((x - 137) / 25) ^ 2 + ((y - 192) / 3) ^ 2; return dd < .3 and "#f4ffe0" or (dd < .7 and "#c8fcb4" or "#96ec9c") end)
  for i = 0, 8 do
    local a = math.pi * (1.08 + i * .105)
    local x, y = floor(137 + cos(a) * 34 + .5), floor(190 + sin(a) * 13 + .5)
    R(x, y, x + 1, y + 1, i % 2 == 0 and "#c8fcb4" or "#96ec9c")
  end
  star(110, 186, "#e4ffd8"); star(164, 185, "#e4ffd8")
end)
-- building: dust puffs + chips over the pile (bob) + glints on stone and trowel (twinkle)
layer("building", "building", "bob", function()
  puff(254, 209, 5); puff(262, 204, 3); puff(306, 206, 4); puff(314, 201, 3)
  R(246, 203, 248, 204, PINE[5]); R(300, 198, 302, 199, PINE[6]); R(270, 196, 271, 197, PINE[6]); P(247, 205, INK); P(301, 200, INK)
end)
layer("building2", "building", "twinkle", function()
  star(245, 221, "#fff8dc", true); star(303, 222, "#fff8dc"); star(240, 235, "#fff8dc"); star(318, 233, "#fff0a8"); star(277, 205, "#fff8dc")
end)
-- decor: the shuttle sliding along the fell (drift) + sparkles on the cloth and yarn (twinkle)
layer("decor", "decor", "drift", function()
  local sh = mpoly({ {367, 205}, {370, 203}, {380, 203}, {383, 205}, {380, 207}, {370, 207} }); mrim(sh)
  mfill(sh, function(x, y) return y <= 204 and PINE[6] or (y >= 207 and PINE[3] or PINE[5]) end)
  R(371, 205, 379, 205, BARN[4]); R(372, 204, 378, 204, BARN[5])
end)
layer("decor2", "decor", "twinkle", function()
  star(362, 212, "#fff8dc"); star(388, 214, "#fff8dc", true); star(421, 204, "#fff8dc"); star(377, 211, "#fff0a8"); star(366, 177, "#fff8dc")
end)

---------------------------------------------------------------- layout.json
local spots = {
  { "cooking", "Cooking", 89, 112, 42, 54, 136, 165 },
  { "pantry", "Pantry", 190, 103, 149, 57, 231, 149 },
  { "tools", "Tools", 300, 126, 255, 93, 345, 159 },
  { "garden", "Garden", 399, 112, 357, 65, 441, 158 },
  { "potions", "Potions", 141, 212, 93, 172, 190, 248 },
  { "building", "Building", 284, 225, 237, 199, 331, 249 },
  { "decor", "Decor", 387, 200, 343, 171, 432, 229 },
}
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], s[3], s[4], s[5], s[6], s[7], s[8])
end
local f = io.open(d .. "/layout.json", "w")
f:write('{"w":480,"h":270,\n "spots":[\n  ' .. table.concat(parts, ",\n  ") .. '\n ],\n "anim":[\n  ' .. table.concat(anims, ",\n  ") .. '\n ]}\n')
f:close()

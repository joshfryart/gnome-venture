-- Olivewhistle Shore: gate view (Hearth Pop v3), 480x270 native.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local NAME = "here-town-olivewhistle"
local W, H = 480, 270
local VPX, VPY = 240, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, max, min, abs, sin, cos = math.floor, math.max, math.min, math.abs, math.sin, math.cos

local function hsh(x, y, s)
  local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function P(x, y, h) x = floor(x); y = floor(y); if h and x >= 0 and x < W and y >= 0 and y < H then c:px(x, y, h) end end
local function R(x0, y0, x1, y1, h) for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do P(x, y, h) end end end
local function RF(x0, y0, x1, y1, f) for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do P(x, y, f(x, y)) end end end
local function MF(m, f) m:each(function(x, y) P(x, y, f(x, y)) end) end
local function poly(pts) local q = {} for i, p in ipairs(pts) do q[i] = { floor(p[1] + 0.5), floor(p[2] + 0.5) } end return c:poly(q) end
local function edge(m, h) m:edge():each(function(x, y) P(x, y, h) end) end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function hex(r, g, b)
  r = max(1, min(254, floor(r + 0.5))); g = max(1, min(254, floor(g + 0.5))); b = max(1, min(254, floor(b + 0.5)))
  return string.format("#%02x%02x%02x", r, g, b)
end
-- cool-violet shade over whatever is there
local function shade(x, y, k)
  if x < 0 or y < 0 or x >= W or y >= H then return end
  local h = c:get(x, y); if not h or #h < 7 then return end
  local r, g, b = rgb(h)
  k = k or 0.78
  P(x, y, hex(r * k * 0.92 + 12, g * k * 0.86 + 8, b * k + 26))
end
-- warm glow over whatever is there
local function glow(x, y, k)
  if x < 0 or y < 0 or x >= W or y >= H then return end
  local h = c:get(x, y); if not h or #h < 7 then return end
  local r, g, b = rgb(h)
  P(x, y, hex(r + (255 - r) * k, g + (230 - g) * k * 0.8, b + (140 - b) * k * 0.5))
end

-- ramps: hi, base, mid, shade, deep
local INK   = "#2b1c26"
local WASH  = { "#fcf6e8", "#f0e6d2", "#e0d3c6", "#c3b4c6", "#8e7c9c" }
local TERRA = { "#f29a66", "#dd7748", "#c25e3a", "#9a4433", "#6e2e2e" }
local BLUE  = { "#7fb4e6", "#4f8ccc", "#3a6fb0", "#2b5190", "#1e3466" }
local OCHRE = { "#f8d896", "#ecbf6c", "#d6a256", "#b07c4a", "#7d5240" }
local CORAL = { "#fcd0ba", "#f4ac92", "#de8e7c", "#b87076", "#80485a" }
local HONEY = { "#f3dca2", "#e2c283", "#cba36a", "#a68062", "#6f5248" }
local WOOD  = { "#d4a674", "#ad7c50", "#8a5e3e", "#6a4434", "#4a2e2a" }
local OLV   = { "#c4cf8a", "#a2b064", "#7f9149", "#5c6e3e", "#3d4a30" }
local LEAF  = { "#b4d872", "#86b84e", "#5f9440", "#427038", "#2c4a2e" }
local LEMON = { "#fff3a6", "#f9da48", "#e8b830", "#b98428" }
local BOUG  = { "#f896cc", "#e4529e", "#c13a86", "#8a2a6a" }
local TEAL  = { "#94dfd2", "#4cb6aa", "#30908c", "#23686c", "#1a4450" }
local BRASS = { "#ffe8a6", "#f2c25a", "#cc9236", "#8f5f2e" }
local STONE = { "#e2d9cc", "#c9bdb0", "#ada09a", "#8b7d84", "#5f5464" }
local CORK  = { "#e2aa6e", "#c88c56", "#a86c44", "#7f4e38", "#56342e" }
local GLASS = { "#8d8ab0", "#4a4468", "#352f50", "#28223e" }
local WARM  = { "#fff4c4", "#ffe08a", "#f7bd5a", "#d98c3e" }

------------------------------------------------------------------ sky
c:stripes(0, 87, { "#4c97d4", "#5fa6da", "#74b5df", "#8cc4e2", "#a6d1e2", "#c2dedc", "#dfe6cc", "#f6e5b2" },
  { 10, 10, 11, 11, 11, 11, 11, 12 })
c:cloud(26, 50, 58, "#fdf4e2", "#e9d2c6")
c:cloud(132, 30, 82, "#fdf4e2", "#e9d2c6")
c:cloud(262, 44, 64, "#fdf4e2", "#e9d2c6")
c:cloud(330, 26, 70, "#fdf4e2", "#e9d2c6")
c:cloud(196, 70, 40, "#fdf2dc", "#efd8c4")
-- warm sun haze in the upper left
for y = 0, 60 do for x = 0, 130 do
  local d = (x / 130) ^ 2 + (y / 60) ^ 2
  if d < 1 and hsh(x, y, 1) > d * 0.9 + 0.35 then glow(x, y, 0.12) end
end end

------------------------------------------------------------------ far headlands
local function hillL(x) return 56 + (x / 190) ^ 1.4 * 32 + 3 * sin(x / 9) + 2 * sin(x / 23) end
local function hillR(x) return 88 - ((x - 286) / 194) ^ 0.75 * 34 + 2 * sin(x / 8) + 2 * sin(x / 19) end
local farL = c:terrain(function(x) return floor(hillL(x) - 6) end, "#a9bdb0", 88, 0, 150)
local farR = c:terrain(function(x) return floor(hillR(x) - 8) end, "#a9bdb0", 88, 330, 479)
local nearL = c:terrain(function(x) return floor(hillL(x)) end, "#8fae86", 88, 0, 186)
local nearR = c:terrain(function(x) return floor(hillR(x)) end, "#8fae86", 88, 286, 479)
-- sun-lit tops and olive-grove dots, tiny white houses
for _, m in ipairs({ nearL, nearR }) do
  m:each(function(x, y)
    if not m:has(x, y - 1) then P(x, y, "#b5c99a") end
    if (y % 4 == 1) and ((x + y) % 7 == 0) and m:has(x, y - 2) then P(x, y, "#5f7d58"); P(x + 1, y, "#5f7d58"); P(x, y - 1, "#7a9a6a") end
  end)
end
local function cube(x, y)
  R(x, y, x + 5, y + 3, WASH[1]); R(x + 4, y, x + 5, y + 3, WASH[3]); R(x - 1, y - 1, x + 6, y - 1, TERRA[2])
  P(x + 2, y + 2, BLUE[3])
end
for _, p in ipairs({ { 126, 72 }, { 140, 76 }, { 156, 79 }, { 132, 80 }, { 168, 82 }, { 18, 62 }, { 26, 66 } }) do cube(p[1], p[2]) end
for _, p in ipairs({ { 304, 82 }, { 316, 78 }, { 440, 62 }, { 452, 60 }, { 344, 76 } }) do cube(p[1], p[2]) end
-- lighthouse on the right headland
do
  local lx = 326
  for y = 56, 80 do
    local hw = 2 + floor((y - 56) / 10)
    for x = lx - hw, lx + hw do
      local band = floor((y - 56) / 5) % 2 == 1
      local t = band and TERRA[2] or WASH[1]
      if x >= lx + hw - 1 then t = band and TERRA[4] or WASH[3] end
      P(x, y, t)
    end
  end
  R(lx - 3, 52, lx + 3, 55, WARM[2]); P(lx - 2, 53, WARM[1]); R(lx - 4, 51, lx + 4, 51, TERRA[4]); R(lx - 2, 50, lx + 2, 50, TERRA[3])
end

------------------------------------------------------------------ sea
RF(0, 88, W - 1, 113, function(x, y)
  local t
  if y < 92 then t = "#86c7dc" elseif y < 98 then t = "#5cb0d6" elseif y < 106 then t = "#45a0cf" else t = "#3a8fc4" end
  local hv = hsh(floor(x / 3), y, 4)
  if hv > 0.93 then t = "#d4eff0" elseif hv > 0.86 then t = "#7cc3de" end
  -- golden sun path
  if x < 200 and y > 92 and hsh(floor(x / 2), y, 6) > 0.8 then t = "#f2e2a8" end
  return t
end)
-- little fishing boats with lateen sails out at sea
local function farBoat(x, y, col)
  R(x, y, x + 10, y + 1, col); R(x + 1, y + 2, x + 9, y + 2, "#2f5f86")
  for i = 0, 7 do R(x + 4, y - 1 - i, x + 4 + floor(i * 0.7), y - 1 - i, WASH[1]) end
  P(x + 3, y - 1, WOOD[4])
end
farBoat(336, 100, TERRA[2]); farBoat(178, 96, BLUE[2]); farBoat(300, 94, LEMON[3])

------------------------------------------------------------------ sea wall (far quay)
RF(0, 114, W - 1, 121, function(x, y)
  if y == 114 then return WASH[1] end
  if y == 115 then return WASH[3] end
  if y == 118 then return ((x // 3) % 2 == 0) and BLUE[2] or LEMON[2] end
  if y == 121 then return WASH[4] end
  local t = WASH[2]; if hsh(x, y, 8) > 0.9 then t = WASH[3] end
  if x % 22 == 0 then t = WASH[4] end
  return t
end)

------------------------------------------------------------------ paving (one-point perspective)
local PAVE = { "#f2e3c2", "#ead6b0", "#e0caa2", "#d5bc94" }
local JOINT = "#b99e7c"
do
  local rowOf, rowTop = {}, {}
  local y, h, r = 122, 2.0, 0
  while y < H do
    local y0, y1 = floor(y), floor(y + h) - 1
    for yy = y0, max(y0, y1) do rowOf[yy] = r end
    rowTop[y0] = true
    y = y + h; h = h * 1.16 + 0.3; r = r + 1
  end
  for yy = 122, H - 1 do
    local d = yy - VPY
    local cw = 24 * d / 158
    local rr = rowOf[yy] or 0
    for x = 0, W - 1 do
      local u = (x - VPX) / d * 158 / 24 + (rr % 2) * 0.5
      local col = floor(u)
      local fr = (u - col) * cw
      local t
      if rowTop[yy] or fr < 1 then t = JOINT
      else
        local hv = hsh(col, rr, 3)
        t = PAVE[1 + floor(hv * 4)]
        if fr < 2.2 or rowTop[yy - 1] then t = "#f6eacc" end
        if rowTop[yy + 1] then t = "#cdb38c" end
        local s = hsh(x, yy, 9)
        if s > 0.965 then t = "#c4a884" elseif s < 0.02 then t = "#f8eed6" end
      end
      P(x, yy, t)
    end
  end
  -- worn central path: bigger lighter flags toward the green
  for yy = 184, H - 1 do
    local d = yy - VPY
    local xl, xr = VPX - 60 * d / 158, VPX + 60 * d / 158
    for x = floor(xl), floor(xr) do
      local hv = hsh(x, yy, 12)
      if hv > 0.9 then glow(x, yy, 0.18) end
    end
  end
end

local SH = "#b8a3ae"
local function castShadow(pts, k)
  local m = poly(pts)
  m:each(function(x, y) shade(x, y, k or 0.84) end)
end
local function contact(x0, x1, y) for x = x0, x1 do shade(x, y, 0.7); shade(x, y + 1, 0.82) end end

------------------------------------------------------------------ texture helpers
local function stucco(r, x, y, x0, x1, seed)
  local cl = hsh(floor(x / 3), floor(y / 2), seed)
  local t = r[2]
  if cl > 0.86 then t = r[1] elseif cl < 0.1 then t = r[3] end
  local hv = hsh(x, y, seed + 1)
  if hv > 0.96 then t = r[3] elseif hv < 0.025 then t = r[1] end
  if x <= x0 + 1 then t = r[1] end
  if x >= x1 - 1 then t = r[3] end
  return t
end
local function stonePatch(x0, y0, w, h, seed, mortar)
  for y = y0, y0 + h - 1 do
    local course = floor((y - y0) / 3)
    for x = x0, x0 + w - 1 do
      local ex = min(x - x0, x0 + w - 1 - x); local ey = min(y - y0, y0 + h - 1 - y)
      if ex + ey >= 1 + floor(hsh(x, y, seed) * 2) then
        local off = (course % 2) * 3
        local bx = (x - x0 + off) % 6
        local by = (y - y0) % 3
        local t = STONE[2]
        if hsh(floor((x - x0 + off) / 6), course, seed) > 0.5 then t = STONE[1] end
        if by == 2 then t = STONE[4] elseif bx == 5 then t = STONE[3] end
        if by == 0 and bx == 0 then t = STONE[1] end
        P(x, y, t)
      end
    end
  end
end
local function tiles(m, r, ytop, xc, seed)
  m:each(function(x, y)
    local row = floor((y - ytop) / 3)
    local o = (x + (row % 2) * 2) % 4
    local t = r[2]
    if o == 0 then t = r[1] elseif o == 3 then t = r[3] end
    if (y - ytop) % 3 == 2 then t = r[4] end
    if x > xc + 6 and o ~= 0 then t = (t == r[2]) and r[3] or t end
    if hsh(floor((x + (row % 2) * 2) / 4), row, seed) > 0.93 and (y - ytop) % 3 ~= 2 then t = r[3] end
    if not m:has(x, y + 1) then t = r[5] end
    if not m:has(x, y - 1) then t = r[1] end
    P(x, y, t)
  end)
  edge(m, r[5])
end

local function window(x, y, w, h, o)
  o = o or {}
  local fr = o.frame or WASH[5]
  R(x - 1, y - 1, x + w, y + h, fr)
  RF(x, y, x + w - 1, y + h - 1, function(px, py)
    if o.inner then return o.inner(px, py) end
    if o.lit then
      if py - y < 1 then return WARM[4] end
      return ((px + py) % 5 == 0) and WARM[1] or WARM[2]
    end
    local d = (px - x) - (py - y)
    if d >= 1 and d < 3 then return GLASS[1] end
    if py - y < 2 then return GLASS[4] end
    return GLASS[3]
  end)
  if w >= 8 and not o.nomull then
    R(x + floor(w / 2), y, x + floor(w / 2), y + h - 1, fr)
    R(x, y + floor(h / 2), x + w - 1, y + floor(h / 2), fr)
  end
  if o.shut then
    local sw = max(3, floor(w / 2))
    for s = 0, 1 do
      local sx = (s == 0) and (x - 1 - sw) or (x + w + 1)
      local m = c:rect(sx, y - 1, sx + sw - 1, y + h)
      MF(m, function(px, py)
        if (py - y) % 2 == 1 then return o.shut[3] end
        if px == sx then return o.shut[1] end
        return o.shut[2]
      end)
      edge(m, o.shut[5])
    end
  end
  R(x - 2, y + h + 1, x + w + 1, y + h + 1, WASH[1]); R(x - 2, y + h + 2, x + w + 1, y + h + 2, WASH[4])
  if o.flowers then
    R(x - 1, y + h + 3, x + w, y + h + 5, TERRA[3]); R(x - 1, y + h + 5, x + w, y + h + 5, TERRA[5])
    for i = x - 1, x + w do
      local v = hsh(i, y, 31)
      if v > 0.35 then P(i, y + h, (v > 0.7) and o.flowers[1] or o.flowers[2]) end
      if v > 0.6 then P(i, y + h - 1, o.flowers[2]) end
      if v < 0.3 then P(i, y + h, LEAF[3]) end
    end
  end
end

local function door(x, y, w, h, r, o)
  o = o or {}
  local m = c:rect(x, y, x + w - 1, y + h - 1)
  m:cut(c:rect(x, y, x, y + 1)); m:cut(c:rect(x + w - 1, y, x + w - 1, y + 1)); m:cut(c:rect(x + 1, y, x + 1, y)); m:cut(c:rect(x + w - 2, y, x + w - 2, y))
  MF(m, function(px, py)
    local t = r[2]
    if (px - x) % 4 == 3 then t = r[3] end
    if px == x + 1 then t = r[1] end
    if px >= x + w - 2 then t = r[4] end
    if (py - y) == floor(h * 0.3) or (py - y) == floor(h * 0.75) then t = r[4] end
    return t
  end)
  edge(m, r[5])
  P(x + w - 4, y + floor(h * 0.55), BRASS[2]); P(x + w - 4, y + floor(h * 0.55) + 1, BRASS[4])
  R(x - 2, y - 2, x + w + 1, y - 2, WASH[1]); R(x - 2, y - 1, x + w + 1, y - 1, WASH[4])
  R(x - 2, y + h, x + w + 1, y + h, STONE[3])
end

local function canopy(cx, cy, rx, ry, ramp, seed, lumps)
  local m = c:ellipse(cx, cy, rx, ry)
  for i = 1, lumps do
    local a = i / lumps * math.pi * 2 + seed
    local lx = cx + cos(a) * rx * 0.78
    local ly = cy + sin(a) * ry * 0.72
    local lr = rx * 0.34 + hsh(i, seed, 1) * rx * 0.14
    m:add(c:ellipse(floor(lx), floor(ly), floor(lr), floor(lr * 0.8)))
  end
  MF(m, function(x, y)
    local nx = (x - cx) / rx; local ny = (y - cy) / ry
    local v = -0.55 * nx - 0.75 * ny
    local cl = hsh(floor(x / 4) + (floor(y / 3) % 2) * 7, floor(y / 3), seed)
    v = v + (cl - 0.5) * 0.7
    local lx, ly = x % 4, y % 3
    if ly == 0 and lx <= 1 then v = v + 0.3 end
    if ly == 2 then v = v - 0.25 end
    if v > 0.7 then return ramp[1] elseif v > 0.12 then return ramp[2] elseif v > -0.4 then return ramp[3] elseif v > -0.85 then return ramp[4] end
    return ramp[5]
  end)
  edge(m, ramp[5])
  return m
end
local function lemon(x, y, big)
  if big then
    local m = c:ellipse(x, y, 5, 6); m:add(c:rect(x, y - 8, x, y - 6)); m:add(c:rect(x, y + 6, x, y + 7))
    MF(m, function(px, py)
      local v = -(px - x) * 0.6 - (py - y) * 0.5
      if v > 2.5 then return LEMON[1] elseif v > -1.5 then return LEMON[2] elseif v > -4 then return LEMON[3] end
      return LEMON[4]
    end)
    edge(m, LEMON[4]); P(x - 2, y - 3, LEMON[1]); P(x - 3, y - 2, LEMON[1])
    -- leaf on top
    P(x + 1, y - 8, LEAF[2]); P(x + 2, y - 9, LEAF[2]); P(x + 3, y - 9, LEAF[3])
    return
  end
  P(x, y, LEMON[2]); P(x + 1, y, LEMON[2]); P(x - 1, y + 1, LEMON[2]); P(x, y + 1, LEMON[1]); P(x + 1, y + 1, LEMON[2]); P(x + 2, y + 1, LEMON[3])
  P(x, y + 2, LEMON[3]); P(x + 1, y + 2, LEMON[4]); P(x - 1, y, LEMON[4] == nil and nil or nil)
end

-- generic house: front wall + side wall receding to the VP + terracotta hip roof
local function house(o)
  local wm = c:rect(o.x0, o.yt, o.x1, o.yb)
  if o.side then
    local xe = (o.side == "r") and o.x1 or o.x0
    local dir = (o.side == "r") and 1 or -1
    local t = o.sw / abs(VPX - xe)
    local ytop2 = o.yt + (VPY - o.yt) * t
    local ybot2 = o.yb + (VPY - o.yb) * t
    local xs = xe + dir * o.sw
    local sm = poly{ { xe, o.yt }, { xs, ytop2 }, { xs, ybot2 }, { xe, o.yb } }
    MF(sm, function(x, y) local hv = hsh(floor(x / 2), floor(y / 2), o.seed + 5); if hv > 0.88 then return o.wall[5] end; if hv < 0.15 then return o.wall[3] end return o.wall[4] end)
    edge(sm, o.wall[5])
    -- side roof
    local rh = o.rh
    local rs = poly{ { xe, o.yt + 1 }, { xs + dir * 2, ytop2 + 1 }, { xs + dir * 1, ytop2 - rh * 0.55 }, { xe - dir * rh * 0.6, o.yt - rh } }
    MF(rs, function(x, y) local row = floor((y - o.yt) / 3); return ((x + row) % 4 == 0) and o.roof[5] or o.roof[4] end)
    edge(rs, o.roof[5])
  end
  MF(wm, function(x, y) return stucco(o.wall, x, y, o.x0, o.x1, o.seed) end)
  for _, p in ipairs(o.patches or {}) do stonePatch(p[1], p[2], p[3], p[4], o.seed + 3) end
  for y = o.yt, o.yt + 2 do for x = o.x0, o.x1 do shade(x, y, 0.82) end end
  edge(wm, o.wall[5])
  local ov = 4
  local rm = poly{ { o.x0 - ov, o.yt + 1 }, { o.x1 + ov, o.yt + 1 }, { o.x1 - o.rh * 0.6, o.yt - o.rh }, { o.x0 + o.rh * 0.6, o.yt - o.rh } }
  tiles(rm, o.roof, o.yt - o.rh, (o.x0 + o.x1) / 2, o.seed)
  -- ridge caps
  for x = floor(o.x0 + o.rh * 0.6), floor(o.x1 - o.rh * 0.6), 4 do R(x, o.yt - o.rh - 1, x + 2, o.yt - o.rh - 1, o.roof[3]); P(x, o.yt - o.rh - 1, o.roof[1]) end
  return wm, rm
end

local function boug(x0, y0, x1, y1, seed, dens)
  for y = y0, y1 do for x = x0, x1 do
    local v = hsh(x, y, seed)
    local cl = hsh(floor(x / 3), floor(y / 3), seed + 1)
    if cl > (dens or 0.45) then
      if v > 0.55 then P(x, y, BOUG[2]) elseif v > 0.3 then P(x, y, BOUG[3]) elseif v > 0.18 then P(x, y, BOUG[1]) else P(x, y, LEAF[4]) end
    end
  end end
end

------------------------------------------------------------------ LIBRARY (far left) box [36,36,124,126]
do
  castShadow({ { 112, 124 }, { 140, 124 }, { 136, 132 }, { 112, 128 } }, 0.86)
  house{ x0 = 40, x1 = 110, yt = 72, yb = 124, rh = 16, side = "r", sw = 12, wall = OCHRE, roof = TERRA, seed = 11,
    patches = { { 44, 108, 10, 9 }, { 96, 78, 9, 7 } } }
  contact(40, 122, 125)
  -- upper windows: shelves of books
  local function books(px, py) local k = floor(px / 2); local cols = { "#c0404e", BLUE[3], LEAF[3], LEMON[3], TEAL[3], CORAL[3] }
    if (py % 6) == 5 then return WOOD[4] end
    if (py % 6) == 0 then return "#3a2a30" end
    local t = cols[1 + floor(hsh(k, floor(py / 6), 2) * 6)]
    if px % 2 == 1 then return "#3a2a30" == t and t or t end
    return t
  end
  window(48, 80, 12, 14, { shut = BLUE, inner = books, nomull = true })
  window(90, 80, 12, 14, { shut = BLUE, inner = books, nomull = true })
  window(69, 80, 12, 12, { shut = BLUE, flowers = BOUG })
  -- big ground floor book window + door
  window(46, 102, 16, 14, { inner = books, nomull = true, frame = OCHRE[5] })
  door(68, 100, 14, 24, LEAF, {})
  window(88, 102, 16, 14, { lit = true, frame = OCHRE[5] })
  -- step
  R(66, 124, 84, 125, STONE[2]); R(66, 125, 84, 125, STONE[4])
  -- BIG OPEN BOOK sign standing on the roof
  local bx, by = 75, 48
  local cover = c:poly{ { bx - 22, by - 6 }, { bx, by - 1 }, { bx + 22, by - 6 }, { bx + 22, by + 8 }, { bx, by + 12 }, { bx - 22, by + 8 } }
  c:fillMask(cover, "#b03a48"); edge(cover, "#6e1e34")
  local lp = poly{ { bx - 20, by - 7 }, { bx - 1, by - 2 }, { bx - 1, by + 9 }, { bx - 20, by + 5 } }
  local rp = poly{ { bx + 1, by - 2 }, { bx + 20, by - 7 }, { bx + 20, by + 5 }, { bx + 1, by + 9 } }
  MF(lp, function(x, y) return ((y - floor((x - bx) * -0.25)) % 3 == 0 and x > bx - 18 and x < bx - 3) and WASH[4] or WASH[1] end)
  MF(rp, function(x, y) return ((y - floor((x - bx) * 0.25)) % 3 == 0 and x < bx + 18 and x > bx + 3) and WASH[4] or WASH[2] end)
  edge(lp, WASH[5]); edge(rp, WASH[5])
  R(bx, by - 2, bx, by + 11, "#6e1e34")
  R(bx + 6, by + 9, bx + 7, by + 16, BLUE[2]); P(bx + 6, by + 17, BLUE[3]); P(bx + 7, by + 17, BLUE[4]) -- ribbon
  R(bx - 2, by + 12, bx + 2, by + 14, WOOD[3]); R(bx - 8, by + 13, bx - 7, by + 16, WOOD[4]); R(bx + 7, by + 13, bx + 8, by + 15, WOOD[4])
  -- bougainvillea climbing the left corner
  boug(36, 70, 46, 120, 41, 0.42)
end

------------------------------------------------------------------ GRANDMOTHER OLIVE (quirk: knitted shawl + slippers)
do
  castShadow({ { 140, 142 }, { 172, 142 }, { 176, 148 }, { 146, 148 } }, 0.84)
  -- gnarled twisted trunk
  local tr = poly{ { 134, 143 }, { 158, 143 }, { 154, 136 }, { 156, 124 }, { 162, 112 }, { 158, 110 }, { 150, 120 }, { 146, 112 }, { 140, 110 }, { 143, 124 }, { 138, 136 } }
  MF(tr, function(x, y)
    local v = sin((x + y * 0.6) / 2.2) + (hsh(x, y, 17) - 0.5)
    if x < 144 and v > 0.3 then return "#b6a48c" end
    if v > 0.6 then return "#9c8a76" elseif v > -0.6 then return "#7f6d60" end
    return "#5c4c4c"
  end)
  edge(tr, "#3f3238")
  R(148, 130, 150, 133, "#3f3238"); P(149, 131, "#2f2430") -- hollow
  canopy(148, 102, 22, 11, OLV, 3, 7)
  canopy(134, 108, 10, 6, OLV, 5, 4)
  canopy(162, 108, 10, 6, OLV, 9, 4)
  -- tiny black olives
  for k = 1, 14 do local x = 130 + floor(hsh(k, 1, 4) * 36); local y = 98 + floor(hsh(k, 2, 4) * 14); P(x, y, "#4a3a52"); P(x, y + 1, "#2f2a3e") end
  -- knitted shawl wrapped around the trunk
  local sh = poly{ { 136, 124 }, { 158, 122 }, { 157, 128 }, { 152, 136 }, { 146, 138 }, { 140, 130 } }
  MF(sh, function(x, y)
    local zig = (x + (y % 2)) % 4
    local t = (floor(y / 2) % 2 == 0) and BOUG[1] or BOUG[2]
    if zig == 0 then t = BOUG[3] end
    if x > 152 then t = BOUG[3] end
    return t
  end)
  edge(sh, BOUG[4])
  for x = 142, 152, 2 do P(x, 139 - floor((x - 142) / 4), BOUG[2]); P(x, 140 - floor((x - 142) / 4), BOUG[3]) end
  -- slippers at the roots
  R(136, 145, 141, 146, BLUE[2]); R(136, 145, 137, 145, BLUE[1]); R(141, 146, 141, 146, BLUE[4]); R(142, 145, 142, 146, BLUE[5])
  R(144, 146, 149, 147, BLUE[2]); R(144, 146, 145, 146, BLUE[1]); R(150, 146, 150, 147, BLUE[5])
end

------------------------------------------------------------------ TEAHOUSE: Cafe Cicada (far right) box [348,40,438,126]
do
  castShadow({ { 362, 124 }, { 438, 124 }, { 446, 130 }, { 368, 130 } }, 0.86)
  house{ x0 = 364, x1 = 432, yt = 72, yb = 124, rh = 14, side = "l", sw = 12, wall = CORAL, roof = TERRA, seed = 23,
    patches = { { 410, 78, 10, 7 } } }
  contact(352, 432, 125)
  window(372, 78, 12, 12, { shut = TEAL, flowers = BOUG })
  window(412, 78, 12, 12, { shut = TEAL, flowers = BOUG })
  door(392, 100, 14, 24, TEAL, {})
  window(372, 104, 12, 12, { lit = true, frame = CORAL[5] })
  window(414, 104, 12, 12, { lit = true, frame = CORAL[5] })
  -- teal striped awning
  local aw = poly{ { 366, 94 }, { 430, 94 }, { 434, 101 }, { 362, 101 } }
  MF(aw, function(x, y) local s = floor((x - 362) / 5) % 2 == 0; if y >= 100 then return s and TEAL[4] or WASH[4] end; return s and TEAL[2] or WASH[1] end)
  edge(aw, TEAL[5])
  for x = 362, 434, 5 do P(x + 2, 102, TEAL[3]); P(x + 1, 102, TEAL[4]) end
  -- tiny cafe tables
  for _, tx in ipairs({ 376, 416 }) do
    R(tx - 4, 116, tx + 4, 117, WASH[1]); R(tx - 4, 117, tx + 4, 117, WASH[4]); R(tx, 118, tx, 123, WOOD[4]); R(tx - 2, 123, tx + 2, 123, WOOD[5])
    P(tx - 1, 115, WASH[1]); P(tx, 115, WASH[2]); P(tx - 1, 114, "#6a3a2a") -- tiny espresso
    R(tx - 7, 118, tx - 6, 123, BLUE[3]); R(tx + 6, 118, tx + 7, 123, BLUE[3])
  end
  -- CUP SIGN on a bracket over the roof
  local sx, sy = 398, 50
  R(sx - 1, sy + 8, sx, 58, WOOD[4])
  local cup = poly{ { sx - 9, sy - 6 }, { sx + 7, sy - 6 }, { sx + 5, sy + 4 }, { sx - 7, sy + 4 } }
  MF(cup, function(x, y) if x < sx - 5 then return WASH[1] end; if x > sx + 2 then return WASH[3] end; return WASH[2] end)
  edge(cup, WASH[5])
  R(sx - 8, sy - 6, sx + 6, sy - 5, "#6a3a2a"); R(sx - 7, sy - 6, sx - 4, sy - 6, "#9a5a3a")
  local hd = poly{ { sx + 7, sy - 4 }, { sx + 11, sy - 4 }, { sx + 11, sy + 1 }, { sx + 6, sy + 1 } }
  edge(hd, WASH[5]); P(sx + 8, sy - 3, WASH[1])
  local sauce = poly{ { sx - 13, sy + 5 }, { sx + 11, sy + 5 }, { sx + 8, sy + 8 }, { sx - 10, sy + 8 } }
  MF(sauce, function(x, y) return (y == sy + 5) and WASH[1] or TEAL[2] end); edge(sauce, TEAL[5])
  for i = 0, 6 do P(sx - 4 + (i % 2), sy - 8 - i, WASH[1]); P(sx + 1 - (i % 2), sy - 9 - i, WASH[2]) end -- steam
  -- QUIRK: moka-pot chimney puffing steam
  local mx = 422
  local mb = poly{ { mx - 5, 62 }, { mx + 5, 62 }, { mx + 4, 54 }, { mx - 4, 54 } }
  local mt = poly{ { mx - 4, 53 }, { mx + 4, 53 }, { mx + 3, 46 }, { mx - 3, 46 } }
  for _, m in ipairs({ mb, mt }) do MF(m, function(x, y) if x < mx - 1 then return STONE[1] elseif x < mx + 2 then return STONE[2] end return STONE[4] end); edge(m, STONE[5]) end
  R(mx - 1, 44, mx + 1, 45, INK); R(mx + 4, 48, mx + 6, 49, STONE[4]); R(mx + 6, 48, mx + 6, 52, STONE[5])
  for i = 0, 8 do local y = 42 - i * 2; P(mx + (i % 3) - 1, y, WASH[1]); P(mx + (i % 3), y - 1, "#e4dce8") end
end

------------------------------------------------------------------ THE LEMON GROVE (green) box [176,92,304,182]
do
  castShadow({ { 300, 168 }, { 304, 182 }, { 314, 186 }, { 310, 170 } }, 0.84)
  -- planter top face (trapezoid in perspective)
  local top = poly{ { 190, 148 }, { 290, 148 }, { 300, 168 }, { 180, 168 } }
  MF(top, function(x, y)
    local v = hsh(floor(x / 2), floor(y / 2), 51)
    if v > 0.82 then return "#c9e07e" elseif v > 0.45 then return "#9cc05a" elseif v > 0.15 then return "#86ab4c" end
    return "#6e9244"
  end)
  -- coping
  local cop = poly{ { 188, 146 }, { 292, 146 }, { 292, 147 }, { 188, 147 } }
  c:fillMask(cop, HONEY[1])
  for y = 147, 168 do local t = (y - 148) / 20; P(floor(190 - 10 * t), y, HONEY[2]); P(floor(189 - 10 * t), y, HONEY[4]); P(floor(290 + 10 * t), y, HONEY[3]); P(floor(291 + 10 * t), y, HONEY[5]) end
  R(178, 168, 302, 169, HONEY[1]); R(178, 170, 302, 170, HONEY[3])
  -- front face: whitewash + blue/yellow tile band
  RF(178, 171, 302, 182, function(x, y)
    if y >= 174 and y <= 179 then
      local tx, ty = (x - 178) % 6, y - 174
      local dm = abs(tx - 2.5) + abs(ty - 2.5)
      if tx == 5 or ty == 5 then return WASH[4] end
      if dm < 1.6 then return LEMON[2] end
      if dm < 3 then return BLUE[2] end
      return WASH[1]
    end
    if y == 182 then return WASH[5] end
    if y == 181 then return WASH[4] end
    return stucco(WASH, x, y, 178, 302, 61)
  end)
  edge(c:rect(178, 168, 302, 182), WASH[5])
  -- three lemon trees
  local trees = { { 210, 160, 22, 18, 116, 7 }, { 240, 154, 28, 22, 116, 9 }, { 271, 160, 22, 18, 118, 7 } }
  for i, t in ipairs(trees) do
    local tx, ty = t[1], t[2]
    for y = ty - 22, ty do
      local hw = (y > ty - 5) and 3 or 2
      for x = tx - hw, tx + hw - 1 do P(x, y, (x < tx - hw + 2) and WOOD[2] or ((x >= tx + hw - 2) and WOOD[4] or WOOD[3])) end
      P(tx - hw - 1, y, WOOD[5]); P(tx + hw, y, WOOD[5])
    end
    R(tx - 7, ty + 1, tx + 7, ty + 2, "#5d7a3c")
  end
  canopy(210, 122, 22, 17, LEAF, 1, 6)
  canopy(271, 124, 22, 17, LEAF, 4, 6)
  canopy(240, 116, 28, 20, LEAF, 2, 7)
  local function lemons(cx, cy, rx, ry, n, s)
    for k = 1, n do
      local x = floor(cx + (hsh(k, s, 2) - 0.5) * rx * 1.5); local y = floor(cy + (hsh(k, s, 3) - 0.5) * ry * 1.4)
      lemon(x, y)
    end
  end
  lemons(210, 122, 22, 17, 9, 1); lemons(271, 124, 22, 17, 9, 2); lemons(240, 116, 28, 20, 12, 3)
  -- QUIRK: one giant lemon propped on a wooden crutch
  lemon(252, 136, true)
  R(252, 144, 253, 160, WOOD[3]); P(251, 144, WOOD[4]); P(254, 144, WOOD[4]); R(250, 143, 251, 143, WOOD[3]); R(254, 143, 255, 143, WOOD[3])
  R(253, 144, 253, 160, WOOD[5])
  -- fallen lemons and a basket on the grass
  lemon(222, 163); lemon(262, 164)
  R(282, 158, 290, 163, WOOD[2]); R(282, 158, 290, 158, WOOD[1]); R(290, 158, 290, 163, WOOD[4]); edge(c:rect(281, 157, 291, 164), WOOD[5])
  lemon(284, 155); lemon(287, 156)
  -- herb tufts on top face
  for k = 1, 16 do local x = 186 + floor(hsh(k, 7, 5) * 108); local y = 150 + floor(hsh(k, 8, 5) * 16)
    if c:get(x, y) and x > 184 and x < 296 then P(x, y, "#4f7a3a"); P(x, y - 1, "#7fae4a"); P(x + 1, y - 1, "#b6d870") end end
end

------------------------------------------------------------------ NOTICE BOARD box [314,104,348,174]
do
  castShadow({ { 320, 172 }, { 346, 172 }, { 360, 178 }, { 330, 178 } }, 0.82)
  R(318, 118, 321, 172, WOOD[3]); R(318, 118, 318, 172, WOOD[1]); R(321, 118, 321, 172, WOOD[4]); edge(c:rect(317, 118, 322, 172), WOOD[5])
  R(339, 118, 342, 172, WOOD[3]); R(339, 118, 339, 172, WOOD[1]); R(342, 118, 342, 172, WOOD[4]); edge(c:rect(338, 118, 343, 172), WOOD[5])
  local bd = c:rect(315, 116, 346, 156)
  MF(bd, function(x, y) local v = hsh(x, y, 71); if v > 0.85 then return CORK[1] elseif v < 0.15 then return CORK[3] end; if x > 342 or y > 153 then return CORK[3] end return CORK[2] end)
  edge(bd, CORK[5]); R(316, 117, 345, 117, CORK[1])
  -- little tiled roof (with a basil pot on top: quirk)
  local rf = poly{ { 312, 116 }, { 349, 116 }, { 344, 108 }, { 317, 108 } }
  tiles(rf, TERRA, 108, 330, 5)
  R(328, 103, 334, 107, TERRA[3]); R(328, 103, 334, 103, TERRA[1]); R(334, 104, 334, 107, TERRA[5])
  P(329, 102, LEAF[2]); P(331, 101, LEAF[1]); P(333, 102, LEAF[3]); P(330, 101, LEAF[3]); P(332, 100, LEAF[2]); P(331, 102, LEAF[3])
  -- pinned papers
  local papers = { { 318, 120, 9, 12, WASH[1] }, { 330, 119, 12, 9, "#fff0b8" }, { 320, 135, 11, 10, "#d8ecf4" }, { 333, 131, 9, 13, WASH[2] }, { 324, 146, 14, 7, "#f8d8e4" } }
  local pins = { "#d84050", BLUE[2], LEAF[3], LEMON[3], TEAL[3] }
  for i, p in ipairs(papers) do
    local x, y, w, h, col = p[1], p[2], p[3], p[4], p[5]
    R(x + 1, y + 1, x + w, y + h, CORK[4])
    R(x, y, x + w - 1, y + h - 1, col)
    for ly = y + 3, y + h - 3, 2 do R(x + 2, ly, x + 2 + floor(hsh(i, ly, 3) * (w - 4)), ly, WASH[4]) end
    if h > 9 then R(x + w - 4, y + h - 4, x + w - 2, y + h - 2, pins[(i % 5) + 1]) end
    P(x + floor(w / 2), y, pins[i]); P(x + floor(w / 2), y + 1, INK)
  end
end

------------------------------------------------------------------ SHOPS (market stalls, seed shop) box [354,128,434,196]
do
  castShadow({ { 360, 194 }, { 432, 194 }, { 444, 200 }, { 372, 200 } }, 0.84)
  -- back shopfront wall
  local wall = c:rect(358, 148, 430, 192)
  MF(wall, function(x, y) return stucco(WASH, x, y, 358, 430, 81) end)
  edge(wall, WASH[5])
  door(388, 160, 12, 32, BLUE, {})
  local function stall(x0, x1, col, goods, seed)
    -- posts
    R(x0 + 1, 144, x0 + 2, 192, WOOD[3]); R(x1 - 2, 144, x1 - 1, 192, WOOD[4])
    -- awning
    local aw = poly{ { x0 + 2, 134 }, { x1 - 2, 134 }, { x1 + 2, 146 }, { x0 - 2, 146 } }
    MF(aw, function(x, y) local s = floor((x - x0 + 2) / 4) % 2 == 0; local t = s and col[2] or WASH[1]; if y >= 144 then t = s and col[4] or WASH[3] end; if y <= 135 then t = s and col[1] or WASH[1] end; return t end)
    edge(aw, col[5] or col[4])
    for x = x0 - 2, x1 + 2, 4 do P(x + 1, 147, col[3]); P(x + 2, 147, col[3]); P(x + 2, 148, col[4]) end
    -- counter
    local ct = c:rect(x0, 168, x1, 192)
    MF(ct, function(x, y) local t = WOOD[2]; if (y - 168) % 5 == 4 then t = WOOD[4] end; if x == x0 + 1 then t = WOOD[1] end; if x > x1 - 3 then t = WOOD[4] end; if hsh(x, y, seed) > 0.93 then t = WOOD[3] end; return t end)
    edge(ct, WOOD[5]); R(x0, 167, x1, 167, WOOD[1])
    goods(x0, x1)
    contact(x0, x1 + 2, 193)
  end
  stall(356, 390, { LEMON[1], LEMON[2], LEMON[3], "#c98f2a", "#8f5f2e" }, function(x0, x1)
    -- seed packets fan + lemons crate
    local cols = { BOUG[2], LEAF[2], BLUE[2], TERRA[2], LEMON[3] }
    for i = 0, 4 do
      local px = x0 + 3 + i * 6
      R(px, 156, px + 4, 166, cols[i + 1]); R(px, 156, px + 4, 157, WASH[1]); R(px + 4, 158, px + 4, 166, WASH[5])
      P(px + 2, 162, LEAF[4]); P(px + 1, 161, LEAF[2]); P(px + 3, 160, LEAF[2]); P(px + 2, 163, WOOD[4])
    end
    R(x0 + 4, 172, x1 - 4, 179, WOOD[3]); edge(c:rect(x0 + 4, 172, x1 - 4, 179), WOOD[5])
    for k = 0, 5 do lemon(x0 + 7 + k * 4, 170) end
  end, 3)
  stall(398, 432, { "#a8ccf0", BLUE[2], BLUE[3], BLUE[4], BLUE[5] }, function(x0, x1)
    -- olive jars and bowls
    for i = 0, 2 do
      local jx = x0 + 6 + i * 10
      local jm = poly{ { jx - 3, 154 }, { jx + 3, 154 }, { jx + 4, 158 }, { jx + 3, 166 }, { jx - 3, 166 }, { jx - 4, 158 } }
      MF(jm, function(x, y) if x < jx - 1 then return TERRA[1] elseif x < jx + 2 then return TERRA[2] end return TERRA[4] end)
      edge(jm, TERRA[5])
      R(jx - 2, 152, jx + 2, 153, (i == 1) and "#4a3a52" or OLV[3]); P(jx - 1, 152, (i == 1) and "#7a6a8a" or OLV[1])
    end
    R(x0 + 3, 172, x1 - 3, 178, WASH[2]); edge(c:rect(x0 + 3, 172, x1 - 3, 178), BLUE[4])
    for x = x0 + 5, x1 - 5, 2 do P(x, 174, OLV[3]); P(x + 1, 175, "#4a3a52") end
  end, 4)
  -- SEED SHOP SIGN: sprout on a board hung from the awnings
  R(392, 130, 393, 148, WOOD[4])
  local sg = c:rect(384, 130, 402, 142)
  MF(sg, function(x, y) return (x < 386) and WOOD[1] or WOOD[2] end); edge(sg, WOOD[5])
  R(390, 138, 396, 140, "#7a5236"); R(392, 137, 394, 137, "#a87a50")
  R(393, 133, 393, 137, LEAF[3]); R(389, 133, 392, 134, LEAF[2]); P(389, 133, LEAF[1]); R(394, 132, 397, 133, LEAF[2]); P(397, 132, LEAF[1])
  -- pots
  for _, px in ipairs({ 360, 368 }) do R(px, 186, px + 5, 192, TERRA[2]); R(px, 186, px + 5, 186, TERRA[1]); R(px + 5, 187, px + 5, 192, TERRA[4]); boug(px, 182, px + 5, 185, px, 0.2) end
end

------------------------------------------------------------------ OLIVE PRESS (near left) box [14,128,114,208]
do
  castShadow({ { 100, 204 }, { 116, 196 }, { 126, 206 }, { 104, 210 } }, 0.84)
  house{ x0 = 18, x1 = 98, yt = 154, yb = 204, rh = 16, side = "r", sw = 12, wall = HONEY, roof = TERRA, seed = 31,
    patches = { { 20, 158, 20, 14 }, { 76, 160, 18, 12 }, { 24, 186, 10, 10 } } }
  contact(18, 110, 205)
  -- big open barn door with dark interior + jars inside
  local dm = c:rect(52, 168, 76, 204)
  MF(dm, function(x, y) if y < 172 then return "#3a2c36" end; return ((x + y) % 7 == 0) and "#4a3a46" or "#2f2632" end)
  edge(dm, WOOD[5])
  for i = 0, 2 do local jx = 58 + i * 7; R(jx - 2, 192, jx + 2, 203, TERRA[4]); R(jx - 1, 190, jx + 1, 191, TERRA[4]); P(jx - 1, 193, TERRA[3]) end
  -- open door leaves
  for _, dx in ipairs({ { 44, 51 }, { 77, 84 } }) do
    local lm = c:rect(dx[1], 168, dx[2], 204)
    MF(lm, function(x, y) local t = WOOD[2]; if (x - dx[1]) % 3 == 2 then t = WOOD[3] end; if y == 176 or y == 196 then t = WOOD[4] end; return t end)
    edge(lm, WOOD[5])
  end
  R(50, 165, 78, 167, WOOD[3]); R(50, 165, 78, 165, WOOD[1]); R(50, 167, 78, 167, WOOD[5])
  -- loft window
  window(60, 157, 8, 6, { shut = BLUE })
  -- OLIVE SIGN hanging from the eave: olive + leaves on a board
  R(28, 152, 40, 152, WOOD[5]); R(30, 152, 30, 155, WOOD[4]); R(38, 152, 38, 155, WOOD[4])
  local sb = c:rect(26, 156, 42, 166); MF(sb, function(x, y) return (y < 158) and WOOD[1] or WOOD[2] end); edge(sb, WOOD[5])
  local ol = c:ellipse(34, 162, 3, 3); MF(ol, function(x, y) return (x < 34 and y < 162) and OLV[1] or OLV[3] end); edge(ol, OLV[5])
  R(36, 158, 40, 159, LEAF[2]); P(40, 158, LEAF[1]); R(28, 158, 31, 159, LEAF[3]); P(28, 158, LEAF[2]); P(34, 158, WOOD[5])
  -- millstone edge-on in its stone basin
  local basin = c:rect(20, 192, 46, 204)
  MF(basin, function(x, y) local t = STONE[2]; if y == 192 then t = STONE[1] end; if (x - 20) % 7 == 6 then t = STONE[3] end; if x > 43 then t = STONE[4] end; return t end)
  edge(basin, STONE[5]); R(22, 193, 44, 193, "#9cae5a")
  local ms = c:rrect(26, 172, 38, 196, 3)
  MF(ms, function(x, y) local t = STONE[2]; if x < 29 then t = STONE[1] elseif x > 35 then t = STONE[4] end; if (y % 4 == 0) and x > 27 and x < 37 then t = STONE[3] end; return t end)
  edge(ms, STONE[5])
  R(16, 182, 48, 184, WOOD[3]); R(16, 182, 48, 182, WOOD[1]); R(16, 184, 48, 184, WOOD[5]) -- beam through
  R(46, 176, 48, 204, WOOD[4]); R(46, 176, 46, 204, WOOD[2])
  -- amphora jars outside
  for i = 0, 2 do
    local jx, jy = 84 + i * 9, 186 + (i % 2) * 2
    local jm = poly{ { jx - 2, jy }, { jx + 2, jy }, { jx + 4, jy + 5 }, { jx + 3, jy + 14 }, { jx, jy + 18 - (i % 2) * 2 }, { jx - 3, jy + 14 }, { jx - 4, jy + 5 } }
    MF(jm, function(x, y) if x < jx - 1 then return TERRA[1] elseif x < jx + 2 then return TERRA[2] end return TERRA[4] end)
    edge(jm, TERRA[5]); R(jx - 3, jy - 1, jx + 3, jy - 1, TERRA[3])
  end
  -- QUIRK: a little blue rowboat full of bougainvillea on the roof ridge
  local rb = poly{ { 30, 134 }, { 52, 134 }, { 48, 140 }, { 34, 140 } }
  MF(rb, function(x, y) return (y == 134) and WASH[1] or ((y < 137) and BLUE[2] or BLUE[4]) end); edge(rb, BLUE[5])
  boug(32, 129, 50, 133, 77, 0.25)
end

------------------------------------------------------------------ HARBOUR quay (near bottom-left) box [8,210,100,266]
do
  local water = poly{ { 0, 226 }, { 84, 226 }, { 98, 269 }, { 0, 269 } }
  MF(water, function(x, y)
    local t = "#3a8fc4"
    if y < 230 then t = "#2f6f9c" end
    local hv = hsh(floor(x / 4), y, 91)
    if (y + floor(x / 6)) % 5 == 0 and hv > 0.4 then t = "#5cb0d6" end
    if hv > 0.95 then t = "#d4eff0" end
    return t
  end)
  -- quay edge stones
  R(0, 222, 86, 225, STONE[2]); R(0, 222, 86, 222, STONE[1]); R(0, 225, 86, 225, STONE[4])
  for x = 0, 86, 8 do R(x, 223, x, 225, STONE[3]) end
  for y = 222, 269 do local x = floor(84 + (y - 226) * 14 / 43); R(x, y, x + 3, y, STONE[2]); P(x + 3, y, STONE[4]); P(x, y, STONE[1]) end
  -- boats
  local function boat(x, y, w, col, trim)
    local hm = poly{ { x, y }, { x + w, y - 3 }, { x + w - 6, y + 9 }, { x + 6, y + 9 } }
    MF(hm, function(px, py) if py <= y - 1 + floor((px - x) * -3 / w) + 2 then return trim end; if py > y + 6 then return col[4] end; return (px < x + w / 2) and col[2] or col[3] end)
    edge(hm, col[5])
    R(x + 4, y + 1, x + w - 4, y + 1, trim)
    -- mast + furled sail
    local mx = x + floor(w * 0.45)
    R(mx, y - 22, mx, y - 1, WOOD[4]); R(mx - 6, y - 18, mx + 8, y - 18, WOOD[3])
    R(mx - 5, y - 17, mx + 7, y - 16, WASH[2]); R(mx - 5, y - 16, mx + 7, y - 16, WASH[4])
    -- reflection
    for px = x + 6, x + w - 6 do if hsh(px, y, 2) > 0.4 then shade(px, y + 11, 0.8) end end
  end
  boat(14, 236, 40, TERRA, WASH[1])
  boat(40, 254, 42, { "#9fd0ee", BLUE[2], BLUE[3], BLUE[4], BLUE[5] }, LEMON[2])
  -- mooring post with drying nets
  R(70, 208, 73, 222, WOOD[3]); R(70, 208, 70, 222, WOOD[1]); R(73, 208, 73, 222, WOOD[5])
  local net = poly{ { 62, 210 }, { 82, 210 }, { 92, 220 }, { 58, 221 } }
  MF(net, function(x, y) if (x + y) % 3 == 0 or (x - y) % 3 == 0 then return "#d88a5a" end end)
  R(92, 216, 96, 221, "#e0a040"); R(92, 216, 96, 216, "#f4c870")  -- float
  -- QUIRK: brass listening-horn pointed at the olive trees (times the nets by cicada song)
  R(22, 206, 24, 222, WOOD[4]); R(22, 206, 22, 222, WOOD[2])
  local horn = poly{ { 24, 210 }, { 36, 202 }, { 38, 214 }, { 24, 213 } }
  MF(horn, function(x, y) if y < 208 then return BRASS[1] elseif y < 211 then return BRASS[2] end return BRASS[3] end)
  edge(horn, BRASS[4]); R(36, 203, 37, 213, BRASS[4])
  R(14, 214, 20, 221, STONE[3]); R(14, 214, 20, 214, STONE[1]); edge(c:rect(14, 214, 20, 221), STONE[5]) -- bollard
end

------------------------------------------------------------------ WILD TRAIL (right edge) box [438,134,466,228]
do
  -- dirt path leaving the picture
  local path = poly{ { 420, 228 }, { 446, 216 }, { 466, 210 }, { 466, 226 }, { 446, 228 } }
  MF(path, function(x, y) local v = hsh(x, y, 101); if v > 0.85 then return "#c89a6a" elseif v < 0.15 then return "#9a7656" end return "#b48660" end)
  -- wild meadow + dry-stone wall
  RF(440, 182, 465, 212, function(x, y)
    local v = hsh(x, y, 103)
    if y > 200 then if v > 0.5 then return "#9cb05a" end return "#7f9448" end
    local course = floor((y - 182) / 4); local bx = (x + course * 3) % 7
    if (y - 182) % 4 == 3 then return STONE[4] end
    if bx == 6 then return STONE[3] end
    return (hsh(floor((x + course * 3) / 7), course, 7) > 0.5) and STONE[1] or STONE[2]
  end)
  -- cane arch with bougainvillea
  R(442, 146, 444, 214, WOOD[3]); R(442, 146, 442, 214, WOOD[1]); R(444, 146, 444, 214, WOOD[5])
  R(460, 146, 462, 212, WOOD[3]); R(460, 146, 460, 212, WOOD[1]); R(462, 146, 462, 212, WOOD[5])
  R(440, 142, 464, 145, WOOD[3]); R(440, 142, 464, 142, WOOD[1]); R(440, 145, 464, 145, WOOD[5])
  boug(438, 134, 465, 148, 113, 0.3)
  boug(438, 148, 446, 176, 117, 0.5)
  -- signpost with arrow boards pointing out
  R(451, 162, 452, 212, WOOD[4]); R(451, 162, 451, 212, WOOD[2])
  local arrows = { { 166, TEAL }, { 176, LEMON }, { 186, CORAL } }
  for _, a in ipairs(arrows) do
    local y, col = a[1], a[2]
    local am = poly{ { 446, y }, { 459, y }, { 462, y + 3 }, { 459, y + 6 }, { 446, y + 6 } }
    MF(am, function(x, yy) return (yy == y) and col[1] or col[2] end); edge(am, col[4] or col[3])
  end
end

------------------------------------------------------------------ GATE FRAME (Mediterranean whitewashed arch)
do
  local function blocks(x0, y0, x1, y1, seed)
    RF(x0, y0, x1, y1, function(x, y)
      local course = floor(y / 7)
      local off = (course % 2) * 6
      local bx = (x + off) % 12
      local t = stucco(WASH, x, y, x0, x1, seed)
      if y % 7 == 6 then t = WASH[3] end
      if bx == 11 and hsh(course, floor((x + off) / 12), seed) > 0.3 then t = WASH[3] end
      return t
    end)
  end
  blocks(0, 0, 15, 269, 201)
  blocks(464, 0, 479, 269, 202)
  blocks(0, 0, 479, 12, 203)
  -- terracotta coping on the lintel
  local cp = c:rect(0, 0, 479, 3)
  tiles(cp, TERRA, 0, 9999, 9)
  -- blue painted inner trim
  R(14, 13, 15, 269, BLUE[2]); R(14, 13, 14, 269, BLUE[1]); R(16, 13, 16, 269, BLUE[5])
  R(463, 13, 464, 269, BLUE[3]); R(463, 13, 463, 269, BLUE[5]); R(465, 13, 465, 269, WASH[4])
  R(14, 12, 465, 12, BLUE[2]); R(14, 11, 465, 11, BLUE[1]); R(14, 13, 465, 13, BLUE[5])
  -- corner corbels
  for i = 0, 9 do R(17, 14 + i, 17 + 9 - i, 14 + i, WASH[2]); P(17 + 9 - i, 14 + i, WASH[5]); R(462 - 9 + i, 14 + i, 462, 14 + i, WASH[3]); P(462 - 9 + i, 14 + i, WASH[5]) end
  -- shade on the right pillar (light from upper left)
  for y = 13, 269 do for x = 466, 479 do if hsh(x, y, 5) > 0.4 then shade(x, y, 0.86) end end end
  -- bougainvillea spilling over both top corners
  boug(0, 2, 60, 22, 211, 0.42); boug(420, 2, 479, 22, 213, 0.42)
  boug(0, 20, 12, 70, 215, 0.5); boug(467, 20, 479, 60, 217, 0.5)
  -- bunting
  local function bunt(x) return 18 + 12 * (1 - ((x - 240) / 224) ^ 2) end
  local fc = { BLUE, LEMON, WASH, TERRA, TEAL }
  for x = 17, 462 do P(x, floor(bunt(x)), WOOD[5]) end
  local k = 0
  for x = 26, 450, 13 do
    k = k + 1
    local col = fc[(k % 5) + 1]
    local y0 = floor(bunt(x + 4)) + 1
    for i = 0, 7 do
      local hw = floor((8 - i) / 2)
      for xx = x + 4 - hw, x + 4 + hw do P(xx, y0 + i, (xx <= x + 4) and col[1] or col[3]) end
    end
    P(x + 4, y0 + 8, col[4] or col[3])
  end
  -- hanging lanterns
  local function lantern(lx)
    R(lx, 13, lx, 30, "#5a4a52")
    R(lx - 4, 31, lx + 4, 33, BRASS[3]); R(lx - 4, 31, lx + 4, 31, BRASS[2])
    R(lx - 4, 34, lx + 4, 46, BRASS[4])
    R(lx - 3, 34, lx + 3, 45, WARM[2]); R(lx - 2, 35, lx, 42, WARM[1]); R(lx + 2, 34, lx + 3, 45, WARM[3])
    R(lx, 34, lx, 45, BRASS[4])
    R(lx - 5, 46, lx + 5, 47, BRASS[3]); R(lx - 5, 47, lx + 5, 47, BRASS[4]); P(lx, 48, BRASS[3])
    for y = 26, 56 do for x = lx - 14, lx + 14 do
      local d = ((x - lx) / 14) ^ 2 + ((y - 40) / 16) ^ 2
      if d < 1 and d > 0.25 and (abs(x - lx) > 5 or y < 30 or y > 48) then glow(x, y, 0.22 * (1 - d)) end
    end end
  end
  lantern(32); lantern(447)
end

------------------------------------------------------------------ finish
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { "green", "The Lemon Grove", 176, 92, 304, 182 },
  { "tea", "Cafe Cicada", 348, 40, 438, 126 },
  { "board", "Notice Board", 312, 100, 346, 176 },
  { "library", "Library", 34, 36, 124, 126 },
  { "s1", "Olive Press", 14, 128, 114, 208 },
  { "s2", "Harbour", 0, 210, 100, 269 },
  { "shops", "Shops", 354, 128, 434, 198 },
  { "wild", "Wild Trail", 438, 134, 466, 228 },
}
local stand = { { 146, 174 }, { 132, 244 }, { 200, 240 }, { 240, 212 }, { 284, 240 }, { 332, 220 } }
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], (s[3] + s[5]) // 2, (s[4] + s[6]) // 2, s[3], s[4], s[5], s[6])
end
local sp = {}
for _, p in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write('{"w":480,"h":270,"horizon":88,"view":"gate","spots":[' .. table.concat(parts, ",") .. '],"stand":[' .. table.concat(sp, ",") .. '],"compass_clear":[380,230,480,270]}\n')
f:close()
print("ok")

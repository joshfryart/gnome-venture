-- here-delve.lua : Gnome Venture "Hearth Pop" v3, GATE VIEW of a Delve (mine mouth), 480x270 native.
-- Single pass. Own pixel buffer -> HP canvas; c:finish{outline=false}; HP.assertClean.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(ROOT .. "/lib/hp.lua")
local OUT = app.params.out or (ROOT .. "/here-gate/places/")
local NAME = "here-delve"
local W, H = 480, 270
local HORIZON = 112
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt

---------------------------------------------------------------- buffer + colour
local buf = {}
local function set(x, y, c) if x >= 0 and x < W and y >= 0 and y < H then buf[y * W + x + 1] = c end end
local function get(x, y) return buf[y * W + x + 1] or "#3b2f5e" end
local function hx(c) return tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) end
local function mix(a, b, t)
  local r1, g1, b1 = hx(a) local r2, g2, b2 = hx(b)
  local function f(p, q) return max(8, min(247, floor(p + (q - p) * t + 0.5))) end
  return string.format("#%02x%02x%02x", f(r1, r2), f(g1, g2), f(b1, b2))
end
local function hash(x, y, s) local n = math.sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453 return n - floor(n) end

local INK = "#2b1c26"
local SHADE = "#3a2d4a"
local WARM = "#ffd27a"

---------------------------------------------------------------- masks
local M = {} M.__index = M
local function mask() return setmetatable({ k = {}, x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9 }, M) end
function M:add(x, y)
  if x < 0 or x >= W or y < 0 or y >= H then return end
  local i = y * W + x
  if not self.k[i] then
    self.k[i] = true
    if x < self.x0 then self.x0 = x end if x > self.x1 then self.x1 = x end
    if y < self.y0 then self.y0 = y end if y > self.y1 then self.y1 = y end
  end
end
function M:has(x, y) return x >= 0 and x < W and y >= 0 and y < H and self.k[y * W + x] end
function M:each(fn) for i in pairs(self.k) do fn(i % W, floor(i / W)) end end
function M:cut(o) for i in pairs(o.k) do self.k[i] = nil end return self end
function M:union(o) o:each(function(x, y) self:add(x, y) end) return self end
local function rect(x0, y0, x1, y1) local m = mask() for y = y0, y1 do for x = x0, x1 do m:add(x, y) end end return m end
local function poly(p)
  local m = mask()
  local ya, yb = 1e9, -1e9
  for _, q in ipairs(p) do ya = min(ya, q[2]) yb = max(yb, q[2]) end
  for y = floor(ya), floor(yb) do
    local yc, xs = y + 0.5, {}
    for i = 1, #p do
      local a, b = p[i], p[i % #p + 1]
      if (a[2] <= yc and b[2] > yc) or (b[2] <= yc and a[2] > yc) then
        xs[#xs + 1] = a[1] + (yc - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = floor(xs[i] + 0.5), floor(xs[i + 1] - 0.5) do m:add(x, y) end
    end
  end
  return m
end
local function oct(cx, cy, r)  -- stepped octagon (no circles)
  local k = floor(r * 0.42)
  return poly{ {cx - r + k, cy - r}, {cx + r - k + 1, cy - r}, {cx + r + 1, cy - r + k}, {cx + r + 1, cy + r - k + 1},
               {cx + r - k + 1, cy + r + 1}, {cx - r + k, cy + r + 1}, {cx - r, cy + r - k + 1}, {cx - r, cy - r + k} }
end
local function fill(m, c) m:each(function(x, y) set(x, y, c) end) end
local function edgeIn(m, c)
  m:each(function(x, y)
    if not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1)) then set(x, y, c) end
  end)
end
local function rim(m, c)
  local r = {}
  m:each(function(x, y)
    for _, d in ipairs{ {1, 0}, {-1, 0}, {0, 1}, {0, -1} } do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) then r[#r + 1] = { nx, ny } end
    end
  end)
  for _, p in ipairs(r) do set(p[1], p[2], c) end
end
local function darken(m, t, col) m:each(function(x, y) set(x, y, mix(get(x, y), col or SHADE, t)) end) end
local function line(pts, c, w)
  w = w or 1
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    for s = 0, n do
      local x = floor(a[1] + (b[1] - a[1]) * s / n + 0.5)
      local y = floor(a[2] + (b[2] - a[2]) * s / n + 0.5)
      for dx = 0, w - 1 do for dy = 0, w - 1 do set(x + dx, y + dy, c) end end
    end
  end
end
-- glow: stepped octagonal warm rings that lighten what is there (no transparency, no dither)
local function glow(cx, cy, r, col, amt)
  col = col or WARM amt = amt or 0.32
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local dx, dy = abs(x - cx), abs(y - cy)
    local d = (dx + dy + max(dx, dy)) / 2
    if d <= r and x >= 0 and x < W and y >= 0 and y < H then
      local t = d < r * 0.45 and amt or (d < r * 0.75 and amt * 0.55 or amt * 0.25)
      set(x, y, mix(get(x, y), col, t))
    end
  end end
end

-- tone a mask with a 5-step ramp {deep,shade,base,hi,lite}, light from upper-left, texture fn
local function tone(m, R, tex, o)
  o = o or {}
  local w, h = max(1, m.x1 - m.x0), max(1, m.y1 - m.y0)
  m:each(function(x, y)
    local u, v = (x - m.x0) / w, (y - m.y0) / h
    local lv = (1 - u) * (o.lu or 0.55) + (1 - v) * (o.lv or 0.45)
    local i = 3
    if lv > 0.74 then i = 4 elseif lv < 0.28 then i = 2 end
    if tex then
      local d, absI = tex(x, y, u, v, x - m.x0, y - m.y0)
      if absI then i = absI else i = i + (d or 0) end
    end
    i = max(1, min(5, i))
    set(x, y, R[i])
  end)
  if o.edge ~= false then edgeIn(m, o.edgeCol or R[1]) end
end

-- textures
local function planksV(pw, seed)
  return function(x, y, u, v, lx, ly)
    if lx % pw == 0 then return nil, 1 end
    if lx % pw == 1 then return 1 end
    local g = hash(floor(lx / pw), floor(ly / 3), seed or 1)
    if g > 0.86 and (ly % 3 == 0) then return -1 end
    if hash(lx, ly, seed or 1) > 0.95 then return -1 end
    return 0
  end
end
local function planksH(ph, seed)
  return function(x, y, u, v, lx, ly)
    if ly % ph == 0 then return nil, 1 end
    if ly % ph == 1 then return 1 end
    local g = hash(floor(lx / 4), floor(ly / ph), seed or 2)
    if g > 0.85 and (lx % 4 == 0) then return -1 end
    if hash(lx, ly, seed or 3) > 0.96 then return -1 end
    return 0
  end
end
local function rockTex(cw, ch, seed)
  return function(x, y, u, v)
    local row = floor(y / ch)
    local col = floor((x + (row % 2) * floor(cw / 2)) / cw)
    local hcell = hash(col, row, seed or 4)
    local ly = y % ch
    local lx = (x + (row % 2) * floor(cw / 2)) % cw
    if ly == ch - 1 and hash(col, row, 9) > 0.25 then return -1 end
    if lx == cw - 1 and hash(col, row, 11) > 0.4 then return -1 end
    if ly == 0 and lx < cw - 2 and hcell > 0.5 then return 1 end
    if hcell > 0.8 then return 1 elseif hcell < 0.18 then return -1 end
    return 0
  end
end
local function corrugate(x, y, u, v, lx, ly)
  local k = lx % 4
  if k == 0 then return 1 elseif k == 2 then return -1 end
  return 0
end

---------------------------------------------------------------- ramps
local R_TIMBER = { "#3e2a22", "#5e3f2c", "#82583a", "#a8774c", "#cf9d66" }
local R_ROCK   = { "#3a2d3c", "#5c4652", "#7d6266", "#a08078", "#c4a090" }
local R_ROCKF  = { "#4a3c52", "#665366", "#80697a", "#9c8290", "#b8a0a4" }
local R_MOSS   = { "#33452e", "#4d6a36", "#6b8a40", "#90ad52", "#b8cc72" }
local R_SHED   = { "#2e3e4e", "#3f5a6a", "#557a84", "#76a0a0", "#a4c8bc" }
local R_TIN    = { "#4a2a2a", "#7a3a30", "#a35a3a", "#c97f4a", "#e8b070" }
local R_CART   = { "#4a2026", "#7a3330", "#a6493a", "#c86b4a", "#e8a070" }
local R_STEEL  = { "#33363f", "#4d5260", "#6d7480", "#959dab", "#c4cad4" }
local R_ORE    = { "#2e2836", "#463c50", "#5f5468", "#7d7086", "#a598a8" }
local R_AQUA   = { "#1f4a5a", "#2f7a86", "#4fb3b0", "#8ee0cc", "#d8fff0" }
local R_VIO    = { "#3a2860", "#5a3c8a", "#8a5cc0", "#b48ae0", "#e8d0ff" }
local R_PINE   = { "#5a3a24", "#80562e", "#a87a40", "#cfa05a", "#ecc888" }
local R_BARREL = { "#4a2a30", "#6e3a38", "#8e5040", "#b07050", "#d09a70" }
local R_COPPER = { "#4a2c2a", "#7c4430", "#b0643a", "#d8925a", "#f4c890" }
local R_BOARD  = { "#5a3c2a", "#8a6038", "#b88a52", "#d8b070", "#f0d49a" }
local R_GRAV   = { "#4f4a4a", "#6e665f", "#8d8478", "#a69c8c", "#c4b8a4" }
local R_MUSH   = { "#5a2a3a", "#9a3a4a", "#d0604a", "#f0905a", "#ffd0a0" }
local R_TEAL   = { "#24343a", "#2f4646", "#3c5850", "#4e6c5a", "#62826a" }

---------------------------------------------------------------- 1. SKY (dusk)
local skyRows = { {0, "#34295a"}, {16, "#45326a"}, {30, "#5c3c76"}, {44, "#7a4878"}, {58, "#9c5476"},
                  {72, "#c06872"}, {86, "#dc8270"}, {98, "#eea072"}, {106, "#f6be82"} }
for y = 0, HORIZON + 8 do
  local c = skyRows[1][2]
  for _, r in ipairs(skyRows) do if y >= r[1] then c = r[2] end end
  for x = 0, W - 1 do set(x, y, c) end
end
-- stars high up
for _, s in ipairs{ {120, 22}, {176, 16}, {300, 20}, {350, 30}, {96, 36}, {392, 18}, {260, 26} } do
  set(s[1], s[2], "#f4e4c4") set(s[1] - 1, s[2], "#b89ab8") set(s[1] + 1, s[2], "#b89ab8")
  set(s[1], s[2] - 1, "#b89ab8") set(s[1], s[2] + 1, "#b89ab8")
end
-- flat dusk clouds (lit pink undersides, light from upper left)
local function cloudBlock(x, y, w)
  local m = poly{ {x, y}, {x + 4, y - 5}, {x + floor(w * 0.3), y - 7}, {x + floor(w * 0.38), y - 12},
                  {x + floor(w * 0.6), y - 12}, {x + floor(w * 0.7), y - 7}, {x + w - 4, y - 6}, {x + w, y} }
  m:each(function(px, py)
    local c = "#d89aa0"
    if py >= y - 2 then c = "#f0b48c" elseif py < y - 9 then c = "#b07e9e" end
    if px > x + w * 0.75 and py < y - 2 then c = "#a07294" end
    set(px, py, c)
  end)
end
cloudBlock(84, 52, 70) cloudBlock(300, 44, 86) cloudBlock(200, 78, 46) cloudBlock(392, 74, 50)

---------------------------------------------------------------- 2. FAR MOUNTAINS + HILLS
for x = 0, W - 1 do
  local t = 70 + floor(10 * math.sin(x * 0.021) + 6 * math.sin(x * 0.057 + 1.3) + 3 * hash(floor(x / 5), 1, 2))
  for y = t, HORIZON + 8 do
    local c = "#6b5a8a"
    if y < t + 2 and x % 7 < 4 then c = "#8a72a0" end
    if y > t + 14 then c = "#5f5080" end
    set(x, y, c)
  end
end
for x = 0, W - 1 do
  local t = 94 + floor(6 * math.sin(x * 0.03 + 2) + 3 * math.sin(x * 0.09))
  for y = t, HORIZON + 10 do
    local c = (y < t + 2) and "#7a6a84" or "#5a5068"
    set(x, y, c)
  end
end
-- wild woods at right (pines) and a few at left
local function pine(cx, by, h, R)
  local w = floor(h * 0.42)
  for i = 0, 2 do
    local ty = by - h + floor(i * h * 0.28)
    local m = poly{ {cx, ty}, {cx + w - (2 - i) * 2, ty + floor(h * 0.42)}, {cx - w + (2 - i) * 2, ty + floor(h * 0.42)} }
    m:each(function(x, y)
      local c = R[3]
      if x < cx - 1 and y < ty + h * 0.3 then c = R[4] end
      if x > cx + 1 then c = R[2] end
      if hash(x, y, 7) > 0.9 then c = R[1] end
      set(x, y, c)
    end)
  end
  line({ {cx, by - 4}, {cx, by} }, "#3e2a22", 2)
end
for _, p in ipairs{ {372, 118, 30}, {390, 116, 40}, {408, 120, 34}, {430, 114, 44}, {448, 118, 36}, {466, 116, 42},
                    {30, 116, 30}, {48, 118, 24} } do
  pine(p[1], p[2], p[3], R_TEAL)
end

---------------------------------------------------------------- 3. GROUND
local GROUND_TOP = 116
for y = GROUND_TOP, H - 1 do
  for x = 0, W - 1 do
    local c
    if y < 132 then c = "#b08860" elseif y < 160 then c = "#a07a54" elseif y < 210 then c = "#93704e" else c = "#866448" end
    local n = hash(x, y, 21)
    if n > 0.94 then c = mix(c, "#5a3e34", 0.45) elseif n < 0.035 then c = mix(c, "#e8c08a", 0.4) end
    set(x, y, c)
  end
end

---------------------------------------------------------------- 4. HILLSIDE ROCK (behind the mouth)
local hill = mask()
local hillTop = {}
for x = 100, 380 do
  local t = 34 + ((x - 240) / 124) ^ 2 * 72 + floor(hash(floor(x / 7), 0, 3) * 7)
  if x > 150 and x < 172 then t = t - 8 end         -- crag left
  if x > 316 and x < 330 then t = t - 5 end         -- crag right
  t = floor(min(t, GROUND_TOP + 4))
  hillTop[x] = t
  for y = t, 132 do hill:add(x, y) end
end
tone(hill, R_ROCK, rockTex(11, 7, 5), { lu = 0.6, lv = 0.4 })
-- moss cap + warm sunset rim on the top-left facing edge
for x = 100, 380 do
  local t = hillTop[x]
  for d = 0, 3 do
    local c = R_MOSS[(d == 0) and 4 or (d == 1 and 3 or 2)]
    if x > 290 then c = R_MOSS[(d == 0) and 3 or 2] end
    if d < 3 or hash(x, 0, 8) > 0.5 then set(x, t + d, c) end
  end
  if hash(x, 1, 9) > 0.8 then set(x, t + 4, R_MOSS[2]) set(x, t + 5, R_MOSS[1]) end
  set(x, t - 1, mix(get(x, t - 1), R_MOSS[1], 0.7))
end
-- hill foot meets ground (soft violet AO)
for x = 100, 380 do for y = 128, 133 do set(x, y, mix(get(x, y), SHADE, 0.25)) end end

---------------------------------------------------------------- 5. PATH + RAILS
local path = poly{ {206, 140}, {274, 140}, {350, 270}, {130, 270} }
tone(path, R_GRAV, function(x, y, u, v)
  local s = 2 + floor((y - 140) / 22)                       -- pebble grows with depth
  local cx, cy = floor(x / (s + 1)), floor(y / max(1, floor(s * 0.7)))
  local hc = hash(cx, cy, 31)
  if (x % (s + 1)) == s and hc > 0.4 then return -1 end
  if hc > 0.82 then return 1 elseif hc < 0.14 then return -1 end
  return 0
end, { lu = 0.3, lv = 0.7, edge = false })
-- kerb stones along the path edge
for y = 140, 269 do
  local t = (y - 140) / 130
  local xl = floor(206 + (130 - 206) * t)
  local xr = floor(274 + (350 - 274) * t)
  local s = 1 + floor(t * 3)
  for d = 0, s do
    set(xl + d, y, ((y // (3 + s)) % 2 == 0) and R_GRAV[2] or R_GRAV[1])
    set(xr - d, y, ((y // (3 + s)) % 2 == 0) and R_GRAV[2] or R_GRAV[1])
  end
end
-- rails: perspective ties then steel rails
local function railX(y, side)
  local t = (y - 128) / (270 - 128)
  if side < 0 then return 233 + (196 - 233) * t else return 247 + (284 - 247) * t end
end
local z = 10.1
while true do
  local y = floor(HORIZON + 1600 / z)
  if y < 142 then break end
  local s = (y - HORIZON) / 158
  local th = max(1, floor(5 * s))
  local xl, xr = floor(railX(y, -1) - 10 * s), floor(railX(y, 1) + 10 * s)
  local tie = rect(xl, y - th, xr, y)
  tone(tie, R_TIMBER, planksV(7, 3), { lu = 0.7, lv = 0.3 })
  darken(rect(xl + 1, y + 1, xr + 1, y + 1), 0.35)
  z = z * 1.17
end
for y = 142, 269 do
  local s = (y - HORIZON) / 158
  local w = max(1, floor(3.4 * s))
  for _, side in ipairs{ -1, 1 } do
    local x = floor(railX(y, side))
    for d = 0, w - 1 do set(x + d, y, d == 0 and R_STEEL[5] or R_STEEL[3]) end
    set(x + w, y, R_STEEL[1])
  end
end

---------------------------------------------------------------- 6. MINE MOUTH (hero spot)
-- opening, receding in depth bands toward the vanishing point
local OX0, OY0, OX1, OY1 = 202, 70, 278, 142
local bands = { "#3e2c40", "#34253a", "#2b1f32", "#24192a", "#1e1424" }
for i = 0, 4 do
  local t = i / 5
  local x0 = floor(OX0 + (232 - OX0) * t) local x1 = floor(OX1 + (248 - OX1) * t)
  local y0 = floor(OY0 + (96 - OY0) * t)  local y1 = floor(OY1 + (126 - OY1) * t)
  fill(rect(x0, y0, x1, y1), bands[i + 1])
end
-- tunnel floor
local tfloor = poly{ {202, 142}, {278, 142}, {250, 126}, {230, 126} }
fill(tfloor, "#3a2c30")
for y = 126, 141 do for x = 202, 278 do
  if tfloor:has(x, y) and hash(x, y, 41) > 0.9 then set(x, y, "#4e3c3a") end
end end
-- rails inside
for y = 126, 141 do
  local xl, xr = floor(railX(y, -1)), floor(railX(y, 1))
  set(xl, y, "#7a6e74") set(xr, y, "#7a6e74")
end
-- inner timber frames (depth)
local function frame(x0, y0, x1, y1, pw, R)
  local posts = rect(x0, y0, x0 + pw - 1, y1):union(rect(x1 - pw + 1, y0, x1, y1)):union(rect(x0, y0, x1, y0 + pw - 1))
  tone(posts, R, nil, { edge = true })
end
frame(226, 90, 254, 128, 2, { "#1a1220", "#2a1e26", "#3a2a2c", "#4a3830", "#5a4636" })
frame(214, 80, 266, 136, 4, { "#2a1c1e", "#3a2a26", "#4e3a2e", "#644a36", "#7a5c40" })
-- inner glowing crystals & a far lamp
local function shard(p, R, gl)
  local m = poly(p)
  local cx = (m.x0 + m.x1) / 2
  m:each(function(x, y)
    local c = (x <= cx) and R[4] or R[3]
    if y > m.y1 - 2 then c = R[2] end
    set(x, y, c)
  end)
  edgeIn(m, R[1])
  set(floor(cx) - 1, m.y0 + 2, R[5])
  return m
end
glow(209, 104, 12, "#8ee0cc", 0.28) glow(270, 96, 12, "#b48ae0", 0.28) glow(240, 104, 9, WARM, 0.35)
shard({ {204, 112}, {206, 98}, {210, 94}, {212, 112} }, R_AQUA)
shard({ {208, 114}, {212, 104}, {216, 114} }, R_AQUA)
shard({ {268, 104}, {272, 88}, {276, 86}, {277, 104} }, R_VIO)
shard({ {263, 106}, {266, 98}, {269, 106} }, R_VIO)
fill(rect(238, 100, 242, 106), "#5a3a2a") fill(rect(239, 101, 241, 105), WARM) set(240, 103, "#fff0c0")
-- mushrooms glowing in the tunnel floor corners
local function mush(x, y, s, R)
  local cap = poly{ {x - s, y - s}, {x - s + 2, y - s - 3}, {x + s - 2, y - s - 3}, {x + s + 1, y - s} }
  fill(rect(x - 1, y - s, x + 1, y), "#e8d8b8") set(x + 1, y - 1, "#b8a088")
  cap:each(function(px, py) set(px, py, px < x and R[4] or R[3]) end)
  edgeIn(cap, R[1])
  set(x - s + 2, y - s - 2, R[5]) set(x + 1, y - s - 1, R[5])
end
-- main timber posts + lintel (hero, ink rim)
local postL = rect(190, 64, 201, 144)
local postR = rect(279, 64, 290, 144)
local lintel = rect(182, 56, 298, 68)
local braceL = poly{ {202, 69}, {214, 69}, {202, 81} }
local braceR = poly{ {278, 69}, {266, 69}, {278, 81} }
for _, m in ipairs{ postL, postR, lintel, braceL, braceR } do rim(m, INK) end
tone(postL, R_TIMBER, planksV(4, 6), { lu = 0.8, lv = 0.2 })
tone(postR, R_TIMBER, planksV(4, 7), { lu = 0.8, lv = 0.2 })
tone(lintel, R_TIMBER, planksH(5, 8), { lu = 0.5, lv = 0.5 })
tone(braceL, R_TIMBER) tone(braceR, R_TIMBER)
-- iron bolts + bands
for _, b in ipairs{ {195, 60}, {285, 60}, {240, 60}, {212, 61}, {268, 61} } do set(b[1], b[2], R_STEEL[5]) set(b[1] + 1, b[2] + 1, R_STEEL[1]) end
for _, yb in ipairs{ 84, 124 } do
  fill(rect(190, yb, 201, yb + 2), R_STEEL[3]) fill(rect(190, yb, 201, yb), R_STEEL[4])
  fill(rect(279, yb, 290, yb + 2), R_STEEL[3]) fill(rect(279, yb, 290, yb), R_STEEL[4])
  set(193, yb + 1, R_STEEL[5]) set(285, yb + 1, R_STEEL[5])
end
-- warm sunset light on lintel top
fill(rect(183, 57, 260, 57), R_TIMBER[5])
-- shadow under lintel into the mouth
darken(rect(202, 69, 278, 72), 0.4)
-- plaque with a pickaxe icon (sign of the spot)
local plaque = rect(224, 38, 256, 54)
rim(plaque, INK)
tone(plaque, R_BOARD, planksH(6, 12))
line({ {232, 50}, {248, 40} }, "#5a3c2a", 2)                              -- handle
line({ {231, 41}, {236, 39}, {242, 40}, {247, 43}, {250, 47} }, R_STEEL[2], 2)  -- head
set(232, 41, R_STEEL[5]) set(246, 43, R_STEEL[5])
set(226, 40, R_STEEL[4]) set(254, 40, R_STEEL[4]) set(226, 52, R_STEEL[4]) set(254, 52, R_STEEL[4])
-- QUIRK: pickaxe stuck in the rock with a tiny gnome hat hung on it
line({ {268, 48}, {282, 30} }, R_TIMBER[2], 2) line({ {268, 48}, {281, 31} }, R_TIMBER[4], 1)
line({ {264, 44}, {268, 47}, {273, 52} }, R_STEEL[3], 2) set(264, 44, R_STEEL[5])
local hat = poly{ {276, 40}, {290, 40}, {284, 26} }
rim(hat, INK) tone(hat, { "#5a2030", "#8a2c3a", "#b8404a", "#d86858", "#f09a80" })
fill(rect(275, 40, 291, 41), "#3e4a7a")
-- lantern on a hook on the left post
glow(184, 92, 22, WARM, 0.34)
line({ {189, 74}, {184, 74}, {184, 80} }, R_STEEL[1], 1)
local lan = rect(179, 81, 189, 96)
rim(lan, INK) fill(lan, "#3a2c2a")
fill(rect(181, 84, 187, 94), "#f5a54a") fill(rect(182, 85, 185, 92), WARM) set(183, 88, "#fff0c0")
fill(rect(178, 80, 190, 82), R_STEEL[2]) fill(rect(178, 95, 190, 96), R_STEEL[2])
-- mushrooms at the mouth feet
glow(184, 140, 10, "#f0905a", 0.22) glow(296, 140, 10, "#8ee0cc", 0.22)
mush(180, 146, 4, R_MUSH) mush(187, 147, 3, R_MUSH)
mush(296, 146, 4, R_AQUA) mush(302, 147, 2, R_AQUA)
-- QUIRK: a striped welcome mat in front of the mine
local mat = poly{ {222, 143}, {258, 143}, {261, 149}, {219, 149} }
rim(mat, INK)
mat:each(function(x, y) set(x, y, ((x // 4) % 2 == 0) and "#b8404a" or "#e8c070") end)
-- redraw rails over the mat
for y = 143, 149 do
  local x = floor(railX(y, -1)) set(x, y, R_STEEL[5]) set(x + 1, y, R_STEEL[1])
  x = floor(railX(y, 1)) set(x, y, R_STEEL[5]) set(x + 1, y, R_STEEL[1])
end

---------------------------------------------------------------- 7. TOOL SHED (left far)
darken(poly{ {132, 150}, {146, 150}, {168, 160}, {150, 160}, {60, 152}, {132, 152} }, 0.35)
local roof = poly{ {44, 116}, {94, 82}, {144, 116}, {140, 119}, {48, 119} }
local shed = rect(54, 114, 134, 150)
rim(shed, INK) rim(roof, INK)
tone(shed, R_SHED, planksV(6, 13), { lu = 0.6, lv = 0.4 })
tone(roof, R_TIN, corrugate, { lu = 0.7, lv = 0.3 })
fill(rect(46, 117, 142, 118), R_TIN[1])
darken(rect(54, 119, 134, 121), 0.35)
-- open door with tools
fill(rect(62, 124, 80, 150), "#2a2030")
rim(rect(62, 124, 80, 150), R_SHED[1])
line({ {66, 128}, {66, 146} }, R_TIMBER[3], 1) fill(rect(65, 145, 67, 149), R_STEEL[3])
line({ {72, 127}, {72, 145} }, R_TIMBER[3], 1) line({ {69, 127}, {75, 127} }, R_STEEL[3], 1)
line({ {77, 130}, {77, 148} }, R_TIMBER[4], 1) fill(rect(76, 130, 78, 132), R_STEEL[4])
-- glowing window
glow(108, 128, 16, WARM, 0.28)
local win = rect(98, 122, 118, 136)
rim(win, R_SHED[1])
fill(win, "#f5a54a") fill(rect(99, 123, 107, 128), WARM) fill(rect(110, 123, 117, 128), WARM)
line({ {108, 122}, {108, 136} }, R_SHED[1], 1) line({ {98, 129}, {118, 129} }, R_SHED[1], 1)
fill(rect(96, 137, 120, 138), R_TIMBER[3]) fill(rect(96, 137, 120, 137), R_TIMBER[4])
-- shovel icon board above door
local sb = rect(64, 116, 78, 122)
fill(sb, R_BOARD[3]) edgeIn(sb, R_BOARD[1])
line({ {67, 121}, {74, 117} }, R_TIMBER[1], 1) fill(rect(74, 117, 76, 118), R_STEEL[2])
-- QUIRK: tiny pair of boots by the door
for _, bx in ipairs{ 84, 90 } do
  local boot = poly{ {bx, 142}, {bx + 3, 142}, {bx + 3, 147}, {bx + 6, 147}, {bx + 6, 150}, {bx, 150} }
  rim(boot, INK) fill(boot, "#8a5030") set(bx + 1, 143, "#b07040")
end

---------------------------------------------------------------- 8. CRYSTAL OUTCROP (right far)
glow(344, 118, 30, "#8ee0cc", 0.2)
darken(poly{ {366, 150}, {378, 150}, {398, 158}, {380, 158} }, 0.3)
local base = poly{ {316, 150}, {322, 134}, {340, 128}, {360, 130}, {374, 140}, {374, 150} }
rim(base, R_ROCK[1])
tone(base, R_ROCK, rockTex(7, 5, 14))
local big = { {336, 132}, {340, 104}, {346, 96}, {352, 104}, {354, 132} }
local mid = { {322, 138}, {322, 118}, {328, 110}, {333, 136} }
local vio = { {356, 136}, {360, 114}, {367, 108}, {370, 136} }
for _, p in ipairs{ big, mid, vio } do rim(poly(p), INK) end
shard(big, R_AQUA) shard(mid, R_AQUA) shard(vio, R_VIO)
shard({ {330, 140}, {332, 128}, {336, 140} }, R_VIO)
shard({ {352, 140}, {355, 130}, {358, 140} }, R_AQUA)
line({ {346, 98}, {345, 128} }, R_AQUA[5], 1)
set(363, 112, R_VIO[5]) set(364, 113, R_VIO[5])

---------------------------------------------------------------- 9. ORE CART on a rail stub (left near)
darken(poly{ {26, 228}, {122, 228}, {140, 236}, {40, 236} }, 0.38)
-- rail stub + ties + bumper
for tx = 18, 118, 10 do
  local tie = rect(tx, 225, tx + 5, 230) tone(tie, R_TIMBER) rim(tie, INK)
end
fill(rect(14, 222, 122, 224), R_STEEL[3]) fill(rect(14, 222, 122, 222), R_STEEL[5]) fill(rect(14, 225, 122, 225), R_STEEL[1])
local bump = rect(10, 210, 20, 224)
rim(bump, INK) tone(bump, R_TIMBER, planksH(4, 15))
fill(rect(10, 214, 20, 216), "#b8404a")
-- body
local body = poly{ {28, 184}, {112, 184}, {104, 214}, {36, 214} }
local lip = rect(25, 180, 115, 184)
local ore = poly{ {32, 180}, {42, 170}, {56, 166}, {68, 172}, {84, 164}, {98, 168}, {108, 176}, {110, 180} }
local w1, w2 = oct(46, 216, 7), oct(94, 216, 7)
for _, m in ipairs{ body, lip, ore, w1, w2 } do rim(m, INK) end
tone(ore, R_ORE, rockTex(5, 4, 17))
for _, g in ipairs{ {48, 172}, {78, 170}, {92, 172}, {60, 176} } do set(g[1], g[2], "#f0c860") set(g[1] + 1, g[2], "#c89040") end
tone(body, R_CART, function(x, y, u, v, lx, ly)
  if y == 194 or y == 204 then return nil, 1 end
  if (y == 195 or y == 205) then return 1 end
  if hash(x, y, 19) > 0.93 then return -1 end
  return 0
end, { lu = 0.6, lv = 0.4 })
for rx = 40, 100, 10 do set(rx, 199, R_CART[5]) set(rx + 1, 200, R_CART[1]) end
tone(lip, R_STEEL, nil, { lu = 0.8, lv = 0.2 })
for _, w in ipairs{ {w1, 46}, {w2, 94} } do
  tone(w[1], R_STEEL, function(x, y)
    local dx, dy = abs(x - w[2]), abs(y - 216)
    if dx <= 1 and dy <= 1 then return nil, 5 end
    if dx + dy == 4 then return nil, 1 end
    return 0
  end)
end
-- QUIRK: a crystal sprouting out of the ore load, glowing
glow(74, 156, 16, "#8ee0cc", 0.25)
local cs = { {70, 166}, {72, 148}, {76, 144}, {80, 150}, {80, 166} }
rim(poly(cs), INK) shard(cs, R_AQUA)

---------------------------------------------------------------- 10. CRATES + BARREL + KETTLE (right near)
darken(poly{ {398, 228}, {440, 228}, {456, 232}, {414, 232} }, 0.36)
darken(poly{ {358, 228}, {398, 228}, {410, 233}, {370, 233} }, 0.36)
local crate = rect(358, 190, 396, 228)
rim(crate, INK)
tone(crate, R_PINE, planksH(7, 21), { lu = 0.6, lv = 0.4 })
line({ {360, 226}, {394, 192} }, R_PINE[2], 2) line({ {360, 225}, {393, 192} }, R_PINE[4], 1)
fill(rect(358, 190, 361, 228), R_PINE[2]) fill(rect(393, 190, 396, 228), R_PINE[2])
edgeIn(crate, R_PINE[1])
-- crate icon: a little crystal mark burned in
line({ {373, 206}, {377, 200}, {381, 206}, {377, 212}, {373, 206} }, R_PINE[1], 1)
local barrel = poly{ {405, 186}, {429, 186}, {433, 197}, {434, 207}, {433, 218}, {429, 228}, {405, 228}, {401, 218}, {400, 207}, {401, 197} }
rim(barrel, INK)
tone(barrel, R_BARREL, planksV(5, 22), { lu = 0.7, lv = 0.3 })
for _, yb in ipairs{ 192, 207, 222 } do
  for x = 400, 434 do if barrel:has(x, yb) then set(x, yb, R_STEEL[2]) set(x, yb - 1, barrel:has(x, yb - 1) and R_STEEL[4] or get(x, yb - 1)) end end
end
local lid = rect(405, 184, 429, 187) fill(lid, R_BARREL[4]) edgeIn(lid, R_BARREL[1])
-- QUIRK: a copper kettle with a wisp of steam sitting on the crate
local kb = poly{ {368, 189}, {370, 180}, {384, 180}, {386, 189} }
local spout = poly{ {386, 186}, {392, 180}, {393, 182}, {388, 188} }
rim(kb, INK) rim(spout, INK)
tone(kb, R_COPPER) tone(spout, R_COPPER)
line({ {371, 179}, {373, 175}, {381, 175}, {383, 179} }, R_STEEL[1], 1)
fill(rect(375, 178, 379, 179), R_COPPER[2]) set(372, 182, R_COPPER[5])
set(393, 177, "#e8dcd0") set(394, 175, "#d8ccd0") set(393, 173, "#e8dcd0") set(395, 172, "#d8ccd0")

---------------------------------------------------------------- 11. WILD TRAIL (right edge arch + signpost)
local trail = poly{ {382, 166}, {400, 150}, {426, 136}, {460, 126}, {460, 140}, {432, 150}, {410, 162}, {398, 168} }
trail:each(function(x, y)
  local c = "#b8946a"
  if hash(x, y, 51) > 0.9 then c = "#8e6e50" elseif hash(x, y, 52) > 0.94 then c = "#d8b484" end
  set(x, y, c)
end)
-- bushes either side of the trail
local function bush(x0, y0, x1, y1)
  local m = poly{ {x0, y1}, {x0 + 2, y0 + 4}, {x0 + floor((x1 - x0) * 0.4), y0}, {x1 - 3, y0 + 3}, {x1, y1} }
  rim(m, R_MOSS[1]) tone(m, R_MOSS, function(x, y) local h = hash(floor(x / 3), floor(y / 3), 61) if h > 0.75 then return 1 elseif h < 0.2 then return -1 end return 0 end)
end
bush(384, 140, 410, 152) bush(436, 150, 458, 162)
-- branch arch
local postA = poly{ {416, 150}, {419, 96}, {424, 96}, {423, 146} }
local postB = poly{ {446, 140}, {448, 92}, {453, 92}, {452, 138} }
local bough = poly{ {414, 98}, {424, 88}, {436, 84}, {448, 86}, {456, 92}, {452, 96}, {444, 91}, {436, 90}, {426, 93}, {418, 102} }
for _, m in ipairs{ postA, postB, bough } do rim(m, INK) end
tone(postA, R_TIMBER, planksV(3, 31), { lu = 0.8, lv = 0.2 })
tone(postB, R_TIMBER, planksV(3, 32), { lu = 0.8, lv = 0.2 })
tone(bough, R_TIMBER, nil, { lu = 0.5, lv = 0.5 })
-- leaves on the bough
for i = 0, 13 do
  local lx = 414 + i * 3 + floor(hash(i, 0, 71) * 3)
  local ly = 84 + floor(abs(i - 6) * 0.9) + floor(hash(i, 1, 72) * 4)
  local lm = poly{ {lx, ly + 2}, {lx + 3, ly - 1}, {lx + 5, ly + 2}, {lx + 2, ly + 5} }
  lm:each(function(x, y) set(x, y, (x < lx + 2) and R_MOSS[4] or R_MOSS[3]) end)
  edgeIn(lm, R_MOSS[1])
end
-- hanging wooden star charm
line({ {435, 92}, {435, 104} }, "#c8b090", 1)
local star = poly{ {435, 104}, {437, 108}, {441, 108}, {438, 111}, {439, 115}, {435, 112}, {431, 115}, {432, 111}, {429, 108}, {433, 108} }
rim(star, INK) tone(star, R_BOARD)
-- signpost with arrow board pointing out and a pine icon (sign of the spot)
local sp = rect(394, 114, 397, 162)
rim(sp, INK) tone(sp, R_TIMBER, nil, { lu = 0.9, lv = 0.1 })
local arrow = poly{ {384, 112}, {408, 112}, {414, 118}, {408, 124}, {384, 124} }
rim(arrow, INK) tone(arrow, R_BOARD, planksH(4, 33))
local picon = poly{ {396, 114}, {401, 122}, {391, 122} }
fill(picon, R_MOSS[2]) set(396, 116, R_MOSS[4]) set(395, 117, R_MOSS[4])
line({ {404, 118}, {409, 118} }, R_BOARD[1], 1) set(408, 117, R_BOARD[1]) set(408, 119, R_BOARD[1])
-- QUIRK: a striped sock drying on the signpost
line({ {398, 128}, {402, 128} }, "#c8b090", 1)
local sock = poly{ {399, 129}, {403, 129}, {403, 137}, {407, 138}, {407, 141}, {399, 141} }
rim(sock, INK)
sock:each(function(x, y) set(x, y, ((y // 2) % 2 == 0) and "#5878b8" or "#f0e0c0") end)

---------------------------------------------------------------- 12. GATE FRAME (mine timbers + rock arch)
-- rock overhangs at top corners
local rockL = poly{ {0, 10}, {98, 10}, {84, 18}, {60, 22}, {42, 30}, {30, 44}, {22, 56}, {0, 60} }
local rockR = poly{ {480, 10}, {382, 10}, {396, 18}, {420, 22}, {438, 30}, {450, 44}, {458, 56}, {480, 60} }
for _, m in ipairs{ rockL, rockR } do rim(m, R_ROCK[1]) tone(m, R_ROCK, rockTex(9, 6, 41), { lu = 0.4, lv = 0.6 }) end
-- moss + roots dripping from the overhangs
for _, r in ipairs{ {40, 30, 8}, {60, 22, 6}, {80, 18, 5}, {440, 30, 9}, {420, 22, 6}, {398, 18, 4} } do
  line({ {r[1], r[2]}, {r[1] + 1, r[2] + r[3]} }, R_MOSS[2], 1)
  set(r[1] + 1, r[2] + r[3], R_MOSS[4])
end
for x = 0, 96 do if rockL:has(x, 11) then set(x, 11, R_MOSS[3]) end end
for x = 384, 479 do if rockR:has(x, 11) then set(x, 11, R_MOSS[3]) end end
-- top beam
local beam = rect(0, 0, 479, 10)
tone(beam, R_TIMBER, planksH(5, 42), { lu = 0.5, lv = 0.5 })
fill(rect(0, 10, 479, 10), INK)
for bx = 30, 470, 60 do set(bx, 4, R_STEEL[5]) set(bx + 1, 5, R_STEEL[1]) end
-- side posts: left full height on a boulder, right stops on a boulder above the calm corner
local pL = rect(0, 0, 21, 269)
local pR = rect(458, 0, 479, 226)
rim(pL, INK) rim(pR, INK)
tone(pL, R_TIMBER, planksV(5, 43), { lu = 0.9, lv = 0.1 })
tone(pR, R_TIMBER, planksV(5, 44), { lu = 0.9, lv = 0.1 })
for _, yb in ipairs{ 70, 170 } do
  fill(rect(0, yb, 21, yb + 3), R_STEEL[3]) fill(rect(0, yb, 21, yb), R_STEEL[4])
  fill(rect(458, yb, 479, yb + 3), R_STEEL[3]) fill(rect(458, yb, 479, yb), R_STEEL[4])
  set(10, yb + 2, R_STEEL[5]) set(468, yb + 2, R_STEEL[5])
end
local bL = poly{ {0, 238}, {14, 232}, {30, 236}, {36, 250}, {34, 270}, {0, 270} }
local bR = poly{ {446, 226}, {452, 214}, {466, 210}, {480, 212}, {480, 228} }
for _, m in ipairs{ bL, bR } do rim(m, INK) tone(m, R_ROCK, rockTex(7, 5, 45)) end
for x = 0, 34 do if bL:has(x, 234) or bL:has(x, 237) then end end
-- hanging lanterns
local function hangLantern(cx, top)
  glow(cx, top + 22, 24, WARM, 0.3)
  for y = 11, top + 9 do set(cx, y, (y % 3 == 0) and R_STEEL[2] or R_STEEL[1]) end
  local cap = poly{ {cx - 4, top + 14}, {cx, top + 10}, {cx + 5, top + 14} }
  local body = rect(cx - 6, top + 14, cx + 6, top + 30)
  rim(body, INK) rim(cap, INK)
  fill(cap, R_STEEL[2]) set(cx, top + 11, R_STEEL[4])
  fill(body, "#3a2c2a")
  fill(rect(cx - 4, top + 16, cx + 4, top + 28), "#f5a54a")
  fill(rect(cx - 3, top + 17, cx + 1, top + 26), WARM)
  set(cx - 1, top + 21, "#fff0c0") set(cx - 1, top + 22, "#fff0c0")
  line({ {cx, top + 16}, {cx, top + 28} }, "#3a2c2a", 1)
  fill(rect(cx - 7, top + 29, cx + 7, top + 31), R_STEEL[2])
end
hangLantern(62, 14)
hangLantern(418, 14)
-- hanging crystal charm at the top centre
line({ {240, 11}, {240, 22} }, "#c8b090", 1)
glow(240, 27, 8, "#8ee0cc", 0.25)
local ch = { {237, 22}, {243, 22}, {245, 26}, {240, 33}, {235, 26} }
rim(poly(ch), INK) shard(ch, R_AQUA)

---------------------------------------------------------------- 13. small grass tufts (away from stand points)
local STAND = { {178, 178}, {302, 178}, {150, 214}, {330, 214}, {165, 252}, {325, 252} }
local function nearStand(x, y) for _, s in ipairs(STAND) do if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 < 34 * 34 then return true end end return false end
for i = 1, 40 do
  local x = 30 + floor(hash(i, 0, 81) * 420)
  local y = 152 + floor(hash(i, 1, 82) * 110)
  local free = not path:has(x, y) and not nearStand(x, y) and not (x > 372 and y > 226)
      and not (x < 140 and y > 160 and y < 238) and not (x > 352 and x < 445 and y > 170 and y < 234)
  if free and get(x, y):sub(1, 3) ~= "#2b" then
    set(x, y, R_MOSS[2]) set(x - 1, y - 1, R_MOSS[3]) set(x + 1, y - 2, R_MOSS[4]) set(x + 2, y - 1, R_MOSS[3])
  end
end

---------------------------------------------------------------- v2.5.40 polish setup
local function protectedPx(x, y)
  if x >= 380 and x < 480 and y >= 230 then return true end
  for _, s in ipairs(STAND) do if abs(x - s[1]) <= 17 and abs(y - s[2]) <= 17 then return true end end
  return false
end
local function sp(x, y, c)  -- guarded set: never inside stand / compass zones
  if x < 0 or x >= W or y < 0 or y >= H or protectedPx(x, y) then return end
  set(x, y, c)
end
local function spRect(x0, y0, x1, y1, c) for y = y0, y1 do for x = x0, x1 do sp(x, y, c) end end end
local function spFill(m, c) m:each(function(x, y) sp(x, y, c) end) end
local function spRim(m, c)
  local r = {}
  m:each(function(x, y)
    for _, d in ipairs{ {1, 0}, {-1, 0}, {0, 1}, {0, -1} } do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) then r[#r + 1] = { nx, ny } end
    end
  end)
  for _, q in ipairs(r) do sp(q[1], q[2], c) end
end
local function spLine(x0, y0, x1, y1, c)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do sp(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
end
-- ground mask: flood fill over dirt-coloured pixels (ink outlines of props stop it)
local function isDirt(x, y)
  local r, g, b = hx(get(x, y))
  return r >= 100 and r <= 185 and g >= 70 and g <= 135 and b >= 40 and b <= 100 and r > g and g > b and (r - b) >= 40 and (r - b) <= 90
end
local gm = mask()
do
  local stack = { {60, 172}, {60, 250}, {130, 200}, {200, 150}, {350, 150}, {360, 250}, {420, 190}, {250, 152}, {140, 160} }
  while #stack > 0 do
    local q = table.remove(stack)
    local x, y = q[1], q[2]
    if y >= 138 and not gm:has(x, y) and x >= 0 and x < W and y < H and isDirt(x, y) and not path:has(x, y) then
      gm:add(x, y)
      stack[#stack + 1] = { x + 1, y } stack[#stack + 1] = { x - 1, y }
      stack[#stack + 1] = { x, y + 1 } stack[#stack + 1] = { x, y - 1 }
    end
  end
end
local DIRT = { "#6b4c3a", "#82583e", "#93703f", "#a8803f", "#b99356", "#c8a368" }
local function gset(x, y, c) if gm:has(x, y) then sp(x, y, c) end end
local function gtone(x, y, t) if gm:has(x, y) then sp(x, y, mix(get(x, y), t[1], t[2])) end end
---------------------------------------------------------------- v2.5.40 polish pass 1 (ground variety, worn paths, flowers, pebbles)
-- broad dithered bands of lighter sun-baked dirt and darker damp dirt (3 tones)
for y = 140, 269 do for x = 0, 479 do
  if gm:has(x, y) then
    local nx, ny = floor(x / 6), floor(y / 4)
    local n = hash(nx, ny, 301) * 0.6 + hash(floor(x / 18), floor(y / 11), 302) * 0.7
    local chk = ((x + y) % 2 == 0)
    if n > 1.0 and chk then sp(x, y, mix(get(x, y), "#c8a368", 0.45))
    elseif n < 0.38 and chk then sp(x, y, mix(get(x, y), "#5c4234", 0.4)) end
  end
end end
-- worn footpaths from the left shed door and the right trail down toward the road
local function worn(pts)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for k = 0, n do
      local x = floor(a[1] + (b[1] - a[1]) * k / n + 0.5)
      local y = floor(a[2] + (b[2] - a[2]) * k / n + 0.5)
      for w = -2, 2 do
        local c = (abs(w) == 2) and ((x + y) % 2 == 0) or abs(w) < 2
        if c then gset(x + w, y, mix(get(x + w, y), "#d2b27a", (abs(w) == 2) and 0.3 or 0.5)) end
      end
      if hash(x, y, 303) > 0.82 then gset(x + floor(hash(x, y, 304) * 5) - 2, y, "#7a5640") end
    end
  end
end
worn{ {96, 150}, {112, 160}, {124, 170}, {132, 180} }
worn{ {360, 152}, {352, 162}, {346, 176}, {344, 190} }
worn{ {120, 238}, {140, 232}, {150, 228} }
-- pebbles (2-3 px, lit top-left, shadow lower-right)
local function pebble(x, y, big)
  if not gm:has(x, y) or not gm:has(x + 2, y + 1) then return end
  sp(x + 1, y + 1, "#4a3830") sp(x + 2, y + 1, "#4a3830")
  sp(x, y, "#a89a8a") sp(x + 1, y, "#8d7f72")
  if big then sp(x, y - 1, "#c4b8a4") sp(x + 1, y - 1, "#a89a8a") sp(x + 2, y, "#6e6258") end
end
for _, p in ipairs{ {40,176,1},{70,160,0},{104,206,0},{122,196,1},{88,230,0},{60,244,0},{128,158,0},{196,160,0},{246,156,1},
  {352,196,0},{372,182,1},{398,160,0},{436,194,0},{368,242,0},{356,228,1},{420,222,0},{214,150,0},{286,153,0},{40,206,0},{112,252,1} } do
  pebble(p[1], p[2], p[3] == 1)
end
-- little flowers (3 kinds: yellow daisy, violet bell, red poppy) with leaves
local function flower(x, y, kind)
  if not gm:has(x, y) then return end
  sp(x, y + 1, R_MOSS[2]) sp(x, y + 2, R_MOSS[1]) sp(x - 1, y + 2, R_MOSS[3]) sp(x + 1, y + 1, R_MOSS[3])
  if kind == 1 then
    sp(x, y - 1, "#f7e07a") sp(x - 1, y, "#fff3c4") sp(x + 1, y, "#fff3c4") sp(x, y, "#e8a030") sp(x, y + 1 - 1, "#e8a030")
  elseif kind == 2 then
    sp(x - 1, y - 1, "#b48ae0") sp(x, y - 1, "#8a5cc0") sp(x, y, "#5a3c8a") sp(x - 1, y, "#8a5cc0")
  else
    sp(x - 1, y, "#d0584a") sp(x + 1, y, "#d0584a") sp(x, y - 1, "#e8745a") sp(x, y, "#ffd27a")
  end
end
for i, f in ipairs{ {52,168,1},{92,178,2},{118,214,3},{46,196,2},{132,236,1},{74,252,3},{196,158,2},{262,154,1},
  {354,210,3},{388,176,1},{372,222,2},{434,172,3},{346,246,1},{100,160,3},{222,150,3},{128,222,2} } do flower(f[1], f[2], f[3]) end
-- scattered fallen leaves (brown-gold)
for i = 1, 26 do
  local x = floor(hash(i, 3, 311) * 480) local y = 146 + floor(hash(i, 4, 312) * 120)
  if gm:has(x, y) and gm:has(x + 1, y) then sp(x, y, "#a8602e") sp(x + 1, y, "#d48a3c") end
end

---------------------------------------------------------------- v2.5.40 polish pass 2 (material cues: strata, chips, lichen, rust, ore glints)
local rockSet = {}
for _, t in ipairs{ R_ROCK, R_ROCKF } do for _, c in ipairs(t) do rockSet[c] = true end end
local function onRock(x, y) return rockSet[get(x, y)] == true end
local function rset(x, y, c) if onRock(x, y) then sp(x, y, c) end end
-- cracks: short wandering dark fissures with a lit lower lip
local function crack(x, y, len, dir, seed)
  for i = 1, len do
    rset(x, y, R_ROCK[1]) rset(x + 1, y + 1, R_ROCK[4])
    local h = hash(x, y, seed)
    if h < 0.45 then y = y + 1 elseif h < 0.75 then x = x + dir else y = y + 1 x = x + dir end
  end
end
for i, c in ipairs{ {150,92,12,1},{168,74,9,1},{160,118,10,-1},{214,64,8,-1},{256,62,9,1},{312,88,12,-1},
  {330,112,9,1},{135,128,8,1},{302,132,8,-1},{185,136,7,1},{338,78,8,-1} } do crack(c[1], c[2], c[3], c[4], 400 + i) end
-- strata: thin darker bedding lines broken into dashes, lit line just below
for _, st in ipairs{ {140,104,34},{300,98,40},{150,138,26},{312,124,30},{164,82,22},{290,72,26} } do
  for x = st[1], st[1] + st[3] do
    if hash(x, st[2], 410) > 0.3 then rset(x, st[2], R_ROCK[2]) end
    if hash(x, st[2], 411) > 0.6 then rset(x, st[2] + 1, R_ROCK[4]) end
  end
end
-- chips: small pale scars where stone broke off (top-left facets lit, lower-right dark)
for i, c in ipairs{ {146,84},{176,112},{196,70},{268,66},{322,100},{340,126},{138,116},{306,70},{244,58},{176,98},{320,140},{150,140} } do
  local x, y = c[1], c[2]
  rset(x, y, R_ROCK[5]) rset(x + 1, y, R_ROCK[4]) rset(x, y + 1, R_ROCK[4])
  rset(x + 1, y + 1, R_ROCK[1]) rset(x + 2, y + 1, R_ROCK[1]) rset(x + 2, y, R_ROCK[2])
end
-- lichen on the north (top) faces: pale grey-green patches
local function lichen(x, y, w)
  for k = 0, w - 1 do
    for r = 0, 1 do
      if hash(x + k, y + r, 420) > 0.25 then rset(x + k, y + r, (k + r) % 2 == 0 and "#9db08a" or "#c4cfa6") end
    end
    if hash(x + k, y, 421) > 0.55 then rset(x + k, y + 2, "#7c9070") end
  end
end
lichen(156, 62, 7) lichen(232, 54, 6) lichen(300, 60, 8) lichen(333, 90, 5) lichen(128, 90, 5) lichen(222, 126, 5)
-- ore glints in the stone: gold fleck with a tiny sparkle cross
local function glint(x, y)
  rset(x, y, "#ffd27a") rset(x - 1, y, "#c98a3a") rset(x + 1, y, "#c98a3a")
  rset(x, y - 1, "#c98a3a") rset(x, y + 1, "#a06a30")
end
glint(158, 100) glint(328, 106) glint(172, 130) glint(311, 118) glint(206, 92) glint(266, 98)
-- rust streaks dripping under the iron bands on the mine posts (timbers)
local function rustDrip(x0, x1, y)
  for x = x0, x1 do
    local len = 2 + floor(hash(x, y, 430) * 4)
    for k = 0, len do
      local c = (k < 2) and "#7a3a28" or ((k < len) and "#5e3022" or "#a35a3a")
      if hash(x, y + 9, 431) > 0.3 then sp(x, y + 1 + k, c) end
    end
  end
end
rustDrip(191, 203, 90) rustDrip(191, 203, 129) rustDrip(279, 291, 90) rustDrip(279, 291, 129)
-- timber grain: short dark checks and one lit knot per post
for _, post in ipairs{ {192, 202}, {280, 290} } do
  for i = 0, 5 do
    local y = 76 + i * 9
    local x = post[1] + floor(hash(i, post[1], 440) * (post[2] - post[1] - 2))
    sp(x, y, R_TIMBER[1]) sp(x + 1, y, R_TIMBER[1]) sp(x, y + 1, R_TIMBER[2])
    if i % 3 == 1 then sp(x + 3, y + 2, R_TIMBER[5]) end
  end
end
-- iron bands: bright rivet heads and a rust bloom
for _, b in ipairs{ {191,86},{191,125},{279,86},{279,125} } do
  for k = 0, 11, 4 do sp(b[1] + k, b[2], R_STEEL[5]) end
  sp(b[1] + 2, b[2] + 1, "#7a3a28") sp(b[1] + 7, b[2] + 1, "#a35a3a")
end
-- mine-mouth lintel: split-wood checks and a nail streak
for x = 190, 290, 11 do sp(x, 61, R_TIMBER[1]) sp(x + 1, 61, R_TIMBER[1]) sp(x + 2, 62, R_TIMBER[2]) end

---------------------------------------------------------------- v2.5.40 polish pass 3 (lived-in props)
local BURLAP = { "#4e3a2a", "#7e6240", "#b08e58", "#d2b478", "#ecd49a" }
local function castShadow(m, t)  -- shade ground under a prop's footprint (falls lower-right)
  m:each(function(x, y) if gm:has(x, y) and onRock(x, y) == false then sp(x, y, mix(get(x, y), "#3a2d4a", t or 0.45)) end end)
end
local function shadowStrip(x0, y0, len, hgt)  -- parallelogram sheared right
  local pts = {}
  local m = mask()
  for r = 0, hgt - 1 do for x = x0 + r, x0 + r + len do m:add(x, y0 + r) end end
  castShadow(m, 0.5)
end
-- ore sack
local function sack(x, y, w, h, seed)
  local body = poly{ {x + 2, y + 2}, {x + w - 2, y + 2}, {x + w, y + 6}, {x + w, y + h - 1}, {x + w - 2, y + h}, {x + 2, y + h}, {x, y + h - 1}, {x, y + 6} }
  local neck = poly{ {x + floor(w / 2) - 2, y}, {x + floor(w / 2) + 3, y}, {x + floor(w / 2) + 4, y + 3}, {x + floor(w / 2) - 3, y + 3} }
  shadowStrip(x + 3, y + h - 2, w, 3)
  spRim(body, INK) spRim(neck, INK)
  spFill(body, BURLAP[3]) spFill(neck, BURLAP[3])
  body:each(function(px, py)
    local rx, ry = px - x, py - y
    if rx >= w - 3 or ry >= h - 2 then sp(px, py, BURLAP[2])
    elseif rx <= 2 and ry > 4 and ry < h - 3 then sp(px, py, BURLAP[4])
    elseif hash(px, py, seed) > 0.8 then sp(px, py, BURLAP[2]) end
  end)
  for k = 0, 4 do sp(x + floor(w / 2) - 2 + k, y + 3, (k % 2 == 0) and "#7a3a28" or "#a35a3a") end  -- cord tie
  sp(x + 2, y + 7, BURLAP[5]) sp(x + 3, y + 7, BURLAP[5])
  -- spilled ore fleck + stitch
  sp(x + floor(w / 2), y + floor(h / 2), "#5f5468") sp(x + floor(w / 2) + 1, y + floor(h / 2), "#a598a8")
  for k = 0, 2 do sp(x + w - 5, y + 8 + k * 3, BURLAP[1]) end
end
sack(44, 243, 17, 19, 501) sack(63, 249, 15, 15, 502) sack(54, 233, 14, 14, 503)
-- tailings pile (little scree hill of broken rock with a dark seam and a few ore sparks)
do
  local pile = poly{ {88, 266}, {94, 258}, {104, 252}, {114, 250}, {124, 256}, {130, 266} }
  shadowStrip(110, 264, 22, 3)
  spRim(pile, INK)
  pile:each(function(x, y)
    local d = (x - 100) * 0.5 + (y - 250) * 0.9
    local h = hash(floor(x / 2), floor(y / 2), 510)
    local c = R_ROCK[3]
    if d > 8 then c = R_ROCK[2] elseif d < -2 then c = R_ROCK[4] end
    if h > 0.82 then c = R_ROCK[5] elseif h < 0.16 then c = R_ROCK[1] end
    sp(x, y, c)
  end)
  sp(102, 255, "#ffd27a") sp(119, 259, "#ffd27a") sp(110, 262, "#8ee0cc")
  for _, q in ipairs{ {85,265},{132,265},{128,267},{90,268} } do sp(q[1], q[2], R_ROCK[3]) sp(q[1] + 1, q[2], R_ROCK[1]) end
end
-- rope coil lying on the ground
do
  local x, y = 119, 192
  shadowStrip(x + 3, y + 7, 12, 3)
  local ring = poly{ {x + 3, y}, {x + 11, y}, {x + 14, y + 3}, {x + 14, y + 5}, {x + 11, y + 8}, {x + 3, y + 8}, {x, y + 5}, {x, y + 3} }
  spRim(ring, INK) spFill(ring, "#b89a62")
  for k = 0, 7 do for r = 0, 14 do
    if ring:has(x + r, y + k) then
      local band = (k + floor(r / 3)) % 2
      sp(x + r, y + k, (band == 0) and "#d2b478" or "#9a7a48")
    end
  end end
  local hole = poly{ {x + 5, y + 3}, {x + 9, y + 3}, {x + 9, y + 5}, {x + 5, y + 5} }
  spFill(hole, "#4e3a2a")
  sp(x + 2, y + 1, "#ecd49a") sp(x + 4, y, "#ecd49a")
  spLine(x + 12, y + 6, x + 16, y + 9, "#9a7a48") sp(x + 17, y + 9, "#7e6240")  -- loose end
end
-- lantern on a post (right, beside the crates)
do
  local x = 350
  shadowStrip(x + 2, 188, 14, 3)
  spRect(x - 1, 160, x + 3, 188, INK)
  for y = 161, 187 do
    sp(x, y, R_TIMBER[4]) sp(x + 1, y, R_TIMBER[3]) sp(x + 2, y, R_TIMBER[2]) sp(x + 3, y, R_TIMBER[1])
    if y % 6 == 0 then sp(x + 1, y, R_TIMBER[2]) end
  end
  spRect(x - 3, 186, x + 5, 188, R_ROCK[3]) spRim(rect(x - 3, 186, x + 5, 188), INK)
  -- bracket arm to the left, lantern hanging
  spRect(x - 9, 161, x, 162, INK) spRect(x - 8, 161, x, 161, R_TIMBER[3])
  spRect(x - 8, 162, x - 8, 165, INK) 
  local body = rect(x - 12, 166, x - 5, 176)
  spRim(body, INK) spFill(body, "#3a2c2a")
  spFill(rect(x - 11, 167, x - 6, 175), "#f5a54a") spFill(rect(x - 11, 168, x - 8, 173), WARM)
  sp(x - 10, 169, "#fff0c0") sp(x - 10, 170, "#fff0c0")
  spRect(x - 13, 165, x - 4, 165, R_STEEL[2]) spRect(x - 13, 177, x - 4, 177, R_STEEL[2])
  sp(x - 8, 164, R_STEEL[2])
end
-- tool lean-to by the right gate post: two pickaxes and a shovel
do
  local function handle(x0, y0, x1, y1)
    spLine(x0 - 1, y0, x1 - 1, y1, INK) spLine(x0 + 2, y0, x1 + 2, y1, INK)
    spLine(x0, y0, x1, y1, R_TIMBER[4]) spLine(x0 + 1, y0, x1 + 1, y1, R_TIMBER[2])
  end
  shadowStrip(440, 207, 18, 3)
  -- pickaxe 1
  handle(442, 208, 448, 178)
  spLine(441, 177, 455, 175, INK) spLine(441, 178, 455, 176, INK)
  spLine(442, 177, 454, 175, R_STEEL[4]) spLine(443, 178, 453, 176, R_STEEL[2])
  sp(441, 177, R_STEEL[5]) sp(455, 175, R_STEEL[3])
  -- pickaxe 2 (leaning the other way, shorter)
  handle(452, 208, 447, 182)
  spLine(445, 181, 441, 185, INK) spLine(446, 180, 451, 182, INK)
  spLine(446, 181, 452, 183, R_STEEL[3]) sp(445, 182, R_STEEL[5])
  -- shovel
  handle(436, 209, 434, 186)
  local blade = poly{ {430, 178}, {438, 178}, {439, 183}, {436, 187}, {433, 187}, {430, 183} }
  spRim(blade, INK) spFill(blade, R_STEEL[3])
  spFill(rect(431, 179, 432, 183), R_STEEL[5]) spFill(rect(437, 182, 438, 183), R_STEEL[1])
  spRect(433, 188, 436, 188, R_TIMBER[1])
end
-- signal flag on a pole near the shed
do
  local x = 130
  shadowStrip(x + 2, 168, 12, 3)
  spRect(x - 1, 140, x + 2, 168, INK)
  for y = 141, 167 do sp(x, y, R_TIMBER[4]) sp(x + 1, y, R_TIMBER[2]) end
  spRect(x - 2, 166, x + 3, 168, R_ROCK[3]) spRim(rect(x - 2, 166, x + 3, 168), INK)
  local fl = poly{ {x + 2, 141}, {x + 16, 143}, {x + 13, 148}, {x + 17, 153}, {x + 2, 152} }
  spRim(fl, INK)
  fl:each(function(px, py)
    local band = floor((py - 141) / 4)
    sp(px, py, (band == 1) and "#f0d49a" or "#c9473a")
    if px - x < 4 then sp(px, py, (band == 1) and "#fff0c0" or "#e8745a") end
    if px - x > 12 and band ~= 1 then sp(px, py, "#8e2f30") end
  end)
  sp(x, 139, R_STEEL[4]) sp(x + 1, 139, R_STEEL[3]) sp(x, 140, R_STEEL[3])
end

---------------------------------------------------------------- v2.5.40 polish pass 4 (light, depth, flora)
-- warm lantern light spilling on stone and dirt: stepped rings, checker edge, no gradients
local function warmGlow(cx, cy, r, amt)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = abs(x - cx) + abs(y - cy) * 1.25
    if d <= r * 1.35 and (onRock(x, y) or gm:has(x, y)) then
      local t = (d < r * 0.55) and amt or ((d < r * 0.95) and amt * 0.6 or ((x + y) % 2 == 0 and amt * 0.4 or 0))
      if t > 0 then sp(x, y, mix(get(x, y), WARM, t)) end
    end
  end end
end
warmGlow(338, 170, 14, 0.30)     -- lantern post: lights crate top, dirt and stone
warmGlow(183, 88, 12, 0.28)      -- lantern on the mine post
-- far things lighter and cooler: dithered haze over distant ridge and hills behind the mouth/shed
for y = 92, 124 do for x = 0, 479 do
  local r, g, b = hx(get(x, y))
  if b > r and b >= g + 8 and r < 110 then
    local t = (y < 108) and 0.30 or 0.18
    if (x + y) % 2 == 0 then sp(x, y, mix(get(x, y), "#b49ccb", t)) end
  end
end end
-- rim light (upper-left key) on main props: crate, barrel, cart, signal pole, lantern post
for x = 358, 396 do local r = hx(get(x, 190)) if r > 120 then sp(x, 190, mix(get(x, 190), "#fff0c0", 0.4)) end end
for y = 191, 228 do if get(358, y) ~= INK then sp(358, y, mix(get(358, y), "#fff0c0", 0.3)) end end
for y = 176, 222 do local c = get(401, y) if c ~= INK then sp(401, y, mix(c, "#ffd9a0", 0.35)) end end
for x = 404, 418 do local c = get(x, 163 + 14) end
for x = 30, 110 do local c = get(x, 150 + 25) end
-- cart top-rim glint
for x = 28, 60 do local c = get(x, 176) if c == R_STEEL[3] or c == R_STEEL[4] then sp(x, 176, R_STEEL[5]) end end
-- foreground plants (3 kinds): fern fronds, thistle, berry shrub
local function fern(x, y, h)
  for k = 0, h do
    sp(x, y - k, R_MOSS[1] and "#3f5a30")
  end
  for k = 2, h, 2 do
    local w = floor((h - k) * 0.45) + 2
    for i = 1, w do
      sp(x - i, y - k - floor(i * 0.5), (i % 2 == 0) and R_MOSS[2] or R_MOSS[3])
      sp(x + i, y - k - floor(i * 0.5) + 1, (i % 2 == 0) and R_MOSS[1] or R_MOSS[2])
    end
    sp(x - w, y - k - floor(w * 0.5), R_MOSS[4])
  end
  sp(x, y - h - 1, R_MOSS[4])
end
fern(140, 266, 16) fern(144, 258, 9) fern(137, 250, 8)
local function thistle(x, y)
  for k = 0, 8 do sp(x, y - k, "#3f5a30") end
  sp(x - 2, y - 3, "#6b8a40") sp(x - 1, y - 4, "#4d6a36") sp(x + 2, y - 5, "#6b8a40") sp(x + 1, y - 6, "#4d6a36")
  sp(x - 1, y - 9, "#b48ae0") sp(x, y - 10, "#d8b8f0") sp(x + 1, y - 9, "#8a5cc0") sp(x - 1, y - 10, "#8a5cc0") sp(x + 1, y - 10, "#b48ae0")
  sp(x, y - 9, "#5a3c8a")
end
thistle(441, 228) thistle(438, 223)
local function berryShrub(x, y, w)
  local m = poly{ {x, y}, {x + 3, y - 5}, {x + w / 2, y - 8}, {x + w - 3, y - 5}, {x + w, y}, {x + w - 2, y + 2}, {x + 2, y + 2} }
  spRim(m, "#2a3a26")
  m:each(function(px, py)
    local h = hash(px, py, 601)
    local c = R_MOSS[2]
    if py - y < -4 or (px - x) < 3 then c = R_MOSS[3] elseif py - y > 0 then c = R_MOSS[1] end
    if h > 0.85 then c = R_MOSS[4] elseif h < 0.12 then c = R_MOSS[1] end
    sp(px, py, c)
  end)
  for _, b in ipairs{ {x + 4, y - 2}, {x + w - 5, y - 3}, {x + floor(w / 2), y - 1} } do sp(b[1], b[2], "#c9473a") sp(b[1], b[2] - 1, "#f08a6a") end
  castShadow(rect(x + 3, y + 3, x + w + 3, y + 4), 0.5)
end
berryShrub(354, 244, 17)
-- moss bunches in damp lee of the boulders
for _, q in ipairs{ {2,238},{10,236},{22,233},{448,214},{458,212} } do
  for i = 0, 3 do if onRock(q[1] + i, q[2]) then sp(q[1] + i, q[2], (i % 2 == 0) and R_MOSS[3] or R_MOSS[4]) end end
end
-- tall grass blades by the timber posts (foreground frame, never over a spot)
for _, g in ipairs{ {28,200},{31,206},{27,214},{116,160},{343,200},{346,256},{120,266} } do
  for k = 0, 4 do sp(g[1] + floor(k / 3), g[2] - k, (k % 2 == 0) and R_MOSS[3] or R_MOSS[2]) end
  sp(g[1] - 1, g[2] - 3, R_MOSS[4]) sp(g[1] + 2, g[2] - 4, R_MOSS[4])
end

---------------------------------------------------------------- 14. write canvas + layout
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
for y = 0, H - 1 do for x = 0, W - 1 do c:px(x, y, buf[y * W + x + 1] or "#3b2f5e") end end
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { k = "mouth", name = "Delve Mouth", box = { 176, 30, 304, 152 } },
  { k = "wild", name = "Wild Trail", box = { 382, 82, 458, 168 } },
}
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}',
    s.k, s.name, floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, s in ipairs(STAND) do st[#st + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":%d,"h":%d,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n',
  W, H, HORIZON, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok " .. NAME)

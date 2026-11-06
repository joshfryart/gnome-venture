-- Mossbottom: gate view, hero scale, dusk. 480x270 native.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params["out"]) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local NAME = "here-town-mossbottom"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, abs, sqrt = math.floor, math.sin, math.abs, math.sqrt
local VPX, VPY, HOR = 240, 112, 118

local function hsh(x, y, s) local v = sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453 return v - floor(v) end
local function px(x, y, col) if x >= 0 and y >= 0 and x < W and y < H then c:px(x, y, col) end end
local function tex(m, fn) m:each(function(x, y) local col = fn(x, y) if col then px(x, y, col) end end) end
local function R(d, s, b, l, h) return { d = d, s = s, b = b, l = l, h = h } end
local function inCompass(x, y) return x >= 376 and y >= 226 end

-- texture painters --------------------------------------------------------
local function stoneTex(Rm, bw, bh, seed, shade)
  return function(x, y)
    local row = floor(y / bh); local off = (row % 2) * floor(bw / 2)
    local col = floor((x + off) / bw); local lx = (x + off) % bw; local ly = y % bh
    if lx == 0 or ly == 0 then
      if hsh(x, y, seed) < 0.12 then return "#5f8f46" end
      return shade and Rm.d or Rm.s
    end
    local v = hsh(col, row, seed)
    local t = v < 0.25 and Rm.l or (v < 0.85 and Rm.b or Rm.s)
    if ly == 1 and lx <= 2 then t = Rm.h end
    if ly == bh - 1 then t = Rm.s end
    if shade then t = (t == Rm.h or t == Rm.l) and Rm.b or Rm.s end
    return t
  end
end
local function plankTex(Rm, pw, seed, shade)
  return function(x, y)
    local lx = x % pw; local k = floor(x / pw)
    if lx == 0 then return Rm.d end
    local t = (lx == 1) and Rm.l or Rm.b
    if lx == pw - 1 then t = Rm.s end
    local g = hsh(k, floor(y / 2), seed)
    if g < 0.12 then t = Rm.s elseif g > 0.94 then t = Rm.l end
    if (y + k * 7) % 19 == 0 then t = Rm.d end
    if shade then t = (t == Rm.l or t == Rm.h) and Rm.b or (t == Rm.d and Rm.d or Rm.s) end
    return t
  end
end
local function shingleTex(Rm, sw, sh, y0, ridgeX, seed)
  return function(x, y)
    local row = floor((y - y0) / sh); local off = (row % 2) * floor(sw / 2)
    local lx = (x + off) % sw; local ly = (y - y0) % sh
    local left = x < ridgeX
    if ly == sh - 1 then return Rm.d end
    if lx == 0 then return left and Rm.s or Rm.d end
    local v = hsh(floor((x + off) / sw), row, seed)
    if ly == 0 then return left and Rm.h or Rm.b end
    if left then return v < 0.25 and Rm.h or Rm.l end
    return v < 0.25 and Rm.b or Rm.s
  end
end
local function thatchTex(Rm, seed)
  return function(x, y)
    local row = floor(y / 6); local ly = y % 6
    local v = hsh(x, row, seed)
    if ly == 5 then return Rm.d end
    if hsh(floor(x / 9), row, seed + 3) < 0.22 and ly < 4 then return (v < 0.5) and "#4f8a3e" or "#6aa24c" end
    if v < 0.18 then return Rm.s elseif v < 0.3 then return Rm.h elseif v < 0.6 then return Rm.l end
    return Rm.b
  end
end
local function domeTex(Rm, cx, yb, rx, hh, seed)
  return function(x, y)
    local nx = (x - cx) / rx; local ny = (yb - y) / hh
    local v = 0.5 - nx * 0.38 + ny * 0.42 + (hsh(x, y, seed) - 0.5) * 0.1
    if yb - y < 3 then v = v - 0.3 end
    if v < 0.32 then return Rm.s elseif v < 0.62 then return Rm.b elseif v < 0.86 then return Rm.l end
    return Rm.h
  end
end
local function dome(cx, yb, rx, hh, pw)
  local pts = {}
  for i = 0, 32 do
    local t = -1 + 2 * i / 32
    pts[#pts + 1] = { floor(cx + rx * t + 0.5), floor(yb - hh * (1 - t * t) ^ (pw or 0.55) + 0.5) }
  end
  return c:poly(pts)
end
local function window(x0, y0, x1, y1, arch, frame)
  frame = frame or "#4a2e22"
  local m
  if arch then
    local r = (x1 - x0) / 2
    m = c:rect(x0, floor(y0 + r), x1, y1); m:add(c:ellipse((x0 + x1) / 2, y0 + r, r, r))
  else m = c:rect(x0, y0, x1, y1) end
  c:fillMask(m, frame)
  local midx, midy = floor((x0 + x1) / 2), floor((y0 + y1) / 2) + 1
  tex(m:shrink(1), function(x, y)
    if x == midx or y == midy then return "#9a5a34" end
    if (x - x0) + (y - y0) < 6 then return "#fff0b0" end
    if (x1 - x) + (y1 - y) < 5 then return "#f0a04c" end
    return "#ffd06a"
  end)
  for x = x0 - 1, x1 + 1 do px(x, y1 + 1, "#6c6478") end
  return m
end
local function door(x0, y0, x1, y1, Rm, arch)
  local m
  if arch then
    local r = (x1 - x0) / 2
    m = c:rect(x0, floor(y0 + r), x1, y1); m:add(c:ellipse((x0 + x1) / 2, y0 + r, r, r))
  else m = c:rect(x0, y0, x1, y1) end
  tex(m, plankTex(Rm, 3, 5))
  c:edgeIn(m, Rm.d)
  px(x1 - 2, floor((y0 + y1) / 2) + 2, "#f2c450"); px(x1 - 3, floor((y0 + y1) / 2) + 2, "#b08030")
  return m
end
local function obj(m, fn, edge) tex(m, fn) if edge then c:edgeIn(m, edge) end return m end

-- 1 SKY ---------------------------------------------------------------------
c:stripes(0, HOR - 1, { "#2a2350", "#38295c", "#4f3268", "#6c3d76", "#8f4b7e", "#b75a7e", "#d8727a", "#eb9674", "#f5ba78" },
  { 3, 3, 3, 3, 3, 2, 2, 2, 2 })
for i = 1, 46 do
  local x = floor(hsh(i, 1) * 470) + 5; local y = floor(hsh(i, 2) * 40) + 16
  px(x, y, "#f6e8c8")
  if i % 7 == 0 then px(x - 1, y, "#b8a6d0"); px(x + 1, y, "#b8a6d0"); px(x, y - 1, "#b8a6d0"); px(x, y + 1, "#b8a6d0") end
end
c:cloud(18, 74, 58, "#f2b0a8", "#b46a86")
c:cloud(96, 44, 40, "#e89aa6", "#a45e82")
c:cloud(318, 52, 66, "#f2b0a8", "#b46a86")
c:cloud(404, 86, 46, "#f8c8a0", "#c87a84")
c:cloud(150, 100, 34, "#f8c8a0", "#c87a84")
c:cloud(250, 30, 30, "#c47e9a", "#8a4e7a")

-- 2 HILLS -------------------------------------------------------------------
local f1 = function(x) return floor(90 + 6 * sin(x / 38) + 4 * sin(x / 14 + 1)) end
local f2 = function(x) return floor(101 + 5 * sin(x / 27 + 2) + 3 * sin(x / 9)) end
local f3 = function(x) return floor(110 + 3 * sin(x / 19 + 0.5)) end
c:terrain(f1, "#6c5c8e", HOR)
for x = 0, W - 1 do px(x, f1(x), "#8a76a8") end
for i = 1, 22 do -- far tree clumps on ridge 1
  local x = floor(hsh(i, 9) * 470); local y = f1(x)
  local m = c:rrect(x, y - 6, x + 5, y + 1, 2); c:fillMask(m, "#544a7a"); px(x + 1, y - 5, "#7a6a9e")
end
c:terrain(f2, "#4f6f78", HOR)
for x = 0, W - 1 do px(x, f2(x), "#6a8c8c") end
for _, x in ipairs({ 30, 74, 128, 170, 318, 352, 410, 444 }) do -- far burrow lights
  local y = f2(x) + 4; px(x, y, "#ffd27a"); px(x + 1, y, "#ffd27a"); px(x, y + 1, "#e8a050"); px(x + 1, y + 1, "#e8a050")
end
c:terrain(f3, "#4d7650", HOR)
for x = 0, W - 1 do px(x, f3(x), "#64925a") end

-- 3 GROUND ------------------------------------------------------------------
for y = HOR, H - 1 do
  for x = 0, W - 1 do
    local d = (y - HOR) / (H - HOR) + (hsh(x, y, 1) - 0.5) * 0.06
    local col = d < 0.12 and "#6f9852" or (d < 0.35 and "#628d4a" or (d < 0.65 and "#578443" or "#4d7a3d"))
    local r = hsh(x, y, 2)
    if not inCompass(x, y) then
      if r < 0.035 then col = "#7aa758" elseif r < 0.06 then col = "#466f38" end
    end
    px(x, y, col)
  end
end
for i = 1, 760 do
  local x = floor(hsh(i, 5) * 480); local y = HOR + 6 + floor(hsh(i, 6) * (H - HOR - 6))
  if not inCompass(x, y) then
    local len = 1 + floor((y - HOR) / 40)
    for k = 0, len do px(x + ((k > len / 2) and 1 or 0), y - k, k == len and "#9cc46a" or "#80ab5c") end
  end
end

-- dirt trail toward the Wild arch (ground, drawn before objects)
local trailM = c:poly{ { 300, 154 }, { 340, 146 }, { 400, 142 }, { 466, 134 }, { 466, 140 }, { 404, 148 }, { 344, 154 }, { 306, 160 } }
tex(trailM, function(x, y) local r = hsh(x, y, 11) return r < 0.1 and "#8a6a4a" or (r < 0.2 and "#c4a07a" or "#a88660") end)

-- 4 STREET / SQUARE (mossy flagstones) ---------------------------------------
local pathM = c:poly{ { 96, 269 }, { 233, HOR }, { 247, HOR }, { 378, 269 } }
local K = 9
local function prow(y) return floor(math.log(y - VPY + 0.5) * K) end
local function pcol(x, y) local d = y - VPY + 0.5 return floor((x - VPX) / d * 5 + hsh(prow(y), 0, 9)) end
local stoneB = { "#8a8394", "#958c97", "#9b9089", "#857f90", "#908a8c" }
local warmB = { "#b49e92", "#bca694", "#ad9790", "#c0a898", "#b8a296" }
tex(pathM, function(x, y)
  local d = y - VPY
  if d < 14 then return (hsh(x, y, 4) < 0.15) and "#7d778a" or "#918a98" end
  local warm = ((x - 240) / 104) ^ 2 + ((y - 190) / 30) ^ 2 < 1
  local r = prow(y); local cl = pcol(x, y)
  if prow(y - 1) ~= r or pcol(x - 1, y) ~= cl then
    if hsh(x, y, 8) < 0.14 then return "#5f8a46" end
    return "#4d4659"
  end
  local v = hsh(r, cl, 7)
  local idx = 1 + floor(v * 5)
  if prow(y + 1) ~= r or pcol(x + 1, y) ~= cl then return warm and "#8a7478" or "#6c6478" end
  if prow(y - 2) ~= r or pcol(x - 2, y) ~= cl then return warm and "#d6bea4" or "#b2aab4" end
  if hsh(x, y, 3) < 0.05 then return warm and "#9a8484" or "#77708a" end
  return warm and warmB[idx] or stoneB[idx]
end)

-- 5 THE GREEN (lawn) ---------------------------------------------------------
local lawnM = c:poly{ { 214, 134 }, { 266, 134 }, { 302, 186 }, { 178, 186 } }
local flowerC = { "#f2d36a", "#e88aa8", "#f4eee0", "#a88ae0" }
tex(lawnM, function(x, y)
  local r = hsh(x, y, 12)
  if r < 0.018 then return flowerC[1 + floor(hsh(x, y, 13) * 4)] end
  local pool = ((x - 240) / 62) ^ 2 + ((y - 176) / 16) ^ 2 < 1
  if (floor((x - 240) / ((y - VPY) * 0.18 + 1))) % 2 == 0 then -- mown stripes in perspective
    if r < 0.08 then return "#5a9040" end
    return pool and "#9ccc62" or "#74ae50"
  end
  if r < 0.08 then return "#86bc5c" end
  return pool and "#8cc45a" or "#68a248"
end)
c:rim(lawnM, "#4d4659")
tex(lawnM:edge(), function(x, y) return ((floor(x / 4) + floor(y / 3)) % 2 == 0) and "#a8a0ac" or "#7c748a" end)

-- 6 MYCELIUM THREADS (all meet at the hub mushroom) ---------------------------
local function thread(x0, y0, x1, y1, seed)
  local n = math.max(abs(x1 - x0), abs(y1 - y0))
  local dx, dy = (x1 - x0) / n, (y1 - y0) / n; local L = sqrt(dx * dx + dy * dy)
  local lx, ly
  for i = 0, n do
    local t = i / n
    local w = sin(t * 9 + seed) * 4 * (1 - t)
    local x = floor(x0 + (x1 - x0) * t - dy / L * w + 0.5)
    local y = floor(y0 + (y1 - y0) * t + dx / L * w + 0.5)
    if not inCompass(x, y) then
      if lx and abs(x - lx) + abs(y - ly) > 1 then px(x, ly, "#7ee4bc") end
      local node = (i % 13 == 0)
      px(x, y, node and "#e6ffd6" or "#8eecc6")
      if node then px(x + 1, y, "#5cc0a0"); px(x - 1, y, "#5cc0a0"); px(x, y + 1, "#5cc0a0") end
    end
    lx, ly = x, y
  end
end
local sources = { { 14, 196 }, { 14, 246 }, { 60, 146 }, { 118, 268 }, { 196, 268 }, { 290, 268 }, { 360, 268 },
  { 150, 124 }, { 330, 124 }, { 470, 214 }, { 420, 150 }, { 100, 124 } }
for i, s in ipairs(sources) do thread(s[1], s[2], 240 + (i % 3 - 1) * 4, 182, i * 1.7) end

-- meadow patch ground (windy) ---------------------------------------------------
local meadowM = c:poly{ { 114, 124 }, { 150, 119 }, { 176, 122 }, { 176, 147 }, { 114, 147 } }
tex(meadowM, function(x, y)
  local s = (x - floor(y * 1.6) + floor(hsh(floor(y / 3), 0, 2) * 20)) % 14
  if s < 3 then return "#a8c866" end
  if hsh(x, y, 14) < 0.07 then return "#6a9444" end
  return "#8db456"
end)

-- 7 SHADOWS (cool, cast lower-right) -------------------------------------------
local function shadow(pts)
  tex(c:poly(pts), function(x, y)
    if pathM:has(x, y) then return "#5d5570" end
    if lawnM:has(x, y) then return "#4c7a50" end
    return "#3e5a4c"
  end)
end
shadow{ { 18, 139 }, { 108, 137 }, { 118, 142 }, { 30, 146 } }
shadow{ { 304, 140 }, { 398, 140 }, { 404, 145 }, { 316, 147 } }
shadow{ { 408, 140 }, { 458, 140 }, { 464, 144 }, { 414, 144 } }
shadow{ { 14, 256 }, { 126, 240 }, { 136, 248 }, { 30, 264 } }
shadow{ { 132, 225 }, { 174, 225 }, { 184, 229 }, { 140, 230 } }
shadow{ { 352, 214 }, { 462, 224 }, { 464, 228 }, { 360, 227 } }
shadow{ { 220, 179 }, { 262, 179 }, { 280, 186 }, { 232, 186 } }
shadow{ { 132, 144 }, { 146, 144 }, { 152, 147 }, { 136, 147 } }

-- 8 LIBRARY (far left) ----------------------------------------------------------
local creamS = R("#7a6250", "#b39a7c", "#d4bf98", "#e6d6b4", "#f4ead0")
local slate = R("#2f3460", "#454c86", "#5c66a8", "#7884c4", "#98a4dc")
obj(c:poly{ { 96, 92 }, { 108, 94 }, { 108, 138 }, { 96, 140 } }, stoneTex(creamS, 8, 5, 21, true), creamS.d)
obj(c:rect(18, 92, 95, 140), stoneTex(creamS, 8, 5, 22), creamS.d)
obj(c:poly{ { 56, 58 }, { 68, 62 }, { 110, 96 }, { 98, 95 } }, function(x, y) return ((y % 4) == 3) and slate.d or slate.s end, slate.d)
obj(c:poly{ { 14, 95 }, { 56, 58 }, { 98, 95 } }, shingleTex(slate, 6, 4, 58, 56, 23), slate.d)
-- book-stack chimney (quirk)
local books = { { 76, 60, 88, "#c0443a", "#7a2420" }, { 78, 65, 90, "#4f9a52", "#2e5a34" }, { 75, 70, 87, "#4a6ac0", "#2a3a78" }, { 77, 75, 89, "#e0a840", "#8a6020" } }
for _, b in ipairs(books) do
  local m = c:rect(b[1], b[2], b[3], b[2] + 4)
  obj(m, function(x, y)
    if x >= b[3] - 2 then return (y % 2 == 0) and "#f4ead0" or "#c8b898" end
    if y == b[2] + 1 and x < b[1] + 6 then return "#f2c86a" end
    return b[4]
  end, b[5])
end
for _, p in ipairs({ { 80, 57 }, { 81, 56 }, { 83, 55 }, { 84, 55 } }) do px(p[1], p[2], "#c8b4c8") end
window(51, 70, 61, 86, true, "#3a2e4a")
window(22, 102, 34, 130, true)
window(78, 102, 90, 130, true)
-- big open-book sign
obj(c:poly{ { 37, 97 }, { 56, 100 }, { 75, 97 }, { 75, 114 }, { 56, 117 }, { 37, 114 } }, function() return "#b03a34" end, "#5a1a1e")
obj(c:poly{ { 40, 99 }, { 55, 102 }, { 55, 113 }, { 40, 111 } }, function(x, y) return ((y - 101) % 3 == 0 and x > 42 and x < 53) and "#9a8a90" or "#f4ead0" end, "#b8a080")
obj(c:poly{ { 57, 102 }, { 72, 99 }, { 72, 111 }, { 57, 113 } }, function(x, y) return ((y - 101) % 3 == 0 and x > 59 and x < 70) and "#9a8a90" or "#e6d6b4" end, "#b8a080")
px(56, 101, "#5a1a1e"); for y = 101, 116 do px(56, y, "#7a2420") end
c:fillMask(c:rect(57, 102, 58, 108), "#e8b840") -- ribbon bookmark
door(50, 118, 62, 139, R("#3a2018", "#5a3424", "#7a4a30", "#98643e", "#b88050"), true)
c:fillMask(c:rect(46, 139, 66, 140), "#8e8796")

-- 9 MEADOW props (s1) ------------------------------------------------------------
for i = 1, 70 do -- wind-bent tall grass + flowers
  local bx = 116 + floor(hsh(i, 31) * 58); local by = 128 + floor(hsh(i, 32) * 19)
  local hgt = 5 + floor(hsh(i, 33) * 7)
  local tx, ty
  for k = 0, hgt do
    tx = bx + floor(k * k / 14); ty = by - k
    px(tx, ty, k > hgt - 2 and "#b4d27a" or (k < 2 and "#4e7a38" or "#6e9e48"))
  end
  if i % 3 == 0 then
    local fc = ({ "#9a6ad0", "#f2cf50", "#f4d8e0", "#e8705e" })[1 + i % 4]
    px(tx, ty, fc); px(tx + 1, ty, fc); px(tx, ty - 1, fc); px(tx + 1, ty + 1, "#7a4a8a")
  end
end
local wood = R("#3a2418", "#5e3a24", "#7e5232", "#9c6c44", "#b88a5c")
obj(c:rect(141, 88, 143, 146), function(x) return x == 141 and wood.l or wood.s end, wood.d)
-- streamers blowing right
for t = 0, 30 do
  local y1 = 98 + floor(sin(t / 4) * 2 + t / 10); local y2 = 104 + floor(sin(t / 4 + 1.5) * 2 + t / 12)
  px(144 + t, y1, "#f08aa0"); px(144 + t, y1 + 1, "#a84a68")
  px(144 + t, y2, "#f2c450"); px(144 + t, y2 + 1, "#a87a28")
end
-- pinwheel (4 triangular blades)
local pc = { 142, 85 }
local blades = {
  { { 0, -11 }, { 8, -6 }, "#e8704e", "#8a3424", "#f4a080" },
  { { 11, 0 }, { 6, 8 }, "#f2c450", "#8a6020", "#fae08a" },
  { { 0, 11 }, { -8, 6 }, "#6ac08a", "#2e6a48", "#a0e0b0" },
  { { -11, 0 }, { -6, -8 }, "#8a78d0", "#443a80", "#b4a8ec" } }
for _, b in ipairs(blades) do
  local m = c:poly{ { pc[1], pc[2] }, { pc[1] + b[1][1], pc[2] + b[1][2] }, { pc[1] + b[2][1], pc[2] + b[2][2] } }
  obj(m, function(x, y) return ((x - pc[1]) * b[1][1] + (y - pc[2]) * b[1][2] > 50) and b[5] or b[3] end, b[4])
end
c:fillMask(c:rect(141, 84, 143, 86), "#e8b840"); px(141, 84, "#fff0b0")
-- wind swirls
for _, s in ipairs({ { 118, 80 }, { 160, 112 }, { 120, 106 } }) do
  for k = 0, 9 do px(s[1] + k, s[2] + floor(sin(k / 2) * 1.5), "#f4e6d0") end
  px(s[1] + 10, s[2] - 1, "#f4e6d0"); px(s[1] + 10, s[2] - 2, "#f4e6d0"); px(s[1] + 9, s[2] - 3, "#f4e6d0")
end

-- 10 WILD TRAIL (right, far) --------------------------------------------------------
local inner = c:poly{ { 416, 142 }, { 416, 92 }, { 433, 80 }, { 450, 92 }, { 450, 142 } }
obj(inner, function(x, y)
  local r = hsh(x, y, 41)
  if y > 128 and abs(x - (433 + (y - 128) * 0.5)) < (y - 124) * 0.6 then return r < 0.2 and "#8a6a4a" or "#a88660" end
  local tree = (hsh(floor(x / 5), 0, 42) * 30 + 90) < y
  if tree then return r < 0.3 and "#2a4a48" or "#1e3a3e" end
  return r < 0.2 and "#3a5a5a" or "#30504e"
end)
for _, p in ipairs({ { 424, 104 }, { 440, 98 }, { 431, 114 }, { 446, 120 } }) do px(p[1], p[2], "#fff2a0") end
local bark = R("#2e1c14", "#4e3222", "#6e4a30", "#8e6644", "#ae8660")
local postL = c:poly{ { 409, 142 }, { 411, 120 }, { 409, 100 }, { 412, 86 }, { 418, 86 }, { 416, 104 }, { 418, 124 }, { 417, 142 } }
local postR = c:poly{ { 449, 142 }, { 450, 122 }, { 448, 104 }, { 449, 86 }, { 455, 86 }, { 457, 102 }, { 455, 122 }, { 458, 142 } }
local archM = c:line({ { 411, 92 }, { 418, 80 }, { 433, 73 }, { 448, 80 }, { 455, 92 } }, 6)
for _, m in ipairs({ postL, postR, archM }) do
  obj(m, function(x, y) local r = hsh(x, y, 43) return (x % 4 == 0 and r < 0.6) and bark.s or (r < 0.2 and bark.l or bark.b) end, bark.d)
end
for i = 1, 16 do -- leaf clusters on the arch
  local t = i / 16; local ax = floor(406 + t * 56); local ay = floor(88 - sin(t * 3.1416) * 18 + hsh(i, 44) * 6)
  local m = c:rrect(ax, ay, ax + 6, ay + 4, 2)
  obj(m, function(x, y) return (y == ay + 1 and x < ax + 3) and "#9cd06a" or "#5aa04a" end, "#2e6a34")
  if i % 4 == 0 then px(ax + 3, ay + 5, "#e05a4a"); px(ax + 4, ay + 5, "#b03a34") end
end
for _, vx in ipairs({ 420, 444 }) do for y = 84, 100 do px(vx + floor(sin(y / 3) * 1.5), y, "#4f9a52") end end
-- signpost with arrow pointing out right
obj(c:rect(426, 112, 428, 142), function(x) return x == 426 and wood.l or wood.s end, wood.d)
obj(c:poly{ { 420, 104 }, { 440, 104 }, { 446, 108 }, { 440, 112 }, { 420, 112 } }, plankTex(R("#4a3020", "#9a7044", "#c0925a", "#d8ac74", "#ecc890"), 40, 45), "#4a3020")
obj(c:poly{ { 425, 106 }, { 431, 106 }, { 434, 108 }, { 431, 110 }, { 425, 110 } }, function(x) return x < 428 and "#7ac05a" or "#4f9a52" end, "#2e6a34")

-- 11 BURROWS (s2) --------------------------------------------------------------------
local hillR = R("#24502e", "#3a7040", "#4f8c4a", "#6aa85a", "#8cc46c")
local hillM = dome(351, 142, 47, 52, 0.6)
obj(hillM, function(x, y)
  local col = domeTex(hillR, 351, 142, 47, 52, 51)(x, y)
  local r = hsh(x, y, 52)
  if r < 0.03 then return ({ "#f2cf50", "#f4d8e0", "#9a6ad0" })[1 + floor(hsh(x, y, 53) * 3)] end
  if r < 0.1 then return hillR.s end
  return col
end, hillR.d)
for x = 310, 392, 3 do -- grass tufts on the crest
  local top
  for y = 88, 142 do if hillM:has(x, y) then top = y break end end
  if top then px(x, top - 1, "#8cc46c"); px(x + 1, top - 2, "#8cc46c") end
end
local ringS = R("#4a4058", "#6c6478", "#8e8796", "#aaa3ad", "#c7c0c2")
local function burrowDoor(x0, y0, x1, y1, Rm)
  local r = (x1 - x0) / 2
  local ring = c:rect(x0 - 3, floor(y0 + r), x1 + 3, y1); ring:add(c:ellipse((x0 + x1) / 2, y0 + r, r + 3, r + 3))
  obj(ring, function(x, y) return ((floor(x / 3) + floor(y / 3)) % 2 == 0) and ringS.l or ringS.b end, ringS.d)
  door(x0, y0, x1, y1, Rm, true)
end
burrowDoor(340, 110, 362, 141, R("#7a5418", "#b88a28", "#e8b840", "#f4d070", "#fae8a8"))
burrowDoor(314, 124, 326, 141, R("#1e3a6a", "#2e5a9a", "#4a7ac0", "#6a9ad8", "#9abce8"))
burrowDoor(370, 124, 382, 141, R("#6a2420", "#9a3a2e", "#c8503e", "#e07058", "#f0a080"))
for _, w in ipairs({ { 328, 112 }, { 364, 102 }, { 384, 114 } }) do window(w[1], w[2], w[1] + 5, w[2] + 5, false, "#3a2e22") end
-- chimney pipes with smoke
for _, p in ipairs({ { 330, 94 }, { 372, 92 } }) do
  obj(c:rect(p[1], p[2], p[1] + 3, p[2] + 8), function(x) return x == p[1] and "#a8a0ac" or "#7c748a" end, "#4a4058")
  for k = 1, 6 do px(p[1] + 1 + floor(sin(k) * 1.5), p[2] - k, "#d0c4d8") end
end
-- dirt pile + shovel (dig icon)
obj(c:poly{ { 384, 142 }, { 389, 133 }, { 394, 131 }, { 398, 135 }, { 398, 142 } }, function(x, y) return hsh(x, y, 54) < 0.3 and "#6a4a2a" or "#8a6440" end, "#4a3020")
obj(c:line({ { 395, 108 }, { 391, 130 } }, 2), function() return "#b88a5c" end, "#5e3a24")
obj(c:poly{ { 387, 128 }, { 395, 129 }, { 394, 136 }, { 390, 138 }, { 386, 135 } }, function(x, y) return (x < 390) and "#c8c4d0" or "#8e8796" end, "#4a4058")
-- roots dangling over the big door (rootlings were here first)
for _, rx in ipairs({ 338, 345, 357, 365 }) do for k = 0, 4 do px(rx + (k % 2), 106 + k, "#7a5234") end end

-- 12 HUB MUSHROOM on the green ------------------------------------------------------
local stalkR = R("#7a5a58", "#c4a890", "#e6d4b8", "#f6ead2", "#fff4e0")
local stalkM = c:poly{ { 231, 98 }, { 249, 98 }, { 251, 140 }, { 255, 174 }, { 264, 182 }, { 216, 182 }, { 225, 174 }, { 229, 140 } }
obj(stalkM, function(x, y)
  local t = (x - 222) / 40
  if hsh(x, floor(y / 4), 61) < 0.12 then return stalkR.s end
  if t < 0.3 then return stalkR.h elseif t < 0.55 then return stalkR.l elseif t < 0.75 then return stalkR.b end
  return stalkR.s
end, stalkR.d)
-- frill ring
obj(c:poly{ { 226, 110 }, { 254, 110 }, { 258, 116 }, { 222, 116 } }, function(x, y) return (x % 4 == 0) and stalkR.s or (y == 110 and stalkR.h or stalkR.l) end, stalkR.d)
-- rootling door at the base (quirk)
door(235, 166, 245, 181, R("#24502e", "#3a7040", "#4f8c4a", "#6aa85a", "#8cc46c"), true)
px(247, 168, "#ffd06a"); px(247, 169, "#f0a04c")
-- gills (glowing underside)
obj(c:poly{ { 186, 100 }, { 294, 100 }, { 284, 107 }, { 196, 107 } }, function(x, y)
  if abs(x - 240) < 12 then return "#c08850" end
  return ((x + floor((y - 100) * (x - 240) / 60)) % 3 == 0) and "#e8a850" or "#ffd77a"
end, "#9a5a34")
local capR = R("#2a2050", "#56489a", "#7462b8", "#9a86d4", "#c4b4ec")
local capM = dome(240, 100, 58, 48)
obj(capM, function(x, y)
  local col = domeTex(capR, 240, 100, 58, 48, 62)(x, y)
  local top
  if not capM:has(x, y - 3) and hsh(x, y, 63) < 0.6 then return (hsh(x, y, 64) < 0.5) and "#6fa050" or "#8cc06a" end -- moss crown
  return col
end, capR.d)
for _, s in ipairs({ { 212, 66, 9, 6 }, { 236, 58, 7, 4 }, { 258, 70, 10, 7 }, { 198, 84, 7, 5 }, { 226, 80, 8, 5 }, { 276, 86, 7, 5 }, { 250, 88, 6, 4 }, { 280, 66, 5, 4 } }) do
  local m = c:rrect(s[1], s[2], s[1] + s[3], s[2] + s[4], 2):clip(capM)
  obj(m, function(x, y)
    if y == s[2] + 1 and x <= s[1] + 2 then return "#e6ffe8" end
    if y == s[2] + s[4] then return "#5cbfa4" end
    return "#a8f4d4"
  end, "#3a8a7a")
end
-- tiny hanging lights from the rim
for _, lx in ipairs({ 198, 216, 264, 282 }) do
  for y = 107, 111 do px(lx, y, "#4a3a5a") end
  obj(c:rect(lx - 1, 112, lx + 1, 115), function(x, y) return (x == lx - 1 and y == 112) and "#fff0b0" or "#ffd06a" end, "#b06a30")
end
-- small glowing mushrooms at the lawn corners
for _, g in ipairs({ { 188, 180 }, { 196, 182 }, { 284, 182 }, { 292, 180 } }) do
  obj(c:rect(g[1] + 1, g[2] - 3, g[1] + 2, g[2]), function() return "#e6d4b8" end, "#8a6a64")
  obj(dome(g[1] + 1.5, g[2] - 3, 3, 3), function(x, y) return (y < g[2] - 4) and "#c8fff0" or "#8eecc6" end, "#2e8a72")
end

-- 13 NOTICE BOARD -------------------------------------------------------------------
local boardW = R("#3a2418", "#6a4a30", "#8a6440", "#a88056", "#c49a6c")
for _, x0 in ipairs({ 134, 168 }) do obj(c:rect(x0, 160, x0 + 3, 226), function(x) return x == x0 and boardW.l or boardW.b end, boardW.d) end
obj(c:rect(131, 164, 175, 208), function(x, y)
  if x <= 132 or x >= 174 or y <= 165 or y >= 207 then return boardW.s end
  return hsh(x, y, 71) < 0.15 and "#b88a5a" or "#c89c66"
end, boardW.d)
local moss = R("#2e5a34", "#3f7a40", "#58964c", "#74b05c", "#98cc74")
obj(c:poly{ { 130, 165 }, { 153, 152 }, { 176, 165 } }, shingleTex(moss, 5, 3, 152, 153, 72), moss.d)
local papers = {
  { 134, 168, 146, 181, R("#8a7a60", "#c8b898", "#f0e4c8", "#f8f0dc", "#fff8ec") },
  { 149, 167, 159, 177, R("#8a4a5a", "#d08aa0", "#f0b4c4", "#f8d0dc", "#fce8ee") },
  { 162, 168, 172, 183, R("#3a5a8a", "#7a9ad0", "#a8c4ec", "#c8dcf8", "#e4eefc") },
  { 135, 185, 149, 202, R("#3a7a5a", "#7ac0a0", "#a8e4c8", "#c8f4e0", "#e6fff2") },
  { 153, 181, 170, 195, R("#8a6a20", "#d8b040", "#f4d670", "#fae69a", "#fff4c8") } }
for i, p in ipairs(papers) do
  local Rm = p[5]
  obj(c:rect(p[1], p[2], p[3], p[4]), function(x, y)
    if (y - p[2]) % 3 == 2 and x > p[1] + 1 and x < p[3] - 1 + ((y + i) % 2) * -3 then return Rm.s end
    if x == p[3] - 1 or y == p[4] - 1 then return Rm.l end
    return Rm.b
  end, Rm.s)
  local pxx = floor((p[1] + p[3]) / 2)
  px(pxx, p[2] + 1, ({ "#c0443a", "#4a6ac0", "#e8b840", "#c0443a", "#4f9a52" })[i]); px(pxx, p[2], "#2b1c26")
end
obj(c:poly{ { 156, 202 }, { 162, 197 }, { 169, 199 }, { 164, 205 } }, function(x, y) return (x + y) % 5 == 0 and "#3f7a40" or "#6ab04c" end, "#2e5a34")
-- glowing mushrooms growing on the left post (quirk)
obj(c:rect(138, 196, 140, 198), function() return "#e6d4b8" end, "#8a6a64")
obj(dome(141, 196, 4, 4), function(x, y) return (y < 194) and "#fff0b0" or "#ffd06a" end, "#b06a30")

-- 14 TEAHOUSE: The Mossy Mug (right near) ------------------------------------------
local terra = R("#7a3a2a", "#b05a3a", "#d47a4e", "#e89a68", "#f6be8a")
local beam = "#5a3424"
obj(c:poly{ { 352, 186 }, { 364, 192 }, { 364, 226 }, { 352, 216 } }, function(x, y) return (y % 5 == 0) and terra.l or terra.h end, terra.s)
local frontM = c:rect(364, 192, 461, 226)
obj(frontM, function(x, y)
  if y >= 216 then return stoneTex(ringS, 7, 4, 81)(x, y) end
  if (x - 364) % 24 == 0 or (x - 364) % 24 == 1 or y == 192 or y == 193 or y == 215 then return beam end
  local r = hsh(x, y, 82)
  return r < 0.08 and terra.s or (r < 0.16 and terra.l or terra.b)
end, terra.d)
-- cap underside + red mushroom-cap roof
obj(c:poly{ { 356, 189 }, { 464, 189 }, { 458, 194 }, { 362, 194 } }, function(x) return (x % 3 == 0) and "#a8805c" or "#d8b088" end, "#6a4a30")
local redR = R("#5a1e22", "#8a2e2e", "#b84438", "#d8644a", "#f08a64")
local teaCap = dome(410, 190, 56, 38, 0.6)
obj(teaCap, function(x, y)
  if not teaCap:has(x, y - 2) and hsh(x, y, 83) < 0.5 then return "#74b05c" end
  return domeTex(redR, 410, 190, 56, 38, 84)(x, y)
end, redR.d)
for _, s in ipairs({ { 376, 172, 8, 5 }, { 396, 160, 9, 6 }, { 420, 166, 7, 5 }, { 440, 176, 8, 5 }, { 404, 178, 6, 4 }, { 366, 182, 5, 3 } }) do
  local m = c:rrect(s[1], s[2], s[1] + s[3], s[2] + s[4], 2):clip(teaCap)
  obj(m, function(x, y) if y == s[2] + 1 and x <= s[1] + 2 then return "#fff4e0" end return (y == s[2] + s[4]) and "#d8c0a0" or "#f2e0c0" end, "#a07858")
end
-- teacup chimney with steam (quirk)
obj(c:poly{ { 438, 154 }, { 452, 154 }, { 450, 162 }, { 440, 162 } }, function(x, y) if y == 154 then return "#6a3a1e" end return (x < 443) and "#fff4e0" or "#e6d4b8" end, "#8a6a64")
obj(c:rect(453, 156, 455, 159), function() return "#e6d4b8" end, "#8a6a64")
for k = 1, 7 do px(444 + floor(sin(k * 1.3) * 1.6), 154 - k, "#f4e6d0"); px(448 + floor(sin(k * 1.1 + 2) * 1.4), 153 - floor(k * 0.8), "#d0c4d8") end
window(388, 198, 402, 214, true)
window(436, 198, 452, 214, true)
door(412, 198, 428, 226, R("#1e3a2a", "#2e5a3a", "#3f6f4a", "#58905e", "#7ab07a"), true)
-- acorn cups on the sills (acorn coffee)
for _, a in ipairs({ { 391, 214 }, { 398, 214 }, { 440, 214 }, { 447, 214 } }) do
  px(a[1], a[2] - 3, "#5a3424"); px(a[1] + 1, a[2] - 3, "#7a4a30"); px(a[1] + 2, a[2] - 3, "#5a3424")
  px(a[1], a[2] - 2, "#c8843e"); px(a[1] + 1, a[2] - 2, "#e0a458"); px(a[1] + 2, a[2] - 2, "#a0602e")
  px(a[1] + 1, a[2] - 1, "#a0602e")
end
-- hanging mug sign
for y = 194, 197 do px(368, y, "#4a3a5a"); px(381, y, "#4a3a5a") end
obj(c:rect(366, 197, 383, 214), function(x, y) if x <= 367 or x >= 382 or y <= 198 or y >= 213 then return boardW.b end return "#f0dcb0" end, boardW.d)
obj(c:rect(370, 203, 377, 211), function(x, y) if y == 203 then return "#6a3a1e" end return (x < 373) and "#fff4e0" or "#d8c0a0" end, "#8a6a64")
obj(c:rect(378, 205, 379, 208), function() return "#d8c0a0" end, "#8a6a64")
for k = 0, 2 do px(372 + (k % 2), 201 - k, "#b8a6d0"); px(375 + ((k + 1) % 2), 201 - k, "#b8a6d0") end

-- 15 SHOPS: Old Twigg's seed emporium (left near) -------------------------------------
local ochre = R("#6a3a22", "#a0602e", "#c8843e", "#e0a458", "#f2c47c")
local straw = R("#6a4a26", "#9a7038", "#c49a4e", "#dcb868", "#eed48a")
obj(c:poly{ { 112, 186 }, { 126, 178 }, { 126, 242 }, { 112, 257 } }, plankTex(ochre, 5, 91, true), ochre.d)
obj(c:rect(14, 184, 111, 257), plankTex(ochre, 5, 92), ochre.d)
obj(c:poly{ { 100, 154 }, { 114, 150 }, { 126, 178 }, { 112, 186 } }, function(x, y) return (y % 6 == 5) and straw.d or straw.s end, straw.d)
obj(c:poly{ { 14, 186 }, { 26, 154 }, { 100, 154 }, { 112, 186 } }, thatchTex(straw, 93), straw.d)
-- dormer
obj(c:poly{ { 50, 166 }, { 60, 157 }, { 70, 166 } }, shingleTex(moss, 4, 3, 157, 60, 94), moss.d)
window(53, 166, 67, 180, false)
-- striped awning with scalloped hem
local awn = c:poly{ { 18, 194 }, { 104, 194 }, { 108, 204 }, { 14, 204 } }
for x = 14, 108, 6 do awn:add(c:rect(x, 205, x + 3, 206)) end
obj(awn, function(x, y)
  local g = (floor((x - 14) / 6) % 2 == 0)
  if y >= 203 then return g and "#2e6a34" or "#c8b898" end
  return g and "#4f9a52" or "#efe2c0"
end, "#2e5a34")
-- shop window with seed jars
local swin = c:rect(20, 209, 68, 236)
c:fillMask(swin, "#4a2e22")
tex(swin:shrink(1), function(x, y) if y == 222 then return "#7a4a30" end if (x - 21) + (y - 210) < 7 then return "#fff0b0" end return "#ffd06a" end)
local jarC = { "#c0443a", "#4f9a52", "#4a6ac0", "#e0a840", "#8a5aa0", "#c87a3a" }
for i = 0, 5 do
  local jx = 23 + i * 7
  for _, jy in ipairs({ 214, 227 }) do
    obj(c:rect(jx, jy, jx + 4, jy + 7), function(x, y) if y == jy then return "#8a6440" end return (x == jx + 1) and "#d8f0ec" or jarC[1 + (i + jy) % 6] end, "#3a2e3a")
  end
end
for x = 18, 70 do px(x, 237, "#6c6478") end
door(76, 210, 94, 257, R("#24502e", "#3a7040", "#4f8c4a", "#6aa85a", "#8cc46c"), true)
window(81, 216, 89, 226, true, "#24502e")
-- seed sacks in front of the window
local sackR = R("#5a3a22", "#8a6440", "#b89068", "#d0ac84", "#e6c8a0")
for i, top in ipairs({ "#e0a840", "#c0443a", "#5a3424", "#6ab04c" }) do
  local sx = 18 + (i - 1) * 13
  local m = c:poly{ { sx + 1, 242 }, { sx + 11, 242 }, { sx + 12, 256 }, { sx, 256 } }
  obj(m, function(x, y)
    if y <= 244 then return (hsh(x, y, 95 + i) < 0.4) and "#fff0b0" or top end
    if y == 245 then return sackR.d end
    return (x < sx + 4) and sackR.l or (hsh(x, y, 96) < 0.15 and sackR.s or sackR.b)
  end, sackR.d)
end
-- Old Twigg's ancient seed jar (quirk: seeds older than his customers)
local jarM = c:rrect(96, 228, 109, 256, 3)
obj(jarM, function(x, y)
  if y <= 230 then return "#7a5234" end
  if x == 98 and y < 250 then return "#e6fff2" end
  if y > 240 and hsh(x, y, 97) < 0.5 then return "#5a3424" end
  if y > 240 then return "#8a6440" end
  return ((x + y) % 7 == 0) and "#f4ead0" or "#a8d8d0"
end, "#3a6a6a")
for k = 0, 5 do px(102 + (k % 2), 227 - k, "#4f9a52") end
px(100, 222, "#6ab04c"); px(101, 222, "#8cc46c"); px(104, 222, "#6ab04c"); px(105, 223, "#8cc46c")
-- hanging seed-sprout sign
for x = 110, 124 do px(x, 190, "#3a2418") end
px(112, 191, "#4a3a5a"); px(122, 191, "#4a3a5a")
obj(c:rect(110, 192, 124, 206), function(x, y) if x <= 111 or x >= 123 or y <= 193 or y >= 205 then return wood.b end return "#f0dcb0" end, wood.d)
obj(c:rrect(114, 200, 119, 204, 2), function(x, y) return (x < 116) and "#c8843e" or "#8a5a2a" end, "#5a3424")
px(117, 199, "#4f9a52"); px(117, 198, "#4f9a52"); px(115, 196, "#6ab04c"); px(116, 197, "#6ab04c"); px(118, 196, "#6ab04c"); px(119, 197, "#8cc46c")

-- 16 GATE FRAME (mossy stone posts, timber lintel) --------------------------------------
local gateS = R("#3a3446", "#5a5266", "#7a7286", "#9890a2", "#b4acbc")
for _, x0 in ipairs({ 0, 466 }) do
  local m = c:rect(x0, 0, x0 + 13, H - 1)
  obj(m, function(x, y)
    local col = stoneTex(gateS, 7, 6, 101 + x0)(x, y)
    if hsh(floor(x / 3), floor(y / 5), 102) < 0.18 then col = (hsh(x, y, 103) < 0.5) and "#5a8a44" or "#78a855" end
    if (x0 == 0 and x == 13) or (x0 == 466 and x == 466) then col = gateS.d end
    return col
  end, gateS.d)
end
local lintel = c:rect(0, 0, W - 1, 13)
obj(lintel, function(x, y)
  if y <= 1 then return (hsh(x, 0, 104) < 0.5) and "#58964c" or "#74b05c" end
  if (y == 6 and hsh(floor(x / 30), 0, 105) < 0.7) then return wood.d end
  local g = hsh(floor(x / 3), y, 106)
  if y >= 12 then return wood.s end
  return g < 0.15 and wood.s or (g > 0.85 and wood.l or wood.b)
end, wood.d)
for x = 2, W - 3 do -- moss drips under the lintel
  local n = floor(hsh(x, 1, 107) * 6) - 2
  for k = 0, n do px(x, 14 + k, k == n and "#3f7a40" or "#58964c") end
end
for _, s in ipairs({ { 14, 1 }, { 465, -1 } }) do
  local m = c:poly{ { s[1], 14 }, { s[1] + s[2] * 20, 14 }, { s[1], 34 } }
  obj(m, function(x, y) return (hsh(x, y, 108) < 0.2) and wood.s or wood.b end, wood.d)
end
-- bunting of leaf pennants
local bc = { { "#e0785a", "#8a3424" }, { "#f2c450", "#8a6020" }, { "#6ab06a", "#2e6a34" }, { "#8a78d0", "#443a80" }, { "#f0a0b0", "#a84a68" } }
local function by(x) return floor(16 + 14 * (1 - ((x - 240) / 226) ^ 2)) end
for x = 14, 465 do px(x, by(x), "#4a3a5a") end
local bi = 0
for x = 22, 456, 15 do
  bi = bi + 1; local y = by(x + 3); local col = bc[1 + bi % 5]
  local m = c:poly{ { x, y + 1 }, { x + 8, y + 1 }, { x + 5, y + 9 }, { x + 4, y + 10 } }
  obj(m, function(px_, py_) return (px_ < x + 3) and col[1] or col[1] end, col[2])
  px(x + 2, y + 3, "#fff0d0")
end
-- hanging mushroom lanterns
for _, lx in ipairs({ 40, 440 }) do
  for y = 14, 23 do px(lx, y, (y % 2 == 0) and "#4a4058" or "#6c6478") end
  obj(c:rect(lx - 4, 30, lx + 4, 40), function(x, y) if x == lx then return "#b06a30" end return (x < lx and y < 35) and "#fff0b0" or "#ffd06a" end, "#8a4a20")
  obj(dome(lx, 30, 8, 6), domeTex(redR, lx, 30, 8, 6, 109), redR.d)
  px(lx - 3, 26, "#f2e0c0"); px(lx + 2, 27, "#f2e0c0")
  obj(c:rect(lx - 3, 41, lx + 3, 42), function() return "#8a4a20" end, "#5a2a14")
end

-- 17 FIREFLIES ----------------------------------------------------------------------
for i = 1, 44 do
  local x = 16 + floor(hsh(i, 121) * 446); local y = 60 + floor(hsh(i, 122) * 160)
  if not inCompass(x, y) then
    px(x, y, "#fff6a8")
    if i % 3 == 0 then px(x - 1, y, "#e8d070"); px(x + 1, y, "#e8d070"); px(x, y - 1, "#e8d070"); px(x, y + 1, "#e8d070") end
  end
end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

-- layout -------------------------------------------------------------------------------
local spots = {
  { "green", "Mossbottom Green", 182, 50, 300, 190 },
  { "tea", "The Mossy Mug", 350, 146, 466, 228 },
  { "board", "Notice Board", 130, 150, 176, 228 },
  { "library", "Library", 16, 54, 110, 142 },
  { "s1", "Meadow", 114, 72, 176, 148 },
  { "s2", "Burrows", 304, 84, 398, 144 },
  { "shops", "Old Twigg's Seed Emporium", 14, 150, 128, 262 },
  { "wild", "Wild Trail", 404, 68, 466, 144 } }
local stand = { { 205, 208 }, { 282, 208 }, { 330, 238 }, { 160, 252 }, { 226, 240 }, { 292, 258 } }
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], floor((s[3] + s[5]) / 2), floor((s[4] + s[6]) / 2), s[3], s[4], s[5], s[6])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n', HOR, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok")

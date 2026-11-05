-- Gnome Venture "Hearth Pop" v3: The Sunsprinkle Isles, gate view (480x270 native)
-- Tropical harbour town at bright noon, seen through a bamboo-and-thatch gate.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(ROOT .. "/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or (ROOT .. "/here-gate/towns/")
if OUT:sub(-1) ~= "/" then OUT = OUT .. "/" end
local NAME = "here-town-sunsprinkle"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, cos, sqrt, abs, min, max = math.floor, math.sin, math.cos, math.sqrt, math.abs, math.min, math.max
local VP = { 240, 112 }

local function hsh(x, y, s)
  local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function P(x, y, col)
  x = floor(x); y = floor(y)
  if col and x >= 0 and x < W and y >= 0 and y < H then c:px(x, y, col) end
end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end

-- shapes ------------------------------------------------------------------
local function S() return { m = {}, n = 0 } end
local function sAdd(s, x, y)
  x = floor(x); y = floor(y)
  if x < 0 or x >= W or y < 0 or y >= H then return end
  local k = y * W + x
  if not s.m[k] then s.m[k] = true; s.n = s.n + 1 end
end
local function has(s, x, y) return x >= 0 and x < W and y >= 0 and y < H and s.m[y * W + x] end
local function rectS(x0, y0, x1, y1, s)
  s = s or S()
  for y = y0, y1 do for x = x0, x1 do sAdd(s, x, y) end end
  return s
end
local function polyS(pts, s)
  s = s or S()
  local y0, y1 = 1e9, -1e9
  for _, p in ipairs(pts) do y0 = min(y0, p[2]); y1 = max(y1, p[2]) end
  local n = #pts
  for y = floor(y0), math.ceil(y1) do
    local yc = y + 0.5
    local xs = {}
    for i = 1, n do
      local a, b = pts[i], pts[i % n + 1]
      if (a[2] <= yc and b[2] > yc) or (b[2] <= yc and a[2] > yc) then
        xs[#xs + 1] = a[1] + (yc - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = math.ceil(xs[i] - 0.5), floor(xs[i + 1] - 0.5) do sAdd(s, x, y) end
    end
  end
  return s
end
local function octS(cx, cy, r, s)
  s = s or S()
  for dy = -r, r do for dx = -r, r do
    if abs(dx) + abs(dy) <= r + floor(r / 2) then sAdd(s, cx + dx, cy + dy) end
  end end
  return s
end
local function each(s, fn) for k in pairs(s.m) do fn(k % W, k // W) end end
local function fill(s, col) each(s, function(x, y) P(x, y, col) end) end
local function edge(s, col)
  local out = {}
  each(s, function(x, y)
    if not (has(s, x - 1, y) and has(s, x + 1, y) and has(s, x, y - 1) and has(s, x, y + 1)) then out[#out + 1] = { x, y } end
  end)
  for _, p in ipairs(out) do P(p[1], p[2], col) end
end
local function bbox(s)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  each(s, function(x, y) x0 = min(x0, x); y0 = min(y0, y); x1 = max(x1, x); y1 = max(y1, y) end)
  return x0, y0, x1, y1
end
-- lit-from-upper-left ramp painting by relative position in the bbox
local function shadeFill(s, r, opt)
  opt = opt or {}
  local x0, y0, x1, y1 = bbox(s)
  local w, h = max(1, x1 - x0), max(1, y1 - y0)
  each(s, function(x, y)
    local v = 1 - ((x - x0) / w * 0.6 + (y - y0) / h * 0.4)
    v = v + (hsh(x, y, opt.seed or 1) - 0.5) * (opt.noise or 0.15)
    local col = v > 0.78 and r.hi or (v > 0.42 and r.base or (v > 0.18 and r.shade or (r.deep2 or r.shade)))
    if opt.lite and v > 0.93 then col = r.lite or r.hi end
    P(x, y, col)
  end)
  edge(s, r.deep)
end
local function rec(x, y, t) return x + (VP[1] - x) * t, y + (VP[2] - y) * t end
local function hex2(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function darken(h, f)
  local r, g, b = hex2(h)
  r = floor(r * f); g = floor(g * f * 0.94); b = floor(min(255, b * f * 1.08 + 6))
  return string.format("#%02x%02x%02x", max(8, r), max(8, g), max(8, b))
end

-- ramps -------------------------------------------------------------------
local WOOD   = { deep = "#4e3322", shade = "#7a5234", base = "#a37046", hi = "#c99566", lite = "#e3b886" }
local PLANK  = { deep = "#8a6446", shade = "#b8916a", base = "#dcb98c", hi = "#ecd2a8", lite = "#f6e4c4" }
local LIB    = { deep = "#235a60", shade = "#3f8e8a", base = "#6cc2b2", hi = "#9de2cf", lite = "#cdf3e6" }
local TEA    = { deep = "#843443", shade = "#c25a68", base = "#ee8e8c", hi = "#f7b7a9", lite = "#fcdccd" }
local SHOP   = { deep = "#86621a", shade = "#c49530", base = "#f1cb52", hi = "#f9e286", lite = "#fdf1c0" }
local BAND   = { deep = "#45337a", shade = "#7360ae", base = "#a48cdc", hi = "#c9b6f0", lite = "#e6dcfa" }
local STRAW  = { deep = "#74501f", shade = "#a8772f", base = "#d6a650", hi = "#ebc674", lite = "#f6e2a2" }
local STRAW2 = { deep = "#6b3f1c", shade = "#9c6630", base = "#c98d48", hi = "#e2b06a", lite = "#f0d29a" }
local TIN    = { deep = "#1d566a", shade = "#2c8396", base = "#47b3bd", hi = "#86dcd8", lite = "#c4f1ea" }
local CORK   = { deep = "#6e4126", shade = "#a0663c", base = "#c98f5a", hi = "#e2b27c" }
local BAMBOO = { deep = "#6a4d1e", shade = "#9c7a30", base = "#c9a446", hi = "#e6c86a", lite = "#f3e2a0" }
local GRASS  = { deep = "#2a6e3a", shade = "#43994a", base = "#72c656", hi = "#a3e36c" }
local LEAF   = { deep = "#1b5a3d", shade = "#2e8a4f", base = "#4cb85a", hi = "#86dc6a", rib = "#bfe680" }
local TRUNK  = { deep = "#5e3f26", shade = "#8a6040", base = "#b48555", hi = "#d6aa74" }
local NUT    = { deep = "#43281b", shade = "#6e4630", base = "#8f5f3d", hi = "#b9875a" }
local CHROME = { deep = "#4e5670", shade = "#8a93ad", base = "#c3cade", hi = "#e8ecf5" }
local SAND   = { base = "#f2deb0", hi = "#f9ecc8", shade = "#e4cb94", ripple = "#e8d29f" }
local SH1, SH2 = "#d2b9aa", "#b39db0"
local INK_IN = "#3a2a3a"
local CREAM = "#f6ecd6"

-- painters ----------------------------------------------------------------
local function wallPaint(s, r, plank)
  plank = plank or 4
  each(s, function(x, y)
    local col = r.base
    local row = y // plank
    if (y % plank) == 0 then col = r.shade
    elseif ((x + row * 7) % 23) == 0 then col = r.shade
    else
      local h = hsh(x, y, 3)
      if h < 0.07 then col = r.shade elseif h > 0.93 then col = r.hi end
      if (y % plank) == 1 and hsh(x, row, 4) > 0.6 then col = r.hi end
    end
    P(x, y, col)
  end)
end
local function thatchPaint(s, r, dark)
  local x0, y0, x1, y1 = bbox(s)
  each(s, function(x, y)
    local layer = (y - y0) // 4
    local rr = (y - y0) % 4
    local h = hsh(x, layer, 5)
    local col
    if rr == 3 then col = r.shade elseif h < 0.25 then col = r.shade elseif h > 0.8 then col = r.hi else col = r.base end
    if hsh(x, y, 9) > 0.95 then col = r.lite end
    local f = (x - x0) / max(1, x1 - x0)
    if dark or f > 0.68 then
      if col == r.lite or col == r.hi then col = r.base elseif col == r.base then col = r.shade else col = r.deep end
    end
    P(x, y, col)
  end)
  edge(s, r.deep)
end
local function tinPaint(s, r, dark)
  each(s, function(x, y)
    local m = x % 4
    local col = (m == 0) and r.shade or (m == 1 and r.hi or r.base)
    if hsh(x, y, 21) > 0.97 then col = "#c9764a" end -- a rust freckle
    if dark then col = (col == r.hi) and r.base or r.shade end
    P(x, y, col)
  end)
  edge(s, r.deep)
end
local function fringe(xa, xb, y, r)
  for x = floor(xa), floor(xb) do
    local L = 1 + floor(hsh(x, y, 11) * 3)
    for k = 1, L do P(x, y + k, k == L and r.deep or r.shade) end
  end
end
local function shadowBox(x0, x1, y0, y1)
  for y = y0, y1 do
    local ins = (y == y0 or y == y1) and 3 or 0
    for x = x0 + ins, x1 - ins do
      local inner = y > y0 and y < y1 and x > x0 + 3 and x < x1 - 3
      P(x, y, inner and SH2 or SH1)
    end
  end
end
local function window(x, y, w, h, shut)
  R(x - 1, y - 1, x + w, y + h, CREAM)
  R(x, y, x + w - 1, y + h - 1, "#2c5d6e")
  for i = 0, min(w, h) - 2 do P(x + 1 + i, y + h - 2 - i, (i % 3 == 0) and "#7fc4d0" or nil) end
  R(x + w // 2, y, x + w // 2, y + h - 1, CREAM)
  R(x, y + h // 2, x + w - 1, y + h // 2, CREAM)
  if shut then
    for _, sx in ipairs({ x - 5, x + w + 1 }) do
      local s = rectS(sx, y - 1, sx + 3, y + h)
      each(s, function(px, py) P(px, py, (py % 2 == 0) and shut.shade or shut.base) end)
      edge(s, shut.deep)
    end
  end
  local fr = rectS(x - 1, y - 1, x + w, y + h)
  edge(fr, "#7a6a5e")
  R(x - 2, y + h + 1, x + w + 1, y + h + 2, WOOD.base); R(x - 2, y + h + 2, x + w + 1, y + h + 2, WOOD.deep)
end
local function door(x, y, w, h, r)
  local s = rectS(x, y, x + w - 1, y + h - 1)
  each(s, function(px, py) P(px, py, ((px - x) % 3 == 0) and r.shade or (hsh(px, py, 2) > 0.9 and r.hi or r.base)) end)
  edge(s, r.deep)
  P(x + w - 3, y + h // 2, "#f2c94c")
end
local function coconut(cx, cy, r)
  local s = octS(cx, cy, r)
  each(s, function(x, y)
    local v = (x - cx) + (y - cy)
    P(x, y, v < -r * 0.6 and NUT.hi or (v < r * 0.5 and NUT.base or NUT.shade))
  end)
  edge(s, NUT.deep)
end

-- palm fronds and trunks ----------------------------------------------------
local function frond(cx, cy, ang, len, droop, wmax, L)
  L = L or LEAF
  local s, cm = S(), {}
  local a = math.rad(ang)
  local dx, dy = cos(a), sin(a)
  local steps = floor(len * 2.5)
  for i = 0, steps do
    local t = i / steps
    local px = cx + dx * len * t
    local py = cy + dy * len * t + droop * t * t
    local tx, ty = dx * len, dy * len + 2 * droop * t
    local tl = sqrt(tx * tx + ty * ty); tx, ty = tx / tl, ty / tl
    local nx, ny = -ty, tx
    local w = wmax * ((1 - t) ^ 0.6) * min(1, t * 5 + 0.2)
    local notch = (floor(t * len) % 3 == 0)
    local sv = -w
    while sv <= w do
      if not (notch and abs(sv) > w * 0.55 and abs(sv) > 1.2) then
        local qx = px + nx * sv - tx * abs(sv) * 0.45
        local qy = py + ny * sv - ty * abs(sv) * 0.45
        local fx, fy = floor(qx), floor(qy)
        if fx >= 0 and fx < W and fy >= 0 and fy < H then
          sAdd(s, fx, fy)
          local up = (ny * sv) < 0 or (abs(ny) < 0.2 and nx * sv < 0)
          local col
          if abs(sv) < 0.6 then col = L.rib
          elseif up then col = (abs(sv) < w * 0.45 or hsh(fx, fy, 6) > 0.8) and L.hi or L.base
          else col = (abs(sv) > w * 0.7) and L.deep or L.shade end
          cm[fy * W + fx] = col
        end
      end
      sv = sv + 0.5
    end
  end
  for k, col in pairs(cm) do P(k % W, k // W, col) end
  edge(s, L.deep)
end
local function bez(p0, p1, p2, t)
  local u = 1 - t
  return u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1], u * u * p0[2] + 2 * u * t * p1[2] + t * t * p2[2]
end
local function trunk(p0, p1, p2, w0, w1, r)
  local s, cm = S(), {}
  for i = 0, 300 do
    local t = i / 300
    local x, y = bez(p0, p1, p2, t)
    local w = w0 + (w1 - w0) * t
    local dx = -w
    while dx <= w do
      local fx, fy = floor(x + dx), floor(y)
      sAdd(s, fx, fy)
      local f = (dx + w) / (2 * w)
      local col = f < 0.3 and r.hi or (f < 0.66 and r.base or r.shade)
      if fy % 5 == 0 then col = (col == r.hi) and r.base or r.deep
      elseif fy % 5 == 1 and f < 0.5 then col = r.hi end
      cm[fy * W + fx] = col
      dx = dx + 0.5
    end
  end
  for k, col in pairs(cm) do P(k % W, k // W, col) end
  edge(s, r.deep)
end
local function palm(base, ctrl, crown, w0, w1, fr, scale)
  trunk(base, ctrl, crown, w0, w1, TRUNK)
  for _, f in ipairs(fr) do frond(crown[1], crown[2], f[1], f[2] * scale, f[3] * scale, f[4] or 4.5 * scale) end
end

-- cottage on stilts ----------------------------------------------------------
local function cottage(o)
  local x0, x1, top, base = o.x0, o.x1, o.top, o.base
  local g = base + o.stilt
  local t = o.t
  local sx = (o.side == "r") and x1 or x0
  local ax, ay = rec(sx, top, t)
  local bx, by = rec(sx, base, t)
  -- ground shadow (light from upper left, falls right)
  shadowBox(min(x0, bx) + 2, max(x1, bx) + 9, g - 2, g + 4)
  -- back stilt at the receded corner
  local gx, gy = rec(sx, g, t)
  local bp = rectS(floor(bx) - 1, floor(by), floor(bx) + 1, floor(gy))
  fill(bp, WOOD.shade); edge(bp, WOOD.deep)
  -- side wall
  local side = polyS{ { sx, top }, { ax, ay }, { bx, by }, { sx, base } }
  each(side, function(x, y)
    local col = (y % 4 == 0) and o.wall.deep or o.wall.shade
    if col == o.wall.shade and hsh(x, y, 7) > 0.92 then col = o.wall.base end
    P(x, y, col)
  end)
  edge(side, o.wall.deep)
  -- roof side plane
  local ov = o.ov or 5
  local mid = floor((x0 + x1) / 2)
  local pk = top - o.rh
  local e1, e2 = { x0 - ov, top + 3 }, { x1 + ov, top + 3 }
  local ee = (o.side == "r") and e2 or e1
  local p1x, p1y = rec(mid, pk, t)
  local p2x, p2y = rec(ee[1], ee[2], t)
  local rs = polyS{ { mid, pk }, { p1x, p1y }, { p2x, p2y }, ee }
  if o.tin then tinPaint(rs, o.roof, true) else thatchPaint(rs, o.roof, true) end
  -- front wall
  local front = rectS(x0, top, x1, base)
  wallPaint(front, o.wall)
  for y = top, top + 2 do for x = x0, x1 do P(x, y, (y == top + 2) and o.wall.shade or darken(o.wall.shade, 0.85)) end end
  edge(front, o.wall.deep)
  -- stilts and deck
  for _, px in ipairs({ x0 + 2, mid - 1, x1 - 4 }) do
    local st = rectS(px, base + 1, px + 2, g)
    each(st, function(x, y) P(x, y, (x == px) and WOOD.hi or (x == px + 1 and WOOD.base or WOOD.shade)) end)
    edge(st, WOOD.deep)
    for k = 1, 2 do P(px + k - 1, g - 1, WOOD.deep) end
  end
  local dk = rectS(x0 - 3, base + 1, x1 + 3, base + 3)
  each(dk, function(x, y) P(x, y, (y == base + 1) and PLANK.hi or ((x % 6 == 0) and PLANK.shade or PLANK.base)) end)
  edge(dk, PLANK.deep)
  -- gable roof
  local gs = polyS{ { mid, pk }, e2, e1 }
  if o.tin then tinPaint(gs, o.roof) else thatchPaint(gs, o.roof) end
  fringe(e1[1], e2[1], e1[2], o.roof)
  local gi = polyS{ { mid, pk + o.inset }, { x1 - 5, top + 2 }, { x0 + 5, top + 2 } }
  wallPaint(gi, o.gable or o.wall, 3)
  edge(gi, (o.gable or o.wall).deep)
  return { mid = mid, pk = pk, g = g }
end

-- 1. SKY ------------------------------------------------------------------
local skyc = { "#3a8ad6", "#4a9de0", "#5eb0e8", "#78c2ef", "#94d3f3", "#b2e2f6", "#cdeef7" }
local skyy = { 0, 22, 40, 56, 70, 82, 93, 104 }
for i = 1, #skyc do R(0, skyy[i], W - 1, skyy[i + 1] - 1, skyc[i]) end
local function cloud(x, y, w)
  local s = S()
  rectS(floor(x + w * 0.06), floor(y - w * 0.12), floor(x + w * 0.94), y, s)
  octS(floor(x + w * 0.24), floor(y - w * 0.16), floor(w * 0.16), s)
  octS(floor(x + w * 0.48), floor(y - w * 0.26), floor(w * 0.22), s)
  octS(floor(x + w * 0.74), floor(y - w * 0.15), floor(w * 0.15), s)
  local x0, y0, x1, y1 = bbox(s)
  each(s, function(px, py)
    local col = "#f8f5ee"
    if py >= y - 2 then col = "#c4d6ec"
    elseif py >= y - w * 0.1 then col = "#e1eaf5"
    elseif (px - x0) / (x1 - x0) > 0.75 and hsh(px, py, 8) > 0.4 then col = "#e1eaf5" end
    P(px, py, col)
  end)
  edge(s, "#9db7da")
end
cloud(70, 58, 64)
cloud(176, 42, 52)
cloud(292, 50, 84)
cloud(396, 70, 46)
cloud(130, 86, 34)

-- 2. FAR ISLANDS + SEA -----------------------------------------------------
local function island(xa, xb, peak, py, s2)
  local s = S()
  for x = xa, xb do
    local u = (x - xa) / (xb - xa)
    local hgt = (sin(u * math.pi) ^ 1.3) * (104 - py) + sin(x / 5 + s2) * 1.5 + (s2 > 1 and -sin(u * math.pi * 2.6) * 4 or 0)
    for y = floor(104 - hgt), 104 do sAdd(s, x, y) end
  end
  each(s, function(x, y)
    local col = (y < 100 - (x % 7 == 0 and 2 or 0)) and "#5aa592" or "#4a8f84"
    if hsh(x, y, 12) > 0.9 then col = "#6fb89c" end
    if x > peak then col = (col == "#6fb89c") and "#5aa592" or "#4a8f84" end
    P(x, y, col)
  end)
  edge(s, "#3d7570")
end
island(96, 206, 150, 84, 0.3)
island(282, 384, 330, 80, 2.0)
-- tiny far palms on the ridges
for _, fp in ipairs({ { 132, 90 }, { 168, 92 }, { 312, 88 }, { 352, 90 } }) do
  R(fp[1], fp[2], fp[1], fp[2] + 6, "#3d7570")
  for _, d in ipairs({ { -3, 1 }, { -2, 0 }, { -1, -1 }, { 1, -1 }, { 2, 0 }, { 3, 1 } }) do P(fp[1] + d[1], fp[2] + d[2], "#3d7570") end
end
local function shore(x) return 120 + floor(2 * sin(x / 13)) end
for x = 0, W - 1 do
  local sy = shore(x)
  for y = 104, sy do
    local col = (y < 108) and "#2a8fb8" or (y < 112 and "#36aac4" or (y < 117 and "#4cc6cc" or "#6fdcd0"))
    if hsh(x // 3, y, 14) > 0.93 then col = "#c8f6ee" end
    if y >= sy - 1 then col = "#eefaf2" end
    P(x, y, col)
  end
end
-- 3. SAND ------------------------------------------------------------------
for x = 0, W - 1 do
  local sy = shore(x)
  P(x, sy + 1, "#e0c48e")
  for y = sy + 2, H - 1 do
    local col = SAND.base
    local h = hsh(x, y, 15)
    if h > 0.94 then col = SAND.hi elseif h < 0.05 then col = SAND.shade end
    if ((y + floor(3 * sin(x / 9 + y / 31))) % 13 == 0) and hsh(x // 4, y, 16) > 0.35 then col = SAND.ripple end
    P(x, y, col)
  end
end
-- pier into the sea (to the vanishing point)
local pier = polyS{ { 234, 108 }, { 246, 108 }, { 247, 121 }, { 233, 121 } }
each(pier, function(x, y) P(x, y, (y % 2 == 0) and PLANK.shade or PLANK.base) end)
edge(pier, PLANK.deep)
for _, px in ipairs({ 234, 245 }) do R(px, 109, px, 113, WOOD.deep) end
-- boardwalk street
local bw = polyS{ { 150, 269 }, { 330, 269 }, { 247, 120 }, { 233, 120 } }
local lines = {}
for k = 0, 26 do lines[floor(120 + 149 * (k / 26) ^ 1.6)] = true end
each(bw, function(x, y)
  local col = PLANK.base
  if lines[y] then col = PLANK.shade
  else
    local h = hsh(x, y, 17)
    if h > 0.93 then col = PLANK.hi elseif h < 0.06 then col = PLANK.shade end
    if hsh(x // 6, y, 18) > 0.92 then col = PLANK.lite end
  end
  P(x, y, col)
end)
edge(bw, PLANK.deep)
-- side rails of the boardwalk
for y = 121, 269 do
  local u = (y - 120) / 149
  local xl, xr = floor(233 - 83 * u), floor(247 + 83 * u)
  P(xl + 1, y, PLANK.deep); P(xr - 1, y, PLANK.deep)
  if y % 2 == 0 then P(xl + 2, y, PLANK.shade) end
end

-- 4. BACK PALM + BOAT ------------------------------------------------------
local function miniPalm(x, gy, h)
  shadowBox(x - 1, x + 10, gy - 1, gy + 2)
  trunk({ x, gy }, { x, gy - h * 0.5 }, { x + 3, gy - h }, 1.5, 1, TRUNK)
  for _, a in ipairs({ -165, -130, -95, -55, -20, 15, 160 }) do frond(x + 3, gy - h, a, 11, 4, 2.5) end
end
miniPalm(116, 122, 22)
-- boat with a patchwork sail (quirk)
local hull = polyS{ { 302, 111 }, { 325, 111 }, { 321, 117 }, { 306, 117 } }
each(hull, function(x, y) P(x, y, (y == 113) and "#f6c445" or (y < 113 and TIN.hi or TIN.base)) end)
edge(hull, TIN.deep)
R(313, 92, 313, 110, WOOD.deep)
local sail = polyS{ { 315, 93 }, { 315, 109 }, { 327, 109 } }
local patch = { "#ef6f62", "#f6e4c4", "#f6c445", "#c9b6f0", "#86dcd8" }
each(sail, function(x, y) P(x, y, patch[((x // 3) + (y // 4)) % #patch + 1]) end)
edge(sail, "#7a5a6a")

-- 5. LIBRARY (far left) ------------------------------------------------------
local lib = cottage{ x0 = 36, x1 = 84, top = 100, base = 128, stilt = 10, t = 0.13, side = "r",
  wall = LIB, roof = STRAW, rh = 28, ov = 5, inset = 8, gable = { deep = "#2d4f6e", shade = "#4f7fa6", base = "#7fb0d6", hi = "#b0d4ee" } }
window(44, 108, 12, 10, { deep = "#843443", shade = "#c25a68", base = "#ee8e8c" })
-- book spines visible in the window
for i = 0, 11 do
  local sc = ({ "#c8424f", "#f6c445", "#4f7fa6", "#8fd35a", "#a48cdc" })[i % 5 + 1]
  if i ~= 6 then R(44 + i, 113 + (i % 2), 44 + i, 117, sc) end
end
door(66, 110, 11, 18, WOOD)
-- ladder steps down
for y = 131, 137, 3 do R(66, y, 76, y, WOOD.base); P(66, y, WOOD.deep); P(76, y, WOOD.deep) end
R(65, 129, 65, 138, WOOD.deep); R(77, 129, 77, 138, WOOD.deep)
-- flower box with hibiscus
R(40, 121, 58, 124, WOOD.base); R(40, 124, 58, 124, WOOD.deep)
for x = 41, 57, 4 do P(x, 120, "#e8414f"); P(x + 1, 120, "#f37a6a"); P(x, 119, "#e8414f"); P(x + 2, 120, GRASS.base) end
-- BIG BOOK SIGN on the gable
local cov = polyS{ { 46, 87 }, { 60, 91 }, { 74, 87 }, { 74, 99 }, { 60, 102 }, { 46, 99 } }
fill(cov, "#c8424f"); edge(cov, "#6e1f2e")
local pgL = polyS{ { 48, 86 }, { 59, 89 }, { 59, 99 }, { 48, 96 } }
local pgR = polyS{ { 61, 89 }, { 72, 86 }, { 72, 96 }, { 61, 99 } }
each(pgL, function(x, y) P(x, y, ((y - floor((x - 48) * 0.27)) % 2 == 0 and x > 49 and x < 58) and "#c9b89c" or "#fbf3df") end)
each(pgR, function(x, y) P(x, y, ((y + floor((x - 61) * 0.27)) % 2 == 0 and x > 62 and x < 71) and "#c9b89c" or "#efe2c6") end)
edge(pgL, "#8a7a64"); edge(pgR, "#8a7a64")
R(60, 89, 60, 100, "#6e1f2e")
R(64, 98, 65, 104, "#e8b23c") -- ribbon bookmark (quirk-ish)
P(64, 105, "#a8762a")

-- coconut zipline between library and board (quirk)
for x = 96, 146 do
  local u = (x - 96) / 50
  P(x, floor(84 + 8 * u + 7 * 4 * u * (1 - u)), "#7a5a3a")
end
R(120, 93, 120, 95, "#7a5a3a")
local bk = rectS(115, 96, 125, 101)
each(bk, function(x, y) P(x, y, ((x + y) % 2 == 0) and STRAW.base or STRAW.shade) end)
edge(bk, STRAW.deep)
coconut(117, 95, 2); coconut(122, 94, 2)

-- 6. NOTICE BOARD --------------------------------------------------------------
shadowBox(134, 170, 169, 175)
for _, px in ipairs({ 135, 157 }) do
  local st = rectS(px, 100, px + 2, 172)
  each(st, function(x, y) P(x, y, (x == px) and BAMBOO.hi or (x == px + 1 and BAMBOO.base or BAMBOO.shade)) end)
  for y = 108, 172, 12 do P(px, y, BAMBOO.deep); P(px + 1, y, BAMBOO.deep); P(px + 2, y, BAMBOO.deep) end
  edge(st, BAMBOO.deep)
end
local bd = rectS(131, 104, 163, 154)
each(bd, function(x, y)
  local col = CORK.base
  local h = hsh(x, y, 19)
  if h > 0.85 then col = CORK.hi elseif h < 0.18 then col = CORK.shade end
  if x <= 132 or x >= 162 or y <= 105 or y >= 153 then col = BAMBOO.base end
  P(x, y, col)
end)
edge(bd, CORK.deep)
local cap = polyS{ { 126, 106 }, { 168, 106 }, { 147, 89 } }
thatchPaint(cap, STRAW2)
fringe(126, 168, 106, STRAW2)
local papers = {
  { 135, 109, 145, 120, "#fbe58a" }, { 148, 108, 159, 116, "#f7b7a9" }, { 136, 123, 147, 134, "#b9ecd9" },
  { 150, 119, 159, 131, "#d8c8f4" }, { 136, 138, 146, 150, "#fcd9b8" }, { 149, 134, 159, 150, "#bfe2f6" } }
for i, p in ipairs(papers) do
  local s = rectS(p[1], p[2], p[3], p[4])
  fill(s, p[5])
  for y = p[2] + 3, p[4] - 2, 2 do R(p[1] + 2, y, p[3] - 2 - (y % 3), y, darken(p[5], 0.62)) end
  edge(s, darken(p[5], 0.5))
  P(floor((p[1] + p[3]) / 2), p[2], ({ "#e8414f", "#2c8396", "#f6c445" })[i % 3 + 1])
  P(floor((p[1] + p[3]) / 2), p[2] + 1, "#7a2030")
end
-- a curled corner on one paper
P(159, 150, CORK.base); P(158, 150, "#8fb6cc"); P(159, 149, "#8fb6cc")

-- 7. PALM GREEN (hero, centre) ------------------------------------------------
shadowBox(186, 304, 196, 202)
local kerb = polyS{ { 184, 190 }, { 296, 190 }, { 296, 197 }, { 184, 197 } }
each(kerb, function(x, y)
  local row = (y - 190) // 3
  local col = ((x + row * 4) % 8 == 0) and "#c96a5a" or (y == 190 and "#f8c3aa" or "#ee9a82")
  if y > 194 and col ~= "#c96a5a" then col = "#d97c68" end
  P(x, y, col)
end)
edge(kerb, "#8a3b3a")
local lawn = polyS{ { 198, 164 }, { 282, 164 }, { 296, 190 }, { 184, 190 } }
each(lawn, function(x, y)
  local col = GRASS.base
  local h = hsh(x, y, 22)
  if h > 0.86 then col = GRASS.hi elseif h < 0.16 then col = GRASS.shade end
  if hsh(x, y // 2, 23) > 0.93 then P(x, y - 1, GRASS.hi) end
  if y > 186 then col = (col == GRASS.hi) and GRASS.base or GRASS.shade end
  P(x, y, col)
end)
edge(lawn, GRASS.deep)
-- hibiscus border
for i, x in ipairs({ 190, 202, 278, 290 }) do
  local y = 186
  local pc = (i % 2 == 0) and "#f37ab0" or "#e8414f"
  P(x, y - 1, pc); P(x - 1, y, pc); P(x + 1, y, pc); P(x, y + 1, pc); P(x, y, "#f6c445")
  P(x + 2, y + 1, GRASS.deep); P(x - 2, y + 1, GRASS.deep)
end
-- trunk shadows on the lawn
R(226, 186, 236, 188, GRASS.deep); R(264, 186, 272, 188, GRASS.deep)
-- palms
palm({ 226, 187 }, { 230, 130 }, { 212, 84 }, 4, 2.5, {
  { -165, 36, 14 }, { -130, 30, 6 }, { -100, 22, 2 }, { -62, 30, 6 }, { -25, 36, 14 }, { 8, 32, 20 }, { 168, 30, 20 }, { 140, 22, 18 } }, 1)
palm({ 266, 187 }, { 264, 140 }, { 278, 92 }, 3.5, 2.5, {
  { -158, 30, 12 }, { -118, 26, 5 }, { -84, 20, 2 }, { -48, 28, 8 }, { -14, 30, 14 }, { 22, 26, 18 }, { 160, 26, 18 } }, 1)
coconut(210, 88, 2); coconut(215, 89, 2); coconut(212, 92, 2)
coconut(276, 96, 2); coconut(281, 96, 2)
-- hammock (quirk: a straw hat left in it)
local hs = S()
local hy = {}
for x = 230, 262 do
  local u = (x - 230) / 32
  local yc = floor(146 + 4 * u + 12 * u * (1 - u))
  hy[x] = yc
  for y = yc, yc + 3 do sAdd(hs, x, y) end
end
local stripes = { "#ef6f62", "#f6c445", "#3fbfb8", "#f6e4c4" }
each(hs, function(x, y) P(x, y, stripes[(x // 3) % 4 + 1]) end)
edge(hs, "#6b3a4a")
for i = 0, 3 do P(228 - i, 145 - i, "#d8c08a"); P(264 + i, 149 - i, "#d8c08a") end
local hx = 246
local hat = rectS(hx - 6, hy[hx] - 2, hx + 6, hy[hx] - 1)
rectS(hx - 3, hy[hx] - 5, hx + 3, hy[hx] - 2, hat)
each(hat, function(x, y) P(x, y, (y == hy[hx] - 3 and abs(x - hx) <= 3) and "#e8414f" or (x < hx and STRAW.hi or STRAW.base)) end)
edge(hat, STRAW.deep)
-- coconut planting patch (quirk: plant a coconut for your grandchildren)
local soil = rectS(238, 176, 258, 181)
each(soil, function(x, y) P(x, y, (hsh(x, y, 24) > 0.6) and "#8a5a3c" or "#6e4630") end)
edge(soil, "#43281b")
coconut(243, 177, 2)
R(244, 171, 244, 175, GRASS.shade); P(242, 171, GRASS.hi); P(243, 170, GRASS.hi); P(245, 170, GRASS.base); P(246, 171, GRASS.base)
-- older sprouts in a row (generations)
R(252, 168, 252, 177, GRASS.shade); P(250, 168, GRASS.hi); P(251, 167, GRASS.hi); P(253, 167, GRASS.base); P(254, 168, GRASS.base); P(252, 166, GRASS.hi)
-- tiny marker stakes with ribbons
for _, sx in ipairs({ 239, 256 }) do R(sx, 170, sx, 180, WOOD.deep); P(sx + 1, 170, "#f37ab0"); P(sx + 2, 171, "#f37ab0") end

-- 8. SHOPS (seed shop, far right) -------------------------------------------
local sh = cottage{ x0 = 344, x1 = 406, top = 98, base = 126, stilt = 8, t = 0.13, side = "l",
  wall = SHOP, roof = TIN, tin = true, rh = 28, ov = 5, inset = 8, gable = { deep = "#5a6a2a", shade = "#8aa040", base = "#b9d06a", hi = "#d8e894" } }
-- open shop front
R(348, 112, 402, 120, "#5a3a44")
for x = 350, 400, 6 do R(x, 113, x + 3, 116, ({ "#f6c445", "#8fd35a", "#ef6f62", "#86dcd8" })[(x // 6) % 4 + 1]) end
R(348, 117, 402, 117, WOOD.deep)
-- counter with seed baskets
R(346, 121, 404, 124, WOOD.base); R(346, 121, 404, 121, WOOD.hi); R(346, 124, 404, 124, WOOD.deep)
local seeds = { { "#c8424f", "#e8717a" }, { "#f6c445", "#fbe58a" }, { "#5aa04a", "#8fd35a" } }
for i, bx in ipairs({ 351, 369, 387 }) do
  local b = rectS(bx, 118, bx + 12, 123)
  each(b, function(x, y) P(x, y, ((x + y) % 2 == 0) and STRAW.base or STRAW.shade) end)
  edge(b, STRAW.deep)
  for x = bx + 1, bx + 11 do
    local top = 117 - floor(2 * sin((x - bx) / 12 * math.pi))
    for y = top, 117 do P(x, y, (hsh(x, y, 25) > 0.5) and seeds[i][1] or seeds[i][2]) end
  end
end
-- striped awning
local aw = polyS{ { 340, 105 }, { 410, 105 }, { 412, 111 }, { 338, 111 } }
each(aw, function(x, y) P(x, y, ((x // 5) % 2 == 0) and (y < 107 and "#f59a8c" or "#ef6f62") or (y < 107 and "#fdf6e6" or "#f2e6cc")) end)
for x = 338, 412 do local k = x % 5; if k ~= 0 and k ~= 4 then P(x, 112, ((x // 5) % 2 == 0) and "#c94a40" or "#d9caa8") end end
edge(aw, "#8a3b3a")
-- seedling-pot sign in the gable
local pot = polyS{ { 369, 91 }, { 381, 91 }, { 379, 98 }, { 371, 98 } }
each(pot, function(x, y) P(x, y, (y == 91) and "#f0a070" or (x < 375 and "#d9774a" or "#b25a38")) end)
edge(pot, "#6e3020")
R(375, 84, 375, 90, GRASS.deep)
local lf1 = polyS{ { 375, 86 }, { 369, 83 }, { 366, 85 }, { 370, 88 } }
local lf2 = polyS{ { 375, 85 }, { 380, 81 }, { 384, 83 }, { 379, 87 } }
fill(lf1, GRASS.hi); edge(lf1, GRASS.deep); fill(lf2, GRASS.base); edge(lf2, GRASS.deep)

-- 9. WILD TRAIL (right edge) -------------------------------------------------
local jg = polyS{ { 436, 128 }, { 438, 96 }, { 448, 86 }, { 462, 84 }, { 479, 88 }, { 479, 130 } }
each(jg, function(x, y) P(x, y, (hsh(x // 2, y // 2, 26) > 0.7) and "#2e7a4a" or "#1f5a3a") end)
edge(jg, "#163f2c")
local path = polyS{ { 436, 141 }, { 464, 141 }, { 479, 131 }, { 479, 124 }, { 456, 126 } }
each(path, function(x, y) P(x, y, (hsh(x, y, 27) > 0.85) and "#e7b98a" or (hsh(x, y, 28) < 0.1 and "#9a6a48" or "#c99a6a")) end)
edge(path, "#8a5a3c")
for _, f in ipairs({ { 446, 100, -150 }, { 456, 94, -60 }, { 470, 96, -120 }, { 474, 108, 170 }, { 440, 112, 160 }, { 466, 116, 20 } }) do
  frond(f[1], f[2], f[3], 14, 6, 3)
end
-- bamboo arch
for _, px in ipairs({ 441, 459 }) do
  local st = rectS(px, 96, px + 3, 141)
  each(st, function(x, y) P(x, y, (x == px) and BAMBOO.hi or (x <= px + 2 and BAMBOO.base or BAMBOO.shade)) end)
  for y = 104, 140, 9 do R(px, y, px + 3, y, BAMBOO.deep) end
  edge(st, BAMBOO.deep)
  shadowBox(px + 1, px + 9, 140, 143)
end
local lt = rectS(437, 92, 466, 96)
each(lt, function(x, y) P(x, y, (y == 93) and BAMBOO.hi or (y == 95 and BAMBOO.shade or BAMBOO.base)) end)
edge(lt, BAMBOO.deep)
for x = 438, 465, 3 do
  local L = 2 + floor(hsh(x, 1, 29) * 6)
  for y = 97, 96 + L do P(x, y, (y % 2 == 0) and LEAF.base or LEAF.shade) end
  if x % 2 == 0 then P(x, 97 + L, "#f37ab0") end
end
-- signpost with an arrow and a leaf icon
local sp = rectS(428, 104, 430, 142)
fill(sp, WOOD.base); R(428, 104, 428, 142, WOOD.hi); edge(sp, WOOD.deep)
local arrow = polyS{ { 424, 106 }, { 446, 106 }, { 452, 110 }, { 446, 115 }, { 424, 115 } }
each(arrow, function(x, y) P(x, y, (y == 107) and WOOD.lite or ((x + y * 3) % 9 == 0 and WOOD.shade or WOOD.hi)) end)
edge(arrow, WOOD.deep)
local lfi = polyS{ { 430, 111 }, { 434, 107 }, { 441, 108 }, { 437, 113 } }
fill(lfi, GRASS.base); edge(lfi, GRASS.deep); R(431, 110, 438, 110, GRASS.hi)
shadowBox(429, 438, 141, 144)

-- 10. TEAHOUSE: THE BREEZY HUT (near left) -------------------------------------
local tea = cottage{ x0 = 24, x1 = 92, top = 176, base = 214, stilt = 8, t = 0.12, side = "r",
  wall = TEA, roof = STRAW, rh = 30, ov = 6, inset = 9, gable = { deep = "#2d6a5a", shade = "#4fa08a", base = "#7fd0b4", hi = "#b6ecd6" } }
-- serving window with shelves
R(32, 184, 84, 198, "#5a3a44")
R(32, 184, 84, 185, "#3e2732")
R(33, 191, 83, 191, WOOD.base)
for x = 35, 81, 5 do R(x, 188, x + 2, 190, ({ "#f6c445", "#86dcd8", "#f7b7a9" })[(x // 5) % 3 + 1]) end
edge(rectS(31, 183, 85, 199), TEA.deep)
-- counter with coconut drinks
R(29, 199, 87, 203, WOOD.base); R(29, 199, 87, 199, WOOD.hi); R(29, 203, 87, 203, WOOD.deep); P(29, 200, WOOD.deep); P(87, 200, WOOD.deep)
for i, x in ipairs({ 40, 54, 68, 80 }) do
  coconut(x, 195, 3)
  P(x - 1, 193, "#f8f3e4"); P(x, 193, "#f8f3e4")
  local sc = ({ "#ef6f62", "#3fbfb8", "#f6c445", "#a48cdc" })[i]
  for k = 0, 4 do P(x + 1 + floor(k / 2), 192 - k, sc) end
end
-- shell wind chimes under the eave (quirk: the breeze)
for x = 30, 86, 8 do
  R(x, 180, x, 183 + (x % 3), "#7a5a3a")
  P(x, 184 + (x % 3), "#fcd9c8"); P(x - 1, 184 + (x % 3), "#f3a8a0"); P(x + 1, 184 + (x % 3), "#f3a8a0")
end
-- coconut-drink sign in the gable
coconut(58, 168, 6)
local flesh = rectS(54, 162, 62, 163)
fill(flesh, "#f8f3e4"); R(53, 164, 63, 164, NUT.deep)
for k = 0, 8 do P(60 + floor(k / 2), 162 - k, "#ef6f62") end
-- paper umbrella
local um = polyS{ { 62, 156 }, { 70, 156 }, { 66, 152 } }
fill(um, "#f6c445"); edge(um, "#a8762a"); P(66, 157, WOOD.deep); P(66, 158, WOOD.deep)
-- steps
for y = 216, 222, 3 do R(56, y, 66, y, WOOD.base); P(56, y, WOOD.deep); P(66, y, WOOD.deep) end

-- 11. BAND STAND (near right) -------------------------------------------------
shadowBox(372, 464, 216, 224)
-- floor (top surface) and lavender back lattice
local fl = polyS{ { 368, 206 }, { 454, 206 }, { 446, 199 }, { 376, 199 } }
each(fl, function(x, y) P(x, y, (y % 2 == 0) and PLANK.hi or PLANK.base) end)
edge(fl, PLANK.deep)
local bp = rectS(378, 176, 444, 199)
each(bp, function(x, y)
  local col = BAND.base
  if (x + y) % 6 == 0 or (x - y) % 6 == 0 then col = BAND.lite elseif hsh(x, y, 30) > 0.9 then col = BAND.hi end
  if x > 432 then col = (col == BAND.lite) and BAND.hi or BAND.shade end
  P(x, y, col)
end)
edge(bp, BAND.deep)
-- front deck face
local dkf = rectS(368, 206, 454, 216)
each(dkf, function(x, y) P(x, y, (y % 3 == 0) and BAND.shade or ((x % 9 == 0) and BAND.deep or BAND.base)) end)
edge(dkf, BAND.deep)
for x = 372, 450, 13 do R(x, 209, x + 6, 213, BAND.hi); R(x, 213, x + 6, 213, BAND.shade) end
-- steel drums, each a different island colour (quirk: every island its own rhythm)
local dcol = { { "#ef6f62", "#b84a40" }, { "#f6c445", "#b08a2a" }, { "#3fbfb8", "#2a8a84" } }
for i, dx in ipairs({ 382, 404, 426 }) do
  R(dx + 2, 198, dx + 2, 205, CHROME.deep); R(dx + 12, 198, dx + 12, 205, CHROME.deep)
  local body = rectS(dx, 188, dx + 14, 197)
  each(body, function(x, y)
    local col = (x < dx + 4) and CHROME.hi or (x < dx + 10 and CHROME.base or CHROME.shade)
    if y >= 191 and y <= 194 then col = (x < dx + 10) and dcol[i][1] or dcol[i][2] end
    P(x, y, col)
  end)
  edge(body, CHROME.deep)
  local topf = polyS{ { dx + 1, 187 }, { dx + 4, 185 }, { dx + 10, 185 }, { dx + 13, 187 }, { dx + 10, 189 }, { dx + 4, 189 } }
  fill(topf, CHROME.hi); edge(topf, CHROME.deep)
  P(dx + 6, 187, CHROME.shade); P(dx + 9, 186, CHROME.shade); P(dx + 7, 186, CHROME.base)
end
-- crossed sticks resting on the middle drum
for k = 0, 7 do P(406 + k, 181 + k // 2, WOOD.deep); P(418 - k, 181 + k // 2, WOOD.deep) end
P(405, 181, "#f37ab0"); P(419, 181, "#f37ab0")
-- posts
for _, px in ipairs({ 370, 449 }) do
  local st = rectS(px, 176, px + 3, 206)
  each(st, function(x, y) P(x, y, (x == px) and BAMBOO.hi or (x <= px + 2 and BAMBOO.base or BAMBOO.shade)) end)
  for y = 184, 204, 8 do R(px, y, px + 3, y, BAMBOO.deep) end
  edge(st, BAMBOO.deep)
end
-- pyramid thatch roof
local rf = polyS{ { 364, 179 }, { 462, 179 }, { 420, 154 }, { 404, 154 } }
thatchPaint(rf, STRAW2)
fringe(364, 462, 179, STRAW2)
R(411, 146, 412, 154, WOOD.deep)
local pen = polyS{ { 413, 146 }, { 421, 148 }, { 413, 151 } }
fill(pen, "#f37ab0"); edge(pen, "#9a3a6a")
-- rhythm flags on the roof edge, one per drum colour
for i, fx in ipairs({ 378, 404, 440 }) do
  local fy = 180 + 3
  local f = polyS{ { fx, fy }, { fx + 7, fy }, { fx + 3, fy + 6 } }
  fill(f, dcol[i][1]); edge(f, dcol[i][2])
end

-- 12. BEACH (bottom-left) -----------------------------------------------------
local wet = polyS{ { 16, 232 }, { 46, 238 }, { 66, 252 }, { 78, 269 }, { 16, 269 } }
each(wet, function(x, y) P(x, y, (hsh(x, y, 31) > 0.9) and SAND.hi or "#e6cb92") end)
local water = polyS{ { 16, 236 }, { 40, 241 }, { 58, 253 }, { 68, 269 }, { 16, 269 } }
each(water, function(x, y)
  local col = (x < 30) and "#36aac4" or (x < 46 and "#4cc6cc" or "#6fdcd0")
  if hsh(x // 3, y, 32) > 0.92 then col = "#c8f6ee" end
  P(x, y, col)
end)
edge(water, "#eefaf2")
-- little rowboat in the shallows
local rb = polyS{ { 20, 252 }, { 44, 252 }, { 40, 259 }, { 24, 259 } }
each(rb, function(x, y) P(x, y, (y == 254) and "#f6c445" or (y < 254 and "#f7b7a9" or "#ee8e8c")) end)
edge(rb, "#843443")
R(26, 251, 38, 251, WOOD.base)
-- driftwood log
local dw = polyS{ { 66, 250 }, { 112, 244 }, { 115, 249 }, { 69, 257 } }
each(dw, function(x, y)
  local col = (hsh(x // 3, y, 33) > 0.7) and "#d8c8b0" or "#b8a48a"
  if (x + y * 4) % 11 == 0 then col = "#8a7660" end
  P(x, y, col)
end)
edge(dw, "#5e4e40")
local stub = polyS{ { 92, 247 }, { 96, 238 }, { 98, 239 }, { 95, 247 } }
fill(stub, "#c8b49a"); edge(stub, "#5e4e40")
-- beach comb (rake) leaning on the log
for k = 0, 16 do P(100 + floor(k / 3), 232 + k, WOOD.base); P(101 + floor(k / 3), 232 + k, WOOD.shade) end
R(94, 231, 108, 232, WOOD.deep)
for x = 94, 108, 2 do P(x, 233, WOOD.deep) end
-- big conch shell icon
local conch = polyS{ { 34, 244 }, { 44, 240 }, { 52, 243 }, { 50, 248 }, { 38, 249 } }
-- (sits on the wet sand, beside the water)
conch = polyS{ { 52, 258 }, { 62, 253 }, { 72, 256 }, { 70, 262 }, { 56, 263 } }
each(conch, function(x, y) P(x, y, ((x - 52) % 4 == 0) and "#e8828a" or (y < 258 and "#fcd9c8" or "#f3a8a0")) end)
edge(conch, "#a84a5a")
P(70, 258, "#f8f3e4"); P(69, 259, "#f37ab0")
-- scattered shells
for _, s in ipairs({ { 84, 262, "#f7b7a9" }, { 100, 258, "#fcd9b8" }, { 114, 265, "#d8c8f4" }, { 90, 266, "#fbe58a" } }) do
  local f = polyS{ { s[1] - 3, s[2] + 2 }, { s[1], s[2] - 2 }, { s[1] + 3, s[2] + 2 } }
  fill(f, s[3]); P(s[1], s[2], "#f8f3e4"); edge(f, darken(s[3], 0.6))
end
-- tiny shell arch for the full-moon crab parade (quirk)
local arch = { { 108, 260 }, { 109, 257 }, { 111, 255 }, { 114, 254 }, { 117, 255 }, { 119, 257 }, { 120, 260 } }
for i, p in ipairs(arch) do P(p[1], p[2], (i % 2 == 0) and "#f7b7a9" or "#fcd9c8"); P(p[1], p[2] + 1, "#a84a5a") end
for x = 102, 122, 3 do P(x, 263, SAND.shade) end

-- 13. GATE FRAME (bamboo + thatch, this region's style) ------------------------
local function vPole(x0, x1)
  local s = rectS(x0, 0, x1, H - 1)
  local w = x1 - x0
  each(s, function(x, y)
    local f = (x - x0) / w
    local col = f < 0.25 and BAMBOO.hi or (f < 0.6 and BAMBOO.base or BAMBOO.shade)
    if f < 0.12 and y % 7 < 3 then col = BAMBOO.lite end
    if y % 30 == 0 then col = BAMBOO.deep elseif y % 30 == 1 then col = BAMBOO.hi end
    P(x, y, col)
  end)
  edge(s, BAMBOO.deep)
end
R(0, 0, 1, H - 1, "#5a4630"); R(478, 0, 479, H - 1, "#5a4630")
vPole(2, 14); vPole(465, 477)
local function hPole(y0, y1)
  local s = rectS(0, y0, W - 1, y1)
  each(s, function(x, y)
    local f = (y - y0) / (y1 - y0)
    local col = f < 0.3 and BAMBOO.hi or (f < 0.65 and BAMBOO.base or BAMBOO.shade)
    if x % 34 == 0 then col = BAMBOO.deep elseif x % 34 == 1 then col = BAMBOO.hi end
    P(x, y, col)
  end)
  edge(s, BAMBOO.deep)
end
hPole(0, 6); hPole(7, 13)
local thf = rectS(0, 14, W - 1, 19)
thatchPaint(thf, STRAW)
fringe(0, W - 1, 19, STRAW)
-- rope lashings at the corners
for _, lx in ipairs({ 2, 465 }) do
  for k = 0, 12 do P(lx + k, 6 + k, "#e3cf98"); P(lx + k, 7 + k, "#a88a52"); P(lx + 12 - k, 6 + k, "#e3cf98") end
end
-- vines with hibiscus on the posts
for i, y in ipairs({ 44, 74, 104, 134, 164, 194, 224 }) do
  for _, px in ipairs({ 8, 471 }) do
    local sgn = (i % 2 == 0) and 1 or -1
    frond(px, y, (sgn > 0) and 30 or 150, 9, 2, 2.5)
    if i % 2 == 1 then
      local fx, fy = px + ((px < 240) and 4 or -4), y + 8
      local pc = (i % 4 == 1) and "#e8414f" or "#f37ab0"
      P(fx, fy - 1, pc); P(fx - 1, fy, pc); P(fx + 1, fy, pc); P(fx, fy + 1, pc); P(fx, fy, "#f6c445")
      P(fx - 1, fy - 1, darken(pc, 0.6)); P(fx + 1, fy + 1, darken(pc, 0.6))
    end
  end
end
-- bunting
local bcols = { "#ef6f62", "#f6c445", "#3fbfb8", "#8fd35a", "#f39ac0", "#9b7fe0" }
local function by(x) local u = (x - 16) / 448 return 23 + floor(18 * 4 * u * (1 - u)) end
for x = 16, 463 do P(x, by(x), "#7a5a3a") end
local fi = 0
for fx = 26, 456, 15 do
  fi = fi + 1
  local y0 = by(fx)
  local f = polyS{ { fx - 4, y0 + 1 }, { fx + 4, by(fx + 4) + 1 }, { fx, y0 + 9 } }
  local col = bcols[(fi - 1) % #bcols + 1]
  each(f, function(x, y) P(x, y, (x < fx) and col or darken(col, 0.86)) end)
  edge(f, darken(col, 0.55))
end
-- hanging lanterns (warm glow)
local function lantern(cx)
  R(cx, 20, cx, 31, "#7a5a3a")
  R(cx - 4, 32, cx + 4, 34, WOOD.deep); R(cx - 3, 32, cx + 3, 32, WOOD.base)
  local s = polyS{ { cx - 4, 35 }, { cx + 5, 35 }, { cx + 7, 38 }, { cx + 7, 46 }, { cx + 5, 50 }, { cx - 4, 50 }, { cx - 6, 46 }, { cx - 6, 38 } }
  each(s, function(x, y)
    local dx = x - cx
    local col = "#f6a24a"
    if abs(dx) <= 1 and y >= 38 and y <= 47 then col = "#fff0b8"
    elseif abs(dx) <= 3 and y >= 37 and y <= 48 then col = "#fcd27a"
    elseif dx >= 4 then col = "#e0702f" end
    if (dx == -4 or dx == 4) and col ~= "#fff0b8" then col = (dx < 0) and "#f0904a" or "#c8562a" end
    P(x, y, col)
  end)
  edge(s, "#a8432a")
  R(cx - 4, 51, cx + 4, 52, WOOD.deep)
  R(cx, 53, cx, 58, "#e8414f"); P(cx - 1, 58, "#e8414f"); P(cx + 1, 58, "#e8414f")
  -- warm glow specks on the frame beam around it
  for _, d in ipairs({ { -9, 40 }, { 9, 43 }, { -8, 48 }, { 10, 36 } }) do P(cx + d[1], d[2], "#fde7a0") end
end
lantern(46); lantern(434)

-- output ----------------------------------------------------------------------
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { "green", "Palm Green", 176, 60, 308, 202 },
  { "tea", "The Breezy Hut", 16, 138, 118, 226 },
  { "board", "Notice Board", 125, 88, 169, 176 },
  { "library", "Library", 28, 66, 110, 140 },
  { "s1", "Beach", 14, 230, 124, 268 },
  { "s2", "Band", 362, 143, 466, 226 },
  { "shops", "Shops", 322, 64, 414, 138 },
  { "wild", "Wild Trail", 422, 80, 479, 142 },
}
local stand = { { 150, 214 }, { 240, 214 }, { 334, 214 }, { 196, 250 }, { 286, 250 }, { 334, 178 } }
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}',
    s[1], s[2], (s[3] + s[5]) // 2, (s[4] + s[6]) // 2, s[3], s[4], s[5], s[6])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write('{"w":480,"h":270,"horizon":104,"view":"gate","spots":[' .. table.concat(parts, ",") .. '],"stand":[' ..
  table.concat(st, ",") .. '],"compass_clear":[380,230,480,270]}\n')
f:close()
print("ok " .. NAME)

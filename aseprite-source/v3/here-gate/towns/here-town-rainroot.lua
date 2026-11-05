-- Hearth Pop v3 : "The Rainroot Reaches" gate view (480x270 native, hero scale)
-- Misty Andean highland town: stone-and-thatch houses, potato terraces, rope bridge, river canoes.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params["out"]) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local NAME = "here-town-rainroot"
local W, H = 480, 270
local VPX, VPY = 240, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }

---------------------------------------------------------------- core helpers
local buf = {}
local floor, abs, min, max = math.floor, math.abs, math.min, math.max
local function px(x, y, col)
  x = floor(x); y = floor(y)
  if x < 0 or y < 0 or x >= W or y >= H or not col then return end
  buf[y * W + x] = col; c:px(x, y, col)
end
local function at(x, y) if x < 0 or y < 0 or x >= W or y >= H then return nil end return buf[y * W + x] end
local function hash(x, y, s)
  local n = math.sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function hex(r, g, b)
  local function cl(v) v = floor(v + 0.5) if v < 8 then v = 8 end if v > 248 then v = 248 end return v end
  return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b))
end
local SC = {}
local function shade(h) -- cool violet shade
  if SC[h] then return SC[h] end
  local r, g, b = rgb(h); local o = hex(r * 0.66 + 10, g * 0.62 + 6, b * 0.72 + 28); SC[h] = o; return o
end
local function warm(h, a) local r, g, b = rgb(h); a = a or 1; return hex(r + 36 * a, g + 22 * a, b - 8 * a) end
local function lit(h, a) local r, g, b = rgb(h); a = a or 1; return hex(r + 24 * a, g + 22 * a, b + 14 * a) end
local function dark(h, a) local r, g, b = rgb(h); a = a or 1; return hex(r - 34 * a, g - 32 * a, b - 22 * a) end

-- masks
local function newMask() return { s = {}, n = 0 } end
local function madd(m, x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return end
  local k = y * W + x
  if not m.s[k] then m.s[k] = true; m.n = m.n + 1 end
end
local function mhas(m, x, y) if x < 0 or x >= W or y < 0 or y >= H then return false end return m.s[y * W + x] == true end
local function meach(m, fn)
  local keys = {}
  for k in pairs(m.s) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do fn(k % W, k // W) end
end
local function poly(pts, m)
  m = m or newMask()
  local miny, maxy = 1e9, -1e9
  for _, p in ipairs(pts) do miny = min(miny, p[2]); maxy = max(maxy, p[2]) end
  local n = #pts
  for y = floor(miny), math.ceil(maxy) do
    local yc = y + 0.5; local xs = {}
    for i = 1, n do
      local a, b = pts[i], pts[i % n + 1]
      if (a[2] <= yc and b[2] > yc) or (b[2] <= yc and a[2] > yc) then
        xs[#xs + 1] = a[1] + (yc - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do
      for x = math.ceil(xs[i] - 0.5), floor(xs[i + 1] - 0.5) do madd(m, x, y) end
    end
  end
  return m
end
local function rect(x0, y0, x1, y1, m)
  m = m or newMask()
  for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do madd(m, x, y) end end
  return m
end
local function ell(cx, cy, rx, ry, m)
  m = m or newMask()
  for y = floor(cy - ry) - 1, math.ceil(cy + ry) + 1 do
    for x = floor(cx - rx) - 1, math.ceil(cx + rx) + 1 do
      local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
      if dx * dx + dy * dy <= 1 then madd(m, x, y) end
    end
  end
  return m
end
local function fill(m, f)
  meach(m, function(x, y)
    local col = (type(f) == "string") and f or f(x, y)
    if col then px(x, y, col) end
  end)
end
local function edgeIn(m, col)
  meach(m, function(x, y)
    if not (mhas(m, x - 1, y) and mhas(m, x + 1, y) and mhas(m, x, y - 1) and mhas(m, x, y + 1)) then px(x, y, col) end
  end)
end
local function shadowMask(m) meach(m, function(x, y) local h = at(x, y) if h then px(x, y, shade(h)) end end) end
local function glowMask(m, a) meach(m, function(x, y) local h = at(x, y) if h then px(x, y, warm(h, a)) end end) end
local function line(x0, y0, x1, y1, col, w)
  local n = max(1, math.ceil(max(abs(x1 - x0), abs(y1 - y0))))
  for i = 0, n do
    local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5)
    for dy = 0, (w or 1) - 1 do px(x, y + dy, type(col) == "function" and col(i, x, y) or col) end
  end
end
local function proj(x, y, f) return x + (VPX - x) * f, y + (VPY - y) * f end

---------------------------------------------------------------- textures
local function stoneTex(R, seed, ch, sw, mortar)
  ch = ch or 5; sw = sw or 9; mortar = mortar or R[2]
  return function(x, y)
    local row = y // ch
    local off = (row % 2) * (sw // 2) + floor(hash(row, seed, 1) * 4)
    local xx = x + off
    local col = xx // sw
    local w2 = sw + floor(hash(col, row, seed + 3) * 3) - 1
    local lx, ly = xx % sw, y % ch
    if ly == ch - 1 or lx == sw - 1 or (lx == w2 and w2 < sw - 1) then return mortar end
    local h = hash(col, row, seed)
    local base = (h < 0.28 and R[2]) or (h < 0.78 and R[3]) or R[4]
    if ly == 0 and lx < sw - 2 then return lit(base, 0.55) end
    if ly == ch - 2 and lx > 1 then return dark(base, 0.3) end
    if hash(x, y, seed + 9) > 0.93 then return dark(base, 0.25) end
    return base
  end
end
local function thatchTex(R, seed, layer)
  layer = layer or 6
  return function(x, y)
    if (y % layer) == layer - 1 and hash(x // 2, y, seed) > 0.2 then return R[2] end
    local h = hash(x, y // 3, seed)
    if h < 0.2 then return R[2] elseif h < 0.68 then return R[3] else return R[4] end
  end
end
local function shadeTex(f) return function(x, y) return shade(f(x, y)) end end
-- polygonal Inca masonry
local function incaTex(R, cw, chh, seed)
  return function(x, y)
    local gx, gy = x // cw, y // chh
    local d1, d2, best = 1e9, 1e9, 0
    local bx, by = 0, 0
    for j = -1, 1 do for i = -1, 1 do
      local cx = (gx + i) * cw + hash(gx + i, gy + j, seed) * cw
      local cy = (gy + j) * chh + hash(gx + i, gy + j, seed + 1) * chh
      local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.2) ^ 2)
      if d < d1 then d2 = d1; d1 = d; best = (gx + i) * 997 + (gy + j); bx, by = cx, cy
      elseif d < d2 then d2 = d end
    end end
    if d2 - d1 < 1.1 then return R[1] end
    local h = hash(best, 3, seed)
    local base = (h < 0.3 and R[2]) or (h < 0.8 and R[3]) or R[4]
    if d2 - d1 < 2.4 then
      if x < bx and y < by then return lit(base, 0.7) else return dark(base, 0.4) end
    end
    return base
  end
end

---------------------------------------------------------------- palettes
local THATCH  = { "#5e4526", "#8f6e3a", "#b8924c", "#d8b66c" }
local THATCH2 = { "#4e3a2a", "#7a5a3a", "#9c7a4c", "#bc9a64" }
local THATCH3 = { "#5c3424", "#8e5236", "#b0704a", "#cc9064" }
local WOOD    = { "#3e2a22", "#62402e", "#86583a", "#a8774e" }
local TEA_ST  = { "#5a3a38", "#8c6258", "#ad8270", "#c9a08a" }
local LIB_ST  = { "#363e5a", "#5d6888", "#7e8aa9", "#a0abc6" }
local SHOP_ST = { "#5e4224", "#93703e", "#b48f56", "#d2ae72" }
local FAR_ST  = { "#45503f", "#6c7a62", "#899880", "#a6b39c" }
local GATE_ST = { "#3a3b46", "#636574", "#7d7f8e", "#9798a6" }

---------------------------------------------------------------- 1. sky
local skyc = { "#6e93c5", "#7c9fcd", "#8cacd5", "#9db8dc", "#afc5e3", "#c0d1e8", "#d0dbec", "#dde2ec", "#e8e2e6", "#eedfdc" }
for y = 0, 116 do
  local i = min(#skyc, 1 + floor(y / 112 * #skyc))
  for x = 0, W - 1 do px(x, y, skyc[i]) end
end
-- soft morning sun glow behind mist (upper right, oval, partly hidden by cloud)
meach(ell(352, 46, 30, 22), function(x, y) px(x, y, warm(at(x, y), 0.35)) end)
meach(ell(352, 46, 14, 11), function(x, y) px(x, y, "#f6ead2") end)

local function cloud(x, y, w, top, mid, under)
  local m = newMask()
  ell(x + w * 0.24, y - w * 0.12, w * 0.24, w * 0.17, m)
  ell(x + w * 0.5, y - w * 0.22, w * 0.27, w * 0.24, m)
  ell(x + w * 0.76, y - w * 0.11, w * 0.23, w * 0.15, m)
  ell(x + w * 0.5, y - w * 0.06, w * 0.48, w * 0.09, m)
  local cut = newMask()
  meach(m, function(px_, py) if py <= y then madd(cut, px_, py) end end)
  fill(cut, function(px_, py)
    local t = (y - py) / (w * 0.46)
    if py >= y - 1 then return under end
    if t < 0.28 then return mid end
    return top
  end)
  -- bumps lit rim upper-left
  meach(cut, function(px_, py)
    if not mhas(cut, px_ - 1, py - 1) and py < y - 3 then px(px_, py, "#f5f4f6") end
  end)
end

---------------------------------------------------------------- 2. snowy peaks
local peaks = { { 58, 40, 1.05 }, { 132, 30, 0.95 }, { 196, 44, 1.0 }, { 286, 34, 0.9 }, { 372, 42, 1.0 }, { 440, 36, 1.1 } }
local function peakAt(x)
  local best, bi = 1e9, 1
  for i, p in ipairs(peaks) do
    local y = p[2] + abs(x - p[1]) * p[3] + floor(hash(x // 3, i, 9) * 3)
    if y < best then best = y; bi = i end
  end
  return best, bi
end
for x = 0, W - 1 do
  local top, bi = peakAt(x)
  local p = peaks[bi]
  local rightFace = x > p[1]
  for y = max(0, top), 112 do
    local depth = y - p[2]
    local snowLine = 24 + floor(hash(x // 2, bi, 4) * 8) + ((x % 9 < 3) and 4 or 0)
    local col
    if depth < snowLine then
      col = rightFace and "#c3cbe2" or "#eef0f6"
      if not rightFace and hash(x, y // 2, 5) > 0.86 then col = "#dde3ef" end
      if rightFace and hash(x, y // 2, 6) > 0.85 then col = "#adb6d4" end
    else
      col = rightFace and "#727799" or "#8d91b2"
      if hash(x // 2, y // 3, 7) > 0.8 then col = rightFace and "#666b8e" or "#9fa3c0" end
    end
    if y == top then col = rightFace and "#a3abc9" or "#f4f4f7" end
    px(x, y, col)
  end
end
-- second, nearer bluish ridge
for x = 0, W - 1 do
  local top = 78 + floor(10 * math.sin(x * 0.031 + 1.2) + 6 * math.sin(x * 0.083) + hash(x // 4, 1, 3) * 3)
  for y = top, 112 do
    local col = (y < top + 3) and "#8a98b8" or "#7a88aa"
    if hash(x // 3, y // 2, 11) > 0.82 then col = "#6f7da0" end
    px(x, y, col)
  end
end
-- mist bands
for y = 86, 104 do
  for x = 0, W - 1 do
    local s = math.sin(x * 0.045 + y * 0.6) + math.sin(x * 0.013 - y * 0.2)
    if s > 0.9 - (y - 86) * 0.06 then px(x, y, (y % 3 == 0) and "#dfe3ee" or "#d2d9e8") end
  end
end
cloud(22, 52, 70, "#eceef4", "#d9dded", "#bcc3da")
cloud(150, 40, 58, "#eceef4", "#d9dded", "#bcc3da")
cloud(250, 64, 84, "#eceef4", "#d9dded", "#bcc3da")
cloud(330, 54, 64, "#eceef4", "#d9dded", "#bcc3da")
cloud(400, 76, 70, "#eceef4", "#d9dded", "#bcc3da")
cloud(100, 86, 52, "#e6e9f1", "#d3d9e9", "#bcc3da")

---------------------------------------------------------------- 3. potato terraces on near hills
local TERR = { "#7f9c4a", "#9a5f8a", "#c9a447", "#8a5c40", "#5f8c4f", "#b5577a", "#cdb878", "#6c8f3e", "#7a4a7e", "#d0884a" }
local function hillTop(x)
  if x < 232 then
    local t = max(0, (x - 0) / 232)
    return 84 + 24 * t ^ 1.7 + 3 * math.sin(x * 0.07)
  else
    local t = max(0, (W - x) / 248)
    return 82 + 26 * t ^ 1.7 + 3 * math.sin(x * 0.06 + 2)
  end
end
for x = 0, W - 1 do
  local top = floor(hillTop(x))
  for y = top, 118 do
    local d = y - top
    local band = d // 5
    local field = (x + band * 13 + floor(hash(band, 0, 2) * 20)) // 34
    local col = TERR[1 + floor(hash(field, band, 21) * #TERR)]
    local ly = d % 5
    if ly == 4 then col = (hash(x // 3, band, 4) > 0.5) and "#7d7066" or "#6b5f58"
    elseif ly == 0 then col = lit(col, 0.6)
    elseif (x + band) % 3 == 0 and ly == 2 then col = dark(col, 0.45) end
    -- field seams
    if (x + band * 13 + floor(hash(band, 0, 2) * 20)) % 34 == 0 then col = "#6b5f58" end
    if y == top then col = "#9db46a" end
    px(x, y, col)
  end
end

---------------------------------------------------------------- 4. ground: meadow + paved street
local function roadL(y) return 234 - (y - 112) * (118 / 157) end
local function roadR(y) return 246 + (y - 112) * (118 / 157) end
local function cob(x, y)
  local v = y - 104
  local K = 2600
  local row = floor(K / v)
  local col = floor((x - 240) / v * 13 + (row % 2) * 0.5)
  return row, col
end
for y = 112, H - 1 do
  for x = 0, W - 1 do
    local col
    local xl, xr = roadL(y), roadR(y)
    if x >= xl and x <= xr then
      local r, cc = cob(x, y)
      local r2 = cob(x, y + 1)
      local _, c2 = cob(x + 1, y)
      local h = hash(cc, r, 31)
      col = (h < 0.3 and "#a99d90") or (h < 0.75 and "#b9ad9d") or "#c8bdac"
      if y > 122 then
        if r2 ~= r or c2 ~= cc then col = "#857a76"
        else
          local r0 = cob(x, y - 1)
          if r0 ~= r then col = lit(col, 0.5) end
        end
      end
      if (x - xl) < 1.5 or (xr - x) < 1.5 then col = "#7d736e" end
    else
      local h = hash(x // 2, y // 2, 41)
      col = (h < 0.33 and "#7f9b50") or (h < 0.8 and "#8aa657") or "#97b162"
      if y > 150 and hash(x, y, 42) > 0.95 then col = "#a9c26c"; px(x, y + 1, "#6e8a44") end
    end
    px(x, y, col)
  end
end

---------------------------------------------------------------- 5. gorge + rope bridge (spot: s1 bridge)
do
  -- gorge cleft between two cliffs
  local gorge = poly { { 52, 66 }, { 98, 68 }, { 92, 116 }, { 58, 116 } }
  fill(gorge, function(x, y)
    if x >= 70 and x <= 79 then
      if (y + x * 3) % 5 == 0 then return "#a9cde0" end
      return (x < 73) and "#e2eef4" or "#bfdbe8"
    end
    return ((y // 4 + x // 6) % 2 == 0) and "#4d4a6c" or "#57537a"
  end)
  -- spray at the bottom
  meach(ell(75, 113, 14, 4), function(x, y) px(x, y, (hash(x, y, 3) > 0.5) and "#dfecf3" or "#c8dde9") end)
  local CL = { "#3f3a4a", "#6a6070", "#857a84", "#a0959a" }
  local left = poly { { 20, 70 }, { 30, 62 }, { 46, 62 }, { 54, 68 }, { 60, 92 }, { 56, 118 }, { 20, 118 } }
  local right = poly { { 96, 70 }, { 106, 64 }, { 124, 66 }, { 132, 76 }, { 132, 118 }, { 92, 118 }, { 94, 92 } }
  for _, m in ipairs { left, right } do
    fill(m, function(x, y)
      local f = incaTex(CL, 9, 7, 5)(x, y)
      if y < 70 and hash(x, 1, 2) > 0.3 then return (y % 2 == 0) and "#7f9a4e" or "#94b05c" end
      return f
    end)
    -- grassy lip
    meach(m, function(x, y) if not mhas(m, x, y - 1) then px(x, y, "#9cb866"); px(x, y + 1, "#7f9a4e") end end)
    edgeIn(m, "#3a3444")
  end
  shadowMask(poly { { 96, 70 }, { 106, 64 }, { 110, 64 }, { 104, 118 }, { 92, 118 } })
  -- posts
  local function post(x, y0, y1)
    fill(rect(x, y0, x + 3, y1), function(xx, yy) return (xx == x) and WOOD[4] or ((xx == x + 3) and WOOD[2] or WOOD[3]) end)
    fill(rect(x - 1, y0 - 2, x + 4, y0), WOOD[2]); px(x - 1, y0 - 2, WOOD[4])
  end
  post(42, 42, 66); post(104, 44, 68)
  -- deck (sag) with planks
  local function sagY(x, a, b, ya, yb, s)
    local t = (x - a) / (b - a)
    return ya + (yb - ya) * t + s * 4 * t * (1 - t)
  end
  for x = 46, 103 do
    local y = floor(sagY(x, 46, 103, 63, 65, 9))
    local plank = (x % 3 == 0) and "#6e4c32" or ((x % 3 == 1) and "#b08254" or "#94683f")
    px(x, y, plank); px(x, y + 1, plank); px(x, y + 2, "#5a3c2a")
  end
  -- hand ropes (twisted) + suspenders
  for x = 45, 104 do
    local y = floor(sagY(x, 45, 104, 45, 47, 12))
    px(x, y, (x % 2 == 0) and "#e0c070" or "#a8823c")
    px(x, y + 1, "#7a5a2a")
    if x % 5 == 0 then
      local yd = floor(sagY(x, 46, 103, 63, 65, 9))
      for yy = y + 2, yd - 1 do px(x, yy, (yy % 2 == 0) and "#c9a557" or "#9a7a3e") end
    end
  end
  -- quirk: spider-built: a big web between left post and cliff, with a little toll pouch
  local wx, wy = 34, 50
  local spokes = { { 42, 43 }, { 42, 52 }, { 42, 60 }, { 27, 62 }, { 26, 50 }, { 30, 42 }, { 36, 40 } }
  for _, s in ipairs(spokes) do line(wx, wy, s[1], s[2], "#e8edf4") end
  for r = 3, 9, 3 do
    local prev
    for i, s in ipairs(spokes) do
      local dx, dy = s[1] - wx, s[2] - wy
      local d = math.sqrt(dx * dx + dy * dy)
      local p = { wx + dx / d * r, wy + dy / d * r * 0.9 }
      if prev then line(prev[1], prev[2], p[1], p[2], "#dfe5ee") end
      prev = p
    end
  end
  -- toll pouch (a fly a year) hanging on post
  fill(poly { { 47, 52 }, { 52, 52 }, { 53, 58 }, { 46, 58 } }, "#7c5aa0"); line(47, 52, 52, 52, "#c59be0"); px(49, 50, "#e0c070"); px(49, 51, "#e0c070")
  px(48, 55, "#3c2a48"); px(50, 55, "#3c2a48")
end

---------------------------------------------------------------- 6. house builder
local function house(o)
  local x0, x1, yb, yt, pk = o.x0, o.x1, o.yb, o.yt, o.peak
  local f = o.f or 0.14
  local cx = (x0 + x1) / 2
  local R, T = o.wall, o.roof
  local wallTex = stoneTex(R, o.seed or 1, o.ch or 5, o.sw or 9)
  local roofTex = thatchTex(T, (o.seed or 1) + 50)
  -- cast shadow lower-right
  shadowMask(poly { { x0 + 3, yb + 1 }, { x1 + 1, yb + 1 }, { x1 + o.shR, yb + o.shD }, { x0 + 10, yb + o.shD } })
  local sx = (o.side == "r") and x1 or x0
  local eav = (o.side == "r") and (x1 + 6) or (x0 - 6)
  -- side wall
  local a1x, a1y = proj(sx, yt, f)
  local a2x, a2y = proj(sx, yb, f)
  local side = poly { { sx, yt }, { sx, yb + 1 }, { a2x, a2y + 1 }, { a1x, a1y } }
  local sideR = (o.side == "r") and { shade(R[1]), shade(R[2]), shade(R[3]), shade(R[4]) } or { R[1], lit(R[2], 0.4), lit(R[3], 0.4), lit(R[4], 0.4) }
  fill(side, stoneTex(sideR, (o.seed or 1) + 7, o.ch or 5, (o.sw or 9) - 3, sideR[1]))
  edgeIn(side, dark(R[1], 0.3))
  -- side roof plane
  local e1x, e1y = proj(eav, yt + 4, f)
  local p1x, p1y = proj(cx, pk - 5, f)
  local rp = poly { { cx, pk - 5 }, { eav, yt + 4 }, { e1x, e1y }, { p1x, p1y } }
  fill(rp, (o.side == "r") and shadeTex(roofTex) or roofTex)
  edgeIn(rp, T[1])
  -- front wall + gable
  local fm = rect(x0, yt, x1, yb)
  poly({ { x0, yt + 0.5 }, { cx, pk }, { x1 + 1, yt + 0.5 } }, fm)
  fill(fm, wallTex)
  -- AO under roof
  meach(fm, function(x, y) if y <= yt + 2 and y >= yt then px(x, y, dark(at(x, y), 0.45)) end end)
  -- plinth row
  fill(rect(x0, yb - 3, x1, yb), function(x, y) return (y == yb - 3) and lit(R[2], 0.3) or ((x % 7 == 0) and R[1] or R[2]) end)
  edgeIn(fm, R[1])
  -- front roof band (inverted V)
  local band = poly { { x0 - 6, yt + 5 }, { cx, pk - 6 }, { x1 + 6, yt + 5 }, { x1 - 2, yt + 5 }, { cx, pk + 5 }, { x0 + 2, yt + 5 } }
  fill(band, roofTex)
  -- fringe
  for x = x0 - 6, x1 + 6 do
    local base = yt + 5
    if hash(x, 7, o.seed or 1) > 0.35 then px(x, base + 1, T[2]) end
    if hash(x, 8, o.seed or 1) > 0.7 then px(x, base + 2, T[1]) end
  end
  edgeIn(band, T[1])
  -- ridge cap
  line(cx - 2, pk - 7, cx + 2, pk - 7, T[1])
  if o.deco then o.deco(cx) end
end

local function window(x0, y0, x1, y1, frame, inner)
  frame = frame or WOOD[1]
  fill(rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), frame)
  fill(rect(x0 - 2, y0 - 2, x1 + 2, y0 - 2), WOOD[3])
  fill(rect(x0, y0, x1, y1), inner or function(x, y)
    if (x - x0) + (y - y0) < 3 then return "#fbe3a0" end
    if y >= y1 - 1 then return "#d99a4a" end
    return "#f3c463"
  end)
  if not inner then
    local mx = (x0 + x1) // 2; for y = y0, y1 do px(mx, y, frame) end
    local my = (y0 + y1) // 2; for x = x0, x1 do px(x, my, frame) end
  end
  fill(rect(x0 - 3, y1 + 3, x1 + 3, y1 + 4), function(x, y) return (y == y1 + 3) and "#c5bcb0" or "#8a8078" end)
  -- warm glow spill on wall under sill
  glowMask(rect(x0 - 1, y1 + 5, x1 + 1, y1 + 7), 0.5)
end

local function door(cx, yb, wb, wt, h, R)
  R = R or WOOD
  local m = poly { { cx - wb / 2, yb + 1 }, { cx - wt / 2, yb - h }, { cx + wt / 2, yb - h }, { cx + wb / 2, yb + 1 } }
  fill(m, function(x, y)
    if (x - floor(cx - wb / 2)) % 4 == 0 then return R[2] end
    if hash(x, y // 2, 3) < 0.12 then return R[4] end
    return R[3]
  end)
  edgeIn(m, R[1])
  local l = rect(cx - wt / 2 - 4, yb - h - 4, cx + wt / 2 + 3, yb - h - 1)
  fill(l, function(x, y) return (y == yb - h - 4) and "#c9c0b2" or "#9c9286" end); edgeIn(l, "#5e5650")
  px(floor(cx + wt / 2 - 2), yb - h // 2, "#e0c070"); px(floor(cx + wt / 2 - 2), yb - h // 2 + 1, "#a07a30")
  -- step
  local s = rect(cx - wb / 2 - 3, yb - 1, cx + wb / 2 + 2, yb + 1)
  fill(s, function(x, y) return (y == yb - 1) and "#c5bcb0" or "#958b80" end)
end

local STRIPES = { "#c4433a", "#e8a23a", "#3f8f8a", "#7a3f80", "#efd28a", "#2f5f9a" }
local function awning(x0, x1, y0, y1, sw, seed)
  local m = poly { { x0 + 3, y0 }, { x1 - 3, y0 }, { x1 + 2, y1 }, { x0 - 2, y1 } }
  fill(m, function(x, y)
    local i = ((x - x0) // sw) % #STRIPES
    local col = STRIPES[1 + (i + (seed or 0)) % #STRIPES]
    if (x + y) % 4 == 0 then col = dark(col, 0.25) end -- weave
    if y <= y0 + 1 then col = lit(col, 0.5) end
    if (x - x0) % sw == 0 then col = "#fbf0d4" end
    return col
  end)
  edgeIn(m, "#4a2a30")
  -- scalloped fringe + tassels
  for x = x0 - 2, x1 + 2 do
    local k = (x - x0) % 6
    if k < 4 then px(x, y1 + 1, STRIPES[1 + ((x - x0) // 6) % #STRIPES]) end
    if k == 1 or k == 2 then px(x, y1 + 2, dark(STRIPES[1 + ((x - x0) // 6) % #STRIPES], 0.4)) end
    if k == 1 then px(x, y1 + 3, "#efd28a") end
  end
  shadowMask(rect(x0, y1 + 2, x1, y1 + 5))
end

---------------------------------------------------------------- 7. far decor (centre + right)
house { x0 = 204, x1 = 224, yb = 110, yt = 100, peak = 90, f = 0.1, side = "r", wall = FAR_ST, roof = THATCH, seed = 71, ch = 3, sw = 5, shR = 6, shD = 3,
  deco = function(cx) window(209, 103, 212, 106) end }
house { x0 = 258, x1 = 280, yb = 110, yt = 99, peak = 88, f = 0.1, side = "l", wall = TEA_ST, roof = THATCH2, seed = 72, ch = 3, sw = 5, shR = 6, shD = 3,
  deco = function(cx) window(270, 102, 273, 105) end }
-- far right terrace house with a potato drying rack
house { x0 = 296, x1 = 346, yb = 108, yt = 86, peak = 66, f = 0.1, side = "l", wall = FAR_ST, roof = THATCH3, seed = 73, ch = 4, sw = 7, shR = 10, shD = 4,
  deco = function(cx)
    window(304, 92, 312, 100)
    door(330, 108, 11, 8, 15, WOOD)
    -- drying rack with colourful potatoes on the gable
    line(300, 80, 342, 80, WOOD[2])
    for i = 0, 9 do
      local col = TERR[1 + (i * 3) % #TERR]
      fill(ell(303 + i * 4, 82, 1.6, 1.1), col)
    end
  end }

---------------------------------------------------------------- 8. Library (left far)
house { x0 = 142, x1 = 194, yb = 130, yt = 90, peak = 62, f = 0.12, side = "r", wall = LIB_ST, roof = THATCH2, seed = 11, ch = 5, sw = 8, shR = 22, shD = 6,
  deco = function(cx)
    -- big open-book sign on the gable
    local cov = poly { { 152, 74 }, { 168, 78 }, { 184, 74 }, { 185, 87 }, { 168, 91 }, { 151, 87 } }
    fill(cov, "#6b3f86"); edgeIn(cov, "#3e2250")
    local lp = poly { { 154, 73 }, { 167, 77 }, { 167, 88 }, { 154, 84 } }
    local rp = poly { { 169, 77 }, { 182, 73 }, { 182, 84 }, { 169, 88 } }
    fill(lp, function(x, y) return ((y - floor((x - 154) * 0.3)) % 3 == 0 and x > 155 and x < 166) and "#a99a86" or "#f2e8d2" end)
    fill(rp, function(x, y) return ((y + floor((x - 169) * 0.3)) % 3 == 0 and x > 170 and x < 181) and "#a99a86" or "#e2d5bc" end)
    edgeIn(lp, "#8a7a68"); edgeIn(rp, "#8a7a68")
    line(168, 77, 168, 90, "#5a3a20")
    -- ribbon bookmark
    line(171, 88, 172, 95, "#c4433a"); px(171, 96, "#c4433a"); px(173, 96, "#c4433a")
    -- book-spine windows
    local spines = { "#c4433a", "#e8a23a", "#3f8f8a", "#7a3f80", "#2f5f9a", "#d9b25a", "#5a8a3e" }
    local function shelf(x0, y0, x1, y1)
      window(x0, y0, x1, y1, WOOD[1], function(x, y)
        if y == (y0 + y1) // 2 or y == y1 then return WOOD[2] end
        if (y > (y0 + y1) // 2 + 2 or (y < (y0 + y1) // 2 and y > y0 + 1)) or hash(x, 1, 3) > 0.25 then
          return spines[1 + (x * 5 + (y > (y0 + y1) // 2 and 3 or 0)) % #spines]
        end
        return "#f3c463"
      end)
    end
    shelf(148, 98, 158, 112)
    shelf(178, 98, 188, 112)
    door(168, 130, 14, 10, 20, WOOD)
    -- stack of books by the door (quirk: a book-stack doorstop step)
    local cols = { "#c4433a", "#2f5f9a", "#e8a23a", "#5a8a3e" }
    for i = 0, 3 do fill(rect(180 - (i % 2), 126 - i * 2, 188 - (i % 2), 127 - i * 2), cols[i + 1]); px(181 - (i % 2), 126 - i * 2, "#f2e8d2") end
  end }

---------------------------------------------------------------- 9. Teahouse "The Yerba Gourd" (left near)
house { x0 = 26, x1 = 110, yb = 220, yt = 162, peak = 132, f = 0.16, side = "r", wall = TEA_ST, roof = THATCH, seed = 21, ch = 6, sw = 11, shR = 34, shD = 8,
  deco = function(cx)
    window(56, 140, 80, 150)                 -- gable window
    awning(30, 106, 168, 178, 5, 0)
    window(36, 186, 50, 200)
    window(86, 186, 100, 200)
    door(68, 220, 20, 15, 30, WOOD)
    -- potted plants
    for _, x in ipairs { 40, 92 } do
      fill(poly { { x, 212 }, { x + 9, 212 }, { x + 8, 219 }, { x + 1, 219 } }, "#b5603a"); line(x, 212, x + 9, 212, "#d9845a")
      for k = 0, 4 do line(x + 2 + k * 1.3, 211, x + k * 2.2, 204 + (k % 2), (k % 2 == 0) and "#5f8c4f" or "#7fae5a") end
    end
    -- hanging gourd sign (mate gourd + metal straw) on a bracket
    line(110, 172, 130, 172, WOOD[1], 2)
    line(118, 174, 118, 178, "#4a3a2e"); line(126, 174, 126, 178, "#4a3a2e")
    local gb = poly { { 114, 179 }, { 131, 179 }, { 131, 197 }, { 114, 197 } }
    fill(gb, WOOD[3]); edgeIn(gb, WOOD[1])
    local g = ell(122.5, 191, 6, 5.2)
    ell(122.5, 185, 3.6, 3.4, g)
    fill(g, function(x, y)
      local nx, ny = (x - 121) / 6, (y - 187) / 7
      if nx + ny < -0.6 then return "#c99a4a" end
      if nx + ny > 0.6 then return "#6e4a24" end
      return "#9a6e34"
    end)
    edgeIn(g, "#4e3218")
    fill(rect(119, 182, 125, 183), "#5a8a3e")     -- green yerba top
    line(124, 183, 128, 177, "#d2d6e0")           -- bombilla
    px(129, 176, "#eef0f4")
    -- quirk: chimney is a giant steaming mate gourd
    local cg = ell(92, 147, 7, 6)
    ell(92, 140, 4, 3.5, cg)
    fill(cg, function(x, y) if x < 90 and y < 146 then return "#c99a4a" end if x > 94 then return "#6e4a24" end return "#9a6e34" end)
    edgeIn(cg, "#4e3218")
    fill(rect(89, 137, 95, 138), "#5a8a3e")
    line(95, 138, 99, 130, "#d2d6e0", 2)
    -- steam
    for i, p in ipairs { { 100, 124, 4, 2.6 }, { 104, 117, 5, 3 }, { 100, 110, 4, 2.4 } } do
      fill(ell(p[1], p[2], p[3], p[4]), (i % 2 == 0) and "#e6e8ef" or "#f1f2f6")
    end
    -- tea lantern by door
    line(86, 206, 86, 210, "#4a3a2e")
    glowMask(ell(86.5, 214, 8, 6), 0.6)
    fill(rect(84, 210, 88, 216), "#f6cf6e"); edgeIn(rect(84, 210, 88, 216), "#7a5638")
  end }

---------------------------------------------------------------- 10. Highland Green (central raised terrace square)
do
  -- shadow lower-right of terrace
  shadowMask(poly { { 312, 222 }, { 322, 228 }, { 322, 232 }, { 176, 232 }, { 172, 229 } })
  local top = poly { { 210, 146 }, { 270, 146 }, { 310, 220 }, { 170, 220 } }
  fill(top, function(x, y)
    local v = y - 104
    local st = floor((x - 240) / v * 7 + 100) % 2
    local col = (st == 0) and "#8ec15a" or "#9ccc66"
    local h = hash(x, y, 61)
    if h > 0.93 then col = "#b4dc7a" elseif h < 0.06 then col = "#77a64a" end
    return col
  end)
  -- front retaining wall (Inca masonry)
  local wall = poly { { 170, 220 }, { 310, 220 }, { 312, 229 }, { 168, 229 } }
  fill(wall, incaTex({ "#4b4652", "#7e7782", "#958d96", "#ada5ac" }, 9, 6, 17))
  edgeIn(wall, "#3f3a48")
  -- grass lip + flower border
  meach(top, function(x, y)
    if not mhas(top, x, y - 1) or not mhas(top, x - 1, y) or not mhas(top, x + 1, y) then px(x, y, "#5b8a3c") end
  end)
  line(171, 219, 309, 219, "#5b8a3c")
  local FL = { "#e05a6a", "#f2c84a", "#b46ad0", "#f08a3a", "#f0e6f2" }
  for x = 174, 306, 3 do
    local y = 216 - (x % 2)
    px(x, y, FL[1 + (x // 3) % #FL]); px(x, y + 1, "#4e7a34")
  end
  -- flag pole with woven striped banner (green icon partner)
  local fx = 252
  fill(rect(fx, 138, fx + 1, 170), function(x) return x == fx and WOOD[4] or WOOD[2] end)
  px(fx, 137, "#e0c070"); px(fx + 1, 137, "#e0c070")
  for y = 140, 152 do
    local wv = floor(math.sin((y - 140) * 0.5) * 0.8)
    for x = fx + 2, fx + 18 + wv do
      local col = STRIPES[1 + ((x - fx) // 3) % #STRIPES]
      if (x + y) % 4 == 0 then col = dark(col, 0.2) end
      if y == 140 then col = lit(col, 0.4) end
      px(x, y, col)
    end
    px(fx + 19 + wv, y, "#4a2a30")
  end
  line(fx + 2, 153, fx + 18, 153, "#4a2a30")
  -- quirk/icon: giant purple potato monument on a stone plinth
  shadowMask(ell(236, 177, 20, 4))
  local pl = poly { { 212, 168 }, { 246, 168 }, { 249, 177 }, { 209, 177 } }
  fill(pl, stoneTex({ "#4b4652", "#7e7782", "#958d96", "#ada5ac" }, 81, 3, 7)); edgeIn(pl, "#3f3a48")
  local pm = ell(229, 157, 16, 11)
  ell(218, 161, 8, 7, pm); ell(239, 160, 8, 8, pm); ell(232, 149, 8, 5, pm)
  fill(pm, function(x, y)
    local nx, ny = (x - 229) / 18, (y - 157) / 13
    local v = -0.65 * nx - 0.75 * ny + (hash(x // 2, y // 2, 9) - 0.5) * 0.15
    if v > 0.55 then return "#c08ad0" elseif v > 0.15 then return "#9a62ae" elseif v > -0.35 then return "#7c4a92" else return "#5e3676" end
  end)
  edgeIn(pm, "#3e2252")
  -- eyes (little dimples) + sprouts
  for _, e in ipairs { { 222, 156 }, { 234, 161 }, { 228, 152 }, { 241, 157 }, { 217, 163 } } do
    px(e[1], e[2], "#4a2a60"); px(e[1] + 1, e[2], "#4a2a60"); px(e[1], e[2] - 1, "#c99adc")
  end
  line(230, 146, 228, 140, "#6fae4a"); line(228, 140, 225, 139, "#8fd060"); line(231, 145, 235, 140, "#6fae4a"); px(236, 139, "#8fd060")
  px(225, 152, "#efe0f6"); px(226, 152, "#efe0f6")
end

---------------------------------------------------------------- 11. Notice board (towering)
do
  shadowMask(poly { { 322, 227 }, { 350, 227 }, { 360, 231 }, { 330, 231 } })
  shadowMask(poly { { 350, 140 }, { 354, 140 }, { 362, 226 }, { 354, 226 } })
  for _, x in ipairs { 322, 343 } do
    local p = rect(x, 132, x + 3, 227)
    fill(p, function(xx, yy) if xx == x then return WOOD[4] end if xx == x + 3 then return WOOD[2] end if yy % 9 == 0 then return WOOD[2] end return WOOD[3] end)
    edgeIn(p, WOOD[1])
  end
  -- thatch cap
  local cap = poly { { 312, 140 }, { 334, 122 }, { 356, 140 }, { 350, 142 }, { 318, 142 } }
  fill(cap, thatchTex(THATCH3, 91, 4)); edgeIn(cap, THATCH3[1])
  -- panel
  local pan = rect(316, 144, 352, 200)
  fill(pan, function(x, y)
    if x <= 317 or x >= 351 or y <= 145 or y >= 199 then return (x + y) % 5 == 0 and WOOD[2] or WOOD[3] end
    local woven = ((x // 3 + y // 3) % 2 == 0)
    return woven and "#c9a86a" or "#b39258"
  end)
  edgeIn(pan, WOOD[1])
  -- pinned papers (no text, scribble rows)
  local PAP = { { 320, 149, 330, 162, "#f2ead6", "#c4433a" }, { 334, 148, 348, 158, "#e6eef2", "#2f5f9a" }, { 321, 167, 333, 182, "#f4e2b8", "#3f8f8a" },
                { 337, 162, 347, 176, "#f0d6dc", "#e8a23a" }, { 336, 180, 348, 195, "#e8f0dc", "#7a3f80" }, { 320, 186, 331, 196, "#f2ead6", "#c4433a" } }
  for _, p in ipairs(PAP) do
    shadowMask(rect(p[1] + 1, p[2] + 1, p[3] + 1, p[4] + 1))
    local m = rect(p[1], p[2], p[3], p[4])
    fill(m, function(x, y) if y > p[2] + 3 and (y - p[2]) % 3 == 1 and x > p[1] + 1 and x < p[3] - 1 and hash(x // 2, y, 4) > 0.25 then return "#9a948c" end return p[5] end)
    edgeIn(m, dark(p[5], 0.9))
    px((p[1] + p[3]) // 2, p[2] + 1, p[6]); px((p[1] + p[3]) // 2 + 1, p[2] + 1, lit(p[6], 0.8))
  end
  -- little tack bucket at the foot
  local b = poly { { 328, 218 }, { 338, 218 }, { 337, 227 }, { 329, 227 } }
  fill(b, "#7d8aa0"); edgeIn(b, "#454e64"); line(329, 218, 337, 218, "#b3bfd2")
end

---------------------------------------------------------------- 12. Shops (seed shop + market front, right near)
house { x0 = 380, x1 = 456, yb = 222, yt = 168, peak = 136, f = 0.12, side = "l", wall = SHOP_ST, roof = THATCH3, seed = 31, ch = 6, sw = 10, shR = 10, shD = 6,
  deco = function(cx)
    -- hanging seed-sprout icon board under the gable
    local sg = rect(408, 144, 428, 160)
    fill(sg, WOOD[3]); edgeIn(sg, WOOD[1])
    fill(ell(418, 156, 5, 2.6), "#7a4e2e")            -- soil mound
    fill(ell(417.5, 153, 2.4, 1.7), "#e8c27a")       -- seed
    line(418, 152, 418, 147, "#4e8a34")
    fill(poly { { 418, 148 }, { 413, 145 }, { 414, 149 } }, "#7fc05a")
    fill(poly { { 419, 148 }, { 424, 145 }, { 423, 149 } }, "#6aae48")
    awning(382, 454, 172, 184, 6, 2)
    -- open shop front with shelves of seed jars
    local sf = rect(388, 190, 448, 206)
    fill(sf, function(x, y) if y == 197 or y == 205 then return WOOD[2] end return "#4e3a40" end)
    edgeIn(sf, WOOD[1])
    local JC = { "#c4433a", "#e8a23a", "#5a8a3e", "#7a3f80", "#d9b25a", "#2f5f9a" }
    for i = 0, 9 do
      local x = 390 + i * 6
      fill(rect(x, 192, x + 3, 196), JC[1 + i % 6]); px(x, 192, "#e9eef4"); px(x + 1, 192, "#e9eef4")
      fill(rect(x + 1, 200, x + 4, 204), JC[1 + (i + 3) % 6])
    end
    -- counter with crates of potatoes in many colours (quirk: one for every day)
    local cn = rect(384, 207, 452, 220)
    fill(cn, function(x, y) if y == 207 then return WOOD[4] end if (x - 384) % 17 == 0 then return WOOD[1] end if y % 4 == 0 then return WOOD[2] end return WOOD[3] end)
    edgeIn(cn, WOOD[1])
    local PC = { "#9a62ae", "#e8c060", "#c4533a", "#d98a9a", "#8a5c40", "#f0e0b0", "#6a3a7a", "#e07a3a", "#b0a040", "#5e3676" }
    for i = 0, 22 do
      local x = 386 + i * 3
      local y = 204 - (i % 2)
      fill(ell(x + 1, y, 1.8, 1.3), PC[1 + (i * 7) % #PC])
    end
    -- seed sacks
    for _, s in ipairs { { 366, "#d8c49a" }, { 372, "#c9b07e" } } do
      local m = poly { { s[1], 222 }, { s[1] + 1, 210 }, { s[1] + 4, 208 }, { s[1] + 7, 210 }, { s[1] + 8, 222 } }
      fill(m, function(x, y) return ((x + y) % 3 == 0) and dark(s[2], 0.3) or s[2] end); edgeIn(m, "#6e5a3a")
      line(s[1] + 2, 210, s[1] + 6, 210, "#c4433a")
    end
  end }
-- potato calendar rack on the shop wall (365 colours quirk), right of the sign
do
  local r = rect(434, 146, 450, 162)
  fill(r, WOOD[2]); edgeIn(r, WOOD[1])
  local PC = { "#9a62ae", "#e8c060", "#c4533a", "#d98a9a", "#f0e0b0", "#e07a3a", "#b0a040", "#5fa04a", "#6aa0d0" }
  for j = 0, 3 do for i = 0, 3 do px(436 + i * 4, 148 + j * 4, PC[1 + (i + j * 4) % #PC]); px(437 + i * 4, 148 + j * 4, PC[1 + (i + j * 4) % #PC]); px(436 + i * 4, 149 + j * 4, dark(PC[1 + (i + j * 4) % #PC], 0.5)) end end
end

---------------------------------------------------------------- 13. Wild Trail (Inca arch at right, path off the edge)
do
  -- dirt path from the street to the arch and out to the right edge
  local path = poly { { 262, 126 }, { 300, 118 }, { 404, 114 }, { 462, 112 }, { 462, 124 }, { 404, 122 }, { 300, 128 }, { 270, 132 } }
  fill(path, function(x, y) local h = hash(x // 2, y, 51) return (h < 0.3 and "#a88a62") or (h < 0.85 and "#b89a70") or "#c8ad84" end)
  -- jungle trees (Amazon side) behind the arch
  for _, t in ipairs { { 452, 60, 18 }, { 400, 74, 12 } } do
    fill(rect(t[1] - 1, t[2], t[1] + 2, 116), function(x) return x == t[1] - 1 and "#8a6a4a" or "#5e4630" end)
    local cm = ell(t[1], t[2], t[3], t[3] * 0.6)
    ell(t[1] - t[3] * 0.6, t[2] + 4, t[3] * 0.6, t[3] * 0.4, cm); ell(t[1] + t[3] * 0.6, t[2] + 4, t[3] * 0.6, t[3] * 0.4, cm)
    fill(cm, function(x, y)
      local v = -(x - t[1]) / t[3] - (y - t[2]) / (t[3] * 0.6)
      local h = hash(x // 3, y // 2, 77)
      if v > 0.6 then return h > 0.5 and "#8ccf5a" or "#7cbf4c" elseif v > -0.4 then return h > 0.3 and "#5e9e3e" or "#4f8c38" else return "#3c6e34" end
    end)
    edgeIn(cm, "#2f5a2e")
  end
  shadowMask(poly { { 446, 117 }, { 460, 117 }, { 462, 124 }, { 452, 124 } })
  local outer = poly { { 404, 117 }, { 411, 64 }, { 441, 64 }, { 448, 117 } }
  local open = poly { { 416, 117 }, { 420, 78 }, { 432, 78 }, { 436, 117 } }
  local arch = newMask()
  meach(outer, function(x, y) if not mhas(open, x, y) then madd(arch, x, y) end end)
  -- view through the opening: misty green trail into the forest
  fill(open, function(x, y)
    if y > 106 then return (hash(x, y, 3) > 0.5) and "#c8ad84" or "#b89a70" end
    if y > 96 then return (x % 3 == 0) and "#4f8c38" or "#5e9e3e" end
    return (y < 88) and "#cfe0d6" or "#a9cfae"
  end)
  fill(arch, incaTex({ "#4a4040", "#86766a", "#a08e7e", "#bba892" }, 8, 7, 23))
  edgeIn(arch, "#3e3434")
  -- lintel stone (trapezoid shape keystone)
  local ln = poly { { 409, 70 }, { 443, 70 }, { 441, 64 }, { 411, 64 } }
  fill(ln, function(x, y) return (y == 64) and "#d2c0a8" or "#ab9886" end); edgeIn(ln, "#3e3434")
  -- vines with leaves
  for _, v in ipairs { { 412, 66, 408, 112 }, { 440, 66, 445, 100 } } do
    local n = 22
    for i = 0, n do
      local t = i / n
      local x = v[1] + (v[3] - v[1]) * t + math.sin(t * 9) * 2
      local y = v[2] + (v[4] - v[2]) * t
      px(x, y, "#3c7a34")
      if i % 3 == 0 then px(x + 1, y, "#7cc04c"); px(x + 2, y + 1, "#5ea040") end
      if i % 7 == 3 then px(x - 1, y, "#e05a8a") end
    end
  end
  -- signpost with arrow boards (no text) + leaf icon
  fill(rect(392, 82, 394, 120), function(x) return x == 392 and WOOD[4] or WOOD[2] end)
  shadowMask(rect(395, 118, 402, 120))
  local a1 = poly { { 384, 84 }, { 400, 84 }, { 405, 88 }, { 400, 92 }, { 384, 92 } }
  fill(a1, "#3f8f8a"); edgeIn(a1, "#1f4f4e"); line(386, 85, 398, 85, "#6fbfb8")
  fill(ell(392, 88, 3, 1.6), "#9ad06a"); px(394, 88, "#4e8a34")
  local a2 = poly { { 386, 96 }, { 402, 96 }, { 407, 100 }, { 402, 104 }, { 386, 104 } }
  fill(a2, "#e8a23a"); edgeIn(a2, "#8a5a1a"); line(388, 97, 400, 97, "#f6cf7a")
  line(390, 100, 398, 100, "#8a5a1a")
end

---------------------------------------------------------------- 14. River landing with canoes (bottom-left)
do
  local water = poly { { 20, 240 }, { 70, 236 }, { 120, 238 }, { 146, 246 }, { 152, 269 }, { 20, 269 } }
  fill(water, function(x, y)
    local col = (y < 246) and "#4f8fae" or "#467fa2"
    if (y % 4 == 0) and hash(x // 5, y, 13) > 0.55 then col = "#7cb4cc" end
    if (y % 4 == 2) and hash(x // 6, y, 14) > 0.7 then col = "#3a6c8e" end
    return col
  end)
  -- bank stones
  meach(water, function(x, y)
    if not mhas(water, x, y - 1) or not mhas(water, x + 1, y) then px(x, y, (hash(x // 3, 1, 2) > 0.5) and "#8e8590" or "#a49ca2"); px(x, y - 1, "#6e6672") end
  end)
  -- dock (wooden landing) with canoe icon post
  local dk = poly { { 108, 244 }, { 146, 244 }, { 150, 258 }, { 112, 258 } }
  fill(dk, function(x, y) if (x - 108) % 5 == 0 then return WOOD[1] end if y == 244 then return WOOD[4] end return (x % 5 < 2) and WOOD[3] or "#94683f" end)
  edgeIn(dk, WOOD[1])
  shadowMask(rect(114, 259, 150, 262))
  for _, x in ipairs { 112, 146 } do fill(rect(x, 240, x + 2, 262), function(xx) return xx == x and WOOD[4] or WOOD[2] end) end
  -- canoe icon board on the post
  local cb = rect(138, 228, 154, 238)
  fill(cb, WOOD[3]); edgeIn(cb, WOOD[1])
  fill(poly { { 140, 233 }, { 146, 235 }, { 152, 233 }, { 150, 236 }, { 142, 236 } }, "#c4533a")
  line(146, 230, 146, 235, "#5a3c2a")
  line(146, 239, 146, 243, WOOD[2])
  -- canoe 1 (red, woven band)
  local c1 = poly { { 26, 252 }, { 34, 247 }, { 88, 247 }, { 98, 251 }, { 90, 256 }, { 32, 256 } }
  shadowMask(poly { { 30, 257 }, { 92, 257 }, { 96, 259 }, { 34, 259 } })
  fill(c1, function(x, y)
    if y <= 248 then return "#e07a5a" end
    if y == 250 or y == 251 then return STRIPES[1 + (x // 3) % #STRIPES] end
    return (y > 254) and "#8a2f22" or "#b8452f"
  end)
  edgeIn(c1, "#5a2018")
  line(36, 248, 86, 248, "#5a2018")
  -- paddle resting across
  line(50, 244, 74, 252, "#a8774e", 1); fill(ell(76, 252, 3, 1.6), "#86583a")
  -- canoe 2 (teal) with a leaf sail (quirk)
  local c2 = poly { { 34, 262 }, { 44, 258 }, { 98, 258 }, { 108, 262 }, { 100, 267 }, { 42, 267 } }
  fill(c2, function(x, y)
    if y <= 259 then return "#5fb0b0" end
    if y == 262 then return "#efd28a" end
    return (y > 265) and "#1f5a60" or "#2f7f86"
  end)
  edgeIn(c2, "#163e44")
  fill(rect(70, 234, 71, 259), function(x) return x == 70 and WOOD[4] or WOOD[2] end)
  local leaf = poly { { 72, 236 }, { 84, 238 }, { 92, 246 }, { 88, 254 }, { 74, 256 }, { 72, 250 } }
  fill(leaf, function(x, y)
    local mid = 72 + (y - 236) * 0.55
    if abs(x - mid) < 0.8 then return "#3e7a2e" end
    if (y + floor(x * 0.5)) % 5 == 0 then return "#5e9e3e" end
    return (x > mid) and "#6fb24a" or "#8ccf5a"
  end)
  edgeIn(leaf, "#2f5a2e")
end

---------------------------------------------------------------- 15. gate frame (Inca stone, thatch lintel), bunting, lanterns
do
  local GT = incaTex(GATE_ST, 11, 9, 3)
  local lp = rect(0, 18, 19, H - 1)
  local rp = rect(460, 18, W - 1, H - 1)
  fill(lp, GT); fill(rp, GT)
  -- slight inward batter (trapezoid feel): inner edge stones
  for y = 18, H - 1 do px(19, y, GATE_ST[1]); px(18, y, (y % 2 == 0) and GATE_ST[2] or GATE_ST[3]); px(460, y, GATE_ST[1]) end
  -- shadow cast by left pillar onto ground (light upper-left)
  for y = 120, H - 1 do for x = 20, 24 do if hash(x, y, 1) > 0.15 then local h = at(x, y) if h then px(x, y, shade(h)) end end end end
  -- trapezoid niches in the pillars
  for _, nx in ipairs { 5, 466 } do
    local n = poly { { nx, 150 }, { nx + 2, 126 }, { nx + 8, 126 }, { nx + 10, 150 } }
    fill(n, "#4a4a5c"); edgeIn(n, "#2e2e3c")
    fill(ell(nx + 5, 146, 3, 2), "#9a62ae"); px(nx + 4, 145, "#c08ad0")  -- little potato offering
  end
  local lin = rect(0, 8, W - 1, 19)
  fill(lin, incaTex(GATE_ST, 14, 6, 8))
  line(0, 19, W - 1, 19, GATE_ST[1])
  fill(rect(0, 0, W - 1, 8), thatchTex(THATCH, 5, 4))
  for x = 0, W - 1 do
    if hash(x, 2, 3) > 0.3 then px(x, 9, THATCH[2]) end
    if hash(x, 3, 3) > 0.6 then px(x, 10, THATCH[1]) end
  end
  shadowMask(rect(20, 20, 459, 21))
  -- bunting of woven pennants
  local function by(x) local t = (x - 240) / 222 return 21 + 20 * (1 - t * t) end
  for x = 20, 459 do px(x, by(x), "#5a3c2a") end
  local k = 0
  for x = 26, 450, 14 do
    local y = floor(by(x + 4))
    local col = STRIPES[1 + k % #STRIPES]
    local col2 = STRIPES[1 + (k + 2) % #STRIPES]
    local pm = poly { { x, y }, { x + 9, y }, { x + 4.5, y + 11 } }
    fill(pm, function(xx, yy) return ((yy - y) % 4 < 2) and col or col2 end)
    edgeIn(pm, dark(col, 0.8))
    k = k + 1
  end
  -- hanging lanterns (warm glow)
  local function lantern(cx, ytop, len)
    for y = ytop, ytop + len do px(cx, y, "#4a3a2e") end
    local y0 = ytop + len
    glowMask(ell(cx + 0.5, y0 + 9, 15, 12), 0.45)
    glowMask(ell(cx + 0.5, y0 + 9, 10, 8), 0.4)
    fill(poly { { cx - 6, y0 + 4 }, { cx, y0 }, { cx + 7, y0 + 4 } }, "#6a4a34")
    local body = rect(cx - 4, y0 + 5, cx + 5, y0 + 15)
    fill(body, function(x, y)
      if x == cx - 4 or x == cx + 5 then return "#7a5638" end
      if (y - y0) % 4 == 0 then return "#e3a048" end
      return (x < cx) and "#f8d77a" or "#f0bf5e"
    end)
    edgeIn(body, "#5a3d2c")
    fill(rect(cx - 3, y0 + 16, cx + 4, y0 + 17), "#6a4a34")
    px(cx - 2, y0 + 7, "#fdf0c0")
    line(cx, y0 + 18, cx, y0 + 21, "#c4433a"); px(cx + 1, y0 + 21, "#e8a23a")
  end
  lantern(40, 20, 8)
  lantern(440, 20, 8)
end

---------------------------------------------------------------- finish + save
c:finish { outline = false }
HP.assertClean(c)
c:save { aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":112,"view":"gate","spots":[
{"k":"green","name":"The Highland Green","x":239,"y":183,"box":[166,138,311,228]},
{"k":"tea","name":"The Yerba Gourd","x":79,"y":175,"box":[22,124,136,226]},
{"k":"board","name":"Notice Board","x":335,"y":175,"box":[313,120,358,230]},
{"k":"library","name":"Library","x":171,"y":95,"box":[138,56,204,134]},
{"k":"s1","name":"Rope Bridge","id":"rr-bridge","verb":"cross the rope bridge","x":76,"y":76,"box":[20,36,132,118]},
{"k":"s2","name":"Canoe Landing","id":"rr-canoe","verb":"paddle the river","x":87,"y":251,"box":[20,232,155,269]},
{"k":"shops","name":"Seed Shop","x":409,"y":176,"box":[362,126,458,226]},
{"k":"wild","name":"Wild Trail","x":422,"y":89,"box":[384,58,458,120]}],
"stand":[{"x":180,"y":250},{"x":240,"y":250},{"x":300,"y":250},{"x":352,"y":250},{"x":204,"y":198},{"x":276,"y":190}],
"compass_clear":[380,230,480,270]}
]]
local f = io.open(OUT .. NAME .. ".layout.json", "w"); f:write(layout); f:close()

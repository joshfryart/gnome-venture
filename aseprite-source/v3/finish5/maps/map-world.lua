-- finish5 map-world 640x360: second richness pass ON TOP of the finish4 live map (base-map-world.png = copy of live).
-- Adds: 4 value layers of rock depth (far dark -> near lit), wavy strata with chips and cracks, ore flecks, crystal glints,
-- rock-fall rubble at cavern rims, ceiling root tangles + hanging vines, glowing mycelium threads beside tunnels,
-- lanterns at tunnel mouths, carved round doorways, themed cavern floor texture (moss / sand ripples / gravel / glints),
-- small pools with drips and reflections, and a warmer, clearer lit Mossbottom hub.
-- Never touches: cavern shapes, tunnel pixels, halos, props, frame spikes. map-world-regions.png is only READ
-- (to know the caverns and keep each cavern centre clear for the game's pins and labels).
-- Run: AppRun -b --script-param out=<dir>/ --script map-world.lua
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local OUT = app.params.out or (d .. "/")
local SRC = d .. "/base-map-world.png"
local REG = d .. "/../../../../game/assets/img/scenes/map-world-regions.png"
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local W, H = 640, 360
local px = app.pixelColor

local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483647) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  return ((n ~ (n >> 16)) % 65536) / 65536
end
local function vn(x, y, sc, s)
  local gx, gy = x / sc, y / sc
  local x0, y0 = floor(gx), floor(gy)
  local fx, fy = gx - x0, gy - y0
  fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
  local a, b, c, e = hash(x0, y0, s), hash(x0 + 1, y0, s), hash(x0, y0 + 1, s), hash(x0 + 1, y0 + 1, s)
  return a + (b - a) * fx + (c - a) * fy + (a - b - c + e) * fx * fy
end
local function hx(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end
local function mix(a, b, t)
  local r1, g1, b1 = hx(a); local r2, g2, b2 = hx(b)
  return hex(floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function set(t) local s = {} for _, k in ipairs(t) do s[k] = true end return s end
local function inb(x, y) return x >= 0 and y >= 0 and x < W and y < H end

-- read base + regions
local img = Image{ fromFile = SRC }
local rimg = Image{ fromFile = REG }
local cur, reg = {}, {}
for y = 0, H - 1 do for x = 0, W - 1 do
  local v = img:getPixel(x, y)
  cur[y * W + x] = hex(px.rgbaR(v), px.rgbaG(v), px.rgbaB(v))
  local r = rimg:getPixel(x, y)
  local k = hex(px.rgbaR(r), px.rgbaG(r), px.rgbaB(r))
  if k ~= "#101010" then reg[y * W + x] = k end
end end
local orig = {}
for i = 0, W * H - 1 do orig[i] = cur[i] end

local ROCK = set{ "#241610", "#2c1c12", "#33221a", "#3d2a1c", "#4a2c1a", "#2a1a10" }
local PATH = set{ "#74462a", "#9a6b3f", "#c9a96e", "#5e3922" }
local INK = "#2b1c26"
local function isRock(i) local y = i // W return ROCK[orig[i]] and y >= 20 and y <= 335 end

local function bfs(isSrc, lim)
  local dist, q, qh = {}, {}, 1
  for i = 0, W * H - 1 do if isSrc(i) then dist[i] = 0; q[#q + 1] = i end end
  while qh <= #q do
    local i = q[qh]; qh = qh + 1
    local x, y, dd = i % W, i // W, dist[i]
    if dd < lim then
      for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local xx, yy = x + o[1], y + o[2]
        if inb(xx, yy) then
          local j = yy * W + xx
          if dist[j] == nil then dist[j] = dd + 1; q[#q + 1] = j end
        end
      end
    end
  end
  return dist
end
local dNR = bfs(function(i) local y = i // W return not ROCK[orig[i]] and y >= 18 and y <= 337 end, 90)   -- depth into rock
local dMask = bfs(function(i) return reg[i] ~= nil end, 30)
local TUN = {}
for i = 0, W * H - 1 do if not reg[i] and PATH[orig[i]] and (dMask[i] or 99) >= 2 and i // W >= 20 and i // W <= 335 then TUN[i] = true end end
local dT = bfs(function(i) return TUN[i] end, 20)
local function D(t, x, y, def) if not inb(x, y) then return def or 0 end return t[y * W + x] or def or 99 end

-- region centres (pins + labels): keep clear. Plus the Mossbottom hub (not a region in the mask).
local HUBX, HUBY = 252, 298
local cen = {}
do
  local sx, sy, n = {}, {}, {}
  for i, k in pairs(reg) do sx[k] = (sx[k] or 0) + i % W; sy[k] = (sy[k] or 0) + i // W; n[k] = (n[k] or 0) + 1 end
  for k, c in pairs(n) do cen[#cen + 1] = { sx[k] / c, sy[k] / c, k } end
  cen[#cen + 1] = { HUBX, HUBY, "hub" }
end
local function nearCentre(x, y, pad)
  pad = pad or 0
  for _, c in ipairs(cen) do
    local dx, dy = (x - c[1]) / (20 + pad), (y - c[2] - 3) / (17 + pad)
    if dx * dx + dy * dy <= 1 then return true end
  end
  return false
end

local used = {}
local function put(x, y, col) if inb(x, y) then cur[y * W + x] = col end end
local function rockAt(x, y, dmin) if not inb(x, y) then return false end local i = y * W + x return isRock(i) and (dNR[i] or 99) >= (dmin or 1) and not used[i] end
local function hubR(x, y) return sqrt((x - HUBX) ^ 2 + ((y - HUBY) * 1.25) ^ 2) end

-- 1. rock: 4 value layers by depth into the rock + wavy strata (dNR >= 3 so the halo dither stays as it was)
local LAY = {
  { "#170f0e", "#1c1311", "#221712", "#2a1c15" },   -- far, deepest (a touch cooler)
  { "#20150f", "#271a12", "#2f2017", "#38271b" },
  { "#2b1c13", "#33231a", "#3c2a1e", "#47331f" },
  { "#36251a", "#42301f", "#4f3925", "#5d452b" },   -- near, lit
}
local layerOf = {}
for y = 20, 335 do for x = 0, W - 1 do
  local i = y * W + x
  if isRock(i) then
    local dd = (dNR[i] or 90) + (vn(x, y, 9, 21) - .5) * 10
    local L = (dd < 9 and 4) or (dd < 20 and 3) or (dd < 34 and 2) or 1
    layerOf[i] = L
    if (dNR[i] or 99) >= 3 then
      local s = y + 5 * sin(x / 41 + y / 97) + 2 * sin(x / 13 + y / 30)
      local band = floor(s / 11)
      local f = s - band * 11
      local v = vn(x, y + band * 7, 7, 3) * .65 + vn(x, y, 3, 8) * .35 + ((band % 2 == 0) and .07 or -.05)
      local t = (v < .38 and 1) or (v < .55 and 2) or (v < .7 and 3) or 4
      if t == 3 and (x + y) % 2 == 0 and v < .58 then t = 2 end
      local col
      if f < 1 and vn(x, band, 6, 5) > .3 then t = 1; col = mix(LAY[L][1], "#0f0a0a", .3)
      elseif f < 2 and vn(x, band, 5, 6) > .45 then col = mix(LAY[L][4], "#8a6a4a", .18) end
      cur[i] = col or LAY[L][t]
    end
  end
end end

-- cracks (dark line, lit lower-right lip) and chips (lit flake, dark under-right)
for n = 1, 110 do
  local x, y = floor(hash(n, 1, 31) * W), 22 + floor(hash(n, 2, 31) * 312)
  if rockAt(x, y, 6) then
    local len = 6 + floor(hash(n, 3, 31) * 12)
    local dx = hash(n, 4, 31) < .5 and -1 or 1
    for s = 1, len do
      if not rockAt(x, y, 3) then break end
      local L = layerOf[y * W + x]
      put(x, y, "#170e0b")
      if rockAt(x + 1, y + 1, 3) then put(x + 1, y + 1, LAY[L][4]) end
      local r = hash(n, s, 32)
      if r < .45 then y = y + 1 elseif r < .8 then x = x + dx else x = x + dx; y = y + 1 end
      if hash(n, s, 33) > .9 then dx = -dx end
    end
  end
end
for n = 1, 260 do
  local x, y = floor(hash(n, 1, 41) * W), 22 + floor(hash(n, 2, 41) * 312)
  local w, h = 2 + floor(hash(n, 3, 41) * 2), 1 + floor(hash(n, 4, 41) * 2)
  local ok = true
  for yy = y, y + h do for xx = x, x + w do if not rockAt(xx, yy, 4) then ok = false end end end
  if ok then
    local L = layerOf[y * W + x]
    local hi = mix(LAY[L][4], "#8a6a4a", .25)
    for yy = y, y + h - 1 do for xx = x, x + w - 1 do put(xx, yy, (yy == y and xx == x) and mix(hi, "#a88a66", .3) or hi) end end
    for xx = x + 1, x + w do put(xx, y + h, LAY[L][1]) end
    put(x + w, y + h - 1, LAY[L][1])
  end
end

-- 2. ore flecks
local ORE = { { "#b8862e", "#ffe08a" }, { "#a8583a", "#e8a070" }, { "#2f8f88", "#9af0e0" }, { "#6a50b0", "#c3b2ea" }, { "#8a8aa0", "#e2e0e6" } }
for n = 1, 260 do
  local x, y = floor(hash(n, 1, 51) * W), 22 + floor(hash(n, 2, 51) * 312)
  if rockAt(x, y, 4) and rockAt(x + 1, y + 1, 4) and rockAt(x - 1, y - 1, 4) then
    local o = ORE[1 + floor(hash(n, 3, 51) * #ORE)]
    if (layerOf[y * W + x] or 1) <= 2 and hash(n, 5, 51) < .4 then o = ORE[1] end
    put(x, y, o[1])
    if hash(n, 4, 51) < .6 then put(x + 1, y, o[1]); put(x, y - 1, o[2]) else put(x - 1, y - 1, o[2]) end
    put(x + 1, y + 1, "#170e0b")
    used[y * W + x] = true
  end
end

-- 3. crystal glints in the rock (small shard clusters with one cream glint)
local CRY = { { "#3a86b0", "#5fc4c8", "#b6f0e0" }, { "#5a459e", "#8a6fd0", "#c9b2f0" }, { "#c94f84", "#f5809f", "#ffc4d8" }, { "#3f9150", "#7cc35a", "#c4e07a" } }
local ncry, lastC = 0, {}
for n = 1, 600 do
  if ncry >= 16 then break end
  local x, y = floor(hash(n, 1, 61) * W), 26 + floor(hash(n, 2, 61) * 306)
  local ok = true
  for yy = y - 7, y + 1 do for xx = x - 3, x + 4 do if not rockAt(xx, yy, 5) then ok = false end end end
  for _, q in ipairs(lastC or {}) do if abs(q[1] - x) + abs(q[2] - y) < 60 then ok = false end end
  if ok then
    lastC = lastC or {}; lastC[#lastC + 1] = { x, y }
    ncry = ncry + 1
    local R = CRY[1 + floor(hash(n, 3, 61) * #CRY)]
    local shards = { { 0, 4 + floor(hash(n, 4, 61) * 3) }, { -2, 2 + floor(hash(n, 5, 61) * 2) }, { 2, 3 + floor(hash(n, 6, 61) * 2) } }
    for _, s in ipairs(shards) do
      local sx, h = x + s[1], s[2]
      for k = 0, h - 1 do put(sx, y - k, R[2]); put(sx + 1, y - k, R[1]) end
      put(sx, y - h, R[3])
    end
    for xx = x - 2, x + 3 do put(xx, y + 1, "#1c110c") end
    put(x, y - shards[1][2] - 1, "#fff4d6")
    put(x - 1, y - shards[1][2], mix(R[3], "#fff4d6", .5)); put(x + 1, y - shards[1][2], mix(R[3], "#fff4d6", .5))
    for yy = y - 7, y + 1 do for xx = x - 3, x + 4 do used[yy * W + xx] = true end end
  end
end

-- 4. rock-fall rubble at cavern rims (in the rock just outside the halo)
local STN = { "#3a2c28", "#5a4a42", "#857565", "#b0a090" }
local function stone(cx, cy, r)
  for yy = cy - r, cy + r do for xx = cx - r - 1, cx + r + 1 do
    local e = ((xx - cx) / (r + .6)) ^ 2 + ((yy - cy) / (r * .8 + .5)) ^ 2
    if e <= 1 and rockAt(xx, yy, 2) then
      local l = (cx - xx) + (cy - yy)
      local col = (e > .7 and (xx - cx) + (yy - cy) > 0) and STN[1] or (l >= 1 and STN[4]) or (l >= -1 and STN[3]) or STN[2]
      put(xx, yy, col)
    end
  end end
  for xx = cx - r, cx + r + 1 do if rockAt(xx, cy + r + 1, 2) then put(xx, cy + r + 1, "#1c110c") end end
end
local nrub, lastR = 0, {}
for n = 1, 4000 do
  if nrub >= 26 then break end
  local x, y = floor(hash(n, 1, 71) * W), 24 + floor(hash(n, 2, 71) * 306)
  local i = y * W + x
  local dd = dNR[i] or 99
  if isRock(i) and dd >= 4 and dd <= 7 and not used[i] and (dT[i] or 99) > 6 then
    local far = true
    for _, p in ipairs(lastR) do if abs(p[1] - x) + abs(p[2] - y) < 34 then far = false end end
    if far then
      nrub = nrub + 1; lastR[#lastR + 1] = { x, y }
      stone(x, y, 2)
      stone(x + 4, y + 1, 1); stone(x - 3, y + 2, 1)
      if hash(n, 3, 71) < .6 then stone(x + 2, y - 3, 1) end
      put(x + 6, y + 3, STN[3]); put(x - 5, y, STN[2])
    end
  end
end

-- 5. ceiling: root tangles and hanging vines (drawn only over rock, so they pass behind spikes)
local function root(x, y, len, thick, seed, depth)
  local dir = 0
  for s = 1, len do
    if not inb(x, y) then return end
    local i = y * W + x
    local okHere = ROCK[orig[i]] and (y < 20 or (dNR[i] or 99) >= 4) and not used[i]
    if y >= 20 and not okHere then return end
    if okHere then
      put(x, y, "#5a3a26")
      if thick > 1 and s < len * .55 then
        if ROCK[orig[i + 1]] then put(x + 1, y, "#3e2618") end
        if ROCK[orig[i - 1]] then put(x - 1, y, "#7a5236") end
      elseif ROCK[orig[i - 1]] and s % 3 == 0 then put(x - 1, y, "#6e4a30") end
    end
    local r = hash(seed, s, 81)
    if r < .2 then dir = -1 elseif r < .4 then dir = 1 elseif r < .75 then dir = 0 end
    x = x + dir; y = y + 1
    if depth < 2 and hash(seed, s, 82) > .93 and s > 4 then root(x, y, floor((len - s) * .6), 1, seed * 7 + s, depth + 1) end
  end
end
local function vine(x, y, len, seed)
  for s = 1, len do
    local i = y * W + x
    if not inb(x, y) then return end
    local okHere = ROCK[orig[i]] and (y < 20 or (dNR[i] or 99) >= 4) and not used[i]
    if y >= 20 and not okHere then
      put(x, y - 1, "#9af0e0"); return
    end
    if okHere then
      put(x, y, "#3c6e34")
      if s % 3 == 0 then
        local side = (s // 3) % 2 == 0 and -1 or 1
        if rockAt(x + side, y, 1) or y < 20 then put(x + side, y, "#5f9a44") end
        if rockAt(x + 2 * side, y - 1, 1) or y < 20 then put(x + 2 * side, y - 1, "#8cc45a") end
      end
    end
    if s == len then
      if okHere then put(x, y + 1, "#52d6c4"); put(x, y + 2, "#9af0e0") end
    end
    x = x + floor(sin((y + seed) / 4) + .5) * ((s % 4 == 0) and 1 or 0)
    y = y + 1
  end
end
for n = 0, 62 do
  local x = 4 + n * 10 + floor(hash(n, 1, 91) * 8)
  if x < W - 4 then
    local len = 16 + floor(hash(n, 2, 91) * 40)
    if hash(n, 3, 91) < .62 then root(x, 2 + floor(hash(n, 4, 91) * 6), len, 2, n + 1, 0)
    else vine(x, 4, 10 + floor(len * .6), n) end
  end
end

-- 6. glowing mycelium threads beside the tunnels (on the rock 2 px off the tunnel, never at the mouths)
for y = 20, 335 do for x = 0, W - 1 do
  local i = y * W + x
  if isRock(i) and dT[i] == 2 and (dMask[i] or 99) >= 8 and not used[i] then
    local v = vn(x, y, 6, 101)
    if v > .5 then
      local col = (hash(x, y, 102) > .9) and "#9af0e0" or ((v > .62) and "#3fa89c" or "#2e6e66")
      put(x, y, col)
      if col == "#9af0e0" then
        -- tiny filament outward
        for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
          local xx, yy = x + o[1], y + o[2]
          if inb(xx, yy) and dT[yy * W + xx] == 3 and isRock(yy * W + xx) then put(xx, yy, "#2e6e66"); put(xx + o[1], yy + o[2], "#24504c") end
        end
      end
      used[i] = true
    end
  end
end end

-- 7. carved round doorways in the rock near tunnels
local function doorway(x, y)
  -- 9 wide x 10 tall; (x,y) top-left
  local function inArch(xx, yy, r) return ((xx - 4) / r) ^ 2 + ((yy - 4.5) / (r + .5)) ^ 2 <= 1 or (yy >= 5 and abs(xx - 4) <= r) end
  for yy = 0, 9 do for xx = 0, 8 do
    local X, Y = x + xx, y + yy
    if yy <= 8 and inArch(xx, yy, 4.4) then
      local col
      if inArch(xx, yy, 3.2) then
        col = (xx % 2 == 0) and "#5e3820" or "#7a4a2a"
        if yy <= 2 then col = "#4a2a1a" end
        if xx == 6 and yy == 5 then col = "#f5b82e" end
        if xx == 2 and yy == 3 then col = "#ffcf6a" end
      else
        col = ((xx + yy) <= 7) and "#b0a090" or "#6a5a50"
        if inArch(xx, yy, 3.9) and not inArch(xx, yy, 3.2) then col = "#2b1c26" end
      end
      put(X, Y, col); used[Y * W + X] = true
    end
  end end
  for xx = 1, 7 do put(x + xx, y + 9, "#6a5240") end
  put(x, y + 9, "#3a2c28"); put(x + 8, y + 9, "#3a2c28")
  -- warm spill under the door
  for xx = 2, 6 do if rockAt(x + xx, y + 10, 1) then put(x + xx, y + 10, (xx % 2 == 0) and "#6a4628" or "#4a3020") end end
end
local doors = {}
for n = 1, 6000 do
  if #doors >= 6 then break end
  local x, y = floor(hash(n, 1, 111) * (W - 10)), 24 + floor(hash(n, 2, 111) * 300)
  local c = (y + 5) * W + x + 4
  local dd = dT[c] or 99
  if dd >= 5 and dd <= 12 and (dMask[c] or 99) >= 10 and not nearCentre(x + 4, y + 5, 6) then
    local ok = true
    for yy = y - 1, y + 11 do for xx = x - 1, x + 9 do if not rockAt(xx, yy, 3) then ok = false end end end
    for _, p in ipairs(doors) do if abs(p[1] - x) + abs(p[2] - y) < 70 then ok = false end end
    if ok then doors[#doors + 1] = { x, y }; doorway(x, y) end
  end
end

-- 8. Mossbottom hub: warm light pool in the rock around the grotto (ordered dither, hard pixels)
for y = HUBY - 50, HUBY + 40 do for x = HUBX - 62, HUBX + 62 do
  if inb(x, y) then
    local i = y * W + x
    if ROCK[orig[i]] and y <= 335 and not used[i] then
      local r = hubR(x, y)
      local c = (x + y) % 2 == 0
      local c4 = (x % 2 == 0) and (y % 2 == 0)
      local col
      if r < 34 then col = c and "#6a4628" or "#56391f"
      elseif r < 42 then col = c and "#56391f" or "#45301f"
      elseif r < 50 then col = c and "#45301f" or nil
      elseif r < 58 then col = c4 and "#45301f" or nil end
      if col then cur[i] = col end
    end
  end
end end
-- hub floor: a touch warmer (lamplight) outside the pin spot
for y = HUBY - 22, HUBY + 22 do for x = HUBX - 34, HUBX + 34 do
  if inb(x, y) then
    local i = y * W + x
    local k = orig[i]
    local r, g, b = hx(k)
    if g > r + 20 and g > b + 10 and r < 120 and hubR(x, y) > 14 then cur[i] = mix(k, "#f5cf6a", .16) end
  end
end end

-- 9. lanterns at tunnel mouths (on the rock beside a tunnel, just before it opens into a cavern) + hub ring
local function lantern(x, y)
  -- glow first
  for yy = y - 4, y + 5 do for xx = x - 4, x + 4 do
    if inb(xx, yy) then
      local i = yy * W + xx
      local r = sqrt((xx - x) ^ 2 + (yy - y) ^ 2)
      if ROCK[orig[i]] and not used[i] and yy >= 20 then
        if r <= 3.2 then cur[i] = ((xx + yy) % 2 == 0) and "#8a5a24" or "#6a4628"
        elseif r <= 4.5 and (xx + yy) % 2 == 0 then cur[i] = "#56391f" end
      end
    end
  end end
  put(x, y - 2, INK)
  put(x - 1, y - 1, INK); put(x, y - 1, "#ffe08a"); put(x + 1, y - 1, INK)
  put(x - 1, y, "#f5b82e"); put(x, y, "#fff0b0"); put(x + 1, y, "#d98322")
  put(x - 1, y + 1, INK); put(x, y + 1, "#d98322"); put(x + 1, y + 1, INK)
  put(x, y + 2, "#4a2e1e"); put(x, y + 3, "#4a2e1e"); put(x - 1, y + 4, "#3a2418"); put(x, y + 4, "#4a2e1e"); put(x + 1, y + 4, "#3a2418")
  for yy = y - 2, y + 4 do for xx = x - 1, x + 1 do if inb(xx, yy) then used[yy * W + xx] = true end end end
end
local lamps = {}
for y = 20, 335 do for x = 0, W - 1 do
  local i = y * W + x
  if TUN[i] and (dMask[i] or 99) >= 3 and (dMask[i] or 99) <= 6 then
    local far = true
    for _, p in ipairs(lamps) do if abs(p[3] - x) + abs(p[4] - y) < 30 then far = false end end
    if far then
      -- find a rock spot 4-6 px off the tunnel, as near this mouth as possible
      local best, bd
      for yy = y - 9, y + 9 do for xx = x - 9, x + 9 do
        if inb(xx, yy) then
          local j = yy * W + xx
          local t = dT[j] or 99
          if t >= 4 and t <= 6 and (dMask[j] or 99) >= 4 then
            local ok = true
            for y2 = yy - 2, yy + 4 do for x2 = xx - 1, xx + 1 do
              if not inb(x2, y2) or not ROCK[orig[y2 * W + x2]] or used[y2 * W + x2] or TUN[y2 * W + x2] or reg[y2 * W + x2] then ok = false end
            end end
            local dd = abs(xx - x) + abs(yy - y)
            if ok and (not bd or dd < bd) then best, bd = { xx, yy }, dd end
          end
        end
      end end
      if best then lamps[#lamps + 1] = { best[1], best[2], x, y } end
    end
  end
end end
for _, p in ipairs(lamps) do lantern(p[1], p[2]) end
for _, a in ipairs({ -2.6, -1.9, -0.5, 0.3, 2.9 }) do
  for rr = 36, 46, 2 do
    local x, y = floor(HUBX + cos(a) * rr + .5), floor(HUBY + sin(a) * rr / 1.25 + .5)
    local ok = true
    for y2 = y - 2, y + 4 do for x2 = x - 1, x + 1 do if not inb(x2, y2) or not ROCK[orig[y2 * W + x2]] or used[y2 * W + x2] or y2 < 20 or y2 > 335 then ok = false end end end
    if ok then lantern(x, y); break end
  end
end

-- 10. cavern floors: themed texture on plain floor pixels (no ink within 2 px), never in the pin/label spot
local stats = {}
for i, k in pairs(reg) do
  local r, g, b = hx(orig[i])
  local s = stats[k] or { r = {}, g = {}, b = {} }
  stats[k] = s
  s.r[#s.r + 1] = r; s.g[#s.g + 1] = g; s.b[#s.b + 1] = b
end
local med = {}
for k, s in pairs(stats) do
  table.sort(s.r); table.sort(s.g); table.sort(s.b)
  local m = #s.r // 2 + 1
  local r, g, b = s.r[m], s.g[m], s.b[m]
  local lum = .3 * r + .59 * g + .11 * b
  local th
  if g > r + 12 and g >= b then th = "moss"
  elseif r > g and g > b and lum > 150 then th = "sand"
  elseif r > g and g > b and r - b > 40 and lum <= 150 and r < 200 then th = "gravel"
  elseif r > 190 and g < 110 then th = "ember"
  elseif b > r then th = "ice"
  else th = "glint" end
  med[k] = { r, g, b, th }
end
local function floorish(x, y)
  if not inb(x, y) then return false end
  local i = y * W + x
  local k = reg[i]
  if not k then return false end
  local r, g, b = hx(orig[i])
  local m = med[k]
  if abs(r - m[1]) + abs(g - m[2]) + abs(b - m[3]) > 70 then return false end
  for yy = y - 2, y + 2 do for xx = x - 2, x + 2 do
    if not inb(xx, yy) or orig[yy * W + xx] == INK or reg[yy * W + xx] ~= k then return false end
  end end
  return true
end
local FL = {}
for y = 20, 335 do for x = 0, W - 1 do if floorish(x, y) and not nearCentre(x, y, 0) then FL[y * W + x] = true end end end
local function shade(c, t) return mix(c, "#2b1c26", t) end
local function light(c, t) return mix(c, "#fff4d6", t) end
for y = 20, 335 do for x = 0, W - 1 do
  local i = y * W + x
  if FL[i] then
    local k = orig[i]
    local th = med[reg[i]][4]
    local h = hash(x, y, 121)
    if th == "moss" then
      local v = vn(x, y, 5, 122)
      if v > .64 then cur[i] = shade(k, .18) elseif v < .3 and (x + y) % 2 == 0 then cur[i] = light(k, .12) end
      if h < .022 and FL[i - W] and FL[i - 2 * W] and FL[i - 1] and FL[i + 1] then   -- grass tuft
        put(x, y, shade(k, .3)); put(x - 1, y - 1, light(k, .22)); put(x + 1, y - 1, light(k, .22)); put(x, y - 2, light(k, .4))
      elseif h > .994 then put(x, y, "#ffc4d8"); put(x, y + 1, shade(k, .3)) end   -- tiny bloom
    elseif th == "sand" then
      local s = (y + 2.5 * sin(x / 7 + y / 23)) % 6
      if s < 1 then cur[i] = shade(k, .14) elseif s < 2 and (x % 3 ~= 0) then cur[i] = light(k, .14) end
      if h < .02 then cur[i] = light(k, .3) elseif h > .985 then cur[i] = shade(k, .25) end
    elseif th == "gravel" then
      if h < .05 and FL[i + 1] and FL[i + W] and FL[i + W + 1] then
        put(x, y, light(k, .35)); put(x + 1, y, light(k, .15)); put(x, y + 1, light(k, .12)); put(x + 1, y + 1, shade(k, .35))
      elseif h > .96 then cur[i] = shade(k, .25) end
    elseif th == "ember" then
      if h < .012 then cur[i] = "#ffcf5a" elseif h > .985 then cur[i] = "#7a2018" end
    elseif th == "ice" then
      if h < .006 and FL[i - W] and FL[i + W] and FL[i - 1] and FL[i + 1] then
        put(x, y, "#f4fbff"); put(x - 1, y, light(k, .4)); put(x + 1, y, light(k, .4)); put(x, y - 1, light(k, .4)); put(x, y + 1, light(k, .4))
      elseif (x * 3 + y) % 11 == 0 and vn(x, y, 6, 123) > .6 then cur[i] = light(k, .18) end
    else
      if h < .008 then cur[i] = "#fff4d6" elseif vn(x, y, 5, 124) > .68 and (x + y) % 2 == 0 then cur[i] = shade(k, .1) end
    end
  end
end end

-- 11. pools with a drip and a reflection (moss / sand / gravel caverns, one each where a clean spot fits)
local function pool(cx, cy, k)
  local rx, ry = 6, 3
  local rim = shade(k, .45)
  for yy = cy - ry - 1, cy + ry + 1 do for xx = cx - rx - 1, cx + rx + 1 do
    local e = ((xx - cx) / (rx + .5)) ^ 2 + ((yy - cy) / (ry + .5)) ^ 2
    local e2 = ((xx - cx) / (rx + 1.5)) ^ 2 + ((yy - cy) / (ry + 1.3)) ^ 2
    if e <= 1 then
      local col = (yy <= cy - ry + 1) and "#2a4a7a" or ((yy >= cy + 1) and "#5fc4c8" or "#3a86b0")
      put(xx, yy, col)
    elseif e2 <= 1 then put(xx, yy, (yy < cy) and rim or light(k, .2)) end
  end end
  -- reflection of the lit cavern ceiling + glint
  put(cx - 3, cy, "#b6f0e0"); put(cx - 2, cy, "#b6f0e0"); put(cx + 2, cy + 1, "#b6f0e0"); put(cx - 4, cy - 1, "#e4f6ff")
  -- drip: falling drop and a ripple ring
  put(cx + 2, cy - ry - 6, "#b6f0e0"); put(cx + 2, cy - ry - 4, "#5fc4c8"); put(cx + 2, cy - ry - 3, "#b6f0e0")
  put(cx + 1, cy - 1, "#8bd8dc"); put(cx + 3, cy - 1, "#8bd8dc"); put(cx + 2, cy - 2, "#8bd8dc")
end
local pooled = {}
for n = 1, 30000 do
  local x, y = floor(hash(n, 1, 131) * W), 22 + floor(hash(n, 2, 131) * 310)
  local i = y * W + x
  local k = reg[i]
  if k and not pooled[k] and FL[i] then
    local th = med[k][4]
    if th == "moss" or th == "sand" or th == "gravel" then
      local ok = true
      local bad = 0
      for yy = y - 9, y + 5 do for xx = x - 8, x + 8 do if not FL[yy * W + xx] then bad = bad + 1 end end end
      ok = bad <= 6 and FL[(y - 9) * W + x + 2] and not nearCentre(x, y, 10)
      if ok then pooled[k] = true; pool(x, y, orig[i]) end
    end
  end
end

-- safety: no pure black/white, opaque
local out = Image(W, H, ColorMode.RGB)
for y = 0, H - 1 do for x = 0, W - 1 do
  local r, g, b = hx(cur[y * W + x])
  if r + g + b == 0 then r, g, b = 23, 14, 11 end
  if r == 255 and g == 255 and b == 255 then r, g, b = 255, 244, 214 end
  out:putPixel(x, y, px.rgba(r, g, b, 255))
end end
out:saveAs(OUT .. "map-world.png")
print("lamps " .. #lamps .. " doors " .. #doors .. " crystals " .. ncry .. " rubble " .. nrub)

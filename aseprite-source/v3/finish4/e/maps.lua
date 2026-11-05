-- finish4 map-world 640x360: cleaned blobs (mode filter), ink rim + lit/shaded edge, glow halos; props v2 (big, 3-tone, glow rims) + frame spikes.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local INK = "#2b1c26"
local SRC = d .. "/base-map-world.png"   -- pre-finish4 picture (was the live map-world.png before finish4)
local mix = GX.mix
local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483647) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  return ((n ~ (n >> 16)) % 65536) / 65536
end
local function hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end
local function set(t) local s = {} for _, k in ipairs(t) do s[k] = true end return s end
local BG = set{ "#2a1a10", "#3d2a1c", "#4a2c1a" }
local HALO = set{ "#25637d", "#3f8fb0", "#4e3a8a", "#7b66b4", "#e8a317" }
local PATH = set{ "#9a6b3f", "#74462a", "#c9a96e", "#f2e4c0" }
local PBODY = set{ "#9a6b3f", "#74462a", "#c9a96e" }
local DETAIL = set{ "#dd3a2a", "#e46a9b", "#8b8f96", "#5b6470", "#eef8f2", "#d6322b", "#f08a24", "#8a4f2a", "#c8d77a", "#a8582f", "#a9d6ea", "#c3b2ea", "#7a5cc0", "#fff3c8" }

local W, H = 640, 360
local img = Image{ fromFile = SRC }
local px = app.pixelColor
local old = {}
for y = 0, H - 1 do for x = 0, W - 1 do
  local v = img:getPixel(x, y)
  old[y * W + x] = hex(px.rgbaR(v), px.rgbaG(v), px.rgbaB(v))
end end
local function cls(k) if BG[k] then return 1 elseif HALO[k] then return 2 elseif PATH[k] then return 3 elseif DETAIL[k] then return 4 else return 5 end end

-- 1. remove detail pixels and speckle: mode of nearby ordinary colours (not path, not detail)
local function modeAt(src, x, y, rad, skipPath)
  local cnt, best, bn = {}, nil, 0
  for dy = -rad, rad do for dx = -rad, rad do
    local xx, yy = x + dx, y + dy
    if xx >= 0 and yy >= 0 and xx < W and yy < H then
      local k = src[yy * W + xx]
      local c = cls(k)
      if c ~= 4 and not (skipPath and c == 3) then
        cnt[k] = (cnt[k] or 0) + 1
        if cnt[k] > bn then bn = cnt[k]; best = k end
      end
    end
  end end
  return best
end
local cur = {}
for i = 0, W * H - 1 do cur[i] = old[i] end
for y = 0, H - 1 do for x = 0, W - 1 do
  local k = old[y * W + x]
  if k == "#f2e4c0" then
    local n = 0
    for dy = -2, 2 do for dx = -2, 2 do local xx, yy = x + dx, y + dy; if xx >= 0 and yy >= 0 and xx < W and yy < H and PBODY[old[yy * W + xx]] then n = n + 1 end end end
    if n >= 8 then cur[y * W + x] = "#c9a96e" else cur[y * W + x] = modeAt(old, x, y, 4, true) or "#2a1a10" end
  elseif cls(k) == 4 then cur[y * W + x] = modeAt(old, x, y, 4, true) or modeAt(old, x, y, 9, true) or "#2a1a10" end
end end
for pass = 1, 2 do
  local nxt = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local k = cur[y * W + x]
    if cls(k) == 3 then nxt[y * W + x] = k else nxt[y * W + x] = modeAt(cur, x, y, 1, true) or k end
  end end
  cur = nxt
end
local C = {}
for i = 0, W * H - 1 do C[i] = cls(cur[i]) end
do  -- enclosed small bg/halo holes inside the figure become figure colour
  local seen = {}
  for i0 = 0, W * H - 1 do
    if (C[i0] == 1 or C[i0] == 2) and not seen[i0] then
      local comp, qh, touch = { i0 }, 1, false
      seen[i0] = true
      while qh <= #comp and #comp < 400 do
        local i = comp[qh]; qh = qh + 1
        local x, y = i % W, i // W
        if x == 0 or y == 0 or x == W - 1 or y == H - 1 then touch = true end
        for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
          local xx, yy = x + o[1], y + o[2]
          if xx >= 0 and yy >= 0 and xx < W and yy < H then
            local j = yy * W + xx
            if (C[j] == 1 or C[j] == 2) and not seen[j] then seen[j] = true; comp[#comp + 1] = j end
          end
        end
      end
      if #comp < 70 and qh > #comp and not touch then
        for _, i in ipairs(comp) do
          local x, y = i % W, i // W
          local best, bn, cnt = nil, 0, {}
          for dy = -4, 4 do for dx = -4, 4 do
            local xx, yy = x + dx, y + dy
            if xx >= 0 and yy >= 0 and xx < W and yy < H then
              local k = cur[yy * W + xx]; local cc = cls(k)
              if cc == 5 then cnt[k] = (cnt[k] or 0) + 1; if cnt[k] > bn then bn = cnt[k]; best = k end end
            end
          end end
          if best then cur[i] = best end
        end
        for _, i in ipairs(comp) do C[i] = cls(cur[i]) end
      end
    end
  end
end
local function cl(x, y) if x < 0 or y < 0 or x >= W or y >= H then return 1 end return C[y * W + x] end

-- 2. distances: dFig = outside distance from figure (blob+path); dIn = inside distance to non-figure
local function bfs(isSrc)
  local dist, q, qh = {}, {}, 1
  for i = 0, W * H - 1 do if isSrc(i) then dist[i] = 0; q[#q + 1] = i end end
  while qh <= #q do
    local i = q[qh]; qh = qh + 1
    local x, y, dd = i % W, i // W, dist[i]
    if dd < 14 then
      for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local xx, yy = x + o[1], y + o[2]
        if xx >= 0 and yy >= 0 and xx < W and yy < H then
          local j = yy * W + xx
          if dist[j] == nil then dist[j] = dd + 1; q[#q + 1] = j end
        end
      end
    end
  end
  return dist
end
local dOut = bfs(function(i) return C[i] == 3 or C[i] == 5 end)           -- distance from figure
local dIn = bfs(function(i) return C[i] == 1 or C[i] == 2 end)            -- distance from outside
local function fig(x, y) local c = cl(x, y) return c == 3 or c == 5 end

-- 3. paint
local c = HP.canvas{ w = W, h = H, scale = 1, name = "map-world" }
local BGT = { "#241610", "#2c1c12", "#33221a", "#3d2a1c" }
for y = 0, H - 1 do for x = 0, W - 1 do
  local k, cc = cur[y * W + x], C[y * W + x]
  local out
  if cc == 1 then
    local v = GX.vn(x, y, 11, 3) * .6 + GX.vn(x, y, 4, 7) * .4
    local i = (v < .36 and 1) or (v < .55 and 2) or (v < .72 and 3) or 4
    if (x + y) % 2 == 0 and v > .5 and v < .56 then i = i - 1 end
    out = BGT[max(1, i)]
    if hash(x, y, 4) > .992 then out = "#4a2c1a" end
    if y < 20 or y > 335 then out = k end   -- keep the frame stalactites as they were
  elseif cc == 2 then
    local dd = dOut[y * W + x] or 14
    local bgc = BGT[2]
    if dd <= 3 then out = mix(k, bgc, .15)
    elseif dd <= 6 then out = ((x + y) % 2 == 0) and mix(k, bgc, .25) or mix(k, bgc, .7)
    elseif dd <= 9 then out = ((x % 2 == 0) and (y % 2 == 0)) and mix(k, bgc, .4) or bgc
    else out = (x % 3 == 0 and y % 3 == 0) and mix(k, bgc, .5) or bgc end
  elseif cc == 3 then
    out = k
  else
    local di = dIn[y * W + x] or 14
    out = k
    local nz = GX.vn(x, y, 30, 5) - .5
    out = mix(out, (nz > 0) and "#fff2c8" or "#2b1c26", abs(nz) * .22)
    if di <= 1 then out = INK
    elseif di <= 3 then
      local tl = (not fig(x - 3, y - 3)) or (not fig(x - 3, y)) or (not fig(x, y - 3))
      local br = (not fig(x + 3, y + 3)) or (not fig(x + 3, y)) or (not fig(x, y + 3))
      if tl and not br then out = mix(k, "#fff2c8", .38) elseif br and not tl then out = mix(k, "#2b1c26", .36) end
      if di == 2 and tl and not br then out = mix(k, "#fff2c8", .55) end
    else
      local h = hash(x, y, 9)
      if h > .965 and fig(x + 1, y) then out = mix(k, "#fff2c8", .3); c:put(x + 1, y, mix(k, "#fff2c8", .3)) elseif h < .03 then out = mix(k, "#2b1c26", .22) end
    end
  end
  c:put(x, y, out)
end end
-- re-ink the path outline where it faces outside the figure
for y = 1, H - 2 do for x = 1, W - 2 do
  if C[y * W + x] == 3 and cur[y * W + x] == "#74462a" and (cl(x - 1, y) <= 2 or cl(x + 1, y) <= 2 or cl(x, y - 1) <= 2 or cl(x, y + 1) <= 2) then c:put(x, y, "#4a2c1a") end
end end

-- 4. props v2 (finish4 redo): fewer, ~1.6x bigger, clear silhouettes, 1px ink, glow rims, 3-tone shading.
-- Every prop sits inside its cavern blob (base on cavern floor, nothing over tunnels) so map-world-regions.png stays valid.
local function groundShadow(x, y, rx, ry)
  for yy = y - ry, y + ry do for xx = x - rx, x + rx do
    if ((xx - x) / rx) ^ 2 + ((yy - y) / ry) ^ 2 <= 1 and fig(xx, yy) then
      local g = c:get(xx, yy); if g then c:put(xx, yy, mix(g, "#1c1210", .45)) end
    end
  end end
end
local function T3(a, b, e) return { hi = a, base = b, shade = e } end
local function ed(m, x, y, dx, dy, lim)
  for k = 1, lim do if not m:has(x + dx * k, y + dy * k) then return k end end
  return lim + 1
end
-- glow: 1px solid ring + 1px dithered ring outside the ink line
local function glowRing(m, g1, g2)
  local a = m:grow(1); local b = a:grow(1); local e = b:grow(1)
  b:each(function(x, y) if not a:has(x, y) then c:put(x, y, g1) end end)
  if g2 then e:each(function(x, y) if not b:has(x, y) and (x + y) % 2 == 0 then local o = c:get(x, y); c:put(x, y, g2) end end) end
end
-- 3-tone fill lit from top-left; fn(x,y,tl,br) may return a colour override
local function draw3(m, R, o)
  o = o or {}
  if o.glow then glowRing(m, o.glow, o.glow2) end
  if o.ink ~= false then local g = m:grow(1); g:each(function(x, y) if not m:has(x, y) then c:put(x, y, INK) end end) end
  local sw, hw = o.sw or 3, o.hw or 2
  m:each(function(x, y)
    local tl = min(ed(m, x, y, -1, -1, hw), ed(m, x, y, -1, 0, hw), ed(m, x, y, 0, -1, hw))
    local br = min(ed(m, x, y, 1, 1, sw), ed(m, x, y, 1, 0, sw), ed(m, x, y, 0, 1, sw))
    local col
    if o.fn then col = o.fn(x, y, tl, br) end
    if not col then
      if br <= sw and br <= tl then col = R.shade elseif tl <= hw then col = R.hi else col = R.base end
    end
    c:put(x, y, col)
  end)
end
local function disc(cx, cy, rx, ry) return GX.disc(HP.mask(), floor(cx), floor(cy), floor(rx), floor(ry or rx)) end

local CAPR = T3("#ff9a84", "#d8404a", "#8a2442")
local CAPB = T3("#d4fff2", "#52d6c4", "#2a7898")
local STEM = T3("#fff6e0", "#e6d0a8", "#a4866a")
local LEAF = { T3("#c8f080", "#5cb450", "#2a6a44"), T3("#d8f490", "#7ac458", "#3a7a40") }
local PINKL = T3("#ffe4f0", "#f094c0", "#a84a80")
local DKL = T3("#8ad070", "#3a8a4c", "#1e5038")
local BARK = T3("#c08a58", "#8a5634", "#54342a")
local ICE3 = T3("#f4ffff", "#8ad4f0", "#3a7cc0")
local LAV3 = T3("#f2e6ff", "#b294f0", "#6046ac")
local GREY3 = T3("#e4dcea", "#a8a0bc", "#625e86")
local TAN3 = T3("#fff0c4", "#d8a868", "#94643e")
local BRN3 = T3("#e8b880", "#a8703c", "#64402c")
local VOL3 = T3("#b47a70", "#74464a", "#3e2434")
local LAVA3 = T3("#fff0a0", "#f8a030", "#c8441f")
local CACT = T3("#c8f080", "#5cb450", "#2a6a44")

local function mushroom(x, y, s, glowCap, seed)
  local R = glowCap and CAPB or CAPR
  local rx, ry, sh = floor(15 * s), floor(10 * s), floor(13 * s)
  if not glowCap then groundShadow(x + 3, y, rx, 3) end
  local cy = y - sh
  local cap = disc(x, cy, rx, ry); cap:clip(HP.rect(x - rx - 1, cy - ry - 1, x + rx + 1, cy + 3))
  local st = HP.rect(x - 3, cy + 2, x + 3, y)
  for xx = x - 5, x + 5 do st:set(xx, y); if abs(xx - x) <= 4 then st:set(xx, y - 1) end end
  local both = cap:copy():add(st)
  if glowCap then glowRing(both, "#9af0e0", "#3f8fb0") end
  draw3(st, STEM, { sw = 2, hw = 1 })
  draw3(cap, R, { sw = 3, hw = 2, fn = function(xx, yy, tl, br) if yy >= cy + 2 then return R.shade end end })
  for xx = x - rx + 2, x + rx - 2 do c:put(xx, cy + 3, INK) end   -- gill line under the rim
  local spots = { { -7, -5, 3 }, { 2, -7, 2 }, { 7, -2, 2 }, { -2, -2, 2 } }
  for _, p in ipairs(spots) do
    local sx, sy = x + floor(p[1] * s), cy + floor(p[2] * s)
    local m = disc(sx, sy, p[3], p[3] - 1)
    m:each(function(xx, yy) if cap:has(xx, yy) and not cap:has(xx, yy + 2) == false then c:put(xx, yy, glowCap and "#f4fff8" or "#fff0d8") end end)
  end
  c:put(x - rx + 4, cy - ry + 4, "#fffaf0"); c:put(x - rx + 5, cy - ry + 3, "#fffaf0")
end

local function crystals(x, y, h, R, glow, seed)
  groundShadow(x + 2, y, 13, 3)
  local shards = { { -9, .62, 4, -4 }, { 9, .55, 4, 4 }, { -3, .42, 3, -2 }, { 2, 1, 6, 0 }, { 7, .38, 3, 2 } }
  local union, ms = HP.mask(), {}
  for i, p in ipairs(shards) do
    local hh, hw, cx, ln = floor(h * p[2]), p[3], x + p[1], p[4]
    local m = c:poly{ { cx - hw, y }, { cx - hw + ln, y - hh + hw + 2 }, { cx + ln, y - hh }, { cx + hw + ln, y - hh + hw + 2 }, { cx + hw, y } }
    ms[i] = { m, cx, ln, hh }
    union:add(m)
  end
  glowRing(union, glow, mix(glow, "#2c1c12", .5))
  for _, s in ipairs(ms) do
    local m, cx, ln, hh = s[1], s[2], s[3], s[4]
    draw3(m, R, { fn = function(xx, yy, tl, br)
      local t = (y - yy) / max(1, hh)
      local mid = cx + ln * t
      if tl <= 1 and xx < mid then return R.hi end
      if xx < mid - .5 then return R.base end
      if xx <= mid + .5 then return mix(R.base, R.hi, .5) end
      return R.shade
    end })
    c:put(floor(cx + ln * .8) - 1, y - hh + 3, "#ffffee")
  end
  c:sparkle(x - 13, y - h + 6); c:sparkle(x + 13, y - floor(h * .6))
end

local function stalagmites(x, y, h, R, seed)
  groundShadow(x + 3, y, 15, 3)
  for _, p in ipairs{ { -9, .6, 6 }, { 9, .48, 5 }, { 0, 1, 8 } } do
    local hh, hw, cx = floor(h * p[2]), p[3], x + p[1]
    local pts = { { cx - hw, y } }
    for i = 1, 4 do local t = i / 5; pts[#pts + 1] = { cx - hw * (1 - t) + (hash(i, seed, p[1] + 9) - .5) * 1.5, y - hh * t } end
    pts[#pts + 1] = { cx, y - hh }
    for i = 4, 1, -1 do local t = i / 5; pts[#pts + 1] = { cx + hw * (1 - t) + (hash(i, seed, p[1] + 19) - .5) * 1.5, y - hh * t } end
    pts[#pts + 1] = { cx + hw, y }
    local m = c:poly(pts)
    draw3(m, R, { sw = 3, hw = 2, fn = function(xx, yy, tl, br)
      if (y - yy) % 7 == 3 and br > 1 and tl > 1 then return R.shade end   -- growth rings
      if xx > cx + 1 and br <= 3 then return R.shade end
    end })
  end
end

local function tree(x, y, r, R, seed, blossom)
  groundShadow(x + 3, y + 3, floor(r * 1.2), 4)
  local tm = HP.rect(x - 2, y - floor(r * .6), x + 2, y + 2)
  tm:set(x - 3, y + 2); tm:set(x + 3, y + 2)
  draw3(tm, BARK, { sw = 2, hw = 1 })
  local cy = y - floor(r * 1.1)
  local m = HP.mask()
  for _, k in ipairs{ { 0, -r * .3, r * .8 }, { -r * .62, r * .12, r * .62 }, { r * .62, r * .12, r * .6 }, { -r * .22, -r * .82, r * .55 }, { r * .38, -r * .62, r * .5 } } do
    m:add(disc(x + k[1], cy + k[2], k[3] + 1, k[3]))
  end
  draw3(m, R, { sw = 4, hw = 2, fn = function(xx, yy, tl, br)
    if br > 4 and tl > 2 and GX.vn(xx, yy, 4, seed) > .66 then return R.hi end   -- leaf clumps catch light
    if br > 4 and tl > 2 and GX.vn(xx, yy, 4, seed + 5) < .25 then return R.shade end
  end })
  local dot = blossom and "#fff4d0" or "#e8506a"
  for i = 1, 4 do
    local fx, fy = x - r + 3 + floor(hash(i, seed, 2) * (r * 2 - 6)), cy - floor(r * .5) + floor(hash(i, seed, 3) * r)
    if m:has(fx, fy) and m:has(fx + 1, fy + 1) then c:put(fx, fy, dot); c:put(fx + 1, fy, dot); c:put(fx, fy + 1, dot); c:put(fx + 1, fy + 1, mix(dot, INK, .3)) end
  end
end

local function pine(x, y, h, seed)
  groundShadow(x + 3, y + 1, floor(h * .4), 4)
  draw3(HP.rect(x - 2, y - 4, x + 2, y + 1), BARK, { sw = 2, hw = 1 })
  local m = HP.mask()
  for i = 0, 2 do
    local ay = y - h + i * floor(h * .26)
    local hw = floor(h * .2) + i * floor(h * .1)
    m:add(c:poly{ { x, ay }, { x + hw, ay + floor(h * .4) }, { x - hw, ay + floor(h * .4) } })
  end
  draw3(m, DKL, { sw = 3, hw = 2, fn = function(xx, yy, tl, br) if xx > x + 1 and br > 1 then return DKL.shade end end })
  c:put(x, y - h, "#e8f8b0")
end

local function peak(x, y, w, h, R, snow, seed)
  groundShadow(x + 4, y + 1, w, 4)
  local pts = { { x - w, y } }
  local nn = 9
  for i = 1, nn - 1 do
    local t = i / nn
    local hp = t < .45 and (t / .45) or ((1 - t) / .55)
    pts[#pts + 1] = { x - w + 2 * w * t, y - h * hp + (hash(i, seed, 1) - .5) * 3 * min(1, hp * 3) }
  end
  pts[#pts + 1] = { x + w, y }
  local m = c:poly(pts)
  local px_ = x - w + 2 * w * .45
  draw3(m, R, { fn = function(xx, yy, tl, br)
    if snow and yy < y - h * .6 + abs(xx - px_) * .5 + (hash(xx, 3, seed) - .5) * 2 then return (xx < px_) and "#f4fbff" or "#b8cce4" end
    if xx > px_ + (y - yy) * .15 then return R.shade end
    if tl <= 2 then return R.hi end
    return R.base
  end })
end

local function volcano(x, y, w, h, seed)
  groundShadow(x + 4, y + 1, w, 4)
  local m = c:poly{ { x - w, y }, { x - 6, y - h }, { x + 6, y - h }, { x + w, y } }
  local lava = HP.mask()
  for yy = y - h, y - floor(h * .25) do
    local wob = floor(sin(yy * .55 + seed) * 1.5)
    for xx = x - 1 + wob, x + 1 + wob do if m:has(xx, yy) then lava:set(xx, yy) end end
  end
  glowRing(HP.rect(x - 6, y - h - 2, x + 6, y - h + 1), "#f8a030", "#c8441f")
  draw3(m, VOL3, { fn = function(xx, yy, tl, br) if xx > x + (y - yy) * .1 + 1 then return VOL3.shade end end })
  lava:each(function(xx, yy) c:put(xx, yy, ((xx + yy) % 3 == 0) and LAVA3.hi or LAVA3.base) end)
  for xx = x - 5, x + 5 do c:put(xx, y - h, LAVA3.base); c:put(xx, y - h - 1, (abs(xx - x) < 4) and LAVA3.hi or LAVA3.base) end
  for _, p in ipairs{ { 1, -5, 3 }, { 4, -10, 3 }, { -1, -15, 2 } } do
    draw3(disc(x + p[1], y - h + p[2] - 1, p[3]), T3("#fff0e0", "#d0c4dc", "#8a82a8"), { sw = 1, hw = 1 })
  end
end

local function cactus(x, y, h, seed)
  groundShadow(x + 3, y + 1, 9, 3)
  local m = HP.mask()
  for yy = y - h, y do for xx = x - 3, x + 3 do if not (yy == y - h and abs(xx - x) == 3) then m:set(xx, yy) end end end
  for _, a in ipairs{ { -1, h * .55, 8 }, { 1, h * .38, 6 } } do
    local ay = y - floor(a[2])
    for xx = min(x, x + a[1] * 8), max(x, x + a[1] * 8) do for yy = ay - 2, ay + 1 do m:set(xx, yy) end end
    for yy = ay - a[3], ay + 1 do for xx = x + a[1] * 8 - 2, x + a[1] * 8 + 2 do m:set(xx, yy) end end
  end
  draw3(m, CACT, { sw = 2, hw = 1, fn = function(xx, yy, tl, br) if br > 2 and tl > 1 and xx % 3 == 0 then return CACT.shade end end })
  for _, p in ipairs{ { -1, -1 }, { 0, -2 }, { 1, -1 }, { 0, -1 } } do c:put(x + p[1], y - h + p[2], "#f08aa0") end
  c:put(x, y - h - 2, "#ffd0dc")
end

local function boulder(x, y, rx, ry, R, seed)
  groundShadow(x + 3, y + 1, rx + 2, 3)
  local m = disc(x, y - ry + 1, rx, ry); m:clip(HP.rect(x - rx - 1, y - ry * 2, x + rx + 1, y))
  draw3(m, R, { sw = 3, hw = 2, fn = function(xx, yy, tl, br) if br > 3 and tl > 2 and (xx - x) * .5 + (yy - (y - ry)) > 2 and hash(xx, yy, seed) < .04 then return R.shade end end })
  c:put(x - floor(rx * .4), y - ry * 2 + 3, "#fffaf0")
end

-- placement: a prop needs its footprint on cavern floor (class 5); its upper part may poke over halo/bg; never over a tunnel.
local clearance = bfs(function(i) return C[i] ~= 5 end)
local occ = {}
local function fits(x, y, hw, h)
  if (clearance[y * W + x] or 14) < 3 then return false end
  for yy = y - h, y + 2, 2 do for xx = x - hw, x + hw, 2 do
    if xx < 0 or yy < 20 or xx >= W or yy >= H - 22 then return false end
    local i = yy * W + xx
    if occ[i] then return false end
    local inner = abs(xx - x) <= hw * .7
    if inner and yy > y - h * .6 and C[i] == 3 then return false end
    if inner and yy > y - h * .4 and C[i] ~= 5 then return false end
  end end
  return true
end
local FAM = {
  ["#4f9a45"] = "green", ["#7ab55c"] = "green", ["#6a9a3a"] = "green", ["#a4b86a"] = "green", ["#bdd292"] = "green",
  ["#2f6a3a"] = "dark", ["#f6b8cf"] = "pink", ["#e0501f"] = "fire", ["#a8241f"] = "fire", ["#d6322b"] = "fire",
  ["#d9a660"] = "tan", ["#f5cf6a"] = "tan", ["#c8ecdc"] = "ice", ["#7a4a1f"] = "brown", ["#5e2f1e"] = "brown",
}
-- kinds per family: {name, half-width, height}
local KIND = {
  green = { { "tree", 17, 34 }, { "mushR", 16, 26 }, { "tree", 17, 34 }, { "mushB", 16, 26 }, { "boulder", 14, 16 } },
  dark  = { { "pine", 15, 42 }, { "mushB", 16, 26 }, { "pine", 15, 42 } },
  pink  = { { "crysL", 16, 38 }, { "treeP", 17, 34 }, { "mushB", 16, 26 } },
  fire  = { { "volcano", 21, 38 }, { "stalV", 17, 34 }, { "volcano", 21, 38 } },
  tan   = { { "cactus", 11, 30 }, { "peakT", 19, 32 }, { "stalT", 17, 32 } },
  ice   = { { "crysI", 16, 40 }, { "peakS", 19, 34 } },
  brown = { { "mushR", 16, 26 }, { "stalB", 17, 34 }, { "peakB", 19, 32 } },
}
local want = { green = 11, dark = 6, pink = 5, fire = 6, tan = 6, ice = 4, brown = 5 }
local list = {}
for t = 1, 30000 do
  local x, y = 24 + floor(hash(t, 1, 77) * (W - 48)), 40 + floor(hash(t, 2, 77) * (H - 70))
  local fam = FAM[cur[y * W + x]]
  if fam and C[y * W + x] == 5 then list[#list + 1] = { x, y, fam, t } end
end
local got, placed = {}, {}
for _, p in ipairs(list) do
  local x, y, fam, t = p[1], p[2], p[3], p[4]
  if (got[fam] or 0) < want[fam] then
    local ks = KIND[fam]
    local k = ks[1 + (got[fam] or 0) % #ks]
    if fits(x, y, k[2], k[3]) then
      for yy = y - k[3] - 1, y + 3 do for xx = x - k[2] - 1, x + k[2] + 1 do if xx >= 0 and xx < W then occ[yy * W + xx] = true end end end
      got[fam] = (got[fam] or 0) + 1
      placed[#placed + 1] = { x, y, k[1], t }
    end
  end
end
table.sort(placed, function(a, b) return a[2] < b[2] end)
for _, p in ipairs(placed) do
  local x, y, kind, t = p[1], p[2], p[3], p[4]
  local sd = t % 97 + 3
  if kind == "tree" then tree(x, y, 15, LEAF[1 + t % 2], sd)
  elseif kind == "treeP" then tree(x, y, 15, PINKL, sd, true)
  elseif kind == "mushR" then mushroom(x, y, 1, false, sd)
  elseif kind == "mushB" then mushroom(x, y, 1, true, sd)
  elseif kind == "boulder" then boulder(x, y, 13, 8, GREY3, sd)
  elseif kind == "pine" then pine(x, y, 40, sd)
  elseif kind == "crysL" then crystals(x, y, 36, LAV3, "#c3b2ea", sd)
  elseif kind == "crysI" then crystals(x, y, 38, ICE3, "#a9e6fa", sd)
  elseif kind == "volcano" then volcano(x, y, 20, 34, sd)
  elseif kind == "stalV" then stalagmites(x, y, 32, VOL3, sd)
  elseif kind == "stalT" then stalagmites(x, y, 30, TAN3, sd)
  elseif kind == "stalB" then stalagmites(x, y, 32, BRN3, sd)
  elseif kind == "cactus" then cactus(x, y, 28, sd)
  elseif kind == "peakT" then peak(x, y, 18, 30, TAN3, false, sd)
  elseif kind == "peakS" then peak(x, y, 18, 32, GREY3, true, sd)
  elseif kind == "peakB" then peak(x, y, 18, 30, BRN3, false, sd)
  end
end

-- 5. frame: big ceiling stalactites and floor stalagmites in the open rock (never over caverns, halos or tunnels)
local FR = T3("#8a6650", "#56392a", "#33221a")
local function frameSpike(cx, y0, len, hw, down, seed)
  local pts = { { cx - hw, y0 } }
  for i = 1, 4 do local t = i / 5; pts[#pts + 1] = { cx - hw * (1 - t) + (hash(i, seed, 1) - .5) * 1.2, y0 + (down and 1 or -1) * len * t } end
  pts[#pts + 1] = { cx, y0 + (down and 1 or -1) * len }
  for i = 4, 1, -1 do local t = i / 5; pts[#pts + 1] = { cx + hw * (1 - t) + (hash(i, seed, 2) - .5) * 1.2, y0 + (down and 1 or -1) * len * t } end
  pts[#pts + 1] = { cx + hw, y0 }
  local m = c:poly(pts)
  local ok = true
  m:grow(2):each(function(x, y) if x >= 0 and y >= 20 and x < W and y <= 335 and C[y * W + x] ~= 1 then ok = false end end)
  if not ok then return end
  draw3(m, FR, { sw = 3, hw = 2, fn = function(xx, yy, tl, br)
    if xx > cx then return FR.shade end
    if xx >= cx - 1 and tl > 1 then return FR.base end
  end })
  local tip = down and (y0 + len) or (y0 - len)
  c:put(cx, tip + (down and -1 or 1), FR.hi)
  if down and hash(cx, 5, seed) > .55 then c:put(cx, tip + 2, "#9ad8ec"); c:put(cx, tip + 3, "#4a9ac8") end   -- drip
end
do
  local cx = 6
  local i = 0
  while cx < W - 6 do
    i = i + 1
    local hw = 6 + floor(hash(i, 1, 41) * 6)
    frameSpike(cx + hw, -1, 14 + floor(hash(i, 2, 41) * 20), hw, true, i)
    cx = cx + hw * 2 + 3 + floor(hash(i, 3, 41) * 14)
  end
  cx = 4; i = 0
  while cx < W - 6 do
    i = i + 1
    local hw = 5 + floor(hash(i, 4, 41) * 6)
    frameSpike(cx + hw, H, 10 + floor(hash(i, 5, 41) * 16), hw, false, i + 50)
    cx = cx + hw * 2 + 4 + floor(hash(i, 6, 41) * 16)
  end
end
c:save{ png = (app.params.out or (d .. "/out/")) .. "map-world.png", scale = 1 }

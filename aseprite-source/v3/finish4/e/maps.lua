-- finish4 map-world 640x360: cleaned blobs (mode filter), ink rim + lit/shaded edge, glow halos, big hand-placed props.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local INK = "#2b1c26"
local SRC = d .. "/../../../../game/assets/img/scenes/map-world.png"
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

-- 4. props
local function groundShadow(x, y, rx, ry, col)
  for yy = y - ry, y + ry do for xx = x - rx, x + rx do
    if ((xx - x) / rx) ^ 2 + ((yy - y) / ry) ^ 2 <= 1 and fig(xx, yy) then
      local g = c:get(xx, yy); if g then c:put(xx, yy, mix(g, "#1c1210", .4)) end
    end
  end end
end
local function E(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), floor(rx), floor(ry or rx)) end
local function lit(m, Rm, seed, o)
  o = o or {}; o.seed = seed; o.R = o.R or 6
  GX.lit(c, m, GX.ramp6(Rm), o)
end
local function rp(a, b, cc, e) return { hi = a, base = b, shade = cc, deep = e } end
local GRN = { rp("#d2f08a", "#78c458", "#3a8a4c", "#1e5a40"), rp("#c8f07a", "#5cb450", "#2f7c48", "#1a4c3c") }
local DKG = rp("#7cc060", "#3a8a4c", "#25603f", "#143c36")
local PNK = rp("#ffe0ec", "#f49ac0", "#c8548a", "#7e2e5e")
local TRK = rp("#d4985c", "#9c6438", "#6e4230", "#452a2c")
local ROCKR = rp("#e0d8e0", "#a8a4bc", "#76789a", "#4c4a6e")
local TANR = rp("#fff0c0", "#e0b070", "#b07c48", "#704a3c")
local LAV = rp("#e8d6ff", "#a98ae0", "#6c52b0", "#3a2e78")
local ICE = rp("#f4ffff", "#9ad8ec", "#4a9ac8", "#2a5a8c")
local LAVA = rp("#ffe090", "#f08a24", "#c8441f", "#6e2030")
local VOLC = rp("#a8706a", "#74464a", "#4e2e3a", "#2e1c2a")
local CAP = rp("#ff9a8a", "#e0504a", "#a8324a", "#6c2240")
local function tree(x, y, r, Rm, seed, blossom)
  groundShadow(x + 2, y + floor(r * .8), floor(r * 1.2), floor(r * .45))
  local tm = HP.mask(); for yy = y, y + floor(r * .8) do for xx = x - 1, x + 1 do tm:set(xx, yy) end end
  lit(tm, TRK, seed, { R = 2, tex = .2, sc = 3 })
  local cl_ = { { x, y - r * .35, r }, { x - r * .75, y + r * .1, r * .72 }, { x + r * .75, y + r * .1, r * .7 }, { x - r * .25, y - r * .95, r * .62 }, { x + r * .45, y - r * .7, r * .55 } }
  table.sort(cl_, function(a, b) return a[2] < b[2] end)
  for i, k in ipairs(cl_) do
    local f = (i - 1) / (#cl_ - 1)
    local m = E(HP.mask(), k[1], k[2], k[3] + 1, k[3])
    m = GX.rough(m, seed + i, 1)
    local dim = .4 * (1 - f)
    local Rd = { hi = mix(Rm.hi, Rm.shade, dim * .5), base = mix(Rm.base, Rm.shade, dim), shade = mix(Rm.shade, Rm.deep, dim), deep = Rm.deep }
    lit(m, Rd, seed + i, { R = k[3] + 2, tex = .5, sc = 3, rimlight = true })
    if f > .3 then c:px(floor(k[1] - k[3] * .4), floor(k[2] - k[3] * .4), Rm.hi); c:px(floor(k[1] - k[3] * .4) + 1, floor(k[2] - k[3] * .4), Rm.hi) end
  end
  if blossom then for i = 1, 4 do c:px(x - r + floor(hash(i, seed, 2) * r * 2), y - r * .5 + floor(hash(i, seed, 3) * r), "#fff4d0") end
  else for i = 1, 3 do c:px(x - r * .6 + floor(hash(i, seed, 2) * r * 1.2), y - r * .4 + floor(hash(i, seed, 3) * r * .8), "#e8506a") end end
end
local function pine(x, y, h, seed)
  groundShadow(x + 2, y, floor(h * .35), 3)
  local m = HP.mask()
  for i = 0, 2 do
    local ay = y - h + i * floor(h * .27)
    local hw = floor(h * .2) + i * floor(h * .11)
    m:add(c:poly{ { x, ay }, { x + hw, ay + floor(h * .4) }, { x - hw, ay + floor(h * .4) } })
  end
  for yy = y - 3, y do for xx = x - 1, x + 1 do m:set(xx, yy) end end
  lit(m, DKG, seed, { R = 8, tex = .4, sc = 3, rimlight = true, fn = function(xx, yy) return ((yy + 99) % 5 == 0) and -.12 or 0 end })
end
local function peak(x, y, w, h, Rm, snow, seed)
  groundShadow(x + 4, y, w, 3)
  local pts = { { x - w, y } }
  local nn = 8
  for i = 1, nn - 1 do
    local t = i / nn
    local hp = t < .45 and (t / .45) or ((1 - t) / .55)
    pts[#pts + 1] = { x - w + 2 * w * t, y - h * hp + (hash(i, seed, 1) - .5) * 3 * min(1, hp * 3) }
  end
  pts[#pts + 1] = { x + w, y }
  local m = c:poly(pts)
  local px_ = x - w + 2 * w * .45
  lit(m, Rm, seed, { R = max(w, 8), tex = .35, sc = 3, rimlight = true, fn = function(xx, yy) return -(xx - px_) / w * .5 end })
  if snow then
    m:each(function(xx, yy) if yy < y - h * .62 + abs(xx - px_) * .5 + (hash(xx, 3, seed) - .5) * 3 then c:px(xx, yy, (xx < px_) and "#f4fbff" or "#c0d4ec") end end)
  end
end
local function volcano(x, y, w, h, seed)
  groundShadow(x + 4, y, w, 3)
  local m = c:poly{ { x - w, y }, { x - 5, y - h }, { x + 5, y - h }, { x + w, y } }
  lit(m, VOLC, seed, { R = max(w, 8), tex = .4, sc = 3, rimlight = true, fn = function(xx, yy) return -(xx - x) / w * .5 end })
  c:fillMask(HP.rect(x - 4, y - h, x + 4, y - h + 1), LAVA.base); c:fillMask(HP.rect(x - 3, y - h - 1, x + 3, y - h), LAVA.hi)
  for k = 0, 2 do c:px(x - 2 + k * 2, y - h + 2 + k, LAVA.base); c:px(x - 2 + k * 2, y - h + 3 + k, LAVA.shade) end
  for k = 1, 5 do c:px(x - 1, y - h + 2 + k * 2, LAVA.base); c:px(x, y - h + 3 + k * 2, LAVA.shade) end
  for _, p in ipairs{ { 0, -3, 3 }, { 3, -7, 2 }, { -2, -11, 2 } } do local sm = E(HP.mask(), x + p[1], y - h + p[2], p[3]); lit(sm, rp("#fff0e0", "#d8cce0", "#a8a0c0", "#6e6890"), seed + p[3], { R = 3, ink = false, tex = .2 }) end
end
local function crystals(x, y, h, Rm, seed)
  groundShadow(x + 2, y, 8, 3)
  for i, p in ipairs{ { -5, .62, 3 }, { 4, .8, 3 }, { 0, 1, 4 } } do
    local hh = floor(h * p[2])
    local m = c:poly{ { x + p[1] - p[3], y }, { x + p[1] - p[3], y - hh + 4 }, { x + p[1], y - hh }, { x + p[1] + p[3], y - hh + 4 }, { x + p[1] + p[3], y } }
    lit(m, Rm, seed + i, { R = p[3] + 3, tex = .1, amb = .3, rimlight = true, fn = function(xx, yy) return -(xx - x - p[1]) / 6 end })
  end
  c:sparkle(x - 8, y - h + 4)
end
local function mush(x, y, r, seed)
  groundShadow(x + 2, y, r, 3)
  local st = HP.rect(x - 2, y - r, x + 2, y)
  lit(st, rp("#fff8e4", "#f0dcb4", "#c9b08a", "#8a6a50"), seed, { R = 3, tex = .1 })
  local cap = E(HP.mask(), x, y - r, r + 3, floor(r * .75)); cap:clip(HP.rect(x - r - 5, y - r * 3, x + r + 5, y - r + 2))
  lit(cap, CAP, seed + 1, { R = r + 3, tex = .2, rimlight = true })
  for _, p in ipairs{ { -4, -3 }, { 2, -5 }, { 5, -1 }, { -1, -1 } } do c:px(x + p[1], y - r + p[2], "#fff4d0"); c:px(x + p[1] + 1, y - r + p[2], "#fff4d0"); c:px(x + p[1], y - r + p[2] + 1, "#f0dcb4") end
end
local function cactus(x, y, h, seed)
  groundShadow(x + 3, y, 7, 3)
  local m = HP.mask()
  for yy = y - h, y do for xx = x - 2, x + 2 do m:set(xx, yy) end end
  for _, a in ipairs{ { -1, h * .55, 6 }, { 1, h * .4, 5 } } do
    local ay = y - floor(a[2])
    for xx = min(x, x + a[1] * 6), max(x, x + a[1] * 6) do for yy = ay - 1, ay + 1 do m:set(xx, yy) end end
    for yy = ay - a[3], ay do for xx = x + a[1] * 6 - 1, x + a[1] * 6 + 1 do m:set(xx, yy) end end
  end
  lit(m, rp("#b8e878", "#5cb450", "#2f7c48", "#1a4c3c"), seed, { R = 4, tex = .2, rimlight = true, fn = function(xx, yy) return ((xx % 3) == 0) and -.1 or 0 end })
  c:px(x, y - h - 1, "#f08aa0"); c:px(x - 1, y - h - 1, "#f08aa0")
end
local function boulder(x, y, rx, ry, Rm, seed)
  groundShadow(x + 3, y + 1, rx + 2, 3)
  local m = E(HP.mask(), x, y - ry + 2, rx, ry); m:clip(HP.rect(x - rx - 2, y - ry * 2, x + rx + 2, y))
  lit(m, Rm, seed, { R = max(rx, 6), tex = .4, sc = 3, rimlight = true })
end

-- candidate placement: blob pixel colour decides the family
local clearance = bfs(function(i) return C[i] ~= 5 end)   -- distance from non-blob (path/halo/bg); also keeps paths clear
local occ = {}
local function free(x, y, r)
  if (clearance[y * W + x] or 14) < 7 then return false end
  local rc = floor(r * .6)
  for dy = -rc, rc, 3 do for dx = -rc, rc, 3 do
    local xx, yy = x + dx, y + dy
    if xx < 0 or yy < 0 or xx >= W or yy >= H or C[yy * W + xx] ~= 5 or occ[yy * W + xx] then return false end
  end end
  return true
end
local FAM = {
  ["#4f9a45"] = "green", ["#7ab55c"] = "green", ["#6a9a3a"] = "green", ["#a4b86a"] = "green", ["#bdd292"] = "green",
  ["#2f6a3a"] = "dark", ["#f6b8cf"] = "pink", ["#e0501f"] = "fire", ["#a8241f"] = "fire", ["#d6322b"] = "fire",
  ["#d9a660"] = "tan", ["#f5cf6a"] = "tan", ["#c8ecdc"] = "ice", ["#7a4a1f"] = "brown", ["#5e2f1e"] = "brown",
}
local placed = {}
local list = {}
for t = 1, 24000 do
  local x, y = 20 + floor(hash(t, 1, 77) * (W - 40)), 24 + floor(hash(t, 2, 77) * (H - 48))
  local fam = FAM[cur[y * W + x]]
  if fam and C[y * W + x] == 5 then list[#list + 1] = { x, y, fam, t } end
end
local want = { green = 16, dark = 9, pink = 8, fire = 8, tan = 8, ice = 5, brown = 7 }
local got = {}
for _, p in ipairs(list) do
  local x, y, fam, t = p[1], p[2], p[3], p[4]
  if (got[fam] or 0) < want[fam] then
    local r = (fam == "dark" or fam == "fire") and 13 or 12
    r = r + floor(hash(t, 3, 5) * 3)
    if free(x, y, r) then
      for yy = y - r - 4, y + r do for xx = x - r - 2, x + r + 2 do occ[yy * W + xx] = true end end
      got[fam] = (got[fam] or 0) + 1
      placed[#placed + 1] = { x, y, fam, r, t }
    end
  end
end
table.sort(placed, function(a, b) return a[2] < b[2] end)
for _, p in ipairs(placed) do
  local x, y, fam, r, t = p[1], p[2] + 4, p[3], p[4], p[5]
  local sd = t % 97 + 3
  if fam == "green" then
    local k = t % 6
    if k == 0 then mush(x, y, 9, sd) elseif k == 1 then boulder(x, y, 10, 7, ROCKR, sd) else tree(x, y - 5, 11 + t % 3, GRN[1 + t % 2], sd) end
  elseif fam == "dark" then
    if t % 3 == 0 then tree(x, y - 5, 11, GRN[2], sd) else pine(x, y, 32 + t % 6, sd) end
  elseif fam == "pink" then
    if t % 2 == 0 then tree(x, y - 5, 11, PNK, sd, true) else crystals(x, y, 28, LAV, sd) end
  elseif fam == "fire" then
    if t % 3 == 0 then boulder(x, y, 11, 8, VOLC, sd) else volcano(x, y, 19 + t % 3, 30 + t % 5, sd) end
  elseif fam == "tan" then
    local k = t % 3
    if k == 0 then cactus(x, y, 22 + t % 4, sd) elseif k == 1 then peak(x, y, 16, 26, TANR, false, sd) else boulder(x, y, 11, 8, TANR, sd) end
  elseif fam == "ice" then
    if t % 2 == 0 then crystals(x, y, 30, ICE, sd) else peak(x, y, 16, 28, ROCKR, true, sd) end
  elseif fam == "brown" then
    if t % 2 == 0 then mush(x, y, 11, sd) else peak(x, y, 17, 28, rp("#e0b078", "#a8703c", "#6e4230", "#452a2c"), false, sd) end
  end
end
c:save{ png = d .. "/out/map-world.png", scale = 1 }

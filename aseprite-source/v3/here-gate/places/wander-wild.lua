-- wander-wild: Hearth Pop v3 wander banner, 480x64 native. A darker tangled wild off the trail:
-- big roots, thorn brambles, shadowed trunks under a leaf roof. Centre third kept calm (a hushed gap).
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local K = dofile(ROOT .. "here-gate/places/_wander-kit.lua")
local OUT = app.params.out or (ROOT .. "here-gate/places/")
local NAME = "wander-wild"
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min
local hash = K.hash
local W, H = 480, 64
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local S = K.new(W, H)

local INK = "#2b1c26"
local ROOF = { "#162418", "#1e3220", "#284228", "#34522e", "#446438", "#587a42" }
local FAR = { "#33403e", "#3e4d48", "#4b5a52", "#5a6a5c" }
local BARK = { "#1c1418", "#2a1f22", "#3a2a2a", "#4e3a34", "#654c40", "#7c604c" }
local ROOT_R = { "#2a1f22", "#3a2a2a", "#4e3a34", "#654c40", "#80634e", "#9a7a5c" }
local MOSS = { "#1d2a1c", "#26371f", "#324626", "#415830", "#55703a", "#6c8a44" }
local MUD = { "#3a2a22", "#4e3828", "#664a32", "#80603e", "#9a7a52" }
local function side(x) return x < 160 or x >= 320 end

-- dusky sky glimpses
S:sky{ { 0, "#3b4a4a" }, { 9, "#4a5c56" }, { 17, "#5c6e60" }, { 25, "#6e7c66" }, { 31, "#83906e" } }

-- ===== real trees: clustered crowns (3-4 tones + lit upper-left edge + ink rim), tapered trunks with roots
local sqrt, cos = math.sqrt, math.cos
local function clusters(cx, cy, w, h, seed, n)
  local cl = {}
  for i = 1, n do
    local a, r = hash(seed, i) * 6.28, sqrt(hash(i, seed)) * 0.62
    local rx = w * (0.2 + hash(seed + i, 7) * 0.13)
    cl[i] = { x = cx + cos(a) * r * w * 0.5, y = cy + sin(a) * r * h * 0.5, rx = rx, ry = rx * (0.7 + hash(i, 3, seed) * 0.22), s = seed * 7 + i }
  end
  -- a lead cluster on top so the crown has a crown
  cl[#cl + 1] = { x = cx - w * 0.08, y = cy - h * 0.3, rx = w * 0.27, ry = w * 0.2, s = seed * 7 + 99 }
  table.sort(cl, function(a, b) return a.y < b.y end)
  return cl
end
-- ramp = { deep, shade, mid, light, litEdge }
local function crown(cl, cx, cy, h, ramp, ink, seed)
  local g = #S.objs + 5000
  local owner = {}
  for ci, k in ipairs(cl) do
    S:obj(ink, ramp[1], g)
    local f = K.lumpy(k.x, k.y, k.rx, k.ry, k.s, 0.26)
    for y = floor(k.y - k.ry * 1.45), floor(k.y + k.ry * 1.45) do
      for x = floor(k.x - k.rx * 1.45), floor(k.x + k.rx * 1.45) do
        local inside, nx, ny = f(x, y)
        if inside and x >= 0 and x < W and y >= 0 and y < H then
          local v = -(nx * 0.62 + ny * 0.78) - max(0, (y - cy) / h) * 1.1 + 0.1
          local hh = hash(floor(x / 2), y, seed)
          if hh > 0.88 then v = v + 0.4 elseif hash(x, floor(y / 2), seed + 3) < 0.09 then v = v - 0.4 end
          local t = v > 0.42 and 4 or (v > -0.08 and 3 or (v > -0.62 and 2 or 1))
          S:put(x, y, ramp[t]); owner[y * W + x] = ci
        end
      end
    end
  end
  for i, ci in pairs(owner) do
    local x, y = i % W, i // W
    local up, lf = owner[i - W], (x > 0) and owner[i - 1] or nil
    if (not up or not lf) and (x - cx) + (y - cy) * 1.3 < h * 0.25 and S.col[i] ~= ramp[1] then
      S.col[i] = ramp[5]                                   -- lit outer edge, upper-left
    elseif ((up and up < ci) or (lf and lf < ci)) and S.col[i] ~= ramp[1] and (y - cy) < h * 0.2 then
      S.col[i] = ramp[4]                                   -- each front clump catches light on its top
    end
  end
end
local function taper(w0, w1) return function(t) local f = w1 + (w0 - w1) * (1 - t) if t < 0.1 then f = f * (1 + (0.1 - t) * 6) end return f end end
local function trunk2(x, yb, ytop, w0, w1, bend, bark, ink, seed, roots)
  local dy = yb - ytop
  S:tube({ { x, yb }, { x + bend * 0.3, yb - dy * 0.35 }, { x - bend * 0.25, yb - dy * 0.7 }, { x + bend, ytop } }, taper(w0, w1), bark,
    { ol = ink, grain = max(2, floor(w0 / 3)), seed = seed, lx = 0.85, ly = 0.15 })
  for r = 1, (roots or 2) do
    local sd = (r % 2 == 1) and -1 or 1
    local reach = w0 * (0.7 + hash(seed, r + 20) * 0.6)
    S:tube({ { x + sd * w0 * 0.2, yb - 3 }, { x + sd * w0 * 0.55, yb - 1 }, { x + sd * reach, yb }, { x + sd * (reach + 3), yb + 2 } },
      function(t) return max(1, w0 * 0.42 * (1 - t)) end, bark, { ol = ink, lx = 0.6, ly = 0.8, seed = seed + r })
  end
end
local function branch(p, w, bark, ink) S:tube(p, function(t) return max(1, w * (1 - t * 0.7)) end, bark, { ol = ink, lx = 0.7, ly = 0.6 }) end
local function oak(x, yb, hgt, w, leaf, bark, ink, seed)
  local ct = yb - hgt * 0.62
  trunk2(x, yb, ct + 2, max(2, w * 0.14), max(1, w * 0.07), (hash(seed, 1) - 0.5) * 4, bark, ink, seed, 2)
  branch({ { x, ct + hgt * 0.15 }, { x - w * 0.12, ct + hgt * 0.05 }, { x - w * 0.22, ct }, { x - w * 0.3, ct - 2 } }, max(1, w * 0.05), bark, ink)
  crown(clusters(x, ct, w, hgt * 0.62, seed, 4 + floor(w / 12)), x, ct, hgt * 0.62, leaf, ink, seed)
end
local function poplar(x, yb, hgt, w, leaf, bark, ink, seed)
  local ct = yb - hgt * 0.55
  trunk2(x, yb, ct, max(2, w * 0.18), 1, (hash(seed, 1) - 0.5) * 2, bark, ink, seed, 2)
  local cl = {}
  for i = 1, 5 do
    local fy = ct - hgt * 0.42 + (i - 1) * hgt * 0.18
    local rr = w * (0.32 + 0.1 * sin(i * 1.3) + hash(seed, i) * 0.08)
    cl[i] = { x = x + (hash(i, seed) - 0.5) * w * 0.3, y = fy, rx = rr, ry = rr * 1.1, s = seed * 5 + i }
  end
  crown(cl, x, ct - hgt * 0.1, hgt * 0.7, leaf, ink, seed)
end
local function crooked(x, yb, hgt, w, leaf, bark, ink, seed)
  local lean = (hash(seed, 2) > 0.5 and 1 or -1) * w * 0.35
  local ct = yb - hgt * 0.6
  trunk2(x, yb, ct, max(2, w * 0.15), 1, lean, bark, ink, seed, 2)
  branch({ { x + lean * 0.2, ct + hgt * 0.22 }, { x - lean * 0.6, ct + hgt * 0.12 }, { x - lean * 1.2, ct + hgt * 0.06 }, { x - lean * 1.5, ct + hgt * 0.02 } }, max(1, w * 0.05), bark, ink)
  local cl = {
    { x = x + lean, y = ct - hgt * 0.06, rx = w * 0.36, ry = w * 0.26, s = seed + 1 },
    { x = x + lean * 0.4, y = ct + hgt * 0.02, rx = w * 0.26, ry = w * 0.2, s = seed + 2 },
    { x = x - lean * 1.5, y = ct + hgt * 0.02, rx = w * 0.24, ry = w * 0.17, s = seed + 3 },
  }
  table.sort(cl, function(a, b) return a.y < b.y end)
  crown(cl, x, ct, hgt * 0.4, leaf, ink, seed)
end
local function pine(x, yb, hgt, w, leaf, bark, ink, seed)
  S:tube({ { x, yb }, { x, yb - 2 }, { x, yb - hgt * 0.4 }, { x, yb - hgt * 0.7 } }, function(t) return max(1, w * 0.14 * (1 - t * 0.6)) end, bark, { ol = ink, lx = 0.9, ly = 0.1 })
  S:obj(nil); local g = #S.objs + 7000
  local tiers = 3 + floor(hgt / 16)
  local top = yb - hgt
  for k = tiers, 1, -1 do
    S:obj(ink, leaf[1], g)
    local ty = top + (k - 1) * hgt * 0.62 / tiers
    local by = ty + hgt * 0.42 + k * 1.2
    if by > yb - 3 then by = yb - 3 end
    local hw = w * 0.5 * (0.45 + 0.55 * k / tiers)
    for y = floor(ty), floor(by) do
      local f = (y - ty) / max(1, by - ty)
      local half = hw * f + (hash(y, k, seed) - 0.5) * 1.4
      if y >= floor(by) - 1 then half = half - (hash(y, k + 9, seed) > 0.5 and 1 or 0) end
      for xx = floor(x - half), floor(x + half) do
        if (y < floor(by)) or hash(xx, k, seed) > 0.35 then
          local rel = (xx - x) / max(1, half)
          local t = rel < -0.4 and 4 or (rel < 0.1 and 3 or (rel < 0.55 and 2 or 1))
          if y >= by - 2 and t > 1 then t = t - 1 end
          if xx == floor(x - half) and t >= 3 then t = 5 end
          if hash(xx, y, seed + k) > 0.9 and t > 1 then t = t - 1 end
          S:put(xx, y, leaf[t])
        end
      end
    end
  end
end

-- palettes: far trees cool and pale (air), mid trees deeper and greener
local FAR_INK = "#283230"
local FAR_BARK = { "#2e3432", "#3a403c", "#485048", "#585f55", "#6a7062" }
local FL = {
  { "#2a3a33", "#34473c", "#425648", "#536a56", "#6b8068" },  -- broadleaf, blue-green
  { "#30382c", "#3c4733", "#4b573d", "#5e6b4a", "#788561" },  -- olive
  { "#24332f", "#2c3f38", "#384d43", "#475e51", "#5d7563" },  -- pine, cool
}
local MID_BARK = { "#241a1c", "#33262a", "#463530", "#5c473c", "#74594a", "#8a6c56" }
local ML = {
  { "#172617", "#203a20", "#2e5028", "#426a34", "#62884a" },
  { "#1d2a14", "#2c3d1c", "#3e5426", "#566e30", "#7a9044" },
  { "#13241e", "#1c3428", "#284634", "#365c40", "#4e7656" },
}

-- far tree line (whole trees, varied kinds; smaller and paler in the hushed centre)
local KINDS = { oak, pine, poplar, crooked, oak, pine, oak, poplar }
for i = 0, 25 do
  local x = 8 + i * 18.5 + floor(hash(i, 1) * 8)
  local cs = side(x)
  local kind = KINDS[1 + floor(hash(i, 7) * #KINDS)]
  local hgt = cs and (24 + hash(i, 2) * 12) or (17 + hash(i, 2) * 6)
  local w = (kind == pine and 13 or (kind == poplar and 10 or 18)) * (cs and 1 or 0.8) * (0.85 + hash(i, 4) * 0.3)
  local leaf = kind == pine and FL[3] or FL[1 + floor(hash(i, 5) * 2)]
  kind(x, 44 + floor(hash(i, 6) * 2), hgt, w, leaf, FAR_BARK, FAR_INK, 40 + i)
end
-- far undergrowth
S:terrain(function(x) return 37 + 2.5 * sin(x / 19) + 1.5 * sin(x / 7 + 1) + (side(x) and 0 or 2) end,
  { "#1f2e26", "#283c2c", "#324a32", "#3e5a38" }, { ol = "#1a221c", base = 0.4, fall = 0.03,
  tex = function(x, y, d, v) return v + (hash(floor(x / 2), y, 2) - 0.5) * 0.3 end })

-- leaf roof along the top (thin over the centre): overhanging crowns of the big trees
for x = -6, W + 6, 13 do
  local cs = side(x)
  local cy = cs and (1 + hash(x, 4) * 5) or (-5 + hash(x, 4) * 2)
  local rx = cs and (10 + hash(x, 5) * 6) or (6 + hash(x, 5) * 3)
  crown(clusters(x, cy, rx * 2.2, rx * 1.2, x + 40, 3), x, cy, rx * 1.4, ML[1 + floor(hash(x, 8) * 3)], INK, x + 40)
end
-- hanging vines (sides)
S:obj(nil)
for x = 3, W - 3, 5 do
  if side(x) and hash(x, 60) > 0.6 then
    local len = 6 + floor(hash(x, 61) * 14)
    local y0 = 6 + floor(hash(x, 62) * 4)
    for k = 0, len do
      local xx = x + floor(sin(k / 3 + x) * 0.8)
      S:put(xx, y0 + k, k % 4 == 0 and "#557440" or "#203a20")
    end
  end
end

-- mid trees, whole and distinct: an old oak, a leaning crab-apple, a dark pine, a tall poplar
oak(66, 50, 44, 34, ML[1], MID_BARK, INK, 301)
pine(142, 49, 40, 20, ML[3], MID_BARK, INK, 302)
crooked(340, 50, 38, 28, ML[2], MID_BARK, INK, 303)
poplar(418, 50, 46, 16, ML[2], MID_BARK, INK, 304)

-- big shadowed trunks in front: flared bases, roots, tapering into the roof, moss on the shade side
local function bigTrunk(x, w, bend, seed)
  trunk2(x, 62, -4, w, w * 0.55, bend, BARK, INK, seed, 3)
  S:obj(nil)
  for y = 12, 58 do
    local t = (62 - y) / 66
    local cxx = floor(x + bend * t * 0.6)
    local rr = floor(w * 0.5 * (1 - 0.4 * t))
    if hash(y // 3, seed, 31) > 0.45 then S:put(cxx + rr - 1, y, (y % 3 == 0) and "#55703a" or "#324626") end
    if hash(y // 4, seed, 32) > 0.82 then S:put(cxx - rr + 2, y, "#8a6c56") end
  end
end
bigTrunk(20, 16, 4, 1)
bigTrunk(98, 10, -3, 2)
bigTrunk(384, 11, 3, 3)
bigTrunk(452, 18, -4, 4)
-- leafy masses hugging the trunk tops
crown(clusters(30, 6, 48, 18, 71, 5), 30, 6, 18, ML[1], INK, 71)
crown(clusters(458, 5, 52, 18, 72, 5), 458, 5, 18, ML[3], INK, 72)

-- forest floor
local function floorTop(x) return 50 + 1.5 * sin(x / 27 + 2) + sin(x / 9) end
S:terrain(floorTop, MOSS, { ol = INK, base = 0.5, fall = 0.03,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 5)
    if hh > 0.92 then return v + 0.25 elseif hh < 0.08 then return v - 0.25 end
    return v + (hash(floor(x / 3), floor(y / 2), 6) - 0.5) * 0.2
  end })

-- thorn brambles (behind the roots)
local function bramble(x0, y0, x1, y1, up, seed)
  S:bramble({ { x0, y0 }, { x0 + (x1 - x0) * 0.3, y0 - up }, { x0 + (x1 - x0) * 0.7, y1 - up }, { x1, y1 } },
    "#4a2234", "#a07070", seed, { berry = "#c23a3a", berry2 = "#e8584a" })
end
bramble(40, 52, 92, 46, 10, 1)
bramble(52, 56, 130, 50, 12, 2)
bramble(110, 54, 150, 44, 8, 3)
bramble(330, 50, 372, 56, 9, 4)
bramble(350, 55, 430, 48, 13, 5)
bramble(400, 44, 470, 54, 7, 6)
bramble(0, 46, 30, 40, 6, 7)

-- big roots
local function root(p, w0, w1, seed)
  S:tube(p, function(t) return w0 + (w1 - w0) * t end, ROOT_R, { ol = INK, grain = 3, seed = seed, lx = 0.3, ly = 0.9 })
end
root({ { 24, 54 }, { 42, 44 }, { 58, 50 }, { 82, 63 } }, 8, 3, 11)
root({ { 14, 56 }, { 6, 52 }, { 2, 58 }, { -4, 63 } }, 7, 4, 12)
root({ { 30, 58 }, { 48, 56 }, { 60, 60 }, { 70, 65 } }, 5, 2, 13)
root({ { 100, 57 }, { 114, 52 }, { 124, 56 }, { 140, 63 } }, 5, 2, 14)
root({ { 380, 57 }, { 366, 52 }, { 356, 57 }, { 344, 64 } }, 5, 2, 15)
root({ { 446, 54 }, { 428, 43 }, { 410, 50 }, { 392, 63 } }, 9, 3, 16)
root({ { 458, 56 }, { 470, 50 }, { 478, 54 }, { 486, 60 } }, 7, 4, 17)
-- thorns over the roots in front
bramble(56, 60, 104, 57, 9, 8)
bramble(400, 58, 452, 60, 8, 9)

-- muddy trail at the bottom
local function trailTop(x) return 59 + 0.8 * sin(x / 21) + (hash(floor(x / 6), 1) > 0.7 and 1 or 0) end
S:terrain(trailTop, MUD, { ol = INK, base = 0.45, fall = 0,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 9)
    if hh > 0.94 then return v + 0.3 elseif hh < 0.06 then return v - 0.25 end
    return v
  end })
-- ferns / dark grass nibbling the trail
S:obj(nil)
for x = 1, W - 2 do
  if hash(x, 50) > (side(x) and 0.72 or 0.9) then
    local t = floor(trailTop(x))
    local hgt = 2 + floor(hash(x, 51) * 4)
    for k = 0, hgt - 1 do S:put(x + (k > 1 and (hash(x, 53) > 0.5 and 1 or -1) or 0), t + 1 - k, k == hgt - 1 and "#55703a" or "#26371f") end
  end
end

S:edges()
-- a hushed paler gap at the centre, deep shade at the edges (hard steps)
S:tint(150, 18, 330, 48, function(x, y)
  local d = abs(x - 240) / 90 + abs(y - 34) / 16
  if d < 0.6 then return 0.22 elseif d < 1.0 then return 0.11 end
end, "#a8b48a")
S:tint(0, 0, W - 1, H - 1, function(x, y)
  local e = min(x, W - 1 - x)
  if e < 14 then return 0.3 elseif e < 34 then return 0.15 end
end, "#140e18")
S:flush(c)
c:finish{ outline = false }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

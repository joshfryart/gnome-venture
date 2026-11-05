-- here-wonder: Gnome Venture "Hearth Pop" v3 gate view, the Wonder (crystal + stone ring under aurora).
-- 480x270 native, gate frame of mossy rock, VP ~ (240,112). Spots: investigate (crystal), wild (right arch).
local ROOT = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(ROOT .. "/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or (ROOT .. "/v3/here-gate/places/")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-wonder" }
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min

local function hsh(x, y, s)
  local n = sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453
  return n - floor(n)
end
local function bbox(m)
  local x0, y0, x1, y1 = m:bbox()
  return x0 or 0, y0 or 0, x1 or 0, y1 or 0
end
-- shaded fill: R dark->light; light from upper-left; texture noise; 1px dark edge in own tone
local function fill(m, R, o)
  o = o or {}
  local x0, y0, x1, y1 = bbox(m)
  local w, h = max(1, x1 - x0), max(1, y1 - y0)
  m:each(function(x, y)
    local u, t = (x - x0) / w, (y - y0) / h
    local v = (o.base or 0.92) - u * (o.ku or 0.42) - t * (o.kt or 0.32) + (hsh(x, y, o.seed or 1) - 0.5) * (o.noise or 0.18)
    if o.fn then v = v + o.fn(x, y, u, t) end
    local n = #R
    local i = max(1, min(n, floor(v * n) + 1))
    c:put(x, y, R[i])
  end)
  if o.edge ~= false then c:fillMask(m:edge(), o.edge or R[1]) end
  return m
end
local function rowFill(m, fn) m:each(function(x, y) local col = fn(x, y) if col then c:put(x, y, col) end end) end
local function diamond(x, y, r, col, core)
  for dy = -r, r do for dx = -r, r do if abs(dx) + abs(dy) <= r then c:put(x + dx, y + dy, col) end end end
  if core then c:put(x, y, core) end
end
local function shadow(cx, cy, rx, ry, col)
  rowFill(c:ellipse(cx, cy, rx, ry), function() return col or "#183028" end)
end

-- palette
local INK = "#2b1c26"
local CRY = { "#1e2c62", "#2f4c94", "#4675c8", "#6ea6e6", "#a2d4f8", "#d6f0ff" }
local VIO = { "#2e1d5e", "#4c3290", "#6e50bc", "#9878e0", "#c4a8f6" }
local TEAL = { "#173f58", "#25637e", "#3a8ea8", "#5cb8cc", "#98e0e8" }
local STONE = { "#26222f", "#3c364c", "#575068", "#746c88", "#958ea8", "#b4aec4" }
local WARM = { "#2e2228", "#4a3638", "#6a5048", "#8a6c5a", "#a88a72", "#c4a88e" }
local ARCH = { "#262a30", "#3a4048", "#55606a", "#717e86", "#93a0a4" }
local MOSS = { "#24442e", "#33603a", "#4a7d44", "#68a050", "#8cc062" }
local PET = { "#5e1c4a", "#963070", "#c24c8e", "#e070a8", "#f6a2c8" }
local STEM = { "#1f3e2a", "#2e5a34", "#457a40", "#62984a" }
local CAP = { "#14505a", "#1f7478", "#2f9c98", "#4cc4b4", "#8ae8d4" }
local CREAM = { "#6a5a50", "#9a8672", "#c6b294", "#e6d8ba" }
local WOOD = { "#3e2620", "#5e3a2a", "#83563a", "#a8744c", "#c8965e" }
local BRASS = { "#5a3a1c", "#8a6028", "#be8c36", "#e8bc56" }
local GLOW = { "#ffb848", "#ffd878", "#fff0b8" }

---------------------------------------------------------------- sky
local skyRows = { {0,"#140f2e"},{16,"#19133a"},{32,"#1f1846"},{48,"#261d54"},{62,"#2e2462"},{76,"#382a70"},{88,"#44327c"},{98,"#523a88"},{106,"#62428e"} }
for y = 0, 112 do
  local col = skyRows[1][2]
  for _, r in ipairs(skyRows) do if y >= r[1] then col = r[2] end end
  for x = 0, W - 1 do c:put(x, y, col) end
end
-- stars
for y = 0, 80 do for x = 0, W - 1 do
  local r = hsh(x, y, 7)
  if r < 0.006 then c:put(x, y, "#c8c0f0") elseif r < 0.009 then c:put(x, y, "#8e86c8") end
end end
for _, s in ipairs({ {70,20},{186,14},{298,52},{420,46},{352,70},{96,74} }) do
  c:put(s[1], s[2], "#e8e4ff"); c:put(s[1]-1, s[2], "#9a90d4"); c:put(s[1]+1, s[2], "#9a90d4"); c:put(s[1], s[2]-1, "#9a90d4"); c:put(s[1], s[2]+1, "#9a90d4")
end
-- aurora: two curtains
local function aurora(x0, x1, base, amp, f1, len, cols, seed)
  for x = x0, x1 do
    local cy = floor(base + amp * sin(x / f1 + seed) + amp * 0.5 * sin(x / (f1 * 0.43) + seed * 2) + 0.5)
    local L = floor(len * (0.65 + 0.35 * sin(x / 9 + seed)) + hsh(x, 3, seed) * 3)
    -- fade at ends
    local e = min(x - x0, x1 - x) / 30
    if e < 1 then L = floor(L * e) end
    for k = 0, L do
      local y = cy - k
      local f = k / max(1, L)
      local col = f < 0.12 and cols[1] or f < 0.4 and cols[2] or f < 0.72 and cols[3] or cols[4]
      if (x + k) % 7 ~= 0 or f < 0.4 then c:put(x, y, col) end
    end
  end
end
aurora(40, 300, 66, 7, 34, 26, { "#8af0c4", "#46c89c", "#2c8c86", "#2a5876" }, 1)
aurora(190, 450, 50, 6, 28, 20, { "#f0a8d8", "#b46ab4", "#7a4a98", "#4a3478" }, 4)
aurora(260, 440, 74, 4, 22, 12, { "#a8f6d4", "#58d0a4", "#2f8c84", "#2c5a78" }, 2.5)

-- twin crescent moons (crescents, not discs)
local function crescent(cx, cy, r, dx, dy, lit, shade)
  local m = c:ellipse(cx, cy, r, r):cut(c:ellipse(cx + dx, cy + dy, r, r))
  m:each(function(x, y) c:put(x, y, (x - cx) + (y - cy) < -r * 0.6 and lit[3] or lit[2]) end)
  c:fillMask(m:edge(), shade)
  return m
end
crescent(122, 36, 13, 6, -4, { "#d8c48c", "#f0dcaa", "#fff2cc" }, "#b89c6a")
crescent(374, 26, 7, -3, -2, { "#c8b8e8", "#e2d6f8", "#f4eeff" }, "#9a8cc8")

---------------------------------------------------------------- far scenery
local ridge = c:terrain(function(x) return 86 + 9 * sin(x / 31) + 5 * sin(x / 11 + 2) end, "#2e2a5a", 112)
ridge:each(function(x, y) if not ridge:has(x, y - 1) then c:put(x, y, "#4a4482") elseif not ridge:has(x, y - 2) and hsh(x, y, 3) < 0.5 then c:put(x, y, "#3c3870") end end)
local hills = c:terrain(function(x) return 101 + 5 * sin(x / 45 + 1) + 3 * sin(x / 17) end, "#1d2f44", 112)
hills:each(function(x, y) if not hills:has(x, y - 1) then c:put(x, y, "#2c4a5a") end end)
-- tiny far trees on the hills
for x = 30, 450, 11 do
  local by = floor(101 + 5 * sin(x / 45 + 1) + 3 * sin(x / 17) + 1)
  if hsh(x, 1, 9) < 0.55 and abs(x - 240) > 60 then
    local th = 6 + floor(hsh(x, 2, 9) * 5)
    for k = 0, th do local hw = floor(k / 3) for dx = -hw, hw do c:put(x + dx, by - th + k, k < 2 and "#2a4a56" or "#182838") end end
  end
end

---------------------------------------------------------------- ground
local HZ = 112
local gRows = { {112,"#1f3a3c"},{122,"#23443f"},{136,"#284d42"},{156,"#2c5544"},{184,"#305c47"},{214,"#34634a"} }
for y = HZ, H - 1 do
  local col = gRows[1][2]
  for _, r in ipairs(gRows) do if y >= r[1] then col = r[2] end end
  for x = 0, W - 1 do c:put(x, y, col) end
end
-- crystal glow on the meadow (diamond falloff)
for y = HZ, 200 do for x = 120, 360 do
  local d = abs(x - 240) * 0.55 + abs(y - 150) * 1.1
  if d < 30 then c:put(x, y, "#4a8a7c") elseif d < 48 + hsh(x, y, 5) * 6 then c:put(x, y, "#3c7468") elseif d < 70 + hsh(x, y, 6) * 8 then c:put(x, y, "#336858") end
end end
-- grass tufts and tiny flowers (not in the calm corner)
for y = HZ + 6, H - 3 do for x = 2, W - 3 do
  local r = hsh(x, y, 11)
  if not (x >= 376 and y >= 226) then
    local dens = 0.012 + (y - HZ) / 160 * 0.02
    if r < dens then
      local tall = y > 180 and 3 or 2
      for k = 0, tall - 1 do c:put(x, y - k, k == tall - 1 and "#6aa05a" or "#4f8a50") end
      c:put(x + 1, y - 1, "#4f8a50"); c:put(x, y + 1, "#1f3e34")
    elseif r < dens + 0.0025 then
      c:put(x, y, hsh(x, y, 12) < 0.5 and "#b8a8ec" or "#f0c8e0")
    end
  end
end end
-- calm corner: a few soft tufts only
for _, p in ipairs({ {392,244},{430,258},{462,238} }) do c:put(p[1], p[2], "#3e7250"); c:put(p[1]+1, p[2], "#3e7250") end

---------------------------------------------------------------- wild trail (to the arch)
local trail = c:poly{ {300,204}, {398,212}, {440,222}, {440,228}, {396,230}, {300,236} }
rowFill(trail, function(x, y)
  local r = hsh(x, y, 21)
  return r < 0.08 and "#7a6650" or r < 0.5 and "#5e4c3c" or "#6a5644"
end)
c:fillMask(trail:edge(), "#3e3228")

-- v2.5.40 polish guard: nothing painted within 16 px of stand points or in the compass corner
local STANDS = { {110,240},{176,246},{256,252},{326,234},{205,197},{282,197} }
local function free(x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return false end
  if x >= 372 and y >= 222 then return false end
  for _, s in ipairs(STANDS) do if abs(x - s[1]) <= 17 and abs(y - s[2]) <= 17 then return false end end
  return true
end
local function gput(x, y, col) if free(x, y) then c:put(x, y, col) end end

-- v2.5.40 polish pass 1: ground variety (dithered tone patches, worn trail scuffs, flowers, pebbles)
for y = HZ + 3, H - 1 do for x = 0, W - 1 do
  local v = sin(x / 19 + y / 13) + 0.6 * sin(x / 7 - y / 9) + 0.5 * sin(x / 41 + y / 5) + (hsh(x, y, 301) - 0.5) * 0.5
  local fy = (y - HZ) / 150
  if v > 1.15 then
    if v > 1.3 or (x + y) % 2 == 0 then gput(x, y, fy < 0.3 and "#2e5848" or "#3a6e50") end
  elseif v < -1.1 then
    if v < -1.25 or (x + y) % 2 == 0 then gput(x, y, fy < 0.3 and "#1c3434" or "#274a3c") end
  elseif v > 0.95 and (x * 3 + y) % 5 == 0 then
    gput(x, y, "#587f4c")
  end
end end
-- warm dry grass flecks
for y = HZ + 20, H - 1 do for x = 0, W - 1 do
  if hsh(x, y, 311) < 0.004 then gput(x, y, "#7e8a50"); gput(x + 1, y - 1, "#6a7c48") end
end end
-- worn scuffs: dirt pixels beside the flagstone road and along the wild trail
for i = 0, 70 do
  local t = i / 70
  local x = floor(300 + t * 140 + 0.5)
  local y = floor(205 + t * 20 + sin(i * 0.9) * 2)
  for k = -3, 3 do if hsh(x, y + k, 321) < 0.3 then gput(x, y + k, "#5a4a38") end end
  if i % 5 == 0 then gput(x, y - 5, "#7a6a4e"); gput(x + 1, y - 5, "#6a5a42") end
  if i % 7 == 3 then gput(x, y + 7, "#4e4034"); gput(x - 1, y + 7, "#4e4034") end
end
for _, p in ipairs({ {102,196},{96,206},{86,214},{112,206},{150,204},{158,212},{166,208},{210,236},{200,230} }) do
  gput(p[1], p[2], "#6a5a44"); gput(p[1] + 1, p[2], "#4e4034"); gput(p[1] - 1, p[2] + 1, "#5a4a38")
end
-- pebbles
for _, p in ipairs({ {70,240,3},{140,222,2},{372,205,2},{300,250,3},{60,262,2},{430,196,2},{402,214,3},{204,260,2},{358,252,2},{20,230,3},{128,258,2},{152,196,2} }) do
  local x, y, r = p[1], p[2], p[3]
  for dx = 0, r do gput(x + dx, y, "#8a849c"); gput(x + dx, y + 1, "#5a546c") end
  gput(x, y, "#b4aec4"); gput(x - 1, y + 1, "#2a2234"); gput(x + r + 1, y + 1, "#2a2234")
  for dx = 0, r do gput(x + dx, y + 2, "#1c3430") end
end
-- flowers (clustered, three kinds)
local function flower(x, y, k)
  gput(x, y + 1, "#2e5a34"); gput(x, y + 2, "#2e5a34")
  if k == 1 then gput(x, y, "#f6d46a"); gput(x - 1, y, "#e8a848"); gput(x + 1, y, "#e8a848"); gput(x, y - 1, "#e8a848")
  elseif k == 2 then gput(x, y, "#f0c8e0"); gput(x - 1, y, "#c24c8e"); gput(x + 1, y, "#c24c8e"); gput(x, y - 1, "#e070a8")
  else gput(x, y, "#c4a8f6"); gput(x, y - 1, "#9878e0"); gput(x - 1, y, "#6e50bc"); gput(x + 1, y, "#6e50bc") end
end
for _, p in ipairs({ {30,150,1},{34,153,2},{26,156,3},{112,214,1},{116,217,3},{148,198,2},{152,201,1},{90,248,2},{94,252,1},{134,236,3},{360,196,1},{364,199,2},{300,196,3},{304,190,1},{408,198,2},{412,202,1},{348,258,3},{210,244,1},{214,247,2},{66,226,2},{70,229,3},{44,260,1},{384,196,3},{190,226,2},{132,176,1},{138,178,2},{370,158,3},{372,162,1} }) do flower(p[1], p[2], p[3]) end

---------------------------------------------------------------- main path (flagstones in perspective)
local function halfw(y) return 26 + (y - 160) * 92 / 110 end
local pathM = c:poly{ {214,160}, {266,160}, {356,270}, {124,270} }
local rowTop, rowIdx = {}, {}
do
  local y, s, r = 160, 5, 0
  while y < H do
    for yy = floor(y), min(H - 1, floor(y + s) - 1) do rowTop[yy] = floor(y); rowIdx[yy] = r end
    y = y + s; s = s * 1.17; r = r + 1
  end
end
local PATH = { "#3a3350", "#5a5272", "#6e6688", "#7e7698", "#948cae", "#aea8c6" }
pathM:each(function(x, y)
  local hw = halfw(y)
  local u = (x - 240) / hw
  local r = rowIdx[y] or 0
  local nPer = 3.5
  local q = u * nPer + (r % 2) * 0.5 + 10
  local k = floor(q)
  local frac = q - k
  local stoneW = hw / nPer
  local col
  if y == rowTop[y] or frac * stoneW < 1 then col = PATH[1]
  else
    local v = hsh(k, r, 31)
    local b = v < 0.3 and 3 or v < 0.75 and 4 or 5
    if y == rowTop[y] + 1 or frac * stoneW < 2 then b = b + 1 end
    if (1 - frac) * stoneW < 2 then b = b - 1 end
    if hsh(x, y, 33) < 0.05 then b = b - 1 end
    col = PATH[max(2, min(6, b))]
  end
  c:put(x, y, col)
end)
-- mossy path border
pathM:edge():each(function(x, y) c:put(x, y, "#2a4a3a") if hsh(x, y, 34) < 0.4 then c:put(x, y - 1, "#3e6e46") end end)
-- crystal shards sprouting from cracks (quirk)
for _, p in ipairs({ {150,262,5},{338,262,4},{228,178,3} }) do
  local x, y, s = p[1], p[2], p[3]
  local m = c:poly{ {x, y - s * 2}, {x + s // 2 + 1, y}, {x - s // 2 - 1, y} }
  fill(m, CRY, { base = 0.95 })
  c:put(x, y - s * 2 + 1, CRY[6])
end

---------------------------------------------------------------- crystal glow aura on sky/far scenery
local crystalAll = c:poly{ {240,28}, {258,64}, {258,140}, {222,140}, {222,64} }
  :add(c:poly{ {204,84}, {214,80}, {228,140}, {212,140} })
  :add(c:poly{ {276,76}, {286,82}, {270,140}, {256,140} })
do
  local a2 = crystalAll:grow(12)
  a2:each(function(x, y) if y < 136 and hsh(x, y, 41) < 0.85 then c:put(x, y, y < 100 and "#3e3a86" or "#2e5a66") end end)
  local a1 = crystalAll:grow(6)
  a1:each(function(x, y) if y < 136 then c:put(x, y, y < 100 and "#5054a8" or "#3f7f84") end end)
end

---------------------------------------------------------------- trilithon (stone arch behind the crystal)
local function stoneBlock(m, seed, mossTop)
  fill(m, STONE, { seed = seed, noise = 0.22 })
  -- cracks
  local x0, y0, x1, y1 = bbox(m)
  for i = 1, 3 do
    local cx = floor(x0 + 3 + hsh(i, seed, 51) * (x1 - x0 - 6))
    local cy = floor(y0 + 4 + hsh(i, seed, 52) * (y1 - y0 - 8))
    for k = 0, 4 do if m:has(cx + (k % 2), cy + k) then c:put(cx + (k % 2), cy + k, STONE[1]) end end
  end
  if mossTop then
    m:each(function(x, y)
      if not m:has(x, y - 2) and hsh(x, y, seed + 3) < 0.85 then c:put(x, y, (not m:has(x, y - 1)) and MOSS[3] or MOSS[4]) end
      if not m:has(x, y - 4) and m:has(x, y - 2) and hsh(x, y, seed + 4) < 0.35 then c:put(x, y, MOSS[2]) end
    end)
  end
end
shadow(196, 147, 14, 3); shadow(298, 147, 14, 3)
stoneBlock(c:poly{ {180,146}, {182,70}, {198,68}, {200,146} }, 61, false)
stoneBlock(c:poly{ {282,146}, {284,68}, {298,70}, {302,146} }, 62, false)
stoneBlock(c:poly{ {172,58}, {306,54}, {310,68}, {174,72} }, 63, true)

---------------------------------------------------------------- dais
shadow(250, 162, 50, 4, "#1c3a34")
local dais1 = c:poly{ {194,150}, {286,150}, {290,161}, {190,161} }
local dais2 = c:poly{ {206,140}, {274,140}, {278,150}, {202,150} }
fill(dais1, STONE, { seed = 71, ku = 0.5, kt = 0.1, base = 0.82 })
for x = 191, 289 do c:put(x, 150, STONE[5]) end
fill(dais2, STONE, { seed = 72, ku = 0.5, kt = 0.1, base = 0.9 })
for x = 203, 277 do c:put(x, 140, STONE[6]) end
for x = 200, 280, 14 do for y = 152, 159 do c:put(x, y, STONE[2]) end end
-- glowing rune strip on dais front (chevrons)
for i = 0, 5 do local bx = 212 + i * 10 for k = 0, 2 do c:put(bx + k, 145 - k, "#7ad8f0") c:put(bx + 4 - k, 145 - k, "#7ad8f0") end end

---------------------------------------------------------------- crystal cluster (the Wonder)
local leftF = c:poly{ {240,28}, {232,58}, {232,140}, {222,140}, {222,64} }
local frontF = c:poly{ {240,28}, {248,58}, {248,140}, {232,140}, {232,58} }
local rightF = c:poly{ {240,28}, {258,64}, {258,140}, {248,140}, {248,58} }
local sideL = c:poly{ {204,84}, {214,80}, {228,140}, {212,140} }
local sideR = c:poly{ {276,76}, {286,82}, {270,140}, {256,140} }
local smallL = c:poly{ {214,116}, {221,112}, {226,140}, {214,140} }
local smallR = c:poly{ {263,118}, {270,122}, {266,140}, {257,140} }
fill(sideL, VIO, { seed = 81, base = 1.0 })
fill(sideR, TEAL, { seed = 82, base = 0.95 })
fill(leftF, CRY, { seed = 83, base = 1.12, ku = 0.2, kt = 0.25, noise = 0.1, edge = CRY[1] })
fill(frontF, CRY, { seed = 84, base = 0.92, ku = 0.2, kt = 0.3, noise = 0.1, edge = CRY[1] })
fill(rightF, CRY, { seed = 85, base = 0.6, ku = 0.2, kt = 0.3, noise = 0.1, edge = CRY[1] })
fill(smallL, VIO, { seed = 86, base = 1.05 })
fill(smallR, TEAL, { seed = 87, base = 0.9 })
-- inner light streaks + glint
for y = 48, 126 do c:put(236, y, y % 9 < 6 and CRY[6] or CRY[5]) end
for y = 66, 110 do c:put(227, y, CRY[6]) end
for y = 90, 128 do c:put(208 + floor((y - 84) / 6), y, "#e4d4ff") end
c:put(240, 31, "#f4fbff"); c:put(239, 32, CRY[6]); c:put(241, 32, CRY[6])
for k = -4, 4 do c:put(240 + k, 24, k == 0 and "#f4fbff" or CRY[5]); c:put(240, 24 + k, k == 0 and "#f4fbff" or CRY[5]) end
-- facet ridges
for y = 58, 140 do c:put(232, y, CRY[5]); c:put(248, y, CRY[2]) end

---------------------------------------------------------------- floating rocks (quirk)
local function floater(x0, y0, w, seed)
  local m = c:poly{ {x0, y0}, {x0 + w, y0 - 1}, {x0 + w - 3, y0 + 6}, {x0 + w // 2, y0 + 10}, {x0 + 3, y0 + 6} }
  fill(m, STONE, { seed = seed })
  for x = x0, x0 + w do if m:has(x, y0) then c:put(x, y0, MOSS[3]) end end
  for x = x0 + 4, x0 + w - 4 do if hsh(x, seed, 2) < 0.5 then c:put(x, y0 + 11 + floor(hsh(x, seed, 3) * 3), "#7ad8f0") end end
  c:put(x0 + w // 2, y0 + 15, "#a8f0ff")
end
floater(150, 34, 18, 91)
floater(312, 30, 16, 92)

---------------------------------------------------------------- mid-left standing stone with rune
shadow(124, 184, 22, 4)
local msL = c:poly{ {100,182}, {98,104}, {108,90}, {126,88}, {136,100}, {138,182} }
stoneBlock(msL, 101, true)
-- moss beard down the left
msL:each(function(x, y) if not msL:has(x - 3, y) and y > 120 and y < 170 and hsh(x, y, 9) < 0.6 then c:put(x, y, MOSS[3]) end end)
-- glowing rune: diamond with tail
local rx, ry = 118, 128
for k = 0, 8 do
  c:put(rx - 8 + k, ry - k, "#7ad8f0"); c:put(rx + k, ry - 8 + k, "#7ad8f0")
  c:put(rx + 8 - k, ry + k, "#5ab8e0"); c:put(rx - k, ry + 8 - k, "#5ab8e0")
end
for y = ry + 10, ry + 24 do c:put(rx, y, "#5ab8e0") end
c:put(rx, ry, "#d6f6ff"); c:put(rx - 1, ry, "#a8f0ff"); c:put(rx + 1, ry, "#a8f0ff")

---------------------------------------------------------------- glowing mushrooms (quirk)
local function mush(cx, by, r, h, seed)
  local st = c:rect(cx - 2, by - h, cx + 2, by)
  fill(st, CREAM, { seed = seed, base = 1.0 })
  local cap = c:ellipse(cx, by - h, r, floor(r * 0.7)):clip(c:rect(cx - r, by - h - r, cx + r, by - h))
  fill(cap, CAP, { seed = seed + 1, base = 1.05 })
  for i = 1, 4 do
    local sx = cx - r + 3 + floor(hsh(i, seed, 1) * (2 * r - 6))
    local sy = by - h - 2 - floor(hsh(i, seed, 2) * (r * 0.4))
    if cap:has(sx, sy) and cap:has(sx + 1, sy + 1) then c:put(sx, sy, "#d8fff0"); c:put(sx + 1, sy, "#a8f0e0"); c:put(sx, sy + 1, "#a8f0e0") end
  end
  for x = cx - r + 1, cx + r - 1 do c:put(x, by - h + 1, CAP[1]) end
end
shadow(162, 181, 16, 3)
mush(166, 180, 9, 16, 111)
mush(152, 180, 6, 9, 113)
mush(174, 180, 4, 6, 115)

---------------------------------------------------------------- mid-right leaning stone with prop pebble (quirk)
shadow(342, 182, 22, 4)
local msR = c:poly{ {324,180}, {326,104}, {336,90}, {350,92}, {358,104}, {356,180} }
stoneBlock(msR, 121, true)
-- violet triangle rune
for k = 0, 10 do c:put(334 + k, 150 - floor(k * 1.6), "#c4a8f6"); c:put(344 + k, 134 + floor(k * 1.6), "#9878e0") end
for x = 334, 354 do c:put(x, 150, "#9878e0") end
c:put(344, 143, "#f0e4ff")
-- prop pebble
local peb = c:poly{ {356,170}, {364,168}, {368,174}, {366,180}, {356,180} }
fill(peb, WARM, { seed = 123 })

---------------------------------------------------------------- giant lantern-flowers near left (quirk: glowing bulbs)
shadow(58, 208, 30, 4)
local function leaf(pts, seed)
  local m = c:poly(pts)
  fill(m, MOSS, { seed = seed, base = 1.0 })
  return m
end
leaf({ {44,206}, {22,186}, {18,170}, {34,178}, {48,200} }, 131)
leaf({ {60,206}, {84,190}, {94,176}, {76,182}, {56,200} }, 132)
local s1 = c:line({ {46,206}, {44,180}, {40,150}, {42,124} }, 4)
local s2 = c:line({ {66,206}, {70,184}, {76,160}, {78,150} }, 3)
fill(s1, STEM, { seed = 133, base = 1.0 })
fill(s2, STEM, { seed = 134, base = 1.0 })
leaf({ {42,160}, {28,150}, {24,140}, {36,146}, {44,156} }, 135)
local function bell(cx, top, w, h, seed)
  local m = c:poly{ {cx - w // 3, top}, {cx + w // 3, top}, {cx + w // 2 + 2, top + h}, {cx - w // 2 - 2, top + h} }
  -- scalloped rim
  for x = cx - w // 2 - 2, cx + w // 2 + 2 do if (x - cx) % 6 < 3 then m:set(x, top + h + 1) m:set(x, top + h + 2) end end
  fill(m, PET, { seed = seed, base = 1.05 })
  for x = cx - w // 3, cx + w // 3 do c:put(x, top, STEM[3]) end
  for y = top + 3, top + h - 2 do c:put(cx - 3 - floor((y - top) / 4), y, PET[4]) end
  -- glowing bulb hanging inside
  for y = top + h + 1, top + h + 4 do c:put(cx, y, STEM[2]) end
  diamond(cx, top + h + 7, 3, GLOW[1], GLOW[3])
  c:put(cx - 1, top + h + 6, GLOW[2]); c:put(cx + 1, top + h + 6, GLOW[2])
  return m
end
bell(42, 108, 26, 16, 141)
bell(78, 136, 20, 12, 142)
-- small bud
local bud = c:poly{ {54,128}, {58,124}, {60,132}, {56,136} }
for y = 136, 150 do c:put(52 + floor((y - 136) / 5), y, STEM[2]) end
fill(bud, PET, { seed = 143 })

---------------------------------------------------------------- mist ring around the dais (back part drawn under, front over)
local function mist(front)
  for x = 170, 310 do
    local dx = (x - 240) / 70
    local yc = 158 + floor((front and 6 or -6) * (1 - dx * dx) + 0.5)
    local th = floor(2 + 2 * sin(x / 6) + hsh(x, 1, 61) * 2)
    for k = 0, th do
      local y = yc - k + floor(sin(x / 9) * 1.5)
      if hsh(x, k, 62) < 0.9 then c:put(x, y, k == th and "#b4b4e0" or (k == 0 and "#6e72a8" or "#8e90c4")) end
    end
  end
end
mist(true)

---------------------------------------------------------------- wild arch on the right + signpost
shadow(424, 227, 36, 3)
local archOuter = c:poly{ {388,226}, {390,142}, {400,118}, {420,104}, {440,112}, {452,136}, {454,226} }
local archInner = c:poly{ {404,226}, {405,152}, {412,134}, {422,128}, {432,134}, {438,152}, {438,226} }
-- view through the arch: deep wood and a trail going in
rowFill(archInner, function(x, y)
  if y < 170 then return hsh(x, y, 71) < 0.5 and "#1a3a34" or "#163028" end
  if y < 200 then return hsh(x, y, 72) < 0.5 and "#22463a" or "#1d3e34" end
  return "#2a5040"
end)
for _, tx in ipairs({ 410, 422, 432 }) do
  for k = 0, 22 do local hw = floor(k / 3) for dx = -hw, hw do if archInner:has(tx + dx, 150 + k) then c:put(tx + dx, 150 + k, k % 4 == 0 and "#2e6648" or "#24543c") end end end
  c:put(tx, 174, "#3a2a24"); c:put(tx, 175, "#3a2a24")
end
local inTrail = c:poly{ {418,200}, {426,200}, {438,226}, {406,226} }:clip(archInner)
rowFill(inTrail, function(x, y) return hsh(x, y, 73) < 0.4 and "#7a6650" or "#6a5644" end)
for _, p in ipairs({ {414,160},{430,146},{422,186} }) do c:put(p[1], p[2], "#ffe08a") end
local arch = archOuter:copy():cut(archInner)
fill(arch, ARCH, { seed = 151, noise = 0.25 })
-- block joints
arch:each(function(x, y)
  if (y % 14 == 0 and (x + floor(y / 14) * 5) % 3 ~= 0) then c:put(x, y, ARCH[1]) end
end)
c:fillMask(archInner:grow(1):clip(arch), ARCH[1])
-- moss cap + hanging vines
arch:each(function(x, y) if not archOuter:has(x, y - 2) and hsh(x, y, 152) < 0.8 then c:put(x, y, MOSS[3]) end end)
for _, vx in ipairs({ 412, 426, 434 }) do
  local top = 0
  for y = 104, 160 do if arch:has(vx, y) and not arch:has(vx, y + 1) then top = y break end end
  if top > 0 then for y = top, top + 12 + (vx % 7) do c:put(vx + floor(sin(y / 3) + 0.5), y, y % 3 == 0 and MOSS[4] or MOSS[2]) end end
end
-- signpost (in front of the arch, left)
shadow(380, 226, 8, 2)
local post = c:rect(376, 186, 380, 225)
fill(post, WOOD, { seed = 161, base = 1.0 })
local board = c:poly{ {362,188}, {392,188}, {400,195}, {392,202}, {362,202} }
fill(board, WOOD, { seed = 162, base = 1.05, kt = 0.15 })
for x = 364, 390 do c:put(x, 195, WOOD[2]) end
-- icon: little pine + footprint dashes (no text)
for k = 0, 7 do local hw = floor(k / 2) for dx = -hw, hw do c:put(372 + dx, 190 + k, k == 0 and MOSS[5] or MOSS[3]) end end
c:put(372, 198, WOOD[1]); c:put(372, 199, WOOD[1])
for i = 0, 2 do c:put(380 + i * 4, 196, "#f0dcaa"); c:put(381 + i * 4, 196, "#f0dcaa") end
c:put(366, 190, "#e8bc56")

---------------------------------------------------------------- floating light motes (around crystal, in the air)
for _, m in ipairs({ {196,44,"#ffe08a"},{282,40,"#a8f0ff"},{206,104,"#c4a8f6"},{276,104,"#a8f0ff"},{168,96,"#ffe08a"},{314,86,"#f0a8d8"},
                     {94,72,"#a8f0ff"},{378,120,"#ffe08a"},{140,140,"#a8f0ff"},{304,124,"#c4a8f6"},{60,94,"#ffe08a"},{212,26,"#a8f0ff"} }) do
  diamond(m[1], m[2], 1, m[3], "#fff8e0")
end

---------------------------------------------------------------- gate frame: mossy rock pillars + overhang, lantern and chime
local function rockFrame(m, seed)
  fill(m, WARM, { seed = seed, noise = 0.26, ku = 0.3, kt = 0.15, base = 0.8 })
  -- boulder joints
  m:each(function(x, y)
    local by = floor((y + floor(x / 22) * 9) / 20)
    if (y + floor(x / 22) * 9) % 20 == 0 then c:put(x, y, WARM[1]) end
    if hsh(by, floor(x / 18), seed) < 0.15 and hsh(x, y, seed + 1) < 0.5 then c:put(x, y, MOSS[2]) end
  end)
end
local leftP = c:terrain(function() return 0 end, nil, H - 1, 0, 0)
leftP = HP.mask()
for y = 0, H - 1 do for x = 0, floor(17 + 3 * sin(y / 9) + 2 * sin(y / 4)) do leftP:set(x, y) end end
local rightP = HP.mask()
for y = 0, 228 do for x = floor(462 - 3 * sin(y / 8) - 2 * sin(y / 5)), W - 1 do rightP:set(x, y) end end
local topB = HP.mask()
for x = 0, W - 1 do for y = 0, floor(11 + 3 * sin(x / 13) + 2 * sin(x / 5) + (abs(x - 240) > 200 and 6 or 0)) do topB:set(x, y) end end
shadow(470, 229, 12, 2)
rockFrame(rightP, 171)
rockFrame(leftP, 172)
rockFrame(topB, 173)
-- moss along the overhang underside + hanging roots
topB:each(function(x, y) if not topB:has(x, y + 1) then c:put(x, y, MOSS[3]) c:put(x, y - 1, MOSS[2]) end end)
for _, vx in ipairs({ 30, 62, 96, 140, 178, 300, 336, 368, 404, 446 }) do
  local top = 0 for y = 0, 30 do if topB:has(vx, y) then top = y end end
  local len = 8 + floor(hsh(vx, 1, 181) * 18)
  for y = top + 1, top + len do
    local xx = vx + floor(sin(y / 4 + vx) * 1.2 + 0.5)
    c:put(xx, y, MOSS[2])
    if y % 4 == 0 then c:put(xx + 1, y, MOSS[4]); c:put(xx - 1, y + 1, MOSS[3]) end
  end
end
-- hanging lantern (left)
for y = 18, 27 do c:put(44, y, y % 2 == 0 and BRASS[2] or BRASS[1]) end
local halo = c:rect(36, 26, 52, 46):cut(c:rect(38, 28, 50, 44))
halo:each(function(x, y) if hsh(x, y, 191) < 0.5 and not topB:has(x, y) then c:put(x, y, "#5a3f6a") end end)
local cap = c:poly{ {40,28}, {48,28}, {50,31}, {38,31} }
fill(cap, BRASS, { seed = 192 })
local lb = c:rect(39, 32, 49, 42)
c:fillMask(lb, BRASS[1])
c:fillMask(c:rect(41, 33, 47, 41), GLOW[1])
c:fillMask(c:rect(42, 34, 45, 39), GLOW[2])
c:fillMask(c:rect(43, 35, 44, 37), GLOW[3])
for y = 33, 41 do c:put(44, y, BRASS[3]) end
c:fillMask(c:rect(40, 43, 48, 44), BRASS[2])
c:put(44, 45, BRASS[3])
-- crystal chime (right)
for y = 18, 24 do c:put(436, y, BRASS[2]) end
for x = 428, 444 do c:put(x, 25, BRASS[3]) end
c:put(428, 26, BRASS[1]); c:put(444, 26, BRASS[1])
for i, dx in ipairs({ -6, 0, 6 }) do
  local x = 436 + dx
  local len = 4 + i
  for y = 26, 26 + len do c:put(x, y, "#8a7a9a") end
  local cm = c:poly{ {x, 27 + len}, {x + 2, 31 + len}, {x, 37 + len}, {x - 2, 31 + len} }
  fill(cm, i == 2 and VIO or CRY, { seed = 200 + i, base = 1.1 })
  c:put(x - 1, 31 + len, "#e4f4ff")
end

-- v2.5.40 polish pass 2: material cues (stone courses + chips, lichen, crystal facets + sparkles, wood, leaf veins)
local function mput(m, x, y, col) if m:has(x, y) then gput(x, y, col) end end
local function chip(m, x, y)
  mput(m, x, y, STONE[6]); mput(m, x + 1, y, STONE[5]); mput(m, x, y + 1, STONE[5])
  mput(m, x + 1, y + 1, STONE[1]); mput(m, x + 2, y + 1, STONE[1]); mput(m, x + 1, y + 2, STONE[2])
end
local function courses(m, y0, step, off, seed)
  local x0, _, x1 = bbox(m)
  for y = y0, 180, step do
    for x = x0, x1 do
      if hsh(x, y, seed) < 0.78 then mput(m, x, y + floor(sin(x / 5 + y) + 0.5), STONE[2]) end
      if hsh(x, y, seed + 1) < 0.25 then mput(m, x, y + 1 + floor(sin(x / 5 + y) + 0.5), STONE[4]) end
    end
  end
end
courses(msL, 112, 15, 0, 401); courses(msR, 112, 15, 0, 402)
for _, q in ipairs({ {104,104},{122,100},{110,150},{128,134},{104,170},{120,168} }) do chip(msL, q[1], q[2]) end
for _, q in ipairs({ {330,116},{344,102},{348,128},{334,164},{346,168},{352,150} }) do chip(msR, q[1], q[2]) end
-- lichen (pale yellow-green) on the weathered north/top-left faces + moss streaks
for _, q in ipairs({ {102,120,3},{112,96,2},{104,152,3},{328,126,3},{340,98,2},{330,160,3} }) do
  for dx = -q[3], q[3] do for dy = -1, 1 do
    if hsh(q[1] + dx, q[2] + dy, 411) < 0.6 then mput(msL, q[1] + dx, q[2] + dy, "#a8b070"); mput(msR, q[1] + dx, q[2] + dy, "#a8b070") end
  end end
  mput(msL, q[1], q[2], "#d4d894"); mput(msR, q[1], q[2], "#d4d894")
end
-- trilithon: course joints, chips, lintel crack, moss drip
local pil1 = c:poly{ {180,146}, {182,70}, {198,68}, {200,146} }
local pil2 = c:poly{ {282,146}, {284,68}, {298,70}, {302,146} }
local lintel = c:poly{ {172,58}, {306,54}, {310,68}, {174,72} }
for _, m in ipairs({ pil1, pil2 }) do
  local x0, _, x1 = bbox(m)
  for y = 86, 140, 18 do for x = x0, x1 do mput(m, x, y, STONE[2]); if (x + y) % 3 == 0 then mput(m, x, y + 1, STONE[5]) end end end
end
for _, q in ipairs({ {186,100},{192,124},{289,90},{292,118},{187,80} }) do chip(pil1, q[1], q[2]); chip(pil2, q[1], q[2]) end
for x = 190, 290, 2 do mput(lintel, x, 62 + floor((x - 190) / 33), STONE[2]) end
for _, mx in ipairs({ 190, 214, 262, 296 }) do for y = 62, 66 do mput(lintel, mx, y, MOSS[y % 2 + 2]) end end
mput(lintel, 240, 60, STONE[1]); mput(lintel, 241, 61, STONE[1]); mput(lintel, 241, 62, STONE[1]); mput(lintel, 242, 63, STONE[1])
-- crystal: facet ramps (3 tones per face), sparkle crosses
for y = 60, 138 do
  if y % 2 == 0 then gput(241, y, CRY[4]); gput(242, y, CRY[3]) end
  if y % 3 == 0 then gput(229, y, CRY[5]) end
  gput(254, y, CRY[1]); if y % 2 == 1 then gput(253, y, CRY[2]) end
end
for y = 100, 138 do if y % 2 == 0 then gput(236 + (y % 4) // 2, y, CRY[3]) end end
for _, q in ipairs({ {236,70},{244,96},{229,120},{252,110},{234,44} }) do
  gput(q[1], q[2], "#f4fbff"); gput(q[1] - 1, q[2], CRY[5]); gput(q[1] + 1, q[2], CRY[5]); gput(q[1], q[2] - 1, CRY[5]); gput(q[1], q[2] + 1, CRY[5])
end
for _, q in ipairs({ {210,94},{209,112},{277,88},{279,104},{268,128} }) do
  gput(q[1], q[2], "#f0e8ff"); gput(q[1], q[2] - 1, VIO[5]); gput(q[1] + 1, q[2], TEAL[5])
end
-- dais chips
for _, q in ipairs({ {198,154},{230,156},{262,153},{280,157},{214,143},{250,144},{268,142} }) do
  gput(q[1], q[2], STONE[1]); gput(q[1] + 1, q[2], STONE[1]); gput(q[1], q[2] - 1, STONE[5]); gput(q[1] + 1, q[2] - 1, STONE[6])
end
-- wild arch: chips, lichen, keystone, rust-brown stain
for _, q in ipairs({ {394,150},{397,176},{396,204},{446,160},{448,190},{444,214},{404,126},{436,120},{420,112} }) do
  gput(q[1], q[2], ARCH[5]); gput(q[1] + 1, q[2], ARCH[4]); gput(q[1], q[2] + 1, ARCH[4]); gput(q[1] + 1, q[2] + 1, ARCH[1]); gput(q[1] + 2, q[2] + 1, ARCH[1])
end
for _, q in ipairs({ {392,130,2},{398,182,3},{404,118,2},{446,206,2} }) do
  for dx = -q[3], q[3] do for dy = -1, 1 do if arch:has(q[1] + dx, q[2] + dy) and hsh(q[1] + dx, q[2] + dy, 421) < 0.65 then gput(q[1] + dx, q[2] + dy, "#a8b070") end end end
end
for y = 106, 114 do mput(arch, 420, y, ARCH[1]); mput(arch, 421, y, ARCH[1]) end
for y = 168, 190 do if hsh(1, y, 431) < 0.7 then mput(arch, 448, y, "#6a5048") end end
-- signpost: grain, nails, rope binding
for y = 188, 224 do if y % 4 ~= 0 then gput(378, y, WOOD[2]) end end
c:put(364, 195, WOOD[5]); c:put(391, 195, WOOD[1])
for y = 203, 206 do c:put(376, y, CREAM[3]); c:put(380, y, CREAM[3]); c:put(377, y, y % 2 == 0 and CREAM[2] or CREAM[4]); c:put(378, y, CREAM[2]); c:put(379, y, CREAM[3]) end
-- lantern-flower leaves: midribs; mushroom gills
for k = 0, 14 do c:put(40 - k, 186 - floor(k * 0.9), MOSS[5]) ; c:put(82 + k * 0 + floor(k * 0.7), 188 - k, MOSS[5]) end
for _, q in ipairs({ {166,180,9},{152,180,6},{174,180,4} }) do
  local hh = q[1] == 166 and 16 or (q[1] == 152 and 9 or 6)
  for x = q[1] - q[3] + 2, q[1] + q[3] - 2, 2 do c:put(x, q[2] - hh + 2, CAP[2]) end
end

---------------------------------------------------------------- layout + save
c:finish{ outline = false }
HP.assertClean(c)
local spots = {
  { k = "investigate", name = "The Crystal Ring", box = { 170, 20, 312, 166 } },
  { k = "wild", name = "Wild Trail", box = { 360, 102, 456, 228 } },
}
local stand = { { x = 110, y = 240 }, { x = 176, y = 246 }, { x = 256, y = 252 }, { x = 326, y = 234 }, { x = 205, y = 197 }, { x = 282, y = 197 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s.k, s.name, (b[1] + b[3]) // 2, (b[2] + b[4]) // 2, b[1], b[2], b[3], b[4])
end
local sp = {}
for _, s in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', s.x, s.y) end
local json = string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n',
  HZ, table.concat(parts, ","), table.concat(sp, ","))
local f = io.open(OUT .. "here-wonder.layout.json", "w") f:write(json) f:close()
c:save{ aseprite = OUT .. "here-wonder.aseprite", png = OUT .. "here-wonder.png", scale = 1 }
print("ok here-wonder")

local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "grassland" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local G = { hi = "#d8f880", base = "#9ce048", shade = "#58b040", deep = "#2a7a44" }
local BARK = { hi = "#c89060", base = "#94603c", shade = "#6e4234", deep = "#442a2c" }
local FL = { "#ff9fc0", "#fff4d6", "#ffd470", "#c9b2f0", "#ff8a5c", "#ffffff" }

-- sky
GX.bands(c, 0, 140, { "#4a9ce6", "#62b0ee", "#7cc2f2", "#9ad2f6", "#bde6f8", "#e0f4f4" }, 3, .2)
-- sun glow top-left
local sg = mk(); E(sg, 40, 4, 26, 16); c:fillMask(sg, "#d8f0fa"); local sg2 = mk(); E(sg2, 40, 4, 15, 9); c:fillMask(sg2, "#ffffff")
-- clouds
local function cloud(cx, cy, w, h, seed)
  local m = mk()
  for i = 1, floor(w / 8) + 3 do
    local x = cx - w / 2 + H(i, seed, 1) * w
    local r = 6 + floor(H(i, seed, 2) * h)
    GX.disc(m, floor(x), floor(cy - r * .4 * H(i, seed, 3)), r, floor(r * .8))
  end
  for x = cx - w / 2 - 4, cx + w / 2 + 4 do for y = cy, cy + 5 do m:set(floor(x), y) end end   -- flat-ish belly
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#ffffff", base = "#f4fbff", shade = "#bcd8f0", deep = "#8cb4e0" }), { R = 10, tex = .3, sc = 4, seed = seed, ink = false, amb = .35 })
end
cloud(90, 40, 80, 12, 11); cloud(250, 28, 100, 14, 12); cloud(400, 70, 60, 9, 13); cloud(170, 82, 50, 8, 14); cloud(330, 44, 50, 8, 15)

-- far hills
GX.ground(c, function(x) return 112 + floor(7 * sin(x / 53 + 1) + 3 * sin(x / 17)) end, { hi = "#a8d8c0", base = "#8cc8b0", shade = "#74b0a4", deep = "#5c9098" }, 5, { top = .7, fall = .2, tex = .2 })
-- windmill on far hill
do
  local wx, wy = 214, 112
  local body = c:poly{ { wx - 6, wy + 6 }, { wx + 6, wy + 6 }, { wx + 3, wy - 18 }, { wx - 3, wy - 18 } }
  GX.lit(c, body, GX.ramp6({ hi = "#f4ece0", base = "#dccfc4", shade = "#b0a4b0", deep = "#807890" }), { R = 4, tex = .1, ink = "#6a6488" })
  local roof = c:poly{ { wx - 4, wy - 18 }, { wx + 4, wy - 18 }, { wx, wy - 24 } }
  GX.lit(c, roof, GX.ramp6({ hi = "#e88a6c", base = "#c8584c", shade = "#9a4048", deep = "#6a2c3c" }), { R = 3, tex = 0, ink = "#6a2c3c" })
  local sail = "#6a6488"
  for k = 0, 3 do
    local a = (k * 90 + 25) / 57.3
    for t = 2, 17 do c:px(wx + floor(t * cos(a) + .5), wy - 16 + floor(t * sin(a) + .5), sail) end
    for t = 7, 16 do local ox, oy = -sin(a), cos(a); c:px(wx + floor(t * cos(a) + ox * 2 + .5), wy - 16 + floor(t * sin(a) + oy * 2 + .5), "#f4ece0") end
  end
end
-- mid hill with fence
GX.ground(c, function(x) return 128 + floor(6 * sin(x / 41 + 3) + 2 * sin(x / 13)) end, { hi = "#cdf090", base = "#a8dc68", shade = "#80c058", deep = "#5ea060" }, 6, { top = .78, fall = .3, tex = .3 })
for fx = 250, 340, 18 do
  local fy = 127 + floor(6 * sin(fx / 41 + 3))
  c:fillMask(c:rect(fx, fy - 8, fx + 1, fy), "#8a6a58")
end
for fx = 250, 340 do local fy = 127 + floor(6 * sin(fx / 41 + 3)); c:px(fx, fy - 6, "#a8826a"); c:px(fx, fy - 3, "#a8826a") end
-- distant tree clumps
for _, t in ipairs{ { 140, 118 }, { 160, 121 }, { 396, 125 }, { 30, 127 } } do
  local m = mk(); E(m, t[1], t[2], 9, 6); m = GX.rough(m, t[1], 1)
  GX.lit(c, m, GX.ramp6({ hi = "#8cd070", base = "#5aa860", shade = "#3e8858", deep = "#2a6a50" }), { R = 5, tex = .5, sc = 3, seed = t[1], ink = false })
end
-- front meadow
GX.ground(c, function(x) return 146 + floor(4 * sin(x / 23 + 2)) end, G, 7, { top = .88, fall = .64, tex = .3, sc = 8 })

-- oak (right), canopy
local function blocked(x, y) return (x < 156 and y > 115 and y < 215) or (x > 280 and x < 440 and y > 60 and y < 220) or (x > 430 and y < 215) end
GX.trunk(c, 452, 470, 40, 200, BARK, 21, { moss = GRN2 })
-- gnarled branch left
for t = 0, 26 do
  local bx, by = 452 - t, 82 - floor(t * .5 + 3 * sin(t / 4))
  for w = 0, 3 - floor(t / 10) do c:px(bx, by + w, t % 5 == 0 and BARK.shade or BARK.base) end
  c:px(bx, by - 1, INK); c:px(bx, by + 4 - floor(t / 10), INK)
end
local CAN = { GRN1, GRN2, { hi = "#d8f070", base = "#8cc850", shade = "#4e9c48", deep = "#2a6a44" } }
GX.foliage(c, 440, 34, 44, 22, CAN[2], 301)
GX.foliage(c, 466, 20, 34, 18, CAN[1], 302)
GX.foliage(c, 426, 62, 20, 9, CAN[3], 303)
GX.foliage(c, 470, 70, 24, 12, CAN[2], 304)

-- shadows on ground
for _, t in ipairs{ { 462, 205, 30, 5 }, { 80, 196, 48, 6 } } do
  local m = mk(); E(m, t[1], t[2], t[3], t[4]); m = GX.rough(m, t[1], 1); c:fillMask(m, GX.mix(G.shade, G.base, .35))
end
-- lighter patches
for i = 0, 9 do
  local x, y = 30 + floor(H(i, 51, 1) * 420), 156 + floor(H(i, 53, 1) * 90)
  if not blocked(x, y) then local m = mk(); E(m, x, y, 12 + i % 4 * 3, 3); m = GX.rough(m, i, 1); c:fillMask(m, GX.mix(G.hi, "#ffffd0", .25)) end
end
-- path of worn earth
do
  local m = mk()
  for y = 222, 262 do for x = 150, 330 do
    local cy = 244 + 8 * sin(x / 28)
    if abs(y - cy) < 5 + 3 * GX.vn(x, y, 9, 4) and H(x, y, 3) > .1 then m:set(x, y) end
  end end
  GX.lit(c, m, GX.ramp6({ hi = "#e8cc90", base = "#d0a868", shade = "#b08450", deep = "#8a6040" }), { R = 3, tex = .5, sc = 3, seed = 8, ink = false, amb = .5 })
end

-- tufts and flowers
for i = 0, 60 do
  local x, y = 6 + floor(H(i, 61, 1) * 470), 156 + floor(H(i, 63, 1) * 112)
  if not blocked(x, y) and not (x > 140 and x < 340 and y > 224 and y < 262) then
    GX.tuft(c, x, y, y > 214 and { hi = G.base, base = G.shade, shade = G.deep } or G)
  end
end
-- wildflower drifts
local drifts = { { 200, 166, 28 }, { 250, 190, 18 }, { 70, 236, 30 }, { 420, 236, 14 }, { 180, 252, 12 } }
for di, dr in ipairs(drifts) do
  local col = FL[1 + di % 5]
  for i = 0, dr[3] do
    local x = dr[1] + floor((H(i, di, 7) - .5) * 70); local y = dr[2] + floor((H(i, di, 8) - .5) * 20)
    if not blocked(x, y) and not (x > 150 and x < 330 and y > 226 and y < 262) then
      GX.flower(c, x, y, H(i, di, 9) < .75 and col or FL[1 + i % 6])
    end
  end
end
-- dandelion puffs
for i, p in ipairs{ { 168, 214 }, { 230, 206 }, { 60, 222 }, { 118, 250 }, { 270, 176 }, { 20, 190 } } do
  local x, y = p[1], p[2]
  for k = 1, 9 do c:px(x, y + k, "#3f9150") end
  local m = mk(); E(m, x, y, 4); m = GX.rough(m, i, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#ffffff", base = "#f4f4ee", shade = "#c8d0d8", deep = "#98a4b8" }), { R = 4, tex = .5, sc = 2, seed = i, ink = false })
  c:px(x - 5, y - 4, "#ffffff"); c:px(x + 5, y - 5, "#ffffff"); c:px(x + 6, y - 7, "#f4f4ee")
end

-- hay bale (hero, left)
do
  local bx, by, r = 74, 168, 34
  local m = mk(); E(m, bx, by, r, r - 2); m = GX.rough(m, 33, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#ffe98a", base = "#f0c04a", shade = "#cc8e34", deep = "#8a5a2a" }), { R = 26, tex = .4, sc = 2, seed = 31, rimlight = true,
    fn = function(x, y)
      local dd = sqrt((x - bx - 4) ^ 2 + (y - by) ^ 2)
      local ring = (floor(dd / 2.6) % 2) * .14 - .07
      local straw = (H(x, y // 2, 5) - .5) * .18
      return ring + straw
    end })
  -- twine bands
  for _, off in ipairs{ -14, 12 } do
    for y = by - r + 3, by + r - 5 do
      local dx = off
      local xx = bx + dx + floor((GX.vn(0, y, 6, 3) - .5) * 2)
      if m:has(xx, y) then c:px(xx, y, "#7a4a2c"); if m:has(xx + 1, y) then c:px(xx + 1, y, "#a8703c") end end
    end
  end
  -- loose straw
  for i = 0, 22 do
    local sx, sy = bx - 40 + floor(H(i, 77, 1) * 80), by + r - 6 + floor(H(i, 78, 1) * 8)
    local len = 3 + floor(H(i, 79, 1) * 4)
    for k = 0, len do c:px(sx + k, sy - floor(k * .3), k == 0 and "#cc8e34" or "#f0c04a") end
  end
  -- stalk in bale top
  for k = 0, 9 do c:px(bx + 8 + k, by - r + 3 - floor(k * .6), "#f0c04a") end
end

-- rabbit (quirk) sitting right of bale
do
  local rx, ry = 124, 196
  local RAB = GX.ramp6({ hi = "#e8d4b8", base = "#c4a07a", shade = "#9a7458", deep = "#6a4a40" })
  local b = mk(); E(b, rx, ry - 6, 7, 6); GX.lit(c, b, RAB, { R = 6, tex = .3, sc = 2, seed = 41, rimlight = true })
  local hd = mk(); E(hd, rx + 4, ry - 14, 4, 4); GX.lit(c, hd, RAB, { R = 4, tex = .1, seed = 42, rimlight = true })
  local e1 = c:poly{ { rx + 2, ry - 17 }, { rx + 4, ry - 17 }, { rx + 3, ry - 26 } }
  GX.lit(c, e1, RAB, { R = 2, tex = 0 })
  local e2 = c:poly{ { rx + 5, ry - 17 }, { rx + 7, ry - 17 }, { rx + 8, ry - 25 } }
  GX.lit(c, e2, RAB, { R = 2, tex = 0 })
  c:px(rx + 3, ry - 22, "#f0a0a0"); c:px(rx + 7, ry - 21, "#f0a0a0")
  c:px(rx + 6, ry - 15, INK); c:px(rx + 8, ry - 13, "#f0a0a0")
  c:fillMask(c:rect(rx - 8, ry - 7, rx - 6, ry - 5), "#fff4ee"); c:px(rx - 9, ry - 6, INK)
  c:fillMask(c:rect(rx + 2, ry - 1, rx + 6, ry), RAB[3]); c:px(rx + 7, ry, INK)
  -- carrot-top dandelion in paws
  c:px(rx + 8, ry - 9, "#ffd470"); c:px(rx + 9, ry - 9, "#ffd470")
end

-- tall seed-head grasses at edges
local function stalk(x, y, h, lean, seed)
  local col = H(seed, 1, 1) < .5 and "#3a9048" or "#58b040"
  local px, py = x, y
  for t = 0, h do
    px = x + floor(lean * (t / h) ^ 2 * 6 + .5); py = y - t
    c:px(px, py, col)
    if t % 9 == 4 then c:px(px + (lean >= 0 and 1 or -1), py - 1, col); c:px(px + (lean >= 0 and 2 or -2), py - 2, col) end
  end
  for k = 0, 6 do
    local hx, hy = px + floor(lean * k * .25), py - k
    c:px(hx, hy, k % 2 == 0 and "#e8c060" or "#c89040"); c:px(hx + 1, hy, k % 2 == 0 and "#c89040" or "#f4dc90")
    if k > 1 then c:px(hx - 1, hy + 1 - k % 2, "#e8c060") end
  end
  c:px(px, py - 7, "#f4dc90")
end
for i = 0, 26 do
  local x = floor(H(i, 91, 1) * 20) + (i % 2) * 2
  stalk(x, 252 + floor(H(i, 92, 1) * 18), 50 + floor(H(i, 93, 1) * 50), 1.5 + H(i, 94, 1) * 1.5, i)
end
for i = 0, 16 do
  local x = 440 + floor(H(i, 95, 1) * 40)
  stalk(x, 240 + floor(H(i, 96, 1) * 30), 28 + floor(H(i, 97, 1) * 30), -1.5 - H(i, 98, 1) * 1.5, i + 50)
end
for i = 0, 8 do   -- some in the left mid area, low
  local x = 150 + floor(H(i, 99, 1) * 12)
  stalk(x, 200 + floor(H(i, 100, 1) * 30), 24 + floor(H(i, 101, 1) * 20), 1.2, i + 80)
end

-- butterflies
for _, b in ipairs{ { 190, 150, "#ff9fc0" }, { 262, 136, "#ffd470" }, { 40, 120, "#a0c8ff" } } do
  local x, y, col = b[1], b[2], b[3]
  c:fillMask(c:rect(x - 3, y - 2, x - 1, y), col); c:fillMask(c:rect(x + 1, y - 2, x + 3, y), col)
  c:fillMask(c:rect(x - 2, y + 1, x - 1, y + 2), GX.mix(col, "#000000", .2)); c:fillMask(c:rect(x + 1, y + 1, x + 2, y + 2), GX.mix(col, "#000000", .2))
  c:px(x, y - 1, INK); c:px(x, y, INK)
end
-- small meadowlark bird in the sky
for _, b in ipairs{ { 120, 100 }, { 134, 94 } } do
  c:px(b[1] - 2, b[2], INK); c:px(b[1] - 1, b[2] - 1, INK); c:px(b[1], b[2], INK); c:px(b[1] + 1, b[2] - 1, INK); c:px(b[1] + 2, b[2], INK)
end

-- contact shadow for satchel
local sh = mk(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, "#2a7a44")

c:save{ aseprite = d.."/../out/scene-grassland.aseprite", png = d.."/../out/scene-grassland.png", scale = 1 }

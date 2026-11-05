-- Gnome Venture "Hearth Pop" v3 - here-gate place: Camp rest stop (gate view, hero scale, dusk)
-- Run: AppRun -b --script-param out=<dir>/ --script here-stop-camp.lua
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/tmp/"
local W, H, HZ = 480, 270, 112
local NAME = "here-stop-camp"
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, cos, abs, max, min, pi = math.floor, math.sin, math.cos, math.abs, math.max, math.min, math.pi
local function hsh(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end

-- ramps {hi, base, shade, deep}
local LOG    = { "#c98e5e", "#9a6440", "#6e4432", "#46282a" }
local WOOD   = { "#e8b982", "#b97a4a", "#864c33", "#51302b" }
local PLANK  = { "#e89a78", "#b8604a", "#8a4440", "#5a2c34" }
local ENDW   = { "#f6d6a0", "#e2b47c", "#c08a5a", "#7a4a34" }
local BIRCH  = { "#f6f0e4", "#ddd5c8", "#b0a6ae", "#5e4e62" }
local STONE  = { "#e2e0e6", "#aaa9b8", "#74758c", "#444663" }
local IRON   = { "#8c8aa8", "#5e5c7c", "#45435e", "#2c2a40" }
local EMBER  = { "#ff8a5c", "#e8493b", "#b52e3f", "#6e2038" }
local GOLD   = { "#ffe38a", "#f5b82e", "#d98322", "#8f4a1f" }
local MOSS   = { "#c4e07a", "#7cc35a", "#3f9150", "#24544a" }
local SEA    = { "#b6f0e0", "#5fc4c8", "#3a86b0", "#2a4a7a" }
local PETAL  = { "#ffc4d8", "#f5809f", "#c94f84", "#7d2c5e" }
local CANVAS = { "#fff0d2", "#efd6a8", "#c9a47a", "#7a5a48" }
local TEAL   = { "#bfe6d8", "#86c2b4", "#5a8e8e", "#2f5258" }
local CREAM  = { "#fff4dc", "#f2e2c2", "#d2bc9c", "#8a7062" }
local PINE   = { "#6f9a6a", "#4a7558", "#355a4a", "#1e3838" }
local FARP   = { "#8a7eb4", "#6c6498", "#55507e", "#3c3862" }
local NEARP  = { "#5a8466", "#3e6252", "#2c4a44", "#1a2e34" }
local DIRT   = { "#d0a070", "#b08058", "#8e6248", "#6a4840" }
local DIRTW  = { "#f0c486", "#cc965e", "#a2704c", "#6a4840" }
local GR     = { "#86aa5c", "#628c52", "#4a6e4c", "#30503f" }
local GRF    = { "#6f8c62", "#567456", "#44604e", "#2e4640" }
local GLOW   = { "#fff6c8", "#ffd27a", "#f5a84a", "#c8743e" }

-- object painter: rim in its own deep tone, lit edge upper-left, shade band lower-right, optional texture
local function obj(m, r, o)
  o = o or {}
  if o.edge ~= false then c:rim(m, o.edge or r[4], o.clip) end
  local lw, sw = o.lit or 1, o.sh or 2
  m:each(function(x, y)
    local i = 2
    for k = 1, lw do if not m:has(x - k, y) or not m:has(x, y - k) then i = 1 end end
    for k = 1, sw do if not m:has(x + k, y) or not m:has(x, y + k) then i = 3 end end
    if o.tex then i = o.tex(x, y, i) or i end
    c:put(x, y, r[i])
  end)
  return m
end
local function poly(p) return c:poly(p) end

-- ground type for shadows
local gt = {}
local function shadow(m)
  local core = m:shrink(1)
  m:each(function(x, y)
    if x < 0 or y < 0 or x >= W or y >= H then return end
    local t, inner = gt[y * W + x], core:has(x, y)
    if t == "d" then c:put(x, y, inner and "#6e4c52" or "#8a6054")
    elseif t == "g" then c:put(x, y, inner and "#2c4244" or "#3a5448") end
  end)
end

-------------------------------------------------------------- SKY (dusk)
c:stripes(0, HZ - 1, { "#2f2656", "#3d2f6e", "#55408a", "#77509a", "#a05a98", "#cc6a8c", "#ea8a7c", "#f6a874", "#fbc884" },
  { 3, 3, 3, 3, 2, 2, 2, 2, 2 })
for _, s in ipairs({ { 70, 22 }, { 150, 30 }, { 206, 18 }, { 300, 24 }, { 352, 34 }, { 410, 20 }, { 120, 44 }, { 262, 40 } }) do
  c:put(s[1], s[2], "#fff4dc")
end
c:sparkle(176, 24); c:sparkle(332, 18); c:sparkle(96, 34)
c:cloud(36, 62, 46, "#e89aa8", "#9a6a9e")
c:cloud(150, 50, 36, "#f2a8a8", "#a86e9e")
c:cloud(300, 58, 52, "#f2a8a8", "#a86e9e")
c:cloud(396, 44, 34, "#e89aa8", "#9a6a9e")
-- far hills
c:terrain(function(x) return floor(84 + 7 * sin(x / 41) + 4 * sin(x / 13 + 1)) end, "#7a62a6", HZ)
c:terrain(function(x) return floor(94 + 5 * sin(x / 29 + 2) + 3 * sin(x / 9)) end, "#5e4c8e", HZ)
-- hill rim light (warm sunset edge on left facing slopes)
for x = 0, W - 1 do
  local y1 = floor(84 + 7 * sin(x / 41) + 4 * sin(x / 13 + 1))
  if floor(84 + 7 * sin((x + 1) / 41) + 4 * sin((x + 1) / 13 + 1)) <= y1 then c:put(x, y1, "#c98aa8") end
end

-------------------------------------------------------------- GROUND
local path  = poly{ { 233, HZ }, { 247, HZ }, { 342, 269 }, { 138, 269 } }
local clear = poly{ { 150, 156 }, { 176, 138 }, { 214, 130 }, { 266, 130 }, { 306, 138 }, { 334, 156 }, { 340, 180 }, { 320, 200 }, { 240, 210 }, { 162, 200 }, { 144, 180 } }
local trail = poly{ { 316, 196 }, { 400, 198 }, { 466, 202 }, { 466, 216 }, { 404, 220 }, { 330, 224 } }
local dirt = path:copy():add(clear):add(trail)
for y = HZ, H - 1 do
  local far = (y - HZ) / (H - HZ)
  for x = 0, W - 1 do
    local n = hsh(x, y, 3)
    if dirt:has(x, y) then
      gt[y * W + x] = "d"
      local dx, dy = (x - 240) / 104, (y - 172) / 40
      local d = dx * dx + dy * dy
      local r = d < 0.5 and DIRTW or DIRT
      local col = r[2]
      if n > 0.92 then col = r[1] elseif n < 0.09 then col = r[3] end
      c:put(x, y, col)
    else
      gt[y * W + x] = "g"
      local r = far < 0.18 and GRF or GR
      local p = sin(x / 11 + y / 4) + sin(x / 27 - y / 7) + (hsh(floor(x / 3), floor(y / 2), 1) - 0.5)
      local col = r[2]
      if p < -0.9 then col = r[3] elseif p > 1.3 then col = r[1] end
      if n > 0.96 then col = r[1] elseif n < 0.05 then col = r[3] end
      c:put(x, y, col)
    end
  end
end
-- soft dirt border
dirt:edge():each(function(x, y) if y > HZ and x > 0 and x < W - 1 and y < H - 1 then c:put(x, y, DIRT[3]) end end)
-- wheel ruts toward the vanishing point
for _, rt in ipairs({ { 196, 238 }, { 284, 242 } }) do
  for y = 140, 268 do
    local t = (y - HZ) / (269 - HZ)
    local x = floor(rt[2] + (rt[1] - rt[2]) * t + 0.5)
    if path:has(x, y) and hsh(x, y, 4) > 0.25 then c:put(x, y, DIRT[3]) end
  end
end
-- pebbles on the dirt
math.randomseed(11)
for _ = 1, 90 do
  local x, y = math.random(140, 340), math.random(130, 266)
  if dirt:has(x, y) and dirt:has(x + 2, y + 1) then
    local s = y > 200 and 2 or 1
    c:put(x, y, "#e6d6c6"); c:put(x + 1, y, "#b8a8a8")
    if s == 2 then c:put(x, y + 1, "#b8a8a8"); c:put(x + 1, y + 1, "#7a6a72") end
  end
end
-- grass tufts
for _ = 1, 700 do
  local x, y = math.random(16, 463), math.random(HZ + 6, 266)
  if gt[y * W + x] == "g" then
    local s = 1 + floor((y - HZ) / 52)
    for k = 0, s do
      c:put(x, y - k, GR[1]); c:put(x - 1 - floor(k / 2), y - k + 1, GR[1]); c:put(x + 1 + floor(k / 2), y - k + 1, GR[2])
    end
    c:put(x, y + 1, GR[3])
  end
end

-------------------------------------------------------------- FOREST EDGE
local TRUNK = { "#8a6a5a", "#6a4c48", "#4e3640", "#32242e" }
local function pine(cx, base, h, w, r)
  local m = HP.mask()
  local tiers = 4
  for t = 0, tiers - 1 do
    local top = base - h + floor(t * h / (tiers + 0.6))
    local bot = top + floor(h * 0.42)
    local hw = floor(w * (0.35 + 0.65 * (t + 1) / tiers) / 2)
    m:add(c:poly{ { cx, top }, { cx + hw, bot }, { cx - hw, bot } })
  end
  local tr = c:rect(cx - 1, base - 6, cx + 1, base)
  obj(tr, TRUNK, { lit = 0, sh = 1 })
  m:cut(c:rect(cx - 30, base - 3, cx + 30, base + 8))
  obj(m, r, { lit = 1, sh = 2, tex = function(x, y, i)
    if i == 2 and (x + y * 2) % 7 == 0 and hsh(x, y, 9) > 0.3 then return 3 end
    if i == 2 and hsh(x, y, 8) > 0.9 then return 1 end
  end })
end
-- far violet pines
local x = 18
while x < 466 do
  if x < 218 or x > 262 then pine(x, 110 - floor(hsh(x, 1, 2) * 3), 24 + floor(hsh(x, 2, 2) * 14), 18, FARP) end
  x = x + 15 + floor(hsh(x, 3, 3) * 6)
end
-- near forest pines
x = 22
while x < 462 do
  if x < 208 or x > 272 then pine(x, 119 + floor(hsh(x, 4, 2) * 3), 42 + floor(hsh(x, 5, 2) * 24), 28, NEARP) end
  x = x + 24 + floor(hsh(x, 6, 3) * 8)
end
-- tunnel in the trees where the road runs on, with a far-away lantern
local tun = poly{ { 228, 112 }, { 233, 100 }, { 247, 100 }, { 252, 112 } }
c:fillMask(tun, "#3a3058")
c:put(240, 104, GOLD[1]); c:put(240, 105, GOLD[2]); c:put(239, 105, GOLD[3]); c:put(241, 105, GOLD[3])

-------------------------------------------------------------- WOODPILE (deco, back left)
shadow(poly{ { 120, 127 }, { 186, 127 }, { 190, 132 }, { 116, 132 } })
obj(c:rect(122, 100, 125, 128), WOOD, { lit = 1, sh = 1 })
obj(c:rect(165, 100, 168, 128), WOOD, { lit = 1, sh = 1 })
obj(poly{ { 118, 98 }, { 172, 98 }, { 168, 94 }, { 122, 94 } }, PLANK, { sh = 1 })
local rows = { { 127, 6 }, { 120, 6 }, { 113, 5 }, { 106, 4 } }
for ri, rw in ipairs(rows) do
  local n = rw[2]
  local x0 = 145 - floor(n * 7 / 2)
  for k = 0, n - 1 do
    local lx = x0 + k * 7
    local lm = c:rrect(lx, rw[1] - 6, lx + 6, rw[1], 2)
    obj(lm, ENDW, { lit = 1, sh = 1, edge = LOG[3], tex = function(px, py, i)
      if px == lx + 3 and py == rw[1] - 3 then return 3 end
      if (px == lx + 2 or px == lx + 4) and (py == rw[1] - 4 or py == rw[1] - 2) and i == 2 then return 3 end
    end })
  end
end
-- chopping block with a hatchet (quirk: hatchet left in the block)
shadow(poly{ { 172, 128 }, { 188, 128 }, { 188, 131 }, { 172, 131 } })
obj(c:rect(174, 118, 185, 128), LOG, { tex = function(px, py, i) if (px + py) % 4 == 0 and i == 2 then return 3 end end })
obj(c:rect(174, 116, 185, 118), ENDW, { lit = 1, sh = 0, edge = LOG[4] })
obj(c:line({ { 176, 116 }, { 170, 106 } }, 2), WOOD, { lit = 0, sh = 1 })
obj(poly{ { 176, 112 }, { 184, 112 }, { 185, 117 }, { 178, 117 } }, STONE, { lit = 1, sh = 1 })

-------------------------------------------------------------- HOMES: two canvas tents (back right)
local function tent(ax, ay, x0, x1, by, r, door)
  shadow(poly{ { x0 - 2, by - 1 }, { x1 + 8, by - 1 }, { x1 + 14, by + 5 }, { x0 + 4, by + 5 } })
  -- guy ropes + pegs
  for _, g in ipairs({ { ax - floor((ax - x0) * 0.55), ay + floor((by - ay) * 0.5), x0 - 9, by + 2 },
                       { ax + floor((x1 - ax) * 0.55), ay + floor((by - ay) * 0.5), x1 + 9, by + 2 } }) do
    c:fillMask(c:line({ { g[1], g[2] }, { g[3], g[4] } }, 1), "#d8c49a")
    obj(c:rect(g[3] - 1, g[4] - 3, g[3], g[4] + 1), WOOD, { lit = 0, sh = 1 })
  end
  -- ridge pole tip
  obj(c:rect(ax - 1, ay - 7, ax + 1, ay + 2), WOOD, { lit = 0, sh = 1 })
  local m = poly{ { ax, ay }, { x1, by }, { x0, by } }
  obj(m, r, { lit = 2, sh = 3, tex = function(px, py, i)
    -- seams fanning from the apex
    local t = (py - ay) / max(1, by - ay)
    for _, f in ipairs({ -0.62, -0.3, 0.3, 0.62 }) do
      local sx = ax + f * (ax - x0) * t
      if abs(px - sx) < 0.6 and i == 2 then return 3 end
    end
    if py > by - 8 and py < by - 4 and r == CANVAS then return nil end
    if i == 2 and hsh(px, py, 12) > 0.94 then return 1 end
  end })
  return m
end
-- tent A (cream canvas, red hem, open glowing door)
local ta = tent(334, 68, 298, 368, 148, CANVAS)
local hem = poly{ { 298, 140 }, { 368, 140 }, { 368, 146 }, { 298, 146 } }:clip(ta)
obj(hem, EMBER, { edge = false, lit = 0, sh = 1, tex = function(px, py, i) if (px // 3) % 2 == 0 and i == 2 then return 1 end end })
local door = poly{ { 334, 94 }, { 349, 147 }, { 319, 147 } }
obj(door, GLOW, { edge = CANVAS[4], lit = 0, sh = 0, tex = function(px, py, i)
  if py > 136 then return 4 elseif py > 128 then return 3 elseif py < 108 then return 1 end
end })
obj(c:rect(326, 138, 342, 145), PETAL, { lit = 1, sh = 1 }) -- bedroll inside
obj(poly{ { 333, 96 }, { 319, 147 }, { 312, 147 }, { 330, 98 } }, CANVAS, { lit = 0, sh = 1 }) -- tied-back flaps
obj(poly{ { 335, 96 }, { 349, 147 }, { 356, 147 }, { 338, 98 } }, CANVAS, { lit = 0, sh = 1 })
c:put(318, 120, GOLD[2]); c:put(318, 121, GOLD[2]); c:put(350, 120, GOLD[2]); c:put(350, 121, GOLD[2]) -- tie toggles
-- homes icon: little pennant on tent A pole
obj(poly{ { 336, 61 }, { 348, 64 }, { 336, 67 } }, PETAL, { lit = 1, sh = 1 })
-- tent B (teal canvas, laced door, patch quirk)
local tb = tent(426, 74, 392, 458, 150, TEAL)
for py = 100, 148, 6 do
  local t = (py - 74) / 76
  c:put(426, py, TEAL[4]); c:put(425, py + 1, "#d8c49a"); c:put(427, py + 1, "#d8c49a")
end
c:fillMask(c:line({ { 426, 92 }, { 426, 149 } }, 1), TEAL[3])
local patch = c:rect(438, 116, 447, 125)
obj(patch, PETAL, { lit = 1, sh = 1 })
for k = 0, 9, 2 do c:put(438 + k, 115, CREAM[1]); c:put(438 + k, 126, CREAM[1]) end
obj(poly{ { 428, 66 }, { 438, 69 }, { 428, 72 } }, GOLD, { lit = 1, sh = 1 })
-- lantern pole between the tents, with a little birdhouse and a clothesline
shadow(poly{ { 376, 153 }, { 392, 153 }, { 394, 156 }, { 378, 156 } })
obj(c:rect(378, 88, 381, 155), LOG, { lit = 1, sh = 1, tex = function(px, py, i) if py % 6 == 0 and i == 2 then return 3 end end })
obj(c:rect(366, 88, 381, 90), LOG, { lit = 0, sh = 1 })
c:fillMask(c:line({ { 369, 91 }, { 369, 95 } }, 1), IRON[4])
obj(poly{ { 363, 96 }, { 369, 92 }, { 375, 96 } }, IRON, { lit = 1, sh = 1 })
obj(c:rect(364, 97, 374, 108), IRON, { lit = 0, sh = 0 })
obj(c:rect(366, 98, 372, 106), GLOW, { edge = false, lit = 1, sh = 1 })
c:put(369, 101, GLOW[1]); c:put(369, 102, "#fffbe8")
obj(c:rect(363, 109, 375, 110), IRON, { lit = 0, sh = 0 })
-- birdhouse (quirk)
obj(poly{ { 374, 118 }, { 380, 112 }, { 386, 118 } }, EMBER, { lit = 1, sh = 1 })
obj(c:rect(375, 119, 385, 128), SEA, { lit = 1, sh = 1 })
c:fillMask(c:rect(379, 122, 381, 124), SEA[4])
-- clothesline to tent B with a drying sock (quirk)
c:fillMask(c:line({ { 382, 96 }, { 396, 100 }, { 412, 96 } }, 1), "#d8c49a")
obj(poly{ { 396, 100 }, { 401, 100 }, { 401, 110 }, { 405, 112 }, { 405, 116 }, { 397, 116 }, { 396, 110 } }, PETAL, { lit = 1, sh = 1,
  tex = function(px, py, i) if py == 104 or py == 105 then return 1 end end })
c:put(397, 99, WOOD[2]); c:put(400, 99, WOOD[2])

-------------------------------------------------------------- STOP: roofed notice board + stamp post (back left)
shadow(poly{ { 26, 142 }, { 116, 142 }, { 124, 148 }, { 32, 148 } })
obj(c:rect(30, 86, 35, 145), WOOD, { tex = function(px, py, i) if (py * 3 + px) % 9 == 0 and i == 2 then return 3 end end })
obj(c:rect(100, 86, 105, 145), WOOD, { tex = function(px, py, i) if (py * 3 + px) % 9 == 0 and i == 2 then return 3 end end })
local board = c:rect(37, 92, 99, 122)
obj(board, WOOD, { lit = 2, sh = 2 })
obj(c:rect(40, 95, 96, 119), { "#e2b88a", "#c89a6a", "#a8784e", "#6a4834" }, { edge = WOOD[4], lit = 0, sh = 1,
  tex = function(px, py, i) local n = hsh(px, py, 21) if n > 0.85 then return 3 elseif n < 0.1 then return 1 end end })
-- pinned notes: a sketch map, a tent card, a pink note
obj(c:rect(43, 97, 60, 113), CREAM, { lit = 0, sh = 1 })
c:fillMask(c:line({ { 45, 110 }, { 49, 104 }, { 53, 106 }, { 58, 99 } }, 1), SEA[3])
c:fillMask(c:rect(46, 100, 48, 102), MOSS[3]); c:fillMask(c:rect(54, 108, 57, 110), MOSS[3])
c:put(58, 100, EMBER[2]); c:put(57, 99, EMBER[2])
obj(c:rect(64, 99, 78, 116), CREAM, { lit = 0, sh = 1 })
c:fillMask(poly{ { 71, 103 }, { 76, 112 }, { 66, 112 } }, TEAL[3]); c:fillMask(c:rect(70, 108, 72, 112), GLOW[2])
obj(c:rect(82, 97, 94, 109), PETAL, { lit = 0, sh = 1 })
c:fillMask(c:rect(85, 101, 91, 101), PETAL[4]); c:fillMask(c:rect(85, 104, 89, 104), PETAL[4])
for _, p in ipairs({ { 51, 97 }, { 71, 99 }, { 88, 97 } }) do c:put(p[1], p[2], GOLD[1]); c:put(p[1], p[2] + 1, GOLD[3]) end
-- stamp shelf
obj(c:rect(38, 129, 98, 133), WOOD, { lit = 1, sh = 1 })
obj(c:rect(42, 125, 62, 128), SEA, { lit = 1, sh = 1 })                 -- ink pad
obj(c:rect(72, 120, 80, 128), EMBER, { lit = 1, sh = 1 })               -- big red stamp
obj(c:rect(74, 114, 78, 119), WOOD, { lit = 1, sh = 1 })
obj(c:rect(72, 110, 80, 113), EMBER, { lit = 1, sh = 1 })
obj(c:rect(86, 124, 94, 128), CREAM, { lit = 0, sh = 1 })               -- stamp card
c:fillMask(c:rect(88, 125, 92, 127), EMBER[3])
-- shingled roof
local roof = poly{ { 22, 90 }, { 34, 76 }, { 102, 76 }, { 114, 90 } }
obj(roof, EMBER, { lit = 1, sh = 2, tex = function(px, py, i)
  if (py - 76) % 4 == 3 then return 3 end
  if i == 2 and ((px + floor((py - 76) / 4) * 4) % 8 == 0) then return 3 end
  if i == 2 and (py - 76) % 4 == 0 then return 1 end
end })
-- stop icon plaque on the ridge: a stamp silhouette
obj(c:rrect(56, 63, 80, 77, 2), CREAM, { edge = WOOD[4], lit = 1, sh = 1 })
c:fillMask(c:rect(66, 65, 70, 68), EMBER[2]); c:fillMask(c:rect(67, 69, 69, 70), EMBER[3])
c:fillMask(c:rect(62, 71, 74, 74), EMBER[2]); c:fillMask(c:rect(62, 74, 74, 74), EMBER[3])
-- lantern hanging under the roof edge
c:put(108, 91, IRON[4]); c:put(108, 92, IRON[4])
obj(c:rect(105, 93, 111, 101), GLOW, { edge = IRON[4], lit = 1, sh = 1 })

-------------------------------------------------------------- DO: fire ring, flames, tripod kettle (centre)
local FX, FY = 240, 174
local back, front = {}, {}
for k = 0, 17 do
  local a = k / 18 * 2 * pi
  local s = { x = floor(FX + 47 * cos(a) + 0.5), y = floor(FY + 13 * sin(a) + 0.5), sn = sin(a) }
  if s.sn < 0 then back[#back + 1] = s else front[#front + 1] = s end
end
local function stone(s)
  local wv = s.sn > 0 and 6 or 4
  local hv = s.sn > 0 and 4 or 3
  obj(c:rrect(s.x - wv, s.y - hv, s.x + wv, s.y + hv, 2), STONE, { lit = 1, sh = 1,
    tex = function(px, py, i) if i == 2 and hsh(px, py, 31) > 0.85 then return 3 end end })
end
shadow(poly{ { 186, 182 }, { 296, 182 }, { 290, 192 }, { 192, 192 } })
for _, s in ipairs(back) do stone(s) end
c:fillMask(c:ellipse(FX, FY, 42, 10), "#4a3a4a")
for _ = 1, 60 do
  local px, py = math.random(202, 278), math.random(166, 182)
  if c:get(px, py) == "#4a3a4a" then c:put(px, py, hsh(px, py, 7) > 0.5 and EMBER[3] or "#6a4a54") end
end
-- crossed logs
obj(c:line({ { 214, 180 }, { 262, 168 } }, 5), LOG, { lit = 1, sh = 1 })
obj(c:line({ { 266, 180 }, { 218, 168 } }, 5), LOG, { lit = 1, sh = 1 })
-- flames
local fl = { { 212, 178 }, { 216, 162 }, { 221, 150 }, { 226, 160 }, { 229, 144 }, { 236, 156 }, { 241, 134 }, { 248, 152 }, { 255, 142 }, { 258, 160 }, { 264, 150 }, { 268, 178 } }
local function scaled(p, sx, sy) local o = {} for i, v in ipairs(p) do o[i] = { floor(FX + (v[1] - FX) * sx + 0.5), floor(178 + (v[2] - 178) * sy + 0.5) } end return o end
obj(poly(fl), EMBER, { edge = EMBER[4], lit = 1, sh = 1 })
c:fillMask(poly(scaled(fl, 0.72, 0.74)), GOLD[2])
c:fillMask(poly(scaled(fl, 0.45, 0.45)), GOLD[1])
c:fillMask(poly(scaled(fl, 0.22, 0.22)), "#fff6c8")
-- tripod
obj(c:line({ { 240, 116 }, { 195, 188 } }, 3), WOOD, { lit = 1, sh = 1 })
obj(c:line({ { 240, 116 }, { 285, 188 } }, 3), WOOD, { lit = 1, sh = 1 })
obj(c:rect(236, 115, 244, 119), GOLD, { edge = GOLD[4], lit = 0, sh = 1, tex = function(px, py, i) if (px + py) % 3 == 0 then return 3 end end })
-- chain + bail
for y = 120, 126 do c:put(240, y, (y % 2 == 0) and STONE[2] or STONE[4]) end
c:fillMask(c:line({ { 226, 144 }, { 229, 132 }, { 240, 127 }, { 251, 132 }, { 254, 144 } }, 1), IRON[4])
-- kettle (do icon)
obj(c:line({ { 255, 150 }, { 261, 145 }, { 265, 138 } }, 3), IRON, { lit = 1, sh = 1 })
local pot = c:rrect(224, 140, 256, 163, 7)
obj(pot, IRON, { lit = 2, sh = 3, tex = function(px, py, i)
  if py == 147 and i ~= 3 then return 1 end
  if py == 148 then return 3 end
end })
c:put(229, 144, "#d8d6ea"); c:put(230, 144, "#d8d6ea"); c:put(229, 145, IRON[1])
obj(c:rrect(229, 135, 251, 140, 2), IRON, { lit = 1, sh = 1 })
obj(c:rect(237, 131, 243, 134), GOLD, { lit = 1, sh = 1 })
-- flames licking the pot sides
obj(poly{ { 220, 164 }, { 223, 152 }, { 227, 160 } }, GOLD, { edge = EMBER[3], lit = 1, sh = 0 })
obj(poly{ { 253, 160 }, { 258, 150 }, { 261, 164 } }, GOLD, { edge = EMBER[3], lit = 1, sh = 0 })
-- steam from the spout (quirk: it curls into a little puff train)
for _, p in ipairs({ { 268, 132, 3 }, { 273, 125, 4 }, { 280, 118, 3 } }) do
  obj(c:rrect(p[1] - p[3], p[2] - p[3] + 1, p[1] + p[3], p[2] + p[3] - 1, 2), { "#fbf6ff", "#e8e0f0", "#c8bcd8", "#9a8cb4" }, { lit = 1, sh = 1 })
end
-- front stones
for _, s in ipairs(front) do stone(s) end
-- marshmallow on a stick propped on the ring (quirk)
obj(c:line({ { 280, 184 }, { 291, 165 } }, 1), WOOD, { lit = 0, sh = 0 })
obj(c:rrect(289, 159, 294, 165, 1), CREAM, { lit = 1, sh = 1, tex = function(px, py, i) if py <= 160 then return 3 end end })
-- embers
for _, p in ipairs({ { 232, 128 }, { 252, 124 }, { 222, 138 }, { 260, 132 } }) do c:put(p[1], p[2], GOLD[1]) end
c:put(214, 132, EMBER[1])

-------------------------------------------------------------- WILD: side trail through a leafy arch + arrow signpost (right)
local wbg = poly{ { 410, 174 }, { 432, 164 }, { 456, 174 }, { 463, 202 }, { 412, 202 } }
c:fillMask(wbg, "#2c4a44")
c:fillMask(wbg:copy():clip(poly{ { 412, 182 }, { 463, 174 }, { 463, 196 }, { 412, 200 } }), "#3a5e4c")
for _ = 1, 50 do
  local px, py = math.random(412, 462), math.random(166, 200)
  if wbg:has(px, py) then c:put(px, py, "#4a7a58") end
end
c:fillMask(poly{ { 418, 202 }, { 463, 199 }, { 463, 204 }, { 418, 206 } }, DIRT[3])
local BARK = { "#a8806a", "#7a5848", "#5a3e3c", "#3a2630" }
obj(c:line({ { 404, 224 }, { 405, 196 }, { 412, 174 }, { 424, 162 }, { 434, 158 } }, 5), BARK, { lit = 1, sh = 2 })
obj(c:line({ { 460, 226 }, { 459, 196 }, { 453, 174 }, { 444, 162 }, { 434, 158 } }, 5), BARK, { lit = 1, sh = 2 })
for _, b in ipairs({ { 404, 182, 9, 7 }, { 412, 166, 10, 7 }, { 426, 156, 11, 6 }, { 442, 156, 10, 6 }, { 454, 168, 9, 7 }, { 460, 186, 6, 8 } }) do
  obj(c:rrect(b[1] - b[3], b[2] - b[4], b[1] + b[3], b[2] + b[4], 4), MOSS, { lit = 1, sh = 2, tex = function(px, py, i)
    if i == 2 and (px + py * 2) % 5 == 0 then return 3 end
    if i == 2 and hsh(px, py, 41) > 0.9 then return 1 end
  end })
end
for _, f in ipairs({ { 402, 178 }, { 416, 160 }, { 430, 152 }, { 446, 154 }, { 458, 168 }, { 411, 172 } }) do
  c:put(f[1], f[2], SEA[1]); c:put(f[1] + 1, f[2], SEA[2]); c:put(f[1], f[2] + 1, SEA[2])
end
-- signpost
shadow(poly{ { 404, 222 }, { 424, 222 }, { 428, 226 }, { 408, 226 } })
obj(c:rect(410, 182, 414, 224), WOOD, { tex = function(px, py, i) if py % 5 == 0 and i == 2 then return 3 end end })
local arrow = poly{ { 398, 186 }, { 428, 186 }, { 436, 192 }, { 428, 198 }, { 398, 198 } }
obj(arrow, SEA, { lit = 1, sh = 2, tex = function(px, py, i) if py == 192 and px > 402 and px < 428 and i == 2 then return 1 end end })
c:fillMask(c:rect(403, 190, 405, 194), MOSS[3]); c:put(406, 191, MOSS[2]) -- leaf mark
-- boot left on the post top (quirk)
obj(poly{ { 409, 172 }, { 414, 172 }, { 414, 178 }, { 419, 178 }, { 419, 182 }, { 409, 182 } }, LOG, { lit = 1, sh = 1 })
c:fillMask(c:rect(409, 172, 414, 173), LOG[1])

-------------------------------------------------------------- PEOPLE: fireside table with birch-log benches (front left)
shadow(poly{ { 18, 236 }, { 136, 236 }, { 140, 248 }, { 22, 248 } })
local function birch(m)
  obj(m, BIRCH, { lit = 1, sh = 2, tex = function(px, py, i)
    local n = hsh(floor(px / 4), py, 51)
    if i == 2 and n > 0.82 and (px % 4) < 3 then return 4 end
    if i == 2 and hsh(px, py, 52) > 0.93 then return 3 end
  end })
end
birch(c:rrect(44, 204, 118, 212, 3))                         -- back bench
obj(c:rect(36, 228, 40, 246), PLANK, { lit = 1, sh = 1 })    -- legs
obj(c:rect(116, 228, 120, 246), PLANK, { lit = 1, sh = 1 })
local top = poly{ { 36, 214 }, { 120, 214 }, { 128, 228 }, { 28, 228 } }
obj(top, PLANK, { lit = 1, sh = 1, tex = function(px, py, i)
  if (px - floor((py - 214) * 0.5)) % 14 == 0 and i == 2 then return 3 end
  if i == 2 and hsh(px, py, 61) > 0.94 then return 1 end
end })
obj(c:rect(28, 229, 128, 233), PLANK, { lit = 0, sh = 1, tex = function(px, py, i) if py == 229 then return 3 end end })
-- table things: mugs, bread loaf, plate, lantern (people icon: the shared mugs)
local function mug(x0, y0, r)
  c:fillMask(c:rect(x0 + 7, y0 + 2, x0 + 9, y0 + 6), r[4]); c:fillMask(c:rect(x0 + 8, y0 + 3, x0 + 8, y0 + 5), r[2])
  obj(c:rect(x0, y0, x0 + 6, y0 + 9), r, { lit = 1, sh = 1 })
  c:fillMask(c:rect(x0 + 1, y0 + 1, x0 + 5, y0 + 1), CREAM[1])
end
mug(46, 210, SEA); mug(58, 213, GOLD)
obj(c:rrect(70, 210, 90, 220, 4), GOLD, { lit = 2, sh = 2, tex = function(px, py, i) if (px == 75 or px == 80 or px == 85) and py < 214 then return 3 end end })
obj(c:rect(94, 218, 108, 221), CREAM, { lit = 1, sh = 1 })
obj(c:rect(97, 215, 100, 218), PETAL, { lit = 1, sh = 0 }); obj(c:rect(102, 215, 105, 218), MOSS, { lit = 1, sh = 0 })
obj(c:rect(111, 204, 119, 206), IRON, { lit = 0, sh = 0 })
obj(c:rect(112, 207, 118, 216), GLOW, { edge = IRON[4], lit = 1, sh = 1 })
obj(c:rect(110, 217, 120, 218), IRON, { lit = 0, sh = 0 })
-- front bench: big birch log with end grain
local fb = c:rrect(18, 246, 136, 260, 5)
birch(fb)
obj(c:rrect(18, 246, 27, 260, 3), ENDW, { edge = BIRCH[4], lit = 1, sh = 1, tex = function(px, py, i)
  if (px == 20 or px == 25) and py > 248 and py < 258 then return 3 end
  if (py == 248 or py == 258) and px > 20 and px < 25 then return 3 end
  if px >= 22 and px <= 23 and py >= 252 and py <= 254 then return 4 end
end })
-- mushroom sprouting from the log (quirk)
obj(c:rect(124, 241, 126, 246), CREAM, { lit = 0, sh = 1 })
obj(poly{ { 119, 241 }, { 122, 236 }, { 128, 236 }, { 131, 241 } }, EMBER, { lit = 1, sh = 1 })
c:put(123, 238, CREAM[1]); c:put(127, 239, CREAM[1])

-------------------------------------------------------------- GATE FRAME: log posts, beam, pine boughs, lanterns, charm
local function logV(x0, x1)
  obj(c:rect(x0, 0, x1, H - 1), LOG, { lit = 2, sh = 3, edge = false, tex = function(px, py, i)
    if (px - x0) % 5 == 2 and hsh(px, floor(py / 3), 71) > 0.35 and i == 2 then return 3 end
    if hsh(floor(px / 3), floor(py / 7), 72) > 0.93 and i == 2 then return 4 end
  end })
end
logV(0, 13); logV(466, 479)
c:fillMask(c:rect(14, 14, 14, H - 1), LOG[4]); c:fillMask(c:rect(465, 14, 465, H - 1), LOG[4])
obj(c:rect(0, 0, W - 1, 12), LOG, { lit = 2, sh = 3, edge = false, tex = function(px, py, i)
  if (py == 4 or py == 8) and hsh(floor(px / 5), py, 73) > 0.3 and i == 2 then return 3 end
  if hsh(floor(px / 6), floor(py / 3), 74) > 0.94 and i == 2 then return 4 end
end })
c:fillMask(c:rect(14, 13, 465, 13), LOG[4])
-- lashings at the corners
for _, lx in ipairs({ 0, 466 }) do
  obj(c:rect(lx, 13, lx + 13, 19), GOLD, { edge = GOLD[4], lit = 0, sh = 1, tex = function(px, py, i) if (px + py) % 3 == 0 then return 3 end end })
end
-- pine boughs drooping from the beam
local function bough(bx, by, len, dir)
  local m = poly{ { bx, by }, { bx + dir * len, by + floor(len * 0.55) }, { bx + dir * floor(len * 0.6), by + floor(len * 0.75) }, { bx - dir * 3, by + floor(len * 0.35) } }
  obj(m, PINE, { lit = 1, sh = 2, tex = function(px, py, i)
    if i == 2 and (px * dir + py * 2) % 4 == 0 then return 3 end
    if i == 2 and (px * dir - py) % 6 == 0 then return 1 end
  end })
end
for _, b in ipairs({ { 14, 11, 34, 1 }, { 36, 11, 30, 1 }, { 58, 11, 24, 1 }, { 80, 11, 18, 1 }, { 100, 11, 13, 1 }, { 6, 18, 26, 1 },
                     { 465, 11, 34, -1 }, { 443, 11, 30, -1 }, { 421, 11, 24, -1 }, { 399, 11, 18, -1 }, { 379, 11, 13, -1 }, { 473, 18, 26, -1 },
                     { 186, 11, 9, 1 }, { 290, 11, 9, -1 } }) do
  bough(b[1], b[2], b[3], b[4])
end
-- pine cones
for _, p in ipairs({ { 52, 30 }, { 428, 30 }, { 92, 22 } }) do
  obj(c:rrect(p[1] - 2, p[2] - 3, p[1] + 2, p[2] + 3, 1), WOOD, { lit = 1, sh = 1, tex = function(px, py, i) if (px + py) % 2 == 0 and i == 2 then return 3 end end })
end
-- hanging lanterns
local function lantern(lx, ly)
  for y = 13, ly - 1 do c:put(lx, y, (y % 2 == 0) and STONE[3] or IRON[4]) end
  obj(poly{ { lx - 7, ly + 4 }, { lx, ly }, { lx + 7, ly + 4 } }, IRON, { lit = 1, sh = 1 })
  obj(c:rect(lx - 6, ly + 5, lx + 6, ly + 20), IRON, { lit = 0, sh = 0 })
  obj(c:rect(lx - 4, ly + 6, lx + 4, ly + 19), GLOW, { edge = false, lit = 2, sh = 2 })
  c:fillMask(c:rect(lx - 1, ly + 10, lx + 1, ly + 15), "#fffbe8")
  c:fillMask(c:rect(lx, ly + 6, lx, ly + 19), IRON[3])
  obj(c:rect(lx - 7, ly + 21, lx + 7, ly + 22), IRON, { lit = 0, sh = 0 })
  c:put(lx, ly + 24, IRON[4]); c:put(lx, ly + 25, GOLD[2])
end
lantern(40, 24); lantern(440, 24)
-- charm: a ribbon-tied bundle of a feather-leaf and cone
for y = 13, 26 do c:put(130, y, "#d8c49a") end
obj(c:rect(127, 27, 133, 29), PETAL, { lit = 1, sh = 0 })
obj(poly{ { 128, 30 }, { 126, 42 }, { 130, 46 } }, MOSS, { lit = 1, sh = 1 })
obj(c:rrect(131, 30, 135, 38, 1), WOOD, { lit = 1, sh = 1, tex = function(px, py, i) if (px + py) % 2 == 0 and i == 2 then return 3 end end })

-------------------------------------------------------------- finish + save + layout
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { k = "do",     name = "Campfire Kettle", box = { 186, 114, 294, 192 } },
  { k = "people", name = "Fireside Table",  box = { 16, 204, 140, 262 } },
  { k = "stop",   name = "Camp Signboard",  box = { 20, 62, 116, 148 } },
  { k = "homes",  name = "Canvas Tents",    box = { 296, 58, 462, 156 } },
  { k = "wild",   name = "Wild Trail",      box = { 396, 160, 465, 228 } },
}
local stand = { { 240, 236 }, { 170, 224 }, { 312, 228 }, { 354, 188 }, { 152, 168 }, { 68, 176 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s.k, s.name,
    floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":%d,"h":%d,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n',
  W, H, HZ, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok " .. NAME)

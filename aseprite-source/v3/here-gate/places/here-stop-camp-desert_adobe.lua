-- Gnome Venture "Hearth Pop" v3 - here-gate place: Camp rest stop, DESERT ADOBE look (gate view, hero scale, golden hour)
-- Same geometry / spots / stand / compass corner as here-stop-camp.lua; only colours, flora, sky, hills, roof/wall style, quirks differ.
-- Run: AppRun -b --script-param out=<dir>/ --script here-stop-camp-desert_adobe.lua
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/tmp/"
local W, H, HZ = 480, 270, 112
local NAME = "here-stop-camp-desert_adobe"
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, cos, abs, max, min, pi = math.floor, math.sin, math.cos, math.abs, math.max, math.min, math.pi
local function hsh(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end

-- ramps {hi, base, shade, deep}
local LOG    = { "#d0a070", "#a0704a", "#74503a", "#4a302a" }  -- mesquite
local WOOD   = { "#e8b982", "#b97a4a", "#864c33", "#51302b" }
local PLANK  = { "#e89a78", "#b8604a", "#8a4440", "#5a2c34" }
local ENDW   = { "#f6d6a0", "#e2b47c", "#c08a5a", "#7a4a34" }
local BIRCH  = { "#ecd4aa", "#c8a47c", "#9a7a5c", "#5e4a44" }  -- palm-log benches
local STONE  = { "#e2e0e6", "#aaa9b8", "#74758c", "#444663" }  -- metal grey (hatchet, chain)
local ROCK   = { "#f6dcb8", "#d8ae84", "#aa8060", "#6e4c44" }  -- sandstone ring
local ADOBE  = { "#f8d6ac", "#e4ae80", "#c48862", "#7e5040" }  -- mud brick / plaster
local TURQ   = { "#a8ece0", "#4cbcb0", "#2e8a88", "#1e5a62" }
local AGAVE  = { "#c4e0c8", "#8ab8a4", "#5e8a82", "#36585a" }
local CACT   = { "#b8d27a", "#7ca852", "#527e44", "#30503a" }
local DATE   = { "#f0a050", "#c86a30", "#8e4228", "#5a2a24" }
local IRON   = { "#8c8aa8", "#5e5c7c", "#45435e", "#2c2a40" }
local EMBER  = { "#ff8a5c", "#e8493b", "#b52e3f", "#6e2038" }
local GOLD   = { "#ffe38a", "#f5b82e", "#d98322", "#8f4a1f" }
local MOSS   = { "#c4e07a", "#7cc35a", "#3f9150", "#24544a" }
local SEA    = { "#b6f0e0", "#5fc4c8", "#3a86b0", "#2a4a7a" }
local PETAL  = { "#ffc4d8", "#f5809f", "#c94f84", "#7d2c5e" }
local CANVAS = { "#fff0d2", "#efd6a8", "#c9a47a", "#7a5a48" }
local TEAL   = { "#f4ae84", "#d6784c", "#a8523c", "#6a2e34" }  -- terracotta canvas (tent B)
local CREAM  = { "#fff4dc", "#f2e2c2", "#d2bc9c", "#8a7062" }
local PINE   = { "#c4d27a", "#8aae52", "#5e8a44", "#34523a" }  -- palm fronds
local FARP   = { "#b4b48a", "#9a9c74", "#7e8264", "#5e6450" }  -- far palms (hazy)
local NEARP  = { "#a8b06a", "#7c9050", "#5a6e44", "#384a38" }  -- near palms
local DIRT   = { "#dca072", "#c4825a", "#a0644a", "#76463a" }  -- packed red earth
local DIRTW  = { "#f2bc84", "#dc9864", "#b4744e", "#76463a" }
local GR     = { "#fae4b0", "#efc890", "#d8a872", "#b08058" }  -- sand
local GRF    = { "#f4dcac", "#ead09c", "#dab684", "#b89070" }
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
    if t == "d" then c:put(x, y, inner and "#8a5450" or "#a06a5a")
    elseif t == "g" then c:put(x, y, inner and "#b07c74" or "#c69a82") end
  end)
end

-------------------------------------------------------------- SKY (dusk)
-- golden-hour haze: cool dusty blue up top, banded down to warm gold at the horizon (dithered band seams)
local SKY = { "#a8c4cc", "#bccdc6", "#cfd4bc", "#e0d6ae", "#ead2a0", "#f2cc92", "#f6d09a", "#f8d8a6", "#fae0b4" }
c:stripes(0, HZ - 1, SKY, { 3, 3, 3, 2, 2, 2, 2, 2, 2 })
do -- dither the band seams so the gradient is banded + dithered, not hard steps
  local prev = c:get(0, 0)
  for y = 1, HZ - 1 do
    local cur = c:get(0, y)
    if cur ~= prev then
      for x = 0, W - 1 do if (x + y) % 2 == 0 then c:put(x, y, prev) end end
      for x = 0, W - 1 do if (x + y) % 4 == 1 then c:put(x, y - 1, cur) end end
    end
    prev = cur
  end
end
-- low golden sun with a banded halo
local SX, SY = 176, 66
for _, rr in ipairs({ { 18, "#fae8bc" }, { 13, "#fcefc8" }, { 9, "#fff2c8" }, { 7, "#fff8de" } }) do
  c:fillMask(c:ellipse(SX, SY, rr[1], rr[1]), rr[2])
end
-- long haze streaks (dust in the air), lit top, shaded underside
for _, s in ipairs({ { 18, 30, 120 }, { 250, 22, 150 }, { 110, 46, 90 }, { 330, 52, 130 }, { 40, 70, 70 }, { 300, 76, 110 } }) do
  local x0, y0, len = s[1], s[2], s[3]
  for x = x0, x0 + len do
    local t = (x - x0) / len
    local th = (t > 0.15 and t < 0.85) and 2 or 1
    if not (th == 1 and x % 2 == 0) then
      c:put(x, y0, "#fbf0d6")
      if th == 2 then c:put(x, y0 + 1, "#f2dcb4"); if x % 3 ~= 0 then c:put(x, y0 + 2, "#e6cca4") end end
    end
  end
end
-- far mesas (flat tops, talus slopes, pale and cool: atmospheric perspective)
local MESAS = { { -10, 58, 80 }, { 120, 150, 86 }, { 300, 372, 78 }, { 418, 470, 84 } }
local function mesaY(x)
  local y = floor(98 + 3 * sin(x / 23) + 2 * sin(x / 7 + 1))
  for _, m in ipairs(MESAS) do
    local a, b, top = m[1], m[2], m[3]
    local d = (x < a) and (a - x) or ((x > b) and (x - b) or 0)
    local my = top + floor(d * 1.3 + (d > 0 and (d * d) * 0.05 or 0))
    if x >= a and x <= b and (x * 7) % 11 == 0 then my = my - 1 end
    if my < y then y = my end
  end
  return y
end
c:terrain(mesaY, "#e2b8a0", HZ)
for x = 0, W - 1 do
  local y1 = mesaY(x)
  c:put(x, y1, "#f4d4b8") -- sunlit rim
  for y = y1 + 1, HZ - 1 do
    -- strata lines on the steep faces, and a cooler shade on the right-facing side
    if (y - y1) % 5 == 3 and hsh(floor(x / 4), y, 5) > 0.3 then c:put(x, y, "#d0a492") end
    if mesaY(x + 1) < y1 and y < y1 + 12 and (x + y) % 2 == 0 then c:put(x, y, "#c89c94") end
  end
end
-- near dunes, smooth curves, warmer, with a lit crest and dithered lee shade
local function duneY(x) return floor(100 + 4 * sin(x / 33 + 2) + 3 * sin(x / 13)) end
c:terrain(duneY, "#ecc690", HZ)
for x = 0, W - 1 do
  local y1 = duneY(x)
  c:put(x, y1, "#f8e0b0")
  if duneY(x + 1) < y1 then for k = 1, 3 do if (x + k) % 2 == 0 then c:put(x, y1 + k, "#dcac7c") end end end
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
      -- wind ripples: thin curved bands, lit crest above a shaded trough
      local p = sin(y * (0.55 + far * 0.4) + sin(x / 23) * 2.4 + sin(x / 61) * 1.5)
      local col = r[2]
      local seg = hsh(floor((x + y * 3) / 11), floor(y / 3), 2) > 0.4
      if p > 0.93 and seg then col = r[1] elseif p < -0.95 and seg and (x % 3) ~= 0 then col = r[3] end
      if n > 0.97 then col = r[1] elseif n < 0.03 then col = r[3] end
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
-- dry grass tufts and sand pebbles (kept off the stand points)
local STANDS = { { 240, 236 }, { 170, 224 }, { 312, 228 }, { 354, 188 }, { 152, 168 }, { 68, 176 } }
local function nearStand(x, y, r)
  for _, s in ipairs(STANDS) do if abs(x - s[1]) < r and abs(y - s[2]) < r then return true end end
  return false
end
local DRY = { "#f0d890", "#d4b468", "#ae8c50", "#7e6440" }
for _ = 1, 260 do
  local x, y = math.random(16, 463), math.random(HZ + 6, 266)
  if gt[y * W + x] == "g" and not nearStand(x, y, 12) then
    local s = 1 + floor((y - HZ) / 52)
    for k = 0, s do
      c:put(x, y - k, DRY[2]); c:put(x - 1 - floor(k / 2), y - k + 1, DRY[1]); c:put(x + 1 + floor(k / 2), y - k + 1, DRY[3])
    end
    c:put(x, y + 1, GR[4])
  end
end
for _ = 1, 120 do
  local x, y = math.random(16, 463), math.random(HZ + 4, 266)
  if gt[y * W + x] == "g" and not nearStand(x, y, 10) then
    c:put(x, y, ROCK[1]); c:put(x + 1, y, ROCK[3])
    if y > 200 then c:put(x, y + 1, ROCK[3]); c:put(x + 1, y + 1, ROCK[4]) end
  end
end

-------------------------------------------------------------- FOREST EDGE
local PTRUNK = { "#c8a47a", "#9a7a58", "#74583f", "#4a3830" }
-- date palm: ringed curved trunk, drooping frond crown, a date cluster under it
local function palm(cx, base, h, lean, r, trunk, scale)
  scale = scale or 1
  local tx = cx + lean
  local tw = scale > 0.8 and 3 or 2
  local tm = c:line({ { cx, base }, { cx + floor(lean * 0.4), base - floor(h * 0.5) }, { tx, base - h } }, tw)
  obj(tm, trunk, { lit = 1, sh = 1, tex = function(px, py, i) if (py % 3 == 0) and i ~= 3 then return 3 end end })
  local top = base - h
  local L = floor(16 * scale)
  local fr = { { -1, -0.35 }, { -0.85, 0.25 }, { -0.45, 0.62 }, { 1, -0.3 }, { 0.85, 0.3 }, { 0.45, 0.66 }, { -0.25, -0.8 }, { 0.3, -0.78 } }
  local m = HP.mask()
  for _, f in ipairs(fr) do
    local ex, ey = tx + floor(f[1] * L), top + floor(f[2] * L)
    local mx, my = tx + floor(f[1] * L * 0.55), top + floor(f[2] * L * 0.55) - floor(3 * scale)
    m:add(c:line({ { tx, top }, { mx, my }, { ex, ey } }, scale > 0.8 and 3 or 2))
  end
  obj(m, r, { lit = 1, sh = 1, tex = function(px, py, i)
    if i == 2 and (px + py) % 3 == 0 then return 3 end
    if i == 2 and hsh(px, py, 8) > 0.88 then return 1 end
  end })
  if scale > 0.8 then
    obj(c:rrect(tx - 3, top + 2, tx + 1, top + 7, 1), DATE, { lit = 1, sh = 1, tex = function(px, py, i) if (px + py) % 2 == 0 and i == 2 then return 3 end end })
  end
end
-- far hazy palms + low scrub bumps along the horizon
local x = 20
while x < 466 do
  if x < 216 or x > 264 then
    local sh = hsh(x, 1, 2)
    if sh > 0.55 then
      palm(x, 111, 18 + floor(hsh(x, 2, 2) * 10), floor((hsh(x, 7, 2) - 0.5) * 6), FARP, { "#c8b496", "#ac9a80", "#8e806c", "#6a6056" }, 0.6)
    else
      obj(c:rrect(x - 6, 105, x + 6, 112, 3), FARP, { lit = 1, sh = 1 })
    end
  end
  x = x + 17 + floor(hsh(x, 3, 3) * 8)
end
-- near date palms (wider spacing than the old pines) + scrub clumps at their feet
x = 26
while x < 462 do
  if x < 206 or x > 274 then
    palm(x, 119 + floor(hsh(x, 4, 2) * 3), 40 + floor(hsh(x, 5, 2) * 22), floor((hsh(x, 8, 2) - 0.5) * 14), NEARP, PTRUNK, 1)
    obj(c:rrect(x + 4, 112, x + 16, 120, 3), NEARP, { lit = 1, sh = 1, tex = function(px, py, i) if i == 2 and px % 3 == 0 then return 3 end end })
  end
  x = x + 34 + floor(hsh(x, 6, 3) * 12)
end
-- a tiny far adobe waystation where the road runs on, with a lit door
obj(c:rect(232, 101, 248, 111), ADOBE, { lit = 1, sh = 1 })
obj(c:rect(231, 99, 249, 101), ADOBE, { lit = 0, sh = 1 })
c:put(235, 102, WOOD[3]); c:put(240, 102, WOOD[3]); c:put(245, 102, WOOD[3])
c:fillMask(c:rect(239, 105, 241, 110), GOLD[2]); c:put(240, 105, GOLD[1])
c:fillMask(c:rect(234, 104, 235, 105), TURQ[3]); c:fillMask(c:rect(245, 104, 246, 105), TURQ[3])

-------------------------------------------------------------- WOODPILE (deco, back left)
shadow(poly{ { 120, 127 }, { 186, 127 }, { 190, 132 }, { 116, 132 } })
obj(c:rect(122, 100, 125, 128), WOOD, { lit = 1, sh = 1 })
obj(c:rect(165, 100, 168, 128), WOOD, { lit = 1, sh = 1 })
obj(poly{ { 116, 99 }, { 174, 99 }, { 168, 93 }, { 122, 93 } }, { "#f0d890", "#d4b468", "#ae8c50", "#6e5438" }, { sh = 1, tex = function(px, py, i) if i == 2 and (px + py * 2) % 4 == 0 then return 3 end end })
for fx = 118, 172, 3 do c:put(fx, 100, "#ae8c50"); if fx % 2 == 0 then c:put(fx, 101, "#ae8c50") end end
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
-- tent A (cream canvas, turquoise + terracotta woven hems, open glowing door)
local ta = tent(334, 68, 298, 368, 148, CANVAS)
local hem = poly{ { 298, 140 }, { 368, 140 }, { 368, 146 }, { 298, 146 } }:clip(ta)
obj(hem, TURQ, { edge = false, lit = 0, sh = 1, tex = function(px, py, i) if py == 142 then return 4 end if (px // 3) % 2 == 0 and i == 2 then return 1 end end })
local hem2 = poly{ { 298, 124 }, { 368, 124 }, { 368, 126 }, { 298, 126 } }:clip(ta)
obj(hem2, EMBER, { edge = false, lit = 0, sh = 0, tex = function(px, py, i) if (px // 2) % 2 == 0 then return 3 end end })
local door = poly{ { 334, 94 }, { 349, 147 }, { 319, 147 } }
obj(door, GLOW, { edge = CANVAS[4], lit = 0, sh = 0, tex = function(px, py, i)
  if py > 136 then return 4 elseif py > 128 then return 3 elseif py < 108 then return 1 end
end })
obj(c:rect(326, 138, 342, 145), PETAL, { lit = 1, sh = 1, tex = function(px, py, i) if (px - 326) % 5 == 2 then return 3 end end }) -- striped kilim bedroll inside
obj(poly{ { 333, 96 }, { 319, 147 }, { 312, 147 }, { 330, 98 } }, CANVAS, { lit = 0, sh = 1 }) -- tied-back flaps
obj(poly{ { 335, 96 }, { 349, 147 }, { 356, 147 }, { 338, 98 } }, CANVAS, { lit = 0, sh = 1 })
c:put(318, 120, GOLD[2]); c:put(318, 121, GOLD[2]); c:put(350, 120, GOLD[2]); c:put(350, 121, GOLD[2]) -- tie toggles
-- homes icon: little pennant on tent A pole
obj(poly{ { 336, 61 }, { 348, 64 }, { 336, 67 } }, PETAL, { lit = 1, sh = 1 })
-- tent B (terracotta striped canvas, laced door, turquoise patch quirk)
local tb = tent(426, 74, 392, 458, 150, TEAL)
-- woven bands across tent B
for _, by in ipairs({ 118, 132 }) do
  local band = poly{ { 380, by }, { 470, by }, { 470, by + 3 }, { 380, by + 3 } }:clip(tb)
  band:each(function(px, py) c:put(px, py, (py == by or py == by + 3) and TEAL[4] or ((px // 2) % 2 == 0 and CREAM[2] or TURQ[2])) end)
end
for py = 100, 148, 6 do
  local t = (py - 74) / 76
  c:put(426, py, TEAL[4]); c:put(425, py + 1, "#d8c49a"); c:put(427, py + 1, "#d8c49a")
end
c:fillMask(c:line({ { 426, 92 }, { 426, 149 } }, 1), TEAL[3])
local patch = c:rect(438, 100, 447, 109)
obj(patch, TURQ, { lit = 1, sh = 1 })
for k = 0, 9, 2 do c:put(438 + k, 99, CREAM[1]); c:put(438 + k, 110, CREAM[1]) end
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
-- clay water jar hung on the pole in a rope sling (quirk), sweating a drip
c:fillMask(c:line({ { 382, 112 }, { 386, 117 } }, 1), "#d8c49a")
local jar = c:rrect(380, 116, 392, 130, 4)
obj(jar, TEAL, { lit = 1, sh = 2, tex = function(px, py, i) if py == 121 or py == 122 then return (px % 2 == 0) and 1 or nil end end })
c:fillMask(c:rect(380, 121, 392, 122), TURQ[2]); c:put(381, 121, TURQ[1])
obj(c:rect(383, 113, 389, 116), TEAL, { lit = 1, sh = 1 })
c:put(390, 132, TURQ[1]); c:put(390, 134, TURQ[2])
-- clothesline to tent B with a drying headscarf (quirk)
c:fillMask(c:line({ { 382, 96 }, { 396, 100 }, { 412, 96 } }, 1), "#d8c49a")
obj(poly{ { 395, 100 }, { 402, 100 }, { 403, 116 }, { 394, 116 } }, TURQ, { lit = 1, sh = 1,
  tex = function(px, py, i) if py == 104 or py == 105 or py == 111 then return 1 end if py == 108 then return 4 end end })
for fx = 394, 403, 2 do c:put(fx, 117, TURQ[3]); c:put(fx, 118, CREAM[2]) end
c:put(397, 99, WOOD[2]); c:put(400, 99, WOOD[2])

-------------------------------------------------------------- STOP: flat-roofed adobe notice board + stamp post (back left)
shadow(poly{ { 26, 142 }, { 116, 142 }, { 124, 148 }, { 32, 148 } })
obj(c:rect(29, 86, 36, 145), ADOBE, { tex = function(px, py, i) if i == 2 and py % 6 == 0 then return 3 end if i == 2 and py % 6 ~= 0 and (px + ((py // 6) % 2) * 3) % 6 == 0 then return 3 end if i == 2 and hsh(px, py, 23) > 0.92 then return 1 end end })
obj(c:rect(99, 86, 106, 145), ADOBE, { tex = function(px, py, i) if i == 2 and py % 6 == 0 then return 3 end if i == 2 and py % 6 ~= 0 and (px + ((py // 6) % 2) * 3) % 6 == 0 then return 3 end if i == 2 and hsh(px, py, 23) > 0.92 then return 1 end end })
c:fillMask(c:rect(29, 140, 36, 145), ADOBE[3]); c:fillMask(c:rect(99, 140, 106, 145), ADOBE[3]) -- splash-worn plinths
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
-- flat adobe roof: plastered slab with a stepped parapet, viga beam ends below, palm-mat fringe
local roof = c:rect(22, 80, 114, 89)
obj(roof, ADOBE, { lit = 1, sh = 2, tex = function(px, py, i) if i == 2 and hsh(px, py, 24) > 0.9 then return 3 end if i == 2 and py == 84 and px % 9 < 4 then return 3 end end })
obj(c:rect(24, 76, 50, 80), ADOBE, { lit = 1, sh = 1 }); obj(c:rect(86, 76, 112, 80), ADOBE, { lit = 1, sh = 1 })
obj(c:rect(26, 73, 34, 76), ADOBE, { lit = 1, sh = 1 }); obj(c:rect(102, 73, 110, 76), ADOBE, { lit = 1, sh = 1 })
c:fillMask(c:rect(22, 88, 114, 89), TURQ[3]); c:fillMask(c:rect(22, 88, 114, 88), TURQ[2]) -- painted trim
for vx = 27, 111, 12 do obj(c:rrect(vx, 89, vx + 4, 94, 1), LOG, { lit = 1, sh = 1, edge = LOG[4], tex = function(px, py, i) if py == 89 then return 3 end end }) end
-- stop icon plaque on the ridge: a stamp silhouette
obj(c:rrect(56, 63, 80, 77, 2), CREAM, { edge = WOOD[4], lit = 1, sh = 1 })
c:fillMask(c:rect(66, 65, 70, 68), EMBER[2]); c:fillMask(c:rect(67, 69, 69, 70), EMBER[3])
c:fillMask(c:rect(62, 71, 74, 74), EMBER[2]); c:fillMask(c:rect(62, 74, 74, 74), EMBER[3])
-- lantern hanging under the roof edge
c:put(108, 91, IRON[4]); c:put(108, 92, IRON[4])
obj(c:rect(105, 93, 111, 101), GLOW, { edge = IRON[4], lit = 1, sh = 1 })

-------------------------------------------------------------- DO: fire ring, flames, tripod kettle (centre)
-- polish pass: one heat field per flame layer (core / mid / tip tones), coal bed, embers, firelight on ground, stones, logs, kettle
local FX, FY = 240, 174
local function hx(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function mix(a, b, t)
  local r1, g1, b1 = hx(a); local r2, g2, b2 = hx(b)
  local function f(p, q) local v = floor(p + (q - p) * t + 0.5) if v < 8 then v = 8 end if v > 247 then v = 247 end return v end
  return string.format("#%02x%02x%02x", f(r1, r2), f(g1, g2), f(b1, b2))
end
-- flame tones, hottest last: deep tip red .. pale core (never pure white)
local FL = { "#7a1f3a", "#c22f3c", "#ea5a2e", "#f78a2c", "#fbb43c", "#ffd968", "#fff1b4" }
local FIRE_LIGHT = "#ff9a48"

-- firelight on the ground: banded + dithered warm wash, strongest near the ring
for y = 136, 214 do
  for x = 150, 330 do
    local dx, dy = (x - FX) / 92, (y - (FY + 4)) / 34
    local d = dx * dx + dy * dy
    if d < 1 then
      local k = c:get(x, y)
      local amt = d < 0.35 and 0.34 or (d < 0.62 and 0.22 or 0.12)
      if d >= 0.62 and (x + y) % 2 == 1 then amt = 0 end
      if d >= 0.35 and d < 0.62 and (x + y) % 4 == 0 then amt = 0.12 end
      if k and amt > 0 then c:put(x, y, mix(k, FIRE_LIGHT, amt)) end
    end
  end
end

local back, front = {}, {}
for k = 0, 17 do
  local a = k / 18 * 2 * pi
  local s = { x = floor(FX + 47 * cos(a) + 0.5), y = floor(FY + 13 * sin(a) + 0.5), sn = sin(a) }
  if s.sn < 0 then back[#back + 1] = s else front[#front + 1] = s end
end
local function stone(s)
  local wv = s.sn > 0 and 6 or 4
  local hv = s.sn > 0 and 4 or 3
  local m = c:rrect(s.x - wv, s.y - hv, s.x + wv, s.y + hv, 2)
  obj(m, ROCK, { lit = 1, sh = 1,
    tex = function(px, py, i) if i == 2 and hsh(px, py, 31) > 0.85 then return 3 end end })
  -- the side facing the fire catches warm light (back stones: lower face, front stones: top face)
  local near = 1 - abs(s.x - FX) / 52
  m:each(function(px, py)
    local face = (s.sn > 0) and (not m:has(px, py - 1) or not m:has(px, py - 2)) or (s.sn <= 0 and (not m:has(px, py + 1) or not m:has(px, py + 2)))
    if face and near > 0.15 then
      local k = c:get(px, py)
      c:put(px, py, (not m:has(px, py - 1) and s.sn > 0) and "#ffd2a0" or mix(k, FIRE_LIGHT, 0.45))
    end
  end)
  -- soot on the inner lip
  if s.sn > 0 then c:put(s.x - 1, s.y - hv + 1, "#6a5060"); c:put(s.x + 2, s.y - hv + 1, "#6a5060") end
end
shadow(poly{ { 186, 182 }, { 296, 182 }, { 290, 192 }, { 192, 192 } })
for _, s in ipairs(back) do stone(s) end
-- ash bed with a ring of glowing coals
c:fillMask(c:ellipse(FX, FY, 42, 10), "#4a3a4a")
for _ = 1, 60 do
  local px, py = math.random(202, 278), math.random(166, 182)
  if c:get(px, py) == "#4a3a4a" then c:put(px, py, hsh(px, py, 7) > 0.5 and EMBER[3] or "#6a4a54") end
end
c:fillMask(c:ellipse(FX, FY + 1, 30, 6), "#6e2038")
c:ellipse(FX, FY + 1, 30, 6):each(function(px, py)
  local n = hsh(floor(px / 2), py, 77)
  local dd = ((px - FX) / 30) ^ 2 + ((py - FY - 1) / 6) ^ 2
  local col = n > 0.55 and "#b52e3f" or "#8a2a3c"
  if dd < 0.55 and n > 0.35 then col = "#e8493b" end
  if dd < 0.3 and n > 0.5 then col = "#f78a2c" end
  if dd < 0.3 and n > 0.85 then col = "#ffd968" end
  c:put(px, py, col)
end)
-- crossed logs: bark, charred ends with glowing cracks, firelit top edge
local function firelog(a, b)
  local m = c:line({ a, b }, 5)
  obj(m, LOG, { lit = 1, sh = 1, tex = function(px, py, i)
    if i == 2 and (px * 2 + py) % 9 == 0 then return 3 end
  end })
  m:each(function(px, py)
    if not m:has(px, py - 1) then c:put(px, py, "#f0a060") end
    -- charred where it enters the fire
    local t = abs(px - FX) / 26
    if t < 0.55 and m:has(px, py - 1) then
      local n = hsh(px, py, 81)
      c:put(px, py, n > 0.8 and "#f78a2c" or (n > 0.55 and "#c22f3c" or "#3e2a36"))
    end
  end)
end
firelog({ 214, 180 }, { 262, 168 })
firelog({ 266, 180 }, { 218, 168 })

-- flame builder: union of tongues, max heat per pixel, painted once (core low and central, red tips)
local function flameLayer(tongues)
  local heat, m = {}, HP.mask()
  for _, tg in ipairs(tongues) do
    local cx, by, h, w, lean, seed = tg[1], tg[2], tg[3], tg[4], tg[5], tg[6] or 1
    for y = by, by - h, -1 do
      local t = (by - y) / h
      local prof = t < 0.22 and (0.72 + t * 1.27) or ((1 - t) / 0.78) ^ 1.15
      local hw = w * prof
      local off = lean * t * t + sin(t * 7 + seed) * w * 0.18 * t
      local x0, x1 = floor(cx + off - hw + 0.5), floor(cx + off + hw + 0.5)
      for x = x0, x1 do
        local d = hw > 0.5 and abs(x - (cx + off)) / (hw + 0.5) or 0
        local v = 1 - (0.82 * t + 0.55 * d ^ 1.6) * (tg[7] or 1)
        local key = y * W + x
        m:set(x, y)
        if not heat[key] or v > heat[key] then heat[key] = v end
      end
    end
  end
  m:each(function(x, y)
    local v = heat[y * W + x] + (((x + y) % 2 == 0) and 0.035 or -0.035)
    local i = v > 0.74 and 7 or v > 0.6 and 6 or v > 0.47 and 5 or v > 0.34 and 4 or v > 0.2 and 3 or v > 0.08 and 2 or 1
    c:put(x, y, FL[i])
  end)
  -- tip-red rim on the outer edge, upper half only (base sits in the coals)
  m:edge():each(function(x, y) if y < FY - 2 then c:put(x, y, (heat[y * W + x] or 0) > 0.45 and FL[3] or FL[2]) end end)
  return m
end
-- back layer: tall tongues behind the kettle, reaching past its sides
flameLayer({
  { 240, 178, 54, 15, 0, 1 }, { 223, 178, 58, 10, -7, 2 }, { 257, 178, 62, 10, 8, 3 },
  { 231, 178, 47, 9, 2, 4 }, { 249, 178, 40, 9, -3, 5 }, { 212, 178, 34, 7, -8, 6 }, { 268, 178, 38, 7, 9, 7 },
  { 216, 176, 50, 6, -12, 8 }, { 264, 176, 46, 6, 12, 9 },
})
-- detached flame wisps above the tips
for _, wsp in ipairs({ { 202, 120, 3 }, { 278, 116, 4 }, { 214, 108, 2 }, { 268, 104, 2 } }) do
  local wx, wy, wh = wsp[1], wsp[2], wsp[3]
  for k = 0, wh do c:put(wx + (k > 1 and 1 or 0), wy - k, k == 0 and FL[4] or FL[3]) end
  c:put(wx - 1, wy, FL[2]); c:put(wx + 1, wy, FL[2])
end
-- rising embers and sparks (mixed sizes, drifting right on the warm air)
for _, p in ipairs({ { 226, 112, 2 }, { 253, 104, 1 }, { 218, 108, 1 }, { 268, 112, 2 }, { 236, 98, 1 }, { 247, 92, 1 },
                     { 274, 100, 1 }, { 208, 120, 1 }, { 230, 86, 1 }, { 261, 84, 2 }, { 282, 108, 1 }, { 202, 104, 1 } }) do
  c:put(p[1], p[2], FL[6])
  if p[3] == 2 then c:put(p[1] + 1, p[2], FL[4]); c:put(p[1], p[2] + 1, FL[3]) end
end
for _, p in ipairs({ { 212, 116 }, { 270, 96 }, { 244, 80 }, { 222, 94 } }) do c:put(p[1], p[2], FL[3]) end
-- tripod (firelit on the inner face of each leg, lower half)
local legL = c:line({ { 240, 116 }, { 195, 188 } }, 3)
local legR = c:line({ { 240, 116 }, { 285, 188 } }, 3)
obj(legL, WOOD, { lit = 1, sh = 1 }); obj(legR, WOOD, { lit = 1, sh = 1 })
legL:each(function(px, py) if py > 140 and not legL:has(px + 1, py) then c:put(px, py, "#ffb070") end end)
legR:each(function(px, py) if py > 140 and not legR:has(px - 1, py) then c:put(px, py, "#ffb070") end end)
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
-- firelight bouncing up onto the kettle belly and its sides (banded, warm)
pot:each(function(px, py)
  local k = c:get(px, py)
  if py >= 158 then c:put(px, py, mix(k, FIRE_LIGHT, (py >= 161) and 0.55 or 0.38))
  elseif py >= 153 and (px + py) % 2 == 0 then c:put(px, py, mix(k, FIRE_LIGHT, 0.25)) end
  if (not pot:has(px - 2, py) or not pot:has(px + 2, py)) and py > 149 then c:put(px, py, mix(c:get(px, py), FIRE_LIGHT, 0.4)) end
end)
c:put(229, 144, "#d8d6ea"); c:put(230, 144, "#d8d6ea"); c:put(229, 145, IRON[1])
obj(c:rrect(229, 135, 251, 140, 2), IRON, { lit = 1, sh = 1 })
obj(c:rect(237, 131, 243, 134), GOLD, { lit = 1, sh = 1 })
-- front layer: low tongues licking up the kettle belly
flameLayer({
  { 228, 178, 22, 7, -2, 11, 1.15 }, { 240, 178, 19, 9, 1, 12, 1.1 }, { 252, 178, 23, 7, 3, 13, 1.15 },
  { 219, 178, 14, 5, -3, 14, 1.2 }, { 261, 178, 15, 5, 3, 15, 1.2 },
})
-- steam from the spout (quirk: it curls into a little puff train), warm-lit underside
for _, p in ipairs({ { 268, 132, 3 }, { 273, 125, 4 }, { 280, 118, 3 } }) do
  obj(c:rrect(p[1] - p[3], p[2] - p[3] + 1, p[1] + p[3], p[2] + p[3] - 1, 2), { "#fbf6ff", "#e8e0f0", "#e8bcb8", "#9a8cb4" }, { lit = 1, sh = 1 })
end
-- front stones
for _, s in ipairs(front) do stone(s) end
-- marshmallow on a stick propped on the ring (quirk), toasted side toward the fire
obj(c:line({ { 280, 184 }, { 291, 165 } }, 1), WOOD, { lit = 0, sh = 0 })
obj(c:rrect(289, 159, 294, 165, 1), CREAM, { lit = 1, sh = 1, tex = function(px, py, i) if py <= 160 then return 3 end end })
c:put(289, 162, "#d08a4a"); c:put(289, 163, "#a8603a"); c:put(290, 164, "#d08a4a")
-- a few stray embers on the dirt just outside the ring
for _, p in ipairs({ { 196, 186 }, { 284, 188 }, { 206, 192 }, { 276, 193 } }) do c:put(p[1], p[2], EMBER[2]); c:put(p[1] + 1, p[2], EMBER[4]) end

-------------------------------------------------------------- WILD: side trail through a palm arch to an oasis glimpse + arrow signpost (right)
local wbg = poly{ { 410, 174 }, { 432, 164 }, { 456, 174 }, { 463, 202 }, { 412, 202 } }
c:fillMask(wbg, "#6e7e52")
c:fillMask(wbg:copy():clip(poly{ { 412, 170 }, { 463, 162 }, { 463, 184 }, { 412, 186 } }), "#8a9862")
-- oasis water glinting through the arch
c:fillMask(wbg:copy():clip(poly{ { 412, 188 }, { 463, 186 }, { 463, 196 }, { 412, 198 } }), TURQ[3])
for px = 414, 462 do if px % 5 == 0 then c:put(px, 190, TURQ[1]); c:put(px + 1, 190, TURQ[2]) end; if px % 7 == 3 then c:put(px, 194, TURQ[2]) end end
for _ = 1, 40 do
  local px, py = math.random(412, 462), math.random(166, 186)
  if wbg:has(px, py) then c:put(px, py, "#a4b070") end
end
c:fillMask(poly{ { 418, 202 }, { 463, 199 }, { 463, 204 }, { 418, 206 } }, DIRT[3])
local BARK = { "#c8a47a", "#9a7a58", "#74583f", "#4a3830" }
local ring = function(px, py, i) if (py + floor(px / 3)) % 4 == 0 and i ~= 3 then return 3 end if i == 2 and (py + floor(px / 3)) % 4 == 1 then return 1 end end
obj(c:line({ { 404, 224 }, { 405, 196 }, { 412, 174 }, { 424, 162 }, { 434, 158 } }, 5), BARK, { lit = 1, sh = 2, tex = ring })
obj(c:line({ { 460, 226 }, { 459, 196 }, { 453, 174 }, { 444, 162 }, { 434, 158 } }, 5), BARK, { lit = 1, sh = 2, tex = ring })
-- frond fans where the old leaf clumps were: drooping blades from each node
local FR = { "#d4e08a", "#94b85a", "#628e46", "#36583a" }
local function fan(fx, fy, len, dirs)
  local m = HP.mask()
  for _, d in ipairs(dirs) do
    local ex, ey = fx + floor(d[1] * len), fy + floor(d[2] * len)
    local mx, my = fx + floor(d[1] * len * 0.55), fy + floor(d[2] * len * 0.55) - 3
    m:add(c:line({ { fx, fy }, { mx, my }, { ex, ey } }, 3))
  end
  obj(m, FR, { lit = 1, sh = 1, tex = function(px, py, i)
    if i == 2 and (px + py) % 3 == 0 then return 3 end
    if i == 2 and hsh(px, py, 41) > 0.9 then return 1 end
  end })
end
fan(406, 180, 12, { { -1, 0.5 }, { -0.7, -0.4 }, { 0.2, -0.9 } })
fan(414, 166, 13, { { -1, 0.2 }, { -0.5, -0.8 }, { 0.4, -0.9 } })
fan(434, 156, 18, { { -1, 0.45 }, { -0.6, -0.55 }, { 0, -0.9 }, { 0.6, -0.55 }, { 1, 0.45 }, { -0.3, 0.7 }, { 0.3, 0.7 } })
fan(454, 168, 13, { { 1, 0.2 }, { 0.5, -0.8 }, { -0.4, -0.9 } })
fan(460, 184, 10, { { 1, 0.5 }, { 0.6, -0.5 } })
-- date clusters + pink bougainvillea pops on the arch
obj(c:rrect(428, 160, 432, 166, 1), DATE, { lit = 1, sh = 1, tex = function(px, py, i) if (px + py) % 2 == 0 and i == 2 then return 3 end end })
obj(c:rrect(437, 160, 441, 165, 1), DATE, { lit = 1, sh = 1, tex = function(px, py, i) if (px + py) % 2 == 0 and i == 2 then return 3 end end })
for _, f in ipairs({ { 402, 186 }, { 409, 176 }, { 418, 166 }, { 450, 166 }, { 458, 176 }, { 461, 190 } }) do
  c:put(f[1], f[2], PETAL[1]); c:put(f[1] + 1, f[2], PETAL[2]); c:put(f[1], f[2] + 1, PETAL[2]); c:put(f[1] + 1, f[2] + 1, PETAL[3])
end
obj(poly{ { 398, 228 }, { 402, 220 }, { 407, 220 }, { 410, 228 } }, BARK, { lit = 1, sh = 1 })
obj(poly{ { 454, 228 }, { 458, 220 }, { 463, 220 }, { 466, 228 } }, BARK, { lit = 1, sh = 1 })
-- agave rosettes and a barrel cactus at the trunk feet
local function agave(fx, fy, s)
  local m = HP.mask()
  for _, d in ipairs({ { -5, -2 }, { -3, -6 }, { 0, -8 }, { 3, -6 }, { 5, -2 }, { -2, -4 }, { 2, -4 } }) do
    m:add(c:line({ { fx, fy }, { fx + floor(d[1] * s), fy + floor(d[2] * s) } }, 2))
  end
  obj(m, AGAVE, { lit = 1, sh = 1 })
  c:put(fx, fy - floor(8 * s), AGAVE[1])
end
local function barrel(bx, by, r)
  obj(c:rrect(bx - r, by - r * 2 + 1, bx + r, by, r - 1), CACT, { lit = 1, sh = 1, tex = function(px, py, i) if i == 2 and (px - bx) % 2 == 0 then return 3 end end })
  c:put(bx, by - r * 2, PETAL[2]); c:put(bx - 1, by - r * 2 + 1, PETAL[1]); c:put(bx + 1, by - r * 2 + 1, PETAL[3])
end
agave(399, 226, 1); agave(469, 224, 0.8); agave(416, 225, 0.8)
barrel(452, 226, 3); barrel(411, 228, 2)
-- open-sand flora between the spots (off the stand points)
shadow(poly{ { 124, 190 }, { 140, 190 }, { 142, 193 }, { 126, 193 } })
barrel(130, 190, 4); agave(122, 192, 0.7)
shadow(poly{ { 364, 216 }, { 382, 216 }, { 384, 219 }, { 366, 219 } })
agave(372, 217, 1.1); barrel(381, 217, 2)
-- a little saguaro on the back-left sand, arms up
shadow(poly{ { 172, 151 }, { 184, 151 }, { 186, 154 }, { 174, 154 } })
local sg = c:rrect(174, 134, 178, 152, 2):add(c:rrect(169, 138, 172, 146, 1)):add(c:rect(172, 144, 174, 146)):add(c:rrect(180, 136, 183, 143, 1)):add(c:rect(178, 141, 180, 143))
obj(sg, CACT, { lit = 1, sh = 1, tex = function(px, py, i) if i == 2 and (px == 176) then return 3 end end })
-- signpost
shadow(poly{ { 404, 222 }, { 424, 222 }, { 428, 226 }, { 408, 226 } })
obj(c:rect(410, 182, 414, 224), WOOD, { tex = function(px, py, i) if py % 5 == 0 and i == 2 then return 3 end end })
local arrow = poly{ { 398, 186 }, { 428, 186 }, { 436, 192 }, { 428, 198 }, { 398, 198 } }
obj(arrow, TURQ, { lit = 1, sh = 2, tex = function(px, py, i) if py == 192 and px > 402 and px < 428 and i == 2 then return 1 end end })
c:fillMask(c:rect(403, 190, 405, 194), CACT[3]); c:put(404, 189, CACT[3]); c:put(402, 191, CACT[3]); c:put(406, 192, CACT[3]) -- cactus mark
-- boot left on the post top (quirk)
obj(poly{ { 409, 172 }, { 414, 172 }, { 414, 178 }, { 419, 178 }, { 419, 182 }, { 409, 182 } }, LOG, { lit = 1, sh = 1 })
c:fillMask(c:rect(409, 172, 414, 173), LOG[1])

-------------------------------------------------------------- PEOPLE: fireside table with palm-log benches (front left)
shadow(poly{ { 18, 236 }, { 136, 236 }, { 140, 248 }, { 22, 248 } })
local function birch(m)
  obj(m, BIRCH, { lit = 1, sh = 2, tex = function(px, py, i)
    if i == 2 and px % 5 == 0 then return 3 end
    if i == 2 and px % 5 == 1 and hsh(floor(px / 5), py, 51) > 0.5 then return 1 end
    if i == 2 and hsh(px, py, 52) > 0.95 then return 4 end
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
-- table things: clay mugs, flatbread, dish of dates and figs, lantern (people icon: the shared mugs)
local function mug(x0, y0, r)
  c:fillMask(c:rect(x0 + 7, y0 + 2, x0 + 9, y0 + 6), r[4]); c:fillMask(c:rect(x0 + 8, y0 + 3, x0 + 8, y0 + 5), r[2])
  obj(c:rect(x0, y0, x0 + 6, y0 + 9), r, { lit = 1, sh = 1 })
  c:fillMask(c:rect(x0 + 1, y0 + 1, x0 + 5, y0 + 1), CREAM[1])
end
mug(46, 210, TURQ); mug(58, 213, TEAL)
obj(c:rrect(70, 210, 90, 220, 4), GOLD, { lit = 2, sh = 2, tex = function(px, py, i) if (px == 75 or px == 80 or px == 85) and py < 214 then return 3 end end })
obj(c:rect(94, 218, 108, 221), CREAM, { lit = 1, sh = 1 })
obj(c:rect(96, 215, 99, 218), DATE, { lit = 1, sh = 0 }); obj(c:rect(100, 214, 102, 218), DATE, { lit = 1, sh = 0 }); obj(c:rect(103, 215, 106, 218), PETAL, { lit = 1, sh = 0 })
obj(c:rect(111, 204, 119, 206), IRON, { lit = 0, sh = 0 })
obj(c:rect(112, 207, 118, 216), GLOW, { edge = IRON[4], lit = 1, sh = 1 })
obj(c:rect(110, 217, 120, 218), IRON, { lit = 0, sh = 0 })
-- front bench: big palm log with fibrous end grain
local fb = c:rrect(18, 246, 136, 260, 5)
birch(fb)
obj(c:rrect(18, 246, 27, 260, 3), ENDW, { edge = BIRCH[4], lit = 1, sh = 1, tex = function(px, py, i)
  if (px == 20 or px == 25) and py > 248 and py < 258 then return 3 end
  if (py == 248 or py == 258) and px > 20 and px < 25 then return 3 end
  if px >= 22 and px <= 23 and py >= 252 and py <= 254 then return 4 end
end })
-- tiny potted cactus perched on the log (quirk), one pink bloom
obj(c:rect(121, 240, 130, 246), TEAL, { lit = 1, sh = 1 })
obj(c:rect(120, 239, 131, 240), TEAL, { lit = 1, sh = 0 })
obj(c:rrect(124, 228, 127, 238, 1), CACT, { lit = 1, sh = 1, tex = function(px, py, i) if i == 2 and px == 125 then return 3 end end })
obj(c:rrect(120, 231, 122, 235, 1), CACT, { lit = 1, sh = 0 }); c:put(123, 234, CACT[2])
c:put(125, 227, PETAL[2]); c:put(126, 227, PETAL[1])

-------------------------------------------------------------- GATE FRAME: adobe pillars, viga lintel, palm fronds, tin lanterns, charm
local function logV(x0, x1)
  obj(c:rect(x0, 0, x1, H - 1), ADOBE, { lit = 2, sh = 3, edge = false, tex = function(px, py, i)
    -- mud-brick courses showing through worn plaster patches, a few chips
    local bare = hsh(floor(px / 7), floor(py / 18), 71) > 0.55
    if bare and py % 6 == 0 and i == 2 then return 3 end
    if bare and py % 6 ~= 0 and (px + ((py // 6) % 2) * 4) % 8 == 0 and i == 2 then return 3 end
    if hsh(px, py, 72) > 0.97 and i == 2 then return 1 end
    if hsh(floor(px / 2), floor(py / 2), 75) > 0.985 then return 4 end
  end })
end
logV(0, 13); logV(466, 479)
c:fillMask(c:rect(14, 14, 14, H - 1), ADOBE[4]); c:fillMask(c:rect(465, 14, 465, H - 1), ADOBE[4])
for _, px0 in ipairs({ 0, 466 }) do c:fillMask(c:rect(px0, 150, px0 + 13, 152), TURQ[3]); c:fillMask(c:rect(px0, 150, px0 + 13, 150), TURQ[2]) end -- painted band
obj(c:rect(0, 0, W - 1, 12), LOG, { lit = 2, sh = 3, edge = false, tex = function(px, py, i)
  if (py == 4 or py == 8) and hsh(floor(px / 5), py, 73) > 0.3 and i == 2 then return 3 end
  if hsh(floor(px / 6), floor(py / 3), 74) > 0.94 and i == 2 then return 4 end
end })
c:fillMask(c:rect(14, 13, 465, 13), LOG[4])
-- lashings at the corners
for _, lx in ipairs({ 0, 466 }) do
  obj(c:rect(lx, 13, lx + 13, 19), GOLD, { edge = GOLD[4], lit = 0, sh = 1, tex = function(px, py, i) if (px + py) % 3 == 0 then return 3 end end })
end
-- palm fronds drooping from the lintel (serrated leaflets)
local function bough(bx, by, len, dir)
  local m = poly{ { bx, by }, { bx + dir * len, by + floor(len * 0.55) }, { bx + dir * floor(len * 0.6), by + floor(len * 0.75) }, { bx - dir * 3, by + floor(len * 0.35) } }
  obj(m, PINE, { lit = 1, sh = 2, tex = function(px, py, i)
    if i == 2 and (px * dir + py) % 3 == 0 then return 3 end
    if i == 2 and (px * dir - py) % 7 == 0 then return 1 end
  end })
end
for _, b in ipairs({ { 14, 11, 34, 1 }, { 36, 11, 30, 1 }, { 58, 11, 24, 1 }, { 80, 11, 18, 1 }, { 100, 11, 13, 1 }, { 6, 18, 26, 1 },
                     { 465, 11, 34, -1 }, { 443, 11, 30, -1 }, { 421, 11, 24, -1 }, { 399, 11, 18, -1 }, { 379, 11, 13, -1 }, { 473, 18, 26, -1 },
                     { 186, 11, 9, 1 }, { 290, 11, 9, -1 } }) do
  bough(b[1], b[2], b[3], b[4])
end
-- date clusters
for _, p in ipairs({ { 52, 30 }, { 428, 30 }, { 92, 22 } }) do
  obj(c:rrect(p[1] - 2, p[2] - 3, p[1] + 2, p[2] + 3, 1), DATE, { lit = 1, sh = 1, tex = function(px, py, i) if (px + py) % 2 == 0 and i == 2 then return 3 end end })
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
-- charm: a turquoise-tied bundle of a palm leaf and a dried red chili
for y = 13, 26 do c:put(130, y, "#d8c49a") end
obj(c:rect(127, 27, 133, 29), TURQ, { lit = 1, sh = 0 })
obj(poly{ { 128, 30 }, { 126, 42 }, { 130, 46 } }, MOSS, { lit = 1, sh = 1 })
obj(poly{ { 131, 30 }, { 135, 30 }, { 134, 40 }, { 132, 44 } }, EMBER, { lit = 1, sh = 1 })
c:fillMask(c:rect(132, 29, 134, 29), CACT[3])

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

-- ramsons (final, Sonnet high). A slim diagonal bunch of wild garlic lying across the tile: slender white bulbs with a
-- violet blush and rootlet tufts at the lower left, five lanceolate leaves on long petioles (glossy, parallel veins, a
-- pale midrib, overlapping with contact shadow) fanning out of a hemp twine wrap with a bow, and a tall triangular scape
-- crowned by a loose umbel of white six-petal stars.
-- quirk: a tiny bee has landed on the umbel.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, rad = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.rad
local c = A.new("ramsons")
local LEAF  = { "#16393a", "#20574a", "#2f7a52", "#4a9c58", "#74bc66", "#a9d67f" }
local WHITE = { "#6f6586", "#9d94b0", "#c9c2d2", "#e8e3e6", "#f8f3ec", "#fffaf0" }
local VIOL  = { "#4a1f4a", "#74315f", "#9c4a78", "#c46e94", "#e098b2", "#f4c4d2" }
local STEM  = { "#3c6a4a", "#5f9a62", "#90c27c", "#c0e0a0" }
local TWINE = { "#6b4a2a", "#9c7440", "#c9a05a", "#e8c880" }
local PETAL = { "#8a82b0", "#bdb6d8", "#e6e2f0", "#fffaf0" }
local ltok = { r = { name = "leaf" } }
local TH0 = rad(-40)
local dx, dy = cos(TH0), sin(TH0)              -- axis, toward the upper right
local px, py = -dy, dx                         -- perpendicular, toward the lower right
local B = { 10, 51 }                           -- bulb end

-- rootlets
local function hair(x, y, pts, hex) for _, p in ipairs(pts) do c:put(x + p[1], y + p[2], hex) end end
local RT = { "#b8a68a", "#8c7a62" }
hair(8, 55, { { 0, 0 }, { -1, 1 }, { -1, 2 }, { -2, 3 } }, RT[1])
hair(10, 56, { { 0, 0 }, { 0, 1 }, { 1, 2 }, { 1, 3 } }, RT[2])
hair(13, 55, { { 0, 0 }, { 1, 1 }, { 2, 2 }, { 3, 2 } }, RT[1])
hair(6, 53, { { 0, 0 }, { -1, 0 }, { -2, 1 } }, RT[2])
hair(15, 53, { { 0, 0 }, { 1, 1 }, { 2, 1 }, { 3, 2 } }, RT[2])

-- bulbs: three slim teardrops, blunt end toward the lower left
local ang = math.atan(-dy, -dx)
local function bulb(cx, cy, L, W)
  local m = A.wedge(cx, cy, L, W, ang, 0.35)
  local n = X.pillow(m, W / 2)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local wm, vm = HP.mask(), HP.mask()
  m:each(function(x, y)
    local u = ((x - cx) * -dx + (y - cy) * -dy) / (L / 2)   -- >0 toward the blunt root end
    local j = X.hash(x, y, 3)
    if u > 0.25 + (j > 0.6 and 0.2 or 0) then vm:set(x, y) else wm:set(x, y) end
  end)
  X.tone(c, wm, v, WHITE, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
  X.tone(c, vm, v, VIOL, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 } })
  -- fine papery lines along the bulb
  m:each(function(x, y)
    local s = (x - cx) * px + (y - cy) * py
    if abs(s - W * 0.18) < 0.45 and wm:has(x, y) and X.hash(x, y, 4) > 0.3 then c:put(x, y, WHITE[2]) end
  end)
  return m
end
bulb(13.5, 51.5, 11, 4.4)
bulb(10.5, 49.5, 11, 4.2)
bulb(15.5, 48.5, 10, 4.0)

-- scape (flower stalk), triangular, drawn between the back and front leaves
local S = { 44.2, 22.4 }

local drawn = {}
local function leaf(off, a, L, w, bend, name)
  local ax, ay = B[1] + px * off + dx * 6, B[2] + py * off + dy * 6
  local ca = TH0 + (rad(a) - TH0) * bend
  local cx, cy = ax + cos(ca) * L * 0.5, ay + sin(ca) * L * 0.5
  local bx, by = ax + cos(rad(a)) * L, ay + sin(rad(a)) * L
  local m, n, T, Sd, len = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.34 then return 0.85 end
    local u = (t - 0.34) / 0.66
    return max(0.85, w * sin(pi * min(1, u * 0.93 + 0.07) ^ 0.9) ^ 0.75)
  end, { ramp = LEAF, veins = {}, rib = 0.13, ribEnd = 0.95, ribHi = "#c8e8a0", fold = 0.5, cool = "#2a5a6a" })
  -- parallel veins and a petiole of pale green
  m:each(function(x, y) local k = K(x, y)
    local s, t = Sd[k], T[k]
    if t < 0.36 then c:put(x, y, s <= 0 and STEM[3] or STEM[2], ltok)
    elseif t < 0.4 and abs(s) < 0.9 then c:put(x, y, s <= 0 and STEM[2] or STEM[1], ltok)
    elseif t > 0.46 and t < 0.94 then
      for _, vs in ipairs{ -0.58, -0.34, 0.34, 0.58 } do
        if abs(s - vs * (1 - (t - 0.46) * 0.6)) < 0.07 and X.hash(x, y, 8) > 0.2 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
      end
    end
    -- gloss: a long soft highlight on the lit half
    if t > 0.5 and t < 0.8 and s < -0.35 and s > -0.5 and (floor(t * len) % 5 < 3) then c:put(x, y, LEAF[6], ltok) end
  end)
  for _, d in ipairs(drawn) do A.contact(c, d, m, LEAF[1], 1, 1, ltok) end
  drawn[#drawn + 1] = m
  return m
end
leaf(-3, -72, 38, 3.1, 0.3)
leaf(-1.2, -58, 45, 3.4, 0.35)
leaf(3.2, -16, 40, 3.2, 0.3)
leaf(2.2, -27, 44, 3.4, 0.35)

-- scape
local sm, sT, sS = A.stem(c, { { 13, 47 }, { 22, 41 }, { 33, 32 }, { S[1], S[2] } }, 1.5, 0.95, STEM, { 0.3, 0.55, 0.8 })
sm:each(function(x, y) if (x + y) % 5 == 0 and sS[K(x, y)] and abs(sS[K(x, y)]) < 0.4 then c:put(x, y, STEM[4]) end end)
local m5 = leaf(-0.2, -47, 42, 3.6, 0.3)       -- front centre leaf crosses the scape
for _, d in ipairs{ sm } do A.contact(c, d, m5, STEM[1], 1, 1) end

-- twine wrap
local tc = { B[1] + dx * 19, B[2] + dy * 19 }
local a1, b1 = { tc[1] - px * 6.5, tc[2] - py * 6.5 }, { tc[1] + px * 6.5, tc[2] + py * 6.5 }
A.rope(c, a1, b1, 3, TWINE)
A.rope(c, { a1[1] - dx * 2.2, a1[2] - dy * 2.2 }, { b1[1] - dx * 2.2, b1[2] - dy * 2.2 }, 2, TWINE)
-- bow at the lower right end + tails
local kx, ky = floor(b1[1] + 0.5), floor(b1[2] + 0.5)
for _, p in ipairs{ { -1, -1 }, { 0, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { 0, 1 } } do c:put(kx + p[1], ky + p[2], TWINE[2]) end
c:put(kx, ky, TWINE[4]) c:put(kx - 1, ky - 1, TWINE[3])
for _, p in ipairs{ { 1, 1 }, { 1, 2 }, { 2, 3 }, { 2, 4 }, { 3, 5 } } do c:put(kx + p[1], ky + p[2], TWINE[3]) end
for _, p in ipairs{ { 2, 0 }, { 3, 1 }, { 4, 1 }, { 5, 2 }, { 5, 3 } } do c:put(kx + p[1], ky + p[2], TWINE[2]) end
c:put(kx + 3, ky + 5, TWINE[4]) c:put(kx + 5, ky + 3, TWINE[4])

-- umbel: pedicels + six-petal star flowers in a dome
local PED = "#9cc88a"
local flowers = {}
for _, f in ipairs{ { -158, 7.5 }, { -124, 7.8 }, { -88, 8 }, { -52, 7.6 }, { -16, 7.4 }, { 18, 6 }, { -105, 3.2 }, { -55, 3.4 } } do
  flowers[#flowers + 1] = { S[1] + cos(rad(f[1])) * f[2], S[2] + sin(rad(f[1])) * f[2] }
end
for _, f in ipairs(flowers) do A.pline(c, { { floor(S[1] + 0.5), floor(S[2] + 0.5) }, { floor(f[1] + 0.5), floor(f[2] + 0.5) } }, PED) end
c:put(floor(S[1] + 0.5), floor(S[2] + 0.5), STEM[2])
table.sort(flowers, function(a, b) return a[2] < b[2] end)
local function star(cx, cy)
  cx, cy = floor(cx + 0.5), floor(cy + 0.5)
  local rows = { "..w..", ".wWw.", "wWyWw", ".wWw.", "..w.." }
  local pal = { w = PETAL[3], W = PETAL[4], y = "#f2c84a" }
  for j, row in ipairs(rows) do for i = 1, 5 do
    local ch = row:sub(i, i)
    if ch ~= "." then
      local col = pal[ch]
      if ch == "w" and (i >= 4 or j >= 4) then col = PETAL[2] end   -- shade lower right
      if ch == "w" and i == 1 and j == 3 then col = PETAL[4] end
      c:put(cx + i - 3, cy + j - 3, col)
    end
  end end
  c:put(cx - 1, cy - 1, PETAL[4])
end
for _, f in ipairs(flowers) do star(f[1], f[2]) end

-- quirk: a bee on the umbel
local bx, by = floor(flowers[1][1] + 0.5) - 3, floor(flowers[1][2] + 0.5) - 3
local bee = { "..ww.", "GgKgK", "sgKsK", ".sKs." }
local pal = { w = "#e4f6ff", G = "#ffe38a", g = "#f5b82e", s = "#d98322", K = "#2b1c26" }
for j, row in ipairs(bee) do for i = 1, #row do local ch = row:sub(i, i) if ch ~= "." then c:put(bx + i - 1, by + j - 1, pal[ch]) end end end
c:put(bx + 2, by - 1, "#b9e2f5") c:put(bx + 3, by - 1, "#e4f6ff")
A.save(c, "ramsons")

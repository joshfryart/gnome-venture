-- firefly-jar (B3, Opus single pass). A slim glass jar of night air with four fireflies glowing inside, a cloth cap
-- tied on with twisted twine. Material: glass as a cylinder (bright left rim, broken specular streak, cool reflected
-- right edge, thick pale base ring, neck threads); each firefly lights the glass around it (halo of lifted tones);
-- grass blades inside; cloth cap with diagonal weave, scalloped skirt, AO under the skirt; ground shadow.
-- quirk: one firefly has got out and sits on top of the cap, lantern still lit.
local NAME = "firefly-jar"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GL = { "#151a3c", "#1e2a54", "#283c6c", "#345488", "#4a74a6", "#78a6ca" }
local RIM, SPEC, COOL = "#b6f0e0", "#effcff", "#5f9ad0"
local BASE = { "#2a4a7a", "#3a86b0", "#7cc4d4", "#c6f0ec" }
local CLOTH = { "#5e1a34", "#93283c", "#c43c40", "#e45e4a", "#f58a66", "#ffb88e" }
local TW = { "#6e4220", "#a86e30", "#d8a248", "#f2cc78" }
local GLOW = { "#c2d83a", "#e8f46a", "#fbfdc8" }
local GRASS = { "#1f4a46", "#2f6a50", "#4a8a56" }
local BUG = { "#2a1e26", "#4a3436", "#d86a4a" }

c:groundShadow(31.5, 57, 13, 2)

local CXJ = 31.5
-- glass mask: body + neck
local body = c:rrect(19, 24, 44, 55, 5)
local neck = c:rect(22, 19, 41, 24)
local glass = body:copy():add(neck)
local n = {}
glass:each(function(x, y)
  local hw = (y <= 23) and 10 or 12.5
  if y >= 24 and y <= 28 then hw = 10 + (y - 23) * 0.5 end
  local nx = max(-0.97, min(0.97, (x - CXJ) / (hw + 0.6)))
  local ny = 0
  if y >= 24 and y <= 28 then ny = -0.45 elseif y >= 52 then ny = 0.4 end
  n[K(x, y)] = { A.norm(nx, ny, sqrt(1 - nx * nx)) }
end)
-- fireflies inside
local flies = { { 26, 33 }, { 37, 30 }, { 30, 43 }, { 38, 46 } }
local bias = {}
glass:each(function(x, y)
  local k = K(x, y)
  for _, f in ipairs(flies) do
    local d = sqrt((x - f[1] - 0.5) ^ 2 + (y - f[2] - 0.5) ^ 2)
    if d < 5.5 then bias[k] = max(bias[k] or 0, d < 3.2 and 2 or 1) end
  end
end)
local gtok = A.tok("glass")
local gidx = A.tone(c, glass, n, GL, { bias = bias, amb = 0.12, wrap = 0.45, cuts = { 0.15, 0.3, 0.45, 0.6, 0.78 }, tok = gtok })

-- grass blades inside the jar
local function blade(pts, col)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local st = max(abs(b[1] - a[1]), abs(b[2] - a[2])) * 2
    for k = 0, st do local f = k / max(1, st)
      c:put(floor(a[1] + (b[1] - a[1]) * f + .5), floor(a[2] + (b[2] - a[2]) * f + .5), col, gtok) end
  end
end
blade({ { 25, 52 }, { 24, 45 }, { 26, 38 }, { 29, 35 } }, GRASS[2])
blade({ { 26, 52 }, { 25, 46 } }, GRASS[1])
blade({ { 35, 52 }, { 36, 44 }, { 34, 38 } }, GRASS[3])
blade({ { 36, 52 }, { 38, 47 }, { 41, 44 } }, GRASS[1])

-- thick glass base
for x = 20, 43 do
  c:put(x, 55, BASE[1], gtok)
  c:put(x, 54, (x < 30) and BASE[3] or BASE[2], gtok)
end
for x = 21, 42 do c:put(x, 53, (x > 23 and x < 34) and BASE[4] or BASE[3], gtok) end
c:put(19, 54, BASE[2], gtok) c:put(44, 54, BASE[1], gtok)
-- rims: bright left, cool right; specular streaks
glass:each(function(x, y)
  if y > 52 then return end
  local l = not glass:has(x - 1, y)
  local r = not glass:has(x + 1, y)
  if l then c:put(x, y, RIM, gtok) elseif r then c:put(x, y, COOL, gtok) end
end)
for y = 28, 47 do if y < 38 or y > 40 then c:put(22, y, SPEC, gtok) end end
for y = 30, 33 do c:put(24, y, RIM, gtok) end
c:put(22, 50, RIM, gtok)
-- shoulder highlight curve
for _, p in ipairs{ { 21, 25 }, { 22, 25 }, { 23, 24 } } do c:put(p[1], p[2], RIM, gtok) end
-- neck threads
for x = 23, 40 do
  c:put(x, 22, GL[max(1, (gidx[K(x, 22)] or 2) - 1)], gtok)
  if x < 38 then c:put(x, 21, GL[min(6, (gidx[K(x, 21)] or 2) + 1)], gtok) end
end

-- fireflies: glow dot + dark body + wing
local ftok = A.tok("flies")
for i, f in ipairs(flies) do
  local x, y = f[1], f[2]
  c:put(x, y, GLOW[3], ftok) c:put(x + 1, y, GLOW[2], ftok)
  c:put(x, y + 1, GLOW[2], ftok) c:put(x + 1, y + 1, GLOW[1], ftok)
  local dx = (i % 2 == 0) and -1 or 1
  c:put(x - dx, y - 1, BUG[1], ftok)
  c:put(x + (dx > 0 and -1 or 2), y, BUG[2], ftok)
end

-- cloth cap: dome + scalloped skirt
local ctok = A.tok("cloth")
local dome = c:ellipse(31.5, 17, 11.5, 4.5)
dome:clip(c:rect(0, 0, 63, 19))
local skirt = c:rect(20, 18, 43, 22)
for x = 20, 43 do if (x - 20) % 4 == 3 then skirt.s[K(x, 22)] = nil end end
local cap = dome:copy():add(skirt)
-- AO on the glass under the skirt
for x = 22, 41 do if not skirt:has(x, 23) then c:put(x, 23, GL[1], gtok) end end
for x = 21, 42 do if skirt:has(x, 22) and glass:has(x, 23) then c:put(x, 23, GL[1], gtok) end end
local cn = X.pillow(cap, 3)
local cidx = A.tone(c, cap, cn, CLOTH, { amb = 0.12, wrap = 0.3, cuts = A.CUTS, tok = ctok })
cap:each(function(x, y)
  if (x + y) % 3 == 0 and y < 19 then A.step(c, cidx, CLOTH, x, y, -1, ctok) end
  if y >= 21 and (x - y) % 3 == 0 then A.step(c, cidx, CLOTH, x, y, -1, ctok) end
end)
-- twine band with twist
local ttok = A.tok("twine")
for x = 20, 43 do
  local ph = (x % 3)
  c:put(x, 19, TW[ph == 0 and 4 or (ph == 1 and 3 or 2)], ttok)
  c:put(x, 20, TW[ph == 0 and 2 or (ph == 1 and 1 or 3)], ttok)
end
-- knot + two twisted tails on the right
A.map(c, { "cd", "ba" }, 43, 19, { a = TW[1], b = TW[2], c = TW[3], d = TW[4] }, ttok)
for i = 0, 6 do
  c:put(45 + (i > 3 and 1 or 0), 21 + i, TW[(i % 2 == 0) and 3 or 2], ttok)
end
for i = 0, 4 do c:put(44 - (i > 2 and 1 or 0), 21 + i, TW[(i % 2 == 0) and 2 or 1], ttok) end

-- quirk: the escaped firefly on top of the cap
local qtok = A.tok("escapee")
A.map(c, {
  "..w.w",
  ".aabbw",
  "rahhbgG",
  ".aabbg",
}, 29, 9, { a = BUG[1], b = BUG[2], h = "#5a4048", r = BUG[3], w = "#c6d2e6", g = GLOW[2], G = GLOW[3] }, qtok)
c:put(28, 10, BUG[2], qtok)

A.save(c, NAME)

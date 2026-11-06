-- ico-salad (final, Opus single pass). A turned wooden bowl heaped with ruffled lettuce, two glossy cherry tomatoes,
-- a cucumber slice and a red-onion ring, on a short foot ring.
-- Material: bowl with per-pixel light (6-tone walnut), concentric lathe grain bands, a bright bevelled lip and dark
-- inner wall; leaves with wavy ruffled edges, pillow light, midribs and veins in two greens (romaine + butterhead);
-- tomatoes with a white-hot specular, cool reflected light and a star calyx; cucumber with dark skin rim, pale flesh
-- and seeds. Ambient shading where the heap meets the lip; ground shadow (it stands).
-- quirk: a drip of dressing is running down the outside of the bowl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, sin, cos, atan, pi, max, min = math.floor, math.abs, math.sqrt, math.sin, math.cos, math.atan, math.pi, math.max, math.min
local c = A.new("ico-salad")
local WOOD = { "#3a1c24", "#64302a", "#924a30", "#bb6c3c", "#d99456", "#f2c07e" }
local ROM  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local BUT  = { "#2e5a34", "#4a8040", "#6fa44a", "#98c656", "#c0e06e", "#e6f6a0" }
local TOM  = { "#5a1830", "#8e2034", "#c42f35", "#e8493b", "#ff7a5a", "#ffb08a" }
local DRS  = { "#b07a3a", "#e0b25a", "#f6dc8c", "#fff4d6" }
local wtok, ltok, ttok = { r = { name = "wood" } }, { r = { name = "leaf" } }, { r = { name = "tom" } }

local CX, CY = 32, 33
c:groundShadow(32, 52, 17, 2)

-- inner back wall of the bowl (seen behind the heap)
local inner = c:ellipse(CX, CY, 20, 3.6)
inner:each(function(x, y) c:put(x, y, (y < CY - 1) and WOOD[2] or WOOD[1], wtok) end)
local backlip = c:ellipse(CX, CY, 22, 5):cut(inner)
backlip:each(function(x, y) if y < CY then c:put(x, y, y <= CY - 5 and WOOD[5] or WOOD[4], wtok) end end)

-- ruffled leaf
local function leaf(cx, cy, rx, ry, ramp, ph, back)
  local m = A.mk(floor(cx - rx - 2), floor(cy - ry - 2), floor(cx + rx + 2), floor(cy + ry + 2), function(x, y)
    local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
    local th = atan(dy, dx)
    local r = 1 + 0.13 * sin(6 * th + ph) + 0.05 * sin(11 * th + ph * 2)
    return dx * dx + dy * dy <= r * r
  end)
  local n = X.pillow(m, 3.2)
  local bias = {}
  m:each(function(x, y) local k = K(x, y) bias[k] = back and -1 or 0 end)
  local idx = A.shade(c, m, n, ramp, { tok = ltok, bias = bias, amb = 0.12, wrap = 0.3 })
  -- midrib (lit) curving up from the base, veins branching
  local bx, by = cx + rx * 0.15, cy + ry * 0.8
  local tx, ty = cx - rx * 0.25, cy - ry * 0.55
  for i = 0, 12 do local t = i / 12
    local x, y = floor(bx + (tx - bx) * t + 0.5), floor(by + (ty - by) * t + 0.5)
    if m:has(x, y) then c:put(x, y, ramp[min(6, (idx[K(x, y)] or 3) + 2)], ltok) if m:has(x + 1, y) then A.step(c, idx, ramp, x + 1, y, -1, ltok) end end
    if i == 4 or i == 8 then
      for j = 1, 3 do
        if m:has(x - j, y - j + 1) then A.step(c, idx, ramp, x - j, y - j + 1, -1, ltok) end
        if m:has(x + j + 1, y - j + 1) then A.step(c, idx, ramp, x + j + 1, y - j + 1, -1, ltok) end
      end
    end
  end
  return m
end

-- back leaves
leaf(19, 27, 7, 5.5, ROM, 0.4, true)
leaf(44, 26, 7.5, 5.5, ROM, 1.9, true)
leaf(31, 22, 8, 6, BUT, 2.7, true)

-- red onion ring (behind the front leaves)
local onion = c:ellipse(15, 29, 4, 3):cut(c:ellipse(15, 29, 2, 1.2))
onion:each(function(x, y) local up = y < 29 c:put(x, y, (x < 15 and up) and "#c9a0e6" or (up and "#9a5ac0" or "#6a3a8e"), ltok) end)
c:put(13, 27, "#efd8ff", ltok)

-- tomato
local function tomato(cx, cy, r)
  local m = c:ellipse(cx, cy, r, r - 0.3)
  local n = X.sphere(cx, cy, r, m)
  local idx = A.shade(c, m, n, TOM, { tok = ttok, amb = 0.06, wrap = 0.2 })
  local rim = X.rim(n)
  m:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and x > cx and y > cy then c:put(x, y, "#b04a78", ttok) end end)
  local sx, sy = floor(cx - r * 0.45 + 0.5), floor(cy - r * 0.35 + 0.5)
  c:put(sx, sy, A.CREAM, ttok) c:put(sx + 1, sy, TOM[6], ttok) c:put(sx, sy + 1, TOM[6], ttok)
  -- star calyx
  local kx, ky = floor(cx + 0.5), floor(cy - r + 1.5)
  A.map(c, { "g.g", ".G.", "g.g" }, kx - 1, ky - 1, { g = ROM[4], G = ROM[2] }, ltok)
  c:put(kx, ky - 2, ROM[3], ltok)
end
tomato(25, 24, 4.5)
tomato(43, 29, 4)

-- cucumber slice tipped toward us
local cu = c:ellipse(36, 22, 5, 4)
cu:each(function(x, y)
  local d = ((x + 0.5 - 36.5) / 5.5) ^ 2 + ((y + 0.5 - 22.5) / 4.5) ^ 2
  local col = d > 0.62 and (y > 22 and "#1f4a2e" or "#2e6a3a") or (d > 0.45 and "#a8d46a" or (d < 0.12 and "#f2fbc8" or "#d4ec9a"))
  c:put(x, y, col, ltok)
end)
for _, p in ipairs{ { 34, 21 }, { 38, 21 }, { 36, 24 }, { 35, 23 }, { 37, 23 } } do c:put(p[1], p[2], "#9cc060", ltok) end
c:put(34, 20, "#fbffe0", ltok)

-- front leaves
leaf(13, 33, 5.5, 3.8, BUT, 0.9, false)
leaf(24, 31, 7.5, 4.2, ROM, 3.1, false)
leaf(39, 32, 8, 4.4, BUT, 4.4, false)
leaf(50, 32.5, 5.5, 3.6, ROM, 5.2, false)

-- bowl front: outer shell below the rim line + foot ring
local shell = c:ellipse(CX, CY, 22, 17):clip(c:rect(0, CY, 63, 63)):cut(c:ellipse(CX, CY, 20, 3.6):clip(c:rect(0, 0, 63, CY + 3)))
shell:cut(c:rect(0, 49, 63, 63))
local foot = c:rrect(25, 47, 39, 51, 1)
local fn = X.pillow(foot, 2)
local fb = {} foot:each(function(x, y) fb[K(x, y)] = (y <= 48) and -2 or 0 end)
A.shade(c, foot, fn, WOOD, { tok = wtok, bias = fb, amb = 0.1 })
local sn = A.body(shell, 27, 30, 23, 4, 0.75)
local bias = {}
shell:each(function(x, y) local k = K(x, y)
  -- lathe grain: latitude bands
  local dx = (x + 0.5 - CX) / 22.5
  local lat = (y + 0.5 - CY) / sqrt(max(0.05, 1 - dx * dx))
  local f = (lat + 0.6 * sin(x * 0.4)) % 3.4
  if f < 0.55 and y > CY + 5 then bias[k] = -1 end
end)
local sidx = A.shade(c, shell, sn, WOOD, { tok = wtok, bias = bias, amb = 0.08, wrap = 0.25 })
-- front lip: the rim band (lit top face) between outer and inner ellipse, front half
local lip = c:ellipse(CX, CY, 22, 5):cut(c:ellipse(CX, CY, 20, 3.6)):clip(c:rect(0, CY, 63, 63))
lip:each(function(x, y)
  local col = (x < CX + 8) and WOOD[6] or WOOD[5]
  if not lip:has(x, y - 1) and not inner:has(x, y - 1) then col = (x < CX + 8) and WOOD[6] or WOOD[5] end
  if not lip:has(x, y + 1) then col = WOOD[3] end
  c:put(x, y, col, wtok)
end)
-- AO on the heap just above the front lip
lip:each(function(x, y) local yy = y - 1 if not lip:has(x, yy) and c:get(x, yy) then
  local h = c:get(x, yy)
  for i = 2, 6 do if h == ROM[i] then c:put(x, yy, ROM[i - 1], ltok) end if h == BUT[i] then c:put(x, yy, BUT[i - 1], ltok) end end
end end)
-- glint on the lip
c:put(18, 36, A.CREAM, wtok) c:put(19, 36, A.CREAM, wtok)

-- quirk: a drip of dressing running down the bowl
local dtok = { r = { name = "dressing" } }
for y = 38, 43 do c:put(41, y, DRS[2], dtok) c:put(40, y, DRS[3], dtok) end
A.map(c, { ".aa.", "abba", "abbc", ".cc." }, 39, 43, { a = DRS[3], b = DRS[2], c = DRS[1] }, dtok)
c:put(40, 44, DRS[4], dtok)
c:put(40, 37, DRS[3], dtok) c:put(41, 37, DRS[3], dtok) c:put(39, 37, DRS[2], dtok)

A.save(c, "ico-salad")

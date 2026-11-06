-- kava (final pass, Opus single pass). A freshly dug kava rootstock: a knobbly woody crown (wrinkle grain, lit knobs,
-- pale lenticels, cool reflected light), thin twisted fibrous roots trailing down, and two jointed green kava canes
-- with swollen dark nodes and purple mottles. The left cane is cut, showing a pale cream face with radial rays;
-- the right one carries a broad heart-shaped kava leaf with palmate veins (V-fold light, cool rim).
-- quirk: a little pink earthworm loops out between the roots.
local NAME = "kava"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local ROOT = { "#3a2622", "#5a3e30", "#7c5a40", "#a07c58", "#c6a27a", "#e6cca2" }
local FIB = { "#5a3e30", "#86663e", "#b08e62", "#d6b88a" }
local CANE = { "#203a2c", "#325634", "#4a7440", "#6a944e", "#94b666", "#c4d88c" }
local MOTTLE = "#5e3c5c"
local LEAF = { "#163a32", "#1f5440", "#2c7046", "#46904e", "#6cb058", "#a2d070" }
local VEIN, COOL = "#c6e692", "#3e6c7a"
local CUT = { "#a88a5a", "#d2b882", "#efe0b2", "#fff4d6" }
local WORM = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

local function line(pts, f)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      f(floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5), j / max(1, n)) end
  end
end

-- rootstock crown
local crown = HP.mask()
for _, e in ipairs{ { 31, 42, 8.5, 5.5 }, { 37, 44, 6.5, 4.5 }, { 25, 45, 5, 3.5 }, { 33, 47, 6, 2.5 } } do crown:add(c:ellipse(e[1], e[2], e[3], e[4])) end
-- knobs: small bumps on the outline
local knobs = { { 23, 41, 1.6 }, { 41, 41, 1.5 }, { 30, 37, 1.4 } }
for _, kb in ipairs(knobs) do crown:add(c:ellipse(kb[1], kb[2], kb[3], kb[3])) end

-- fibrous roots (drawn first, under the crown)
local rtok = { r = { name = "roots" } }
local roots = { { { 23, 46 }, { 20, 50 }, { 17, 52 }, { 13, 53 } }, { { 27, 48 }, { 26, 52 }, { 25, 54 }, { 23, 56 } },
                { { 32, 49 }, { 33, 53 }, { 32, 54 }, { 34, 56 } }, { { 38, 48 }, { 41, 52 }, { 44, 53 }, { 48, 55 } },
                { { 42, 45 }, { 46, 46 }, { 49, 48 }, { 51, 51 } } }
local rootM = HP.mask()
for i, p in ipairs(roots) do
  local m, n, T, S = A.tube(p, function(t) return 1.05 * (1 - t) + 0.35 end)
  m:cut(crown)
  local idx = A.shade(c, m, n, FIB, { tok = rtok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
  -- twist: dark ticks every few px along the root
  m:each(function(x, y) local k = K(x, y) if (T[k] * 14 + i) % 3 < 0.7 and S[k] > -0.3 then c:put(x, y, FIB[1], rtok) end end)
  rootM:add(m)
end

-- canes: jointed stems with nodes
local ctok = { r = { name = "cane" } }
local function cane(p, w, nodes)
  local m, n, T, S = A.tube(p, function(t) return w end)
  local idx = A.shade(c, m, n, CANE, { tok = ctok, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 7) > 0.86 and S[k] > -0.5 then c:put(x, y, MOTTLE, ctok) end
    if abs(S[k] + 0.4) < 0.15 and T[k] > 0.05 and T[k] < 0.95 then c:put(x, y, CANE[min(6, (idx[k] or 3) + 1)], ctok) end
  end)
  -- nodes: swollen ring (1 px wider), dark band below a pale band
  for _, nt in ipairs(nodes) do
    local x, y = A.bez(p, nt)
    local cx, cy = floor(x + 0.5), floor(y + 0.5)
    local hw = floor(w + 0.5) + 1
    for dx = -hw, hw do
      c:put(cx + dx, cy, dx < 0 and CANE[2] or CANE[1], ctok)
      if abs(dx) < hw then c:put(cx + dx, cy - 1, dx <= 0 and CANE[6] or CANE[4], ctok) end
      m:set(cx + dx, cy)
    end
  end
  return m
end
local caneB = cane({ { 36, 40 }, { 37, 34 }, { 38, 29 }, { 39, 23 } }, 1.4, { 0.45 })
local caneA = cane({ { 28, 40 }, { 27, 33 }, { 28, 26 }, { 26, 19 } }, 1.6, { 0.3, 0.75 })
-- cut face on cane A: pale disc with radial rays and a dark pith dot
do local tok = { r = { name = "cut" } }
  local cm = c:ellipse(26, 18, 2, 1)
  cm:each(function(x, y) c:put(x, y, (x <= 25) and CUT[3] or CUT[2], tok) end)
  c:put(24, 18, CUT[4], tok) c:put(26, 18, CUT[1], tok) c:put(28, 18, CUT[1], tok)
  c:put(26, 17, CUT[2], tok) c:put(26, 19, CUT[2], tok)
end

-- heart leaf on cane B
local ltok = { r = { name = "leaf" } }
local S0x, S0y = 40, 21
local ang = -62 * pi / 180
local ux, uy = cos(ang), sin(ang)
local px, py = -uy, ux
local lm = HP.mask()
for _, sd in ipairs{ -1, 1 } do lm:add(A.rell(S0x + ux * 3.6 + px * sd * 3.6, S0y + uy * 3.6 + py * sd * 3.6, ux, uy, 4.0, 3.6)) end
lm:add(A.rell(S0x + ux * 7.5, S0y + uy * 7.5, ux, uy, 6.8, 5.4))
lm:add(c:poly{ { floor(S0x + ux * 8 + px * 3.5 + 0.5), floor(S0y + uy * 8 + py * 3.5 + 0.5) },
  { floor(S0x + ux * 15.5 + 0.5), floor(S0y + uy * 15.5 + 0.5) },
  { floor(S0x + ux * 8 - px * 3.5 + 0.5), floor(S0y + uy * 8 - py * 3.5 + 0.5) } })
-- sinus notch at the petiole
for t = 0, 1.6, 0.4 do lm.s[K(floor(S0x + ux * t + 0.5), floor(S0y + uy * t + 0.5))] = nil end
lm:cut(caneB)
-- normals: pillow + V fold along the axis
local ln = X.pillow(lm, 2.2)
local LS = {}
lm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - S0x, y - S0y
  local s = dx * px + dy * py
  LS[k] = s
  local f = s < 0 and -0.38 or 0.38
  local nn = ln[k]
  ln[k] = { A.norm(nn[1] + px * f, nn[2] + py * f, nn[3]) }
end)
local lb = {}
X.ao(lb, lm, caneB, 1, -1)
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = lb, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- palmate veins from the petiole junction
for _, va in ipairs{ { 0, 14 }, { 0.5, 9 }, { -0.5, 9 }, { 1.15, 5.5 }, { -1.15, 5.5 } } do
  local vx, vy = A.rot(ux, uy, va[1])
  line({ { S0x + ux * 1.5, S0y + uy * 1.5 }, { S0x + ux * 1.5 + vx * va[2], S0y + uy * 1.5 + vy * va[2] } }, function(x, y, t)
    if lm:has(x, y) and not lm:edge():has(x, y) then
      local k = K(x, y)
      c:put(x, y, (LS[k] or 0) <= 0.3 and VEIN or LEAF[min(6, (lidx[k] or 3) + 1)], ltok)
    end
  end)
end
-- cool rim on the shade side
lm:edge():each(function(x, y) local k = K(x, y) if (LS[k] or 0) > 2.5 and (lidx[k] or 1) <= 3 then c:put(x, y, COOL, ltok) end end)
-- petiole joint
c:put(39, 22, CANE[3], ctok) c:put(40, 22, CANE[2], ctok) c:put(39, 21, CANE[4], ctok)

-- crown last: woody, wrinkled, knobby
local wtok = { r = { name = "crown" } }
local cn = A.body(crown, 29, 40, 9, 4, 0.5)
local cb = {}
X.ao(cb, crown, caneA, 1, -1) X.ao(cb, crown, caneB, 1, -1)
local cidx = A.shade(c, crown, cn, ROOT, { tok = wtok, bias = cb, amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
crown:each(function(x, y) local k = K(x, y)
  local ph = (y + 0.08 * (x - 31) ^ 2 * 0.25 + sin(x * 0.7) * 0.8) % 3
  if ph < 0.7 and not crown:edge():has(x, y) then c:put(x, y, ROOT[max(1, (cidx[k] or 3) - 1)], wtok) end
  if X.hash(x, y, 13) > 0.93 and (cidx[k] or 1) >= 3 then c:put(x, y, ROOT[6], wtok) end
end)
for _, kb in ipairs(knobs) do c:put(floor(kb[1] - 0.5), floor(kb[2] - 0.5), ROOT[6], wtok) end
local rim = X.rim(cn)
crown:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and y > 44 then c:put(x, y, "#7a7494", wtok) end end)
-- cane bases sit in the crown: dark collar
for _, q in ipairs{ { 26, 39 }, { 27, 39 }, { 28, 39 }, { 29, 39 }, { 30, 39 }, { 35, 40 }, { 36, 40 }, { 37, 40 }, { 38, 40 } } do
  if crown:has(q[1], q[2]) then c:put(q[1], q[2], ROOT[1], wtok) end end
local gx, gy = A.specAt(crown, cn, 30) if gx then c:put(gx, gy, ROOT[6], wtok) c:put(gx + 1, gy, ROOT[6], wtok) end

-- quirk: earthworm loop between roots
do local tok = { r = { name = "worm" } }
  local wm, wn, WT, WS = A.tube({ { 36, 56 }, { 37, 51 }, { 41, 51 }, { 41, 56 } }, function(t) return 0.95 end)
  wm:cut(rootM)
  local wi = A.shade(c, wm, wn, WORM, { tok = tok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
  wm:each(function(x, y) local k = K(x, y) if (WT[k] * 9) % 2 < 0.35 then c:put(x, y, WORM[max(1, wi[k] - 1)], tok) end end)
  c:put(38, 51, "#fff4d6", tok)
end

A.save(c, NAME)

-- kangkong-stir-fry (final pass, Opus single pass). Adobong kangkong on a white enamel plate with a blue rim stripe
-- (3/4 view: lit back wall, shaded front lip, thick edge, ground shadow). A loose heap of glossy wilted arrowhead
-- leaves (oil sheen specks, midribs) and bias-cut hollow stem pieces (open ends show the dark hollow), golden fried
-- garlic chips and red chili rings, in a pool of dark soy-vinegar sauce with one bright glint.
-- quirk: a steam curl rises off the heap and loops once.
local NAME = "kangkong-stir-fry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local PLATE = { "#6c6a8c", "#9a98b4", "#c6c3d4", "#e4e0e4", "#f4f0ea", "#fffaf2" }
local BLUE = { "#26407a", "#3462a8", "#5a8ed0", "#90bce8" }
local SAUCE = { "#2e1418", "#4a2220", "#6a3424", "#8e4c2c", "#b86c3a", "#e6a462" }
local LEAF = { "#122e2a", "#1a4434", "#255e3a", "#367a3e", "#549a46", "#88c060" }
local STEM = { "#2a5236", "#3e7040", "#5a924a", "#80b25a", "#acd27a", "#dcf0a8" }
local GARLIC = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local CHILI = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local STEAM = { "#b4c0dc", "#dce4f2", "#f4f6fa" }
local SHEEN = "#e2f2b8"

c:groundShadow(32, 53, 23, 3)
-- plate geometry
local CX, CY = 32, 44
local O = c:ellipse(CX, CY, 24, 9)
local foot = c:ellipse(CX, CY + 2, 23, 8.5):cut(O)
local W = c:ellipse(CX, CY - 1, 19, 6.5)
local ptok = { r = { name = "plate" } }
foot:each(function(x, y) c:put(x, y, (x < CX - 10) and PLATE[3] or (x < CX + 8 and PLATE[2] or PLATE[1]), ptok) end)
-- thickness: a pale lip line just under the rim on the lit side
foot:each(function(x, y) if not foot:has(x, y - 1) and x < CX then c:put(x, y, PLATE[4], ptok) end end)
local ring = O:copy():cut(W)
ring:each(function(x, y)
  local dx, dy = (x - CX) / 24.5, (y - CY) / 9.5
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local lit = -cos(a + 2.3)            -- upper-left of the ring faces the light
  local i = lit > 0.45 and 6 or (lit > -0.1 and 5 or (lit > -0.6 and 4 or 3))
  if r > 0.97 then i = i - 1 end
  c:put(x, y, PLATE[max(1, i)], ptok)
  if r > 0.84 and r < 0.94 then
    local b = lit > 0.45 and 4 or (lit > -0.2 and 3 or (lit > -0.7 and 2 or 1))
    c:put(x, y, BLUE[b], ptok)
  end
end)
-- well: lit back wall, shaded front wall, sauce floor
W:each(function(x, y)
  local dy = (y - (CY - 1)) / 7
  local i = dy < -0.55 and 3 or (dy < 0 and 4 or 5)
  if dy > 0.8 then i = 4 end
  c:put(x, y, PLATE[i], ptok)
end)
local sauce = c:ellipse(CX, CY, 17, 4.5)
local stok = { r = { name = "sauce" } }
sauce:each(function(x, y)
  local dx, dy = (x - CX) / 17.5, (y - CY) / 5
  local i = 3
  if dy < -0.5 then i = 2 elseif dy > 0.55 then i = 4 end
  if dx > 0.6 then i = i - 1 end
  c:put(x, y, SAUCE[max(1, i)], stok)
end)
-- specular on the rim
c:put(14, 39, "#fff4d6", ptok) c:put(15, 38, "#fff4d6", ptok) c:put(16, 38, PLATE[6], ptok)

-- food heap
local heap = HP.mask()
local ltok = { r = { name = "leaf" } }
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local base = (t < 0.22) and (0.6 + t * 9) or 1
    return max(0.4, w * min(base, 1) * (1 - t) ^ 0.6)
  end, { fold = 0.5 })
  local b = {}
  X.ao(b, m, heap, 1, -1)
  local nm = m:copy():cut(heap)
  local idx = A.shade(c, nm, n, LEAF, { tok = ltok, bias = b, amb = 0.1, wrap = 0.28, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  local sp = X.spec(n, 18)
  nm:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[5] or LEAF[3], ltok)
    elseif sp[k] and sp[k] > 0.55 and not b[k] and X.hash(x, y, 5) > 0.35 then c:put(x, y, SHEEN, ltok) end
  end)
  heap:add(nm)
end
local stems = {}
local function stem(p, capA, capB)
  local m, n, T, S = A.tube(p, function(t) return 1.45 end)
  local nm = m:copy():cut(heap)
  local b = {}
  X.ao(b, nm, heap, 1, -1)
  local tok = { r = { name = "stem" } }
  local idx = A.shade(c, nm, n, STEM, { tok = tok, bias = b, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  -- ridge lines along the hollow stem
  nm:each(function(x, y) local k = K(x, y) if abs(S[k] + 0.45) < 0.12 and T[k] > 0.1 and T[k] < 0.9 then c:put(x, y, STEM[6], tok) end end)
  -- open cut ends: pale ring, dark hollow centre
  for _, e in ipairs{ capA and { p[1], p[2] } or false, capB and { p[4], p[3] } or false } do
    if e then
      local x, y = floor(e[1][1] + 0.5), floor(e[1][2] + 0.5)
      for _, d in ipairs{ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } } do c:put(x + d[1], y + d[2], STEM[5], tok) end
      c:put(x - 1, y - 1, STEM[6], tok) c:put(x + 1, y + 1, STEM[3], tok)
      c:put(x, y, LEAF[1], tok)
      m:set(x - 1, y) m:set(x + 1, y) m:set(x, y - 1) m:set(x, y + 1) m:set(x, y)
    end
  end
  heap:add(m)
end
-- front to back (heap mask blocks later, deeper pieces)
stem({ { 20, 45 }, { 25, 44 }, { 30, 44 }, { 34, 45 } }, true, false)
leaf(36, 46, 42, 45, 47, 41, 3.0)
stem({ { 26, 42 }, { 28, 38 }, { 31, 34 }, { 33, 29 } }, false, true)
stem({ { 41, 43 }, { 40, 39 }, { 39, 35 }, { 41, 30 } }, false, true)
leaf(15, 42, 17, 35, 23, 29, 3.4)
leaf(25, 40, 27, 31, 33, 24, 3.6)
leaf(38, 40, 42, 32, 40, 24, 3.4)
leaf(48, 43, 50, 36, 46, 29, 3.2)
stem({ { 14, 41 }, { 19, 38 }, { 24, 37 }, { 29, 35 } }, true, false)
stem({ { 34, 37 }, { 39, 35 }, { 44, 36 }, { 50, 39 } }, false, true)
leaf(30, 36, 33, 28, 36, 20, 3.2)

-- garlic chips and chili rings on top
local gtok = { r = { name = "garlic" } }
for _, g in ipairs{ { 22, 40 }, { 35, 32 }, { 45, 37 }, { 29, 42 }, { 18, 36 } } do
  local x, y = g[1], g[2]
  c:put(x, y, GARLIC[4], gtok) c:put(x + 1, y, GARLIC[3], gtok) c:put(x, y + 1, GARLIC[3], gtok) c:put(x + 1, y + 1, GARLIC[2], gtok)
end
local ctok = { r = { name = "chili" } }
for _, q in ipairs{ { 32, 40 }, { 44, 33 }, { 24, 33 } } do
  local x, y = q[1], q[2]
  c:put(x, y - 1, CHILI[4], ctok) c:put(x - 1, y, CHILI[3], ctok) c:put(x + 1, y, CHILI[2], ctok) c:put(x, y + 1, CHILI[1], ctok)
  c:put(x - 1, y - 1, CHILI[3], ctok) c:put(x + 1, y + 1, CHILI[1], ctok)
  c:put(x, y, "#ffd8a6", ctok)
end
-- sauce glint
c:put(19, 47, SAUCE[6], stok) c:put(20, 47, SAUCE[5], stok)

-- quirk: steam curl
local etok = { r = { name = "steam" } }
local curl = { { 38, 18, 2 }, { 39, 17, 2 }, { 39, 16, 1 }, { 38, 15, 2 }, { 37, 14, 3 }, { 37, 13, 3 }, { 38, 12, 3 }, { 39, 11, 2 }, { 40, 11, 2 } }
for _, p in ipairs(curl) do c:put(p[1], p[2], STEAM[p[3]], etok) end

A.save(c, NAME)

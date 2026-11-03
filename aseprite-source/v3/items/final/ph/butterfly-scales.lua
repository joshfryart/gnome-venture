-- butterfly-scales (final, Opus aB13_3 single pass). A shed butterfly forewing fragment seen up close: rows of
-- overlapping shingle scales (scalloped rims, raised lit bases) shifting from rose at the furry root to violet at the
-- tip, dark radiating veins, a plum margin band with cream spots, a sky-blue iridescent sheen, a torn bite in the
-- outer edge. Loose scales drift off the tear.
-- quirk: one drifting scale has flipped over and flashes its blue underside.
local NAME = "butterfly-scales"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, atan, pi, max, min = math.floor, math.abs, math.sqrt, math.atan, math.pi, math.max, math.min
local c = A.new(NAME)
local PINK = { "#5a1e48", "#8a2c62", "#c4477e", "#ec6f9c", "#ff9ec0", "#ffd2e2" }
local VIO = { "#2e2050", "#46307e", "#6a48b0", "#8e6fd6", "#b89cf0", "#e0d0ff" }
local BAND = { "#2a1430", "#3e1c42", "#5a2a58" }
local VEIN = "#33163a"
local SHEEN = { "#8fd8f0", "#c8f4ff" }
local FUZZ = { "#3a2226", "#5e3a30", "#8a5c42", "#b88a5e" }
local BLUE = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local wtok = { r = { name = "wing" } }

local RX, RY = 14, 48 -- wing root
local wm = c:poly{ { 12, 49 }, { 15, 40 }, { 22, 28 }, { 32, 18 }, { 42, 12 }, { 48, 11 }, { 51, 15 }, { 51, 24 }, { 49, 32 }, { 45, 38 }, { 37, 44 }, { 26, 49 }, { 17, 51 } }
-- torn bite out of the outer margin
local bite = c:ellipse(52, 27, 3, 3.5)
bite:each(function(x, y) end)
wm:cut(bite)
for _, p in ipairs{ { 48, 23 }, { 47, 30 } } do wm.s[K(p[1], p[2])] = nil end
local wn = X.pillow(wm, 4, 0.8)
local v = X.light(wn, { amb = 0.18, wrap = 0.3 })
local d = X.dist(wm)
-- outer margin distance: distance to the edge away from the root side
local VE = { -2.6, -1.95, -1.45, -1.05, -0.62 } -- vein angles (radians, screen coords, up-right)
wm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - RX, y - RY
  local r = sqrt(dx * dx + dy * dy)
  local th = atan(dy, dx)
  local row = floor(r / 3.2)
  local vv = (r / 3.2) % 1
  local arc = th * r / 3.4 + (row % 2) * 0.5
  local u = arc % 1
  local val = v[k] or 0.5
  local ramp = (r + ((row * 7) % 3) * 0.8 < 27) and PINK or VIO
  local i = 1
  for j, t in ipairs{ 0.16, 0.32, 0.48, 0.64, 0.82 } do if val >= t then i = j + 1 end end
  local edge = 0.6 + 0.4 * (1 - (2 * u - 1) ^ 2)
  if vv > edge - 0.3 and vv <= edge then i = i - 1 end
  if vv > edge then i = i - 2 end
  if vv < 0.2 and abs(u - 0.5) < 0.3 then i = i + 1 end
  i = max(1, min(6, i))
  local col = ramp[i]
  -- marginal band with cream spots (outer edge, far from root)
  local dd = d[k] or 9
  if r > 22 and dd < 2.6 then
    col = BAND[dd < 1 and 1 or (val > 0.55 and 3 or 2)]
    if dd >= 1 and dd < 2.6 and floor(th * r / 5) % 2 == 0 and floor(th * r) % 5 < 2 then col = "#f6e2c4" end
  end
  -- veins
  for _, a in ipairs(VE) do if r > 4 and abs((th - a) * r) < 0.55 and dd > 1.5 then col = VEIN end end
  -- iridescent sheen: sky glints on the most lit violet scale bases
  if ramp == VIO and val > 0.84 and vv < 0.35 and (x + y) % 2 == 0 then col = SHEEN[2] end
  if ramp == VIO and val > 0.7 and val <= 0.84 and vv < 0.2 and x % 3 == 0 then col = SHEEN[1] end
  c:put(x, y, col, wtok)
end)
-- torn edge: frayed lighter scale ends along the bite
wm:edge():each(function(x, y) if bite:grow(1):has(x, y) then c:put(x, y, PINK[5], wtok) end end)
-- furry root stub (torn from the body)
local ftok = { r = { name = "fuzz" } }
for _, p in ipairs{ { 12, 48, 2 }, { 13, 48, 3 }, { 12, 49, 2 }, { 13, 50, 1 }, { 14, 49, 2 }, { 14, 50, 1 }, { 11, 47, 3 }, { 13, 47, 4 },
  { 12, 50, 1 }, { 15, 48, 3 }, { 15, 49, 2 }, { 14, 47, 4 }, { 11, 49, 2 }, { 16, 47, 2 } } do c:put(p[1], p[2], FUZZ[p[3]], ftok) end
-- ambient shading where the wing meets its root
for _, p in ipairs{ { 16, 46 }, { 17, 46 }, { 16, 48 } } do if wm:has(p[1], p[2]) then c:put(p[1], p[2], PINK[1], wtok) end end

-- loose drifting scales (shingle paddles)
local function scale(x, y, R, flip)
  local tok = { r = { name = "loose" .. x } }
  local rows = flip and {
    ".hb.", "hbbs", "bbsd", ".sd." } or {
    ".bh.", "bhbs", "bbsd", ".sd." }
  for j, row in ipairs(rows) do for i = 1, 4 do
    local ch = row:sub(i, i)
    local col = ({ h = R[4], b = R[3], s = R[2], d = R[1] })[ch]
    if col then c:put(x + i - 1, y + j - 1, col, tok) end
  end end
end
scale(52, 34, { VIO[2], VIO[3], VIO[4], VIO[6] })
scale(47, 43, { PINK[2], PINK[3], PINK[4], PINK[6] })
scale(53, 41, BLUE, true) -- quirk: flipped, blue underside
c:sparkle(55, 39)

A.fin(c, NAME)

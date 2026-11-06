-- ico-world-map (final pass, Opus). A tri-fold parchment chart, zigzag folded so the outer panels catch the light
-- and the middle one turns into shade. Printed inside a 3 px paper border: a teal sea with a pale shallow ring
-- round two chunky continents and an islet, hill chevrons, a dashed red route and a bold red X on the far island.
-- Material: per-pixel light per panel (bulge across each panel), paper fibre specks, bright top bevel and darker
-- underside row (paper thickness), mountain-fold ridge light and valley-fold crease shadow, contact shadow under the flap.
-- History: Sonnet draft (_dA12) replaced.
-- quirk: the top-right corner is dog-eared, its blank back showing, with a tiny pencilled compass "N" on it.
local NAME = "ico-world-map"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local PAPER = { "#6b3f2e", "#9a6640", "#c69560", "#e2bc84", "#f3daa6", "#fff0cc" }
local BACK  = { "#8a6a52", "#b8936c", "#d8b88a", "#ecd4a6", "#f8e8c4", "#fff6dc" }
local SEA   = { "#22386a", "#2c5a8e", "#3a7eac", "#55a2c6", "#80c6d6", "#b4e6e4" }
local LAND  = { "#284a36", "#386a3a", "#548e40", "#78ae4c", "#a2ca62", "#cce286" }
local RED   = { "#5e1a34", "#9a2738", "#d03c38", "#ee5c40", "#ff8a5c", "#ffc08a" }
local CUTS  = { 0.3, 0.45, 0.6, 0.74, 0.87 }

-- panels: x range and top edge (zigzag), height 37
local HGT = 37
local function top(x)
  if x <= 24 then return floor(16 - (x - 9) * 4 / 15 + 0.5) end
  if x <= 39 then return floor(12 + (x - 24) * 4 / 15 + 0.5) end
  return floor(16 - (x - 39) * 4 / 16 + 0.5)
end
local function panel(x) if x <= 24 then return 1 elseif x <= 39 then return 2 else return 3 end end
local PX = { { 9, 24 }, { 25, 39 }, { 40, 55 } }

-- map-space content (u 0..46, w 0..37)
local function blob(u, w, cx, cy, rx, ry, wob, ph)
  local dx, dy = (u - cx) / rx, (w - cy) / ry
  local a = math.atan(dy, dx)
  local r = 1 + wob * sin(a * 3 + ph) + wob * 0.6 * sin(a * 5 + ph * 2)
  return dx * dx + dy * dy <= r * r
end
local function land(u, w)
  return blob(u, w, 12, 13, 7.5, 7.0, 0.12, 0.4) or blob(u, w, 8.5, 22.5, 4.2, 6.0, 0.1, 1.3)
      or blob(u, w, 33.5, 21.5, 7.0, 6.5, 0.12, 2.2) or blob(u, w, 29, 29, 3.5, 2.6, 0.1, 0.7)
      or blob(u, w, 23, 9, 2.6, 2.2, 0.0, 0)
end
local function shallow(u, w)
  for _, d in ipairs{ { 2, 0 }, { -2, 0 }, { 0, 2 }, { 0, -2 }, { 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 } } do
    if land(u + d[1], w + d[2]) then return true end
  end
  return false
end
local route = { { 14, 16 }, { 17, 24 }, { 22, 28 }, { 27, 23 }, { 32, 21.5 } }
local function routeAt(u, w)
  local acc = 0
  for i = 1, #route - 1 do
    local ax, ay, bx, by = route[i][1], route[i][2], route[i + 1][1], route[i + 1][2]
    local vx, vy = bx - ax, by - ay
    local L = sqrt(vx * vx + vy * vy)
    local t = max(0, min(1, ((u - ax) * vx + (w - ay) * vy) / (L * L)))
    local px, py = ax + vx * t, ay + vy * t
    if (u - px) ^ 2 + (w - py) ^ 2 < 1.0 then return ((acc + t * L) % 4.0) < 2.6 end
    acc = acc + L
  end
  return false
end
local XU, XW = 34, 21

-- dog-ear: corner u 46,w 0 folded down along the line (39,0)-(46,7)
local function cutCorner(u, w) return (46 - u) + w < 7 end
local function flap(u, w) return u >= 39 and w <= 7 and (46 - u) + w >= 7 and (u - 39) + (7 - w) >= 0 and u <= 46 end

-- paint
local paper = HP.mask()
for x = 9, 55 do local t = top(x) for y = t, t + HGT do
  local u, w = x - 9, y - t
  if not cutCorner(u, w) then paper:set(x, y) end
end end
local flapM = HP.mask()
for x = 47, 55 do for y = 10, 26 do end end
for x = 9, 55 do local t = top(x) for y = t, t + HGT do
  local u, w = x - 9, y - t
  if flap(u, w) then flapM:set(x, y) end
end end

local tok = { r = { name = "map" } }
paper:each(function(x, y)
  local p = panel(x)
  local x0, x1 = PX[p][1], PX[p][2]
  local s = (x - x0) / (x1 - x0)                 -- 0..1 across panel
  local tilt = (p == 2) and 0.42 or -0.22
  local nx = tilt + (s - 0.5) * 0.3
  local t = top(x)
  local u, w = x - 9, y - t
  local ny = (w < 3) and -0.25 or ((w > HGT - 3) and 0.2 or 0)
  local n = { A.norm(nx, ny, 1) }
  local v = X.light({ [1] = n }, { amb = 0.1, wrap = 0.35 })[1]
  local i = A.q(v, CUTS)
  -- folds: ridge light on the mountain fold, crease shadow in the valley
  if x == 24 then i = i + 1 end
  if x == 25 then i = i - 1 end
  if x == 40 then i = i - 1 end
  if w == 0 then i = i + 1 end
  if w == HGT then i = i - 2 end
  local ramp
  local border = u <= 2 or u >= 44 or w <= 2 or w >= HGT - 2
  if border then
    ramp = PAPER
    if X.hash(x, y, 7) > 0.84 and w > 0 and w < HGT then i = i - 1 end
  elseif u == 3 or u == 43 or w == 3 or w == HGT - 3 then
    ramp = PAPER i = i - 2                       -- printed frame line
  elseif land(u, w) then
    ramp = LAND
    -- coast: darker 1 px rim inside the land
    if not land(u + 1, w) or not land(u - 1, w) or not land(u, w + 1) or not land(u, w - 1) then i = i - 1 end
  elseif shallow(u, w) then ramp = SEA i = i + 1
  else
    ramp = SEA
    if (w + floor(u / 4)) % 6 == 0 and (u % 4) < 2 and X.hash(x, y, 3) > 0.35 then i = i + 1 end  -- wave ticks
  end
  -- hill chevrons on the big continents
  for _, h in ipairs{ { 11, 11 }, { 14, 15 }, { 35, 19 }, { 8, 22 } } do
    local du, dw = u - h[1], w - h[2]
    if ramp == LAND and dw <= 0 and dw >= -1 and abs(du) == dw + 1 then i = i - 2 end
    if ramp == LAND and dw == -2 and du == 0 then i = i - 2 end
  end
  if not border and routeAt(u, w) and not (abs(u - XU) <= 3 and abs(w - XW) <= 3) then ramp = RED i = (i >= 4) and 4 or 3 end
  -- the X
  local du, dw = u - XU, w - XW
  if abs(du) <= 3 and abs(dw) <= 3 and (abs(du - dw) <= 0 or abs(du + dw) <= 0 or abs(du - dw) == 1 and du > dw or abs(du + dw) == 1 and du + dw > 0) then
    ramp = RED i = (du + dw < -1) and 4 or ((du + dw > 1) and 2 or 3)
  end
  -- contact shadow of the flap on the print below it
  if flapM:has(x - 1, y) or flapM:has(x, y - 1) or flapM:has(x - 1, y - 1) then
    if not flapM:has(x, y) then i = i - 2 end
  end
  c:put(x, y, ramp[max(1, min(#ramp, i))], tok)
end)
-- flap: blank paper back, lit (it faces up-left), darker near the fold line, pencil "N"
flapM:each(function(x, y)
  local t = top(x) local u, w = x - 9, y - t
  local d = (46 - u) + w - 7                    -- 0 on fold line
  local i = 5
  if d <= 0 then i = 3 elseif d == 1 then i = 4 end
  if u == 39 or w == 7 then i = 4 end
  c:put(x, y, BACK[i], tok)
end)
-- pencil N on the flap
local nb = { { 0, 0 }, { 0, 1 }, { 0, 2 }, { 0, 3 }, { 1, 1 }, { 2, 2 }, { 3, 0 }, { 3, 1 }, { 3, 2 }, { 3, 3 } }
do local x0 = 48 local y0 = top(48) + 2
  for _, p in ipairs(nb) do if flapM:has(x0 + p[1], y0 + p[2]) then c:put(x0 + p[1], y0 + p[2], BACK[2], tok) end end
end
-- one glint on the X
c:put(9 + XU - 2, top(9 + XU) + XW - 2, RED[6], tok)
A.save(c, "ico", NAME)

-- ico-cooking-pan (final, Opus). A cast-iron skillet seen in three-quarter view from above: a rounded rolled rim, a
-- visible inner wall and flat floor, the outer side wall showing as a crescent along the front, and a slim handle
-- running out to the lower right (iron neck, brass collar with a rivet, wooden grip with a hanging hole).
-- Material: height-field normals snapped to a 6-tone slate iron ramp, bright machined edge + specular streak on the
-- upper-left rim, rim shadow falling on the floor, contact shadow under the egg, lacy browned edge on the egg white,
-- wood grain along the grip, AO where the handle meets the pan wall.
-- quirk: the fried egg's yolk has set in the shape of a heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, atan = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.atan
local c = A.new("ico-cooking-pan")
local FE   = { "#2f2d48", "#45456a", "#5e6189", "#7d84a8", "#a6aec8", "#d8dcea" }
local WOOD = { "#4a2a26", "#6e3d2c", "#93583a", "#b8794c", "#d99e66", "#f0c48a" }
local BR   = { "#6a3a1c", "#a8641e", "#d9962c", "#f5c650", "#fff0a8" }
local EGG  = { "#8e7f9c", "#b3a6b8", "#d3c9cf", "#ebe2da", "#f8efdf", "#fff4d6" }
local YOLK = { "#8f3f17", "#c8661c", "#ec9124", "#f8b632", "#ffd860", "#fff0b0" }
local LACE = "#d09a58"
local tFE, tWD, tBR, tEG, tYK = A.tok("iron"), A.tok("wood"), A.tok("brass"), A.tok("egg"), A.tok("yolk")

local CX, CY, RX, RY = 23.5, 24, 16.5, 12.5
local WALL = 4
local function rr(x, y) return sqrt(((x - CX) / RX) ^ 2 + ((y - CY) / RY) ^ 2) end
-- radial profile: flat floor, inner wall up to a rolled rim, then down to the outer edge
local function prof(r)
  if r < 0.70 then return 0 end
  if r < 0.84 then local t = (r - 0.70) / 0.14 return 4.2 * sin(t * pi / 2) end
  if r < 0.94 then local t = (r - 0.84) / 0.10 return 4.2 + 0.9 * sin(t * pi) end
  if r <= 1.04 then local t = (r - 0.94) / 0.10 return 4.2 - 1.8 * t end
  return 2.4
end
local top = HP.mask()
for y = 0, 63 do for x = 0, 63 do if rr(x, y) <= 1.0 then top:set(x, y) end end end
-- outer side wall: the top ellipse pushed down WALL px, minus the top
local side = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  if not top:has(x, y) and sqrt(((x - CX) / RX) ^ 2 + ((y - CY - WALL) / (RY - 0.3)) ^ 2) <= 1.0 and y > CY then side:set(x, y) end
end end
local pan = top:copy():add(side)

-- handle: iron neck, brass collar, wooden grip (drawn under the pan)
local ang = 0.78
local ux, uy = cos(ang), sin(ang)
local hx0, hy0 = CX + ux * (RX - 3), CY + uy * (RY - 1) + 1
local neckM, neckN, neckT, neckS = A.seg(hx0, hy0, hx0 + ux * 9, hy0 + uy * 9, 1.55, 1.45)
local gx0, gy0 = hx0 + ux * 8.5, hy0 + uy * 8.5
local GL = 17
local gripM, gripN, gripT, gripS = A.seg(gx0, gy0, gx0 + ux * GL, gy0 + uy * GL, 2.45, 2.75)
-- rounded butt end
local bx, by = gx0 + ux * GL, gy0 + uy * GL
local butt = A.ell(bx, by, 2.4, 2.4)
butt:each(function(x, y) if not gripM:has(x, y) then
  local dx, dy = x - bx, y - by local l = sqrt(dx * dx + dy * dy) + 0.6
  gripM:set(x, y) gripN[K(x, y)] = { A.norm(dx / l, dy / l, 0.75) } gripT[K(x, y)] = 1 gripS[K(x, y)] = (dx * -uy + dy * ux) / 3
end end)
-- normals for the grip: flatten a little so the top face reads
for k, n in pairs(gripN) do gripN[k] = { A.norm(n[1] * 0.85, n[2] * 0.85, n[3] + 0.15) } end
local collarM = HP.mask()
gripM:each(function(x, y) local t = gripT[K(x, y)] if t and t < 0.13 then collarM:set(x, y) end end)

-- paint handle
do
  local bias = {}
  -- AO where neck and grip run under the pan wall
  X.ao(bias, neckM, pan, 2, -1)
  X.ao(bias, gripM, collarM, 1, -1)
  local nidx = A.shade(c, neckM, neckN, FE, { bias = bias, tok = tFE, amb = 0.1 })
  local wm = gripM:copy():cut(collarM)
  local widx = A.shade(c, wm, gripN, WOOD, { bias = bias, tok = tWD, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  -- grain: two wavy dark lines along the grip + one lit fleck line
  wm:each(function(x, y) local k = K(x, y) local t, s = gripT[k], gripS[k]
    if t and s and t > 0.16 and t < 0.97 then
      local w1 = -0.35 + 0.12 * sin(t * 19)
      local w2 = 0.30 + 0.10 * sin(t * 13 + 1)
      if abs(s - w1) < 0.13 then A.step(c, widx, WOOD, x, y, -1, tWD) end
      if abs(s - w2) < 0.12 and t > 0.3 and t < 0.8 then A.step(c, widx, WOOD, x, y, -1, tWD) end
    end end)
  A.shade(c, collarM, gripN, BR, { tok = tBR, cuts = { 0.25, 0.45, 0.65, 0.85 } })
  -- collar edge line toward the wood + rivet
  wm:each(function(x, y) if collarM:has(x - 1, y) or collarM:has(x, y - 1) then c:put(x, y, WOOD[1], tWD) end end)
  local rx, ry = floor(gx0 + ux * 1.0 + 0.5), floor(gy0 + uy * 1.0 + 0.5)
  c:put(rx, ry, BR[5], tBR) c:put(rx + 1, ry + 1, BR[1], tBR)
  -- hanging hole near the butt: dark eye, lit lower-right lip
  local hx, hy = floor(gx0 + ux * (GL - 1.5) + 0.5), floor(gy0 + uy * (GL - 1.5) + 0.5)
  for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do c:put(hx + p[1], hy + p[2], A.INK, tWD) end
  c:put(hx - 1, hy, WOOD[2], tWD) c:put(hx, hy - 1, WOOD[2], tWD)
  c:put(hx + 2, hy + 1, WOOD[6], tWD) c:put(hx + 1, hy + 2, WOOD[6], tWD)
end

-- pan normals
local nrm = A.hnorm(top, function(x, y) return prof(rr(x, y)) end, 0.9)
side:each(function(x, y)
  local th = atan((y - CY) / RY, (x - CX) / RX)
  nrm[K(x, y)] = { A.norm(cos(th), 0.5 * sin(th), 0.85 * max(0.15, sin(th)) + 0.15) }
end)
local bias = {}
-- side wall: bottom row deep (ambient where it meets the stove/ground)
side:each(function(x, y) if not side:has(x, y + 1) then bias[K(x, y)] = -1 end end)
-- rim shadow on the floor and lower inner wall (light from the upper left)
top:each(function(x, y)
  local r = rr(x, y)
  if r < 0.70 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end
  if r < 0.80 then
    local rs = rr(x - 1.6, y - 2.0)
    if rs >= 0.80 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end
  end
end)
-- egg masks (needed for the contact shadow before the iron is painted)
local ex, ey = CX - 1, CY + 0.5
local white = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = (x - ex) / 8.6, (y - ey) / 6.4
  local th = atan(dy, dx)
  local R = 1 + 0.10 * sin(3 * th + 0.8) + 0.06 * sin(5 * th + 2.1)
  if sqrt(dx * dx + dy * dy) <= R then white:set(x, y) end
end end
A.cast(bias, top, white, 1, 1, -1)
A.cast(bias, top, white, 2, 1, -1)
local idx = A.shade(c, pan, nrm, FE, { bias = bias, tok = tFE, amb = 0.06, wrap = 0.2, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
-- floor: a faint seasoning ring (one tone darker, broken)
top:each(function(x, y) local r = rr(x, y)
  if abs(r - 0.58) < 0.035 and X.hash(x, y, 9) > 0.45 and not white:grow(1):has(x, y) then A.step(c, idx, FE, x, y, -1, tFE) end end)
-- bright machined edge on the rim crest, upper-left arc; specular streak inside it
top:each(function(x, y) local r = rr(x, y)
  local th = atan((y - CY) / RY, (x - CX) / RX)
  if r > 0.86 and r < 0.93 and th < -1.35 and th > -2.75 then c:put(x, y, FE[6], tFE) end
  if r > 0.87 and r < 0.92 and th < -1.85 and th > -2.35 then c:put(x, y, A.CREAM, tFE) end
end)
-- front lip: one lit row where rim meets the side wall
side:each(function(x, y) if top:has(x, y - 1) and x < CX - 3 then c:put(x, y, FE[4], tFE) end end)

-- egg white
local wn = X.pillow(white, 2.2)
local wb = {}
local yolkM = HP.mask()
do -- heart-shaped yolk (hand-drawn mask)
  local rows = { ".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." }
  local hx, hy = floor(ex - 2.5), floor(ey - 3)
  for j, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) == "X" then yolkM:set(hx + i - 1, hy + j - 1) end end end
end
A.cast(wb, white, yolkM, 1, 1, -1)
local widx = A.shade(c, white, wn, EGG, { bias = wb, tok = tEG, amb = 0.25, wrap = 0.4, cuts = { 0.15, 0.3, 0.47, 0.64, 0.86 } })
-- lacy browned edge on the lower-right rim of the white
white:edge():each(function(x, y) if (x - ex) + (y - ey) > 3 and X.hash(x, y, 2) > 0.35 then c:put(x, y, LACE, tEG) end end)
-- yolk: domed, glossy
local yn = X.pillow(yolkM, 2.6, 1.4)
A.shade(c, yolkM, yn, YOLK, { tok = tYK, amb = 0.08, wrap = 0.2, cuts = { 0.18, 0.34, 0.52, 0.7, 0.86 } })
-- glint (2x1) + cream sparkle pixel on the upper-left lobe
local sx, sy = floor(ex - 2.5) + 1, floor(ey - 3) + 1
for _, p in ipairs{ { 0, 0 }, { 1, 0 } } do if yolkM:has(sx + p[1], sy + p[2]) then c:put(sx + p[1], sy + p[2], YOLK[6], tYK) end end
if yolkM:has(sx, sy + 1) then c:put(sx, sy + 1, A.CREAM, tYK) end

A.save(c, "ico-cooking-pan")

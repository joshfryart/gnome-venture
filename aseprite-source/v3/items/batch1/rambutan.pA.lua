-- rambutan (pass A, Opus). One round fruit on a short woody stalk, covered in soft hooked spines (red, green tips).
-- Material: sphere light (6-tone crimson), rind tubercles each with a hooked spine (lit/dark side), outer spines
-- following the curve, cool reflected light lower-right, one glossy specular.
-- quirk: a torn window in the rind shows the glossy pearl flesh inside.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rambutan" }
local floor, sin, cos, pi, max, min, sqrt = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local RIND  = { "#4a1530", "#74203a", "#a3303e", "#cc4440", "#e8663f", "#ff9a5a" }
local TIPG  = { "#4f8a3e", "#8fc04e", "#c9e070" }
local PEARL = { "#9aa7b8", "#c9d1d8", "#e8ecea", "#fbf8ee" }
local STEM  = { "#3f2a22", "#5e4030", "#86603e", "#a9824f" }
local CX, CY, R = 31.5, 36.5, 9.5

-- stalk (behind)
local sm, sn = G.tube({ {32, 27}, {32, 23}, {33, 21}, {35, 19} }, function(t) return 1.3 - 0.3 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), STEM, { 0.3, 0.55, 0.8 })
c:px(36, 18, STEM[4])

-- outer spines: short hooked curves around the rim (clockwise hook)
local spines = {}
local NS = 22
for i = 0, NS - 1 do
  local a = (i + 0.5 * (i % 2)) / NS * 2 * pi
  if not (a > 4.45 and a < 4.9) then                      -- gap at the top where the stalk joins
    local L = 6 + (i % 3 == 0 and 1 or 0)
    local pts = {}
    for j = 0, L do
      local rr = R - 1 + j
      local aa = a + j * j * 0.012 + (j >= L - 1 and 0.1 or 0)
      pts[#pts + 1] = { floor(CX + cos(aa) * rr + .5), floor(CY + sin(aa) * rr + .5) }
    end
    spines[#spines + 1] = { pts = pts, a = a }
  end
end
for _, s in ipairs(spines) do
  local lit = -cos(s.a) * 0.6 - sin(s.a) * 0.75
  local col = lit > 0.3 and RIND[5] or (lit > -0.3 and RIND[4] or RIND[3])
  local tip = lit > 0.0 and TIPG[3] or (lit > -0.5 and TIPG[2] or TIPG[1])
  local m = c:line(s.pts, 1)
  m:each(function(x, y) c:px(x, y, col) end)
  local p = s.pts[#s.pts] c:px(p[1], p[2], tip)
end

-- body
local body = c:ellipse(CX, CY, R, R)
local n = X.sphere(CX - 0.6, CY - 0.6, R, body)
local v = X.light(n, { amb = 0.05, wrap = 0.2 })
local idx = G.tone(c, body, v, RIND, { 0.2, 0.36, 0.52, 0.68, 0.84 })
-- tubercles: jittered grid, each a hooked mark: dark crease below-right, lit dot above-left, green-tipped hook
for gy = -12, 12, 4 do for gx = -12, 12, 4 do
  local x = floor(CX + gx + ((gy // 4) % 2) * 2 + (X.hash(gx, gy, 1) - 0.5) * 1.6 + .5)
  local y = floor(CY + gy + (X.hash(gx, gy, 2) - 0.5) * 1.6 + .5)
  local k = K(x, y)
  if body:shrink(1):has(x, y) then
    local i = idx[k]
    c:px(x, y, RIND[max(1, i - 2)])
    if body:has(x + 1, y) then c:px(x + 1, y, RIND[max(1, i - 1)]) end
    if body:has(x - 1, y - 1) then c:px(x - 1, y - 1, RIND[min(6, i + 1)]) end
    if i >= 4 and body:has(x, y - 1) then c:px(x, y - 1, TIPG[i >= 5 and 3 or 2]) end
  end
end end
-- hairs lying over the face: short curved strokes
for gy = -8, 8, 4 do for gx = -8, 8, 4 do
  local x0 = CX + gx + ((gy // 4) % 2) * 2 + 1
  local y0 = CY + gy - 1
  local a = math.atan(y0 - CY, x0 - CX) + 0.6
  local pts = {}
  for j = 0, 2 do pts[#pts + 1] = { floor(x0 + cos(a) * j + .5), floor(y0 + sin(a) * j + .5) } end
  local inside = true
  for _, p in ipairs(pts) do if not body:shrink(1):has(p[1], p[2]) then inside = false end end
  if inside then
    local i = idx[K(pts[1][1], pts[1][2])]
    G.line(c, pts, RIND[min(6, i + 1)])
    c:px(pts[3][1], pts[3][2], i >= 4 and TIPG[3] or TIPG[1])
  end
end end
-- cool reflected light
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.75 then c:px(x, y, "#8a4a80") end end)
-- specular
c:px(26, 31, "#fff1dc") c:px(27, 31, "#fff1dc") c:px(26, 32, RIND[6])

-- quirk: torn window, pearl flesh
local win = c:ellipse(35, 40, 3.5, 3)
local wn = X.sphere(34, 39, 5, win)
G.tone(c, win, X.light(wn, { amb = 0.2, wrap = 0.3 }), PEARL, { 0.3, 0.55, 0.78 })
win:grow(1):cut(win):each(function(x, y) if body:has(x, y) then
  c:px(x, y, (y > 40) and "#f2c8b4" or RIND[1]) end end)       -- rind thickness on the lower lip, dark shadow on the upper
c:px(33, 38, "#fdfcf6") c:px(34, 38, "#fdfcf6")
G.fin(c, "rambutan.pA")

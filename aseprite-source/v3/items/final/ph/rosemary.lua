-- rosemary (final pass, Sonnet). One slim arching woody sprig with a short side shoot, both clothed in stiff
-- forward-swept needle leaves: dark glossy green on the lit face, silvery-grey underside on the shade face, drawn in
-- two depth layers (far needles behind the stem, near needles over it). Ruddy bark with a cut pale base, and small
-- blue-violet two-lipped flowers on little stalks (lit lip, dark throat).
-- quirk: a tiny bee is perched on one of the flowers.
local NAME = "rosemary"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, atan2, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.atan, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local NEED = { "#1c4a34", "#2a6840", "#3f8a4a", "#5eae58", "#86cc72", "#b4e89a" }
local SILV = "#b4d0c4"
local BARK = { "#3a2420", "#5a382c", "#7e5238", "#a2704a", "#c89466", "#e8bc88" }
local FLOW = { "#2c2a6a", "#443fa6", "#6663d8", "#8a89f0", "#b4b6ff", "#dcdeff" }
local ntok, btok, ftok = { r = { name = "needle" } }, { r = { name = "bark" } }, { r = { name = "flower" } }

local main = { { 18, 55 }, { 19, 38 }, { 28, 26 }, { 43, 13 } }
local sx0, sy0 = G.bez(main, 0.3)
local shoot = { { sx0, sy0 }, { 15, 38 }, { 11, 31 }, { 11, 22 } }

local function frame(p, t)
  local x, y = G.bez(p, t)
  local x2, y2 = G.bez(p, min(1, t + 0.01))
  local x1, y1 = G.bez(p, max(0, t - 0.01))
  return x, y, atan2(y2 - y1, x2 - x1)
end
-- needles along a sprig. side = -1 / 1 picks the far / near layer
local function needles(p, t0, t1, step, L0, side)
  local t = t0 + (side > 0 and step / 2 or 0)
  while t <= t1 do
    local x, y, a = frame(p, t)
    local L = L0 * (1 - 0.42 * t)
    A.needle(c, x, y, a + side * 0.55, L, 0.75, NEED, ntok, { silver = (side > 0) and SILV or nil, bias = (side < 0) and -1 or 0 })
    t = t + step
  end
end
local function stem(p, w0, w1, cutBase)
  local m, n, T = G.tube(p, function(t) return w0 + (w1 - w0) * t end)
  local idx = X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), BARK, { cuts = A.CUTS, tok = btok })
  m:each(function(x, y) local k = K(x, y)
    if cutBase and T[k] < 0.04 then c:put(x, y, (x + y) % 2 == 0 and "#f4e2b8" or "#e8cc98", btok)
    elseif X.hash(x, y, 5) > 0.88 then c:put(x, y, BARK[max(1, (idx[k] or 3) - 1)], btok) end end)
  return m
end

-- far layer, stems, near layer
needles(main, 0.1, 1.0, 0.04, 9, -1) needles(shoot, 0.12, 1.0, 0.07, 7, -1)
stem(shoot, 1.0, 0.5, false) stem(main, 1.5, 0.7, true)
needles(main, 0.1, 1.0, 0.04, 9, 1) needles(shoot, 0.12, 1.0, 0.07, 7, 1)
do local x, y, a = frame(main, 1.0) A.needle(c, x, y, a, 4.5, 0.7, NEED, ntok) end
do local x, y, a = frame(shoot, 1.0) A.needle(c, x, y, a, 3.8, 0.7, NEED, ntok) end

-- flowers on little stalks
local fl = { { main, 0.5, 1 }, { main, 0.74, 1 }, { main, 0.86, -1 }, { main, 0.97, 1 }, { shoot, 0.66, -1 }, { shoot, 0.92, 1 } }
local flowerAt = {}
for i, f in ipairs(fl) do
  local x, y, a = frame(f[1], f[2])
  local nx, ny = -sin(a) * f[3], cos(a) * f[3]
  local fx, fy = x + nx * 5, y + ny * 5
  A.line(c, x, y, fx, fy, NEED[3], ntok)
  local m, n = G.oval(fx, fy, 1.9, 1.4, a + pi / 2 + 0.3 * f[3], 0.9)
  G.toneN(c, m, n, FLOW, { tok = ftok, cuts = A.CUTS, amb = 0.12, wrap = 0.3 })
  local ix, iy = floor(fx + 0.5), floor(fy + 0.5)
  -- lower lip + dark throat
  local lx, ly = floor(fx + nx * 1.6 + 0.5), floor(fy + ny * 1.6 + 0.5)
  if m:has(lx, ly) then c:put(lx, ly, FLOW[5], ftok) end
  c:put(ix, iy, FLOW[1], ftok)
  local sx, sy = G.specAt(m, n, 20)
  if sx and (sx ~= ix or sy ~= iy) then c:put(sx, sy, FLOW[6], ftok) end
  flowerAt[i] = { floor(fx + 0.5), floor(fy + 0.5) }
end

-- quirk: a bee perched on the third flower
local bx, by = flowerAt[3][1] + 1, flowerAt[3][2] - 5
local bt = { r = { name = "bee" } }
c:put(bx + 1, by, "#e6f2ff", bt) c:put(bx + 2, by, "#e6f2ff", bt) c:put(bx + 2, by - 1, "#c4dcf2", bt)
local body = { "#ffd54a", "#3a2a1a", "#ffd54a", "#3a2a1a", "#241810" }
for i, col in ipairs(body) do c:put(bx + i - 1, by + 1, col, bt) end
c:put(bx + 1, by + 2, "#e0a830", bt) c:put(bx + 2, by + 2, "#3a2a1a", bt) c:put(bx + 3, by + 2, "#c88a20", bt)
c:put(bx + 4, by + 2, "#6a4a22", bt)
G.save2(c, NAME)

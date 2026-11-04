-- minnow (final, Opus single pass). Slim little fish swimming right with a slight head-up curve: countershaded olive
-- back, silver flanks with a scale lattice, cream belly, dark lateral stripe under a thin gold line, gill arc, eye
-- with glint, forked tail with rays, dorsal, anal and pectoral fins (6-tone translucent amber, AO where they meet).
-- quirk: a tiny duckweed frond is stuck on its head.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("minnow")
local SIL  = { "#2c3a4e", "#46607a", "#6f8fa2", "#9fbcc4", "#cfe2df", "#f1f8ec" }
local BACK = { "#1d2a22", "#2c4030", "#40583a", "#5c7444", "#7e9254", "#a8b26c" }
local BELLY = { "#5a5a78", "#8a8aa2", "#b8b8c4", "#dcd8d2", "#f0ead8", "#fff8e8" }
local FIN  = { "#4a3020", "#7a4e26", "#a87430", "#cc9a44", "#e8c068", "#f8e2a0" }
local INK, SPEC = "#2b1c26", "#fff4d6"
local ftok = { r = { name = "fin" } }

local p = { { 15, 36 }, { 25, 33.5 }, { 39, 29.5 }, { 51, 28.5 } }
local function hw(t) return 1.7 + 3.9 * sin(pi * min(1, t * 0.86 + 0.04)) ^ 0.75 end
local function at(t, s) -- point on the body at param t, side s (-1 top .. 1 bottom), relative to half width
  local x, y = A.bez(p, t)
  local x2, y2 = A.bez(p, min(1, t + 0.01))
  local x1, y1 = A.bez(p, max(0, t - 0.01))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx*tx + ty*ty)
  local px, py = -ty / l, tx / l
  if px + py < 0 then px, py = -px, -py end
  local w = hw(t) * s
  return x + px * w, y + py * w
end

-- fins first (body paints over their roots)
local function fin(poly, rays, rayDir)
  local m = c:poly(poly)
  local n = X.pillow(m, 1.5)
  local idx = A.shade(c, m, n, FIN, { tok = ftok, amb = 0.15, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- rays: every other line from the root
  m:each(function(x, y) local k = K(x, y)
    if rays(x, y) then c:put(x, y, FIN[max(1, (idx[k] or 3) - 1)], ftok) end end)
  return m
end
-- tail (forked)
local tx0, ty0 = at(0, 0)
local tail = fin({ { 16, 34 }, { 8, 26 }, { 5, 27 }, { 10, 36 }, { 5, 45 }, { 8, 46 }, { 16, 38 } },
  function(x, y) return (y - 36) % 3 == 0 and x < 14 end)
-- dorsal
local dx, dy = at(0.5, -1)
local dors = fin({ { floor(dx) - 4, floor(dy) + 2 }, { floor(dx) + 1, floor(dy) - 6 }, { floor(dx) + 3, floor(dy) - 6 }, { floor(dx) + 5, floor(dy) + 2 } },
  function(x, y) return (x - y) % 3 == 0 end)
-- anal fin
local ax, ay = at(0.3, 1)
local anal = fin({ { floor(ax) - 3, floor(ay) - 2 }, { floor(ax) - 5, floor(ay) + 4 }, { floor(ax) - 2, floor(ay) + 4 }, { floor(ax) + 4, floor(ay) - 2 } },
  function(x, y) return (x + y) % 3 == 0 end)
-- pelvic
local vx, vy = at(0.55, 1)
local pelv = fin({ { floor(vx) - 2, floor(vy) - 2 }, { floor(vx) - 5, floor(vy) + 3 }, { floor(vx) - 2, floor(vy) + 3 }, { floor(vx) + 3, floor(vy) - 2 } },
  function(x, y) return (x + y) % 3 == 1 end)

-- body
local m, n, T, S, samp = A.tube(p, hw)
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local bias = {}
-- AO on fins next to the body
for _, fm in ipairs{ tail, dors, anal, pelv } do
  fm:each(function(x, y) if m:grow(1):has(x, y) and not m:has(x, y) then c:put(x, y, FIN[1], ftok) end end)
end
local btok = { r = { name = "body" } }
local idx = X.tone(c, m, v, SIL, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = btok })
m:each(function(x, y) local k = K(x, y)
  local s, t, i = S[k], T[k], idx[k]
  if s < -0.42 + 0.08 * sin(x * 0.9) then c:put(x, y, BACK[i], btok)
  elseif s > 0.5 then c:put(x, y, BELLY[min(6, i + 1)], btok) end
  -- scale lattice on the flank
  if s > -0.42 and s < 0.45 and t > 0.12 and t < 0.74 and ((x + 2 * y) % 5 == 0) and (x % 2 == 0) then
    c:put(x, y, SIL[max(1, i - 1)], btok) end
end)
-- lateral stripe (dark) with a thin gold line above
m:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  if t > 0.06 and t < 0.8 then
    local off = 0.08 + 0.05 * sin(t * 6)
    if abs(s - off) < 0.11 then c:put(x, y, "#34405a", btok)
    elseif s < off and s > off - 0.26 and t > 0.15 and t < 0.75 then c:put(x, y, "#e2b85a", btok) end
  end
end)
-- gill arc
for i = -6, 6 do
  local s = i / 7
  local gx, gy = at(0.79 - 0.035 * (1 - s * s), s * 0.8)
  c:put(floor(gx + .5), floor(gy + .5), SIL[2], btok)
end
-- mouth
local mx, my = at(0.995, 0.15)
c:put(floor(mx + .5), floor(my + .5), "#3a2a3a", btok)
c:put(floor(mx - .5), floor(my + .5), "#3a2a3a", btok)
-- eye
local ex, ey = at(0.9, -0.28)
ex, ey = floor(ex + .5), floor(ey + .5)
A.map(c, { ".gg.", "gKKg", "gKKg", ".gg." }, ex - 1, ey - 1, { g = "#e8c868", K = INK })
c:put(ex, ey, SPEC)
-- body sheen + cool bounce on the belly
local sx, sy = at(0.62, -0.2)
c:put(floor(sx), floor(sy), BELLY[6], btok) c:put(floor(sx) + 1, floor(sy), BELLY[6], btok) c:put(floor(sx) + 2, floor(sy), SPEC, btok)
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.6 and S[k] > 0.7 and T[k] > 0.2 and T[k] < 0.9 then c:put(x, y, "#a6a0d6", btok) end end)

-- pectoral fin over the body behind the gill
local qx, qy = at(0.74, 0.35)
qx, qy = floor(qx), floor(qy)
local pect = c:poly{ { qx, qy - 1 }, { qx + 1, qy }, { qx - 5, qy + 4 }, { qx - 6, qy + 3 } }
A.shade(c, pect, X.pillow(pect, 1.2), FIN, { tok = { r = { name = "pect" } }, amb = 0.2 })
pect:shift(1, 1):each(function(x, y) if m:has(x, y) and not pect:has(x, y) then
  local k = K(x, y) c:put(x, y, SIL[max(1, (idx[k] or 3) - 2)], btok) end end)

-- quirk: duckweed frond stuck on the head
local hx, hy = at(0.86, -1)
hx, hy = floor(hx + .5), floor(hy + .5)
A.map(c, { ".LL.ll", "LLlLlD", ".DD.." }, hx - 2, hy - 2, { L = "#8ed05a", l = "#5aa040", D = "#2e6a34" })

A.save(c, "minnow")

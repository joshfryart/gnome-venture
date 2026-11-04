-- natto (final, Opus single pass). A slim indigo rice bowl with a pale seigaiha wave band and an unglazed bisque
-- foot, heaped with glossy amber soybeans laced with sticky strands and two scallion rings. A pair of wood
-- chopsticks with red-lacquered grips pinch one bean above the heap.
-- quirk: the lifted bean drags two long sagging threads of natto goo back down to the heap.
local NAME = "natto"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC25_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GL = { "#1b1c40", "#262f6c", "#33499a", "#4466be", "#6a94da", "#a9c9f0" }
local BIS = { "#4a2e2a", "#77503e", "#a47d5c", "#ccab82" }
local BEAN = { "#3a1f20", "#62351f", "#8d5428", "#b77833", "#d9a055", "#f4d08c" }
local WOOD = { "#4a2a22", "#74432d", "#9e6639", "#c48a4e", "#e2b378", "#f6daa4" }
local LAC = { "#4a1424", "#7a1f2c", "#a82d33", "#d24a3a", "#ee7a58", "#ffb08a" }
local GOO, GOOS = "#f2e8cf", "#c7b592"
local CX, RY0 = 32, 35

local function ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / (rx + .4))^2 + ((y - cy) / (ry + .4))^2 <= 1 then m:set(x, y) end end end
  return m
end

-- ground shadow (drawn first, everything solid sits over it)
c:groundShadow(CX, 51, 14, 1)

-- bowl body: rounded wall from the rim down to the foot
local outer, inner = ell(CX, RY0, 19, 5), ell(CX, RY0, 17, 3.6)
local body = HP.mask()
local function bw(y) local t = (y - RY0) / 13.6 return 19 * sqrt(max(0, 1 - t * t)) end
for y = RY0, 47 do local w = bw(y) for x = floor(CX - w - 1), floor(CX + w + 1) do
  if abs(x - CX) <= w + 0.2 then body:set(x, y) end end end
body:add(outer:copy()):cut(inner)
local bn = {}
body:each(function(x, y)
  local w = max(bw(y), 6)
  local nx = (x - CX) / (w + 0.8)
  local ny = max(-0.2, (y - RY0) / 14) * 0.9
  bn[K(x, y)] = { A.norm(nx, ny, sqrt(max(0.05, 1 - nx * nx - ny * ny))) }
end)
-- foot ring (unglazed)
local foot = HP.mask()
for y = 47, 50 do local w = 8 - (y - 47) * 0.4 for x = floor(CX - w), floor(CX + w) do foot:set(x, y) end end
local bias = {}
X.ao(bias, body, foot, 1, -1)
local btok = { r = { name = "bowl" } }
local bvis = body:copy():cut(foot)
local bidx = A.shade(c, bvis, bn, GL, { tok = btok, bias = bias, amb = 0.1, wrap = 0.3 })
-- lip: the rim ring between outer and inner ellipse, facing up
local lip = outer:copy():cut(inner)
lip:each(function(x, y)
  local front = y >= RY0
  local lx = (x - CX) / 19
  local i = front and (lx < -0.35 and 6 or lx < 0.45 and 5 or 4) or (lx < 0.3 and 5 or 4)
  if not front and abs(lx) < 0.75 then i = i - 1 end
  c:put(x, y, GL[i], btok)
end)
-- dark row just under the front lip (ambient where lip turns into the wall)
for x = CX - 18, CX + 18 do
  local y = floor(RY0 + 5 * sqrt(max(0, 1 - ((x - CX) / 19.4)^2)) + 1.5)
  if bvis:has(x, y) and not lip:has(x, y) then A.step(c, bidx, GL, x, y, -1, btok) end
end
-- seigaiha wave band
for x0 = CX - 17, CX + 14, 4 do
  for _, q in ipairs{ { 0, 42 }, { 1, 41 }, { 2, 41 }, { 3, 42 } } do
    local x, y = x0 + q[1], q[2]
    if bvis:has(x, y) and bvis:has(x - 1, y) and bvis:has(x + 1, y) then
      local i = bidx[K(x, y)] or 3
      c:put(x, y, i >= 4 and "#d8e6f6" or i >= 3 and "#93acd6" or "#5f74ad", btok)
    end
  end
end
-- glaze specular streak on the lit flank
for _, q in ipairs{ { 17, 38, "#e8f3ff" }, { 17, 39, GL[6] }, { 18, 40, GL[6] }, { 18, 41, GL[6] }, { 19, 43, GL[5] } } do
  if bvis:has(q[1], q[2]) then c:put(q[1], q[2], q[3], btok) end
end
-- foot
local ftok = { r = { name = "foot" } }
foot:each(function(x, y)
  local i = (y == 47) and 1 or (x < CX - 4 and 4 or x < CX + 3 and 3 or 2)
  if y == 50 and i > 2 then i = i - 1 end
  c:put(x, y, BIS[i], ftok)
end)

-- interior (dark glaze), beans heaped over it
inner:each(function(x, y) c:put(x, y, (y < RY0 - 1) and GL[2] or GL[3], btok) end)
local dome = HP.mask()
for y = 18, RY0 do for x = CX - 18, CX + 18 do
  if ((x - CX) / 16.5)^2 + ((y - RY0) / 11.5)^2 <= 1 then dome:set(x, y) end end end
local allowed = inner:copy():add(dome)
local rows = {
  { 24, { 29, 34 } },
  { 27, { 24, 29, 34, 39 } },
  { 30, { 19, 24, 29, 34, 39, 44 } },
  { 33, { 16, 21, 26, 31, 36, 41, 46 } },
  { 36, { 20, 25, 30, 35, 40, 45 } },
}
local beanM = HP.mask()
local function bean(cx, cy, ang, tokname, clip)
  local m, n = A.oval(cx, cy, 2.5, 1.8, ang, 0.9)
  if clip then m:clip(clip) end
  local g = m:grow(1):clip(beanM):cut(m)
  if clip then g:clip(clip) end
  g:each(function(x, y) c:put(x, y, BEAN[1], { r = { name = "beans" } }) end)
  local idx = A.shade(c, m, n, BEAN, { tok = { r = { name = tokname } }, amb = 0.1, wrap = 0.25 })
  -- hilum: tiny dark seed-eye on a few beans
  beanM:add(m)
  return m, idx
end
local seed = 0
for _, r in ipairs(rows) do
  for _, x in ipairs(r[2]) do
    seed = seed + 1
    local jx = floor(X.hash(x, r[1], 3) * 3) - 1
    local jy = floor(X.hash(x, r[1], 7) * 2)
    local ang = (X.hash(x, r[1], 11) - 0.5) * 1.6
    local m = bean(x + jx, r[1] + jy, ang, "beans", allowed)
    if seed % 4 == 1 then
      local bx, by = x + jx + 1, r[1] + jy + 1
      if m:has(bx, by) then c:put(bx, by, BEAN[2], { r = { name = "beans" } }) end
    end
  end
end
-- front lip redrawn over the beans
lip:each(function(x, y)
  if y >= RY0 then
    local lx = (x - CX) / 19
    c:put(x, y, GL[lx < -0.35 and 6 or lx < 0.45 and 5 or 4], btok)
  end
end)
-- shadow line on the beans just behind the front lip
inner:each(function(x, y) if y >= RY0 and lip:has(x, y + 1) then c:put(x, y, BEAN[1], btok) end end)

-- scallion rings
local SC = { h = "#c8ec8a", g = "#6cba4e", d = "#2f6a3a", p = "#eef8cc" }
A.map(c, { "hgg", "gpd", "gdd" }, 26, 24, SC, { r = { name = "scallion" } })
A.map(c, { "hgg", "gpd", "gdd" }, 41, 29, SC, { r = { name = "scallion" } })

-- sticky strands across the heap
local gtok = { r = { name = "goo" } }
for _, s in ipairs{
  { { 21, 30 }, { 23, 29 }, { 26, 29 } },
  { { 32, 26 }, { 35, 25 }, { 37, 26 } },
  { { 38, 32 }, { 41, 33 }, { 43, 33 } },
  { { 24, 36 }, { 27, 35 }, { 30, 36 } },
} do A.poly1(c, s, function(x, y, i) return i == 1 and GOO or GOOS end, gtok) end

-- quirk: lifted bean + two sagging goo threads back to the heap (drawn before the sticks)
A.poly1(c, { { 37, 16 }, { 35, 19 }, { 34, 22 }, { 33, 24 } }, function(x, y, i) return i < 3 and GOO or GOOS end, gtok)
A.poly1(c, { { 40, 17 }, { 41, 20 }, { 40, 23 }, { 38, 26 } }, function(x, y, i) return i < 2 and GOO or GOOS end, gtok)
local lifted = bean(38, 14, -0.5, "lifted")
c:put(37, 13, "#fff4d6", { r = { name = "lifted" } })
c:put(35, 15, GOOS, gtok) c:put(34, 16, GOOS, gtok)  -- goo film dripping off the bean's lit end

-- chopsticks: wood with grain, lacquered grip ends; tips pinch the bean
local function stick(ax, ay, bx, by, name)
  local pts = { { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } }
  local m, n, T, S = A.tube(pts, function(t) return 1.35 - t * 0.5 end)
  local edge = m:grow(1):cut(m):clip(lifted)
  edge:each(function(x, y) c:put(x, y, BEAN[1], { r = { name = "lifted" } }) end)
  local tok = { r = { name = name } }
  local idx = A.shade(c, m, n, WOOD, { tok = tok, amb = 0.12, wrap = 0.35 })
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if t < 0.22 then c:put(x, y, LAC[idx[k]], tok)
    elseif t < 0.25 then c:put(x, y, WOOD[min(6, idx[k] + 1)], tok)
    elseif s > 0.1 and (t * len) % 5 < 0.9 then c:put(x, y, WOOD[max(1, idx[k] - 1)], tok) end
  end)
  return m
end
stick(58, 3, 39, 12.5, "stickA")
stick(60, 8, 41, 17, "stickB")

A.save(c, NAME)

-- feast-riverside-bake (Opus single pass, aB30_4). A whole slim river trout baked golden on a long pewter platter:
-- crisp spotted back, silvery belly, three scored cuts, fanned tail and dorsal fin with rays, two lemon wheels laid
-- along its back and dill fronds scattered on the platter.
-- Material: per-pixel tube light on the fish (6-tone skin ramp blended into a 6-tone belly ramp), scores with a dark
-- cut and lit lip, bevelled pewter rim with a specular and darker well, AO under the fish, rind/pith/segment lemons.
-- quirk: the trout holds a dill sprig in its mouth like a little pipe.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.pi
local NAME = "feast-riverside-bake"
local c = A.new2(NAME)
local PEW  = { "#3e4260", "#5c6282", "#8088a6", "#a6aec4", "#c8d0de", "#e8ecf2" }
local SKIN = { "#4a2418", "#7a3e1e", "#a8622a", "#cc8a3c", "#e8b060", "#f8d894" }
local BELLY = { "#6a3c3c", "#9a6258", "#c89480", "#e4bc9c", "#f2d8bc", "#fcf0dc" }
local FIN  = { "#3e1e18", "#6a3420", "#94542a", "#b87438", "#d89a50", "#f0c27a" }
local LEM  = { "#8a6a10", "#c49a14", "#e8c42a", "#f6dc4a", "#fcec8a", "#fff8cc" }
local DILL = { "#24543a", "#3f8a4a", "#7cc35a", "#b4e07a" }
local CX, CY, RX, RY = 32, 41, 23, 8.5

c:groundShadow(CX, CY + RY + 2, RX - 1, 2)
-- platter: front thickness, rim, well
local top = A.ell(CX, CY, RX, RY)
local well = A.ell(CX, CY + 0.3, RX - 3.5, RY - 2.6)
top:shift(0, 2):cut(top):each(function(x, y) c:put(x, y, top:shift(0, 2):has(x, y + 1) and PEW[3] or PEW[2]) end)
A.pil(c, top:copy():cut(well), PEW, 1.2, { wrap = 0.3 })
-- fish masks first (for the cast shadow in the well)
local P = { { 12, 36 }, { 21, 31.5 }, { 36, 31.5 }, { 46, 36 } }
local function hw(t)
  if t < 0.1 then return 3.4 + (t / 0.1) * 2.4 end
  return 1.4 + 4.4 * ((1 - t) / 0.9) ^ 0.8
end
local fm, fn, FT, FS, samp = A.tube(P, hw)
local tail = HP.poly({ { 44, 36 }, { 53, 27 }, { 56, 30 }, { 52, 36 }, { 56, 42 }, { 53, 45 } })
local dors = HP.poly({ { 24, 29 }, { 27, 25 }, { 33, 25 }, { 35, 29 } })
local pec = HP.poly({ { 18, 37 }, { 24, 38 }, { 20, 42 } })
local wb = {}
well:each(function(x, y) wb[K(x, y)] = -1 end)
A.cast(wb, well, fm:copy():add(tail), 1, 2, -2)
A.shadeN(c, well, X.pillow(well, 2), PEW, { bias = wb, wrap = 0.4, amb = 0.2 })
c:put(CX - RX + 4, CY - 4, PEW[6]) c:put(CX - RX + 5, CY - 5, "#f8fafc")
-- dill fronds on the platter
local function frond(x, y, dir)
  A.dots(c, { { x, y }, { x + dir, y - 1 }, { x + 2 * dir, y - 1 }, { x + 3 * dir, y - 2 } }, DILL[2])
  A.dots(c, { { x + dir, y - 2 }, { x + 2 * dir, y }, { x + 3 * dir, y - 3 } }, DILL[3])
  c:put(x + 4 * dir, y - 2, DILL[4])
end
frond(14, 45, 1) frond(42, 46, 1) frond(50, 41, -1) frond(30, 46, -1)
-- fins (behind the body)
local function fins(m, x0, x1)
  local idx = A.shadeN(c, m, X.pillow(m, 1.2), FIN, { wrap = 0.3 })
  m:each(function(x, y) if (x + y) % 3 == 0 and (idx[K(x, y)] or 1) > 2 then c:put(x, y, FIN[(idx[K(x, y)]) - 1]) end end)
end
fins(tail) fins(dors)
-- body: skin on the back, silver on the belly
local v = X.light(fn, { amb = 0.08, wrap = 0.25 })
local cuts = A.CUTS
fm:each(function(x, y) local k = K(x, y)
  local val = v[k] or 0
  local i = 1
  for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end
  local s = FS[k]
  if FT[k] < 0.06 then i = max(1, i - 1) end
  c:put(x, y, (s > 0.15 and BELLY or SKIN)[i])
  if s > 0.05 and s <= 0.15 then c:put(x, y, BELLY[max(1, i - 1)]) end
end)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- trout spots on the back
fm:each(function(x, y) local k = K(x, y)
  if FS[k] < -0.15 and FT[k] > 0.25 and FT[k] < 0.9 and A.hash(x, y, 4) > 0.86 then c:put(x, y, SKIN[2]) end end)
-- scored cuts (dark cut, lit lip)
for _, ct in ipairs{ 0.36, 0.5, 0.64 } do
  fm:each(function(x, y) local k = K(x, y)
    local s = FS[k]
    if s > -0.85 and s < 0.25 then
      local d = FT[k] * LEN - ct * LEN + s * 2.2
      if d > -0.5 and d < 0.5 then c:put(x, y, SKIN[1])
      elseif d >= 0.5 and d < 1.5 and s < 0 then c:put(x, y, SKIN[6]) end
    end
  end)
end
-- gill arc + head shading
fm:each(function(x, y) local k = K(x, y)
  local d = FT[k] * LEN - 0.17 * LEN - abs(FS[k]) * 1.4
  if d > -0.5 and d < 0.5 and abs(FS[k]) < 0.85 then c:put(x, y, SKIN[2]) end end)
fins(pec)
-- cooked eye + mouth
A.dots(c, { { 13, 33 }, { 14, 33 }, { 15, 33 }, { 13, 34 }, { 15, 34 }, { 13, 35 }, { 14, 35 }, { 15, 35 } }, "#ece6da") c:put(14, 34, "#3a3446") c:put(13, 33, "#fffcf2")
A.dots(c, { { 12, 32 }, { 13, 32 }, { 14, 32 }, { 15, 32 } }, SKIN[2])
A.dots(c, { { 9, 37 }, { 10, 37 }, { 11, 37 } }, SKIN[1])
-- specular on the back
A.dots(c, { { 19, 30 }, { 20, 30 } }, "#fff1cf")
-- lemon wheels along the back
local function lemon(cx, cy)
  local m = A.ell(cx, cy, 2.8, 2)
  A.pil(c, m, LEM, 1)
  local e = m:edge()
  e:each(function(x, y) c:put(x, y, (y > cy or x > cx + 1) and LEM[2] or LEM[4]) end)
  local inn = m:copy():cut(e)
  inn:each(function(x, y)
    local a = math.atan(y - cy, (x - cx) * 0.7)
    local sp = abs(((a / (pi / 3)) % 1) - 0.5) > 0.38
    c:put(x, y, sp and LEM[6] or LEM[5])
  end)
  c:put(floor(cx), floor(cy), LEM[6])
  c:put(floor(cx) - 1, floor(cy) - 1, "#fffcea")
end
lemon(29, 29.5) lemon(37, 30.5)
-- quirk: dill sprig in the mouth like a pipe
A.dots(c, { { 9, 38 }, { 8, 39 }, { 7, 40 }, { 6, 40 } }, DILL[1])
A.dots(c, { { 5, 39 }, { 6, 38 }, { 5, 41 } }, DILL[2])
A.dots(c, { { 4, 40 }, { 5, 38 } }, DILL[3])
c:put(4, 39, DILL[4])
A.save2(c, NAME)

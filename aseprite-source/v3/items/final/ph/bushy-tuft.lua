-- bushy-tuft (final, Opus aB13_3 single pass). A bushy tuft of tawny fur: eight slim tapered locks fanning out of a
-- red twine binding (diagonal twist), each lock with strand grooves along its length, sun-bleached tips, back locks a
-- step darker, contact shadow where locks overlap; a short brush of cut ends under the binding (paler end grain).
-- quirk: a little green burdock burr has hooked itself into one of the upper locks.
local NAME = "bushy-tuft"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local FUR = { "#3c2028", "#5e3428", "#8a5532", "#b8803e", "#d9a95a", "#f2d48c" }
local TW = { "#4a1f2e", "#7a2c36", "#a83e3a", "#d0603e", "#ec8c58", "#ffbf86" }
local BUR = { "#26301c", "#3e4c22", "#5e702c", "#86963a", "#b2bc56", "#dce28a" }
local ftok = { r = { name = "fur" } }
local IDX, ALL = {}, HP.mask()

local function lock(ax, ay, cx, cy, bx, by, W, back, seed)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, W * (0.5 + 0.5 * sin(pi * min(t * 1.25, 1))) * (1 - t ^ 3))
  end, { fold = 0.25 })
  local b = {}
  m:each(function(x, y) local k = K(x, y)
    if back then b[k] = -1 end
    if T[k] > 0.82 then b[k] = (b[k] or 0) + 1 end
  end)
  local idx = A.shade(c, m, n, FUR, { tok = ftok, bias = b, amb = 0.1, wrap = 0.35, cuts = { 0.12, 0.28, 0.45, 0.62, 0.8 } })
  local off = X.hash(seed, 1, 3)
  m:each(function(x, y) local k = K(x, y)
    local g = ((S[k] + 1) * W * 0.6 + off + T[k] * 0.8) % 1
    local i = idx[k]
    if abs(g - 0.5) < 0.13 and T[k] > 0.1 and T[k] < 0.9 then i = max(1, i - 1)
    elseif abs(g - 0.1) < 0.06 and S[k] < 0 and T[k] > 0.2 and T[k] < 0.75 then i = min(6, i + 1) end
    c:put(x, y, FUR[i], ftok)
    idx[k] = i
  end)
  -- contact shadow on earlier locks just below/right of this one
  m:shift(1, 1):each(function(x, y) local k = K(x, y)
    if ALL:has(x, y) and not m:has(x, y) and IDX[k] then
      IDX[k] = max(1, IDX[k] - 2) c:put(x, y, FUR[IDX[k]], ftok) end end)
  for k, i in pairs(idx) do IDX[k] = i end
  ALL:add(m)
  return m, T, S
end
-- back locks
lock(31, 47, 23, 37, 10, 31, 3.3, true, 1)
lock(33, 47, 42, 37, 54, 29, 3.3, true, 2)
local mU, TU, SU = lock(31, 46, 26, 30, 19, 14, 3.6, true, 3)
local mR, TR, SR = lock(33, 46, 39, 30, 46, 13, 3.6, true, 4)
-- front locks
lock(31, 47, 21, 40, 13, 44, 2.8, false, 5)
lock(33, 47, 44, 40, 52, 44, 2.8, false, 6)
lock(32, 46, 30, 34, 27, 21, 3.0, false, 7)
lock(32, 46, 32, 27, 36, 8, 3.9, false, 8)

-- binding: red twine wrap with a diagonal twist
local ttok = { r = { name = "twine" } }
local tm = c:rrect(28, 45, 36, 50, 1)
A.shade(c, tm, X.pillow(tm, 2.2), TW, { tok = ttok, amb = 0.1, wrap = 0.3 })
tm:each(function(x, y) if (x + y) % 3 == 0 and y > 45 and y < 50 then
  local cur = c:get(x, y) c:put(x, y, x < 33 and TW[3] or TW[2], ttok) end end)
c:put(30, 46, TW[6], ttok) c:put(31, 46, TW[6], ttok)
-- ambient shading on fur just above the binding
for x = 28, 36 do if ALL:has(x, 44) then c:put(x, 44, FUR[2], ftok) end end
-- loose twine end (dangling)
for _, p in ipairs{ { 37, 49, 4 }, { 38, 50, 3 }, { 38, 51, 3 }, { 39, 52, 2 } } do c:put(p[1], p[2], TW[p[3]], ttok) end

-- cut ends under the binding: short brush with paler cut tips
local etok = { r = { name = "ends" } }
for x = 29, 35 do
  local h = 53 + ((x * 7) % 3 == 0 and 1 or 0)
  for y = 51, h do
    local i = (x <= 30) and 4 or ((x >= 34) and 2 or 3)
    if x % 2 == 0 then i = i - 1 end
    if y == 51 then i = 1 end
    if y == h then i = (x % 2 == 0) and 5 or 6 end
    c:put(x, y, FUR[max(1, i)], etok)
  end
end

-- quirk: burdock burr hooked into the upper right lock
local bm, bn = A.oval(41.5, 22.5, 2.6, 2.4, 0, 0.8)
local btok = { r = { name = "burr" } }
-- shadow on fur
bm:shift(1, 1):each(function(x, y) local k = K(x, y)
  if ALL:has(x, y) and not bm:has(x, y) and IDX[k] then c:put(x, y, FUR[max(1, IDX[k] - 2)], ftok) end end)
A.shade(c, bm, bn, BUR, { tok = btok, amb = 0.1, wrap = 0.25 })
bm:each(function(x, y) if (x * 3 + y * 5) % 4 == 0 then c:put(x, y, BUR[2], btok) end end)
c:put(40, 21, BUR[6], btok)
for _, p in ipairs{ { 41, 19, 4 }, { 38, 22, 4 }, { 44, 23, 2 }, { 42, 25, 2 }, { 39, 20, 5 }, { 44, 20, 3 } } do c:put(p[1], p[2], BUR[p[3]], btok) end

A.fin(c, NAME)

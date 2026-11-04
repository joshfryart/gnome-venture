-- fox-fang (B32, Opus single pass). One slim, gently hooked fox canine: glossy ivory enamel crown (cool shade,
-- specular streak, cool reflected edge, faint growth lines), a darker cemento-enamel line, and a longer amber root
-- with grain lines. The root is drilled and a twisted leather thong runs through it, knotted, two frayed tails.
-- quirk: a tiny crescent moon is scratched into the root.
local NAME = "fox-fang"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local IVORY = { "#4a3c52", "#7a6c7a", "#aa9c94", "#d2c4a8", "#ece2c6", "#fbf4de" }
local ROOT = { "#4a2826", "#76422e", "#9e6438", "#c28a4e", "#ddb06e", "#f0d296" }
local COOL = "#93a4c0"
local LEATH = { "#3e2228", "#6a3a2c", "#965a38", "#be8452" }

-- tooth axis: root lower-left, hooked tip upper-right
local P = { { 20, 55 }, { 19, 40 }, { 28, 22 }, { 44, 12 } }
local CEJ = 0.42
local tm, tn, TT, TS = G.tube(P, function(t)
  if t < CEJ then return 2.9 + 1.2 * (t / CEJ) end
  return max(0.35, 4.3 * (1 - (t - CEJ) / (1 - CEJ)) ^ 0.8)
end, 160)
local crown, root = HP.mask(), HP.mask()
tm:each(function(x, y) if TT[K(x, y)] >= CEJ then crown:set(x, y) else root:set(x, y) end end)

-- thong goes behind the root first (back strand)
local hx, hy = G.bez(P, 0.13) hx, hy = floor(hx + .5), floor(hy + .5)
local function cord(pts, w, startTone)
  local m, n, T = G.tube(pts, function() return w end, 80)
  m:cut(tm)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local i = floor(v[k] * 3.2) + 1
    -- twist: diagonal bands along the cord
    if floor(T[k] * 26 + (x - y) * 0.25) % 2 == 0 then i = i - 1 end
    c:put(x, y, LEATH[max(1, min(4, i))])
  end)
  return m
end
local kx, ky = hx - 9, hy - 4
local back = cord({ { hx, hy }, { hx - 3, hy - 4 }, { kx + 3, ky - 2 }, { kx, ky } }, 1.0)

local bias = {}
-- ambient dark on the root where the crown flares over it
X.ao(bias, root, crown, 1, -1)
local ridx = G.shade(c, root, tn, ROOT, { bias = bias, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
-- root grain: broken lines along the length
root:each(function(x, y) local k = K(x, y)
  local s = TS[k]
  if abs(s - 0.25) < 0.12 or abs(s + 0.35) < 0.1 then
    if X.hash(x, floor(y / 2), 7) > 0.35 then c:put(x, y, ROOT[max(1, ridx[k] - 1)]) end
  end
end)
local cidx = G.shade(c, crown, tn, IVORY, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.1, wrap = 0.3 })
-- cemento-enamel line: the crown's lowest pixel row in a darker ivory
crown:each(function(x, y) local k = K(x, y) if TT[k] < CEJ + 0.025 then c:put(x, y, IVORY[max(1, cidx[k] - 2)]) end end)
-- growth lines (perikymata) across the crown, faint
crown:each(function(x, y) local k = K(x, y)
  local t = TT[k]
  if t > CEJ + 0.06 and t < 0.8 and (floor(t * 60) % 6 == 0) and TS[k] > -0.2 and TS[k] < 0.7 then
    c:put(x, y, IVORY[max(1, cidx[k] - 1)]) end
end)
-- specular streak along the lit flank
crown:each(function(x, y) local k = K(x, y)
  local t, s = TT[k], TS[k]
  if s > -0.6 and s < -0.32 and t > CEJ + 0.08 and t < 0.86 then c:put(x, y, IVORY[6]) end
end)
-- cool reflected light on the shade edge of the crown
crown:edge():each(function(x, y) local k = K(x, y) if TS[k] > 0.62 and TT[k] > CEJ + 0.05 and TT[k] < 0.9 then c:put(x, y, COOL) end end)

-- drilled hole: dark core, lit lower-right inner wall
c:put(hx, hy, "#2b1c26") c:put(hx, hy - 1, "#3a2228") c:put(hx - 1, hy, "#3a2228")
c:put(hx + 1, hy, ROOT[5]) c:put(hx, hy + 1, ROOT[5]) c:put(hx - 1, hy - 1, ROOT[1])

-- front strand from the hole to the knot (over the root), knot, two frayed tails
local front = cord({ { hx - 1, hy + 1 }, { hx - 4, hy + 2 }, { kx - 1, ky + 3 }, { kx, ky } }, 1.0)
for _, q in ipairs{ { kx - 1, ky - 1, 2 }, { kx, ky - 1, 3 }, { kx - 1, ky, 2 }, { kx, ky, 4 }, { kx + 1, ky, 2 }, { kx, ky + 1, 1 }, { kx - 1, ky + 1, 1 } } do
  c:put(q[1], q[2], LEATH[q[3]]) end
local function tail(pts)
  local m, n, T = G.tube(pts, function(t) return 0.6 end, 40)
  m:each(function(x, y) local k = K(x, y)
    local i = (floor(T[k] * 9) % 2 == 0) and 3 or 2
    if T[k] > 0.85 then i = 4 end
    c:put(x, y, LEATH[i]) end)
end
tail({ { kx - 1, ky + 1 }, { kx - 3, ky + 5 }, { kx - 3, ky + 8 }, { kx - 5, ky + 11 } })
tail({ { kx, ky + 1 }, { kx + 1, ky + 5 }, { kx, ky + 8 }, { kx + 1, ky + 12 } })
-- frayed ends: two hair pixels each
c:put(kx - 6, ky + 12, LEATH[4]) c:put(kx - 4, ky + 12, LEATH[3])
c:put(kx + 2, ky + 13, LEATH[4]) c:put(kx, ky + 13, LEATH[3])

-- quirk: scratched crescent moon on the root
do local mx, my = G.bez(P, 0.27) mx, my = floor(mx + .5), floor(my + .5)
  for _, q in ipairs{ { -1, -1 }, { -1, 0 }, { -1, 1 }, { 0, -2 }, { 0, 2 } } do c:put(mx + q[1], my + q[2], ROOT[2]) end
  c:put(mx, my - 1, ROOT[6]) end
-- one cream glint high on the crown
do local x, y = G.bez(P, 0.62) x, y = floor(x - 1.5), floor(y - 1.2)
  if crown:has(x, y) then c:put(x, y, "#fff4d6") end end

G.save(c, NAME)

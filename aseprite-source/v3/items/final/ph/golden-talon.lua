-- golden-talon (Opus single pass, aB35_1). A single gilded raptor talon worn as a charm: a slim crescent hook rising from
-- a cord-wrapped root, tip curling down to the right.
-- Material: polished metal on a tube normal field (6-tone gold, violet-brown shade), bright bevel edge along the outer
-- curve, Blinn specular streak + one cream glint, a keratin groove down the side (dark line + lit lip), cool reflected
-- light on the inner curve. Root: gold collar ring, then leather cord wound in a twist (diagonal grooves), AO under the
-- collar; two cord ends hang from the knot.
-- quirk: a tiny blue jay feather is tied to one of the cord ends.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "golden-talon"
local c = G.new2(NAME)
local GOLD = { "#4e2420", "#8f4a1f", "#c7731e", "#eba22a", "#fbd04a", "#fff0a6" }
local CORD = { "#3e1f22", "#6e2a2c", "#9a3e30", "#c45e3a", "#e48a56" }
local FEA = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local SPEC, COOL = "#fff8e2", "#b07a6a"

-- cord ends + feather first (they hang behind/below the root)
local ctok = { r = { name = "cord" } }
local ends = { { { 23, 51 }, { 24, 54 }, { 26, 57 }, { 27, 59 } }, { { 25, 51 }, { 28, 53 }, { 31, 54 }, { 34, 54 } } }
for e, pts in ipairs(ends) do
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for s = 0, n do
      local x, y = floor(a[1] + (b[1] - a[1]) * s / n + .5), floor(a[2] + (b[2] - a[2]) * s / n + .5)
      c:put(x, y, ((x + y) % 2 == 0) and CORD[4] or CORD[3], ctok)
    end
  end
end
-- frayed tip on the first end
c:put(26, 60, CORD[5], ctok) c:put(28, 60, CORD[4], ctok)
-- quirk: blue jay feather tied on the second end
local fm, fn, FT, FS = G.blade(34, 54, 39, 52, 44, 49, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 2.1 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.6)
end, { fold = 0.3 })
local ftok = { r = { name = "feather" } }
local fidx = X.tone(c, fm, X.light(fn, { amb = 0.15, wrap = 0.3 }), FEA, { cuts = { 0.3, 0.55, 0.8 }, tok = ftok })
fm:each(function(x, y) local k = K(x, y)
  if abs(FS[k]) < 0.18 then c:put(x, y, "#e4f6ff", ftok) return end         -- pale quill
  local band = floor(FT[k] * 9 + abs(FS[k]) * 1.2)
  if band % 3 == 0 and FT[k] > 0.2 then c:put(x, y, "#2b2440", ftok) end     -- jay bars
end)
c:put(34, 54, CORD[2], ctok) c:put(35, 54, CORD[2], ctok)                     -- binding

-- claw
local p = { { 22, 49 }, { 11, 30 }, { 27, 8 }, { 46, 22 } }
local function hw(t) return 5.3 * (1 - t) ^ 0.82 + 0.35 end
local m, n, T, S, samp = G.tube(p, hw)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
local WRAP, COL = 0.12, 0.165
local claw, root, collar = HP.mask(), HP.mask(), HP.mask()
m:each(function(x, y) local t = T[K(x, y)]
  if t < WRAP then root:set(x, y) elseif t < COL then collar:set(x, y) else claw:set(x, y) end end)
-- root: leather cord wound in a twist
local bias = {}
X.ao(bias, root, collar, 1, -1)
local v = X.light(n, { amb = 0.06, wrap = 0.25 })
local ridx = X.tone(c, root, v, CORD, { cuts = { 0.22, 0.42, 0.62, 0.82 }, bias = bias, tok = ctok })
root:each(function(x, y) local k = K(x, y)
  local d = (T[k] * LEN + S[k] * 2.4) / 2.2
  local f = d - floor(d)
  if f < 0.3 then c:put(x, y, CORD[max(1, ridx[k] - 1)], ctok)
  elseif f < 0.55 and S[k] < 0.3 then c:put(x, y, CORD[min(5, ridx[k] + 1)], ctok) end
end)
-- collar: bright ring with dark seams
local gtok = { r = { name = "gold" } }
local cidx = X.tone(c, collar, v, GOLD, { cuts = { 0.12, 0.25, 0.42, 0.6, 0.78 }, tok = gtok })
collar:each(function(x, y) local k = K(x, y)
  local tl = (T[k] - WRAP) * LEN
  local tr = (COL - T[k]) * LEN
  if tl < 0.7 or tr < 0.7 then c:put(x, y, GOLD[max(1, cidx[k] - 2)], gtok) end
end)
-- claw body: polished gold
local cb = {}
X.ao(cb, claw, collar, 1, -1)
local idx = X.tone(c, claw, v, GOLD, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = cb, tok = gtok })
-- keratin groove down the side
claw:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  if t > 0.22 and t < 0.86 then
    if abs(s - 0.28) < 0.12 then c:put(x, y, GOLD[max(1, idx[k] - 2)], gtok)
    elseif abs(s - 0.48) < 0.1 and t < 0.75 then c:put(x, y, GOLD[min(6, idx[k] + 1)], gtok) end
  end
end)
-- bevel edge: bright line on the outer (lit) curve, cool bounce on the inner curve
claw:edge():each(function(x, y) local k = K(x, y)
  if S[k] < -0.72 and T[k] > 0.2 and T[k] < 0.9 and idx[k] >= 4 then c:put(x, y, GOLD[6], gtok) end
  if S[k] > 0.72 and T[k] > 0.25 and T[k] < 0.85 then c:put(x, y, COOL, gtok) end
end)
-- specular streak + glint on the shoulder of the hook
local sp = X.spec(n, 24)
claw:each(function(x, y) local k = K(x, y) if sp[k] > 0.78 and T[k] > 0.25 and T[k] < 0.7 then c:put(x, y, GOLD[6], gtok) end end)
local gx, gy = G.at(samp, 0.42, -0.45)
c:put(gx, gy, SPEC, gtok) c:put(gx + 1, gy, SPEC, gtok)
-- needle tip: darkest point
local tx, ty = G.at(samp, 1, 0) c:put(tx, ty, GOLD[2], gtok)
-- knot under the root
for _, q in ipairs{ { 23, 50, 2 }, { 24, 50, 3 }, { 24, 51, 2 } } do c:put(q[1], q[2], CORD[q[3]], ctok) end
G.save2(c, NAME)

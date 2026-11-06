-- fox-pelt (B32, Opus single pass). A tanned red-fox pelt laid flat, seen from the fur side: pointed head with
-- dark-backed ears, white cheeks and an ink nose, empty eye slits; slim legs splayed out ending in black socks;
-- a darker dorsal stripe; short fur strokes; the hide curls up on the lower-right showing pale suede.
-- The brush (tail) sweeps out lower-right with a cream tip and casts a contact shadow on the body.
-- quirk: a little green burr is caught in the tail fur.
local NAME = "fox-pelt"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local FUR = { "#5a1e2e", "#8e2e2a", "#c04824", "#e26c2a", "#f59a44", "#ffc777" }
local WHITE = { "#5e4a5c", "#968294", "#c6b5b4", "#e6dace", "#f8efe0" }
local SOCK = { "#2f1e28", "#48303a", "#6a4a4c" }
local SUEDE = { "#b88a66", "#e2c39c" }

local core = HP.mask()
local body = G.oval(31, 33, 7.2, 12.2, 0)
local head = G.oval(31, 18, 5.2, 4.4, 0)
local muzzle = c:poly{ { 28, 18 }, { 34, 18 }, { 32, 9 }, { 30, 9 } }
local earL = c:poly{ { 25, 17 }, { 29, 14 }, { 21, 8 } }
local earR = c:poly{ { 37, 17 }, { 33, 14 }, { 41, 8 } }
core:add(body):add(head):add(muzzle):add(earL):add(earR)
local legs, LT = {}, {}
local function leg(p)
  local m, n, T = G.tube(p, function(t) return 1.75 - 0.35 * t end, 60)
  core:add(m)
  m:each(function(x, y) LT[K(x, y)] = T[K(x, y)] end)
  legs[#legs + 1] = m
end
leg({ { 26, 25 }, { 22, 25 }, { 18, 27 }, { 14, 31 } })
leg({ { 36, 25 }, { 40, 25 }, { 44, 27 }, { 48, 31 } })
leg({ { 26, 40 }, { 22, 42 }, { 19, 44 }, { 16, 48 } })
leg({ { 36, 40 }, { 40, 42 }, { 43, 44 }, { 46, 48 } })

-- tail first defines the overlap; body shading gets AO from it
local TP = { { 31, 43 }, { 32, 53 }, { 40, 58 }, { 51, 54 } }
local tm, tn, TT, TS = G.tube(TP, function(t) return 1.8 + 3.0 * sin(pi * min(1, t * 1.05 + 0.04)) ^ 0.7 end, 140)
local coreVis = core:copy():cut(tm)
local bias = {}
X.ao(bias, coreVis, tm, 1, -1)
G.cast(bias, coreVis, tm, 1, 1, -1)
-- dorsal stripe
coreVis:each(function(x, y) if abs(x - 31) <= 1 and y >= 21 and y <= 43 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
local cn = X.pillow(core, 3)
local idx = G.shade(c, coreVis, cn, FUR, { bias = bias, cuts = { 0.12, 0.28, 0.46, 0.64, 0.82 }, amb = 0.15, wrap = 0.35 })
-- fur strokes: short 2px dark ticks and a few light ones, running down the body
coreVis:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 11)
  if h > 0.86 and coreVis:has(x, y + 1) then
    c:put(x, y, FUR[max(1, idx[k] - 1)]) c:put(x, y + 1, FUR[max(1, (idx[K(x, y + 1)] or idx[k]) - 1)])
  elseif h < 0.06 and idx[k] >= 3 then c:put(x, y, FUR[min(6, idx[k] + 1)]) end
end)
-- legs: black socks on the lower half
for _, m in ipairs(legs) do m:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.55 and not tm:has(x, y) then c:put(x, y, SOCK[max(1, min(3, (idx[k] or 3) - 2))]) end end) end
-- ears: dark backs toward the tips
earL:copy():add(earR):each(function(x, y) if y <= 11 then local k = K(x, y) c:put(x, y, SOCK[max(1, min(3, (idx[k] or 3) - 2))]) end end)
-- white cheeks and chin either side of the muzzle base
head:each(function(x, y) local dx = abs(x - 31)
  if y >= 18 and dx >= 2 and dx <= 4 then local k = K(x, y) c:put(x, y, WHITE[max(1, min(5, (idx[k] or 3)))]) end end)
-- nose tip (ink with cream glint) and empty eye slits
c:put(30, 9, "#2b1c26") c:put(31, 9, "#2b1c26") c:put(30, 10, "#2b1c26") c:put(31, 10, "#3a2630") c:put(30, 9, "#fff4d6")
for _, q in ipairs{ { 28, 16 }, { 29, 16 }, { 33, 16 }, { 34, 16 } } do c:put(q[1], q[2], "#3a1e26") end
c:put(28, 15, FUR[2]) c:put(34, 15, FUR[2])
-- suede: hide curls up along the lower-right of the body edge
body:edge():each(function(x, y)
  local u = (x - 31) / 7.2 + (y - 33) / 12.2 * 0.7
  if u > 0.72 and not tm:has(x, y) and not core:copy():cut(body):has(x, y) then c:put(x, y, u > 0.95 and SUEDE[1] or SUEDE[2]) end
end)

-- tail: tube light, fur strokes along it, cream tip
local tv = X.light(tn, { amb = 0.14, wrap = 0.35 })
tm:each(function(x, y) local k = K(x, y)
  local cuts = { 0.12, 0.28, 0.46, 0.64, 0.82 }
  local i = 1 for j, t in ipairs(cuts) do if tv[k] >= t then i = j + 1 end end
  local t = TT[k]
  if floor(t * 30 + TS[k] * 3) % 3 == 0 and X.hash(x, y, 5) > 0.4 then i = i - 1 end
  if t > 0.86 then c:put(x, y, WHITE[max(1, min(5, i - 1))])
  elseif t > 0.8 then c:put(x, y, FUR[max(1, i - 1)])
  else c:put(x, y, FUR[max(1, min(6, i))]) end
end)

-- quirk: burr in the tail
do local bx, by = G.bez(TP, 0.5) bx, by = floor(bx + .5), floor(by - 1.5)
  c:put(bx, by, "#6a8a2e") c:put(bx - 1, by, "#8aac3c") c:put(bx, by - 1, "#a8c856") c:put(bx + 1, by, "#4a6224") c:put(bx, by + 1, "#4a6224")
  c:put(bx - 1, by - 1, "#3a4a20") c:put(bx + 1, by + 1, "#3a4a20") c:put(bx + 1, by - 1, "#3a4a20") c:put(bx - 1, by + 1, "#3a4a20")
end

G.save(c, NAME)

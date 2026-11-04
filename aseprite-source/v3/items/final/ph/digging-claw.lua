-- digging-claw (final pass, Opus). Gnome hand cultivator on the diagonal: slim turned wooden handle (grain lines, pale
-- end grain cap, dark hang hole), brass ferrule with two raised rings and a rivet, then three hooked steel tines that
-- splay and curl down like talons (per-pixel tube light, bright bevel edge, specular streak, darker tips worn dull,
-- AO where the tines meet the head).
-- quirk: a clod of soil is stuck on the lowest tine, and a seedling has already sprouted from it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local OUT = app.params.out or (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/")
local c = A.new("digging-claw")

local WOOD  = { "#4a2a24", "#74452e", "#9a6438", "#bd844a", "#dba566", "#f0c78c" }
local BRASS = { "#5e3417", "#8f5a1f", "#c0862c", "#e3b347", "#f6d877", "#fff2b0" }
local STEEL = { "#2f3048", "#4a4c66", "#6f7290", "#9a9db4", "#c7c9d8", "#eef0f6" }
local SOIL  = { "#2e1c1c", "#4e3028", "#6e4632", "#8e6040" }
local SPROUT = { "#2f7a46", "#5fae52", "#a6d86e" }

-- tines first (head/ferrule painted over their roots)
local ttok = { r = { name = "steel" } }
local tines = {
  { { 35, 28 }, { 42, 16 }, { 50, 10 }, { 54, 17 } },
  { { 36, 29 }, { 46, 22 }, { 55, 21 }, { 56, 29 } },
  { { 35, 31 }, { 44, 31 }, { 51, 34 }, { 49, 42 } },
}
local tm = HP.mask()
for i, p in ipairs(tines) do
  local m, n, T, S = A.tube(p, function(t) return 1.7 * (1 - t) ^ 0.7 + 0.35 end)
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.12 then bias[k] = -1 end if T[k] > 0.9 then bias[k] = (bias[k] or 0) - 1 end end)
  local idx = A.shade(c, m, n, STEEL, { amb = 0.08, wrap = 0.2, bias = bias, tok = ttok })
  -- bevel: bright lit edge + specular streak on the curve's shoulder
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.55 and T[k] > 0.15 and T[k] < 0.75 then c:put(x, y, STEEL[5], ttok) end
    if S[k] > 0.6 and T[k] > 0.2 and T[k] < 0.8 then c:put(x, y, (i == 3) and "#5b5f86" or STEEL[2], ttok) end end)
  tm:add(m)
end
-- one specular glint per tine shoulder (glossy metal)
c:put(43, 15, STEEL[6], ttok) c:put(48, 21, STEEL[6], ttok) c:put(44, 30, STEEL[6], ttok)
c:put(44, 16, A.CREAM, ttok)

-- head: curved bridge the tines are forged from
local htok = { r = { name = "head" } }
local head = c:ellipse(35, 30, 3.2, 3.6)
local hn = X.sphere(34.6, 29.6, 3.6, head)
A.shade(c, head, hn, STEEL, { amb = 0.08, wrap = 0.2, tok = htok })
-- AO where tines leave the head
tm:each(function(x, y) if not head:has(x, y) and head:grow(1):has(x, y) then c:put(x, y, STEEL[2], ttok) end end)

-- wooden handle (lower-left), half-width 2, swelling to a rounded butt
local wtok = { r = { name = "wood" } }
local hm, hn2, HT, HS = X.cyl(13, 53, 31, 34, function(t)
  if t < 0.08 then return 1.9 + t * 6 end
  if t < 0.22 then return 2.4 - (t - 0.08) * 3 end
  return 2.0 end)
local hb = {}
hm:each(function(x, y) local k = K(x, y) if HT[k] > 0.94 then hb[k] = -1 end end)
local wi = A.shade(c, hm, hn2, WOOD, { amb = 0.1, wrap = 0.25, bias = hb, tok = wtok })
-- grain lines along the shaft, broken
hm:each(function(x, y) local k = K(x, y) local s, t = HS[k], HT[k]
  if t > 0.12 and t < 0.92 and (abs(s - 0.25) < 0.14 or abs(s + 0.45) < 0.12) and X.hash(x, y, 3) > 0.3 then
    A.step(c, wi, WOOD, x, y, -1, wtok) end end)
-- pale end grain cap at the butt + growth ring
local cap = c:ellipse(13.6, 52.4, 2.1, 2.1):clip(hm)
cap:each(function(x, y) c:put(x, y, WOOD[6], wtok) end)
c:put(13, 52, WOOD[4], wtok) c:put(14, 53, WOOD[5], wtok) c:put(15, 53, WOOD[3], wtok) c:put(14, 54, WOOD[3], wtok)
-- hang hole
c:put(17, 48, WOOD[1], wtok) c:put(18, 48, A.INK, wtok) c:put(17, 49, A.INK, wtok) c:put(18, 49, WOOD[2], wtok)
-- spec on the handle
c:put(20, 42, WOOD[6], wtok) c:put(21, 41, WOOD[6], wtok)

-- brass ferrule between handle and head
local ftok = { r = { name = "brass" } }
local fm, fn, FT, FS = X.cyl(29, 36, 34, 31, function() return 2.6 end)
local fi = A.shade(c, fm, fn, BRASS, { amb = 0.08, wrap = 0.22, tok = ftok })
fm:each(function(x, y) local k = K(x, y) local t = FT[k]
  if abs(t - 0.33) < 0.1 or abs(t - 0.8) < 0.1 then A.step(c, fi, BRASS, x, y, -2, ftok)
  elseif abs(t - 0.5) < 0.09 or abs(t - 0.97) < 0.07 then A.step(c, fi, BRASS, x, y, 1, ftok) end end)
-- rivet
c:put(31, 33, BRASS[1], ftok) c:put(30, 33, BRASS[6], ftok)
-- AO on the wood where it enters the ferrule
hm:each(function(x, y) if not fm:has(x, y) and fm:grow(1):has(x, y) then c:put(x, y, WOOD[1], wtok) end end)

-- quirk: soil clod on the lowest tine with a seedling
local stok = { r = { name = "soil" } }
local clod = c:ellipse(49.5, 36.5, 2.6, 2):add(c:ellipse(47.5, 37.5, 1.5, 1.2))
local cn = X.pillow(clod, 1.5)
local ci = A.shade(c, clod, cn, SOIL, { amb = 0.1, wrap = 0.3, tok = stok, cuts = { 0.3, 0.55, 0.78 } })
for _, p in ipairs{ { 48, 37 }, { 50, 35 }, { 51, 37 } } do c:put(p[1], p[2], (p[1] % 2 == 0) and SOIL[4] or SOIL[1], stok) end
local gtok = { r = { name = "sprout" } }
c:put(50, 34, SPROUT[1], gtok) c:put(50, 33, SPROUT[2], gtok) c:put(50, 32, SPROUT[2], gtok)
c:put(49, 31, SPROUT[2], gtok) c:put(48, 31, SPROUT[3], gtok) c:put(48, 30, SPROUT[3], gtok)
c:put(51, 31, SPROUT[2], gtok) c:put(52, 31, SPROUT[1], gtok) c:put(52, 30, SPROUT[2], gtok)

A.finish(c, "digging-claw", OUT)

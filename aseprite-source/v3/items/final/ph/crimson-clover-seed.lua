-- crimson-clover-seed (final pass, Opus). Five tiny glossy crimson-clover seeds (rounded kidney ovals, amber to
-- red-brown) scattered on a torn, broad clover leaflet (pale chevron watermark, netted veins, cool shade edge).
-- One seed has sprouted: hairy pale stem, two round cotyledons, and a first trifoliate clover leaf (three obovate
-- leaflets each with its own pale V mark).
-- quirk: a tiny crimson flower spike has already bloomed on the seedling, far too early.
local NAME = "crimson-clover-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_4.lua")
local G, HP, X, K = A, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#173f3a", "#1f5a42", "#2c7848", "#46984e", "#70b85a", "#a4d474" }
local CHEV = "#b9dc8a"
local SEED = { "#4a1e24", "#7a2e26", "#a8482a", "#d07a32", "#eeaa4c", "#ffe08a" }
local STEM = { "#3f7a4e", "#78ae66", "#aed48a", "#dcefb4" }
local RED = { "#5e1530", "#931e36", "#c92c3e", "#ec4f4c", "#ff8670", "#ffc0a0" }

local seeds = { { 14, 50, 2.6, 1.9, 0.3 }, { 21, 47, 2.6, 1.9, -0.5 }, { 27, 51, 2.5, 1.8, 0.1 },
                { 41, 46, 2.5, 1.8, 0.9 }, { 34, 46, 2.7, 2.0, -0.2 } }
local sm = {}
for i, s in ipairs(seeds) do sm[i] = (G.oval(s[1], s[2], s[3], s[4], s[5], 0.8)) end

-- scrap: broad obovate leaflet lying flat, torn across the base
local lm, LT, LS = A.scrap(c, LEAF, 6, 52, 26, 40, 52, 47, 9.5, {
  casters = sm, tear0 = 0.12, seed = 4, veins = "net", vs = 4.2, sweep = 1.4,
  wfn = function(t) if t > 0.99 then return -1 end return max(0.6, 9.5 * sin(pi * min(1, 0.12 + t * 0.88)) ^ 0.45) end })
-- pale chevron watermark (crimson clover leaflets carry a faint V)
lm:each(function(x, y) local k = K(x, y)
  local d = abs(LT[k] - (0.42 + abs(LS[k]) * 0.14))
  if d < 0.022 and abs(LS[k]) > 0.18 and abs(LS[k]) < 0.7 then
    local p = c:get(x, y)
    if p ~= LEAF[1] then c:put(x, y, LS[k] < 0 and CHEV or LEAF[5], { r = { name = "scrap" } }) end
  end end)

-- sprout from seed 5: stem, cotyledons, trifoliate leaf
local stok = { r = { name = "stem" } }
local sp = { { 34, 45 }, { 33, 38 }, { 35, 31 }, { 34, 24 } }
local stm = A.stem(c, sp, function(t) return 1.0 end, STEM, { cut = sm[5], tok = stok })
-- hairs: pale 1px spikes alternating along the stem
for i = 2, 9 do local x, y = G.bez(sp, i / 10) local sd = (i % 2 == 0) and -1 or 1
  local hx, hy = floor(x + 0.5) + sd * 2, floor(y + 0.5)
  if not stm:has(hx, hy) then c:put(hx, hy, sd < 0 and STEM[4] or STEM[2], stok) end end
local function round(ax, ay, bx, by, w)
  local mx, my = (ax + bx) / 2, (ay + by) / 2
  return A.leaf(c, ax, ay, mx + (ay - by) * 0.1, my, bx, by, w, LEAF, { pw = 0.5, vs = 9, cut = stm })
end
local c1 = round(33, 36, 25, 33, 2.4)
local c2 = round(36, 34, 43, 33, 2.4)
-- trifoliate: three obovate leaflets on a short common point
local tri = HP.mask()
local LF = {}
for i, a in ipairs{ -0.95, 0, 0.95 } do
  local ux, uy = G.rot(0, -1, a)
  local bx, by = 34 + ux * 9, 22 + uy * 9
  local m, T, S = A.leaf(c, 34 + ux * 1, 23 + uy * 1, 34 + ux * 6 + uy * 0.6, 22 + uy * 6, bx, by, 3.6, LEAF,
    { wfn = function(t) if t > 0.97 then return -1 end return max(0.6, 3.6 * sin(pi * min(1, 0.06 + t * 0.62)) ^ 0.6) end, vs = 3.6, cut = tri })
  LF[i] = { m, T, S }
  tri:add(m)
end
for _, L in ipairs(LF) do local m, T, S = L[1], L[2], L[3]
  m:each(function(x, y) local k = K(x, y)
    if T[k] and abs(T[k] - (0.5 + abs(S[k]) * 0.18)) < 0.045 and abs(S[k]) > 0.25 and abs(S[k]) < 0.75 then
      c:put(x, y, S[k] < 0 and CHEV or LEAF[5], { r = { name = "leaf" } }) end end)
end
-- quirk: early crimson flower spike on a thin side stalk from the stem
local fsp = { { 35, 30 }, { 39, 27 }, { 42, 22 }, { 44, 17 } }
A.stem(c, fsp, function(t) return 0.6 end, STEM, { cut = stm:copy():add(tri), tok = stok })
local spike = HP.mask()
for i = 0, 5 do local r = 2.3 - i * 0.3 spike:add(G.rell(45 + i * 0.35, 15 - i * 1.4, 0.2, -1, max(0.7, r * 0.8), max(0.6, r))) end
spike:cut(tri)
local fidx = A.shade(c, spike, A.body(spike, 44.5, 12, 4, 2.5, 0.5), RED, { tok = { r = { name = "flower" } } })
-- florets: little scale bumps
spike:each(function(x, y) if (x + y * 2) % 4 == 0 and (fidx[K(x, y)] or 1) >= 3 then c:put(x, y, RED[min(6, fidx[K(x, y)] + 1)], { r = { name = "flower" } }) end end)
c:put(44, 9, RED[6], { r = { name = "flower" } })

-- seeds last (over the stem foot), glossy, AO between neighbours
for i, s in ipairs(seeds) do
  local b = {}
  for j = i + 1, #seeds do X.ao(b, sm[i], sm[j], 1, -1) end
  local over = {}
  for j = i + 1, #seeds do over[#over + 1] = sm[j] end
  A.seed(c, s, SEED, { bias = b, over = over, glint = "#fff4d6", name = "seed" .. i })
end
-- dark hilum notch on the kidney's inner curve
for _, s in ipairs(seeds) do local ux, uy = cos(s[5] + pi / 2), sin(s[5] + pi / 2)
  c:put(floor(s[1] + ux * 1.6 + 0.5), floor(s[2] + uy * 1.6 + 0.5), SEED[1], { r = { name = "seed1" } }) end
A.save(c, NAME)

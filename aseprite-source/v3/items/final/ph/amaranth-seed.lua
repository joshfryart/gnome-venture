-- amaranth-seed (final, Opus). A little heap of tiny glossy gold amaranth seeds (lens-shaped, each with its own
-- specular, AO where they pile) on a broad ovate amaranth leaf scrap: pinnate curving veins, a wine-red midrib and
-- red-flushed margin toward the tip, emarginate (notched) tip, torn off at the base with pale broken tissue, cool
-- reflected edge and a contact shadow under the heap. One seed has sprouted on the left: a striped crimson stem,
-- two narrow cotyledons with red undersides and a first true leaf, oval with the notched amaranth tip.
-- quirk: one wild black seed sits in the gold heap.
local NAME = "amaranth-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1d3a30", "#2a5838", "#3c7840", "#579848", "#7eb85a", "#b2d67a" }
local WINE = { "#3a1430", "#5a1a3a", "#7c2444", "#a0344e", "#c25a68", "#e08a8a" }
local VEIN, COOL, TORN = "#cfe69a", "#3c6a74", "#e2eeb8"
local GOLD = { "#6a3a1c", "#975a22", "#c4862e", "#e4b04a", "#f6d47a", "#fff0bc" }
local BLACK = { "#1e1620", "#2e2230", "#423446", "#5e4e64", "#8a7c94", "#c0b4ca" }
local RSTEM = { "#5a1a3a", "#8a2a48", "#b8445a", "#e07a80" }

-- leaf scrap: broad ovate, base lower-right (torn), notched tip upper-left
local lm, ln, LT, LS, len = A.blade(56, 53, 36, 57, 9, 40, function(t)
  if t > 0.975 then return -1 end
  local u = t ^ 0.85
  return max(0.6, 9.4 * sin(pi * min(1, u * 0.96 + 0.03)) ^ 0.6)
end, { fold = 0.3 })
-- emarginate tip: a small notch at the end of the midrib
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.93 and abs(LS[k]) < 0.3 then lm.s[k] = nil end end)
local tornEdge = A.tear(lm, LT, LS, 0.1, "lo", 0.045, 5)

-- seeds: tiny lenses (cx, cy, rx, ry, ang); order back to front; #5 is the black one
local SP = {
  { 36, 44, 1.8, 1.3, 0.3 }, { 40, 43, 1.8, 1.3, -0.4 }, { 44, 44, 1.8, 1.3, 0.2 },
  { 34, 47, 1.8, 1.3, -0.2 }, { 38, 47, 1.8, 1.3, 0.5 }, { 42, 47, 1.8, 1.3, -0.1 },
  { 46, 47, 1.8, 1.3, 0.4 }, { 36, 50, 1.8, 1.3, 0.1 }, { 40, 50, 1.8, 1.3, -0.3 },
  { 44, 50, 1.8, 1.3, 0.2 }, { 49, 50, 1.8, 1.3, -0.4 }, { 31, 50, 1.7, 1.2, 0.3 },
  { 28, 45, 1.8, 1.3, 0.2 },   -- the sprouting one (left)
}
local heap = HP.mask()
for _, s in ipairs(SP) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) heap:add(s.m) end

local bias = {}
A.contact(bias, lm, heap, 2)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 }, amb = 0.12, wrap = 0.3 })
local PER = 6.5
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  local as = abs(s)
  if bias[k] then return end
  if as < 0.12 and t > 0.1 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or WINE[4], ltok) return end
  local ph = (t * len - as * 5.0) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and as > 0.14 and as < 0.75 and t > 0.12 and t < 0.86 then
    c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 2)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.15 and not tornEdge:has(x, y) then c:put(x, y, LT[k] > 0.5 and WINE[3] or COOL, ltok) end end)
tornEdge:each(function(x, y) c:put(x, y, (LS[K(x, y)] < 0.2) and TORN or LEAF[5], ltok) end)

-- sprout on the left seed: striped crimson stem, cotyledons, notched true leaf
local stok = { r = { name = "stem" } }
local sp = { { 28, 44 }, { 26, 38 }, { 30, 32 }, { 28, 25 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.05 - 0.15 * t end)
sm:cut(SP[13].m)
local sidx = A.shade(c, sm, sn, RSTEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
local function oleaf(ax, ay, cx, cy, bx, by, w, notch)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.975 then return -1 end
    if t < 0.18 then return 0.5 end
    return max(0.5, w * sin(pi * min(1, (t - 0.14) / 0.86 * 0.95 + 0.05)) ^ 0.55)
  end, { fold = 0.32 })
  if notch then m:each(function(x, y) local k = K(x, y) if T[k] > 0.9 and abs(S[k]) < 0.35 then m.s[k] = nil end end) end
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if T[k] < 0.18 then c:put(x, y, RSTEM[2], ltok)                               -- red petiole
    elseif abs(S[k]) < 0.15 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or WINE[3], ltok)
    elseif S[k] > 0.72 and T[k] > 0.25 then c:put(x, y, WINE[2], ltok) end       -- red underside showing on the rim
  end)
  return m
end
oleaf(27, 26, 20, 28, 15, 21, 2.2)         -- cotyledon left
oleaf(29, 26, 36, 28, 41, 21, 2.2)         -- cotyledon right
oleaf(28, 26, 26, 19, 31, 12, 3.4, true)   -- first true leaf
sm:each(function(x, y) local k = K(x, y) if SS[k] > 0.25 and SS[k] < 0.6 and ST[k] < 0.8 then c:put(x, y, RSTEM[1], stok) end end) -- stripe

-- seeds: glossy gold lenses, each lit, AO onto the ones behind, a 1 px specular on each
for i, s in ipairs(SP) do
  local ramp = (i == 5) and BLACK or GOLD
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #SP do vis:cut(SP[j].m) X.ao(sb, s.m, SP[j].m, 1, -1) end
  A.shade(c, vis, s.n, ramp, { bias = sb, tok = tok, cuts = { 0.12, 0.3, 0.5, 0.7, 0.88 }, amb = 0.05, wrap = 0.15 })
  local hx, hy = floor(s[1] - 0.6 + 0.5), floor(s[2] - 0.6 + 0.5)
  if vis:has(hx, hy) then c:put(hx, hy, i == 5 and BLACK[6] or "#fffbe8", tok) end
  -- hilum rim: one dark pixel on the lower-right edge
  local rx, ry = floor(s[1] + 1.2 + 0.5), floor(s[2] + 0.6 + 0.5)
  if vis:has(rx, ry) then c:put(rx, ry, ramp[2], tok) end
end
-- split coat on the sprouting seed
c:put(28, 44, RSTEM[3]) c:put(27, 44, GOLD[2])
A.save(c, NAME)

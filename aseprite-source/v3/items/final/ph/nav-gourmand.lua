-- nav-gourmand (final pass, Opus). A tall, slightly tilted cream menu card with a red ribbon bookmark, a gold
-- seal and short ink lines of "dishes", and a slim polished silver spoon laid diagonally across it. Paper: bevelled
-- pillow card, laid-paper lines, curled corner. Spoon: concave bowl (dark upper-left inner rim, bright lower-right
-- inner bowl, specular), cylinder handle with a bright edge streak, contact shadow cast on the card.
-- quirk: a single drop of red sauce is about to drip off the spoon tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("nav-gourmand")
local PAPER = { "#7a5a5e", "#b49a8e", "#d8c4a6", "#eedcb8", "#f8ecce", "#fff4d6" }
local SIL   = { "#35344e", "#5a5b78", "#8a8ca4", "#b4b6c8", "#dcdde6", "#f4f4f2" }
local RIB   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local tk = function(n) return { r = { name = n } } end

-- ribbon bookmark (behind card bottom)
local rib = c:poly{ { 20, 46 }, { 24, 45 }, { 25, 55 }, { 23, 53 }, { 21, 56 } }
A.shade(c, rib, A.slab(rib, 1, 0, 0, 1), RIB, { tok = tk("rib"), cuts = { 0.3, 0.55, 0.8 } })

-- card: tilted rectangle via face()
local O, U, V = { 13, 15 }, { 26, -5 }, { 6, 34 }
local card = A.face(O, U, V, function(u, v) return u >= 0 and u <= 1 and v >= 0 and v <= 1 and not (u > 0.86 and v < 0.13 and (u - 0.86) + (0.13 - v) * 0.9 > 0.12) end)
local cbias = {}
local cidx = A.shade(c, card, A.slab(card, 2, 0, 0, 1), PAPER, { tok = tk("card"), amb = 0.12, bias = cbias })
-- curled corner (top-right): folded flap
local flap = A.face(O, U, V, function(u, v) return u > 0.79 and u <= 0.93 and v >= 0.0 and v < 0.13 and (u - 0.79) * 1.0 + (0.13 - v) * 0.9 > 0.12 and (u - 0.86) + (0.13 - v) * 0.9 <= 0.12 end)
flap:each(function(x, y) c:put(x, y, PAPER[3], tk("flap")) end)
flap:edge():each(function(x, y) if card:has(x + 1, y + 1) then c:put(x, y, PAPER[2], tk("flap")) end end)
-- laid paper: faint lines parallel to the top edge
card:each(function(x, y)
  local det = U[1] * V[2] - U[2] * V[1]
  local dx, dy = x + 0.5 - O[1], y + 0.5 - O[2]
  local v = (U[1] * dy - U[2] * dx) / det
  local u = (dx * V[2] - dy * V[1]) / det
  -- dish lines
  local lines = { { 0.42, 0.2, 0.78 }, { 0.54, 0.2, 0.66 }, { 0.66, 0.2, 0.74 }, { 0.78, 0.2, 0.58 } }
  for _, L in ipairs(lines) do
    if math.abs(v - L[1]) < 0.016 and u > L[2] and u < L[3] then c:put(x, y, "#864c33", tk("card")) end
  end
  -- title bar
  if math.abs(v - 0.26) < 0.025 and u > 0.3 and u < 0.7 then c:put(x, y, "#b52e3f", tk("card")) end
end)
-- gold seal at the top
local seal = A.face(O, U, V, function(u, v) return ((u - 0.5) * 26) ^ 2 + ((v - 0.12) * 34) ^ 2 <= 7 end)
A.shade(c, seal, X.sphere(floor(O[1] + 0.5 * U[1] + 0.12 * V[1]), floor(O[2] + 0.5 * U[2] + 0.12 * V[2]), 2.6, seal),
  { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }, { tok = tk("seal"), cuts = { 0.3, 0.55, 0.8 } })

-- spoon: handle from lower-left up to bowl at upper-right
local bx, by = 42, 22
local hm, hn, HT, HS, hidx = A.stem(c, { { 14, 54 }, { 22, 45 }, { 31, 35 }, { 38, 28 } }, function(t) return 1.2 + t * 0.4 + (t < 0.08 and 0.6 or 0) end, SIL, { tok = tk("handle"), amb = 0.1, wrap = 0.2 })
-- bright edge streak on lit side
hm:each(function(x, y) local k = K(x, y) if HS[k] < -0.4 and HT[k] > 0.15 and HT[k] < 0.85 and (x + y) % 2 == 0 then c:put(x, y, SIL[6], tk("handle")) end end)
-- bowl: rotated oval, concave
local bowl = HP.mask()
for y = by - 9, by + 9 do for x = bx - 9, bx + 9 do
  local dx, dy = x - bx, y - by
  local u, v = (dx + dy) / 2, (dx - dy) / 2
  if (u / 3.4) ^ 2 + (v / 4.6) ^ 2 <= 1 then bowl:set(x, y) end
end end
local bn = {}
bowl:each(function(x, y)
  local dx, dy = x - bx, y - by
  local u, v = (dx + dy) / 2, (dx - dy) / 2
  local nu, nv = u / 3.8, v / 5
  local q = max(0.05, 1 - nu * nu - nv * nv)
  -- outer rim convex (1 px), inner concave
  local inside = (u / 2.6) ^ 2 + (v / 3.7) ^ 2 <= 1
  local s = inside and -1 or 1
  local nx, ny = s * (nu + nv) / 1.4, s * (nu - nv) / 1.4
  bn[K(x, y)] = { A.norm(nx, ny, sqrt(q)) }
end)
local bidx = A.shade(c, bowl, bn, SIL, { tok = tk("bowl"), amb = 0.12, wrap = 0.15 })
c:put(bx + 2, by + 1, SIL[6], tk("bowl")) c:put(bx + 3, by + 1, "#ffffee", tk("bowl"))
-- contact shadow of the spoon on the card (offset down-right)
local sh = hm:copy():add(bowl):shift(1, 2)
sh:each(function(x, y) if card:has(x, y) and not hm:has(x, y) and not bowl:has(x, y) and not seal:has(x, y) then
  local i = cidx[K(x, y)] or 4 c:put(x, y, PAPER[max(1, i - 2)], tk("card")) end end)

-- quirk: sauce drop hanging from the bowl tip
local DR = { K = "#2b1c26", h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038" }
A.map(c, {
  ".R.",
  "hRr",
  "Rrd",
  ".d.",
}, bx + 4, by + 5, DR, tk("drop"))

A.save(c, "nav-gourmand")

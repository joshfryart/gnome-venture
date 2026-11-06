-- broken-cane-fishing-rod (final, Opus single pass). A slim bamboo cane pole on the diagonal (cylinder light,
-- raised nodes with a dark groove and lit lip, a waxy streak) with a cork grip (pores) and gold thread wraps.
-- Damage: the cane has snapped two thirds up; the tip section droops sharply, still hinged by splintered fibres,
-- jagged split ends with a dark gap, and a splinter chip flying off. The line still hangs from the tip to a
-- red-and-cream bobber (sphere light, glint) and a steel hook.
-- quirk: a small pink worm on the hook is waving, unbothered by the catastrophe.
local NAME = "broken-cane-fishing-rod"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CANE = { "#4a3a1c", "#6e5626", "#957a34", "#bea24a", "#dcc56c", "#f4e6a4" }
local CORK = { "#4a2a20", "#6e4430", "#946240", "#b88458", "#d6a878", "#f0cfa0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local RED = { "#5e1a30", "#9e2a3a", "#d8413a", "#f2704c", "#ffa47a" }
local CRM = { "#8a7a8e", "#c2b8b8", "#efe4cc", "#fff4d6" }
local STEEL = { "#2f3248", "#71758e", "#c6c8d6" }
local LINE = "#d8d2c2"

local function nodes(m, T, S, idx, ramp, tok, len, list)
  m:each(function(x, y) local k = K(x, y) local t = T[k]
    for _, nt in ipairs(list) do
      local d = (t - nt) * len
      if d > -0.5 and d < 0.5 then c:put(x, y, ramp[max(1, (idx[k] or 3) - 2)], tok)
      elseif d >= 0.5 and d < 1.5 and S[k] < 0.3 then c:put(x, y, ramp[min(6, (idx[k] or 3) + 1)], tok) end
    end
  end)
end

-- lower cane (butt to break)
local ctok = { r = { name = "cane" } }
local lp = { { 12, 56 }, { 19, 47 }, { 28, 37 }, { 36, 28 } }
local lm, ln, LT, LS = A.tube(lp, function(t) return 1.75 - t * 0.45 end)
local lidx = A.shade(c, lm, ln, CANE, { tok = ctok, amb = 0.08, wrap = 0.22 })
nodes(lm, LT, LS, lidx, CANE, ctok, 38, { 0.47, 0.68, 0.88 })
-- waxy streak along the lit side
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.36 and LT[k] < 0.84 and LS[k] < -0.35 and LS[k] > -0.75 and (lidx[k] or 0) >= 5 and A.hash(x, y, 2) > 0.3 then c:put(x, y, CANE[6], ctok) end end)
-- jagged split end at the break
for _, q in ipairs{ { 36, 27, 6 }, { 37, 26, 5 }, { 35, 27, 2 }, { 37, 28, 3 } } do c:put(q[1], q[2], CANE[q[3]], ctok) end

-- cork grip over the butt
local gtok = { r = { name = "cork" } }
local gp = { { 12, 56 }, { 14, 53 }, { 17, 50 }, { 19, 47 } }
local gm, gn, GT, GS = A.tube(gp, function(t) return 2.5 - t * 0.3 end)
local gb = {}
gm:each(function(x, y) if A.hash(x, y, 9) > 0.78 then gb[K(x, y)] = -2 end end)
A.shade(c, gm, gn, CORK, { tok = gtok, bias = gb, amb = 0.1, wrap = 0.25 })
c:put(12, 56, CORK[2], gtok) c:put(11, 56, CORK[3], gtok)
-- gold thread wraps at the grip top and one node
local wtok = { r = { name = "wrap" } }
local function wrapBand(m, T, S, t0, t1)
  m:each(function(x, y) local k = K(x, y)
    if T[k] >= t0 and T[k] <= t1 then
      local s = S[k]
      c:put(x, y, GOLD[s < -0.45 and 4 or (s < 0.2 and 3 or (s < 0.65 and 2 or 1))], wtok)
    end end)
end
wrapBand(gm, GT, GS, 0.9, 1.0)
wrapBand(lm, LT, LS, 0.3, 0.34)

-- tip section, drooping from the break
local tp = { { 38, 26 }, { 44, 25 }, { 50, 28 }, { 54, 34 } }
local tm, tn, TT, TS = A.tube(tp, function(t) return 1.15 - t * 0.55 end)
local tb = {}
tm:each(function(x, y) if TT[K(x, y)] < 0.08 then tb[K(x, y)] = -1 end end)
local tidx = A.shade(c, tm, tn, CANE, { tok = ctok, bias = tb, amb = 0.08, wrap = 0.22 })
nodes(tm, TT, TS, tidx, CANE, ctok, 21, { 0.45 })
-- splintered hinge: fibres still bridging the gap, one sticking up
c:put(37, 27, CANE[4], ctok) c:put(38, 27, CANE[2], ctok)
c:put(38, 24, CANE[5], ctok) c:put(39, 23, CANE[6], ctok) c:put(37, 25, CANE[4], ctok)
-- tip eyelet
c:put(55, 35, STEEL[2], ctok)

-- line, bobber, hook
local ltok = { r = { name = "line" } }
for y = 36, 40 do c:put(55, y, LINE, ltok) end
local btok = { r = { name = "bobber" } }
c:put(55, 40, RED[2], btok)
local bm = HP.ellipse(55, 44, 3, 3)
local bn = X.sphere(55, 44, 3, bm)
local bv = X.light(bn, { amb = 0.1, wrap = 0.2 })
bm:each(function(x, y) local k = K(x, y)
  if y <= 44 then X.tone(c, HP.mask():set(x, y), { [k] = bv[k] }, RED, { cuts = { 0.2, 0.42, 0.64, 0.84 }, tok = btok })
  else X.tone(c, HP.mask():set(x, y), { [k] = bv[k] }, CRM, { cuts = { 0.25, 0.55, 0.8 }, tok = btok }) end
end)
for x = 52, 58 do if bm:has(x, 44) then c:put(x, 44, x < 56 and RED[2] or RED[1], btok) end end
c:put(53, 42, A.CREAM, btok)
for y = 48, 50 do c:put(55, y, LINE, ltok) end
-- hook: J shape
local hk = { { 55, 51 }, { 55, 52 }, { 55, 53 }, { 54, 54 }, { 53, 53 }, { 53, 52 } }
for i, q in ipairs(hk) do c:put(q[1], q[2], i < 3 and STEEL[3] or STEEL[2], ltok) end

-- flying chip from the break
A.map(c, 40, 18, { "..a", ".ab", "bc." }, { a = CANE[6], b = CANE[4], c = CANE[2] }, ctok)

-- quirk: a pink worm on the hook, waving
local WM = { a = "#ffb4c8", b = "#f5809f", c = "#c94f84" }
A.map(c, 50, 49, { "a..", "b..", ".b.", ".cb" }, WM, { r = { name = "worm" } })
c:put(52, 53, WM.b, { r = { name = "worm" } })
A.save(c, NAME)

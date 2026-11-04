-- ico-scales (final, Opus single pass). Brass balance: stepped foot, slim turned post (cylinder, specular streak),
-- collar and ball finial, a tilted 3 px beam with knob ends, thin chains to two shallow pans (bevelled rim, dark
-- bowl inside, cool bounce on the underside). Right pan: a small stack of silver coins. Ground shadow (it stands).
-- quirk: a single acorn in the left pan outweighs the whole coin stack.
local NAME = "ico-scales"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_2.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, floor, max, min, sqrt = math.abs, math.floor, math.max, math.min, math.sqrt
local c = A.new(NAME)
local BR = { "#4e2a1e", "#83491f", "#b97022", "#e09f2c", "#f6cc55", "#fff0a8" }
local CH = "#8f531f"
local AG = { "#3e4060", "#62647e", "#8c8da4", "#b8b8c8", "#dddce6", "#f6f4f8" }
local NUT = { "#5a3020", "#8a4c2a", "#b86f38", "#d8934c", "#efb870", "#ffe0a4" }
local CAP = { "#3a2422", "#563428", "#7a4e34", "#9c6c44", "#bd8c58" }

c:groundShadow(32, 56, 13, 2)
local btok, ptok = A.tok("brass"), A.tok("pan")

-- foot: low dome + plinth
local foot = HP.mask()
for y = 50, 55 do
  local hw = ({ 6, 7, 8, 10, 11, 12 })[y - 49]
  for x = 32 - hw, 33 + hw do foot:set(x, y) end
end
local fn = A.bulge(X.pillow(foot, 2), 30, 48, 12, 8, 0.5)
local fidx = A.shade(c, foot, fn, BR, { tok = btok })
for x = 21, 44 do A.step(c, fidx, BR, x, 53, -1, btok) end   -- step edge
for x = 22, 43 do A.step(c, fidx, BR, x, 52, 1, btok) end

-- post (turned rod)
local pm, pn = X.cyl(32.5, 15, 32.5, 50, function(t) return 1.9 + (t > 0.92 and 1 or 0) end)
local pidx = A.shade(c, pm, pn, BR, { tok = btok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.88 } })
-- AO where the post enters the foot
for x = 30, 35 do A.step(c, fidx, BR, x, 50, -1, btok) end
-- specular streak
for y = 22, 44 do if y % 7 ~= 0 then c:put(31, y, BR[6], btok) end end

-- beam: tilted, left end low
local LX, LY, RX, RY = 15, 22, 50, 15
local bm, bn = A.tube({ { LX, LY }, { 26.7, 19.7 }, { 38.3, 17.3 }, { RX, RY } }, function(t) return 1.45 end)
local bidx = A.shade(c, bm, bn, BR, { tok = btok })
-- knob ends
for _, e in ipairs{ { LX, LY }, { RX, RY } } do
  local km = A.ellM(e[1], e[2], 2.2, 2.2)
  A.shade(c, km, X.sphere(e[1], e[2], 2.4, km), BR, { tok = btok })
end
-- collar where beam crosses post, and finial
local col = A.ellM(32.5, 18.5, 3.2, 2.6)
local cidx = A.shade(c, col, X.sphere(32.5, 18.5, 3.4, col), BR, { tok = btok })
local neck = c:rect(31, 13, 34, 14)
A.shade(c, neck, X.pillow(neck, 1), BR, { tok = btok })
local fin = A.ellM(32.5, 10, 3, 3)
A.shade(c, fin, X.sphere(32.5, 10, 3.2, fin), BR, { tok = btok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
c:put(31, 8, BR[6], btok) c:put(31, 9, BR[6], btok)
c:put(30, 8, A.CREAM, btok)
c:put(31, 17, BR[6], btok) c:put(32, 17, BR[6], btok)

-- pan: shallow bowl (lower half ellipse) + rim, hanging below a knob end
local function pan(cx, top)
  local rx = 7
  local bowl = HP.mask()
  A.ellM(cx, top, rx, 5):each(function(x, y) if y >= top then bowl:set(x, y) end end)
  local rim = A.ellM(cx, top, rx, 1.3)
  local inner = A.ellM(cx, top, rx - 1.6, 0.6)
  -- chains first (behind rim)
  for _, ex in ipairs{ cx - rx + 0.5, cx + rx - 0.5 } do end
  local n = X.sphere(cx, top - 2, rx + 0.5, bowl)
  local bias = {}
  local idx = A.shade(c, bowl, n, BR, { tok = ptok, bias = bias })
  -- cool bounce on the lower right underside
  bowl:edge():each(function(x, y) if x > cx + 1 and y > top + 2 then c:put(x, y, "#a86a3a", ptok) end end)
  A.shade(c, rim, A.bulge(X.pillow(rim, 1), cx - 3, top, rx, 2, 0.6), BR, { tok = ptok })
  inner:each(function(x, y) c:put(x, y, BR[2], ptok) end)
  return bowl:add(rim), top
end
local function chain(x0, y0, x1, y1) A.line(c, x0, y0, x1, y1, CH, A.tok("chain")) end
local LPX, LPT = 15, 40
local RPX, RPT = 50, 32
chain(LX - 1, LY + 2, LPX - 6, LPT - 1) chain(LX + 1, LY + 2, LPX + 6, LPT - 1)
chain(RX - 1, RY + 2, RPX - 6, RPT - 1) chain(RX + 1, RY + 2, RPX + 6, RPT - 1)
local lp = pan(LPX, LPT)
local rp = pan(RPX, RPT)

-- quirk: acorn in the left pan
local ntok, ktk = A.tok("nut"), A.tok("cap")
local nut = A.ellM(15, 35.2, 3.1, 3.4)
local nidx = A.shade(c, nut, X.sphere(14.2, 34.4, 3.6, nut), NUT, { tok = ntok })
c:put(15, 39, NUT[2], ntok) -- point
local cap = HP.mask()
for _, r in ipairs{ { 13, 17, 29 }, { 12, 18, 30 }, { 11, 19, 31 }, { 11, 19, 32 } } do for x = r[1], r[2] do cap:set(x, r[3]) end end
local capi = A.shade(c, cap, A.bulge(X.pillow(cap, 1.2), 13, 29, 4, 2, 0.7), CAP, { tok = ktk })
for _, p in ipairs{ { 12, 32 }, { 14, 32 }, { 16, 32 }, { 18, 32 }, { 13, 31 }, { 15, 31 }, { 17, 31 }, { 14, 30 }, { 16, 30 } } do A.step(c, capi, CAP, p[1], p[2], -1, ktk) end
for x = 12, 18 do if nut:has(x, 33) then A.step(c, nidx, NUT, x, 33, -2, ntok) end end -- AO under the cap
c:put(16, 28, CAP[2], ktk) c:put(17, 27, CAP[3], ktk)  -- stalk
c:put(13, 34, NUT[6], ntok) c:put(13, 35, NUT[6], ntok)
-- AO under the acorn on the rim
for x = 13, 17 do if lp:has(x, 39) then c:put(x, 39, BR[1], ptok) end end

-- silver coins in the right pan: a stack of three, milled edges, the middle one nudged left
local ctok = A.tok("coin")
A.map(c, {
  " 6655444 ",
  "554444333",
  "433333222",
  "111111111",
  "4333322221",
  "1111111111",
  " 433333222",
  " 111111111",
}, 46, 24, { ["1"] = AG[1], ["2"] = AG[2], ["3"] = AG[3], ["4"] = AG[4], ["5"] = AG[5], ["6"] = AG[6] }, ctok)
c:put(45, 28, AG[4], ctok) c:put(45, 29, AG[1], ctok)
-- milling ticks on the edges
for _, x in ipairs{ 48, 51, 54 } do c:put(x, 26, AG[2], ctok) end
for _, x in ipairs{ 47, 50, 53 } do c:put(x, 28, AG[2], ctok) end
A.save(c, NAME)

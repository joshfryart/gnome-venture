-- cattail-fluff (final, Opus single pass). A slim cattail stalk with its velvety brown seed spike splitting open:
-- cream down bursts from the upper-right side in scalloped puffs (cool-violet shade, radial fibre streaks), the bare
-- wiry tip pokes out above, a twisting strap leaf rises behind the stalk, and loose seeds drift away on their plumes.
-- quirk: a ladybird rides the top drifting tuft like a balloon.
local NAME = "cattail-fluff"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sin, cos, pi, atan = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)
local FL = { "#6e6488", "#9a90b0", "#c4bccc", "#e2dcd8", "#f4eedc", "#fff4d6" }
local BR = { "#2e1a1e", "#4a2a26", "#6a3c2c", "#8c5434", "#ae7044", "#cc9460" }
local ST = { "#24443a", "#3a6040", "#5a8048", "#80a058", "#a8c070", "#d0dc94" }
local LF = { "#1c3c36", "#2c5a40", "#3f7a48", "#5c9a50", "#84b862", "#b4d482" }

-- strap leaf behind (twists once)
local ltok = { r = { name = "leaf" } }
local lm, lnn, lT, lS = G.tube({ { 24, 51 }, { 20, 44 }, { 14, 37 }, { 13, 28 } }, function(t) return t > 0.97 and 0.3 or (1.7 - t * 0.9) end)
local lidx = A.shade(c, lm, lnn, LF, { amb = 0.14, wrap = 0.3, tok = ltok })
lm:each(function(x, y) local k = K(x, y)
  local t, s = lT[k], lS[k]
  if t > 0.55 then c:put(x, y, LF[max(1, min(6, 7 - lidx[k]))], ltok) end      -- back face after the twist
  if t > 0.52 and t < 0.58 then c:put(x, y, LF[1], ltok) end                  -- twist crease
  if t < 0.5 and abs(s) < 0.2 and t > 0.05 then c:put(x, y, LF[min(6, lidx[k] + 1)], ltok) end -- parallel vein
end)

-- stalk
local stok = { r = { name = "stalk" } }
local sm, sn, sT, sS = G.tube({ { 23, 52 }, { 25, 43 }, { 28, 35 }, { 31, 27 } }, function(t) return 1.25 end)
sm:cut(HP.rect(0, 52, 63, 63))
local sb = {} X.ao(sb, sm, lm, 1, 0) -- (stalk is in front of the leaf)
local sidx = A.shade(c, sm, sn, ST, { amb = 0.12, wrap = 0.3, tok = stok })
-- spike
local ktok = { r = { name = "spike" } }
local km, kn, kT, kS = G.tube({ { 30.5, 29 }, { 32, 23 }, { 33.5, 17 }, { 35, 12 } }, function(t) return 3.2 - 0.6 * t end)
-- fluff mass bursting from the upper-right side
local fm = HP.mask()
for _, e in ipairs{ { 40, 19, 4.2, 3.6 }, { 44, 14, 3.6, 3.2 }, { 38, 13, 3.0, 2.8 }, { 45, 21, 3.0, 2.6 }, { 41, 9, 2.6, 2.4 },
                    { 48, 17, 2.4, 2.2 }, { 36, 24, 2.4, 2.0 }, { 47, 11, 2.0, 1.8 } } do
  fm:add(HP.ellipse(e[1], e[2], e[3], e[4]))
end
local kb = {}
X.ao(kb, km, fm, 2, -1)
local kidx = A.shade(c, km:copy():cut(fm), kn, BR, { amb = 0.08, wrap = 0.25, bias = kb, tok = ktok })
km:copy():cut(fm):each(function(x, y) local k = K(x, y)
  local i = kidx[k] if not i then return end
  if X.hash(x, y, 21) < 0.12 and i < 6 then c:put(x, y, BR[i + 1], ktok) end      -- velvet nap
  if kS[k] > -0.1 and kS[k] < 0.25 and kT[k] > 0.3 and (floor(kT[k] * 30) % 4 == 0) then c:put(x, y, BR[max(1, i - 1)], ktok) end -- split
end)
-- stalk shaded where it enters the spike
X.ao({}, sm, km, 1, -1)
-- bare wiry tip above the spike
A.stem(c, { { 35, 10 }, { 35.5, 7 }, { 36, 5 }, { 36.5, 3 } }, function(t) return 0.75 end, { BR[2], BR[3], BR[4], BR[5] }, { cut = km:copy():add(fm), tok = { r = { name = "tip" } } })

-- fluff shading
local ftok = { r = { name = "fluff" } }
local fn = A.body(fm, 42, 15, 9, 3, 0.5)
local fb = {}
X.ao(fb, fm, km, 1, -1)
local fidx = A.shade(c, fm, fn, FL, { amb = 0.2, wrap = 0.35, bias = fb, tok = ftok, cuts = { 0.18, 0.34, 0.5, 0.64, 0.8 } })
fm:each(function(x, y) local k = K(x, y)
  local i = fidx[k]
  local dx, dy = x - 35, y - 20
  local a = atan(dy, dx)
  local d = math.sqrt(dx * dx + dy * dy)
  if d > 4 and ((a * 7 / pi) % 1) < 0.14 and i > 2 then c:put(x, y, FL[i - 1], ftok) end   -- radial fibres
end)
-- seeds peppered in the down (tiny dark achenes)
for _, p in ipairs{ { 38, 20 }, { 37, 16 }, { 41, 22 } } do if fm:has(p[1], p[2]) then c:put(p[1], p[2], BR[3], ftok) end end
c:put(40, 10, A.CREAM, ftok) c:put(41, 10, A.CREAM, ftok)

-- drifting seeds: small plume fans with a dark seed tail
local function drift(x, y, big)
  local tok = { r = { name = "drift" } }
  if big then
    local b = HP.ellipse(x, y, 2.2, 1.6)
    local bn = X.sphere(x - 0.4, y - 0.4, 2.2, b)
    A.shade(c, b, bn, FL, { amb = 0.25, wrap = 0.35, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.64, 0.8 } })
    c:put(x, y + 2, FL[3], tok) c:put(x, y + 3, BR[4], tok) c:put(x, y + 4, BR[2], tok)
  else
    for _, p in ipairs{ { -1, -2, 5 }, { 0, -2, 6 }, { 1, -2, 4 }, { -2, -3, 5 }, { 2, -3, 3 }, { 0, -1, 4 } } do c:put(x + p[1], y + p[2], FL[p[3]], tok) end
    c:put(x, y, BR[4], tok) c:put(x, y + 1, BR[2], tok)
  end
end
drift(52, 8, true)
drift(53, 28, false)
-- quirk: ladybird on top of the big drifting tuft
local bt = { r = { name = "ladybird" } }
for _, p in ipairs{ { 51, 5, "#e8493b" }, { 52, 5, "#2b1c26" }, { 53, 5, "#b52e3f" }, { 51, 4, "#ff8a5c" }, { 53, 4, "#e8493b" }, { 52, 4, "#2b1c26" }, { 52, 3, "#2b1c26" } } do
  c:put(p[1], p[2], p[3], bt)
end

A.save(c, NAME)

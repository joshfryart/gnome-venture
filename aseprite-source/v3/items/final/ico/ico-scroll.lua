-- ico-scroll (final, Opus single pass). Hanging scroll: parchment sheet (fibre flecks, a torn nick on the left edge,
-- AO under each roll), a top roll on a turned wooden dowel with knob ends (grain, pale end grain), a looser bottom
-- curl whose right end shows the paper spiral. Four ink lines, a red drop cap, a pressed wax seal with ribbon tails.
-- quirk: a little green bookworm peeking out of the bottom roll's spiral.
local NAME = "ico-scroll"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_2.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, floor, max, min, sqrt = math.abs, math.floor, math.max, math.min, math.sqrt
local c = A.new(NAME)
local PA = { "#7c5848", "#a67e5c", "#c9a477", "#e2c596", "#f2dfb2", "#fcefcf" }
local WD = { "#3e2420", "#5f3727", "#85533a", "#a8714a", "#c9915e", "#e8b880" }
local WAX = { "#4a1a2e", "#7a2236", "#b02e3c", "#da4840", "#f37658", "#ffae8a" }
local INKL = { "#4a3038", "#6e4c4a" }
local WORM = { "#2e5e46", "#4f9a55", "#86c46a", "#c4e48c" }
local ptok, wtok, stok = A.tok("paper"), A.tok("wood"), A.tok("seal")

-- sheet
local sheet = c:rect(19, 15, 45, 47)
for _, p in ipairs{ { 19, 30 }, { 19, 31 }, { 20, 31 }, { 19, 32 }, { 45, 22 } } do sheet.s[K(p[1], p[2])] = nil end
local sb = {}
sheet:each(function(x, y) local k = K(x, y)
  if y <= 17 then sb[k] = (y == 16 or y == 15) and -2 or -1 end      -- AO under top roll
  if y >= 45 then sb[k] = (y == 47) and -2 or -1 end                 -- AO above bottom curl
end)
local sn = A.bulge(X.pillow(sheet, 2), 26, 22, 22, 40, 0.35)
local sidx = A.shade(c, sheet, sn, PA, { tok = ptok, bias = sb, cuts = { 0.14, 0.28, 0.44, 0.6, 0.78 } })
-- fibre flecks
for _, p in ipairs{ { 23, 19, -1 }, { 40, 25, -1 }, { 27, 42, -1 }, { 42, 34, -1 }, { 21, 37, 1 }, { 36, 19, 1 }, { 31, 44, -1 } } do A.step(c, sidx, PA, p[1], p[2], p[3], ptok) end
-- ink lines (2 px tall, uneven ends) and a red drop cap
local lines = { { 26, 20, 41 }, { 21, 25, 40 }, { 21, 30, 37 }, { 21, 35, 33 } }
for i, l in ipairs(lines) do
  for x = l[1], l[3] do
    local gap = (x - l[1]) % 9 == 6
    if not gap then c:put(x, l[2], INKL[2], ptok) c:put(x, l[2] + 1, INKL[1], ptok) end
  end
end
A.map(c, { "4555", "3.24", "3..4", "3224", "2..3", "2..3" }, 21, 19, { ["2"] = WAX[2], ["3"] = WAX[3], ["4"] = WAX[4], ["5"] = WAX[5] }, ptok)

-- top roll: paper cylinder on a dowel with knobs
local rm, rn = X.cyl(17, 12.5, 47, 12.5, function() return 3.3 end)
local ridx = A.shade(c, rm, rn, PA, { tok = ptok })
-- paper end edges (spiral lip)
for y = 10, 15 do A.step(c, ridx, PA, 17, y, -1, ptok) A.step(c, ridx, PA, 47, y, -2, ptok) end
for _, e in ipairs{ { 11, 16 }, { 48, 53 } } do
  local dm, dn = X.cyl(e[1], 12.5, e[2], 12.5, function() return 1.6 end)
  A.shade(c, dm, dn, WD, { tok = wtok })
end
for _, kx in ipairs{ 10.5, 53.5 } do
  local km = A.ellM(kx, 12.5, 2.4, 3)
  local kidx = A.shade(c, km, X.sphere(kx, 12.5, 3, km), WD, { tok = wtok })
  -- grain ring on the knob
  c:put(floor(kx) + (kx < 30 and 1 or 0), 11, WD[kx < 30 and 4 or 3], wtok)
end
c:put(9, 11, WD[6], wtok) c:put(10, 10, WD[6], wtok)

-- bottom curl: thicker roll, right end shows the paper spiral
local bm, bnn = X.cyl(18, 49.5, 46, 49.5, function() return 3.6 end)
local bidx = A.shade(c, bm, bnn, PA, { tok = ptok })
for x = 20, 44 do A.step(c, bidx, PA, x, 46, 1, ptok) end        -- lip where the sheet wraps over
for y = 47, 52 do A.step(c, bidx, PA, 18, y, -1, ptok) end
-- spiral end cap at the right
local cap = A.ellM(47, 49.5, 1.8, 3.6)
local spiral = {
  "5444",
  "4321",
  "3211",
  "421.",
  "4321",
  "5432",
  ".543",
}
local cp = { ["1"] = PA[1], ["2"] = PA[2], ["3"] = PA[3], ["4"] = PA[4], ["5"] = PA[5] }
A.map(c, spiral, 45, 46, cp, ptok)

-- quirk: bookworm peeking out of the spiral hole
local qtok = A.tok("worm")
A.map(c, {
  ".34.",
  "3443",
  "2332",
  "122.",
}, 47, 44, { ["1"] = WORM[1], ["2"] = WORM[2], ["3"] = WORM[3], ["4"] = WORM[4] }, qtok)
c:put(49, 45, A.INK, qtok)
c:put(50, 46, "#f5809f", qtok)

-- wax seal with ribbon tails, pressed onto the sheet bottom
local rtok = A.tok("ribbon")
for _, t in ipairs{ { { 35, 45 }, { 33, 55 }, WAX[3], WAX[2] }, { { 39, 45 }, { 41, 55 }, WAX[4], WAX[2] } } do
  local tm, tn = X.cyl(t[1][1], t[1][2], t[2][1], t[2][2], function(u) return 1.3 end)
  A.shade(c, tm, tn, WAX, { tok = rtok, cuts = { 0.2, 0.4, 0.58, 0.76, 0.95 } })
end
-- fishtail notches
c.pix[55 * 64 + 33], c.own[55 * 64 + 33] = nil, nil
c.pix[55 * 64 + 41], c.own[55 * 64 + 41] = nil, nil
local seal = A.ellM(37, 43, 4.3, 4.1)
-- wavy blob edge
for _, p in ipairs{ { 37, 38 }, { 42, 43 }, { 32, 43 }, { 37, 48 } } do seal:set(p[1], p[2]) end
local sidx2 = A.shade(c, seal, X.sphere(36.5, 42.5, 4.6, seal), WAX, { tok = stok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.86 } })
-- pressed ring + crest
for _, p in ipairs{ { 36, 41 }, { 37, 41 }, { 38, 41 }, { 35, 42 }, { 35, 43 }, { 39, 42 }, { 39, 43 }, { 36, 44 }, { 37, 44 }, { 38, 44 } } do
  A.step(c, sidx2, WAX, p[1], p[2], -2, stok)
end
c:put(37, 42, WAX[5], stok) c:put(37, 43, WAX[4], stok)
c:put(34, 40, WAX[6], stok) c:put(35, 39, WAX[6], stok)
-- contact shadow of the seal on the paper
for _, p in ipairs{ { 42, 44 }, { 42, 45 }, { 41, 46 }, { 43, 42 } } do A.step(c, sidx, PA, p[1], p[2], -2, ptok) end

A.save(c, NAME)

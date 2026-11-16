-- Termite Tower (th-termite-tower), perch sprite 36x36. Opus richness pass (c05/opus3), hand-built at this size.
-- Richness pass: hue-shifted laterite ramp, grain courses with lit knobs, two rain runnels, vents with lit lips,
-- a pebble at the foot. Fix vs opus2 (outline read like a crown): the spire now leans, ONE short
-- chimney sits low on the left shoulder and the right side is a smooth sloping buttress, so the top is a single
-- lopsided point, not three.
-- Bold and few: smug face low in the wide base (pill eyes under sloped brows, one-sided smirk).
-- quirk: a pale termite on the spire's shoulder heaving one red grain over its head (bolder than opus2).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-termite-tower-perch", 36)

local LAT = { "#3a1420", "#651e24", "#93302a", "#ba4632", "#da6a48", "#f09a6e" }
local TRM = { "#7a4a2e", "#c99a64", "#ecd2a4", "#f8ead0" }
local BNC = "#6a4a6e"

c:groundShadow(18, 32, 11, 1.5)
local function column(m, y0, y1, cxf, hwf)
  for y = y0, y1 do
    local cx, hw = cxf(y), hwf(y)
    for x = math.floor(cx - hw + .5), math.floor(cx + hw - .5) do m:set(x, y) end
  end
end
local mound = HP.mask()
-- leaning spire (tip right of centre), widening into the base
column(mound, 3, 31, function(y) return 19.5 - (y - 3) * .06 end,
  function(y) local t = (y - 3) / 28 return 1.3 + t * 8.8 + math.sin(y * 1.1) * .45 end)
-- one short chimney low on the left shoulder
column(mound, 17, 27, function(y) return 9.5 + (y - 17) * .15 end, function(y) return 2 + (y - 17) * .12 end)
mound:add(c:ellipse(9.5, 17, 2, 2.5))
-- smooth buttress on the right: a sloping lump, no peak
mound:add(c:ellipse(25, 24, 4.5, 6))
mound:add(c:ellipse(18, 29.5, 10.5, 2))
local mb = {} mound:each(function(x, y) if y >= 30 then mb[K(x, y)] = -1 end end)
local mI, mT = O.shade(c, mound, LAT, { R = 3, bias = mb, amb = .25, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, mI, mT, LAT, function(x, y, i)
  local face = x > 12 and x < 24 and y > 17 and y < 27
  if face then return nil end
  if (y == 8 or y == 13 or y == 28) and (x % 3 ~= 0) and i >= 2 then return -1 end -- grain courses
  if (y == 7 or y == 12 or y == 27) and (x % 3 == 1) and i >= 3 and i <= 5 then return 1 end -- lit knobs
  if H(x, y, 4) > .9 and i >= 3 and i <= 5 then return 1 end
end)
-- rain runnels down the shaded right flank
O.mark(c, { { 23, 15 }, { 23, 16 }, { 24, 17 } }, LAT[2])
-- vents with lit lips
O.mark(c, { { 19, 9 }, { 20, 9 } }, LAT[1]) O.mark(c, { { 19, 10 }, { 20, 10 } }, LAT[6])
O.mark(c, { { 9, 18 } }, LAT[1]) O.mark(c, { { 9, 19 } }, LAT[6])
O.shade(c, c:ellipse(29, 30, 1.5, 1), { "#4a3a44", "#7a6a70", "#a89a98", "#d0c4bc" }, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = LAT[1] })

c:eyeSmall(14, 20) c:eyeSmall(20, 20)
O.mark(c, { { 13, 19 }, { 14, 18 }, { 15, 19 } }, LAT[1]) -- brows sloped in
O.mark(c, { { 20, 19 }, { 21, 18 }, { 22, 19 } }, LAT[1])
O.mark(c, { { 15, 18 }, { 20, 18 } }, LAT[1])
O.dot(c, 12, 24, "#f5809f") O.dot(c, 24, 24, "#f5809f")
O.mark(c, { { 16, 25 }, { 17, 25 }, { 18, 25 }, { 19, 24 } }, P.ink)

-- termite + grain: bolder (pale 3x2 abdomen, thorax, head, the grain held up)
O.flat(c, c:rect(21, 11, 23, 12), TRM[3], "termite") O.dot(c, 21, 12, TRM[2]) O.dot(c, 22, 12, TRM[2]) O.dot(c, 21, 11, TRM[4])
O.flat(c, c:rect(24, 10, 24, 11), TRM[2], "termite")
O.flat(c, c:rect(25, 9, 26, 10), "#a65a2a", "thead") O.dot(c, 25, 9, "#d88a3c")
local g = c:ellipse(26.5, 6.5, 1.5, 1.5)
O.shade(c, g, LAT, { R = 1, amb = .5, sep = LAT[1] })
O.dot(c, 26, 6, LAT[6])

O.done(c, "th-termite-tower-perch")

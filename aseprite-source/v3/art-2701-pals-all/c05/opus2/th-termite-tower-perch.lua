-- Termite Tower (th-termite-tower), perch sprite 36x36. Opus second pass (c05/opus2), hand-built at this size.
-- Bold and few: knobbly red spire with two shoulder chimneys, three grain courses, two vents, a smug face
-- low in the wide base (pill eyes under sloped brows, one-sided smirk).
-- quirk: a pale termite on the spire's shoulder holding one red grain over its head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("th-termite-tower-perch", 36)

local LAT = { "#3a161d", "#621e22", "#8e2c2a", "#b43f33", "#d4614a", "#ec8f6c" }
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
column(mound, 4, 31, function() return 18 end, function(y) local t = (y - 4) / 27 return 1.5 + t * 8.5 + math.sin(y * 1.1) * .5 end)
column(mound, 12, 28, function(y) return 9 + (y - 12) * .15 end, function(y) return 1.5 + (y - 12) * .1 + math.sin(y) * .4 end)
column(mound, 15, 28, function(y) return 27 - (y - 15) * .15 end, function(y) return 1.3 + (y - 15) * .1 + math.sin(y * 1.3) * .4 end)
mound:add(c:ellipse(18, 29.5, 10, 2))
local mb = {} mound:each(function(x, y) if y >= 30 then mb[K(x, y)] = -1 end end)
local mI, mT = O.shade(c, mound, LAT, { R = 3, bias = mb, amb = .25, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, mI, mT, LAT, function(x, y, i)
  local face = x > 12 and x < 24 and y > 18 and y < 27
  if not face and (y == 9 or y == 15 or y == 28) and (x % 3 ~= 0) and i >= 2 then return -1 end
end)
O.mark(c, { { 17, 8 }, { 18, 8 } }, LAT[1]) O.mark(c, { { 17, 9 }, { 18, 9 } }, LAT[6])
O.mark(c, { { 9, 15 } }, LAT[1]) O.mark(c, { { 9, 16 } }, LAT[6])

c:eyeSmall(14, 20) c:eyeSmall(20, 20)
O.mark(c, { { 13, 19 }, { 14, 18 }, { 15, 19 } }, LAT[1]) -- brows sloped in
O.mark(c, { { 20, 19 }, { 21, 18 }, { 22, 19 } }, LAT[1])
O.mark(c, { { 13, 18 } }, LAT[4]) O.mark(c, { { 15, 18 }, { 20, 18 } }, LAT[1])
O.dot(c, 12, 24, "#f5809f") O.dot(c, 24, 24, "#f5809f")
O.mark(c, { { 16, 25 }, { 17, 25 }, { 18, 25 }, { 19, 24 } }, P.ink)

-- termite + grain
O.flat(c, c:rect(21, 9, 22, 10), TRM[3], "termite") O.dot(c, 21, 10, TRM[2])
O.flat(c, c:rect(23, 8, 24, 8), "#a65a2a", "thead")
local g = c:ellipse(24.5, 5.5, 1, 1)
O.shade(c, g, LAT, { R = 1, amb = .5, sep = LAT[1] })

O.done(c, "th-termite-tower-perch")

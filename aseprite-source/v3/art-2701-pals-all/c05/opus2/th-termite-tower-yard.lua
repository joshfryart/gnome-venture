-- Termite Tower (th-termite-tower), yard sprite 64x64. Opus second pass (art-2701-pals-all/c05/opus2) over the Haiku pass.
-- Rootwarden, common, Thornacre. "Builds a red tower one grain at a time and never says sorry."
-- A red laterite termite mound that is alive: a knobbly main spire with two lower chimney turrets on its
-- shoulders, built in visible courses of little mud grains (ridges + lit grain specks), dark air vents with lit
-- lower lips, stubby mud arms, and a smug face low in the wide base (locked eyes under slanted brows, one-sided
-- smirk: no apology coming).
-- Fixes vs Haiku: no longer a traffic cone. Lumpy organic profile, turrets, courses and vents read as a mound;
-- 6-tone laterite ramp with rim light and a cool bounce instead of flat red bands.
-- quirk: a tiny pale termite on the spire's shoulder heaving one red grain up towards the top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-termite-tower-yard", 64)

local LAT = { "#3a161d", "#621e22", "#8e2c2a", "#b43f33", "#d4614a", "#ec8f6c" }
local TRM = { "#7a4a2e", "#c99a64", "#ecd2a4", "#f8ead0" }
local TH  = { "#5a2e1c", "#a65a2a", "#d88a3c" }
local BNC = "#6a4a6e"

c:groundShadow(32, 58, 19, 2.5)

local function column(m, y0, y1, cxf, hwf)
  for y = y0, y1 do
    local cx, hw = cxf(y), hwf(y)
    for x = math.floor(cx - hw + .5), math.floor(cx + hw - .5) do m:set(x, y) end
  end
end
local mound = HP.mask()
-- main spire: knobbly cone, rounded tip
column(mound, 8, 56, function(y) return 32 + math.sin(y * .21) * .8 end,
  function(y) local t = (y - 8) / 48 return 2 + t * 13 + math.sin(y * .9) * .7 + (y < 10 and -1 or 0) end)
-- left chimney turret
column(mound, 22, 46, function(y) return 17.5 + (y - 22) * .12 end, function(y) return 2.2 + (y - 22) * .13 + math.sin(y * 1.1) * .5 end)
-- right chimney turret
column(mound, 29, 46, function(y) return 47 - (y - 29) * .14 end, function(y) return 1.8 + (y - 29) * .13 + math.sin(y * 1.3) * .5 end)
-- spread foot
mound:add(c:ellipse(32, 53, 17, 3.5))
local mb = {}
mound:each(function(x, y) if y >= 54 then mb[K(x, y)] = -1 end end)
local mI, mT = O.shade(c, mound, LAT, { R = 5, bias = mb, amb = .2, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
-- courses of grains: a darker seam every 4 rows with knobs, lit specks between
O.tex(c, mI, mT, LAT, function(x, y, i)
  local face = x > 22 and x < 42 and y > 33 and y < 47
  if not face and (y + math.floor(x / 5)) % 4 == 0 and H(x, y, 3) > .3 and i >= 2 then return -1 end
  if H(x, y, 4) > (face and .97 or .9) and i >= 2 and i <= 5 then return 1 end
end)
-- vents: dark holes with a lit lower lip
for _, v in ipairs({ { 31, 13, 2 }, { 17, 25, 1 }, { 47, 32, 1 }, { 29, 25, 1 }, { 19, 38, 1 } }) do
  local x, y, w = v[1], v[2], v[3]
  local pts, lip = {}, {}
  for i = 0, w do pts[#pts+1] = { x + i, y } pts[#pts+1] = { x + i, y + 1 } lip[#lip+1] = { x + i, y + 2 } end
  O.mark(c, pts, LAT[1]) O.mark(c, lip, LAT[6])
end

-- smug face
c:eyeLocked(25, 36) c:eyeLocked(34, 36)
O.mark(c, { { 24, 34 }, { 25, 34 }, { 26, 34 }, { 27, 35 }, { 28, 35 }, { 29, 35 } }, LAT[1]) -- brows slope in: smug
O.mark(c, { { 34, 35 }, { 35, 35 }, { 36, 35 }, { 37, 34 }, { 38, 34 }, { 39, 34 } }, LAT[1])
c:cheek(23, 42) c:cheek(39, 42)
O.mark(c, { { 29, 44 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 33, 43 }, { 34, 42 } }, P.ink) -- one-sided smirk
O.mark(c, { { 35, 42 } }, LAT[2])

-- quirk: tiny termite on the right shoulder of the spire, heaving one red grain up
local tx, ty = 37, 19
O.flat(c, c:rect(tx, ty, tx + 2, ty + 1), TRM[3], "termite")       -- pale abdomen
O.dot(c, tx, ty + 1, TRM[2]) O.dot(c, tx + 1, ty + 1, TRM[2]) O.dot(c, tx, ty, TRM[4])
O.flat(c, c:rect(tx + 3, ty - 1, tx + 3, ty), TRM[2], "termite")   -- thorax
O.flat(c, c:rect(tx + 4, ty - 2, tx + 5, ty - 1), TH[2], "thead")  -- head
O.dot(c, tx + 4, ty - 2, TH[3])
-- the grain, held up over its head
local g = c:ellipse(tx + 5.5, ty - 5.5, 1.5, 1.5)
O.shade(c, g, LAT, { R = 1, amb = .45, sep = LAT[1] })
O.dot(c, tx + 5, ty - 6, LAT[6])
O.dot(c, tx + 5, ty - 3, TH[1])                                      -- mandible up to the grain

O.done(c, "th-termite-tower-yard")

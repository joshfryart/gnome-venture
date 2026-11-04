-- sea-daffodil-seed (first draft, Sonnet). Three black glossy angular wedge seeds (bright edge facet) on a long
-- grey-green strap leaf scrap with parallel veins; sprout: a pale bulb nub with two arching blue-green strap leaves.
-- quirk: a tiny pink sea shell lies on the leaf scrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sea-daffodil-seed")
local floor = math.floor
local LF = A.R("#7da898")
A.scrap(c, 3, 57, 58, 47, 7.5, LF, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 })
-- parallel veins
for i = -2, 2, 2 do A.ln(c, 8, 56 + i, 54, 47 + i, LF[2]) end
local sdr = A.R("#33303f")
local function wedge(cx, cy)
  local m = c:poly{ { cx - 3, cy + 2 }, { cx, cy - 3 }, { cx + 3, cy - 1 }, { cx + 2, cy + 3 } }
  A.lit(c, m, sdr, 1.8, { amb = .06 })
  c:px(cx - 1, cy - 1, "#cfd2f0") c:px(cx, cy - 2, "#8a8fb8")
end
wedge(14, 53) wedge(24, 52) wedge(34, 49)
-- bulb nub + arching strap leaves
A.sph(c, 44, 44, 3.2, "#efe4c4", {})
c:px(43, 47, "#c9b890") c:px(45, 47, "#c9b890")
A.blade(c, 44, 42, 36, 24, 2.4, "#6aa89a", { veins = { 4, 8 }, slant = 1.2 })
A.blade(c, 36, 24, 26, 12, 2.0, "#5a9a92", { veins = { 4 }, slant = 1.2 })
A.blade(c, 45, 42, 52, 26, 2.4, "#7ab8a6", { veins = { 4, 8 }, slant = 1.2 })
A.blade(c, 52, 26, 55, 12, 2.0, "#6aa89a", { veins = { 4 }, slant = 1.2 })
-- shell
A.sph(c, 20, 45, 2.4, "#f5a0b0", {})
c:px(20, 44, "#ffe0e4") c:px(21, 46, "#c94f84") c:px(19, 46, "#c94f84") c:px(20, 47, "#c94f84")
A.fin()

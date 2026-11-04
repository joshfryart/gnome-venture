-- scorpion-stinger (first draft, Sonnet). The curled tip of a scorpion tail: four plump amber segments strung along a
-- tall hook curve, ridged and shrinking, ending in a bulb (telson) and a sharp dark curved barb.
-- quirk: a bright green venom drop hangs from the barb tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("scorpion-stinger")
local floor, sin = math.floor, math.sin
c:groundShadow(24, 58, 12, 2)
local pts = A.curve({ { 14, 55 }, { 6, 22 }, { 40, 4 }, { 46, 30 } }, 40)
local R = A.R("#b8742e")
local tube = A.sweepM(pts, function(t) return 5.4 - t * 2.4 end)
A.lit(c, tube, R, 3.2, { amb = .08, wrap = .3 })
-- segment rings: dark joint lines across the tail, lit bump after each
for _, t in ipairs{ .17, .38, .58, .78 } do
  local p = pts[floor(t * 40) + 1]
  local nx, ny = -p[4], p[3]
  for k = -6, 6 do local x, y = floor(p[1] + nx * k + .5), floor(p[2] + ny * k + .5) if tube:has(x, y) then c:px(x, y, R[1]) end end
  for k = -5, 5 do local x, y = floor(p[1] + nx * k - p[3] * 1 + .5), floor(p[2] + ny * k - p[4] * 1 + .5) if tube:has(x, y) and k < 0 then c:px(x, y, R[6]) end end
end
-- telson bulb at end
local te = pts[41]
A.sph(c, floor(te[1] + .5), floor(te[2] + .5) + 2, 4, "#8a4a22", {})
-- barb: curved dark spike pointing down-left
local tx, ty = floor(te[1] + .5), floor(te[2] + .5) + 5
c:fillMask(c:poly{ { tx - 2, ty }, { tx + 2, ty }, { tx + 1, ty + 5 }, { tx - 2, ty + 9 } }, "#3a1e22")
c:px(tx, ty + 1, "#a85a3a") c:px(tx, ty + 2, "#7a3a2a")
-- venom drop
A.sph(c, tx - 2, ty + 13, 1.8, "#7cc35a", { spec = "#c4e07a" })
c:px(tx - 2, ty + 11, "#7cc35a") c:px(tx - 2, ty + 10, "#3f9150")
A.fin()

-- herb-flatbread (dC11 first draft): round golden flatbread with charred blisters, oil sheen and scattered green herb flecks, one torn corner.
-- quirk: a rosemary sprig lies across it, and a fold shows the soft white crumb at the tear.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("herb-flatbread")
local P = D.P
c:groundShadow(32, 53, 25, 3)
local body = D.ell(32, 38, 25, 15, -0.08)
body:cut(D.ell(55, 29, 5, 5))
D.part(c, body, D.r4("#ffe6a8", "#e8b25f", "#b9783f", "#6e3f2e"), 8)
-- crust rim row
body:edge():each(function(x, y) end)
-- blisters
for _, b in ipairs{ {18,34},{27,45},{40,33},{46,42},{33,40} } do
  c:fillMask(D.ell(b[1], b[2], 2.4, 1.6), "#8f4a2f") c:px(b[1] - 1, b[2] - 1, "#c7803f")
end
-- herb flecks
for _, h in ipairs{ {22,38},{25,31},{30,35},{36,44},{44,36},{14,40},{38,29},{29,46},{49,38} } do
  c:px(h[1], h[2], P.moss.shade) c:px(h[1] + 1, h[2], P.moss.base) c:px(h[1] + 1, h[2] - 1, P.moss.hi)
end
-- oil sheen
for x = 21, 28 do c:px(x, 29, "#fff4d6") end
-- crumb at the tear
D.ln(c, 50, 30, 53, 33, "#fffaf0") D.ln(c, 52, 27, 55, 30, "#f4e3b8")
-- rosemary sprig
D.ln(c, 14, 46, 44, 24, P.moss.deep)
for i = 0, 8 do
  local x, y = 17 + i * 3, 44 - i * 2.4
  c:px(math.floor(x), math.floor(y) - 2, P.moss.base) c:px(math.floor(x) + 1, math.floor(y) + 2, P.moss.shade)
end
D.fin()

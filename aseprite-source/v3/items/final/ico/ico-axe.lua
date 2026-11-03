local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-axe: woodcutter's axe, long slim hickory handle with grain, bevelled steel head with a bright cutting edge.
-- quirk: a red twine whipping is wound round the haft below the head, with the loose end dangling.
local c = D.new("ico-axe")
local WD = { "#51302b", "#74452f", "#9a6038", "#b97a4a", "#d49a62", "#eab882" }
D.cyl(c, 11, 57, 42, 16, function(t) return 2.2 + t * 0.6 end, WD)
for _, p in ipairs{ {18, 46}, {21, 42}, {26, 36}, {30, 31} } do D.shift(c, p[1], p[2], WD, -2) end
-- knob
c:part(c:ellipse(11, 57, 3, 3), "wood", { band = 1 })
-- head
c:part(c:poly{ {32, 15}, {39, 12}, {42, 24}, {35, 25} }, "stone", { band = 1 })
c:part(c:poly{ {38, 12}, {50, 6}, {59, 9}, {61, 23}, {53, 30}, {42, 26} }, "stone", { band = 3, pop = { x = 43, y = 12, horizontal = true } })
D.polyline(c, { {59, 9}, {61, 23}, {55, 29} }, CREAM)
D.polyline(c, { {58, 10}, {60, 22} }, "#e2e0e6")
c:fillMask(c:ellipse(41, 18, 1.5, 1.5), "#444663")
-- twine
for _, p in ipairs{ {{27, 38}, {32, 36}}, {{25, 41}, {30, 39}}, {{23, 44}, {28, 42}} } do
  D.polyline(c, p, "#e8493b") D.polyline(c, { {p[1][1], p[1][2] + 1}, {p[2][1], p[2][2] + 1} }, "#b52e3f")
end
D.polyline(c, { {28, 45}, {32, 50}, {30, 54} }, "#e8493b")
D.move(c, -3, -2)
D.fin()

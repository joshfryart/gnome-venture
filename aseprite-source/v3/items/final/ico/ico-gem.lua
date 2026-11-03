local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-gem: cut diamond in flat cyan facets, bright table on top.
-- quirk: a small shard has chipped off and hovers at the upper right.
local c = D.new("ico-gem")
local T = { "#1f4a7a", "#2f78b4", "#4aa0d8", "#78c8ec", "#aee4f6", "#e6f8fc" }
local A, B, C, Dd, E = {13,23}, {22,12}, {42,12}, {51,23}, {32,56}
local out = c:poly{ A, B, C, Dd, E }
D.fill(out, T[3])
local function f(pts, t) D.fill(D.isect(c:poly(pts), out), T[t]) end
f({ B, C, {40,23}, {24,23} }, 5)
f({ A, B, {24,23} }, 4)
f({ C, Dd, {40,23} }, 2)
f({ A, {24,23}, E }, 3)
f({ {24,23}, {40,23}, E }, 4)
f({ {40,23}, Dd, E }, 2)
f({ {32,23}, {40,23}, E }, 3)
for _, l in ipairs{ {{24,23},{40,23}}, {{24,23},{32,56}}, {{40,23},{32,56}}, {{22,12},{24,23}}, {{42,12},{40,23}}, {{32,23},{32,56}} } do
  D.ln(c, l[1][1], l[1][2], l[2][1], l[2][2], T[1], out)
end
D.ln(c, 13, 23, 51, 23, T[2], out)
c:sparkle(30, 17)
D.fill(c:poly{ {54,5},{58,9},{54,13},{50,9} }, T[4]) D.fill(c:poly{ {54,9},{58,9},{54,13} }, T[2])
D.fin()

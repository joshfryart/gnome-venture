-- ico-shuffle first draft. two bold arrows swapping lanes and crossing. quirk: a tiny gold die rides on the crossing
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-shuffle")
local function path(p, ramp)
  local m = D.swept(c, D.bez(p, 40), function(t) return 2.6 end)
  D.lit(c, m, ramp, 2.2)
end
path({ {8, 46}, {30, 46}, {30, 18}, {46, 18} }, D.BLU)
D.lit(c, c:poly{ {44, 10}, {58, 18}, {44, 26} }, D.BLU, 2)
-- gap where green passes over
path({ {8, 18}, {30, 18}, {30, 46}, {46, 46} }, D.GRN)
D.lit(c, c:poly{ {44, 38}, {58, 46}, {44, 54} }, D.GRN, 2)
D.lit(c, c:rect(28, 28, 36, 36), D.CRM, 1.5)
D.R(c, 30, 30, 31, 31, "#2b1c26") D.R(c, 33, 33, 34, 34, "#2b1c26")
D.fin()

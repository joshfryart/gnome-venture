-- ico-sea-creature first draft. round pink octopus with four curled arms. quirk: one arm holds up a shiny pearl
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-sea-creature")
local PK = D.PINK
local arms = {
  { {22, 34}, {10, 40}, {8, 52}, {16, 54} }, { {28, 36}, {22, 50}, {26, 58}, {32, 54} },
  { {36, 36}, {42, 50}, {38, 58}, {32, 56} }, { {42, 34}, {54, 36}, {58, 26}, {54, 22} } }
for _, a in ipairs(arms) do D.lit(c, D.swept(c, D.bez(a, 20), function(t) return 3 - t * 1.2 end), PK, 2) end
D.lit(c, D.ell(32, 24, 16, 15), PK, 7)
D.lit(c, c:ellipse(32, 36, 12, 5), PK, 2)
c:eyeSmall(23, 25) c:eyeSmall(37, 25)
D.R(c, 29, 33, 34, 33, "#6e2150") D.pts(c, { {28, 32}, {35, 32} }, "#6e2150")
c:cheek(19, 31) c:cheek(40, 31)
-- dots on head
D.pts(c, { {30, 14}, {31, 14}, {36, 16}, {26, 17} }, "#a33468")
-- pearl
D.lit(c, c:ellipse(53, 18, 3, 3), D.CRM, 2) c:px(52, 16, "#ffffff" == "" and "" or "#fff4d6")
c:sparkle(58, 12)
D.fin()

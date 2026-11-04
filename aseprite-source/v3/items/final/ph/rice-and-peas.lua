-- rice-and-peas (final draft D12, Sonnet). Island-style: a mound of pink-tinged coconut rice flecked with red kidney peas
-- and green thyme on a banana-leaf plate with a lime wedge. quirk: a bright green pea-pod hangs off the plate edge.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rice-and-peas")
D.shadow(c, 32, 57, 26, 2.5)
-- banana leaf plate
local leaf = c:ellipse(32, 44, 26, 11)
local li = D.lit(c, leaf, { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }, 8, { wrap = 0.3 })
for x = 10, 54, 4 do D.ln(c, x, 36, x + 2, 52, "#2a6440", leaf) end
D.ln(c, 8, 44, 56, 44, "#9dd06c", leaf)
-- rice mound
local mound = c:ellipse(29, 35, 15, 11):clip(c:rect(0, 0, 63, 44))
mound:add(c:ellipse(29, 41, 15, 4))
D.lit(c, mound, { "#7a4a3a", "#a87260", "#cf9a80", "#e8be9c", "#f6dcbc", "#fff0d8" }, 6, { wrap = 0.35 })
D.scatter(mound, 30, 3, function(x, y) c:px(x, y, "#fff4d6") c:px(x + 1, y, "#cf9a80") end)
local BN = { "#3a1018", "#6e2038", "#a02a3c", "#c8403c", "#e86a50", "#ffa07a" }
for _, q in ipairs{ {23,33,0.3},{31,28,-0.4},{36,36,0.2},{27,39,0.5},{40,31,-0.3},{20,38,0.1} } do
  B.lit(c, B.ell(q[1], q[2], 2.4, 1.7, q[3]), BN, 1.5) c:px(q[1] - 1, q[2] - 1, "#ffd0b0") end
for _, q in ipairs{ {26,31},{34,32},{38,40},{17,41},{30,36} } do c:fillMask(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#45954c") c:px(q[1], q[2], "#9dd06c") end
-- thyme sprig
D.ln(c, 28, 24, 31, 20, "#3e8048") for _, q in ipairs{ {28,23},{30,22},{31,20},{29,21},{32,22} } do c:px(q[1], q[2], "#6ab455") end
-- lime wedge
local lime = c:ellipse(49, 40, 6, 5):clip(c:rect(0, 40, 63, 63)):add(c:ellipse(49, 40, 6, 5):clip(c:rect(0, 0, 63, 40)):clip(c:rect(0, 0, 0, 0)))
local wedge = c:poly{ {43,39},{55,39},{54,44},{49,47},{44,44} }
D.lit(c, wedge, { "#2e5a1c", "#4a8a2c", "#78b83c", "#a4d84c", "#cce86c", "#eefaa0" }, 3, {})
c:fillMask(c:poly{ {45,40},{53,40},{52,43},{49,45},{46,43} }, "#d0e870")
for _, q in ipairs{ {49,40,49,45},{47,40,47,43},{51,40,51,43} } do D.ln(c, q[1], q[2], q[3], q[4], "#fff0a0") end
-- pea pod
local pod = D.stalk(c, 12, 57, 24, 55, function(t) return 1.8 * (1 - (2 * t - 1) ^ 2) ^ 0.5 + 0.4 end, { "#2e6a44", "#3e8048", "#62a456", "#94c868", "#b8dc88", "#e0f4b0" }, {})
for x = 14, 22, 3 do c:px(x, 56, "#173f36") end
D.fin()

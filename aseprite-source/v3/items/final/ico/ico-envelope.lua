local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-envelope: cream letter envelope with a heart wax seal and a V flap.
-- quirk: the letter inside pokes out of the top with a scribbled line.
local c = D.new("ico-envelope")
local PAP = { "#a08a78", "#d4c0a2", "#ece0c0", "#f8f0d8", "#fffbe8", "#fffdf2" }
c:fillMask(c:poly{ {14,16},{36,8},{44,22},{20,24} }, "#fffbe8")
D.poly(c, { {18,17},{34,12} }, "#c9a98a") D.poly(c, { {20,20},{38,15} }, "#c9a98a")
local body = c:rect(9, 20, 54, 50)
D.lit(body, PAP, 14, { amb = 0.1 })
-- flap
local flap = c:poly{ {9,20},{54,20},{32,40} }
D.lit(flap, { "#b89a7a", "#d8c09c", "#ecdcb8", "#f6ead0", "#fff6dc", "#fffbe8" }, 8, { amb = 0.1 })
D.ln(c, 9, 21, 32, 41, "#a08a78") D.ln(c, 54, 21, 32, 41, "#a08a78")
D.ln(c, 9, 50, 25, 36, "#c9a98a") D.ln(c, 54, 50, 39, 36, "#c9a98a")
-- seal heart
local heart = c:ellipse(29, 38, 3, 3):add(c:ellipse(35, 38, 3, 3)):add(c:poly{ {26,39},{38,39},{32,47} })
D.lit(heart, D.RED, 3, { amb = 0.05 })
c:px(28, 36, "#ffc0a0")
D.fin()

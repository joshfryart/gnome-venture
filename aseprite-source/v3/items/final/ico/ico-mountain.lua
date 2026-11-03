-- ico-mountain first draft (Sonnet). quirk: a tiny red flag is planted on the summit
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-mountain")
local SK = D.rp("stone")
-- back peak
local back = c:poly{ {30, 52}, {44, 24}, {58, 52} }
D.fill(back, "#8f97c8")
D.fill(c:poly{ {44, 24}, {58, 52}, {47, 52} }, "#6e76a8")
D.fill(c:poly{ {44, 24}, {40, 32}, {44, 30}, {46, 34}, {49, 29} }, "#e4f6ff")
-- main peak
local main = c:poly{ {4, 54}, {26, 14}, {50, 54} }
main:add(c:rect(4, 52, 50, 54))
D.fill(main, "#aaa9b8")
local shade = main:copy():clip(c:poly{ {26, 14}, {50, 54}, {30, 54}, {28, 34} })
D.fill(shade, "#74758c")
D.fill(shade:copy():clip(c:poly{ {40, 20}, {50, 54}, {40, 54} }), "#5a5c78")
local lit = main:copy():clip(c:poly{ {26, 14}, {4, 54}, {14, 54}, {24, 34} })
D.fill(lit, "#e2e0e6")
-- ridge lines
D.ln(26, 14, 28, 34, "#444663") D.ln(28, 34, 30, 54, "#5a5c78")
D.ln(18, 38, 24, 46, "#aaa9b8") D.ln(36, 40, 40, 46, "#5a5c78")
-- snow cap
local snow = main:copy():clip(c:rect(0, 0, 63, 30))
snow:each(function(x, y) if y <= 25 + ((x // 3) % 2) * 3 + abs(x - 26) // 3 then end end)
local cap = HP.mask()
main:each(function(x, y) if y <= 24 + ((floor(x / 3)) % 2) * 3 + (x > 26 and 1 or 0) then cap:set(x, y) end end)
D.fill(cap, "#fbfcff") D.fill(cap:copy():clip(c:rect(27, 0, 63, 63)), "#c9d6ee")
D.fill(c:rect(24, 17, 26, 18), "#fbfcff")
-- foreground grass and base
D.fill(c:rect(2, 54, 56, 58), "#3f9150") D.fill(c:rect(2, 54, 56, 55), "#7cc35a") D.fill(c:rect(2, 58, 56, 58), "#24544a")
-- flag
D.fill(c:rect(26, 6, 26, 14), "#51302b")
D.fill(c:poly{ {27, 6}, {34, 8}, {27, 11} }, "#e8493b") c:px(28, 7, "#ff8a5c")
D.fin()

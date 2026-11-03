-- ico-newspaper first draft (Sonnet). quirk: a coffee-cup ring stains one corner and the corner is dog-eared
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-newspaper")
local PAP = { "#a89070", "#c9b48f", "#e6d5b0", "#f2e6c4", "#fbf1d4", "#fffbe8" }
c:groundShadow(32, 57, 22, 2)
local back = c:rrect(8, 14, 54, 52, 2)
D.lit(back, { "#7a6850", "#9a8468", "#b8a282", "#cdb994", "#dccaa6", "#e6d5b0" }, 2)
local page = c:rect(11, 11, 56, 49):cut(c:poly{ {49, 11}, {56, 11}, {56, 18} })
D.lit(page, PAP, 3, { amb = .12 })
-- dog ear
D.fill(c:poly{ {49, 11}, {56, 18}, {49, 18} }, "#c9b48f") D.fill(c:poly{ {49, 12}, {55, 18}, {49, 18} }, "#a89070")
-- headline
D.fill(c:rect(14, 14, 45, 19), "#2b1c26")
for _, x in ipairs{ 16, 22, 28, 34, 40 } do D.fill(c:rect(x, 15, x + 3, 18), "#fffbe8") end
for _, x in ipairs{ 18, 24, 30, 36 } do D.fill(c:rect(x, 15, x, 18), "#2b1c26") end
-- photo
D.fill(c:rect(14, 23, 29, 36), "#3a86b0") D.fill(c:rect(14, 23, 29, 28), "#b6f0e0")
D.fill(D.ell(22, 30, 3, 3), "#ffe38a") D.fill(c:poly{ {14, 36}, {20, 31}, {26, 36} }, "#3f9150")
D.fill(c:rect(14, 36, 29, 36), "#24544a")
-- text bars
for _, y in ipairs{ 23, 27, 31, 35 } do D.fill(c:rect(32, y, 53, y + 1), "#74758c") end
for _, y in ipairs{ 40, 44 } do D.fill(c:rect(14, y, 53, y + 1), "#74758c") end
D.fill(c:rect(14, 40, 20, 41), "#2b1c26")
-- coffee ring
for y = 0, 63 do for x = 0, 63 do
  local d = sqrt((x - 48) ^ 2 + (y - 42) ^ 2)
  if d >= 4.5 and d <= 6.3 and page:has(x, y) and not ((x + y) % 5 == 0) then c:px(x, y, "#864c33") end
end end
D.fin()

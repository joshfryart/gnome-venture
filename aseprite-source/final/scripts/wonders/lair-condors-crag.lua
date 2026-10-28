-- lair-condors-crag.lua : boss lair, SA (Andes), bright day above the clouds. The Grand Condor on its crag, wings spread.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-condors-crag"

c:bands(c:rect(0, 0, W - 1, 100), { "#5aa0d4", "#6cb0dc", "#82c0e4", "#9ccfea", "#b8dff0", "#d6eef2" }, { dir = "v" })
-- sun, upper left
c:fill(c:ellipse(30, 24, 11, 11), "#fbe8a8"); c:fill(c:ellipse(30, 24, 8, 8), "#fff3c8")
-- far snowy range
local function peak(pts, rock, snow, snowline)
  local m = c:poly(pts)
  c:fill(m, rock); c:fill(m:copy():clip(c:rect(0, 0, W, snowline)), snow)
  return m
end
peak({ {0,100},{0,70},{14,56},{26,68},{40,48},{58,72},{72,62},{84,100} }, "#8ea2c8", "#f4f8fc", 66)
peak({ {150,100},{166,64},{182,44},{196,60},{208,50},{224,66},{240,58},{240,100} }, "#8ea2c8", "#f4f8fc", 62)
-- shade side of the far peaks (lower right facets)
c:fill(c:poly({ {40,48},{58,72},{46,72} }), "#7a8ebc"); c:fill(c:poly({ {182,44},{196,60},{188,60} }), "#7a8ebc")
-- lower, nearer ridges
peak({ {0,100},{0,84},{20,76},{44,88},{60,80},{80,100} }, "#6c80ac", "#e4ecf4", 82)
peak({ {164,100},{180,82},{200,76},{220,86},{240,78},{240,100} }, "#6c80ac", "#e4ecf4", 82)
-- cloud sea
c:fill(c:rect(0, 96, W, H), "#f2f6f8")
for _, cl in ipairs({ {20,98,24},{70,100,28},{170,98,26},{220,100,22},{120,104,34} }) do
  local m = c:ellipse(cl[1], cl[2], cl[3], 6); m:add(c:ellipse(cl[1] - cl[3] * 0.5, cl[2] - 3, cl[3] * 0.5, 5)); m:add(c:ellipse(cl[1] + cl[3] * 0.4, cl[2] - 4, cl[3] * 0.45, 5))
  c:fill(m, "#f4f8fa"); c:fill(m:copy():clip(c:rect(0, cl[2] + 2, W, H)), "#d6e2ec")
end
c:fill(c:rect(0, 108, W, H), "#d6e2ec"); c:fill(c:rect(0, 120, W, H), "#b8cade")
for _, y in ipairs({ 112, 118, 124 }) do for x = 6 + y % 5, W, 44 do c:fill(c:rect(x, y, x + 9, y), "#eef4f8") end end

-- the crag (central tower of rock)
local crag = c:poly({ {74,128},{82,104},{90,92},{98,80},{112,74},{138,74},{150,82},{156,96},{164,110},{172,128} })
c:part(crag, GV.ramp("#8b8f96"), { cres = 8, deep = 13 })
c:fill(c:poly({ {98,80},{112,74},{138,74},{150,82},{142,84},{130,80},{116,84},{104,84} }), "#e8eef4")
for _, l in ipairs({ { {92,100},{104,96},{110,102} }, { {128,92},{140,90},{148,96} }, { {100,112},{116,110},{124,116} }, { {138,106},{150,108},{158,114} } }) do
  c:seam(l, { free = true, on = 3, off = 0, gap = "#2a1a10" })
end
-- nest of sticks on the crag top
c:part(c:ellipse(120, 76, 18, 5), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
for _, p in ipairs({ {106,75},{112,73},{120,72},{128,73},{134,75} }) do c:px(p[1], p[2], "#d9a660"); c:px(p[1] + 1, p[2] + 1, "#5e2f1e") end

-- the Grand Condor
local CX, CY = 120, 58
local DARK = GV.ramp("#4a4458", { rim = "#7a7488", shade = "#322c40", deep = "#201a2c", gloss = "#9a94ac" })
local wingL = { {110,48},{92,38},{70,32},{48,30},{30,38},{36,46},{26,52},{36,58},{30,66},{44,64},{50,72},{62,66},{72,72},{84,64},{98,68},{110,64} }
local wingR = {}
for i, p in ipairs(wingL) do wingR[i] = { 2 * CX - p[1], p[2] } end
c:part(c:poly(wingL), DARK, { cres = 6, deep = 10, gloss = false })
c:part(c:poly(wingR), DARK, { cres = 6, deep = 10, gloss = false })
-- white wing patches (secondaries)
c:fill(c:poly({ {98,48},{80,42},{66,42},{58,50},{72,54},{88,56},{98,56} }), "#f2e4c0")
c:fill(c:poly({ {142,48},{160,42},{174,42},{182,50},{168,54},{152,56},{142,56} }), "#f2e4c0")
c:fill(c:poly({ {58,50},{66,42},{72,54} }), "#d8c496"); c:fill(c:poly({ {182,50},{174,42},{168,54} }), "#d8c496")
-- feather finger lines
for _, x in ipairs({ 36, 44, 54, 64, 74, 84 }) do c:fill(c:rect(x, 58, x, 63), "#322c40"); c:fill(c:rect(2 * CX - x, 58, 2 * CX - x, 63), "#322c40") end
-- body, white ruff, head
c:part(c:ellipse(CX, CY + 6, 14, 16), DARK, { cres = 5, deep = 8 })
c:part(c:ellipse(CX, CY - 8, 15, 7), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5, pale = true })
c:part(c:ellipse(CX, CY - 22, 12, 11), GV.ramp("#d9885a", { rim = "#f9d49c", shade = "#b8603f" }), { cres = 4, deep = 7 })
-- comb on the forehead (a bump, a little crest)
c:part(c:ellipse(CX, CY - 33, 3, 3), GV.ramp("#a82a2a"), { flat = true })
-- wrinkly neck skin
c:fill(c:rect(CX - 6, CY - 13, CX + 6, CY - 12), "#b8603f")
-- eyes and hooked beak
for _, dx in ipairs({ -6, 6 }) do c:eye(CX + dx - 2, CY - 25) end
c:part(c:poly({ {CX - 4, CY - 19}, {CX + 4, CY - 19}, {CX + 3, CY - 11}, {CX, CY - 9}, {CX - 2, CY - 13} }), GV.ramp("#e8d9b0"), { flat = true, gloss = false })
c:px(CX - 1, CY - 17, "#2a1a10"); c:px(CX + 1, CY - 17, "#2a1a10")
-- talons
for _, dx in ipairs({ -8, 4 }) do c:part(c:rect(CX + dx, CY + 20, CX + dx + 4, CY + 22), GV.ramp("#e8d9b0"), { flat = true, gloss = false }) end

-- foreground: rocks, ichu grass, a puya flower
local fl = c:poly({ {0,H},{0,112},{18,106},{40,112},{52,H} })
c:part(fl, GV.ramp("#7a6a5a"), { cres = 6, deep = 9, gloss = false })
local fr = c:poly({ {188,H},{198,110},{220,104},{H+105,108},{W,106},{W,H} })
c:part(fr, GV.ramp("#7a6a5a"), { cres = 6, deep = 9, gloss = false })
for _, p in ipairs({ {8,111},{20,106},{34,110},{196,111},{212,105},{228,106} }) do
  c:px(p[1], p[2], "#d8c070"); c:px(p[1] + 1, p[2] - 2, "#e8d890"); c:px(p[1] + 2, p[2], "#d8c070"); c:px(p[1] + 3, p[2] - 1, "#e8d890"); c:px(p[1] + 1, p[2] - 1, "#a89a50")
end
c:px(26, 104, "#d6322b"); c:px(27, 104, "#e0501f"); c:px(27, 103, "#f08a24")
-- small birds far away
for _, g in ipairs({ {170,30},{180,26},{194,34} }) do
  c:px(g[1], g[2], "#3e2f66"); c:px(g[1] + 1, g[2] + 1, "#3e2f66"); c:px(g[1] + 2, g[2], "#3e2f66"); c:px(g[1] + 3, g[2] + 1, "#3e2f66"); c:px(g[1] + 4, g[2], "#3e2f66")
end
L.finish(c, SLUG)

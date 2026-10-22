-- ph/tile-wild : top-down untamed meadow tile (full bleed, no halo)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/tile-wild"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

-- ground with a few soft flat patches (kept off the edges so the tile repeats)
c:fill(c:rect(0, 0, 63, 63), "#b0bc66")
c:fill(c:ellipse(44, 38, 13, 9):add(c:ellipse(50, 26, 7, 5)), "#a4b86a")
c:fill(c:ellipse(18, 14, 8, 5), "#a4b86a")
c:fill(c:ellipse(14, 50, 6, 4), "#a4b86a")
c:fill(c:ellipse(30, 22, 4, 2), "#bcc878"); c:fill(c:ellipse(52, 56, 5, 2), "#bcc878")

-- grass sprigs: 3-blade fans, base at (x, y)
local sprig = { "g.g.g", "g.g.g", ".ggg.", "..d.." }
local sprigB = { "..t..", "g.g.g", "g.g.g", ".ggg.", "..d.." }
local bases = { {22,38},{57,50},{44,39},{54,29},{38,44},{44,29},{51,28},{41,38},{23,11},{35,33},{23,16},{54,45},{34,7},{22,36} }
for i, b in ipairs(bases) do
  local rows = (i % 3 == 0) and sprigB or sprig
  c:paint(rows, b[1] - 2, b[2] - #rows + 1, { g = "#6a9a3a", d = "#4a8a3e", t = "#7ab55c" })
end

-- speckles
for _, p in ipairs({ {12,20},{44,8},{26,46},{52,38},{8,56},{36,28} }) do c:px(p[1], p[2], "#6a9a3a") end

-- wildflowers: 3x3 cut-corner (plus) with umber ring, a gold heart and one gloss pixel
local function flower(x, y, petal, gl, heart)
  c:paint({ ".gpu.", "phhpu", "phhpu", ".ppu.", ".uu.." }, x - 2, y - 2,
    { u = "#4a2c1a", p = petal, h = heart, g = gl })
end
flower(31, 36, "#f6b8cf", "#ffe2ec", "#e8a317")
flower(14, 51, "#f5cf6a", "#fff1c8", "#d0862a")
flower(14, 19, "#f4f0e0", "#fff3c8", "#e8a317")
flower(30, 42, "#c3b2ea", "#e6dcfa", "#e8a317")

local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))

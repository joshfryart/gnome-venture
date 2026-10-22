local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- packet body: tall flat paper packet with clipped top corners
local body = c:poly({ {17, 13}, {48, 13}, {51, 16}, {51, 55}, {14, 55}, {14, 16} })
-- folded flap: band across the top with a slight V point at the bottom
local flap = c:poly({ {17, 13}, {48, 13}, {51, 16}, {51, 23}, {35, 23}, {32, 26}, {29, 23}, {14, 23}, {14, 16} })
local win = c:rrect(19, 28, 45, 50, 6)
local bud = c:ellipse(32, 40, 7, 7)

local p = c:build{
  { "body", body, "#f1ece0", { pale = true } },
  { "flap", flap, "#dcb06a" },
  { "win",  win,  "#f4f0e0", { pale = true, gloss = false } },
}
-- orange ring around the label window
c:fill(win:copy():cut(win:shrink(2)), "#f08a24")
c:part(bud, GV.ramp("#f08a24", { shade = "#e0501f" }))
-- stem and leaf
c:fill(c:rect(31, 30, 33, 32), "#2e5a2c")
c:fill(c:ascii({ ".gg..", "gggg.", ".gggg", "..gg." }, 34, 29), "#58a03e")
c:px(35, 30, "#8cc860")
-- print marks
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end
-- fold seam across the flap
c:seam({ { 16, 21 }, { 49, 21 } })

local t = c:save(O .. "aseprite/ph/tree-peony-seed.aseprite", O .. "png/ph/tree-peony-seed.png")
print(GV.report(t))

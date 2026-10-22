local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:poly({ {44, 15}, {47, 8}, {51, 6}, {51, 11}, {48, 16} })
local body = c:ellipse(32, 41, 21, 15):cut(c:rect(0, 54, 63, 63))
local lid = c:ellipse(32, 26, 15.5, 13):cut(c:rect(0, 27, 63, 63))
local p = c:build{
  { "leaf", leaf, "#2f5a2a", { flat = true } },
  { "body", body, GV.ramp("#c9c5bc") },
  { "neck", c:rect(21, 24, 43, 30), GV.ramp("#b4b0a6"), { gloss = false } },
  { "lid",  lid, GV.ramp("#3e2f66", { rim = "#7b66b4" }) },
  { "knob", c:ellipse(31.5, 11, 3.5, 3), "#291d4a", { flat = true } },
}
-- berry cluster
c:fill(c:rect(31, 30, 32, 34), "#2f5a2a")
local berries = { {31.5,36,"#54447f"}, {26.5,40,"#291d4a"}, {36.5,40,"#291d4a"},
                  {22.5,46,"#54447f"}, {31.5,45,"#291d4a"}, {40.5,46,"#54447f"} }
for _, b in ipairs(berries) do
  c:fill(c:ellipse(b[1], b[2], 2.6, 2.6), b[3])
  c:px(math.floor(b[1]) - 1, b[2] - 2, "#a894dc")
end
c:fill(c:poly({ {33, 30}, {37, 28}, {38, 31}, {34, 32} }), "#4a8a3e")
c:seam({ {18, 27}, {46, 27} })
c:button(30, 17)
c:ground(32, 57, 17, 2)
c:save(O .. "aseprite/ph/mulberry-seed.aseprite", O .. "png/ph/mulberry-seed.png")
print(GV.report(c:check()))

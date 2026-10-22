local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0")
local tan = GV.ramp("#dcb06a")
local bundle = c:ellipse(31.5, 41, 18, 15):add(c:poly({ {25,22}, {39,22}, {45,31}, {19,31} }))
local ears = c:poly({ {19,9}, {30,21}, {22,25} }):add(c:poly({ {44,8}, {43,25}, {34,21} }))
ears:add(c:rrect(26, 16, 37, 23, 2))
local tie = c:rrect(23, 21, 40, 25, 1)
local knot = c:ellipse(31.5, 23, 3, 3)
local patch = c:ellipse(31.5, 43, 9, 8)
local tag = c:poly({ {47,26}, {53,33}, {44,35} })
local p = c:build{
  { "ears",   ears,   cloth, { gloss = false } },
  { "bundle", bundle, cloth, { stitch = { side = "lit" } } },
  { "tie",    tie,    tan, { gloss = false } },
  { "patch",  patch,  "moss" },
  { "knot",   knot,   GV.ramp("#a5663a"), { gloss = false } },
  { "tag",    tag,    GV.ramp("#2e5a2c"), { gloss = false } },
}
-- string tails
c:fill(c:line({ {29,26}, {26,31} }, 2), "#a5663a")
c:fill(c:line({ {34,26}, {37,31} }, 2), "#a5663a")
c:fill(c:line({ {41,25}, {45,29} }, 1), "#a5663a")
for _, d in ipairs({ {27,44}, {32,40}, {36,45} }) do
  c:fill(c:rect(d[1], d[2], d[1]+1, d[2]+1), "#4a8a3e")
end
c:seam({ {22, 28}, {41, 28} })
local t = c:save(O .. "aseprite/ph/pear-seed.aseprite", O .. "png/ph/pear-seed.png")
print(GV.report(t))

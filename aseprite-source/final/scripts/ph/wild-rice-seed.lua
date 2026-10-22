local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- grain tips fanning out of both ends
local tips = c:mask()
for _, q in ipairs({ {24, 10}, {28, 9}, {32, 9}, {36, 9}, {40, 10}, {44, 11} }) do
  tips:add(c:line({ {16, q[1] + 2}, {q[2], q[1] + (q[1] - 34) // 3} }, 2))
  tips:add(c:line({ {47, q[1] + 2}, {63 - q[2], q[1] + (q[1] - 34) // 3} }, 2))
end
local cloth = c:rrect(13, 22, 50, 46, 9)
local tieA = c:rect(23, 21, 26, 47)
local tieB = c:rect(37, 21, 40, 47)
local p = c:build{
  { "tips",  tips,  GV.ramp("#5e2f1e"), { flat = true } },
  { "cloth", cloth, GV.ramp("#e9d9b0"), { stitch = { side = "lit" } } },
  { "tieA",  tieA,  GV.ramp("#7a4a1f"), { gloss = false } },
  { "tieB",  tieB,  GV.ramp("#7a4a1f"), { gloss = false } },
}
-- grain tip highlights
for _, q in ipairs({ {24, 10}, {28, 9}, {32, 9}, {36, 9}, {40, 10}, {44, 11} }) do
  local y = q[1] + (q[1] - 34) // 3
  c:px(q[2], y, "#a8582f"); c:px(63 - q[2], y, "#a8582f")
end
-- loose string ends
local ends = c:line({ {24, 47}, {22, 51} }, 2):add(c:line({ {39, 47}, {41, 51} }, 2))
c:part(ends, GV.ramp("#7a4a1f"), { flat = true })
-- knot bumps
c:fill(c:rect(23, 33, 26, 35), "#9a6b3f"); c:fill(c:rect(37, 33, 40, 35), "#9a6b3f")
-- cloth fold
c:paint({ "cc.....cc", "..ccccc.." }, 28, 38, { c = "#c9a96e" })
c:ground(31.5, 55, 15, 1.5)
local t = c:save(O .. "aseprite/ph/wild-rice-seed.aseprite", O .. "png/ph/wild-rice-seed.png")
print(GV.report(t))

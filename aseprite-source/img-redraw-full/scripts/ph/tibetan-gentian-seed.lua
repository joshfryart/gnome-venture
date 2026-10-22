local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local crateM = c:rrect(13, 29, 50, 52, 1)
local p = c:build{
  { "bud", c:ellipse(31.5, 17, 7, 7), GV.ramp("#a4b86a", { shade = "#6a9a3a" }) },
  { "stem", c:rect(31, 23, 32, 26), "#2f5a2a", { flat = true } },
  { "crate", crateM, "wood", { gloss = false, light = crateM } },
  { "postL", c:rect(13, 29, 18, 52), GV.ramp("#a8582f"), { light = crateM, gloss = false } },
  { "postR", c:rect(45, 29, 50, 52), GV.ramp("#a8582f"), { light = crateM, gloss = false } },
  { "rim", c:rrect(11, 24, 52, 29, 1), GV.ramp("#d9a660"), { light = crateM } },
}
-- soil inside the rim
c:fill(c:rect(15, 24, 48, 25), "#7a4a1f")
c:fill(c:rect(16, 24, 47, 24), "#5e3a1c")
c:px(31, 24, "#2f5a2a"); c:px(32, 24, "#2f5a2a"); c:px(31, 25, "#2f5a2a"); c:px(32, 25, "#2f5a2a")
-- plank gaps between the posts
c:fill(c:rect(19, 36, 44, 37), "#8a4f2a")
c:fill(c:rect(19, 44, 44, 45), "#8a4f2a")
c:fill(c:rect(19, 38, 44, 38), "#d9a660")
c:fill(c:rect(19, 46, 44, 46), "#d9a660")
-- nails
for _, q in ipairs({ {15, 31}, {47, 31}, {15, 49}, {47, 49}, {15, 40}, {47, 40} }) do
  c:px(q[1], q[2], "#e8a317"); c:px(q[1] + 1, q[2], "#b8661a")
end
-- bud bract lines
c:paint({ "s...s", ".s.s." }, 29, 19, { s = "#6a9a3a" })

local t = c:save(O .. "aseprite/ph/tibetan-gentian-seed.aseprite", O .. "png/ph/tibetan-gentian-seed.png")
print(GV.report(t))

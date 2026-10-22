local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local slats = c:rect(19, 30, 45, 36):add(c:rect(19, 38, 45, 44)):add(c:rect(19, 46, 45, 53))
local p = c:build{
  { "back",  c:rect(14, 24, 50, 54), GV.ramp("#5e2f1e"), { gloss = false } },
  { "seed",  c:ellipse(32, 26, 9, 9), GV.ramp("#f08a24") },
  { "slats", slats, "wood", { gloss = false } },
  { "postL", c:rect(13, 21, 19, 55), GV.ramp("#8a4f2a"), { gloss = false } },
  { "postR", c:rect(45, 21, 51, 55), GV.ramp("#8a4f2a"), { gloss = false } },
  { "stem",  c:rect(31, 11, 32, 17), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf",  c:ellipse(37, 11, 4, 2.5), GV.ramp("#58a03e"), { gloss = false } },
}
-- wood grain on slats
for _, y in ipairs({33, 41, 49}) do
  c:paint({ "gg...ggg....gg" }, 23, y, { g = "#8a4f2a" })
end
-- nails on posts at each slat
for _, y in ipairs({33, 41, 49}) do c:px(16, y, "#2a1a10"); c:px(48, y, "#2a1a10") end
c:px(16, 24, "#2a1a10"); c:px(48, 24, "#2a1a10")
local t = c:save(O .. "aseprite/ph/rock-rose-seed.aseprite", O .. "png/ph/rock-rose-seed.png")
print(GV.report(t))

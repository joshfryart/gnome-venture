local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "r" }
local cream = GV.ramp("#f8eed2", { rim = "#fff3c8" })
-- rails
c:part(c:rect(32, 28, 63, 30), GV.ramp("#968f96"), { flat = true })
c:part(c:rect(32, 36, 63, 38), GV.ramp("#968f96"), { flat = true })
-- pickets
for _, x in ipairs({ 37, 43, 49, 55, 61 }) do
  c:part(c:rrect(x, 23, x + 3, 42, 1), cream, { flat = true })
  c:fill(c:rect(x + 3, 24, x + 3, 41), cream.shade)
end
-- end post with inset panel
c:part(c:rrect(22, 19, 34, 44, 2), GV.ramp("#d6c9b6"))
c:part(c:rrect(25, 23, 31, 40, 2), cream, { gloss = false })
c:part(c:rrect(21, 17, 35, 20, 1), GV.ramp("#d6c9b6"), { flat = true })
c:ground(43, 44, 22, 1.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/picket-fence-end.aseprite", O .. "png/ph/picket-fence-end.png")
print(GV.report(t))

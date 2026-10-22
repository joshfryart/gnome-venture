local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#a5663a")
local postR = GV.ramp("#5e2f1e")
local d = -4
local p = c:build{
  { "hrail", c:rrect(30 + d, 23 + d, 57, 33 + d, 2), wood },
  { "vrail", c:rrect(23 + d, 30 + d, 33 + d, 56, 2), wood },
}
local dk, lt = "#5e2f1e", "#dcb06a"
for _, x in ipairs({ 34, 40, 46, 52 }) do
  c:fill(c:line({ {x, 24 + d}, {x + 3, 31 + d} }, 1):clip(p.hrail.m), dk)
  c:fill(c:line({ {x + 1, 24 + d}, {x + 4, 31 + d} }, 1):clip(p.hrail.m), dk)
  c:fill(c:line({ {x + 3, 25 + d}, {x + 5, 29 + d} }, 1):clip(p.hrail.m), lt)
end
for _, y in ipairs({ 34, 40, 46 }) do
  c:fill(c:line({ {24 + d, y}, {31 + d, y + 3} }, 1):clip(p.vrail.m), dk)
  c:fill(c:line({ {24 + d, y + 1}, {31 + d, y + 4} }, 1):clip(p.vrail.m), dk)
  c:fill(c:line({ {25 + d, y + 3}, {29 + d, y + 5} }, 1):clip(p.vrail.m), lt)
end
c:part(c:ellipse(28 + d, 28 + d, 7, 7), postR, { gloss = { 21, 21 } })
c:part(c:ellipse(28 + d, 28 + d, 2.5, 2.5), wood, { flat = true })
local t = c:save(O .. "aseprite/ph/wattle-fence-corner.aseprite", O .. "png/ph/wattle-fence-corner.png")
print(GV.report(t))

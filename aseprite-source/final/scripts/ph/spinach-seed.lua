local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local top = c:rect(23, 20, 41, 30)
top:add(c:poly({{20,23},{21,14},{25,18},{28,13},{32,17},{36,13},{39,18},{43,14},{44,23}}))
local leaf = c:poly({{28,33},{33,36},{37,43},{35,50},{28,54},{21,50},{19,43},{23,36}})
local p = c:build{
  { "sack",  c:rrect(12, 28, 52, 54, 10), "#c9a96e", { stitch = { side = "lit" } } },
  { "top",   top, "#c9a96e" },
  { "twine", c:rect(21, 27, 43, 30), "#8c4a1a", { gloss = false } },
  { "leaf",  leaf, "moss" },
  { "tag",   c:rrect(39, 31, 51, 45, 2), "#7a5cc0" },
}
c:fill(c:line({{28,51},{28,37}}, 2), "#2f5a2a")
c:fill(c:line({{43,30},{44,32}}, 1), "#8c4a1a")
c:fill(c:rect(45, 33, 46, 34), "#f2e4c0")
c:px(16, 34, "#8c4a1a"); c:px(20, 51, "#8c4a1a"); c:px(46, 50, "#8c4a1a")
c:seam({ {18, 51}, {46, 51} })
local t = c:save(O .. "aseprite/ph/spinach-seed.aseprite", O .. "png/ph/spinach-seed.png")
print(GV.report(t))

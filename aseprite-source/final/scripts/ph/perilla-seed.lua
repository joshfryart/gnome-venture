local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lid = c:rrect(10, 15, 52, 28, 3):cut(c:poly({{30,29},{54,24},{54,29}}))
local p = c:build{
  { "hinge", c:rrect(27, 11, 35, 17, 1), "#5b6470", { flat = true } },
  { "inner", c:poly({{12,27},{51,23},{51,33},{12,33}}), "#3e2f66", { flat = true } },
  { "body",  c:rrect(12, 30, 50, 50, 3), "#8b8f96" },
  { "lid",   lid, "#c9c5bc" },
}
-- orange rim stripe on lid bottom
c:fill(c:line({{12,26},{29,26}}, 2):clip(p.lid.m), "#f08a24")
c:fill(c:line({{30,26},{50,22}}, 2):clip(p.lid.m):cut(c:rect(0,0,63,22)), "#f08a24")
-- leaf emblem
local leaf = c:ellipse(31, 20, 6, 3)
leaf:set(24, 21); leaf:set(25, 21); leaf:set(38, 19); leaf:set(37, 19)
c:part(leaf, "#58a03e", { flat = true, contact = false })
c:fill(c:line({{26,21},{36,19}}, 1), "#2e5a2c")
c:px(32, 21, "#2e5a2c"); c:px(30, 19, "#2e5a2c")
-- body seam + clasp
c:seam({ {14,34}, {48,34} })
c:button(29, 32)
c:ground(31, 51, 17, 1.5)
local t = c:save(O .. "aseprite/ph/perilla-seed.aseprite", O .. "png/ph/perilla-seed.png")
print(GV.report(t))

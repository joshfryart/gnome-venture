local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function beard(cx)
  return c:poly({ {cx - 7.5, 39}, {cx + 7.5, 39}, {cx + 5, 46}, {cx, 52}, {cx - 5, 46} })
end
c:build{
  { "lface",  c:ellipse(21, 37, 6.5, 6), GV.ramp("#dcb06a"), { cres = 2, deep = 1 } },
  { "lbeard", beard(21), GV.ramp("#f1ece0"), { cres = 3, deep = 1 } },
  { "lhat",   c:poly({ {12, 30}, {17, 13}, {31, 30} }), GV.ramp("#58a03e"), { cres = 3, deep = 1 } },
  { "lbrim",  c:rrect(11, 29, 31, 33, 1), GV.ramp("#2e5a2c"), { cres = 2, deep = 1, gloss = false } },
  { "rface",  c:ellipse(41, 37, 6.5, 6), GV.ramp("#f1ece0"), { cres = 2, deep = 1 } },
  { "rbeard", beard(41), GV.ramp("#d6c9b6"), { cres = 3, deep = 1 } },
  { "rhat",   c:poly({ {31, 30}, {45, 11}, {51, 30} }), GV.ramp("#7a5cc0"), { cres = 3, deep = 1 } },
  { "rbrim",  c:rrect(31, 29, 51, 33, 1), GV.ramp("#4e3a8a"), { cres = 2, deep = 1, gloss = false } },
}
c:seam({ {13, 31}, {29, 31} })
c:seam({ {33, 31}, {49, 31} })
c:eye(17, 35, true); c:eye(23, 35, true)
c:eye(37, 35, true); c:eye(43, 35, true)
local t = c:save(O .. "aseprite/ico/ico-people.aseprite", O .. "png/ico/ico-people.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function post(x0, x1)
  local m = c:rect(x0, 30, x1, 50)
  m:add(c:poly({ {x0, 31}, {(x0 + x1 + 1) / 2, 25}, {x1 + 1, 31} }))
  return m
end
local railL = c:rect(6, 36, 22, 38):add(c:rect(6, 43, 22, 45))
local railR = c:rect(42, 36, 57, 38):add(c:rect(42, 43, 57, 45))
local posts = post(7, 13):add(post(16, 22)):add(post(42, 48)):add(post(51, 57))
local leafL = c:poly({ {33, 30}, {28, 22}, {17, 19}, {22, 27}, {31, 31} })
local leafR = c:poly({ {32, 28}, {37, 18}, {47, 14}, {43, 24}, {34, 29} })
c:build{
  { "bed", c:ellipse(31.5, 44, 20, 7), "#7a4a1f" },
  { "top", c:ellipse(31.5, 42, 15, 4), "#9a6b3f", { flat = true } },
  { "railL", railL, "#c4925f" },
  { "railR", railR, "#c4925f" },
  { "posts", posts, "#dcb06a" },
  { "stem", c:rect(31, 26, 33, 41), "#2f5a2a", { flat = true } },
  { "leafL", leafL, "#6a9a3a" },
  { "leafR", leafR, "#7ab55c" },
}
local t = c:save(O .. "aseprite/ph/nav-garden.aseprite", O .. "png/ph/nav-garden.png")
print(GV.report(t))

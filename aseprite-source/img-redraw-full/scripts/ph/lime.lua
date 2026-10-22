local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 38, 16, 16)
local stem = c:rrect(30, 15, 33, 25, 1)
local leaf = c:poly({ {33, 19}, {37, 11}, {45, 7}, {47, 9}, {44, 16}, {36, 21} })
local p = c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "body", body, "moss", { gloss = { 24, 29 } } },
  { "leaf", leaf, "#6a9a3a", { cres = 2, deep = 1 } },
}
-- leaf midrib
c:fill(c:line({ {35, 18}, {44, 10} }, 1), "#a4b86a")
-- two bean dimples (lighter)
c:paint({ ".aa.", "aaaa", ".aa." }, 37, 32, { a = "#a4b86a" })
c:paint({ ".aa.", "aaaa", ".aa." }, 26, 43, { a = "#a4b86a" })
-- navel at stem end
c:paint({ "dd", "dd" }, 31, 23, { d = "#4a8a3e" })
local t = c:save(O .. "aseprite/ph/lime.aseprite", O .. "png/ph/lime.png")
print(GV.report(t))

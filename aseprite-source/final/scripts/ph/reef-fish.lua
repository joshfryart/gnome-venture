local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ {40, 33}, {56, 19}, {53, 33}, {56, 47} })
local body = c:ellipse(26, 33, 18, 12)
body:add(c:poly({ {38, 26}, {44, 31}, {44, 36}, {38, 41} }))
local fin = c:poly({ {21, 24}, {28, 13}, {38, 22}, {36, 25} })
local belly = c:ellipse(28, 39, 13, 5):clip(body)
belly:cut(c:rect(0, 0, 63, 34))
local p = c:build{
  { "fin", fin, "#4a8a3e" },
  { "tail", tail, "#6a9a3a" },
  { "body", body, "moss", { gloss = { 13, 27 }, light = body:copy():add(tail) } },
  { "belly", belly, "#f8eed2", { gloss = false, contact = false, rim = false } },
}
-- dark bars
c:fill(c:rect(27, 23, 29, 38):clip(body), "#2f5a2a")
c:fill(c:rect(34, 25, 36, 37):clip(body), "#2f5a2a")
-- tail rays
c:paint({ "r.......", ".r......" }, 45, 26, { r = "#4a8a3e" })
c:paint({ ".r......", "r......." }, 45, 39, { r = "#4a8a3e" })
-- mouth and gill
c:paint({ "uu" }, 9, 35, { u = "umber" })
c:paint({ "u", "u", ".u", ".u", "u" }, 21, 30, { u = "#2f5a2a" })
c:eye(14, 29)
local t = c:save(O .. "aseprite/ph/reef-fish.aseprite", O .. "png/ph/reef-fish.png")
print(GV.report(t))

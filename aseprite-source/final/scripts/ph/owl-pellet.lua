local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy body: overlapping blobs
local body = c:ellipse(32, 37, 19, 12)
body:add(c:ellipse(20, 35, 9, 9)):add(c:ellipse(31, 29, 10, 7)):add(c:ellipse(43, 33, 9, 9))
body:add(c:ellipse(37, 43, 10, 6)):add(c:ellipse(15, 40, 6, 6)):add(c:ellipse(49, 39, 6, 6))
-- fur tufts poking out of the edge
body:add(c:poly({{24,24},{27,19},{29,24}})):add(c:poly({{40,25},{44,21},{45,27}}))
body:add(c:poly({{9,38},{5,35},{10,42}})):add(c:poly({{53,36},{57,33},{55,40}}))
local rib = c:line({{35,28},{36,24},{38,20},{41,17},{45,15}}, 3)
local skull = c:ellipse(20, 27, 6, 5):add(c:rrect(17, 29, 23, 34, 1))
local tip = c:rrect(47, 38, 55, 42, 2)
local P = c:build{
  { "body", body, "#6b5a4a" },
  { "rib", rib, "cream", { flat = true } },
  { "skull", skull, "cream", { gloss = false } },
  { "tip", tip, "cream", { flat = true } },
}
-- dark fur patches
c:fill(c:ellipse(26, 41, 3, 2):clip(body), "#4a3c30")
c:fill(c:ellipse(36, 35, 2.5, 2):clip(body), "#4a3c30")
-- fur strokes
c:paint({ "f.", ".f", ".f" }, 30, 31, { f = "#8a7a64" })
c:paint({ ".f", "f.", "f." }, 18, 41, { f = "#8a7a64" })
c:paint({ "f.", "f.", ".f" }, 43, 40, { f = "#8a7a64" })
c:paint({ ".f", "f." }, 28, 46, { f = "#8a7a64" })
-- skull sockets
c:paint({"ss.ss","ss.ss"}, 17, 27, {s="#2a1a10"}); c:paint({"t.t.t"}, 18, 32, {t="#c9a96e"})
local t = c:save(O .. "aseprite/ph/owl-pellet.aseprite", O .. "png/ph/owl-pellet.png")
print(GV.report(t))

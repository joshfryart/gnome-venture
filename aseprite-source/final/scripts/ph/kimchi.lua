local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea", { rim = "#8fcbd8" })
local body = c:rrect(18, 22, 46, 55, 7)
local cont = c:rrect(21, 28, 43, 53, 5)
local lid = c:rrect(16, 12, 48, 23, 3)
local label = c:rect(22, 35, 42, 45)
local p = c:build{
  { "glass", body, glass, { gloss = { 24, 26 } } },
  { "contents", cont, "moss", { gloss = false, rim = false } },
  { "lid", lid, "gold", { gloss = { 20, 14 } } },
  { "label", label, GV.ramp("#f1ece0"), { gloss = false } },
}
-- leafy contents: darker leaf veins + red chilli flecks
c:paint({ "rr.", ".rr" }, 24, 30, { r = "#dd3a2a" })
c:paint({ "r.", "rr" }, 37, 31, { r = "#dd3a2a" })
c:paint({ "rr", ".r" }, 25, 47, { r = "#dd3a2a" })
c:paint({ ".r", "rr" }, 36, 48, { r = "#ae2a2a" })
c:paint({ "r" }, 31, 49, { r = "#dd3a2a" })
c:paint({ "g..", ".g.", "..g" }, 31, 29, { g = "#2f5a2a" })
c:paint({ "..g", ".g.", "g.." }, 29, 47, { g = "#2f5a2a" })
-- label dashes
c:paint({ "uuuuu.uuuu.uuuu" }, 25, 39, { u = "umber" })
c:paint({ "uuuu.uuuuu.uuu" }, 26, 42, { u = "umber" })
-- glass highlight
c:fill(c:rect(21, 26, 21, 33), "#c8ecdc")
c:fill(c:rect(21, 47, 21, 50), "#c8ecdc")
-- lid seam
c:seam({ { 18, 21 }, { 46, 21 } })
c:button(30, 15)
local t = c:save(O .. "aseprite/ph/kimchi.aseprite", O .. "png/ph/kimchi.png")
print(GV.report(t))

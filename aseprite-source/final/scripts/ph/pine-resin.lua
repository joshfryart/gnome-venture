local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bark = c:rrect(8, 40, 55, 55, 4):add(c:rrect(14, 38, 48, 41, 2))
local pool = c:ellipse(31.5, 41, 17, 5)
local drip = c:rrect(41, 41, 45, 50, 2):add(c:ellipse(43, 51, 3, 3))
local glob = c:ellipse(31.5, 30, 12, 12):add(c:poly({{31,6},{33,6},{43,26},{20,26}}))
local P = c:build{
  { "bark", bark, "wood", { gloss = false } },
  { "pool", pool, "gold", { gloss = false } },
  { "drip", drip, GV.ramp("#d0862a"), { gloss = { 42, 44 } } },
  { "glob", glob, "gold", { gloss = false } },
}
-- bark furrows
c:paint({ "ffff....ffffff" }, 12, 50, { f = "#5e2f1e" })
c:paint({ "fffff" }, 46, 47, { f = "#5e2f1e" })
c:paint({ "fffffff" }, 20, 53, { f = "#5e2f1e" })
-- inner glow
c:fill(c:ellipse(34, 33, 3, 4), "#f5cf6a")
-- bubble ring
c:paint({ ".b.", "b.b", ".b." }, 36, 23, { b = "#fff1c8" })
-- big enamel gloss comma
c:paint({
  "..gg",
  ".ggg",
  "ggg.",
  "gg..",
  "gg..",
  "gg..",
  ".g..",
}, 23, 20, { g = "#fff1c8" })
c:px(29, 17, "#fff1c8"); c:px(30, 15, "#fff1c8")
local t = c:save(O .. "aseprite/ph/pine-resin.aseprite", O .. "png/ph/pine-resin.png")
print(GV.report(t))

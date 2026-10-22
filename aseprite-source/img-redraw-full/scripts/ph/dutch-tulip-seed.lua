local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- ember-family ramps
local orange = GV.ramp("#f08a24")
local band   = GV.ramp("#e0501f")
-- round belly
local body = c:ellipse(31.5, 37, 18, 15)
-- neck band
local neck = c:rrect(18, 21, 45, 26, 2)
-- domed lid
local lid = c:ellipse(31.5, 21, 15, 10):cut(c:rect(0, 22, 63, 63))
lid:add(c:rect(17, 19, 46, 21))
-- bulb knob
local knob = c:ellipse(31.5, 10, 4, 4)
c:build{
  { "body", body, orange },
  { "neck", neck, band },
  { "lid",  lid,  orange },
  { "knob", knob, "petal" },
}
-- leaf on the knob
c:part(c:ellipse(37, 6.5, 2, 1.5), "#58a03e", { flat = true })
-- tulip motif on the belly
c:paint({
  "p..p..p",
  "pp.p.pp",
  "pLppppp",
  "pLppppp",
  "ppppppp",
  ".ppppp.",
  "..ppp..",
}, 28, 30, { p = "#e46a9b", L = "#f6b8cf" })
c:paint({
  "...g...",
  "...g...",
  "gg.g.gg",
  ".ggggg.",
  "...g...",
}, 28, 37, { g = "#2f5a2a" })
-- seam where the lid meets the neck
c:seam({ {19, 22}, {44, 22} })
-- glaze dots near the foot
c:fill(c:rect(25, 46, 26, 47), "#8c4a1a")
c:fill(c:rect(31, 47, 32, 48), "#8c4a1a")
c:fill(c:rect(37, 46, 38, 47), "#8c4a1a")
c:ground(31.5, 52, 14, 1.5)
local t = c:save(O .. "aseprite/ph/dutch-tulip-seed.aseprite", O .. "png/ph/dutch-tulip-seed.png")
print(GV.report(t))

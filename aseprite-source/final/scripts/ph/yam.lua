local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = GV.ramp("#58a03e")
local lL = c:poly({{33,23},{26,16},{24,9},{26,6},{30,10},{34,18}})
local lR = c:poly({{31,23},{38,16},{40,9},{38,6},{34,10},{30,18}})
local body = c:ellipse(32,28,15,9):add(c:poly({{17,28},{48,28},{43,40},{37,50},{34.5,56},{29.5,56},{27,50},{21,40}}))
c:build{
  { "leafL", lL, leaf, { flat = true } },
  { "leafR", lR, leaf, { flat = true } },
  { "body", body, GV.ramp("#e0501f") },
}
local S = "#5e2f1e"
c:fill(c:line({{23,32},{27,31}},2), S)
c:fill(c:line({{34,41},{38,40}},2), S)
c:fill(c:line({{39,28},{42,29}},2), S)
local t = c:save(O.."aseprite/ph/yam.aseprite", O.."png/ph/yam.png")
print(GV.report(t))

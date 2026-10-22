local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 39, 19, 13)
local lip = c:rrect(16, 23, 48, 27, 2)
local lid = c:ellipse(32, 23, 14, 7):cut(c:rect(0, 24, 63, 63))
local knob = c:ellipse(32, 13, 3, 3)
local whole = body:copy(); whole:add(lip); whole:add(lid)
local p = c:build{
  { "body", body, "water", { light = whole } },
  { "lip", lip, GV.ramp("#8fcbd8") },
  { "lid", lid, "water" },
  { "knob", knob, "gold" },
}
-- glaze band following the belly curve
local band = c:line({ {12, 30}, {22, 32}, {32, 33}, {42, 32}, {52, 30} }, 2):clip(body)
c:fill(band, "#2f6290")
-- fruit crest
local fruit = c:ellipse(32, 44, 6.5, 6.5)
c:part(fruit, "red", { gloss = { 28, 40 } })
c:paint({
  "aa..a..aa",
  ".aaaaaaa.",
}, 28, 37, { a = "#ae2a2a" })
c:px(31, 44, "#ffc27a"); c:px(34, 42, "#ffc27a"); c:px(33, 46, "#ffc27a"); c:px(29, 46, "#ffc27a")
c:seam({ {18, 25}, {46, 25} })
local t = c:save(O .. "aseprite/ph/pomegranate-seed.aseprite", O .. "png/ph/pomegranate-seed.png")
print(GV.report(t))

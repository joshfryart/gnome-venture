local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 46.5, 20, 6.5)
local top = c:ellipse(30.5, 44, 14, 3)
local L = {{31,44},{27,43},{23,40},{19,35},{17,30},{17,25},{22,25},{26,28},{29,32},{31,37},{32,43}}
local R = {}
for i, p in ipairs(L) do R[i] = {63 - p[1], p[2]} end
local p = c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { contour = false, contact = false, gloss = false, flat = true } },
  { "lleaf", c:poly(L), "moss", { gloss = {21, 28} } },
  { "rleaf", c:poly(R), GV.ramp("#58a03e"), { gloss = {39, 28} } },
}
c:line({{22,29},{27,34},{30,40}}, 1):each(function(x,y) if p.lleaf.m:has(x,y) then c:px(x,y,GV.R.moss.shade) end end)
c:line({{41,29},{36,34},{33,40}}, 1):each(function(x,y) if p.rleaf.m:has(x,y) then c:px(x,y,"#3f7a2e") end end)
c:paint({ "u.....u" }, 18, 48, { u = "#6b3812" })
c:paint({ "u...u" }, 36, 50, { u = "#6b3812" })
local t = c:save(O .. "aseprite/ph/stage-vegetable-1.aseprite", O .. "png/ph/stage-vegetable-1.png")
print(GV.report(t))

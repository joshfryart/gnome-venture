local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ant = GV.ramp("#8c4a1a")
local leafR = { "moss", GV.ramp("#4a8a3e"), "moss" }
local ants = { {10, 25}, {21, 35}, {32, 45} }
local parts = {}
for i, a in ipairs(ants) do
  local ox, oy = a[1], a[2]
  table.insert(parts, { "legs"..i, c:line({{ox+9,oy+2},{ox+7,oy+3},{ox+5,oy+5}}, 2)
      :add(c:line({{ox+11,oy+1},{ox+11,oy+5}}, 2))
      :add(c:line({{ox+13,oy+1},{ox+15,oy+3},{ox+17,oy+5}}, 2)), GV.R.leg, { flat = true } })
end
for i, a in ipairs(ants) do
  local ox, oy = a[1], a[2]
  table.insert(parts, { "abd"..i, c:ellipse(ox+4.5, oy, 4.5, 3.5), ant })
  table.insert(parts, { "tho"..i, c:ellipse(ox+11, oy-1, 2, 2), ant, { flat = true } })
  table.insert(parts, { "head"..i, c:ellipse(ox+16.5, oy-2.5, 3.5, 3.5), ant })
  table.insert(parts, { "ant"..i, c:line({{ox+19,oy-3},{ox+21,oy-3},{ox+22,oy-1}}, 1):add(c:line({{ox+20,oy-2},{ox+21,oy-2}},1)), GV.ramp("#4a2c1a"), { flat = true } })
  table.insert(parts, { "leaf"..i, c:poly({{ox+5,oy-9},{ox+8,oy-14},{ox+14,oy-16},{ox+20,oy-16},{ox+22,oy-12},{ox+19,oy-8},{ox+14,oy-6},{ox+8,oy-6}}), leafR[i] })
end
c:build(parts)
for i, a in ipairs(ants) do
  local ox, oy = a[1], a[2]
  local r = type(leafR[i]) == "string" and GV.R[leafR[i]] or leafR[i]
  c:fill(c:line({{ox+8,oy-8},{ox+13,oy-10},{ox+19,oy-13}}, 1), r.rim)
  c:eye(ox+16, oy-4, true)
end

local t = c:save(O.."aseprite/ph/creature-leafcutter-column.aseprite", O.."png/ph/creature-leafcutter-column.png")
print(GV.report(t))

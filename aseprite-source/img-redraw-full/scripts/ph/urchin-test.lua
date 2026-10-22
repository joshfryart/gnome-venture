local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local frame = c:line({{32,52},{32,36}}, 6)
frame:add(c:line({{32,44},{20,32},{20,18}}, 6))
frame:add(c:line({{32,40},{44,28},{44,18}}, 6))
frame:add(c:ellipse(20.5, 16.5, 3.5))
frame:add(c:ellipse(44.5, 16.5, 3.5))
frame:add(c:rrect(26, 48, 38, 52, 2))
local p = c:build{
  { "frame", frame, GV.ramp("#e46a9b", { rim = "#f6b8cf" }), { gloss = {18,22} } },
}
-- tubercle beads along the arms
for _, q in ipairs({ {19,24}, {19,28}, {26,37}, {32,46}, {44,22}, {40,32}, {32,40} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#f6b8cf")
end
local t = c:save(B .. "aseprite/ph/urchin-test.aseprite", B .. "png/ph/urchin-test.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local body = c:poly({{32,7},{44,20},{51,36},{47,48},{38,54},{26,54},{17,48},{13,36},{20,20}})
-- feathery notches along both sides
local notches = {
  {{13,30},{22,33},{13,36}}, {{14,42},{23,44},{16,48}}, {{17,22},{25,26},{15,28}},
  {{51,30},{42,33},{51,36}}, {{50,42},{41,44},{48,48}}, {{47,22},{39,26},{49,28}},
}
for _, n in ipairs(notches) do body:cut(c:poly(n)) end
local p = c:build{
  { "frond", body, GV.ramp("#7ab55c"), { gloss = {22, 38} } },
}
local S = "#2f5a2a"
c:fill(c:rect(31, 16, 32, 57), "#4a8a3e")
c:fill(c:rect(31, 16, 31, 57), "#6a9a3a")
-- side fronds (diagonal veins)
local fr = {
  {{31,36},{22,29}}, {{32,28},{41,21}}, {{31,44},{24,38}},
  {{32,38},{40,32}}, {{32,46},{39,41}}, {{31,26},{25,22}},
}
for _, f in ipairs(fr) do c:fill(c:line(f, 2), "#4a8a3e") end
local tufts = {{21,28},{40,20},{23,37},{39,31},{38,40},{24,21}}
for _, q in ipairs(tufts) do
  c:fill(c:rect(q[1]-1, q[2]-1, q[1]+1, q[2]+1), "#a4b86a"); c:px(q[1]-1, q[2]-1, "#c8d77a")
end
-- tip cluster
c:fill(c:rrect(30, 11, 33, 14, 1), "#c8d77a")
-- stem stub below frond
c:fill(c:rect(31, 55, 32, 57), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/dill.aseprite", O .. "png/ph/dill.png")
print(GV.report(t))

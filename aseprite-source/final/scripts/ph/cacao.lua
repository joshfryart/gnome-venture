local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pod = c:poly({ {9,42},{13,34},{20,26},{28,20},{37,16},{46,15},{53,16},{56,19},{55,24},
  {50,31},{42,37},{33,42},{24,45},{16,46},{11,45} })
local p = c:build{
  { "stem", c:line({ {12,40},{8,44},{6,47} }, 3), "moss", { flat = true } },
  { "pod", pod, GV.ramp("#8c4a1a"), { gloss = { 20, 30 } } },
}
-- ridge along the belly
c:fill(c:line({ {15,42},{24,40},{33,37},{42,32},{50,25} }, 2):clip(p.pod.m:shrink(2)), "#5e2f1e")
-- bumps with lit rim
for _, b in ipairs({ {25,30}, {34,25}, {43,21} }) do
  local e = c:ellipse(b[1] + 0.5, b[2] + 0.5, 3.5, 3)
  c:fill(e:copy():shift(-1, -1), "#c98a50")
  c:fill(e, "#44281c")
  c:px(b[1] - 1, b[2] - 1, "#8a4f2a")
end
c:ground(33, 52, 16, 2)
local t = c:save(O .. "aseprite/ph/cacao.aseprite", O .. "png/ph/cacao.png")
print(GV.report(t))

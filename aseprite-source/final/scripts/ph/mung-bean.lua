local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- boat pod: thick curved line, low-left to high-right, fattest in the middle
local pod = c:line({ {14,42},{20,38},{30,33},{40,28},{48,24},{52,21} }, 9)
pod:add(c:line({ {20,38},{30,33},{40,28},{46,25} }, 13))
pod:add(c:ellipse(33, 33, 14, 7))
-- groove (open lens along the top)
local groove = c:poly({ {16,36},{24,30},{33,26},{42,22},{49,20},{47,24},{40,29},{31,34},{22,38} })
groove:add(c:line({ {19,35},{28,30},{37,26},{46,22} }, 6))

local woodS = GV.ramp("#8a4f2a")
local p = c:build{
  { "tail", c:line({ {14,43},{11,45},{9,47} }, 3), "#2f5a2a", { flat = true } },
  { "pod", pod, woodS },
}
c:fill(groove:clip(pod), "#5e2f1e")
-- three beans in the groove
local beans = c:build{
  { "b1", c:ellipse(25, 33, 4.5, 4.5), "moss" },
  { "b2", c:ellipse(34, 29, 4.5, 4.5), "moss" },
  { "b3", c:ellipse(43, 25, 4.5, 4.5), "moss" },
}
-- ridge line along the lower edge
c:line({ {17,44},{24,42},{32,39},{40,35},{47,30},{51,26} }, 1):each(function(x, y)
  if pod:has(x, y) then c:px(x, y, "#a8582f") end
end)

local t = c:save(O .. "aseprite/ph/mung-bean.aseprite", O .. "png/ph/mung-bean.png")
print(GV.report(t))

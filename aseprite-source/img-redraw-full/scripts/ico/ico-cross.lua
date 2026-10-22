local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function bar(x0, y0, x1, y1)
  local m = c:mask()
  for i = 0, 34 do
    local t = i / 34
    m:add(c:ellipse(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, 5, 5))
  end
  return m
end
local a = bar(16.5, 16.5, 47.5, 47.5)
local b = bar(47.5, 16.5, 16.5, 47.5)
c:build{
  { "barA", a, "red", { light = a:copy():add(b) } },
  { "barB", b, "red", { light = a:copy():add(b) } },
}
local t = c:save(O .. "aseprite/ico/ico-cross.aseprite", O .. "png/ico/ico-cross.png")
print(GV.report(t))

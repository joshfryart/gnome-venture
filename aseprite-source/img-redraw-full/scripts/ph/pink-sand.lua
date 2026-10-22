local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local m = c:ellipse(24.5, 42, 16, 20)
m:add(c:ellipse(45, 46, 12, 10))
m:add(c:rrect(8, 44, 56, 54, 5))
m:cut(c:rect(0, 55, 63, 63))
local p = c:build{
  { "mound", m, GV.ramp("#e8a8b0", { shade = "#d98fa8" }) },
}
local hi, lo = c:mask(), c:mask()
local function wave(x0, x1, yb, per, amp)
  for x = x0, x1 do
    local y = yb - math.floor(amp * math.abs(math.sin((x - x0) * math.pi / per)) + 0.5)
    hi:set(x, y); lo:set(x, y + 1)
  end
end
wave(17, 43, 39, 9, 2.4)
wave(27, 51, 47, 8, 2)
local inner = m:shrink(3)
hi:clip(inner); lo:clip(inner); lo:cut(hi)
c:fill(lo, "#d98fa8"); c:fill(hi, "#f6b8cf")
for _, q in ipairs({ {18,31},{23,27},{15,36},{27,31} }) do c:px(q[1], q[2], "#fff3c8") end
local t = c:save(O .. "aseprite/ph/pink-sand.aseprite", O .. "png/ph/pink-sand.png")
print(GV.report(t))

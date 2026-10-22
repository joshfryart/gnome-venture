local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function tell(cx, cy, rx, ry, deg)
  local a = math.rad(deg); local pts = {}
  for i = 0, 47 do
    local t = i / 48 * 2 * math.pi
    local x, y = rx * math.cos(t), ry * math.sin(t)
    pts[#pts + 1] = { cx + x * math.cos(a) - y * math.sin(a) + 0.5, cy + x * math.sin(a) + y * math.cos(a) + 0.5 }
  end
  return c:poly(pts)
end

local petal = GV.ramp("#e46a9b")
local lowL = tell(24.5, 43, 5, 9, 30)
local lowR = tell(39.5, 43, 5, 9, -30)
local sideL = tell(19, 29, 10, 7, -18)
local sideR = tell(45, 29, 10, 7, 18)
local top = tell(32, 19, 7, 9, 0)
local lip = c:ellipse(32, 41, 8, 7)
local p = c:build{
  { "lowL", lowL, petal },
  { "lowR", lowR, petal },
  { "sideL", sideL, petal },
  { "sideR", sideR, petal },
  { "top", top, petal },
  { "lip", lip, GV.ramp("#e46a9b", { base = "#c9508a" }) },
}
-- pale streaks on side petals and dark streak on top petal
c:fill(c:line({ {13, 28}, {22, 30} }, 2), "#f6b8cf")
c:fill(c:line({ {42, 30}, {51, 28} }, 2), "#f6b8cf")
c:fill(c:line({ {32, 13}, {32, 22} }, 1), "#b8456f")
-- pale inner lip
c:fill(c:ellipse(32, 40.5, 5, 4), "#f6b8cf")
c:fill(c:ellipse(32, 45, 4, 1.5):cut(c:ellipse(32, 40.5, 5, 4)), "#b8456f")
-- lip spots
for _, s in ipairs({ {28, 39}, {35, 39}, {30, 42}, {33, 42}, {31, 37} }) do
  c:fill(c:rect(s[1], s[2], s[1] + 1, s[2] + 1), "#8a2f62")
end
-- column
c:part(c:ellipse(32, 31, 3.5, 3.5), "cream", { gloss = false })
c:fill(c:ellipse(32, 31, 1.5, 1.5), "#f1b92d")
c:px(31, 30, "#fff3c8")
local t = c:save(O .. "aseprite/flowers/orchid.aseprite", O .. "png/flowers/orchid.png")
print(GV.report(t))

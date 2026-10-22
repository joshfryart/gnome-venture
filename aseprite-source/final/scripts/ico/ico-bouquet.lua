local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function flower(cx, cy)
  local m = c:ellipse(cx, cy, 6.5)
  for i = 0, 4 do
    local a = -math.pi / 2 + i * 2 * math.pi / 5
    m:add(c:ellipse(cx + 4.5 * math.cos(a), cy + 4.5 * math.sin(a), 3.5))
  end
  return m
end
local cone = c:poly({ {19, 38}, {46, 38}, {36, 57}, {29, 57} })
c:build{
  { "stems", c:line({ {32, 48}, {24, 30} }, 2):add(c:line({ {32, 48}, {32, 30} }, 2)):add(c:line({ {32, 48}, {40, 30} }, 2)), "moss", { flat = true } },
  { "pink", flower(19, 21), GV.ramp("#e46a9b") },
  { "violet", flower(45, 21), GV.ramp("#7b66b4") },
  { "orange", flower(32, 14), GV.ramp("#e0501f") },
  { "cone", cone, "gold" },
  { "yellow", flower(25, 31), "gold" },
  { "ppink", flower(39, 31), GV.ramp("#f6b8cf") },
}
c:fill(c:poly({ {27, 41}, {38, 41}, {34, 56}, {31, 56} }), "#e8a317")
c:seam({ {38, 42}, {35, 55} })
c:seam({ {22, 40}, {44, 40} }, { free = true })
c:fill(c:ellipse(25, 31, 2.5), "#f1ece0")
c:px(24, 30, "#fff3c8")
for _, p in ipairs({ {19, 21}, {32, 14}, {45, 21}, {39, 31} }) do
  c:fill(c:ellipse(p[1], p[2], 2.5), "#f5cf6a")
  c:px(p[1] - 1, p[2] - 1, "#fff1c8")
  c:px(p[1] + 1, p[2] + 1, "#d0862a")
end
local t = c:save(O .. "aseprite/ico/ico-bouquet.aseprite", O .. "png/ico/ico-bouquet.png")
print(GV.report(t))

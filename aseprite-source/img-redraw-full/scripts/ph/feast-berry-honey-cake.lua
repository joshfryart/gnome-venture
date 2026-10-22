local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function star(cx, cy, R, r)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end
local dome = c:ellipse(31.5, 34, 18, 15):cut(c:rect(0, 40, 63, 63))
dome:add(c:rrect(14, 32, 49, 44, 3))
local p = c:build{
  { "plate", c:ellipse(31.5, 46, 25, 8), GV.ramp("#d6c9b6") },
  { "plateIn", c:ellipse(31.5, 45, 20, 5.5), GV.ramp("#f4f0e0"), { flat = true } },
  { "cake", dome, "gold", { stitch = { side = "lit" } } },
  { "berryL", c:ellipse(22, 36, 4, 4), GV.ramp("#b07a10") },
  { "berryR", c:ellipse(40.5, 34, 4.5, 4.5), "moss" },
  { "bead", c:ellipse(31.5, 25, 3, 3), "gold" },
  { "star", star(31.5, 17, 8.5, 4), GV.ramp("#f5cf6a") },
}
-- inner plate rim line
-- honey drip scallops along the dome base
local drip = { 16, 17, 22, 23, 24, 29, 30, 35, 36, 37, 42, 43, 47 }
for _, x in ipairs({16,17,18, 25,26, 33,34,35, 44,45}) do c:px(x, 44, "#d0862a"); end
for _, x in ipairs({17, 25, 34, 44}) do c:px(x, 45, "#d0862a") end
local t = c:save(O .. "aseprite/ph/feast-berry-honey-cake.aseprite", O .. "png/ph/feast-berry-honey-cake.png")
print(GV.report(t))

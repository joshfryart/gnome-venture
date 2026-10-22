local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0")
local neck = c:poly({ {26, 18}, {38, 18}, {36, 26}, {28, 26} })
neck:add(c:poly({ {24, 12}, {27, 18}, {23, 18} })); neck:add(c:poly({ {29, 11}, {32, 18}, {27, 18} }))
neck:add(c:poly({ {35, 11}, {37, 18}, {32, 18} })); neck:add(c:poly({ {40, 12}, {41, 18}, {37, 18} }))
neck:add(c:rect(23, 16, 40, 19))
-- melon capsule: rotated pill
local cap = c:mask()
local a = math.rad(-35); local ca, sa = math.cos(a), math.sin(a)
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x + 0.5 - 31.5, y + 0.5 - 40
  local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
  local hu = math.max(math.abs(u) - 7.5, 0)
  if hu * hu + v * v <= 4.6 * 4.6 then cap:set(x, y) end
end end
local cord = c:line({ {26, 28}, {24, 33} }, 2):add(c:line({ {38, 28}, {40, 33} }, 2))
local p = c:build{
  { "body", c:ellipse(31.5, 41, 18, 15), cloth, { stitch = { side = "lit" } } },
  { "neck", neck, cloth },
  { "string", c:rrect(25, 25, 39, 28, 1), GV.ramp("#dcb06a") },
  { "cords", cord, GV.ramp("#dcb06a"), { flat = true } },
  { "capsule", cap, "moss" },
  { "stem", c:rrect(40, 30, 43, 34, 1), GV.ramp("#2f5a2a"), { flat = true } },
}
-- melon bumps
c:paint({ "d..d", "..d.", "d..d" }, 28, 39, { d = "#4a8a3e" })
c:px(23, 45, "#4a8a3e"); c:px(36, 37, "#4a8a3e")
c:seam({ {16, 34}, {18, 50} })
c:ground(31.5, 57, 14, 1.5)
local t = c:save(O .. "aseprite/ph/bitter-melon-seed.aseprite", O .. "png/ph/bitter-melon-seed.png")
print(GV.report(t))

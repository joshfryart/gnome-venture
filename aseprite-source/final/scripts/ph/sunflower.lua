local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local CX, CY = 31.5, 23.5

local function petal(a, r0, r1, wd)
  local ca, sa = math.cos(a), math.sin(a)
  local px, py = -sa, ca
  local function P(r, w) return { CX + ca * r + px * w, CY + sa * r + py * w } end
  local rm = r0 + (r1 - r0) * 0.45
  return c:poly({ P(r0, wd * 0.7), P(rm, wd), P(r1 - 2.5, wd * 0.55), P(r1, 0),
                  P(r1 - 2.5, -wd * 0.55), P(rm, -wd), P(r0, -wd * 0.7) })
end

local back, front = c:mask(), c:mask()
for i = 0, 7 do
  local a = i * math.pi / 4
  if i % 2 == 0 then front:add(petal(a - math.pi / 2, 5, 17, 4.2))
  else back:add(petal(a - math.pi / 2, 5, 15.5, 4.0)) end
end

local leaf = c:poly({ {30, 50}, {26, 51}, {20, 49}, {16, 42}, {22, 42}, {27, 45}, {31, 48} })

local p = c:build{
  { "stem",  c:rect(30, 36, 33, 57), "moss" },
  { "leaf",  leaf, GV.ramp("#6a9a3a") },
  { "back",  back, GV.ramp("#d0862a"), { light = back:copy():add(front) } },
  { "front", front, "gold", { light = back:copy():add(front) } },
  { "disc",  c:ellipse(CX, CY, 7.5, 7.5), GV.ramp("#5e2f1e", { base = "#5e2f1e" }) },
}
-- seed dots ring
for i = 0, 9 do
  local a = i * math.pi / 5
  local x = math.floor(CX + math.cos(a) * 4.6 + 0.5)
  local y = math.floor(CY + math.sin(a) * 4.6 + 0.5)
  c:px(x, y, "#8a4f2a")
end
c:px(31, 23, "#8a4f2a"); c:px(32, 24, "#8a4f2a")
-- leaf vein
c:paint({ "v....", ".vv..", "...vv" }, 21, 44, { v = "#4a8a3e" })
c:ground(31.5, 58, 8, 1.5)
local t = c:save(O .. "aseprite/ph/sunflower.aseprite", O .. "png/ph/sunflower.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function oval(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u * u) / (rx * rx) + (v * v) / (ry * ry) <= 1 then m:set(x, y) end
  end end
  return m
end

local legs = c:rect(25, 50, 27, 57):add(c:rect(37, 50, 39, 57))
local body = c:ellipse(31.5, 35, 17, 17)
local belly = c:ellipse(31.5, 42, 9.5, 10)
local wingL = oval(15, 39, 5.5, 12, 14)
local wingR = oval(48, 39, 5.5, 12, -14)
local beak = c:poly({ {28, 27}, {36, 27}, {36, 31}, {34, 35}, {31, 37}, {29, 36}, {31, 34}, {28, 31} })

local p = c:build{
  { "legs", legs, "gold", { flat = true } },
  { "body", body, GV.ramp("#dcb06a") },
  { "belly", belly, GV.ramp("#f8eed2"), { stitch = { side = "lit" } } },
  { "wingL", wingL, GV.ramp("#a5663a") },
  { "wingR", wingR, GV.ramp("#a5663a") },
  { "beak", beak, "gold" },
}
-- toes
c:paint({ "g.g.g" }, 24, 57, { g = "#b8661a" })
c:paint({ "g.g.g" }, 36, 57, { g = "#b8661a" })
-- feather scallops on wings
c:paint({ "d..", ".d.", "..d", "...", "d..", ".d.", "..d" }, 13, 36, { d = "#5e2f1e" })
c:paint({ "..d", ".d.", "d..", "...", "..d", ".d.", "d.." }, 48, 36, { d = "#5e2f1e" })
-- eyes and heavy slanted brows
c:eye(22, 23); c:eye(37, 23)
c:fill(c:line({ {20, 20}, {28, 22} }, 2):add(c:line({ {20, 19}, {27, 21} }, 2)), "#2a1a10")
c:fill(c:line({ {43, 20}, {35, 22} }, 2):add(c:line({ {43, 19}, {36, 21} }, 2)), "#2a1a10")
-- nostril
c:px(33, 29, "#7a3a14")

local t = c:save(O .. "aseprite/ph/creature-griffon-vulture.aseprite", O .. "png/ph/creature-griffon-vulture.png")
print(GV.report(t))

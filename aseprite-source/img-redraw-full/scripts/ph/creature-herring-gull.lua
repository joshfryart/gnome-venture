local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function tilted(cx, cy, rx, ry, deg)
  local m = c:mask(); local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

local legs = c:rect(26, 50, 27, 56):add(c:rect(36, 50, 37, 56))
local feet = c:rect(23, 56, 29, 57):add(c:rect(34, 56, 40, 57))
legs:add(feet)
local body = c:ellipse(31.5, 35, 17, 17)
local belly = c:ellipse(31.5, 43, 9, 7.5)
local wingL = tilted(16, 40, 5, 10.5, 14)
local wingR = tilted(47, 40, 5, 10.5, -14)
local beak = c:poly({ {28, 30}, {36, 30}, {35, 33}, {33, 36}, {32, 37}, {31, 36}, {29, 33} })
local wingRamp = GV.ramp("#a38f80")
c:build{
  { "legs",  legs,  "gold", { flat = true } },
  { "body",  body,  GV.ramp("#f8eed2"), { pale = true } },
  { "belly", belly, GV.ramp("#f1ece0"), { pale = true, gloss = false, contour = "#f5b860" } },
  { "wingL", wingL, wingRamp, { gloss = { 14, 33 } } },
  { "wingR", wingR, wingRamp, { gloss = false } },
  { "beak",  beak,  "gold", { gloss = { 30, 31 } } },
}
-- feather tips on wings
c:paint({ "d.d", ".d." }, 15, 47, { d = wingRamp.deep })
c:paint({ "d.d", ".d." }, 46, 47, { d = wingRamp.deep })
-- red gull spot on beak hook
c:px(32, 35, "#dd3a2a"); c:px(33, 34, "#dd3a2a")
-- brows
c:fill(c:line({ {22, 21}, {28, 23} }, 2), GV.C.ol3)
c:fill(c:line({ {41, 21}, {35, 23} }, 2), GV.C.ol3)
c:eye(23, 24); c:eye(36, 24)
c:ground(31.5, 58, 13, 1.5)
local t = c:save(O .. "aseprite/ph/creature-herring-gull.aseprite", O .. "png/ph/creature-herring-gull.png")
print(GV.report(t))

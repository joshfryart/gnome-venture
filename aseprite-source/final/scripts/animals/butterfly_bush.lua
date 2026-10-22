-- animals/butterfly_bush : fan of purple plumes with an orange butterfly
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function rell(cx, cy, rx, ry, deg, taper)
  local a = math.rad(deg)
  local upx, upy = math.sin(a), -math.cos(a)
  local rtx, rty = math.cos(a), math.sin(a)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local v = dx * upx + dy * upy
    local u = dx * rtx + dy * rty
    local r = rx
    if taper and v > 0 then r = rx * (1 - 0.35 * v / ry) end  -- pointier top
    if (u / r)^2 + (v / ry)^2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function leaf(x0, y0, x1, y1, w)
  local m = c:mask()
  local L = math.sqrt((x1 - x0)^2 + (y1 - y0)^2)
  local ux, uy = (x1 - x0) / L, (y1 - y0) / L
  for y = 0, 63 do for x = 0, 63 do
    local t = (x - x0) * ux + (y - y0) * uy
    local d = -(x - x0) * uy + (y - y0) * ux
    if t >= 0 and t <= L and math.abs(d) <= w * math.sin(math.pi * (t / L) ^ 0.8) then m:set(x, y) end
  end end
  return m
end

local back = GV.ramp("#7b66b4")
local front = GV.ramp("#a894dc")
c:build{
  { "stem",  c:rect(30, 34, 33, 53), GV.ramp("#8a4f2a"), { gloss = false } },
  { "leafL", leaf(31, 50, 12, 39, 4), "leaf" },
  { "leafR", leaf(32, 46, 51, 36, 4), "leaf" },
  { "plL",   rell(19.5, 30, 5, 10, -26, true), back },
  { "plR",   rell(44.5, 30, 5, 10, 26, true), back },
  { "plC",   rell(32, 22, 5.5, 11.5, 0, true), back },
  { "frL",   rell(25.5, 28, 4.5, 9, -12, true), front },
  { "frR",   rell(38.5, 28, 4.5, 9, 12, true), front },
}
-- florets: tiny diamonds up the plumes
for _, p in ipairs({ { 32, 14 }, { 31, 19 }, { 18, 26 }, { 45, 26 }, { 25, 25 }, { 38, 25 }, { 26, 31 }, { 39, 31 }, { 20, 33 }, { 44, 33 } }) do
  c:paint({ ".f.", "fgf" }, p[1] - 1, p[2], { f = "#e6cdf5", g = "#c8a8e6" })
end
-- butterfly
c:build{
  { "wingL", c:ellipse(44.5, 13, 3, 3):add(c:ellipse(45, 17, 2, 1.5)), GV.ramp("#f08a24"), { gloss = { 43, 12 } } },
  { "wingR", c:ellipse(50.5, 13, 3, 3):add(c:ellipse(50, 17, 2, 1.5)), GV.ramp("#f08a24"), { gloss = { 49, 12 } } },
  { "body",  c:rect(47, 11, 48, 18), GV.ramp("#35161f"), { flat = true } },
}
c:px(46, 10, "#35161f"); c:px(49, 10, "#35161f")
c:px(44, 14, "#35161f"); c:px(51, 14, "#35161f")

local t = c:save(O .. "aseprite/animals/butterfly_bush.aseprite", O .. "png/animals/butterfly_bush.png")
print(GV.report(t))

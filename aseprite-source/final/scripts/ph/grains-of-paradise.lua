local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local podR = GV.ramp("#f08a24")
local seedR = GV.ramp("#e0501f")
local P0, C, P2 = { 11, 41 }, { 28, 24 }, { 54, 18 }
local function bz(t)
  local u = 1 - t
  return u*u*P0[1] + 2*u*t*C[1] + t*t*P2[1], u*u*P0[2] + 2*u*t*C[2] + t*t*P2[2]
end
local pod = c:mask()
local ridge = {}
for i = 0, 60 do
  local t = i / 60
  local x, y = bz(t)
  local r = 3 + 8 * math.sin(math.pi * t) ^ 0.7
  pod:add(c:ellipse(x, y, r, r))
  if i % 6 == 0 and t > 0.08 and t < 0.92 then
    local x2, y2 = bz(math.min(1, t + 0.01))
    local dx, dy = x2 - x, y2 - y
    local L = math.sqrt(dx*dx + dy*dy)
    local nx, ny = dy / L, -dx / L   -- upward normal
    ridge[#ridge + 1] = { math.floor(x + nx * (r - 4) + 0.5), math.floor(y + ny * (r - 4) + 0.5) }
  end
end
local stem = c:line({ {11, 41}, {8, 44}, {6, 47} }, 3)
local p = c:build{
  { "stem", stem, "moss", { flat = true } },
  { "pod", pod, podR, { gloss = { 16, 32 } } },
}
c:fill(c:line(ridge, 2), "#e0501f")
local seeds = { {24, 33}, {33, 29}, {42, 25} }
for i, s in ipairs(seeds) do
  c:part(c:ellipse(s[1], s[2], 3.5, 3.5), seedR, { gloss = { s[1] - 2, s[2] - 2 }, contact = false })
  c:px(s[1] + 1, s[2] + 1, "#6b1b2c")
end
local t = c:save(O .. "aseprite/ph/grains-of-paradise.aseprite", O .. "png/ph/grains-of-paradise.png")
print(GV.report(t))

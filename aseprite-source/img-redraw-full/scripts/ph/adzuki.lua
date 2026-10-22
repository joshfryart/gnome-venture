local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function bz(t)
  local u = 1 - t
  return u*u*10 + 2*u*t*26 + t*t*54, u*u*46 + 2*u*t*20 + t*t*24
end
local pod = c:mask()
for i = 0, 40 do
  local t = i / 40
  local x, y = bz(t)
  local r = 2 + 6.5 * math.sin(math.pi * (0.08 + 0.84 * t))
  pod:add(c:ellipse(x, y, r, r))
end
local stem = c:line({ {12, 43}, {9, 47}, {6, 48} }, 3)
local beans = {}
for i, t in ipairs({ 0.3, 0.5, 0.7 }) do
  local x, y = bz(t)
  beans[i] = c:ellipse(math.floor(x) + 0.5, math.floor(y) - 3.5, 5, 5)
end
local p = c:build{
  { "stem", stem, "#4a8a3e", { flat = true } },
  { "pod", pod, GV.ramp("#dcb06a", { rim = "#d9a660" }), { cres = 3, deep = 1 } },
  { "b1", beans[1], GV.ramp("#a5663a") },
  { "b2", beans[2], GV.ramp("#a5663a") },
  { "b3", beans[3], GV.ramp("#a5663a") },
  { "tip", c:rect(54, 22, 56, 23), "#b07a45", { flat = true } },
}
local pts = {}
for i = 0, 10 do local x, y = bz(0.12 + 0.76 * i / 10); pts[#pts+1] = { math.floor(x), math.floor(y) + 5 } end
c:seam(pts)
local t = c:save(O .. "aseprite/ph/adzuki.aseprite", O .. "png/ph/adzuki.png")
print(GV.report(t))

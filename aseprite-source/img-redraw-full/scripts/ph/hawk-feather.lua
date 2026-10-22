local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- feather axis from base B to tip T
local Bx, By, Tx, Ty = 17, 52, 50, 9
local dx, dy = Tx - Bx, Ty - By
local L = math.sqrt(dx*dx + dy*dy)
local ux, uy = dx / L, dy / L
local nx, ny = -uy, ux            -- normal (right/lower side)
local left, right = {}, {}
local N = 24
for i = 0, N do
  local t = i / N
  local w = math.sin(math.pi * (0.08 + 0.92 * t)) ^ 0.75
  if t > 0.65 then w = w * math.max(0.05, 1 - (t - 0.65) * 2.4) end   -- sharpen tip
  local ax, ay = Bx + dx * t, By + dy * t
  left[#left+1]  = { ax - nx * w * 10, ay - ny * w * 10 }   -- upper-left vane (wider)
  right[#right+1] = { ax + nx * w * 7.5, ay + ny * w * 7.5 }
end
local pts = {}
for i = 1, #left do pts[#pts+1] = left[i] end
for i = #right, 1, -1 do pts[#pts+1] = right[i] end
local vane = c:poly(pts)
-- notch in the vane edges (feather splits)
vane:cut(c:line({ {22, 37}, {18, 40} }, 2))
vane:cut(c:line({ {40, 37}, {44, 39} }, 2))
local p = c:build{
  { "vane", vane, GV.ramp("#f08a24"), { gloss = { 23, 23 } } },
}
-- three slanted 2px bars, retoned per shade so the crescent survives
local vr, br = GV.ramp("#f08a24"), GV.ramp("#b8452f")
local bars = c:mask()
for _, b in ipairs({ { 25, 41 }, { 31, 32 }, { 38, 23 } }) do
  local cx, cy = b[1], b[2]
  bars:add(c:line({ { cx - nx * 12 - ux * 3, cy - ny * 12 - uy * 3 }, { cx + nx * 10 - ux * 2, cy + ny * 10 - uy * 2 } }, 2))
end
bars:clip(p.vane.m)
bars:each(function(x, y)
  local h = c:get(x, y)
  for _, k in ipairs({ "rim", "base", "shade", "deep", "bounce" }) do
    if h == vr[k] then c:px(x, y, br[k]) return end
  end
end)
-- shaft, tip, quill
local shaft = c:line({ { 14, 56 }, { 30, 35 }, { 46, 13 } }, 2)
c:part(shaft, GV.ramp("#d6322b"), { flat = true, contact = false })
c:part(c:poly({ { 45, 13 }, { 53, 5 }, { 49, 15 } }), GV.ramp("#b8452f"), { flat = true, contact = false })
c:part(c:rect(12, 55, 14, 57), GV.ramp("#ecc58a"), { flat = true, contact = false })
local t = c:save(O .. "aseprite/ph/hawk-feather.aseprite", O .. "png/ph/hawk-feather.png")
print(GV.report(t))

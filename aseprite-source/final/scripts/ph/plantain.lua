local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local a = math.rad(35)
local ux, uy = math.cos(a), -math.sin(a)
local cx, cy, half, r = 31.5, 32, 15, 8.5
local ax, ay = cx - ux*half, cy - uy*half
local bx, by = cx + ux*half, cy + uy*half
local function along(x, y) return (x - cx)*ux + (y - cy)*uy end
local function dseg(x, y)
  local t = math.max(-half, math.min(half, along(x, y)))
  local px, py = cx + ux*t, cy + uy*t
  return math.sqrt((x-px)^2 + (y-py)^2)
end
local body, cap, stub = c:mask(), c:mask(), c:mask()
for y = 0, 63 do for x = 0, 63 do
  local d, t = dseg(x, y), along(x, y)
  if d <= r then
    if t > half + 1 then cap:set(x, y) else body:set(x, y) end
  end
  -- short stalk stub poking out of the cap
  local perp = math.abs((x - cx)*(-uy) + (y - cy)*ux)
  if perp <= 2 and t > half + r - 2 and t <= half + r + 3 then stub:set(x, y) end
end end
c:build{
  { "body", body, "gold" },
  { "stub", stub, "#2f5a2a", { flat = true } },
  { "cap",  cap, GV.ramp("#3f7a34") },
}
-- ridge line along the upper side
local rpts = {}
for _, t in ipairs({ -half, half }) do
  rpts[#rpts+1] = { math.floor(cx + ux*t - uy*4 + 0.5), math.floor(cy + uy*t + ux*4*-1 + 0.5) }
end
c:fill(c:line(rpts, 1), "#f5cf6a")
-- freckle beans
c:paint({ ".ff", "ff." }, 23, 38, { f = "#8a4f2a" })
c:paint({ "ff.", ".ff" }, 36, 31, { f = "#8a4f2a" })
c:paint({ ".f", "ff" }, 29, 37, { f = "#8a4f2a" })
local t = c:save(O .. "aseprite/ph/plantain.aseprite", O .. "png/ph/plantain.png")
print(GV.report(t))

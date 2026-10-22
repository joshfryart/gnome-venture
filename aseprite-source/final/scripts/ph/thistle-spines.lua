local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered thorn along a quadratic bezier: w0 at base, sharp at tip
local function thorn(b, k, t, w0)
  local L, R = {}, {}
  local N = 24
  for i = 0, N do
    local u = i / N
    local x = (1-u)^2*b[1] + 2*(1-u)*u*k[1] + u^2*t[1]
    local y = (1-u)^2*b[2] + 2*(1-u)*u*k[2] + u^2*t[2]
    local dx = 2*(1-u)*(k[1]-b[1]) + 2*u*(t[1]-k[1])
    local dy = 2*(1-u)*(k[2]-b[2]) + 2*u*(t[2]-k[2])
    local l = math.sqrt(dx*dx + dy*dy)
    local w = w0 * 0.5 * (1 - u)^0.8 + 0.6
    L[#L+1] = { x - dy/l*w, y + dx/l*w }
    R[#R+1] = { x + dy/l*w, y - dx/l*w }
  end
  local pts = {}
  for i = 1, #L do pts[#pts+1] = L[i] end
  for i = #R, 1, -1 do pts[#pts+1] = R[i] end
  return c:poly(pts)
end

local backT  = thorn({16, 52}, {2, 26}, {31, 5}, 9)
local frontT = thorn({26, 52}, {56, 34}, {32, 5}, 9)
local nub = c:ellipse(21, 52, 7, 4)

local p = c:build{
  { "back",  backT,  GV.ramp("#a8582f") },
  { "front", frontT, GV.ramp("#d9a660") },
  { "nub",   nub, "wood" },
}
-- pale cream stripe along the inner curve of the back thorn
local stripe = c:line({ {13, 44}, {12, 36}, {15, 27}, {20, 19} }, 2):clip(backT):cut(frontT)
c:fill(stripe, "#f1ece0")
-- nub stitch-wrap: a tied thread band where both thorns join
c:seam({ {15, 51}, {28, 51} })
c:ground(21, 58, 9, 1.5)
local t = c:save(O .. "aseprite/ph/thistle-spines.aseprite", O .. "png/ph/thistle-spines.png")
print(GV.report(t))

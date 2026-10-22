local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- egg-shaped wing: root (rx,ry) -> tip (tx,ty), narrow at root, fat near tip
local function wing(rx, ry, tx, ty, wmax)
  local m = c:mask()
  local dx, dy = tx - rx, ty - ry
  local L = math.sqrt(dx*dx + dy*dy); local ux, uy = dx/L, dy/L
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x + 0.5 - rx, y + 0.5 - ry
    local a = px*ux + py*uy; local b = -px*uy + py*ux
    if a >= 0 and a <= L then
      local t = a / L
      local hw = wmax * math.sqrt(math.max(0, 1 - ((t - 0.62)/0.62)^2)) * (0.35 + 0.65*t)
      if t > 0.62 then hw = wmax * math.sqrt(math.max(0, 1 - ((t - 0.62)/0.38)^2)) end
      if math.abs(b) <= hw then m:set(x, y) end
    end
  end end
  return m
end
local lw = wing(31, 36, 12, 12, 10)
local rw = wing(33, 36, 52, 12, 10)
local moss = "moss"
local p = c:build{
  { "lw", lw, moss, {} },
  { "rw", rw, moss, {} },
  { "body", c:rrect(29, 20, 34, 50, 3), "dusk" },
}
-- veins along each wing axis
local vc = "#4a8a3e"
c:fill(c:line({ {28, 32}, {23, 26}, {18, 20} }, 1):clip(lw:shrink(2)), vc)
c:fill(c:line({ {35, 32}, {40, 26}, {45, 20} }, 1):clip(rw:shrink(2)), vc)
c:fill(c:line({ {22, 25}, {16, 26} }, 1):clip(lw:shrink(2)), vc)
c:fill(c:line({ {41, 25}, {47, 26} }, 1):clip(rw:shrink(2)), vc)
-- head knob + antennae with clubs
c:paint({ "a....a", ".a..a.", "..aa.." }, 29, 15, { a = "#54447f" })
c:fill(c:rect(27, 13, 29, 15), "#3e2f66"); c:fill(c:rect(34, 13, 36, 15), "#3e2f66")

local t = c:save(O .. "aseprite/ph/cricket-chirp.aseprite", O .. "png/ph/cricket-chirp.png")
print(GV.report(t))

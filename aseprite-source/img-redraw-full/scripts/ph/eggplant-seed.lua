local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(13, 12, 51, 56, 3)
local flap = c:poly({ {13, 12}, {52, 12}, {52, 25}, {32, 31}, {13, 25} })
local win = c:rrect(18, 31, 46, 51, 5)

-- eggplant: rotated pill (-35 deg), centre (31,41)
local egg = c:mask()
local a = math.rad(-35)
local ca, sa = math.cos(a), math.sin(a)
for y = 28, 56 do for x = 14, 50 do
  local dx, dy = x - 31, y - 42
  local u = dx * ca + dy * sa     -- along axis
  local v = -dx * sa + dy * ca    -- across
  local hw = 9.5
  local r = (u < 0) and 5 or 4    -- fatter bottom end
  local uu = math.max(0, math.abs(u) - (hw - r))
  if uu * uu + v * v <= r * r then egg:set(x, y) end
end end

c:part(body, GV.ramp("#f1ece0"), { gloss = { 16, 30 } })
c:part(win, GV.ramp("#f4f0e0"), { gloss = false })
c:fill(win:copy():cut(win:shrink(2)), "#7a5cc0")
c:part(flap, GV.ramp("#f4f0e0"))
c:part(egg, GV.ramp("#7a5cc0", { shade = "#4e3a8a" }))
-- calyx at upper-right end
c:paint({
  "..gg..",
  ".gggg.",
  "gggggg",
  "g.gg.g",
}, 36, 31, { g = "#2e5a2c" })
c:fill(c:rect(40, 28, 41, 31), "#2e5a2c")
-- flap edge line (V)
c:fill(c:line({ {14, 24}, {32, 29}, {50, 24} }, 2), "#dcb06a")
c:seam({ {16, 21}, {48, 21} })
-- seed dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 53, x + 1, 54), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/eggplant-seed.aseprite", O .. "png/ph/eggplant-seed.png")
print(GV.report(t))

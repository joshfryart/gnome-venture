local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slats: six 3px bars with 1px gaps, rounded tops
local slatParts = {}
local xs = { 20, 24, 28, 32, 36, 40 }
local tops = { 26, 24, 23, 23, 24, 26 }
for i, x in ipairs(xs) do
  local m = c:rrect(x, tops[i], x + 3, 46, 1)
  slatParts[#slatParts + 1] = { "slat" .. i, m, GV.ramp("#d9a660"), { flat = true } }
end

local parts = {}
for _, s in ipairs(slatParts) do parts[#parts + 1] = s end
parts[#parts + 1] = { "rails", c:rect(20, 29, 43, 31):add(c:rect(20, 39, 43, 41)), GV.ramp("#c4925f"), { flat = true } }
parts[#parts + 1] = { "brace", c:line({ { 22, 38 }, { 41, 32 } }, 3), GV.ramp("#8a4f2a"), { gloss = false } }
parts[#parts + 1] = { "bushL", c:ellipse(15, 39, 6.5, 7.5), "moss" }
parts[#parts + 1] = { "bushR", c:ellipse(48, 39, 6.5, 7.5), "moss" }
local p = c:build(parts)

-- lavender flower tips on the bushes
local lav, lavL = "#8a6ac8", "#b59ae6"
for _, q in ipairs({ { 12, 35 }, { 16, 34 }, { 19, 36 }, { 45, 35 }, { 49, 34 }, { 52, 36 } }) do
  c:px(q[1], q[2], lavL); c:px(q[1], q[2] + 1, lav)
end
-- leaf glints
c:px(14, 41, "#c8d77a"); c:px(17, 43, "#c8d77a"); c:px(47, 42, "#c8d77a"); c:px(50, 44, "#c8d77a")

c:seam({ { 21, 30 }, { 42, 30 } })
c:ground(31.5, 47, 22, 1.5)
local t = c:save(O .. "aseprite/ph/lavender-border-gate.aseprite", O .. "png/ph/lavender-border-gate.png")
print(GV.report(t))

-- ph/bitter-melon : long warty green gourd lying diagonally, stem upper-right
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- axis from tail (12,51) to shoulder (48,15)
local ax, ay, bx, by = 12, 51, 47, 16
local body = c:mask()
local N = 60
for i = 0, N do
  local t = i / N
  local x, y = ax + (bx - ax) * t, ay + (by - ay) * t
  -- fat toward the stem end, tapering to a point at the tail
  local hw = 1.5 + 6.5 * math.sin(math.pi * (0.15 + 0.8 * t)) ^ 0.7 * (0.55 + 0.45 * t)
  if t > 0.92 then hw = hw * (1 - (t - 0.92) * 4) end
  body:add(c:ellipse(x, y, hw, hw))
end
local stem = c:line({ {45, 18}, {49, 14}, {52, 11} }, 3):add(c:rrect(50, 8, 54, 12, 1))

c:build{
  { "body", body, "moss" },
  { "stem", stem, GV.ramp("#2f5a2a", { rim = "#4a8a3e" }), { gloss = false } },
}
-- centre ridge along the length
c:fill(c:line({ {16, 47}, {44, 19} }, 1), "#6a9a3a")

-- warts: bean bumps in two rows (lit top, shade bottom)
local function wart(x, y)
  c:paint({ ".gl.", "glld", ".dd." }, x, y, { g = "#c8d77a", l = "#a4b86a", d = "#2f5a2a" })
end
-- upper row (above ridge)
for _, p in ipairs({ {17, 41}, {23, 35}, {29, 29}, {35, 23}, {41, 18} }) do wart(p[1], p[2]) end
-- lower row (below ridge)
for _, p in ipairs({ {20, 47}, {26, 41}, {32, 35}, {38, 29}, {44, 23} }) do wart(p[1], p[2]) end

local t = c:save(O .. "aseprite/ph/bitter-melon.aseprite", O .. "png/ph/bitter-melon.png")
print(GV.report(t))

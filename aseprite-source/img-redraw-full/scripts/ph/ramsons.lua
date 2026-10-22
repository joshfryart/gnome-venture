local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local PX, PY = 32, 35
local function leaf(deg, len, wid)
  local a = math.rad(deg)
  local dx, dy = math.sin(a), -math.cos(a)
  local nx, ny = -dy, dx
  local L, R = {}, {}
  local N = 14
  for i = 0, N do
    local t = i / N
    local w = wid * (math.sin(math.pi * (0.15 + 0.85 * t)) ^ 0.8)
    if i == N then w = 1.1 end
    local bx, by = PX + 0.5 + dx * (4 + len * t), PY + 0.5 + dy * (4 + len * t)
    L[#L + 1] = { bx + nx * w, by + ny * w }
    table.insert(R, 1, { bx - nx * w, by - ny * w })
  end
  for _, q in ipairs(R) do L[#L + 1] = q end
  return c:poly(L)
end
local p = c:build{
  { "stem", c:rrect(30, 34, 33, 53, 1), "#2f5a2a", { flat = true } },
  { "outerL", leaf(-68, 18, 3.8), "moss" },
  { "outerR", leaf(68, 18, 3.8), "moss" },
  { "midL", leaf(-34, 22, 3.8), "moss" },
  { "midR", leaf(34, 22, 3.8), "moss" },
  { "centre", leaf(0, 23, 4.2), "leaf" },
  { "hub", c:ellipse(31.5, 35, 4.5, 4.5), "moss", { gloss = { 29, 33 } } },
}
c:line({ { 31, 29 }, { 31, 14 } }, 1):each(function(x, y) if p.centre.m:has(x, y) then c:px(x, y, "#2f5a2a") end end)
local s = c:save(O .. "aseprite/ph/ramsons.aseprite", O .. "png/ph/ramsons.png")
print(GV.report(s))

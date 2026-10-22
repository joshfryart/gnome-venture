local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tilted lens (boat) helper: points along two arcs between tips
local function lens(x0, y0, x1, y1, bulgeTop, bulgeBot)
  local pts = {}
  local dx, dy = x1 - x0, y1 - y0
  local len = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / len, -dx / len -- normal pointing "up"
  for i = 0, 20 do
    local t = i / 20
    local b = math.sin(math.pi * t) * bulgeTop
    pts[#pts + 1] = { x0 + dx * t + nx * b, y0 + dy * t + ny * b }
  end
  for i = 20, 0, -1 do
    local t = i / 20
    local b = math.sin(math.pi * t) * bulgeBot
    pts[#pts + 1] = { x0 + dx * t - nx * b, y0 + dy * t - ny * b }
  end
  return c:poly(pts)
end

local stem = c:line({ {15, 44}, {13, 47}, {11, 50} }, 3)
local back = lens(11, 43, 52, 23, 11, 4)
local front = lens(11, 45, 53, 25, 5, 11)
local slit = lens(17, 39, 47, 26, 5, 3)
local seeds = c:ellipse(23, 36, 4, 4)
seeds:add(c:ellipse(32, 32.5, 4.5, 4.5))
seeds:add(c:ellipse(41, 29, 4, 4))
local tendril = c:line({ {51, 25}, {53, 22}, {54, 19}, {52, 17} }, 2)

local p = c:build{
  { "stem", stem, "leaf", { flat = true } },
  { "back", back, GV.ramp("#4a8a3e"), { gloss = false } },
  { "front", front, "moss", { gloss = { 18, 40 }, light = front:copy():add(back) } },
  { "slit", slit, GV.ramp("#c8d77a"), { gloss = false, rim = false } },
  { "seeds", seeds, GV.ramp("#7a5cc0"), { gloss = false } },
  { "tendril", tendril, "leaf", { flat = true } },
}
-- seed glints
for _, s in ipairs({ { 21, 34 }, { 30, 30 }, { 39, 27 } }) do
  c:px(s[1], s[2], "#a894dc"); c:px(s[1] + 1, s[2], "#a894dc"); c:px(s[1], s[2] + 1, "#a894dc")
end
-- seam along the lower lip of the slit
c:seam({ {19, 41}, {27, 40}, {36, 36}, {44, 32}, {48, 29} })

local t = c:save(D .. "img-redraw-full/aseprite/ph/giant-seed-pod.aseprite", D .. "img-redraw-full/png/ph/giant-seed-pod.png")
print(GV.report(t))

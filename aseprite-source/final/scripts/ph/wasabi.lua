-- ph/wasabi : knobby tan rhizome tapering down, two green leaves on top
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"

-- pointed lens between two points, max half-width hw
local function lens(x0, y0, x1, y1, hw)
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx * dx + dy * dy)
  local px, py = -dy / L, dx / L
  local a, b = {}, {}
  for i = 0, 12 do
    local t = i / 12
    local w = hw * math.sin(math.pi * t) ^ 0.8
    local cx, cy = x0 + dx * t, y0 + dy * t
    a[#a + 1] = { cx + px * w, cy + py * w }
    table.insert(b, 1, { cx - px * w, cy - py * w })
  end
  for _, p in ipairs(b) do a[#a + 1] = p end
  return c:poly(a)
end

-- root: wide flat top, knobby sides, pointed bottom
local root = c:poly({
  {19, 21}, {45, 21}, {46, 25}, {44, 30}, {43, 34}, {41, 39}, {39, 44},
  {36, 50}, {33, 56}, {31, 56}, {28, 50}, {25, 44}, {23, 39}, {21, 34}, {19, 29}, {18, 25},
})
root:add(c:rrect(19, 19, 45, 26, 3))
root:add(c:ellipse(19.5, 27, 2, 2.5)):add(c:ellipse(44.5, 33, 2, 2.5))
root:add(c:ellipse(23, 40, 2, 2)):add(c:ellipse(39.5, 45, 1.5, 2))

c:build{
  { "leafL", lens(31, 22, 23, 7, 5.5), "#4a8a3e" },
  { "leafR", lens(34, 22, 42, 7, 5.5), "#7ab55c" },
  { "root",  root, "#d9a660", { gloss = {26, 27} } },
}

-- leaf veins
c:fill(c:line({ {30, 18}, {26, 10} }, 1), GV.R.moss.deep)
c:fill(c:line({ {35, 18}, {39, 10} }, 1), GV.R.moss.shade)

-- bark nicks: short horizontal ring dashes
local nick = "#5e2f1e"
for _, n in ipairs({ {22, 28, 30}, {34, 39, 31}, {29, 33, 37}, {36, 40, 41}, {25, 29, 45}, {31, 34, 50} }) do
  c:fill(c:rect(n[1], n[3], n[2], n[3]), nick)
end

c:ground(32, 57, 15, 2.5)
local t = c:save(O .. "aseprite/ph/wasabi.aseprite", O .. "png/ph/wasabi.png")
print(GV.report(t))

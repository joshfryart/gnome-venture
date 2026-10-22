local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local rails = c:rect(8, 24, 56, 29):add(c:rect(8, 40, 56, 45))
local function pale(x0, x1)
  local mid = (x0 + x1 + 1) / 2
  return c:rect(x0, 20, x1, 55):add(c:poly({ {x0, 21}, {mid, 12}, {x1 + 1, 21} }))
end

local parts = {
  { "rails", rails, GV.ramp("#c4925f") },
}
local xs = { {9, 19}, {27, 37}, {45, 55} }
for i, x in ipairs(xs) do
  parts[#parts + 1] = { "pale" .. i, pale(x[1], x[2]), "cream", { gloss = (i == 1) and { 12, 19 } or false } }
end
local p = c:build(parts)

-- nail dots where pales cross rails
for _, x in ipairs(xs) do
  local nx = math.floor((x[1] + x[2]) / 2)
  c:paint({ "nn", "nn" }, nx, 26, { n = "#8a4f2a" })
  c:paint({ "nn", "nn" }, nx, 42, { n = "#8a4f2a" })
end

-- grass tufts at the feet between pales
for _, gx in ipairs({ 20, 38 }) do
  c:fill(c:ascii({ "..g.g.", ".gggg.", "gggggg" }, gx, 53), "#7ab55c")
end

c:ground(31.5, 57, 22, 1.5)
local t = c:save(O .. "aseprite/ph/picket-fence.aseprite", O .. "png/ph/picket-fence.png")
print(GV.report(t))

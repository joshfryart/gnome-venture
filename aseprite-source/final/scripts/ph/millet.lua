local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stalk = c:rect(31, 24, 33, 57)
local leaf = c:line({ {31, 52}, {27, 49}, {23, 47}, {19, 44}, {16, 40} }, 3)

-- tilted bean: stack of offset rows
local function bean(cx, cy, dir)
  local m = c:mask()
  m:add(c:ellipse(cx, cy, 3, 5))
  return m:cut(c:mask()) -- placeholder chain
end
local function tilted(cx, cy, dir)
  -- dir -1 leans top outward to the left, +1 to the right
  local m = c:mask()
  for i = -5, 5 do
    local half = math.floor(math.sqrt(math.max(0, 1 - (i / 5.5) ^ 2)) * 3.5 + 0.5)
    local off = math.floor((-i) * 0.35 * dir + 0.5)
    if half >= 1 then m:add(c:rect(cx - half + off, cy + i, cx + half - 1 + off, cy + i)) end
  end
  return m
end

local parts = {
  { "stalk", stalk, "moss", { flat = true } },
  { "leaf", leaf, "moss", { gloss = false } },
}
local tan = GV.ramp("#dcb06a")
local ys = { 23, 31, 39 }
for i, y in ipairs(ys) do
  parts[#parts + 1] = { "L" .. i, tilted(27, y, -1), "#f5cf6a" }
  parts[#parts + 1] = { "R" .. i, tilted(38, y, 1), tan }
end
parts[#parts + 1] = { "tip", c:ellipse(32.5, 14, 3.5, 7), "#f5cf6a" }
c:build(parts)


local t = c:save(O .. "aseprite/ph/millet.aseprite", O .. "png/ph/millet.png")
print(GV.report(t))

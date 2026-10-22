local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- egg: pointed top, fuller bottom
local egg = c:mask()
for y = 9, 54 do
  local t = (y - 32.5) / 22.5
  local hw = 16.5 * math.sqrt(math.max(0, 1 - t * t)) * (1 + 0.13 * t)
  for x = 0, 63 do
    if math.abs(x - 31.5) <= hw then egg:set(x, y) end
  end
end

local nestBack = c:ellipse(31.5, 50, 17, 4)
local nestFront = c:ellipse(31.5, 53, 18, 4):cut(c:ellipse(31.5, 48.5, 12, 3))

c:build{
  { "nestback", nestBack, GV.ramp("#b07a45"), { gloss = false } },
  { "egg", egg, GV.ramp("#d9a066"), { gloss = { 22, 18 } } },
  { "nest", nestFront, GV.ramp("#d9a660"), { gloss = false } },
}

-- highlight sweep (cream-safe light stripe)
c:line({ { 20, 31 }, { 20, 26 }, { 22, 21 }, { 25, 17 } }, 2):each(function(x, y)
  if egg:has(x, y) then c:px(x, y, "#f3d6ae") end
end)
c:px(22, 18, "#fff1c8"); c:px(23, 18, "#fff1c8"); c:px(22, 19, "#fff1c8")

-- speckles
c:fill(c:rect(36, 29, 37, 30), "#a8582f")
c:fill(c:rect(27, 39, 28, 40), "#a8582f")
c:px(40, 36, "#a8582f")

-- straw strands on the nest
c:paint({ "s..s...s..s...s..s" }, 23, 54, { s = "#a8582f" })
c:paint({ ".g...g..g...g...g." }, 23, 52, { g = "#ecc58a" })

local t = c:save(O .. "aseprite/animals/item-hen-egg.aseprite", O .. "png/animals/item-hen-egg.png")
print(GV.report(t))

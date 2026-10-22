-- ph/holly-hedge-corner
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "rb" }
local holly = GV.ramp("#3f8a3a", { rim = "#a4b86a", gloss = "#c8d77a", deep = "#2f5a2a" })

-- ground shadow in the inner corner of the L
c:fill(c:rect(40, 41, 63, 46):add(c:rect(41, 41, 46, 63)), "#6a4528")

-- spiky holly puffs: a round puff with leaf points on its outer side
local parts, n, centres = {}, 0, {}
local function puff(x, y, dir, gl)
  n = n + 1
  local m = c:ellipse(x, y, 7.5, 7.5)
  if dir == "up" or dir == "both" then
    m:add(c:poly({ {x - 6, y - 4}, {x - 5, y - 10}, {x - 1, y - 6} }))
    m:add(c:poly({ {x + 1, y - 6}, {x + 5, y - 10}, {x + 6, y - 4} }))
  end
  if dir == "left" or dir == "both" then
    m:add(c:poly({ {x - 4, y - 6}, {x - 10, y - 5}, {x - 6, y - 1} }))
    m:add(c:poly({ {x - 6, y + 1}, {x - 10, y + 5}, {x - 4, y + 6} }))
  end
  parts[#parts + 1] = { "p" .. n, m, holly, { gloss = gl or false } }
  centres[#centres + 1] = { x, y }
end
for _, x in ipairs({ 68, 61, 54, 47, 40 }) do puff(x, 32, "up") end
for _, y in ipairs({ 68, 61, 54, 47, 40 }) do puff(32, y, "left") end
puff(30, 31, "both", { 25, 27 })
c:build(parts)

-- red berry clusters, one per puff, offset to its upper-left
for i, p in ipairs(centres) do
  local bx, by = p[1] - 3, p[2] - 3
  if i == #centres then bx, by = p[1] + 1, p[2] - 1 end
  if bx < 62 and by < 62 then
    c:paint({
      "rr.",
      "grr",
      ".rs",
    }, bx, by, { r = "#dd3a2a", g = "#ff9158", s = "#ae2a2a" })
  end
end

local t = c:save(O .. "aseprite/ph/holly-hedge-corner.aseprite", O .. "png/ph/holly-hedge-corner.png")
print(GV.report(t))

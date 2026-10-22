local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- teardrop leaf: pointed top (y=11), widest at y=34, rounded base at y=52
local leaf = c:mask()
for y = 11, 52 do
  local hw
  if y <= 36 then
    local t = (y - 11) / 25
    hw = 18 * t ^ 0.75
  else
    local t = (y - 36) / 16
    hw = 18 * math.sqrt(math.max(0, 1 - t * t))
  end
  local cxr = 32 + (y < 18 and (18 - y) * 0.25 or 0) -- tip curls slightly right
  for x = math.floor(cxr - hw + 0.5), math.floor(cxr + hw - 0.5) do leaf:set(x, y) end
end
leaf:add(c:rect(32, 10, 33, 11))

c:build{
  { "stalk", c:rrect(30, 48, 34, 57, 1), "#4a8a3e" },
  { "leaf", leaf, "moss", { gloss = { 20, 26 } } },
}
-- midrib
c:fill(c:line({ {32, 50}, {32, 16} }, 2):clip(leaf), "#c8d77a")
-- side veins (1px accents)
local vein = "#4a8a3e"
local function v(pts) c:fill(c:line(pts, 1):clip(leaf), vein) end
v({ {31, 26}, {26, 22}, {23, 21} })
v({ {34, 26}, {39, 22}, {42, 21} })
v({ {31, 36}, {24, 31}, {19, 30} })
v({ {34, 36}, {41, 31}, {46, 30} })
v({ {31, 45}, {25, 42}, {20, 41} })
v({ {34, 45}, {40, 42}, {45, 41} })

local t = c:save(O .. "aseprite/ph/basil.aseprite", O .. "png/ph/basil.png")
print(GV.report(t))

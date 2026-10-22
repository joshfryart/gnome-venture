local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2 }
local W, H = 120, 40

-- sky
c:bands(c:rect(0, 0, W - 1, H - 1), { "#c9e6f2", "#bde0ef", "#b3dbec", "#a9d6ea", "#9fcfe5" }, { dir = "v" })
c:fill(c:ellipse(24, 8, 6, 1.5), "#f4f0e0"); c:fill(c:ellipse(22, 7, 3, 1), "#f4f0e0")
c:fill(c:ellipse(84, 5.5, 8, 1.5), "#f4f0e0"); c:fill(c:ellipse(87, 4.5, 4, 1), "#f4f0e0")

local function band(top, f)
  local m = c:mask()
  for x = 0, W - 1 do
    local y0 = math.floor(f(x) + 0.5)
    for y = math.max(0, y0), H - 1 do m:set(x, y) end
  end
  return m
end
local far = band(0, function(x) return 22 - 4.5 * math.sin(math.pi * x / (W - 1)) + 1.2 * math.sin(x / 7) end)
local mid = band(0, function(x) return 25 + 2.5 * math.sin(x / 11 + 1) end)
local front = band(0, function(x) return 33.5 + 1 * math.sin(x / 9 + 2) end)

c:part(far, GV.ramp("#58a03e"), { gloss = false, rim = false, bounce = false })
c:part(mid, "moss", { gloss = false, bounce = false })

-- trees: x, crown cy, r, colour
local trees = {
  { 8.5, 20, 6, "#e0501f" }, { 26.5, 22, 5, "#e8a317" }, { 45.5, 24.5, 4.5, "#d6322b" },
  { 66, 18.5, 6.5, "#f08a24" }, { 84, 23, 5, "#d6322b" }, { 103, 25.5, 4, "#e8a317" },
  { 115, 21, 5.5, "#e0501f" },
}
for _, t in ipairs(trees) do
  local x, cy, r = t[1], t[2], t[3]
  local tx = math.floor(x)
  c:part(c:rect(tx - 1, math.floor(cy), tx + 1, 35), GV.ramp("#c4925f"), { gloss = false, flat = true })
end
for _, t in ipairs(trees) do
  local x, cy, r, col = t[1], t[2], t[3], t[4]
  local crown = c:ellipse(x, cy, r, r * 0.92)
  crown:add(c:ellipse(x - r * 0.45, cy + r * 0.25, r * 0.7))
  crown:add(c:ellipse(x + r * 0.5, cy + r * 0.2, r * 0.65))
  c:part(crown, GV.ramp(col, { dot = "#ffc27a" }), { cres = 2 })
end
c:part(front, GV.ramp("#b0bc66"), { gloss = false, bounce = false })
-- leaf piles on the meadow
for _, x in ipairs({ 14.5, 33.5, 53, 72, 91, 110.5 }) do
  c:part(c:ellipse(x, 36, 2.5, 1), GV.ramp("#e0501f"), { flat = true, gloss = false, outline = false })
end
-- hem stitches
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })
local t = c:save(O .. "aseprite/ph/banner-na.aseprite", O .. "png/ph/banner-na.png")
print(GV.report(t))

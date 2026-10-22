local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

local tile = c:rrect(3, 3, 60, 60, 7)
local function band(f, y1)
  local m = c:mask()
  for x = 0, 63 do
    for y = math.floor(f(x) + 0.5), y1 do m:set(x, y) end
  end
  return m:clip(tile)
end

local water = c:rect(0, 37, 63, 63):clip(tile)
local bank = band(function(x) return 34 + 1.2 * math.sin(x / 3.5) + 0.6 * math.sin(x / 1.7) end, 38)

c:part(tile, GV.ramp("#a9d6ea"), { gloss = false, rim = false, bounce = false, cres = 0 })
c:part(water, GV.ramp("#3f93b2"), { outline = false, gloss = false, rim = false, contour = false })
c:part(bank, GV.ramp("#58a03e"), { outline = false, gloss = false, contour = false })
-- soft clouds in the sky
c:fill(c:rrect(26, 10, 37, 12, 1), "#c8ecdc")
c:fill(c:rrect(29, 8, 34, 10, 1), "#c8ecdc")

-- ripples
for _, r in ipairs({ { 11, 28, 47 }, { 40, 49, 54 }, { 22, 30, 56 } }) do
  for x = r[1], r[2] do
    local y = r[3] + (((x // 3) % 2 == 0) and 0 or -1)
    c:px(x, y, "#a9d6ea"); c:px(x + 1, y, "#a9d6ea")
  end
end

-- cattails: stems then heads (staggered heights)
local stemR = GV.ramp("#c4925f")
local headR = GV.ramp("#8c4a1a")
local cats = { { 13, 22 }, { 20, 17 }, { 45, 19 }, { 51, 24 } }
for _, k in ipairs(cats) do
  local st = c:rect(k[1], k[2] + 5, k[1] + 1, 44)
  c:part(st, stemR, { flat = true, outline = false, contour = false })
  c:px(k[1] + 1, k[2] + 6, stemR.shade)
  for y = k[2] + 6, 44 do c:px(k[1] + 1, y, stemR.shade) end
end
for _, k in ipairs(cats) do
  c:fill(c:rect(k[1], k[2] - 7, k[1] + 1, k[2] - 4), "#8a4f2a") -- spike tip
  local hd = c:rrect(k[1] - 1, k[2] - 4, k[1] + 2, k[2] + 5, 2)
  c:part(hd, headR, { gloss = { k[1] - 1, k[2] - 2 }, contour = false })
end
-- lily pad with a notch, then bloom
local pad = c:ellipse(33.5, 48, 7, 3):cut(c:poly({ { 33, 48 }, { 37, 44 }, { 39, 44 } }))
c:part(pad, GV.ramp("#58a03e"), { gloss = false, contour = false })
local bloom = c:ellipse(35, 46, 2, 1.5)
c:part(bloom, GV.ramp("#e46a9b"), { flat = true, contour = false })
c:px(35, 44, "#e46a9b"); c:px(34, 45, "#f6b8cf"); c:px(35, 46, "#e8a317")

local t = c:save(O .. "aseprite/ph/land-wetland.aseprite", O .. "png/ph/land-wetland.png")
print(GV.report(t))

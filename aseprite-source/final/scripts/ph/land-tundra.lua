local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

local T = c:rrect(3, 3, 61, 61, 7)
-- pale icy sky, paler toward the horizon
c:bands(T:copy():clip(c:rect(0, 0, 63, 42)), { "#8fc4e0", "#a9d6ea", "#c4e4f0" }, { dir = "v" })

-- wavy snowfield
local snow = c:mask()
for x = 3, 61 do
  local top = math.floor(39 + 2 * math.sin((x - 3) / 9) - (x > 40 and (x - 40) / 6 or 0) + 0.5)
  for y = top, 61 do snow:set(x, y) end
end
snow:clip(T)
c:part(snow, GV.ramp("#f4f0e0"), { outline = false, gloss = false, rim = false, cres = 3 })
-- ice shadow ripples
for x = 4, 60 do
  local y = math.floor(51 + 1.5 * math.sin(x / 5) + 0.5)
  if T:has(x, y) then c:px(x, y, "#a9d6ea") end
  if x % 3 ~= 0 and T:has(x, y + 1) then c:px(x, y + 1, "#c4e4f0") end
end

-- rock mounds (behind trunks' base)
c:part(c:ellipse(18, 43, 8, 3):cut(c:rect(0, 45, 63, 63)), GV.ramp("#6a6070"), { gloss = false, cres = 2 })
c:part(c:ellipse(35, 46, 7, 2.5):cut(c:rect(0, 48, 63, 63)), GV.ramp("#6a6070"), { gloss = false, cres = 2 })

-- trunks
c:part(c:rect(17, 35, 19, 41), GV.ramp("#b6814d"), { flat = true })
c:part(c:rect(34, 39, 36, 44), GV.ramp("#b6814d"), { flat = true })

-- big pine: three stacked tiers
local pine = GV.ramp("#2e5a2c")
local big = c:poly({ { 18, 11 }, { 12, 21 }, { 25, 21 } })
big:add(c:poly({ { 18, 16 }, { 10, 28 }, { 27, 28 } }))
big:add(c:poly({ { 18, 22 }, { 8, 36 }, { 29, 36 } }))
c:part(big, pine, { gloss = false, cres = 3 })
-- small pine, lower and shorter
local sm = c:poly({ { 35, 23 }, { 30, 31 }, { 41, 31 } })
sm:add(c:poly({ { 35, 28 }, { 28, 40 }, { 43, 40 } }))
c:part(sm, pine, { gloss = false, cres = 3 })

-- snow caps and ledges
local W = "#f4f0e0"
c:fill(big:copy():clip(c:rect(0, 0, 63, 16)), W)
c:paint({ "ww....ww", ".w....w." }, 14, 17, { w = W })
c:paint({ "ww......ww", ".w......w." }, 13, 23, { w = W })
c:paint({ "ww.......ww", "w.........w" }, 12, 29, { w = W })
c:fill(sm:copy():clip(c:rect(0, 0, 63, 26)), W)
c:paint({ "ww...ww", ".w...w." }, 32, 29, { w = W })

-- small blue tent at lower right
local tent = c:poly({ { 48, 43 }, { 41, 55 }, { 56, 55 } })
c:part(tent, "water", { gloss = false, cres = 3 })
c:fill(c:poly({ { 48, 47 }, { 46, 55 }, { 51, 55 } }), "#2a3c6c")
c:px(48, 43, W); c:px(47, 44, W); c:px(49, 44, W)

-- snowflakes
for _, p in ipairs({ { 10, 12 }, { 50, 12 }, { 42, 19 }, { 54, 26 }, { 28, 8 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), W)
end

-- hem stitch along the bottom
c:seam({ { 10, 58 }, { 54, 58 } }, { free = true })
-- tile edge outline (inside the tile)
c:outline(T:shrink(2))

local t = c:save(O .. "aseprite/ph/land-tundra.aseprite", O .. "png/ph/land-tundra.png")
print(GV.report(t))

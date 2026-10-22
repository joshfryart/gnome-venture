-- extras/icon-32: hand-drawn 32x32 version of the app icon (not a downscale).
-- Green felt badge with a light ring, red gnome hat with gold seam, cream beard, salmon nose.
-- Transparent corners like the original icon-32.png. Writes png/icon-32.png and aseprite/icon-32.aseprite.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local c = GV.canvas{ w = 32, h = 32, mode = "scene", ol = 1, olx = 1, cres = 2, deep = 1 }

local disc = c:ellipse(15.5, 15.5, 14.5)
c:part(disc, "leaf", { gloss = false })
local ring = c:ellipse(15.5, 15.5, 12.5):cut(c:ellipse(15.5, 15.5, 11.5))
c:part(ring, "moss", { outline = false, contour = false, contact = false, gloss = false, bounce = false,
                       light = c:ellipse(15.5, 15.5, 12.5), cres = 2, deep = 0 })

local hat   = c:poly({ {15, 4}, {17, 4}, {25, 20}, {7, 20} })
local beard = c:rrect(6, 19, 25, 22, 1):add(c:ellipse(15.5, 21, 7, 4.5):cut(c:rect(0, 0, 31, 21)))
local nose  = c:ellipse(15.5, 20.5, 2.5)
c:outline(hat:copy():add(beard):add(nose))
c:part(beard, "cream", { outline = false, gloss = false, cres = 1, deep = 0 })
c:part(hat,   "red",   { outline = false, gloss = false, cres = 3, deep = 1 })
c:part(nose,  GV.ramp("#e9a08c"), { outline = false, gloss = false, flat = true, contact = false })
-- hand-placed accents
c:px(14, 19, GV.ramp("#e9a08c").gloss)         -- nose glint
c:px(14, 9, GV.R.red.gloss); c:px(13, 11, GV.R.red.gloss) -- enamel comma on the lit hat side
c:seam({ {15, 10}, {15, 17} })
c:px(15, 7, GV.C.gold); c:px(16, 7, GV.C.goldS) -- 2 px button at the seam head
c:px(8, 20, GV.R.cream.gloss)                  -- beard gloss

local t = c:save(O .. "aseprite/icon-32.aseprite", O .. "png/icon-32.png")
print(GV.report(t))
-- ascii dump for checking by eye
local img = Image{ fromFile = O .. "png/icon-32.png" }
local map, n, L = {}, 0, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
for y = 0, 31 do
  local row = ""
  for x = 0, 31 do
    local v = img:getPixel(x, y)
    if app.pixelColor.rgbaA(v) == 0 then row = row .. "." else
      local key = string.format("%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v))
      if not map[key] then n = n + 1; map[key] = L:sub(n, n) end
      row = row .. map[key]
    end
  end
  print(row)
end
for k, v in pairs(map) do io.write(v, "=", k, " ") end print()

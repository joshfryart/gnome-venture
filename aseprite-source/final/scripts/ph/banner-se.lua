local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2, ol = 1, olx = 1 }

-- sky: hard bands, lighter toward the horizon
c:bands(c:rect(0, 0, 119, 18), { "#8fc4e0", "#a9d6ea", "#c4e4f0" }, { dir = "v" })
-- sun low at the far left
c:part(c:ellipse(24, 9, 4, 4), "gold", { outline = false, flat = true })
c:fill(c:rect(22, 7, 23, 7), "#fff1c8"); c:px(22, 8, "#fff1c8")
-- sea
c:bands(c:rect(0, 20, 119, 39), { "#3f8fb0", "#3f8fb0", "#2f6290" }, { dir = "v" })
c:fill(c:rect(0, 19, 119, 19), "#c8ecdc")
-- sun glitter on the water under the sun
c:fill(c:rect(21, 22, 27, 22), "#f5cf6a"); c:fill(c:rect(22, 25, 26, 25), "#f5cf6a"); c:fill(c:rect(23, 28, 25, 28), "#e8a317")
-- scalloped wave dashes
for i = 0, 3 do
  local x = 2 + i * 7
  c:paint({ ".ww.", "w..w" }, x, 35, { w = "#f4f0e0" })
end
for _, p in ipairs({ { 8, 24 }, { 34, 27 }, { 14, 30 }, { 30, 33 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 3, p[2]), "#8fcbd8")
end

-- headland: diagonal sandy wedge rising to the right
local head = c:poly({ { 40, 41 }, { 60, 22 }, { 84, 16 }, { 121, 16 }, { 121, 41 } })
c:part(head, GV.ramp("#dcb06a"), { gloss = false })
-- olive-green grass line along the top edge
c:line({ { 60, 23 }, { 72, 20 }, { 84, 17 }, { 119, 17 } }, 1)
c:fill(c:line({ { 59, 23 }, { 72, 20 }, { 84, 17 }, { 119, 17 } }, 1), "#b0bc66")
-- cliff strata on the sea face
c:fill(c:line({ { 50, 34 }, { 56, 34 } }, 1), "#b8864a")
c:fill(c:line({ { 46, 38 }, { 54, 38 } }, 1), "#b8864a")

-- cottage
c:part(c:rect(89, 19, 97, 25), GV.ramp("#f4f0e0"), { gloss = false, cres = 2 })
c:part(c:poly({ { 87, 20 }, { 93, 14 }, { 100, 20 } }), GV.ramp("#d6322b"), { gloss = false })
c:fill(c:rect(92, 22, 93, 25), "#3f8fb0")
c:fill(c:rect(95, 21, 96, 22), "#3f8fb0")

-- four round grey-green olive trees on stub trunks
local olive = GV.ramp("#9aa67e", { gloss = "#c8d77a", rim = "#b0bc66" })
for _, t in ipairs({ { 68, 24 }, { 78, 28 }, { 105, 26 }, { 114, 32 } }) do
  local x, y = t[1], t[2]
  c:part(c:rect(x - 1, y + 2, x, y + 5), GV.ramp("#b6814d"), { flat = true })
  c:part(c:ellipse(x - 0.5, y - 0.5, 4, 3.5), olive, { gloss = false, cres = 2 })
  c:fill(c:rect(x - 3, y - 3, x - 2, y - 3), "#c8d77a")
end

-- stepped dark corner vignette
local V = "#12324a"
for _, r in ipairs({ { 0, 0, 3 }, { 0, 1, 1 }, { 0, 2, 0 } }) do
  c:fill(c:rect(0, r[2], r[3], r[2]), V)
  c:fill(c:rect(119 - r[3], r[2], 119, r[2]), V)
  c:fill(c:rect(0, 39 - r[2], r[3], 39 - r[2]), V)
  c:fill(c:rect(119 - r[3], 39 - r[2], 119, 39 - r[2]), V)
end

-- hem stitch top and bottom
c:seam({ { 4, 1 }, { 115, 1 } }, { free = true })
c:seam({ { 4, 38 }, { 115, 38 } }, { free = true })

local t = c:save(O .. "aseprite/ph/banner-se.aseprite", O .. "png/ph/banner-se.png")
print(GV.report(t))

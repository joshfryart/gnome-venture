local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- Echo Stone: a big smooth river stone (stone family, cool blue-grey) with a
-- glowing concentric echo-ring mark carved into its face.
local stone = GV.ramp("#8b8f96", { rim = "#c9c5bc", gloss = "#f1ece0" })
local body = c:ellipse(31.5, 35, 24, 17):add(c:ellipse(28, 30, 19, 14))
c:build{ { "stone", body, stone, { gloss = { 15, 24 } } } }
-- carved rings, centred right of the gloss
local cx, cy = 34, 36
local function ring(rx, ry, w)
  return c:ellipse(cx, cy, rx, ry):cut(c:ellipse(cx, cy, rx - w, ry - w))
end
local glow, glowL, glowS = "#8fcbd8", "#c8ecdc", "#3f8fb0"
for _, r in ipairs({ { 15, 10.5 }, { 9.5, 6.5 } }) do
  c:fill(ring(r[1] + 1, r[2] + 1, 1), "#5b6470")       -- cut groove edge
  ring(r[1], r[2], 2):each(function(x, y)
    local s = (x - cx) + (y - cy)
    if s < -6 then c:px(x, y, glowL) elseif s < 7 then c:px(x, y, glow) else c:px(x, y, glowS) end
  end)
end
-- glowing core
c:fill(c:ellipse(cx, cy, 3, 2.5), glow)
c:fill(c:rect(cx - 1, cy - 1, cx, cy), glowL)
c:px(cx + 2, cy + 2, glowS)
local t = c:save(D .. "final/aseprite/ph/echo-stone.aseprite", PNG .. "echo-stone.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

-- ph/pickled-mushrooms (Pantry pickle): squat jar under a wide speckled mushroom-cap wooden lid with a gill band, golden chanterelle funnels inside
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-mushrooms"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(16, 28, 48, 56, 8), "glass" },
  { "brine", c:rrect(18, 33, 46, 54, 6), "#f5e0a0", { contour = "#c8a83a", gloss = false } },
}
-- chanterelles: trumpet caps on tapered stems, ridge lines
local ch = GV.ramp("#e8a317", { shade = "#b07a10" })
local function funnel(x, y)
  c:part(c:poly({ {x - 2, y}, {x + 2, y}, {x + 1, y + 7}, {x - 1, y + 7} }), ch, { flat = true, contour = "#7a3a14" })
  c:fill(c:rect(x, y + 1, x, y + 6), "#f5cf6a")
  local cap = c:ellipse(x, y - 1, 5, 2.5):add(c:poly({ {x - 5, y - 1}, {x + 6, y - 1}, {x + 2, y + 2}, {x - 2, y + 2} }))
  c:part(cap, ch, { cres = 1, deep = 0, gloss = false, contact = false, contour = "#7a3a14" })
  c:fill(c:rect(x - 3, y - 2, x + 2, y - 2), "#f5cf6a")
  c:px(x - 2, y + 1, "#f5cf6a"); c:px(x, y + 1, "#f5cf6a"); c:px(x + 2, y, "#b07a10")
end
funnel(23, 41); funnel(32, 37); funnel(42, 42)
-- oval label with a chanterelle emblem
c:part(c:ellipse(32, 50, 7, 4.5), "cream", { gloss = false, contact = false })
c:paint({
  ".ooooo.",
  "oOoooos",
  ".ooooo.",
  "..sys..",
  "...y...",
  "...y...",
}, 29, 47, { o = "#e8a317", O = "#f5cf6a", s = "#b07a10", y = "#f5cf6a" })
-- stem knob under the cap, then the mushroom-cap lid overhanging the shoulders
c:part(c:rrect(28, 26, 36, 32, 1), "#c9a96e", { flat = true, contour = "#7a4a1f" })
c:part(c:rect(12, 27, 52, 29), "#c9a96e", { cres = 1, deep = 0, gloss = false, contact = false, contour = "#7a4a1f" })   -- gill band
for x = 13, 51, 2 do c:px(x, 28, "#9a6b3f") end
local cap = c:ellipse(32, 27, 23, 15):cut(c:rect(0, 27, 63, 63))
c:part(cap, GV.ramp("#9a6b3f", { shade = "#7a4a1f" }), { contour = "#5e2f1e", gloss = { 19, 17 } })
for _, q in ipairs({ {25, 15}, {37, 17}, {44, 22}, {30, 21}, {19, 23} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#f1ece0"); c:px(q[1] + 1, q[2] + 1, "#c9c5bc")
end
c:seam({ {14, 26}, {50, 26} })
c:gloss(c:rrect(16, 28, 48, 56, 8), "glass", { 19, 36 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")

-- ph/rooibos-concentrate (Pantry cordial): tall square-cornered box bottle, T-shaped wooden stopper, red-brown rooibos concentrate, needle-sprig label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "rooibos-concentrate"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass",  c:rrect(17, 18, 45, 56, 3):add(c:rect(26, 14, 36, 19)), "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(19, 23, 43, 54, 2), GV.ramp("#a8441f", { shade = "#7a3014" }), { contour = "#7a3014", gloss = { 21, 26 } } },
  { "label",  c:rect(21, 32, 41, 50), "cream", { gloss = false, contact = false } },
}
-- T-stopper: wooden stem and a wide bar knob
c:part(c:rect(28, 10, 34, 16), "#c9a96e", { gloss = false })
c:part(c:rrect(22, 6, 40, 11, 2), "soil", { gloss = { 25, 7 } })
c:fill(c:rect(26, 9, 36, 9), "#7a4a1f")
c:seam({ {27, 16}, {35, 16} }, { free = true })
-- needle sprig
c:fill(c:rect(31, 37, 31, 48), "#4f9a45")
for i = 0, 5 do local y = 38 + i * 2; local s = (i % 2 == 0) and -1 or 1
  c:px(31 + s, y, "#4f9a45"); c:px(31 + 2 * s, y - 1, "#4f9a45"); c:px(31 - s, y + 1, "#4f9a45"); c:px(31 - 2 * s, y, "#4f9a45")
end
c:fill(c:rect(30, 35, 32, 36), "#a4b86a")
c:ground(31, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

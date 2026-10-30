-- ph/peach-jam (Pantry jam): short round pot under a pink scalloped paper cap with fold lines, tied with red string
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "peach-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cap = c:ellipse(32, 25, 18, 10):clip(c:rect(0, 0, 63, 25)):add(c:rect(14, 25, 50, 30))
for _, x in ipairs({ 16, 22, 29, 35, 42, 48 }) do cap:add(c:ellipse(x, 31, 3, 2)) end
local p = c:build{
  { "glass", c:rrect(15, 27, 49, 54, 9), "glass" },
  { "jam",   c:rrect(17, 31, 47, 52, 7), "#f2a05a", { contour = "#a8582f", gloss = { 20, 36 } } },
  { "label", c:rrect(22, 38, 42, 48, 2), "cream", { gloss = false, contact = false } },
  { "cap",   cap, "#f6b8cf", { gloss = false } },
}
for _, s in ipairs({ {19, 45}, {24, 50}, {38, 51}, {44, 44}, {45, 36} }) do c:px(s[1], s[2], "#f5cf6a") end
-- radial fold lines from the crown to the hem
for _, f in ipairs({ { 20, 30 }, { 26, 30 }, { 38, 30 }, { 44, 30 } }) do
  local x0, y0, x1, y1 = 32, 16, f[1], f[2]
  for i = 2, 14 do
    local x, y = math.floor(x0 + (x1 - x0) * i / 14 + 0.5), math.floor(y0 + (y1 - y0) * i / 14 + 0.5)
    local cur = c:get(x, y)
    if cur and cur ~= "#2a1a10" then c:px(x, y, "#e46a9b") end
  end
end
c:px(31, 16, "#fff3c8"); c:px(30, 17, "#fff3c8"); c:px(29, 18, "#fff3c8")   -- paper sheen
-- red string round the neck with two tails on the right
c:fill(c:rect(15, 28, 49, 28), "#d6322b")
c:paint({ "rr", "r.r", "r..r", "r...r", ".r..r", ".r...", "..r.." }, 44, 28, { r = "#ae2a2a" })
-- label: blushing peach with a red-tinted cleft and one leaf
c:paint({
  ".....gg..",
  "....gg...",
  "..oocbb..",
  ".oOocbbb.",
  ".ooocbbbs",
  ".oooobbbs",
  "..oooobs.",
  "...ssss..",
}, 28, 39, { o = "#f2a05a", O = "#ffd38a", b = "#e46a6a", c = "#d6322b", s = "#c8561c", g = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

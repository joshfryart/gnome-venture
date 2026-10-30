-- ph/cranberry-sauce (Pantry jam): open tin can, ruby jelly dome standing above the rim with can ridges printed on it, curled lid behind
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "cranberry-sauce"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local lid = c:ellipse(49, 19, 5, 8)
c:build{
  { "lid",   lid, "#c9c5bc", { gloss = false } },
  { "can",   c:rrect(15, 27, 49, 54, 2), "stone", { gloss = false } },
  { "rim",   c:rrect(14, 24, 50, 29, 2), "#c9c5bc", { gloss = false } },
  { "jelly", c:rrect(19, 9, 45, 26, 8), "#d6322b", { gloss = { 23, 12 } } },
  { "label", c:rect(15, 34, 49, 46), "cream", { gloss = false, contact = false } },
}
c:fill(c:ellipse(49, 19, 2, 5), "#8b8f96"); c:fill(c:ellipse(49, 18, 1, 3), "#c9c5bc")   -- curl of the peeled lid
-- ridge rings printed on the jelly and on the can
for _, y in ipairs({ 15, 20 }) do
  for x = 19, 45 do
    local cur = c:get(x, y)
    if cur and cur ~= "#2a1a10" and cur ~= "#4a2c1a" and cur ~= "#74462a" then c:px(x, y, "#a8241f"); if x > 20 and x < 44 then c:px(x, y + 1, "#f2793a") end end
  end
end
for _, y in ipairs({ 31, 50 }) do
  c:fill(c:rect(16, y, 48, y), "#5b6470"); c:fill(c:rect(16, y + 1, 48, y + 1), "#c9c5bc")
end
c:fill(c:rect(16, 27, 48, 27), "#5b6470")              -- shadow under the rolled rim
-- label: two cranberries with a leaf, and print dashes
c:paint({
  "....ll...",
  "...lLll..",
  "..l.ll...",
  ".rrr.rrr.",
  "rprrrprrr",
  "rrrsrrrrs",
  ".rss.rss.",
}, 20, 36, { r = "#d6322b", p = "#ff9158", s = "#a8241f", l = "#4f9a45", L = "#7ab55c" })
c:paint({ "uuuuuu", "", "uuuu.uu", "", "uuuuu" }, 34, 37, { u = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

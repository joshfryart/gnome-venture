-- ph/gooseberry-jam (Pantry jam): hexagonal faceted jar (lit, mid and shaded facet bands), green enamel hex lid with a knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "gooseberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:poly({ {22, 19}, {43, 19}, {47, 23}, {47, 52}, {44, 56}, {21, 56}, {18, 52}, {18, 23} })
local fill  = c:poly({ {23, 23}, {42, 23}, {45, 26}, {45, 51}, {43, 54}, {22, 54}, {20, 51}, {20, 26} })
local lid   = c:poly({ {21, 11}, {44, 11}, {49, 16}, {49, 23}, {16, 23}, {16, 16} })
local p = c:build{
  { "glass", glass, "glass" },
  { "jam",   fill, "#a4b86a", { contour = "#5f7a34", gloss = false } },
  { "label", c:rect(25, 34, 40, 46), "cream", { gloss = false, contact = false } },
  { "lid",   lid, "#4f9a45", { gloss = { 20, 14 } } },
  { "knob",  c:rrect(29, 6, 35, 11, 2), "#4f9a45", { gloss = false } },
}
-- facets: left band lit, right band shaded, 1 px facet edges at x 24 and x 40 (lid too)
local J = p.jam.r
fill:each(function(x, y)
  local cur = c:get(x, y)
  if x < 24 and (cur == J.base) then c:px(x, y, "#c8d77a") end
  if x > 40 and (cur == J.base or cur == J.rim) then c:px(x, y, J.shade) end
end)
for _, y0 in ipairs({ { 24, 53, "#e6eea0" }, { 40, 53, "#5f7a34" } }) do
  local x = y0[1]
  for y = 24, y0[2] do
    if fill:has(x, y) and not (y >= 34 and y <= 46) then c:px(x, y, y0[3]) end
  end
  c:px(x, 20, x == 24 and "#eef8f2" or "#6f98c4"); c:px(x, 21, x == 24 and "#eef8f2" or "#6f98c4")
  for y = 13, 21 do c:px(x, y, x == 24 and "#a4b86a" or "#2f6a3a") end
end
c:fill(c:rect(17, 22, 48, 22), "#2f5a2a")             -- enamel rim
c:seam({ {18, 21}, {47, 21} })
for _, s in ipairs({ {22, 29}, {27, 27}, {33, 30}, {38, 26}, {43, 30}, {21, 49}, {28, 50}, {35, 49}, {42, 48} }) do
  c:px(s[1], s[2], "#7ab55c"); c:px(s[1] + 1, s[2], "#e6eea0")   -- seeds
end
-- label: veined gooseberry with a whisker tip
c:paint({
  "....k...",
  "...k....",
  ".aaaaaa.",
  "aLagagaa",
  "aagagaga",
  "aagagaga",
  "aaagagas",
  ".aassss.",
  "...kk...",
}, 29, 35, { a = "#a4b86a", L = "#e6eea0", g = "#4f9a45", s = "#7ab55c", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

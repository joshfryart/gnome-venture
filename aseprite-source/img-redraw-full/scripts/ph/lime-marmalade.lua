-- ph/lime-marmalade (Pantry marmalade): tall diamond-cut glass jar (lattice facets) of green jelly with gold strands, ribbed green cap
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "lime-marmalade"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:rrect(17, 18, 47, 54, 5)
local fill = c:rrect(19, 23, 45, 52, 4)
c:build{
  { "glass", glass, "glass" },
  { "jelly", fill, "#a4c86a", { contour = "#5f7a34", gloss = false } },
  { "label", c:rect(22, 34, 42, 46), "cream", { gloss = false, contact = false } },
  { "cap",   c:rrect(16, 9, 48, 20, 3), "#4f9a45", { gloss = { 19, 12 } } },
}
-- gold strands in the jelly
for _, s in ipairs({ {21, 26}, {28, 28}, {36, 26}, {41, 30}, {22, 49}, {30, 50}, {38, 48} }) do
  c:px(s[1], s[2], "#e8c840"); c:px(s[1] + 1, s[2] + 1, "#e8c840"); c:px(s[1] + 2, s[2] + 1, "#e8c840")
end
-- cut-glass diamond lattice across glass and jelly (not on the label)
glass:each(function(x, y)
  if y > 20 and (x >= 22 and x <= 42 and y >= 34 and y <= 46) == false then
    local cur = c:get(x, y)
    if cur and cur ~= "#2a1a10" and cur ~= "#4a2c1a" and ((x + y) % 6 == 0 or (x - y) % 6 == 0) then
      c:px(x, y, fill:has(x, y) and "#c8e08a" or "#c9e6f2")
    end
  end
end)
for x = 19, 46, 3 do c:fill(c:rect(x, 12, x, 18), "#2f5a2a") end   -- cap ribs
c:fill(c:rect(18, 10, 46, 10), "#a4b86a")
c:seam({ {17, 19}, {47, 19} })
-- label: lime wedge, rind semicircle with pale pith spokes
c:paint({
  "ggggggggggg",
  "gpppppppppg",
  ".gLpLpLpLg.",
  ".gLLpLpLLg.",
  "..gLLpLLg..",
  "...gLLLg...",
  "....ggg....",
}, 27, 37, { g = "#4f9a45", p = "#f1ece0", L = "#a4c86a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

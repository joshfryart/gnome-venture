-- ph/blackcurrant-jam (Pantry jam): tallest, narrowest jar, near-black fill with a magenta edge glow, ribbed pewter lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "blackcurrant-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(22, 14, 42, 54, 5), "glass" },
  { "jam",   c:rrect(24, 19, 40, 52, 4), "#2a1230", { contour = "#1e1438", gloss = false } },
  { "label", c:rrect(25, 30, 39, 44, 1), "cream", { gloss = false, contact = false } },
  { "lid",   c:rrect(21, 7, 43, 16, 2), "stone", { gloss = false } },
}
c:fill(c:rect(24, 21, 24, 50), "#7a2a5a")            -- magenta edge glow (left)
c:fill(c:rect(25, 20, 25, 28), "#c9c5bc")            -- glass gloss column
c:fill(c:rect(25, 46, 25, 49), "#c9c5bc")
for x = 23, 41, 3 do                                   -- pewter ribs: dark groove with a lit ridge beside it
  c:fill(c:rect(x, 9, x, 14), "#5b6470"); c:fill(c:rect(x + 1, 9, x + 1, 14), "#c9c5bc")
end
c:fill(c:rect(23, 8, 41, 8), "#c9c5bc")                -- lit top edge of the lid
c:seam({ {22, 15}, {42, 15} })
-- label: blackcurrant strig, three berries on a stem with a leaf
c:paint({
  "......LLL..",
  "..gggggLL..",
  ".g...g...g.",
  "pbb.pbb.pbb",
  "bbb.bbb.bbb",
  ".b...b...b.",
}, 27, 32, { g = "#4f9a45", L = "#7ab55c", b = "#2a1230", p = "#7a2a5a" })
c:paint({ "uu.uuu.uu", "", ".uuu.uu.." }, 28, 40, { u = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

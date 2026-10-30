-- ph/pickled-carrots (Pantry pickle): very slim tall straight jar, slate ridged screw lid, carrot batons standing like a fence, dill on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-carrots"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(21, 15, 43, 56, 4), "glass" },
  { "brine", c:rrect(23, 20, 41, 54, 3), "#f8e8c0", { contour = "#c9b878", gloss = false } },
}
-- batons: five 3 px orange sticks, staggered tops, lit left column, shade right column
local tops = { 24, 21, 26, 22, 25 }
for i = 0, 4 do
  local x = 23 + i * 4
  local y = tops[i + 1]
  c:fill(c:rect(x, y, x + 2, 54), "#ef8a24")
  c:fill(c:rect(x + 2, y + 1, x + 2, 54), "#c8641a")
  c:fill(c:rect(x, y + 1, x, 53), "#ffb35a")
  c:fill(c:rect(x, y, x + 2, y), "#f5a04a")
  for yy = y + 5, 52, 6 do c:px(x + 1, yy, "#c8641a") end   -- carrot rings
end
-- dill sprig poking up between lid and brine
c:paint({
  "g...g",
  ".g.g.",
  "g.G.g",
  ".GGG.",
  "..G..",
}, 30, 16, { g = "#7ab55c", G = "#4f9a45" })
-- label with a carrot emblem
c:part(c:rect(24, 34, 40, 45), "cream", { gloss = false, contact = false })
c:fill(c:rect(23, 35, 23, 44), "#ef8a24")                -- baton breaks the label edge
c:paint({
  ".g.g.",
  "..G..",
  ".ooo.",
  ".oOo.",
  ".ooo.",
  "..oo.",
  "..o..",
  "..s..",
}, 25, 35, { g = "#7ab55c", G = "#4f9a45", o = "#ef8a24", O = "#ffb35a", s = "#c8641a" })
c:paint({ "uuu.uu", "", "uu.uuu", "", "uuuu" }, 32, 37, { u = "#7a5a3a" })
-- slate screw lid with ridges
c:part(c:rrect(20, 8, 44, 16, 2), "#5b6470", { contour = "#3d4650", gloss = { 23, 10 } })
for _, x in ipairs({ 27, 32, 37 }) do c:fill(c:rect(x, 10, x, 14), "#3d4650"); c:px(x - 1, 10, "#8b8f96") end
c:seam({ {21, 15}, {43, 15} })
c:gloss(c:rrect(21, 15, 43, 56, 4), "glass", { 24, 23 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")

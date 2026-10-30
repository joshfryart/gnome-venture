-- ph/soft-cheese (Pantry dairy): muslin cheesecloth bag hanging from a string loop, herby cheese bulging, a whey drop falling
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "soft-cheese"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f4f0e0", { shade = "#e0d4b0", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
-- string loop it hangs from
c:part(c:line({ {32, 15}, {27, 9}, {29, 6}, {35, 6}, {37, 9}, {32, 15} }, 2), "soil", { flat = true, contact = false })
-- teardrop bag: gathered neck, round heavy bottom
local bag = c:ellipse(32, 38, 17, 13):add(c:poly({ {28, 15}, {37, 15}, {44, 28}, {20, 28} }))
c:part(bag, cloth, { gloss = { 22, 31 }, stitch = { side = "lit" } })
bag:each(function(x, y) if (x * 3 + y) % 7 == 0 and c:get(x, y) == "#f4f0e0" then c:px(x, y, "#e6dcc0") end end)   -- weave
c:part(c:rrect(26, 13, 38, 18, 2), cloth, { gloss = false, cres = 2, deep = 0 })   -- gathered top
c:paint({ ".k.k.k.k.", "k.k.k.k.k" }, 28, 14, { k = "#c9b878" })
c:part(c:rect(27, 18, 37, 19), "soil", { flat = true, contact = false })            -- tie
for _, p in ipairs({ {22, 40}, {41, 33}, {38, 46}, {26, 48}, {44, 41} }) do   -- dill flecks
  c:paint({ "g.", ".g" }, p[1], p[2], { g = "#4f9a45" })
end
-- emblem: milk drop with a dill leaf
c:paint({
  "....w....",
  "...wBw...",
  "..wBBBw..",
  ".wBWBBBw.",
  ".wBBBBBw.",
  ".wBBBBbw.",
  "..wBbbw..",
  "...www.gg",
  ".......g.",
}, 28, 33, { w = "#5a86b8", B = "#a9d6ea", b = "#8fb4d6", W = "#eef8f2", g = "#4f9a45" })
-- whey drop falling under the bag
c:part(c:poly({ {32, 52}, {34, 55}, {33, 57}, {31, 57}, {30, 55} }), "glass", { flat = true, contact = false })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

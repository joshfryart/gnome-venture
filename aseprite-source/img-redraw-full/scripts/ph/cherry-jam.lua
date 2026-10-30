-- ph/cherry-jam (Pantry jam): round-bellied swing-top jar, cream ceramic stopper, orange rubber ring and a wire bail arch
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "cherry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wire = c:line({ {19, 31}, {16, 23}, {18, 15}, {23, 10}, {29, 8}, {31, 10}, {33, 10}, {35, 8}, {41, 10}, {46, 15}, {48, 23}, {45, 31} }, 2)
c:build{
  { "glass",   c:ellipse(32, 41, 20, 13):add(c:rect(24, 22, 40, 28)), "glass" },
  { "jam",     c:ellipse(32, 42, 18, 10), "#a8241f", { contour = "#6b1b2c", gloss = { 18, 38 } } },
  { "label",   c:rect(24, 36, 40, 46), "cream", { gloss = false, contact = false } },
  { "ring",    c:rect(23, 21, 41, 23), "#f08a24", { gloss = false } },
  { "stopper", c:rrect(22, 13, 42, 21, 3), "cream", { gloss = false } },
  { "wire",    wire, "stone", { flat = true, contact = false } },
}
c:px(26, 15, "#f8fcf4"); c:px(27, 15, "#fff3c8"); c:px(26, 16, "#fff3c8")   -- stopper glaze glint (one white px)
for _, p in ipairs({ {17, 44}, {45, 39}, {30, 49}, {42, 48} }) do        -- cherry pits in the jam
  c:paint({ "kk", "kp" }, p[1], p[2], { k = "umber", p = "#6b1b2c" })
end
-- label: twin cherries on joined stems with a leaf
c:paint({
  "......LL.",
  ".....gL..",
  "....g.g..",
  "...g...g.",
  "..g....g.",
  "rrr...rrr",
  "rpr..rprr",
  "rrs...rrs",
  ".s.....s.",
}, 28, 37, { r = "#d6322b", p = "#ff9158", s = "#a8241f", g = "#4f9a45", L = "#7ab55c" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

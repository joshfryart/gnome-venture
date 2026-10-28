-- Old Wizard v2 (Puzzles helper): ember puzzle-piece body, floppy purple hat drooping to the right with a star,
-- gold half-moon spectacles under bushy grey brows, long forked cream beard, right arm raised casting a sparkle.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/wizard/"

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dy = 4
local function R(x0, y0, x1, y1, r) return c:rrect(x0, y0 + dy, x1, y1 + dy, r or 0) end
local body = R(17, 26, 46, 49, 3)
body:add(R(26, 14, 37, 28, 2)); body:add(c:ellipse(31.5, 15 + dy, 7, 5.5))
body:cut(c:rect(27, 44 + dy, 36, 50 + dy))                                   -- notch
-- left arm out, right arm raised (bent up at the elbow)
local arms = R(11, 33, 32, 39, 2); arms:add(c:ellipse(12, 36 + dy, 3, 4))
arms:add(c:rrect(44, 30 + dy, 54, 36 + dy, 2)); arms:add(c:rrect(49, 18 + dy, 54, 36 + dy, 2))
arms:add(c:ellipse(51.5, 18 + dy, 3, 3))
arms:cut(R(18, 28, 45, 45))

local hat = c:poly({ { 23, 23 }, { 27, 11 }, { 34, 8 }, { 44, 6 }, { 47, 11 }, { 40, 12 }, { 42, 23 } })  -- drooping cone
hat:add(c:rrect(19, 21, 44, 24, 1))                                                           -- brim
local beard = c:ellipse(31.5, 45, 11, 9):clip(c:rect(0, 41, 63, 54))
beard:add(c:rrect(23, 39, 40, 43, 2))                                                         -- moustache
beard:cut(c:rect(28, 50, 35, 54))                                                             -- fork over the notch
beard:add(c:rrect(21, 48, 27, 54, 2)); beard:add(c:rrect(36, 48, 42, 54, 2))                   -- two prongs

c:build{
  { "arms",  arms,  GV.ramp("#f08a24"), { flat = true } },
  { "body",  body,  GV.ramp("#e0501f"), { stitch = { side = "lit" } } },
  { "beard", beard, GV.ramp("#f4ecd8", { pale = true }), { gloss = { 25, 42 } } },
  { "hat",   hat,   GV.ramp("#5a3f9e"), { gloss = { 28, 13 } } },
}
-- sparkle above the raised hand (gold, with a pale centre)
c:paint({ "...s...", "...s...", "..sss..", "sssssss", "..sss..", "...s...", "...s..." }, 49, 10, { s = "#f5cf6a" })
c:px(52, 13, "#fff1c8")
c:px(47, 9, "#f5cf6a"); c:px(57, 9, "#f5cf6a"); c:px(47, 18, "#f5cf6a"); c:px(57, 18, "#f5cf6a")
-- star on the hat, hat band seam
c:paint({ ".s.", "sss", ".s." }, 33, 14, { s = "#f5cf6a" })
c:seam({ { 22, 22 }, { 41, 22 } })
-- bushy grey brows
c:paint({ "gggg..", "ggGGGG" }, 20, 31, { g = "#c4c4c4", G = "#9a9a9a" })
c:paint({ "..gggg", "GGGGgg" }, 34, 31, { g = "#c4c4c4", G = "#9a9a9a" })
-- half-moon spectacles: gold rim under each eye, bridge between
c:eye(21, 33); c:eye(35, 33)
c:paint({ "o.....o", ".ooooo." }, 20, 37, { o = "#e8a317" })
c:paint({ "o.....o", ".ooooo." }, 34, 37, { o = "#e8a317" })
c:paint({ "ooo" }, 27, 36, { o = "#e8a317" })
-- kind smile on the moustache
c:paint({ "u.....u", ".uuuuu." }, 28, 41, { u = "umber" })

local t = c:save(OUT .. "wizard-v2.aseprite", OUT .. "wizard-v2.png")
print("wizard-v2", GV.report(t))
assert(t.semi == 0 and t.margin >= 3)

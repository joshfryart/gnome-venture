-- ph/artichoke-fava-stew (Gourmand P2 dish): terracotta cazuela of olive stew, two halved artichoke hearts, green favas, a lemon wedge on the rim
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "artichoke-fava-stew"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- wide shallow cazuela with straight flared sides
local dish = c:poly({ {8, 38}, {56, 38}, {51, 51}, {13, 51} }):add(c:ellipse(31.5, 38, 24, 8))
dish:add(c:ellipse(31.5, 50, 19, 2.5))
c:part(dish, "#a5663a", { cres = 3, gloss = false })
c:fill(c:ellipse(31.5, 38, 24, 8):edge():clip(c:rect(0, 29, 63, 38)), "#d08c58")
c:fill(c:rect(10, 43, 53, 43):clip(dish), "#7e4428")                         -- glaze line
c:seam({ {12, 46}, {51, 46} }, { gap = "#7e4428" })
-- stew surface
local stew = c:ellipse(31.5, 38, 21, 6)
c:part(stew, "#8a9a3a", { contour = "#5e2f1e", cres = 2, gloss = false, contact = false })
for _, p in ipairs({ {15, 38}, {22, 41}, {44, 41}, {48, 37}, {30, 42}, {37, 34} }) do c:px(p[1], p[2], "#6a7a2a") end
-- artichoke heart halves: pale cut face, green leaf tips, dark choke
local function heart(x, y)
  local h = c:ellipse(x, y, 5, 4):add(c:poly({ {x - 4, y - 2}, {x - 3, y - 7}, {x, y - 4}, {x + 3, y - 7}, {x + 5, y - 2} }))
  c:part(h, "#8aa04a", { cres = 2, gloss = false, contact = false, contour = "#3a4a1a" })
  local core = h:shrink(1)
  c:fill(core, "#dfe4a8")
  c:fill(core:copy():cut(core:shift(1, 1)), "#f0f0c8")
  c:fill(c:line({ {x - 2, y - 4}, {x, y - 1}, {x + 2, y - 4} }, 1), "#a8b860")   -- leaf layers
  c:fill(c:ellipse(x, y + 1, 2, 1.5), "#a86a8a")                                 -- choke
  c:px(x - 1, y + 1, "#c890a8")
end
heart(23, 36); heart(38, 35)
-- fava beans
for _, p in ipairs({ {15, 40}, {30, 40}, {45, 39}, {31, 33}, {18, 35}, {41, 41} }) do
  c:paint({ "lb.", "bbd" }, p[1], p[2], { l = "#b4e07a", b = "#7ab648", d = "#4a8a3e" })
end
-- lemon wedge standing on the right rim
local wedge = c:ellipse(49, 33, 7, 6):clip(c:rect(0, 0, 63, 33))
c:part(wedge, "#e8b020", { cres = 2, gloss = false, contact = false })
local fl = c:ellipse(49, 34, 5, 5):clip(c:rect(0, 0, 63, 33))
c:fill(fl, "#f8e070")
for _, l in ipairs({ { {49, 33}, {49, 30} }, { {49, 33}, {46, 31} }, { {49, 33}, {52, 31} } }) do c:fill(c:line(l, 1), "#f5c838") end
c:fill(c:rect(43, 33, 55, 33), "#f0d890")
c:ground(31.5, 55, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

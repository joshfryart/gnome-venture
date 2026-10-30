-- ph/pickled-okra (Pantry pickle): jar of pale brine with four standing ridged okra pods, brine bubbles, low label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "pickled-okra"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "glass", c:rrect(18, 22, 46, 55, 7):add(c:rect(20, 20, 44, 23)), "glass" },
  { "brine", c:rrect(20, 28, 44, 53, 5), "#d8ecc8", { contour = "#8fb4a0", gloss = false } },
}
-- okra pods: three slim tapered pods standing in brine, gaps between, stem cap up, tip down, ridge line
local pods = { {24, 29, 0}, {32, 27, 1}, {40, 30, -1} }
for _, q in ipairs(pods) do
  local x, y, lean = q[1], q[2], q[3]
  local m = c:poly({ {x - 2, y + 4}, {x + 4, y + 4}, {x + 3 + lean, y + 16}, {x + 1 + lean, y + 22}, {x + lean, y + 22}, {x - 1 + lean, y + 16} })
  c:part(m, "moss", { cres = 3, deep = 0, gloss = false, contact = false, contour = "#2f5a2a" })
  c:fill(c:line({ {x + 1, y + 6}, {x + 1 + lean, y + 18} }, 1), "#4a8a3e")   -- ridge
  c:fill(c:rrect(x - 2, y + 1, x + 3, y + 4, 1), "#2f5a2a")                       -- stem cap
  c:fill(c:rect(x, y - 2, x + 1, y), "#4a8a3e")                               -- stem
  c:px(x - 1, y + 6, "#c8d77a"); c:px(x - 1, y + 7, "#c8d77a")              -- lit edge glint
end
c:part(c:rrect(22, 44, 42, 50, 2), "cream", { gloss = false, contact = false })
c:paint({ "u.uuu.uu.uu" }, 27, 47, { u = "#7a5a3a" })
c:part(c:rrect(17, 12, 47, 21, 3), "gold")
c:seam({ {19, 20}, {45, 20} })
for _, b in ipairs({ {26, 33}, {38, 29}, {33, 41} }) do c:px(b[1], b[2], "#f6fbf0") end   -- brine bubbles
c:gloss(c:rrect(18, 22, 46, 55, 7), "glass", { 21, 30 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")

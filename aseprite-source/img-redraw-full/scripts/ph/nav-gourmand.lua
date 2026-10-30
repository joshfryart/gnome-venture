-- ph/nav-gourmand (menu icon): one silver spoon on the diagonal over a folded white napkin set as a diamond
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N, MARGIN = "nav-gourmand", 3
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local napkin = c:poly({ {32, 8}, {54, 30}, {32, 52}, {10, 30} }):add(c:ellipse(32, 51, 3, 2.5))
local np = c:part(napkin, GV.ramp("#f8f4ea", { shade = "#d8c49a", bounce = "#e6d4ac", deep = "#9a6b3f" }), { gloss = { 22, 26 } })
-- folded corner: the upper-right half sits a shade lower, with a crisp fold line
local fold = c:poly({ {32, 9}, {53, 30}, {32, 30} })
fold:each(function(x, y) if np.m:has(x, y) and c:get(x, y) ~= "#9a6b3f" then c:px(x, y, "#e4dec9") end end)
c:fill(c:line({ {33, 30}, {52, 30} }, 1), "#c9bfa8")
c:fill(c:line({ {32, 10}, {32, 29} }, 1), "#c9bfa8")
c:stitch(np.m, { side = "lit" })
-- spoon: 4 px handle, bowl tilted 45 degrees at the upper right
local silver = GV.ramp("#dfe5ea", { shade = "#a9b3bc", deep = "#7d8791", bounce = "#b9c2ca", rim = "#f4f7f9", gloss = "#f8fbfc", dot = "#fbfdfe", pale = false })
c:part(c:line({ {15, 50}, {37, 28} }, 4), GV.ramp("#c9d0d6", { shade = "#8d97a0", rim = "#e6ebef", pale = false }), { cres = 3, deep = 0, gloss = false })
local bowl = c:mask()
for y = 6, 40 do for x = 26, 60 do
  local u, v = ((x - 44) + (y - 22)) / 1.4142, ((x - 44) - (y - 22)) / 1.4142
  if (u / 7.5) ^ 2 + (v / 10.5) ^ 2 <= 1 then bowl:set(x, y) end
end end
c:part(bowl, silver, { gloss = false })
local dish = c:mask()
bowl:each(function(x, y)
  local u, v = ((x - 44.5) + (y - 22.5)) / 1.4142, ((x - 44.5) - (y - 22.5)) / 1.4142
  if (u / 4.5) ^ 2 + (v / 7.5) ^ 2 <= 1 then dish:set(x, y) end
end)
dish:each(function(x, y) c:px(x, y, ((x - 44.5) + (y - 22.5) < -2) and "#b9c2ca" or "#f4f7f9") end)
c:paint({ "..hh", ".hh.", "hh..", "h..." }, 39, 13, { h = "#fbfdfe" })   -- hard highlight comma
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= MARGIN and t.bw <= 4, N .. " failed checks")

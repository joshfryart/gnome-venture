-- ph/passion-fruit-curd (Pantry curd): short straight tumbler of gold curd peppered with black seeds, purple foil cap with crimp tucks
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "passion-fruit-curd"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local foil = c:rrect(16, 15, 48, 25, 4):add(c:rect(14, 22, 50, 30))
for _, x in ipairs({ 17, 23, 29, 35, 41, 47 }) do foil:add(c:rect(x, 31, x + 2, 31)) end   -- crimp hem teeth
c:build{
  { "glass", c:rrect(16, 27, 48, 54, 4), "glass" },
  { "curd",  c:rrect(18, 31, 46, 52, 3), "#f0c030", { contour = "#b8661a", gloss = false } },
  { "label", c:rect(23, 38, 41, 48), "cream", { gloss = false, contact = false } },
  { "foil",  foil, "#7a5cc0", { gloss = { 20, 17 } } },
}
for _, x in ipairs({ 20, 26, 32, 38, 44 }) do               -- crimp tucks
  for y = 21, 30 do if c:get(x, y) ~= "#2a1a10" then c:px(x, y, "#4e3a8a") end end
  c:px(x + 1, 22, "#a894dc"); c:px(x + 1, 26, "#a894dc")
end
c:fill(c:rect(17, 16, 47, 16), "#a894dc")
for _, s in ipairs({ {21, 34}, {26, 33}, {33, 35}, {39, 33}, {44, 36}, {22, 50}, {28, 51}, {35, 50}, {42, 50}, {44, 44}, {20, 42} }) do
  c:px(s[1], s[2], "#2a1a10"); c:px(s[1] + 1, s[2], "#b8661a")                  -- black seeds
end
c:fill(c:rect(19, 35, 19, 47), "#f5cf6a")                -- glass gloss column
-- label: halved passion fruit, purple rind, orange pulp with seeds
c:paint({
  "..vvvv..",
  ".vooooV.",
  "vookookv",
  "vkooooov",
  "voookoov",
  "vokoookv",
  ".vooooV.",
  "..vvvv..",
}, 28, 39, { v = "#7a5cc0", V = "#4e3a8a", o = "#f08a24", k = "umber" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

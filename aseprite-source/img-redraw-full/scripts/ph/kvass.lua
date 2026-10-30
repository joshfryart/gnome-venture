-- ph/kvass (Pantry ferment): round-bellied wooden keg with two iron hoops, brass tap dripping burgundy, rye ear branded on the front
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "kvass"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local iron = GV.ramp("#4a5260", { rim = "#8b8f96", gloss = "#c9c5bc", shade = "#2e3440", deep = "#20242e" })
-- barrel: bulging belly, flat top and bottom
local keg = c:ellipse(32, 33, 22, 26):clip(c:rect(0, 13, 63, 53))
c:part(keg, "soil", { gloss = { 16, 24 } })
for _, x in ipairs({ 18, 25, 32, 39, 46 }) do   -- stave joints, bowed with the belly
  local pts = {}
  for y = 15, 52 do pts[#pts + 1] = { math.floor(x + (x - 32) * 0.18 * math.sin(math.pi * (y - 13) / 40) + 0.5), y } end
  c:fill(c:line(pts, 1):clip(keg), "#7a4a1f")
end
c:part(c:ellipse(32, 14, 18, 4), "#c9a96e", { gloss = false, contact = false, cres = 2, deep = 0 })   -- top head
c:fill(c:ellipse(22, 14, 2, 1), "#3d2a1c")   -- bung
-- iron hoops follow the curve of the belly
local function hoop(y, bow)
  local m = c:mask()
  for x = 10, 54 do
    local yy = y + math.floor(bow * (1 - ((x - 32) / 22) ^ 2) + 0.5)
    m:add(c:rect(x, yy, x, yy + 2))
  end
  c:part(m:clip(keg), iron, { gloss = false, contact = false, cres = 1, deep = 0 })
end
hoop(19, 2); hoop(46, 2)
-- branded rye ear on a cream roundel
c:part(c:ellipse(32, 31, 7), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false, cres = 3, deep = 0 })
c:paint({
  "...g...",
  "..gkg..",
  ".g.k.g.",
  "..gkg..",
  ".g.k.g.",
  "..gkg..",
  "...k...",
  "...k...",
  "...k...",
}, 29, 26, { g = "#c9a030", k = "#8a5a2a" })
-- brass tap with a T handle, burgundy drip
c:part(c:rrect(28, 39, 35, 43, 1), "gold", { gloss = false, cres = 2, deep = 0 })
c:part(c:rect(34, 36, 36, 39), "gold", { flat = true, contact = false })
c:part(c:rect(30, 43, 33, 46), "gold", { flat = true, contact = false })
c:px(30, 40, "#fff1c8")
c:fill(c:rect(31, 47, 32, 48), "#8a2a3a"); c:fill(c:rect(31, 51, 32, 52), "#8a2a3a")
c:ground(32, 56, 17, 1.5)
c:part(c:ellipse(32, 55, 4, 0.5), "#8a2a3a", { flat = true, contact = false, rim = false })   -- puddle
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

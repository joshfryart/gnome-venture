-- ph/dried-apple-rings (Pantry dried): garland of five dried apple rings sagging on twine between two short pale stakes, apple tag hanging below
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "dried-apple-rings"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- short, pale pegs (not tall dark posts) so the ring garland carries the picture at 16 px
local post = GV.ramp("#d9bf8a", { rim = "#ecd8a8", shade = "#c9a96e", deep = "#b8925a", bounce = "#c9a96e", gloss = "#f1e4c4" })
c:part(c:rect(8, 19, 10, 36):add(c:poly({ {8, 36}, {11, 36}, {9.5, 40} })), post, { gloss = false, cres = 2, deep = 0, solid = false, contact = false })
c:part(c:rect(53, 19, 55, 36):add(c:poly({ {53, 36}, {56, 36}, {54.5, 40} })), post, { gloss = false, cres = 2, deep = 0, solid = false, contact = false })
c:fill(c:rect(10, 22, 10, 36), "#b8925a"); c:fill(c:rect(55, 22, 55, 36), "#b8925a")
c:part(c:rrect(7, 16, 11, 19, 1), "#9a6b3f", { flat = true, solid = false, contact = false })
c:part(c:rrect(52, 16, 56, 19, 1), "#9a6b3f", { flat = true, solid = false, contact = false })
-- sagging twine
local pts = {}
for x = 11, 52 do local u = (x - 31.5) / 20.5; pts[#pts + 1] = { x, math.floor(21 + 13 * (1 - u * u) + 0.5) } end
c:part(c:line(pts, 1), "#c9a96e", { flat = true, contact = false, rim = false })
c:fill(c:rect(10, 20, 12, 21), "#7a4a1f"); c:fill(c:rect(51, 20, 53, 21), "#7a4a1f")   -- knots
-- tag string + tag with a tiny apple
c:fill(c:line({ {32, 38}, {32, 42} }, 1), "#9a6b3f")
c:part(c:rrect(26, 42, 38, 53, 1), "cream", { gloss = false, contact = false })
c:paint({ "..kg.", ".rkr.", "rRrrr", "rrrrs", ".rrs." }, 30, 45, { r = "#d6322b", R = "#ff9158", s = "#ae2a2a", k = "#7a4a1f", g = "#4f9a45" })
-- rings threaded on the twine: hand-shaded annuli with a dark hole the twine runs through
for i, q in ipairs({ {15, 28}, {23.5, 32}, {32, 34}, {40.5, 32}, {49, 28} }) do
  local cx, cy = q[1], q[2]
  local hole = c:ellipse(cx, cy, 1.8)
  local m = c:ellipse(cx, cy, 4.6):cut(hole)
  c:part(m, "#e8c080", { flat = true, rim = false, contour = false, contact = false })
  m:each(function(x, y)
    local s = (x - cx) + (y - cy)
    if s > 3 then c:px(x, y, "#c89040") elseif s < -4 then c:px(x, y, "#f8e6b8") end
  end)
  c:fill(m:edge():cut(hole:grow(1)), (i == 2 or i == 4) and "#d6322b" or "#a8702a")
  c:fill(hole, "#3d2a1c")
  local hy = math.floor(cy + 0.5)
  c:fill(c:rect(math.floor(cx) - 1, hy, math.floor(cx) + 1, hy):clip(hole), "#c9a96e")
end
c:fill(c:rect(23, 26, 23, 27), "#7a4a1f"); c:fill(c:rect(40, 26, 40, 27), "#7a4a1f")

local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

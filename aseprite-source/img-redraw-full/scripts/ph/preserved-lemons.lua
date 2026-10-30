-- ph/preserved-lemons (Pantry pickle): big wide-shouldered jar, conical blue-glazed tagine lid with cream dot bands and gold ball finial, huge lemon wedges over a salt crust
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "preserved-lemons"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(12, 26, 52, 56, 11), "glass" },
  { "brine", c:rrect(14, 30, 50, 54, 9), "#f8e098", { contour = "#c8a83a", gloss = false } },
}
-- salt crust at the bottom
for _, q in ipairs({ {19, 53}, {23, 54}, {28, 53}, {33, 54}, {38, 53}, {42, 54}, {46, 52}, {25, 52}, {36, 52} }) do c:px(q[1], q[2], "#e8e0d0") end
-- lemon wedges: big half-moons, yellow flesh, pale pith ring, rind edge, segment lines
local lem = GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#b8661a" })
local function wedge(x, y, flip)
  local m = c:ellipse(x, y, 8, 7)
  m = flip and m:cut(c:rect(0, 0, 63, y - 1)) or m:cut(c:rect(0, y + 1, 63, 63))
  c:part(m, lem, { cres = 2, deep = 1, gloss = false, contact = false, contour = "#8a5a10" })
  local inner = (flip and c:ellipse(x, y, 5, 4):cut(c:rect(0, 0, 63, y - 1)) or c:ellipse(x, y, 5, 4):cut(c:rect(0, y + 1, 63, 63)))
  c:fill(m:copy():cut(m:shrink(1)):cut(c:rect(0, y, 63, y)), "#e8a317")   -- rind edge
  c:fill(m:shrink(1):cut(inner):cut(c:rect(0, y, 63, y)), "#fbf6e8")      -- pith ring
  c:fill(inner, "#f5cf6a")
  local d = flip and 1 or -1
  c:fill(c:line({ {x, y}, {x, y + d * 4} }, 1), "#fbf6e8")
  c:fill(c:line({ {x, y}, {x - 3, y + d * 3} }, 1), "#fbf6e8")
  c:fill(c:line({ {x, y}, {x + 3, y + d * 3} }, 1), "#fbf6e8")
end
wedge(22, 40, false); wedge(41, 39, false); wedge(25, 45, true); wedge(41, 46, true)
-- label with a lemon emblem
c:part(c:rrect(25, 41, 39, 49, 2), "cream", { gloss = false, contact = false })
c:paint({
  "....gg..",
  "..yyyg..",
  ".yYyyyy.",
  "yyyyyyys",
  ".yyyyys.",
  "..ysss..",
}, 28, 42, { y = "#f5cf6a", Y = "#fff1c8", s = "#e8a317", g = "#7ab55c" })
-- conical tagine lid with cream dot bands and a gold finial
local cone = c:poly({ {12, 29}, {53, 29}, {33, 9}, {32, 9} })
c:part(cone, GV.ramp("#3f8fb0", { shade = "#25637d" }), { contour = "#1a3f5a", gloss = { 27, 18 } })
for x = 18, 47, 3 do if cone:has(x, 26) then c:px(x, 26, "#f1ece0") end end
for x = 24, 41, 3 do if cone:has(x, 21) then c:px(x, 21, "#f1ece0") end end
c:fill(c:rect(13, 28, 52, 28), "#25637d")
c:part(c:ellipse(32.5, 8, 2.5, 2.5), "gold", { flat = true })
c:px(32, 7, "#fff1c8")
c:gloss(c:rrect(12, 26, 52, 56, 11), "glass", { 16, 36 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")

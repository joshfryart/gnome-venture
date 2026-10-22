local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 120, h = 80, mode = "scene", out = 2, ol = 1, olx = 1 }
-- backdrop
c:bands(c:rect(0, 0, 119, 79), { "#eef0d4", "#e3e6c4", "#d9deb6" }, { dir = "v" })
-- grass hill
local hill = c:poly({ {0,59}, {20,57}, {40,56}, {60,56}, {80,54}, {100,52}, {120,51}, {120,80}, {0,80} })
c:part(hill, GV.ramp("#b0bc66"), { gloss = false, outline = false })
-- tufts
for _, x in ipairs({ 8, 16, 100, 110, 104 }) do
  c:paint({ "g.g", ".g." }, x, x > 99 and 60 or 64, { g = "#7a8a3e" })
end
-- bed
c:build{
  { "frame", c:rrect(26, 15, 93, 70, 5), GV.ramp("#8c4a1a"), { gloss = false } },
  { "board", c:rrect(26, 15, 93, 19, 2), GV.ramp("#c4925f", { rim = "#f2e4c0" }), { gloss = false } },
}
-- soil cells
local cols, rows = { 29, 45, 61, 77 }, { 22, 34, 46, 58 }
for _, y in ipairs(rows) do for _, x in ipairs(cols) do
  local cell = c:rrect(x, y, x + 13, y + 9, 2)
  c:fill(cell, "#44281c")
  c:fill(c:rect(x, y, x + 13, y + 1):clip(cell), "#997851")
  c:fill(c:rect(x, y + 2, x + 13, y + 2):clip(cell), "#2a1a10")
end end
local SPR = { ".a...b.", "aaa.bbb", ".aa.bb.", "...s...", "...s...", "...s..." }
local TOM = { "..gsg..", "...g...", ".rrrrr.", "rhrrrrr", "rrrrrrd", "rrrrrdd", ".rddd.." }
local CAR = { "g.g.g", ".ggg.", "ooooo", "hoooq", ".ooq.", ".ooq.", "..o.." }
local L = { a = "#7ab55c", b = "#58a03e", s = "#2e5a2c", g = "#58a03e", r = "#d6322b", h = "#ff9158", d = "#ae2a2a", o = "#f08a24", q = "#c4621a" }
local plan = {
  { "S", "T", ".", "C" },
  { "C", "S", "S", "." },
  { "T", ".", "S", "T" },
  { "S", "C", ".", "S" },
}
for r = 1, 4 do for k = 1, 4 do
  local x, y, kind = cols[k], rows[r], plan[r][k]
  if kind == "S" then c:paint(SPR, x + 4, y + 1, L)
  elseif kind == "T" then c:paint(TOM, x + 3, y + 1, L)
  elseif kind == "C" then c:paint(CAR, x + 5, y + 1, L) end
end end
-- plus coin (more land)
c:part(c:ellipse(101.5, 19.5, 7, 7), GV.ramp("#f5cf6a"), { gloss = { 97, 14 } })
c:fill(c:rect(97, 19, 106, 20):add(c:rect(101, 15, 102, 24)), "#7a4a10")
-- frame ring and hem stitches
c:fill(c:rect(0, 0, 119, 0):add(c:rect(0, 79, 119, 79)):add(c:rect(0, 0, 0, 79)):add(c:rect(119, 0, 119, 79)), "#2a1a10")
c:seam({ {1, 2}, {118, 2} }, { free = true })
c:seam({ {1, 77}, {118, 77} }, { free = true })
local t = c:save(D .. "img-redraw-full/aseprite/landing/garden.aseprite", D .. "img-redraw-full/png/landing/garden.png")
print(GV.report(t))

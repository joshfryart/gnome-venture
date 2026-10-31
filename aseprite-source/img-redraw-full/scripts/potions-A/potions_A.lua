-- potions-A: Alchemy Table potion icons, version A (Opus medium, plain). 64x64 sticker, gvlib.
-- Not installed: run with --script-param out=<dir>/ --script-param ase=<dir>/ (claude/todo.md, Alchemy block).
-- One colour and one silhouette per potion so they read at 16 px:
--   healing (round flask, green), strong (wide flask, deep green, gold neck band), grand (tall faceted bottle, gold),
--   lucky (teardrop, pink, clover), sage (square bottle, blue, leaf sprig), stoneskin (stone jug with handle),
--   swiftfoot (slim vial, orange, wing), garden tonic (amber bottle with a sprout from the cork).
local D = (debug.getinfo(1, "S").source:match("^@(.*/)aseprite%-source/") or "/home/user/gnome-venture/") .. "aseprite-source/"   -- repo of this script
local GV = dofile(D .. "gvlib/gvlib.lua")
local P = app.params or {}
local OUT = P.out or (D .. "img-redraw-full/out-potions/A/")
local ASE = P.ase or (D .. "img-redraw-full/aseprite/potions-A/")
local HEART = { ".r.r.", "rRrrr", "rrrrr", ".rrr.", "..r.." }
local HL = { r = "#dd3a2a", R = "#ff9158" }

local function done(c, n)
  local t = c:save(ASE .. n .. ".aseprite", OUT .. n .. ".png")
  print(n, GV.report(t))
  assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, n .. " failed checks")
end

local function cork(c, x0, y0, x1, y1)
  c:part(c:rrect(x0, y0, x1, y1, 1), "#c9a96e", { gloss = false })
  c:px(x0 + 2, y0 + 2, "#9a6b3f"); c:px(x1 - 2, y0 + 4, "#9a6b3f")
end

local D_ = {}

D_["healing-potion"] = function(c)
  local body = c:ellipse(32, 41, 14, 13):add(c:rect(28, 16, 36, 30))
  c:part(body, "#d8ecf0", { pale = false })
  c:part(c:ellipse(32, 42, 12, 10.5):cut(c:rect(0, 0, 63, 33)), "#7ab55c", { contour = "#4a8a3e", gloss = { 22, 37 } })
  c:fill(c:rect(21, 33, 43, 33), "#c8d77a")
  cork(c, 27, 8, 37, 16)
  c:seam({ { 28, 18 }, { 36, 18 } }, { free = true })
  c:paint(HEART, 30, 40, HL)
  c:ground(32, 57, 12, 1.5)
end

D_["strong-healing-potion"] = function(c)
  local body = c:ellipse(32, 40, 17, 15):add(c:rect(27, 14, 37, 27))
  c:part(body, "#d8ecf0", { pale = false })
  c:part(c:ellipse(32, 41, 15, 12.5):cut(c:rect(0, 0, 63, 31)), "#4f9a45", { contour = "#2f5a2a", gloss = { 20, 36 } })
  c:fill(c:rect(18, 31, 46, 31), "#a4b86a")
  c:part(c:rect(26, 20, 38, 23), "gold", { gloss = false })
  cork(c, 26, 6, 38, 14)
  c:part(c:ellipse(32, 10, 3, 2.5), "red", { gloss = false })
  c:part(c:rrect(24, 37, 40, 48, 2), "cream", { gloss = false, contact = false })
  c:paint(HEART, 27, 40, HL); c:paint(HEART, 33, 40, HL)
  c:ground(32, 57, 14, 1.5)
end

D_["grand-healing-elixir"] = function(c)
  local body = c:poly({ { 20, 27 }, { 32, 20 }, { 45, 27 }, { 45, 50 }, { 39, 55 }, { 26, 55 }, { 20, 50 } })
  body:add(c:rect(28, 15, 36, 23))
  c:part(body, "#e8f1e8", { pale = false })
  c:part(c:poly({ { 22, 34 }, { 43, 34 }, { 43, 49 }, { 38, 53 }, { 27, 53 }, { 22, 49 } }), "#e8a317", { contour = "#b8661a", gloss = { 25, 38 } })
  c:fill(c:rect(23, 34, 42, 34), "#fff1c8")
  c:part(c:rect(27, 16, 37, 19), "gold", { gloss = false })
  -- star stopper
  c:part(c:poly({ { 32, 5 }, { 35, 10 }, { 40, 11 }, { 36, 14 }, { 37, 17 }, { 32, 15 }, { 27, 17 }, { 28, 14 }, { 24, 11 }, { 29, 10 } }), "gold", { gloss = false })
  c:paint(HEART, 30, 41, HL)
  c:seam({ { 21, 29 }, { 32, 23 }, { 44, 29 } }, { free = true })
  c:ground(32, 57, 13, 1.2)
end

D_["lucky-draught"] = function(c)
  local body = c:ellipse(32, 43, 14, 12):add(c:poly({ { 20, 38 }, { 32, 18 }, { 45, 38 } })):add(c:rect(29, 14, 35, 22))
  c:part(body, "#e8eef2", { pale = false })
  c:part(c:ellipse(32, 44, 12, 9.5):add(c:rect(21, 36, 43, 44)):cut(c:rect(0, 0, 63, 34)), "#e46a9b", { contour = "#a8346a", gloss = { 22, 40 } })
  c:fill(c:rect(23, 35, 41, 35), "#f6b8cf")
  cork(c, 28, 7, 36, 15)
  c:paint({ ".ggg.ggg.", "gGggsgggg", "gggggggg.", ".gggggg..", "ggggsgggg", "gGggggggg", ".ggg.ggg.", "....s....", ".....s...", "......s.." }, 28, 38, { g = "#2f8a3a", G = "#a4b86a", s = "#1f4a22" })
  c:px(25, 30, "#ffffff"); c:px(39, 27, "#fff3c8")
  c:ground(32, 57, 12, 1.5)
end

D_["sages-draught"] = function(c)
  local body = c:rrect(19, 24, 45, 55, 4):add(c:rect(28, 15, 36, 25))
  c:part(body, "#e2ecf0", { pale = false })
  c:part(c:rrect(21, 33, 43, 53, 3), "#3f8fb0", { contour = "#2f6290", gloss = { 24, 37 } })
  c:fill(c:rect(22, 33, 42, 33), "#8fcbd8")
  cork(c, 27, 8, 37, 16)
  -- sage sprig tied at the neck
  c:part(c:line({ { 36, 20 }, { 41, 14 } }, 2), "#4a8a3e", { flat = true })
  c:part(c:poly({ { 39, 15 }, { 44, 8 }, { 47, 10 }, { 42, 17 } }), "#7ab55c", { gloss = false })
  c:part(c:poly({ { 38, 19 }, { 46, 17 }, { 46, 20 }, { 38, 22 } }), "#a4b86a", { gloss = false })
  c:seam({ { 28, 19 }, { 36, 19 } }, { free = true })
  -- crescent moon and two stars on the glass
  c:paint({ ".mmm.", "mm...", "m....", "mm...", ".mmm." }, 25, 39, { m = "#fff1c8" })
  c:px(36, 39, "#fff1c8"); c:px(38, 45, "#fff1c8"); c:px(33, 47, "#fff1c8")
  c:ground(32, 58, 14, 1.5)
end

D_["stoneskin-brew"] = function(c)
  local jug = c:ellipse(30, 41, 15, 14):add(c:rrect(24, 16, 36, 28, 2))
  c:part(c:line({ { 41, 26 }, { 49, 28 }, { 50, 38 }, { 44, 46 } }, 4), "#8b8f96", { gloss = false })
  c:part(jug, "#8b8f96", { gloss = { 21, 34 } })
  c:part(c:rrect(23, 12, 37, 17, 2), "#5b6470", { gloss = false })
  cork(c, 26, 6, 34, 12)
  c:spot(c:ellipse(24, 44, 2, 1.5), "#5b6470"); c:spot(c:ellipse(35, 38, 2.5, 2), "#5b6470"); c:spot(c:ellipse(31, 50, 2, 1.5), "#5b6470")
  -- shield mark
  c:part(c:poly({ { 25, 38 }, { 36, 38 }, { 36, 45 }, { 31, 50 }, { 30, 50 }, { 25, 45 } }), "#b07a45", { gloss = false })
  c:paint({ "..g..", "..g..", "ggggg", "..g..", "..g.." }, 28, 40, { g = "#f5cf6a" })
  c:seam({ { 23, 29 }, { 37, 29 } }, { free = true })
  c:ground(31, 57, 14, 1.5)
end

D_["swiftfoot-elixir"] = function(c)
  local vial = c:rrect(23, 18, 35, 54, 6):add(c:rect(25, 13, 33, 19))
  -- wing behind the vial
  c:part(c:poly({ { 33, 37 }, { 46, 33 }, { 50, 35 }, { 46, 39 }, { 33, 42 } }), "#c9c5bc", { gloss = false })
  c:part(c:poly({ { 33, 32 }, { 47, 25 }, { 51, 27 }, { 47, 32 }, { 33, 38 } }), "#e8e2d4", { gloss = false })
  c:part(c:poly({ { 33, 28 }, { 44, 18 }, { 49, 18 }, { 46, 24 }, { 33, 33 } }), "#f1ece0", { gloss = false })
  c:part(vial, "#e8eef2", { pale = false })
  c:part(c:rrect(25, 29, 33, 52, 4), "#f08a24", { contour = "#b8661a", gloss = { 27, 32 } })
  c:fill(c:rect(25, 29, 33, 29), "#ffc27a")
  cork(c, 24, 7, 34, 14)
  c:seam({ { 24, 21 }, { 34, 21 } }, { free = true })
  c:ground(29, 57, 9, 1.5)
end

D_["garden-tonic"] = function(c)
  local body = c:rrect(20, 31, 44, 54, 6):add(c:rect(28, 22, 36, 32))
  c:part(body, "#b07a45", { gloss = { 24, 35 } })
  c:part(c:rrect(23, 39, 41, 50, 2), "cream", { gloss = false })
  cork(c, 27, 16, 37, 22)
  -- sprout from the cork
  c:part(c:rect(31, 9, 33, 16), "#4f9a45", { flat = true })
  c:part(c:poly({ { 31, 13 }, { 24, 11 }, { 21, 7 }, { 27, 7 }, { 31, 10 } }), "#7ab55c", { gloss = false })
  c:part(c:poly({ { 33, 12 }, { 37, 7 }, { 44, 6 }, { 42, 10 }, { 34, 14 } }), "#7ab55c", { gloss = false })
  -- leaf on the label
  c:paint({ "..gg", ".gGg", "gggg", "ggg.", "s..." }, 30, 42, { g = "#4f9a45", G = "#a4b86a", s = "#2f5a2a" })
  c:seam({ { 21, 36 }, { 43, 36 } }, { free = true })
  c:ground(32, 57, 13, 1.5)
end

local only = P.only
for _, n in ipairs({ "healing-potion", "strong-healing-potion", "grand-healing-elixir", "lucky-draught", "sages-draught", "stoneskin-brew", "swiftfoot-elixir", "garden-tonic" }) do
  if not only or only == n then
    local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
    D_[n](c)
    done(c, n)
  end
end

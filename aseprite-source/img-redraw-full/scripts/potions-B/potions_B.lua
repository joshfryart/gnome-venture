-- potions-B: Alchemy Table potion icons, version B (Opus, impeccable skill as critique lens). 64x64 sticker, gvlib.
-- Critique of A that drives B: colour mass is the identity at 16 px, so the liquid fills the bottle; one hero glyph per potion,
-- about twice A's size, no small labels; healing tiers are a visible ladder (bottle grows, liquid deepens, glyph escalates:
-- heart, heart + gold collar, gold heart crowned); every potion has its own silhouette (round, wide, tall hex, teardrop,
-- tall square, jug, slim vial + wing, squat jar + big sprout).
-- Not installed: run with --script-param out=<dir>/ --script-param ase=<dir>/ (claude/todo.md, Alchemy block).
local D = (debug.getinfo(1, "S").source:match("^@(.*/)aseprite%-source/") or "/home/user/gnome-venture/") .. "aseprite-source/"   -- repo of this script
local GV = dofile(D .. "gvlib/gvlib.lua")
local P = app.params or {}
local OUT = P.out or (D .. "img-redraw-full/out-potions/B/")
local ASE = P.ase or (D .. "img-redraw-full/aseprite/potions-B/")
local HEART = { ".rr.rr.", "rRRrrrr", "rRrrrrr", "rrrrrrr", ".rrrrr.", "..rrr..", "...r..." }
local HL = { r = "#dd3a2a", R = "#ffc27a" }
local HG = { r = "#fff1c8", R = "#ffffff" }

local function done(c, n)
  local t = c:save(ASE .. n .. ".aseprite", OUT .. n .. ".png")
  print(n, GV.report(t))
  assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, n .. " failed checks")
end

local function cork(c, x0, y0, x1, y1)
  c:part(c:rrect(x0, y0, x1, y1, 1), "#c9a96e", { gloss = false })
  c:px(x0 + 2, y0 + 2, "#9a6b3f"); c:px(x1 - 2, y0 + 3, "#9a6b3f")
end

local D_ = {}

-- tier 1: small round flask, bright green, one heart
D_["healing-potion"] = function(c)
  c:part(c:ellipse(32, 43, 13, 12):add(c:rect(28, 19, 36, 32)), "#d8ecf0", { pale = false })
  c:part(c:ellipse(32, 43, 11, 10):add(c:rect(29, 28, 35, 34)):cut(c:rect(0, 0, 63, 27)), "#7ab55c", { contour = "#4a8a3e", gloss = { 24, 38 } })
  c:fill(c:rect(29, 28, 35, 28), "#c8d77a")
  cork(c, 27, 12, 37, 19)
  c:paint(HEART, 29, 40, HL)
  c:ground(32, 57, 11, 1.5)
end

-- tier 2: wider flask, deep green, gold collar, bigger heart
D_["strong-healing-potion"] = function(c)
  c:part(c:ellipse(32, 41, 17, 15):add(c:rect(27, 14, 37, 28)), "#d8ecf0", { pale = false })
  c:part(c:ellipse(32, 41, 15, 13):add(c:rect(28, 24, 36, 30)):cut(c:rect(0, 0, 63, 23)), "#3f8a3a", { contour = "#2f5a2a", gloss = { 21, 34 } })
  c:fill(c:rect(28, 24, 36, 24), "#a4b86a")
  c:part(c:rect(25, 17, 39, 21), "gold", { gloss = false })
  c:button(30, 18)
  cork(c, 26, 7, 38, 14)
  c:paint({ ".rrr.rrr.", "rRRrrrrrr", "rRrrrrrrr", "rrrrrrrrr", ".rrrrrrr.", "..rrrrr..", "...rrr...", "....r...." }, 28, 37, HL)
  c:ground(32, 57, 14, 1.5)
end

-- tier 3: tall faceted bottle, gold liquid, cream heart, crown stopper
D_["grand-healing-elixir"] = function(c)
  local body = c:poly({ { 19, 28 }, { 32, 21 }, { 46, 28 }, { 46, 50 }, { 39, 56 }, { 26, 56 }, { 19, 50 } }):add(c:rect(28, 15, 36, 24))
  c:part(body, "#e8f1e8", { pale = false })
  c:part(c:poly({ { 21, 30 }, { 32, 24 }, { 44, 30 }, { 44, 50 }, { 38, 54 }, { 27, 54 }, { 21, 50 } }), "#e8a317", { contour = "#b8661a", gloss = { 24, 33 } })
  c:part(c:rect(26, 15, 38, 19), "gold", { gloss = false })
  -- crown stopper
  c:part(c:poly({ { 25, 15 }, { 25, 8 }, { 29, 11 }, { 32, 6 }, { 35, 11 }, { 39, 8 }, { 39, 15 } }), "gold", { gloss = false })
  c:px(32, 10, "#dd3a2a"); c:px(26, 11, "#dd3a2a"); c:px(38, 11, "#dd3a2a")
  c:paint({ ".rrr.rrr.", "rRRrrrrrr", "rRrrrrrrr", "rrrrrrrrr", ".rrrrrrr.", "..rrrrr..", "...rrr...", "....r...." }, 28, 36, { r = "#dd3a2a", R = "#fff1c8" })
  c:ground(32, 58, 14, 1.2)
end

-- teardrop flask, pink, big clover
D_["lucky-draught"] = function(c)
  local body = c:ellipse(32, 44, 14, 12):add(c:poly({ { 19, 40 }, { 32, 19 }, { 46, 40 } })):add(c:rect(29, 15, 35, 23))
  c:part(body, "#e8eef2", { pale = false })
  c:part(c:ellipse(32, 44, 12, 10):add(c:poly({ { 22, 40 }, { 32, 25 }, { 43, 40 } })), "#e46a9b", { contour = "#a8346a", gloss = { 25, 37 } })
  cork(c, 28, 8, 36, 16)
  c:paint({ ".ggg.ggg.", "gGGggGGgg", "gGggggggg", ".gggsggg.", "gggsssggg", "gGggsgggg", "ggggggggg", ".ggg.ggg.", "....s....", ".....s..." }, 28, 35, { g = "#2f8a3a", G = "#7ab55c", s = "#1f4a22" })
  c:ground(32, 58, 12, 1.5)
end

-- tall square bottle, deep blue, one big sage leaf, crescent moon
D_["sages-draught"] = function(c)
  c:part(c:rrect(21, 22, 43, 55, 3):add(c:rect(28, 14, 36, 23)), "#e2ecf0", { pale = false })
  c:part(c:rrect(23, 25, 41, 53, 2), "#2f6c9a", { contour = "#2a3c6c", gloss = { 26, 28 } })
  c:fill(c:rect(23, 25, 41, 25), "#8fcbd8")
  cork(c, 27, 7, 37, 14)
  -- one big leaf leaning off the neck
  c:part(c:poly({ { 37, 17 }, { 42, 10 }, { 49, 7 }, { 48, 13 }, { 41, 19 } }), "#7ab55c", { gloss = false })
  c:part(c:line({ { 38, 17 }, { 46, 10 } }, 1), "#4a8a3e", { flat = true, solid = false })
  c:paint({ "..mmm..", ".mm....", "mm.....", "mm.....", "mm.....", ".mm....", "..mmm.." }, 27, 34, { m = "#fff1c8" })
  c:px(37, 33, "#fff1c8"); c:px(36, 41, "#fff1c8"); c:px(38, 46, "#fff1c8")
  c:ground(32, 58, 13, 1.5)
end

-- stone jug with handle, big shield
D_["stoneskin-brew"] = function(c)
  c:part(c:line({ { 42, 26 }, { 49, 28 }, { 50, 38 }, { 44, 46 } }, 4), "#8b8f96", { gloss = false })
  c:part(c:ellipse(30, 41, 15, 14):add(c:rrect(24, 17, 36, 28, 2)), "#8b8f96", { gloss = { 20, 33 } })
  c:part(c:rrect(23, 12, 37, 17, 2), "#5b6470", { gloss = false })
  cork(c, 26, 6, 34, 12)
  c:part(c:poly({ { 22, 33 }, { 38, 33 }, { 38, 43 }, { 31, 51 }, { 29, 51 }, { 22, 43 } }), "#b07a45", { gloss = { 25, 36 } })
  c:paint({ "...g...", "...g...", "ggggggg", "...g...", "...g...", "...g..." }, 27, 36, { g = "#f5cf6a" })
  c:ground(31, 58, 14, 1.5)
end

-- slim vial, orange, big wing is the silhouette
D_["swiftfoot-elixir"] = function(c)
  c:part(c:poly({ { 30, 39 }, { 45, 35 }, { 51, 38 }, { 46, 42 }, { 30, 45 } }), "#e8e2d4", { gloss = false })
  c:part(c:poly({ { 30, 33 }, { 46, 26 }, { 52, 28 }, { 47, 33 }, { 30, 40 } }), "#f1ece0", { gloss = false })
  c:part(c:poly({ { 30, 28 }, { 42, 16 }, { 50, 15 }, { 46, 23 }, { 30, 34 } }), "#fbf3e2", { gloss = false })
  c:part(c:rrect(19, 19, 32, 55, 6):add(c:rect(21, 14, 30, 20)), "#e8eef2", { pale = false })
  c:part(c:rrect(21, 23, 30, 53, 4), "#f08a24", { contour = "#b8661a", gloss = { 23, 26 } })
  c:fill(c:rect(21, 23, 30, 23), "#ffc27a")
  cork(c, 20, 7, 31, 14)
  c:ground(26, 58, 9, 1.5)
end

-- squat jar of green tonic, the sprout is the hero
D_["garden-tonic"] = function(c)
  c:part(c:rrect(18, 34, 46, 55, 7):add(c:rect(26, 28, 38, 35)), "#d8ecf0", { pale = false })
  c:part(c:rrect(20, 38, 44, 53, 5), "#6aa83a", { contour = "#2f5a2a", gloss = { 24, 42 } })
  c:fill(c:rect(22, 38, 42, 38), "#c8d77a")
  c:part(c:rect(25, 31, 39, 33), "#b07a45", { gloss = false })
  cork(c, 25, 23, 39, 29)
  c:part(c:rect(31, 12, 33, 23), "#4a8a3e", { flat = true })
  c:part(c:poly({ { 31, 17 }, { 22, 15 }, { 16, 8 }, { 24, 8 }, { 31, 13 } }), "#7ab55c", { gloss = false })
  c:part(c:poly({ { 33, 16 }, { 39, 9 }, { 48, 6 }, { 45, 12 }, { 34, 19 } }), "#7ab55c", { gloss = false })
  c:part(c:line({ { 30, 15 }, { 21, 10 } }, 1), "#4a8a3e", { flat = true, solid = false })
  c:part(c:line({ { 34, 15 }, { 44, 9 } }, 1), "#4a8a3e", { flat = true, solid = false })
  c:ground(32, 58, 14, 1.5)
end

for _, n in ipairs({ "healing-potion", "strong-healing-potion", "grand-healing-elixir", "lucky-draught", "sages-draught", "stoneskin-brew", "swiftfoot-elixir", "garden-tonic" }) do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  D_[n](c)
  done(c, n)
end

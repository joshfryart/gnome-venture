-- ph/pickled-bamboo-shoots, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: a green tube with a cap and a window reads as a can or a lantern; the shoot itself is hidden. Fix
-- (specificity): a short bamboo-section cup (one node ring, cut rim) with three ivory shoot halves standing out of it,
-- each a cone with stacked sheath lines. Green cup + cream spears is a silhouette no other jar has.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "pickled-bamboo-shoots", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bam = GV.ramp("#7ab04a", { gloss = "#e4f0a0", dot = "#f4f8d0" })
local ivory = GV.ramp("#f0e2b4", { gloss = "#fff3c8", dot = "#fbf6e8", rim = "#fff3c8", pale = false })
local function shoot(x, base, top, w)
  local m = c:poly({ {x - w, base}, {x + w + 1, base}, {x + 2, top + 3}, {x, top}, {x - 1, top + 3} })
  c:part(m, ivory, { gloss = false, cres = 3, contact = false })
  for y = top + 6, base - 2, 4 do
    local hw = math.floor(w * (y - top) / (base - top) + 0.5)
    c:fill(c:line({ {x - hw + 1, y + 1}, {x, y - 1}, {x + hw - 1, y + 1} }, 1):clip(m), "#c9a96e")
  end
  c:px(x, top + 1, "#d6a040")
end
shoot(23, 32, 10, 7)
shoot(42, 32, 11, 7)
shoot(32, 34, 6, 8)
-- bamboo cup
local cup = c:rrect(14, 28, 50, 55, 3)
c:part(cup, bam, { gloss = { 17, 33 } })
c:fill(c:ellipse(32, 29, 17, 2):clip(cup), "#4a8a3e")
c:part(c:rrect(13, 42, 51, 44, 1), bam, { flat = true, contact = false })
c:fill(c:rect(14, 44, 50, 44), "#4a8a3e")
c:fill(c:line({ {20, 34}, {20, 39} }, 1), "#c8e080"); c:fill(c:line({ {20, 48}, {20, 52} }, 1), "#c8e080")
c:ground(32, 57, 19, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

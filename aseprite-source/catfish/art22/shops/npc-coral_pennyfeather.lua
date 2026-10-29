-- npc-coral_pennyfeather.lua : Cat Fish pet shop keeper bust, Coral Pennyfeather of Driftwood & Whisker
-- (Sunsprinkle Isles, CB, Caribbean). Matches the shipped villager busts (game/assets/img/ph/npc-*.png):
-- 80x100, gvlib "bust" mode (1 px umber outline +1 lower right, 1 px #000000 border, none on the bottom edge),
-- round flat backdrop disc, big round head, smock bleeding off the bottom, seam + button, locked eyes.
-- Coral is bird folk (Pennyfeather): a coral-pink flamingo with a pale bent beak and a dark tip, wearing a red
-- madras head tie (gold and green check, knot at the upper right), a turquoise blouse with a cream apron and a
-- little conch pendant. She holds up a driftwood feather-wand cat toy (coral, turquoise and gold feathers and a
-- bell on a string), the shop's best seller. Friendly smile, no text.
-- Run: AppRun -b --script npc-coral_pennyfeather.lua   Writes ../out/npc-coral_pennyfeather.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"

local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local skyR   = GV.ramp("#a9d6ea")
local pinkR  = GV.ramp("#f28a78")                 -- coral flamingo feathers
local turqR  = GV.ramp("#3fb5ad")
local madR   = GV.R.red
local woodR  = GV.R.wood
local GREEN, GOLDT = "#4f9a45", "#f5cf6a"

---------------------------------------------------------------- shapes
local disc   = c:ellipse(39.5, 48, 34, 34):cut(c:rect(0, 86, 79, 99))
local blouse = c:ellipse(39.5, 102, 33, 25)
local apron  = c:poly({ {28, 82}, {51, 82}, {56, 100}, {23, 100} })
local head   = c:ellipse(37.5, 56, 19, 17)
-- head tie: dome over the crown, brim band, knot with two lobes and a tail at the upper right
local wrap = c:ellipse(37.5, 45, 21, 14):cut(c:rect(0, 47, 79, 99))
wrap:add(c:rrect(16, 43, 59, 48, 2))
local knot = c:ellipse(55, 31, 6, 5):add(c:ellipse(47, 28, 5, 4.5)):add(c:poly({ {56, 33}, {64, 38}, {60, 41}, {53, 36} }))
-- wing-hand at lower right holding the wand
local wing = c:ellipse(60.5, 86, 7, 6)
-- wand: driftwood stick from the hand up to the upper right
local stick = c:line({ {63, 85}, {67, 64}, {71, 47} }, 2)

---------------------------------------------------------------- build (back to front)
local p = c:build{
  { "disc",   disc,   skyR, { flat = true } },
  { "blouse", blouse, turqR, { stitch = { side = "lit" } } },
  { "apron",  apron,  "cream" },
  { "head",   head,   pinkR },
  { "knot",   knot,   madR, { gloss = false } },
  { "wrap",   wrap,   madR, { gloss = { 24, 38 } } },
}
-- madras check on the tie (gold + green lines, clipped inside the edge)
local inner = wrap:shrink(1):add(knot:shrink(1))
for x = 18, 64, 6 do
  inner:copy():clip(c:rect(x, 0, x, 99)):each(function(xx, yy) c:px(xx, yy, GOLDT) end)
end
for x = 21, 64, 12 do
  inner:copy():clip(c:rect(x, 0, x + 1, 99)):each(function(xx, yy) c:px(xx, yy, GREEN) end)
end
for _, y in ipairs({ 37, 45, 30 }) do
  inner:copy():clip(c:rect(0, y, 79, y)):each(function(xx, yy) c:px(xx, yy, GOLDT) end)
end
c:seam({ {18, 47}, {57, 47} })

-- stick, then the hand over it; feathers and bell on a string at the top
c:part(stick, woodR, { flat = true, contact = false })
c:part(wing, pinkR, { gloss = false })
c:fill(c:line({ {57, 85}, {60, 87} }, 1), pinkR.shade)      -- feather tips on the wing
c:fill(c:line({ {57, 88}, {60, 90} }, 1), pinkR.shade)
c:fill(c:line({ {71, 47}, {73, 52}, {72, 56} }, 1), "#f1ece0")  -- string
c:part(c:ellipse(72, 58.5, 2.5, 2.5), "gold", { gloss = false, contact = false })   -- bell
c:px(71, 57, "#fff1c8"); c:px(72, 60, "#7a3a14")
local f1 = c:line({ {71, 46}, {67, 41}, {65, 36} }, 3)
local f2 = c:line({ {72, 46}, {72, 39}, {73, 34} }, 3)
local f3 = c:line({ {72, 46}, {76, 42}, {77, 38} }, 2)
c:part(f2, turqR, { flat = true, contact = false })
c:part(f1, pinkR, { flat = true, contact = false })
c:part(f3, "gold", { flat = true, contact = false })
c:px(72, 37, turqR.shade); c:px(72, 41, turqR.shade); c:px(66, 39, pinkR.shade); c:px(68, 42, pinkR.shade)
c:part(c:rect(70, 45, 73, 47), woodR, { flat = true, contact = false })  -- wrapped grip at the tip

---------------------------------------------------------------- face
c:eye(27, 52); c:eye(43, 52)
-- flamingo beak: pale, bent down, dark tip
local beak = c:poly({ {34, 58}, {42, 58}, {41, 63}, {38, 67}, {36, 63} })
c:fill(beak, "#f2e4c0")
c:fill(c:poly({ {35, 58}, {41, 58}, {40, 59}, {36, 59} }), "#fff3c8")
c:fill(beak:copy():clip(c:rect(0, 63, 79, 99)), "#3e2f66")
c:px(38, 63, "#7b66b4")
beak:edge():clip(c:rect(0, 59, 79, 62)):each(function(x, y) c:px(x, y, "#c9a96e") end)
-- smile lines either side of the beak
c:paint({ "u...", ".uu." }, 30, 61, { u = "umber" })
c:paint({ "...u", ".uu." }, 42, 61, { u = "umber" })
-- feather tuft cheeks (small chevrons, not blush)
c:paint({ "s.", ".s" }, 22, 60, { s = pinkR.shade })
c:paint({ ".s", "s." }, 52, 60, { s = pinkR.shade })

---------------------------------------------------------------- clothes details
-- cream ruffled collar points and the conch pendant
c:part(c:poly({ {30, 75}, {37, 75}, {33, 81} }), "cream", { flat = true })
c:part(c:poly({ {41, 75}, {48, 75}, {44, 81} }), "cream", { flat = true })
c:fill(c:line({ {33, 74}, {39, 78}, {45, 74} }, 1), "#c9a96e")
local conch = c:ellipse(39, 80.5, 2.5, 2):add(c:poly({ {40, 79}, {43, 81}, {40, 83} }))
c:part(conch, GV.ramp("#f6b8cf"), { flat = true, contact = false })
c:px(38, 80, "#fff3c8")
-- apron seam + button + paw-print pocket
c:seam({ {27, 85}, {24, 99} }); c:seam({ {52, 85}, {55, 99} })
c:button(37, 86)
c:fill(c:ellipse(39.5, 95, 2, 1.5), pinkR.base)
c:px(37, 92, pinkR.base); c:px(39, 91, pinkR.base); c:px(41, 92, pinkR.base)

local t = c:save(OUT .. "npc-coral_pennyfeather.aseprite", OUT .. "npc-coral_pennyfeather.png")
print(GV.report(t))

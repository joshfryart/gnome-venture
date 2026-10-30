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
local pinkR  = GV.ramp("#f6a08c", { shade = "#e27c7a", deep = "#b95a6c", bounce = "#ea8a80" })                 -- coral flamingo feathers
local turqR  = GV.ramp("#3fb5ad")
local madR   = GV.R.red
local woodR  = GV.R.wood
local GREEN, GOLDT = "#4f9a45", "#f5cf6a"

---------------------------------------------------------------- shapes
local disc   = c:ellipse(39.5, 48, 34, 34):cut(c:rect(0, 86, 79, 99))
local blouse = c:ellipse(39.5, 102, 33, 25)
local apron  = c:poly({ {28, 82}, {51, 82}, {56, 100}, {23, 100} })
local head   = c:ellipse(37.5, 56, 19, 17)
-- head tie: dome over the crown, brim band, knot with two lobes and a tail at the upper left
local wrap = c:ellipse(37.5, 45, 21, 14):cut(c:rect(0, 47, 79, 99))
wrap:add(c:rrect(16, 43, 59, 48, 2))
local knot = c:ellipse(20, 31, 6, 5):add(c:ellipse(28, 28, 5, 4.5)):add(c:poly({ {19, 33}, {11, 38}, {15, 41}, {22, 36} }))
-- wing-hand at lower right holding the wand
local wing = c:ellipse(57.5, 88, 6, 5.5)
-- wand: driftwood stick from the hand up to the upper right
local stick = c:line({ {59, 87}, {63, 64}, {66, 47} }, 2)

---------------------------------------------------------------- build (back to front)
local p = c:build{
  { "disc",   disc,   skyR, { flat = true } },
  { "blouse", blouse, turqR, { stitch = { side = "lit" } } },
  { "apron",  apron,  "cream", { gloss = false } },
  { "head",   head,   pinkR },
  { "knot",   knot,   madR, { gloss = false } },
  { "wrap",   wrap,   madR, { gloss = { 30, 36 } } },
}
-- madras check on the tie (gold + green lines, clipped inside the edge)
local inner = wrap:shrink(1):add(knot:shrink(1))
for x = 13, 60, 6 do
  inner:copy():clip(c:rect(x, 0, x, 99)):each(function(xx, yy) c:px(xx, yy, GOLDT) end)
end
for x = 16, 60, 12 do
  inner:copy():clip(c:rect(x, 0, x + 1, 99)):each(function(xx, yy) c:px(xx, yy, GREEN) end)
end
for _, y in ipairs({ 37, 45, 30 }) do
  inner:copy():clip(c:rect(0, y, 79, y)):each(function(xx, yy) c:px(xx, yy, GOLDT) end)
end
c:seam({ {18, 47}, {57, 47} })

-- stick, then the hand over it; feathers and bell on a string at the top
c:part(stick, woodR, { flat = true, contact = false })
c:part(wing, pinkR, { flat = true })
c:fill(c:line({ {54, 86}, {57, 87} }, 1), pinkR.shade)      -- feather fingers curled round the stick
c:fill(c:line({ {54, 89}, {57, 90} }, 1), pinkR.shade)
c:fill(c:line({ {67, 47}, {69, 51}, {70, 53} }, 1), "#f1ece0")  -- string
c:part(c:ellipse(70.5, 56.5, 3, 3), "gold", { flat = true, contact = false })   -- bell
c:px(69, 55, "#fff1c8"); c:fill(c:rect(69, 58, 72, 58), "#b8661a"); c:px(70, 59, "#7a3a14"); c:px(71, 59, "#7a3a14")
local f1 = c:line({ {64, 46}, {60, 41}, {57, 36} }, 2):add(c:poly({ {55, 28}, {59, 31}, {61, 37}, {57, 39}, {54, 33} }))
local f2 = c:line({ {66, 46}, {66, 38} }, 2):add(c:poly({ {66, 25}, {69, 30}, {69, 38}, {64, 38}, {64, 30} }))
local f3 = c:line({ {67, 46}, {71, 41} }, 2):add(c:poly({ {76, 31}, {76, 37}, {73, 42}, {70, 40}, {72, 35} }))
c:part(f2, turqR, { flat = true, contact = false })
c:part(f1, pinkR, { flat = true, contact = false })
c:part(f3, "gold", { flat = true, contact = false })
-- feather spines (1 px quills)
c:fill(c:line({ {66, 29}, {66, 37} }, 1), turqR.shade); c:fill(c:line({ {58, 32}, {57, 37} }, 1), pinkR.deep); c:fill(c:line({ {73, 35}, {72, 40} }, 1), "#b8661a")
c:part(c:rect(64, 45, 67, 48), woodR, { flat = true, contact = false })  -- wrapped grip at the tip

---------------------------------------------------------------- face
c:eye(27, 52); c:eye(43, 52)
-- flamingo beak: pale, bent down, dark tip
c:paint({
  "ooooooooooo",
  "ollllllllco",
  "occcccccccso",
  ".occcccccsso",
  "..ocddddsso.",
  "...oddddso..",
  "....odddo...",
  ".....odo....",
  "......o.....",
}, 33, 58, { o = "#4a2c1a", l = "#fff3c8", c = "#f2e4c0", s = "#c9a96e", d = "#3e2f66" })
c:px(38, 62, "#7b66b4"); c:px(39, 62, "#7b66b4")
-- smile lines either side of the beak
c:paint({ "u...", ".uu." }, 29, 61, { u = "umber" })
c:paint({ "...u", ".uu." }, 43, 61, { u = "umber" })

---------------------------------------------------------------- clothes details
-- conch pendant on a cream cord
c:fill(c:line({ {33, 75}, {39, 79}, {45, 75} }, 1), "#c9a96e")
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

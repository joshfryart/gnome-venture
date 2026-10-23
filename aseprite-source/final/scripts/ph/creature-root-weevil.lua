-- ph/creature-root-weevil : 3/4 side weevil. Humped root-brown wing cases at left,
-- big round head, long down-curved pale gnawed-wood snout ending in tiny jaws
-- (dark bark head, locked eyes, grumpy brows). Elbowed antenna with a club from mid-snout.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local backR  = GV.ramp("#7a4a1f")                  -- soil mid: root brown wing cases
local headR  = GV.ramp("#5a3420", { rim = "#8a5a36" }) -- dark root-bark head
local snoutR = GV.ramp("#c9a96e")                  -- soil pale: gnawed wood snout

-- legs (behind body), short and bent
c:limb({ {13, 45}, {9, 49}, {10, 53} })
c:limb({ {22, 47}, {21, 51}, {23, 54} })
c:limb({ {33, 43}, {36, 48}, {34, 53} })

-- shapes
local back = c:ellipse(20, 37, 13, 11.5)           -- humped wing cases
back:add(c:ellipse(14, 42, 7.5, 6))                -- round rump
local head = c:ellipse(34.5, 28, 10, 9.5)          -- big chibi head
local snout = c:line({ {40, 31}, {45, 31}, {48, 33} }, 7)
snout:add(c:line({ {48, 33}, {51, 37}, {52, 41} }, 6))
snout:add(c:line({ {52, 41}, {53, 44} }, 4))
snout:cut(head)

local p = c:build{
  { "back",  back,  backR },
  { "snout", snout, snoutR, { gloss = { 45, 30 } } },
  { "head",  head,  headR },
}

-- wing-case grooves (striae), 1 px, following the hump
for i, g in ipairs({
  { {13, 29}, {10, 36}, {10, 44} },
  { {26, 32}, {25, 40}, {24, 47} },
}) do
  local m = c:line(g, 1); m:clip(p.back.m:shrink(2)); m:cut(head:grow(1))
  c:fill(m, backR.shade)
end

-- seam down the middle of the back where the two wing cases meet, button at its head
c:seam({ {20, 28}, {17, 35}, {17, 42}, {18, 48} })
c:button(19, 24)

-- tiny jaws at the snout tip
local jawR = GV.ramp("#b07a45")
c:part(c:ascii({ "jj....jj", "jj....jj", "jjj..jjj", ".jj..jj." }, 49, 44), jawR, { flat = true, contact = false })

-- elbowed antenna from mid-snout, 4x4 club
c:limb({ {48, 30}, {47, 24}, {50, 21} })
c:part(c:rrect(50, 17, 53, 20, 1), "dusk", { flat = true })

-- face: two wide locked eyes, grumpy brows
c:eye(28, 25); c:eye(36, 25)
c:paint({ "aa.", "..a" }, 28, 22, { a = "#2a1a10" })
c:paint({ ".aa", "a.." }, 38, 22, { a = "#2a1a10" })

c:ground(25, 55, 18, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-root-weevil.aseprite", PNG .. "creature-root-weevil.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local D = -3 -- vertical shift to keep halo inside the frame

local legR = GV.ramp("#e0501f")
local shell = GV.ramp("#f08a24")
local belly = GV.ramp("#f8eed2")
local function L(pts, w) for _, p in ipairs(pts) do p[2] = p[2] + D end return c:line(pts, w) end

-- legs (splayed, two each side, bent)
local legs = L({ {21,45}, {15,50}, {12,55} }, 2)
legs:add(L({ {24,49}, {19,53}, {16,57} }, 2))
legs:add(L({ {42,45}, {48,50}, {51,55} }, 2))
legs:add(L({ {39,49}, {44,53}, {47,57} }, 2))

-- arms
local arms = L({ {20,41}, {17,36}, {16,30} }, 3)
arms:add(L({ {43,41}, {46,36}, {47,30} }, 3))

-- claws: fat ovals with a wide V notch opening up -> two pincer fingers
local function claw(cx, dir)
  local m = c:ellipse(cx, 22 + D, 6, 8)
  local t = cx + dir
  m:cut(c:poly({ {t - 2, 12 + D}, {t + 3, 12 + D}, {t + 1, 23 + D}, {t, 23 + D} }))
  return m
end
local clawL = claw(14, -1)
local clawR = claw(49, 1)

local body = c:ellipse(31.5, 43.5 + D, 16, 11)
local bel = c:ellipse(31.5, 47 + D, 9, 5.5)
local stalks = c:rect(26, 27 + D, 27, 33 + D):add(c:rect(36, 27 + D, 37, 33 + D))
local bases = c:ellipse(26.5, 26.5 + D, 4):add(c:ellipse(36.5, 26.5 + D, 4))

c:build{
  { "legs", legs, legR, { flat = true } },
  { "arms", arms, legR, { flat = true } },
  { "clawL", clawL, shell },
  { "clawR", clawR, shell },
  { "stalks", stalks, legR, { flat = true } },
  { "body", body, shell, { stitch = { side = "lit" } } },
  { "belly", bel, belly, { gloss = false } },
  { "bases", bases, shell, { gloss = false } },
}
c:seam({ {31, 43 + D}, {31, 52 + D} })
c:eye(24, 24 + D); c:eye(34, 24 + D)
c:paint({ "u...u", ".uuu." }, 29, 36 + D, { u = "umber" })
c:ground(31.5, 55 + D, 15, 1.5)
local t = c:save(O .. "aseprite/ph/creature-shore-crab.aseprite", O .. "png/ph/creature-shore-crab.png")
print(GV.report(t))

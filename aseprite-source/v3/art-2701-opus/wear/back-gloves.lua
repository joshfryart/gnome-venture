-- back-gloves: Work Gloves avatar layer, back view (Opus pass, art-2701). 512x80 = 8 frames of 64x80, lined up with gnome25.
-- Thick tan leather gloves seen from behind: a flared dark-suede gauntlet cuff with cream stitches over the sleeve end,
-- a lit knuckle ridge, finger seams and rounded fingertips, and a THUMB on the inner side of each hand (toward the body),
-- parted from the hand by a dark seam so it reads at 100%. Hands follow the rig's bob and arm swing (left +arm, right -arm).
-- quirk: the left glove's index fingertip is worn through, a dot of skin shows.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local W = O.W
local MAP = {
  a = "#6e4529", b = "#a3713f", c = "#cf9c5f", d = "#e6bd80", e = "#f6d9a4",   -- tan leather
  K = "#4e2c24", L = "#7e4a2f", M = "#9e6239", N = "#be8048", S = "#f2d6a0",   -- suede cuff + stitch
  h = "#f0b98d",                                                                -- skin through the worn tip
}
local LEFT = {      -- x = hx-4 .. hx+4, y = hy-4 .. hy+2; thumb on the right (inner) side
  "NSSNSSNML",
  "LMMMMMMLK",
  ".cdddccb.",
  ".deedccb.",
  ".ddcccbac",
  ".ccccbbab",
  "..hbcbab.",
}
local RIGHT = {     -- thumb on the left (inner) side
  "NSSNSSNMK",
  "LMMMMMMLK",
  ".cdddccb.",
  ".deedccb.",
  "dadcccbb.",
  "cacccbba.",
  ".bccbcb..",
}
local frames = {}
for f = 0, 7 do
  local p = O.F[f + 1]
  local b = -p.bob
  local px = {}
  O.paint(px, LEFT, 20 - 4, 57 + b + p.arm - 4, MAP)
  O.paint(px, RIGHT, 45 - 4, 57 + b - p.arm - 4, MAP)
  local body = O.mask("back", O.BODY, f)
  frames[#frames + 1] = O.finish(px, body)
end
O.saveStrip("back-gloves", frames)

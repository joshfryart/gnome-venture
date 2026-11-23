-- pl-eggs-3-perch.lua — 36x36 perch sprite (chibi bandit pal on a small wooden perch)
-- Stage-driven: 2=BLOCK-IN 3=PERSPECTIVE 4=SHADE 5=TEXTURE 6=DETAIL 7=CRITIQUE
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-eggs-3-perch-20261120-180703/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local STAGE = 7

-- outline colours out of the sprite palette
GV.C.ol1, GV.C.ol2, GV.C.ol3 = "#2b1c26", "#2b1c26", "#241a36"
GV.C.halo = "#efddc5"   -- eye cream
GV.C.umber = "#2b1c26"  -- contours

local c = GV.canvas{ w = 36, h = 36, mode = "scene" }
c.ol, c.olx, c.cres, c.deep = 1, 0, 2, 2

-- ramps (one per material), derived from the pal's dominant colours
local R_GOLD   = GV.ramp("#c18823", { bounce = "#ab751a" })
local R_MAROON = GV.ramp("#963610", { deep = "#60100e" })
local R_BLUE   = GV.ramp("#4facda", { shade = "#3b4c71", deep = "#241a36" })
local R_PURP   = GV.ramp("#3b2a4f", { deep = "#241a36" })
local R_BOW    = GV.ramp("#4facda", { shade = "#3b4c71", deep = "#3b4c71" })
local R_WOOD   = GV.ramp("#907147", { shade = "#7a4336", deep = "#5b3a2c" })
local R_CREAM  = GV.ramp("#efddc5")
local R_NOSE   = GV.ramp("#963610")

local shaded = STAGE >= 4
local function opts(always_flat, extra)
  local o = extra or {}
  o.outline = false
  if not shaded then o.flat = true; o.gloss = false; o.contact = false
  else o.flat = always_flat or (extra and extra.flat) or false end
  return o
end

-- parts, back to front
local P = c:build{
  { "pole",  c:rect(27, 6, 28, 28), R_WOOD, opts(true) },
  { "cloth", c:rect(29, 11, 30, 16), R_CREAM, opts(true) },
  { "plank", c:rrect(7, 26, 24, 29, 1), R_WOOD, opts(false) },
  { "body",  c:rrect(9, 15, 22, 25, 3), R_MAROON, opts(false) },
  { "feetL", c:rrect(10, 24, 13, 26, 1), R_PURP, opts(true, { flat = true }) },
  { "feetR", c:rrect(17, 24, 20, 26, 1), R_PURP, opts(true, { flat = true }) },
  { "bow",   c:poly({ { 11, 16 }, { 15, 18 }, { 11, 20 } }):add(c:poly({ { 21, 16 }, { 17, 18 }, { 21, 20 } }))
                 :add(c:rrect(14, 17, 17, 19, 1)), R_BOW, opts(false, { gloss = false, contour = false, cres = 1 }) },
  { "head",  c:ellipse(15.5, 11, 7.5, 7), R_GOLD, opts(false, { gloss = { 11, 8 } }) },
  { "hat",   c:ellipse(13, 4, 2, 2):add(c:ellipse(18, 4, 2, 2))
                 :add(c:rrect(15, 4, 16, 6, 0)), R_BLUE, opts(false, { gloss = false, cres = 1, contour = false }) },
}

-- mask band clipped to the head, painted after the head
local band = c:part(c:rect(9, 9, 22, 13):clip(P.head.m), R_PURP, opts(true))
P.band = band

-- face details (px marks, not parts — parts this small contour to all-dark)
c:eye(10, 10, true); c:eye(18, 10, true)
c:px(11, 11, GV.C.halo); c:px(19, 11, GV.C.halo)         -- eye glints
-- nose: 4x2 hand-toned diagonal (light upper-left), px marks not parts
c:px(14, 15, R_NOSE.rim); c:px(15, 15, R_NOSE.rim); c:px(16, 15, R_NOSE.base); c:px(17, 15, R_NOSE.base)
c:px(14, 16, R_NOSE.base); c:px(15, 16, R_NOSE.base); c:px(16, 16, R_NOSE.shade); c:px(17, 16, R_NOSE.shade)
c:px(15, 17, "#241a36"); c:px(16, 17, "#241a36")         -- tiny mouth

-- texture: hand-placed, 1 shade step from base, follows the form
if STAGE >= 5 then
  -- plank wood grain: short horizontal streaks + tiny edge wear glints on the top edge
  c:px(11, 27, R_WOOD.shade); c:px(12, 27, R_WOOD.shade)
  c:px(18, 28, R_WOOD.shade); c:px(19, 28, R_WOOD.shade); c:px(22, 28, R_WOOD.shade)
  c:px(16, 26, R_WOOD.gloss); c:px(21, 26, R_WOOD.gloss)
  -- head: 1px base dither stepping into the shade crescent border
  c:px(12, 14, R_GOLD.base); c:px(18, 14, R_GOLD.base)
  -- cloth: 2px weave dots
  c:px(30, 14, R_CREAM.shade); c:px(30, 15, R_CREAM.rim)
end
if STAGE >= 6 then
  -- soften the hat's contact row with 2px of base gold (fix 2 from TEXTURE)
  c:px(13, 7, R_GOLD.base); c:px(17, 7, R_GOLD.base)
end
if STAGE >= 7 then
  -- gold dot beside the head gloss comma (fix 2 from CRITIQUE)
  c:px(11, 7, R_GOLD.dot)
end

-- sparkle accent
local sprk = c:mask()
for j, row in ipairs({ ".a.", "aca", ".a." }) do
  for i = 1, 3 do
    local ch = row:sub(i, i)
    if ch == "a" then c:px(4 + i - 1, 19 + j - 1, "#c18823"); sprk:set(4 + i - 1, 19 + j - 1)
    elseif ch == "c" then c:px(4 + i - 1, 19 + j - 1, "#efddc5"); sprk:set(4 + i - 1, 19 + j - 1) end
  end
end
if STAGE >= 6 then
  c:px(5, 18, "#efddc5"); c:px(5, 22, "#c18823"); sprk:set(5, 18); sprk:set(5, 22)
end

-- ground shadow ellipse
c:ground(17.5, 30.5, 8, 1, "#3b2a4f")

-- 1 px silhouette outline, drawn once at the end
local sil = c:mask()
for _, name in ipairs({ "pole", "cloth", "plank", "feetL", "feetR", "body", "bow", "head", "hat" }) do
  sil:add(P[name].m)
end
sil:add(P.band.m)
sil:add(sprk)
c:outline(sil)

local t = c:save(D .. "out/pl-eggs-3-perch.aseprite", D .. "out/pl-eggs-3-perch.png")
print(GV.report(t))

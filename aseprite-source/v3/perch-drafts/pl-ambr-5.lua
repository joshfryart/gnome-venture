-- pl-ambr-5-perch.lua : chibi amber/acorn-sprout pal on an acorn-cap perch, 36x36
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-ambr-5-perch-20261120-162008/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, ol = 1, olx = 1 }

local R_BODY  = GV.ramp("#d08546")   -- pal body orange
local R_BELLY = GV.ramp("#f7e6b6", { shade = "#d8c49a", bounce = "#e6d4ac", deep = "#c9a96e", rim = "#f8e6b8" }) -- cream, no white dot
local R_CAP   = GV.ramp("#ab7e3d")   -- acorn cap / amber
local R_LEAF  = GV.ramp("#758a5c")   -- sprout greens
local R_STEM  = GV.ramp("#7a6a44")   -- stem taupe
local R_SHADOW = { base = "#6e5b4b" }

-- soft ground shadow: a kept flat part (saved from the outline pass by 'keep')
local shadow = c:ellipse(17.5, 28.5, 9.5, 1.7)

-- cap: dome under the body, rim line y21, tapering to a rounded bottom at y27
local cap = c:poly({ {8,21}, {27,21}, {23,27}, {12,27} })
cap:add(c:rrect(12, 22, 23, 27, 2))

-- sprout behind the body: stem + two leaves (small tuft, half body width)
local stem  = c:rect(17, 4, 18, 10)
local leafR = c:ellipse(21, 5, 3.6, 2.6)
local leafL = c:ellipse(13.5, 6.5, 3.2, 2.2)

local body = c:ellipse(17.5, 17, 8, 8)          -- spans x9..26, y9..25
local drop = c:ellipse(5, 11.5, 1.6, 1.6)
drop:add(c:rect(6, 9, 6, 9))                    -- spark joins the drop's silhouette

c:build{
  { "shadow", shadow, R_SHADOW, { flat = true, gloss = false, stitch = false, contact = false, solid = false, rim = false, bounce = false } },
  { "cap",  cap,  R_CAP,  { cres = 3, deep = 0, gloss = { 10, 23 }, stitch = false, light = cap:copy():grow(1) } },
  { "stem", stem, R_STEM, { flat = true, gloss = false, stitch = false, contact = false } },
  { "leafR", leafR, R_LEAF, { cres = 2, deep = 1, gloss = { 19, 3 }, stitch = false } },
  { "leafL", leafL, R_LEAF, { cres = 2, deep = 1, gloss = { 12, 5 }, stitch = false } },
  { "body", body, R_BODY, { light = c:ellipse(17.5, 17, 9.5, 9.5), cres = 4, deep = 2, gloss = { 13, 12 }, stitch = false, contour = false } },
  { "drop", drop, R_CAP, { flat = true, gloss = false, stitch = false, contact = false, solid = false } },
}

-- body gloss (auto comma would land under the left eye): 2px comma above it
c:px(11, 10, R_BODY.gloss); c:px(12, 10, R_BODY.dot)

-- cream belly: plain marking on the body (no auto contour/crescent), hand-shaded
local belly = c:ellipse(17, 21, 5.2, 3):clip(body)
c:fill(belly, R_BELLY.base)
belly:each(function(x, y)
  if not belly:has(x + 1, y + 1) then c:px(x, y, (x - 17.5) + (y - 21) > 1 and R_BELLY.shade or R_BELLY.bounce) end
end)
c:px(15, 19, R_BELLY.rim); c:px(15, 20, R_BELLY.gloss)   -- small glint, upper-left

-- face
c:eye(11, 11); c:eye(20, 11)
c:px(17, 17, R_BODY.deep); c:px(18, 17, R_BODY.deep)     -- tiny mouth above the belly

-- amber drop detail: bright amber marble
c:px(4, 11, R_CAP.gloss); c:px(4, 12, R_CAP.dot)
c:px(6, 13, R_CAP.shade); c:px(5, 13, R_CAP.shade)
c:px(6, 9, GV.C.gold)                                     -- spark (part of the drop)

-- texture: cap cross-hatch net (1 step only, lower-right dome)
cap:each(function(x, y)
  if (x + y) % 3 == 0 and (x + y) > 27 and (x > 13 or y > 23) and c:get(x, y) == R_CAP.base then c:px(x, y, R_CAP.shade) end
end)
-- texture: rim nicks on the cap's lit upper-left arc
c:px(11, 21, R_CAP.rim); c:px(9, 21, R_CAP.rim); c:px(26, 21, R_CAP.rim)
-- texture: leaf veins following the leaf tilt
c:px(20, 5, R_LEAF.rim); c:px(21, 4, R_LEAF.rim); c:px(14, 6, R_LEAF.rim); c:px(15, 5, R_LEAF.rim)
-- texture: tone-on-tone pits on the body's lit side
c:px(21, 10, R_BODY.rim); c:px(23, 12, R_BODY.rim); c:px(12, 14, R_BODY.shade); c:px(22, 15, R_BODY.shade)
c:px(11, 20, R_BODY.shade); c:px(24, 19, R_BODY.shade)
-- texture: 1px dither where the body crescent meets the base (soften the boundary)
body:each(function(x, y)
  if c:get(x, y) == R_BODY.shade and (x + y) % 2 == 0 and c:get(x - 1, y - 1) == R_BODY.base then c:px(x, y, R_BODY.base) end
end)
-- texture: edge wear on the cap rim (a couple of lighter nicks on the lit top edge)
c:px(9, 21, R_CAP.rim); c:px(26, 21, R_CAP.rim)

local t = c:save(D .. "out/pl-ambr-5-perch.aseprite", D .. "out/pl-ambr-5-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1 and t.bw == 0)

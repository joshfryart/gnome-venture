-- banner-SA-pets.lua : Cat Fish pet shops (claude/plan-catfish-petshops.md s1), SA "Canopy Critter Co."
-- Shop banner for the Rainroot Reaches market town: "a leafy treehouse shop strung with vines, feathers and
-- friendly noises". Same format as game/assets/img/scenes/banner-*.png: 480x120 opaque, drawn on a 240x60 grid
-- in gvlib "scene" mode at out=2, no border, gold hem stitch top and bottom, umber outline on raised objects only,
-- stepped bands for the sky, a small palette (the shipped banners use 15-23 colours).
-- Focal subject: one treehouse shop on a big rainforest trunk. Its thatched roof has cat ears, its two round
-- windows glow warm like cat eyes, a pink nose and gold-thread whiskers sit over the open arched door. A fish sign
-- hangs from a bracket on the right with a toucan perched on it, an orange cat sits on the deck rail and a vine
-- ladder drops to the forest floor. Feather bunting, two distant stilt huts of the market town, hanging vines and
-- big foreground leaves frame it. Warm golden afternoon light from the upper left. No text.
-- Pass 1: colours 105 -> ~40 (4-step felt ramps), thin 1 px outlines on small/far things (2 px only on the shop),
-- bigger roof and ears, clearer door (no stripe), cat on the rail, lighter toucan, pointed leaves.
-- Run: AppRun -b --script banner-SA-pets.lua     Writes ../out/banner-SA-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
local D = "#2a1a10"
local sin = math.sin

-- felt(hex): 4-step ramp (gloss, rim, base, shade) so the banner keeps a small palette
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce, n.dot = r.shade, r.shade, r.gloss
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
local WOOD  = felt("#b07a45")
local DARKW = felt("#6a3a22", { rim = "#8a4f2a" })
local STRAW = felt("#e0a83c")
local LEAF  = felt("#4a8a3e", { gloss = "#8fb860", rim = "#6a9a4a" })
local PINK  = felt("#e46a9b")
local ORNG  = felt("#e8913a")
local TEAL  = felt("#3f8fb0")
local GLOW, GLOW2 = "#ffd77a", "#fff1c8"

local function below(f)
  local m = c:mask()
  for x = 0, W - 1 do for y = math.max(0, math.floor(f(x) + 0.5)), H - 1 do m:set(x, y) end end
  return m
end
local function thin(m) c:outline(m, { ol = 1, olx = 0 }) end
-- small raised part with a 1 px outline
local function small(m, ramp, o)
  o = o or {}; o.outline = false
  local p = c:part(m, ramp, o); thin(m); return p
end

-- 1. sky: warm golden afternoon, hard bands; sun upper left
c:bands(c:rect(0, 0, W - 1, H - 1), { "#f0b874", "#f4c486", "#f7d098", "#f9dcae" }, { dir = "v" })
c:fill(c:ellipse(46, 12, 9, 9), "#fbe6c2")
c:fill(c:ellipse(46, 12, 6, 6), GLOW2)

-- 2. far canopy (hazy), mid canopy, forest floor; each with a 1 px lit top edge
local far = below(function(x) return 27 + 3 * sin(x / 7.5) + 2 * sin(x / 3.1 + 1) end)
c:fill(far, "#a9c47a"); c:fill(far:edge():clip(c:rect(0, 0, W - 1, 40)), "#c8d77a")
local mid = below(function(x) return 39 + 3 * sin(x / 9 + 2) + 1.5 * sin(x / 4 + 0.5) end)
c:fill(mid, "#6a9a4a"); c:fill(mid:edge():clip(c:rect(0, 0, W - 1, 46)), "#8fb860")
local floor = below(function(x) return 52 + sin(x / 11) end)
c:fill(floor, "#3f6a36"); c:fill(floor:edge():clip(c:rect(0, 0, W - 1, 54)), "#4a8a3e")

-- 3. two distant stilt huts of the market town (flat, 1 px outline)
local function hut(x0, x1, top, base)
  local cx = (x0 + x1) / 2
  local stilts = c:rect(x0 + 2, base, x0 + 3, base + 9):add(c:rect(x1 - 3, base, x1 - 2, base + 9))
  c:fill(stilts, "#8a4f2a"); thin(stilts)
  small(c:rect(x0, top + 6, x1, base), WOOD, { gloss = false, flat = true })
  small(c:poly({ { x0 - 3, top + 7 }, { cx, top - 2 }, { x1 + 4, top + 7 } }), STRAW, { gloss = false, flat = true })
  c:fill(c:rect(cx - 1, top + 9, cx + 1, top + 12), GLOW)
end
hut(26, 40, 26, 40)
hut(198, 212, 24, 38)

-- 4. the great trunk (bleeds off the bottom) with root flares
local trunk = c:rect(106, 30, 134, 59)
trunk:add(c:poly({ { 97, 60 }, { 106, 47 }, { 106, 60 } })):add(c:poly({ { 134, 47 }, { 143, 60 }, { 134, 60 } }))
c:part(trunk, DARKW, { gloss = false })
c:fill(c:rect(113, 50, 114, 56):add(c:rect(125, 52, 126, 57)), "#4a2c1a")

-- 5. vine ladder from the deck on the left
local ladder = c:rect(86, 47, 87, 59):add(c:rect(94, 47, 95, 59))
for y = 50, 58, 4 do ladder:add(c:rect(86, y, 95, y + 1)) end
small(ladder, STRAW, { flat = true })

-- 6. deck + shop body
c:part(c:rrect(78, 44, 162, 48, 1), WOOD, { gloss = false })
local body = c:rrect(90, 17, 150, 44, 3)
c:part(body, WOOD, { gloss = { 93, 23 } })
for y = 37, 41, 4 do c:fill(c:rect(92, y, 148, y):clip(body:shrink(2)), "#8a4f2a") end

-- 7. thatched roof with cat ears (one part), pink inner ears, fringe
local roof = c:ellipse(120, 17, 36, 11):cut(c:rect(0, 23, W - 1, H - 1))
roof:add(c:poly({ { 86, 15 }, { 93, 2 }, { 107, 8 } })):add(c:poly({ { 133, 8 }, { 147, 2 }, { 154, 15 } }))
c:part(roof, STRAW, { gloss = { 99, 11 } })
c:fill(c:poly({ { 92, 11 }, { 94, 6 }, { 101, 9 } }), PINK.base)
c:fill(c:poly({ { 139, 9 }, { 146, 6 }, { 148, 11 } }), PINK.base)
for x = 86, 154, 3 do c:px(x, 22, STRAW.shade) end
for _, p in ipairs({ { 110, 12 }, { 118, 10 }, { 126, 11 }, { 114, 17 }, { 128, 16 }, { 104, 18 }, { 136, 18 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 2, p[2]), STRAW.shade)
end
c:seam({ { 86, 21 }, { 154, 21 } })

-- 8. cat-eye windows (warm glow), pink nose, gold-thread whiskers, open arched door
local function window(cx, cy)
  c:part(c:ellipse(cx, cy, 6, 6), DARKW, { flat = true })
  c:fill(c:ellipse(cx, cy, 4, 4), GLOW)
  c:fill(c:ellipse(cx - 1.5, cy - 1.5, 1.5, 1.5), GLOW2)
  c:fill(c:rect(cx, cy - 4, cx, cy + 4), DARKW.base)
end
window(103, 28); window(137, 28)
c:part(c:poly({ { 116, 24 }, { 125, 24 }, { 120, 29 } }), PINK, { gloss = false, outline = false })
thin(c:poly({ { 116, 24 }, { 125, 24 }, { 120, 29 } }))
-- whiskers: two cream threads each side of the nose
c:fill(c:line({ { 111, 30 }, { 98, 33 } }, 1):add(c:line({ { 111, 32 }, { 99, 36 } }, 1)), "#fbe6c2")
c:fill(c:line({ { 129, 30 }, { 142, 33 } }, 1):add(c:line({ { 129, 32 }, { 141, 36 } }, 1)), "#fbe6c2")
local doorM = c:rrect(112, 31, 128, 44, 5):cut(c:rect(0, 45, W - 1, H - 1))
c:part(doorM, DARKW, { flat = true })
local inner = c:rrect(114, 33, 126, 44, 4):cut(c:rect(0, 45, W - 1, H - 1))
c:fill(inner, "#f5b860")
c:fill(c:rect(118, 36, 122, 44), GLOW) -- warm light from inside
-- red felt curtains tied back at the sides
local cur = c:poly({ { 114, 33 }, { 119, 33 }, { 116, 39 }, { 117, 44 }, { 114, 44 } })
cur:add(c:poly({ { 121, 33 }, { 127, 33 }, { 127, 44 }, { 124, 44 }, { 125, 39 } })):clip(inner)
c:fill(cur, "#c23a4a"); c:fill(c:rect(114, 33, 126, 33):clip(inner), "#e0606a")
c:px(116, 39, "#f5cf6a"); c:px(124, 39, "#f5cf6a")

-- 9. railing (gap at the door)
local rail = c:rect(80, 39, 110, 40):add(c:rect(130, 39, 160, 40))
for x = 80, 104, 8 do rail:add(c:rect(x, 39, x + 1, 43)) end
for x = 135, 159, 8 do rail:add(c:rect(x, 39, x + 1, 43)) end
small(rail, WOOD, { flat = true })

-- 10. paper lantern (left) and fish sign on a bracket (right) with a toucan
c:fill(c:rect(80, 12, 80, 16), "#4a2c1a")
small(c:rrect(77, 16, 83, 23, 2), ORNG, { gloss = { 78, 18 } })
c:fill(c:rect(78, 19, 82, 20), GLOW)
small(c:rect(150, 18, 170, 19), DARKW, { flat = true })
c:fill(c:rect(161, 20, 161, 21), "#4a2c1a")
small(c:ellipse(161, 25, 6, 3.5):add(c:poly({ { 166, 25 }, { 171, 21 }, { 171, 30 } })), TEAL, { gloss = { 157, 23 } })
c:px(157, 25, D)
-- toucan perched on the bracket end, facing left, big orange beak
small(c:ellipse(167, 13, 3, 4), "#3e2f66", { gloss = false, flat = true })
c:fill(c:rect(164, 12, 165, 14), GLOW2)
c:px(166, 11, GLOW2); c:px(166, 12, D)
small(c:poly({ { 157, 10 }, { 164, 10 }, { 164, 14 }, { 157, 12 } }), ORNG, { flat = true })
c:px(157, 10, "#dd3a2a"); c:px(158, 10, "#dd3a2a")
c:fill(c:rect(168, 17, 169, 17), ORNG.base) -- feet

-- 11. orange cat sitting on the left rail end, against the green canopy
local catM = c:ellipse(86, 35, 4, 3.5):add(c:ellipse(86, 30, 4, 3))
catM:add(c:poly({ { 82, 30 }, { 83, 25 }, { 86, 28 } })):add(c:poly({ { 86, 28 }, { 89, 25 }, { 90, 30 } }))
local tail = c:line({ { 82, 37 }, { 79, 36 }, { 78, 33 } }, 2)
small(tail, ORNG, { flat = true })
small(catM, ORNG, { gloss = false })
c:px(84, 30, D); c:px(88, 30, D)
c:px(86, 31, PINK.base)
c:fill(c:rect(86, 26, 86, 27):add(c:rect(85, 34, 85, 35)):add(c:rect(87, 34, 87, 35)), ORNG.shade)

-- 12. feather bunting strung from the canopy to the roof ears
local function bunting(x0, y0, x1, y1, sag)
  local cols = { "#dd3a2a", "#f5cf6a", TEAL.base, "#7ab55c" }
  local i = 0
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = math.floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + 0.5)
    c:px(x, y, "#4a2c1a")
    if (x - x0) % 6 == 3 and x < x1 - 2 then
      i = i + 1
      c:paint({ "xx", "xx", "xx", ".x" }, x - 1, y + 1, { x = cols[(i - 1) % 4 + 1] })
    end
  end
end
bunting(56, 4, 89, 12, 6)
bunting(151, 12, 186, 4, 6)

-- 13. canopy fringe at the top corners and hanging vines
small(c:ellipse(10, 0, 30, 7):add(c:ellipse(40, -1, 18, 5)), LEAF, { gloss = false })
small(c:ellipse(230, 0, 30, 7):add(c:ellipse(200, -1, 18, 5)), LEAF, { gloss = false })
for _, v in ipairs({ { 14, 22 }, { 30, 14 }, { 62, 9 }, { 180, 9 }, { 212, 16 }, { 228, 24 } }) do
  c:fill(c:rect(v[1], 5, v[1] + 1, v[2]), "#3f6a36")
  for y = 9, v[2] - 1, 5 do
    local x = v[1] + (((y // 5) % 2 == 0) and 2 or -2)
    c:fill(c:rect(x, y, x + 1, y + 1), LEAF.rim)
  end
end

-- 14. foreground pointed leaves in the bottom corners
local function leaf(pts) small(c:poly(pts), LEAF, { gloss = false }) end
leaf({ { -2, 59 }, { 6, 42 }, { 22, 38 }, { 16, 50 }, { 6, 60 } })
leaf({ { 10, 60 }, { 26, 46 }, { 44, 46 }, { 32, 56 }, { 22, 60 } })
leaf({ { 241, 59 }, { 233, 42 }, { 217, 38 }, { 223, 50 }, { 233, 60 } })
leaf({ { 229, 60 }, { 213, 46 }, { 195, 46 }, { 207, 56 }, { 217, 60 } })
c:fill(c:line({ { 3, 56 }, { 18, 41 } }, 1), LEAF.shade); c:fill(c:line({ { 236, 56 }, { 221, 41 } }, 1), LEAF.shade)
c:fill(c:line({ { 16, 58 }, { 40, 47 } }, 1), LEAF.shade); c:fill(c:line({ { 223, 58 }, { 199, 47 } }, 1), LEAF.shade)

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-SA-pets.aseprite", OUT .. "banner-SA-pets.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)

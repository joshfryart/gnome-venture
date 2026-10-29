-- banner-SA-pets.lua : Cat Fish pet shops (claude/plan-catfish-petshops.md s1), SA "Canopy Critter Co."
-- Shop banner for the Rainroot Reaches market town: "a leafy treehouse shop strung with vines, feathers and
-- friendly noises". Same format as game/assets/img/scenes/banner-*.png: 480x120 opaque, drawn on a 240x60 grid
-- in gvlib "scene" mode at out=2, no border, gold hem stitch top and bottom, 3-tone umber outline on raised
-- objects only, stepped bands for the sky. Focal subject: one treehouse shop on a big rainforest trunk whose
-- thatched roof has cat ears; its two round windows glow warm like cat eyes, a pink nose and stitched-thread
-- whiskers sit over the open door; a fish sign hangs on the right, a toucan perches on its bracket, an orange cat
-- sits on the deck and a vine ladder drops to the forest floor. Feather bunting, two distant stilt huts of the
-- market town, hanging vines, big foreground leaves and a red bromeliad frame it. Warm golden afternoon light
-- from the upper left. No text.
-- Run: AppRun -b --script banner-SA-pets.lua     Writes ../out/banner-SA-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
local D = "#2a1a10"
local sin = math.sin

local function below(f)
  local m = c:mask()
  for x = 0, W - 1 do for y = math.max(0, math.floor(f(x) + 0.5)), H - 1 do m:set(x, y) end end
  return m
end
local function thin(m) c:outline(m, { ol = 1, olx = 0 }) end

-- 1. sky: warm golden afternoon, hard bands
c:bands(c:rect(0, 0, W - 1, H - 1), { "#f0b874", "#f4c486", "#f7d098", "#f9dcae", "#fbe6c2" }, { dir = "v" })
-- sun, upper left, in stepped rings
c:fill(c:ellipse(46, 12, 9, 9), "#fbe6c2")
c:fill(c:ellipse(46, 12, 6, 6), "#fff1c8")

-- 2. far canopy (hazy), then mid canopy (darker), each with a 1 px lit top edge
local far = below(function(x) return 27 + 3 * sin(x / 7.5) + 2 * sin(x / 3.1 + 1) end)
c:fill(far, "#a9c47a"); c:fill(far:edge():clip(c:rect(0, 0, W - 1, 40)), "#c8d77a")
local mid = below(function(x) return 39 + 3 * sin(x / 9 + 2) + 1.5 * sin(x / 4 + 0.5) end)
c:fill(mid, "#6a9a4a"); c:fill(mid:edge():clip(c:rect(0, 0, W - 1, 46)), "#8fb860")
local floor = below(function(x) return 52 + sin(x / 11) end)
c:fill(floor, "#3f6a36"); c:fill(floor:edge():clip(c:rect(0, 0, W - 1, 54)), "#5a8a40")

-- 3. two distant stilt huts of the market town (thin outline, muted)
local function hut(x0, x1, top, base)
  local cx = (x0 + x1) / 2
  local stilts = c:rect(x0 + 2, base, x0 + 3, base + 8):add(c:rect(x1 - 3, base, x1 - 2, base + 8))
  c:fill(stilts, "#7a5a3a"); thin(stilts)
  local body = c:rect(x0, top + 6, x1, base)
  c:part(body, "#b8906a", { outline = false, gloss = false }); thin(body)
  local roof = c:poly({ { x0 - 3, top + 7 }, { cx, top - 2 }, { x1 + 4, top + 7 } })
  c:part(roof, "#d0a860", { outline = false, gloss = false }); thin(roof)
  c:fill(c:rect(cx - 1, top + 9, cx + 1, top + 12), "#f5cf6a")
end
hut(26, 40, 26, 40)
hut(196, 210, 24, 38)

-- 4. the great trunk (bleeds off the bottom), behind the shop, with root flares
local trunk = c:rect(106, 30, 134, 59)
trunk:add(c:poly({ { 98, 60 }, { 106, 48 }, { 106, 60 } })):add(c:poly({ { 134, 48 }, { 142, 60 }, { 134, 60 } }))
c:part(trunk, "#8a5a34", { gloss = false })
c:fill(c:rect(113, 50, 114, 57):add(c:rect(125, 52, 126, 58)), "#5e2f1e")

-- 5. vine ladder hanging from the deck on the left (behind the deck)
local ropes = c:rect(88, 47, 89, 59):add(c:rect(96, 47, 97, 59))
local rungs = c:mask()
for y = 50, 58, 4 do rungs:add(c:rect(88, y, 97, y + 1)) end
c:part(ropes:add(rungs), "#9a7a3a", { flat = true })

-- 6. deck + shop body
local deck = c:rrect(80, 44, 160, 48, 1)
c:part(deck, "#c08a50", { gloss = false })
c:fill(c:rect(80, 46, 160, 46):clip(deck:shrink(1)), "#a8682f")
local body = c:rrect(92, 17, 148, 44, 3)
c:part(body, "#b07a45", { gloss = { 95, 23 } })
for y = 30, 42, 6 do c:fill(c:rect(93, y, 147, y):clip(body:shrink(2)), "#8a4f2a") end

-- 7. thatched roof with cat ears
local roof = c:ellipse(120, 17, 33, 10):cut(c:rect(0, 23, W - 1, H - 1))
local earL = c:poly({ { 91, 12 }, { 97, 3 }, { 108, 9 } })
local earR = c:poly({ { 132, 9 }, { 143, 3 }, { 149, 12 } })
roof:add(earL):add(earR)
c:part(roof, "#e0a83c", { gloss = { 100, 11 } })
c:fill(c:poly({ { 96, 10 }, { 98, 6 }, { 103, 9 } }), "#e46a9b")
c:fill(c:poly({ { 137, 9 }, { 142, 6 }, { 144, 10 } }), "#e46a9b")
-- thatch fringe and straw strokes
for x = 89, 151, 3 do c:px(x, 22, "#b8661a") end
for _, p in ipairs({ { 108, 12 }, { 116, 10 }, { 124, 10 }, { 132, 12 }, { 112, 17 }, { 128, 17 }, { 120, 14 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 2, p[2]), "#b8661a")
end
c:seam({ { 88, 21 }, { 152, 21 } })

-- 8. cat-eye windows (warm glow), nose, stitched whiskers, open door
local function window(cx, cy)
  local fr = c:ellipse(cx, cy, 6, 6)
  c:part(fr, "#6a3a22", { gloss = false, flat = true })
  local gl = c:ellipse(cx, cy, 4, 4)
  c:fill(gl, "#ffd77a"); c:fill(c:ellipse(cx - 1, cy - 1, 2, 2), "#fff1c8")
  c:fill(c:rect(cx, cy - 4, cx, cy + 4):add(c:rect(cx - 4, cy, cx + 4, cy)), "#6a3a22")
end
window(104, 29); window(136, 29)
local nose = c:poly({ { 116, 25 }, { 125, 25 }, { 120, 30 } })
c:part(nose, "#e46a9b", { gloss = false })
c:seam({ { 110, 30 }, { 98, 37 } }, { free = true })
c:seam({ { 130, 30 }, { 142, 37 } }, { free = true })
local door = c:rrect(113, 32, 127, 44, 6):cut(c:rect(0, 45, W - 1, H - 1))
c:part(door, "#5e2f1e", { gloss = false, flat = true })
c:fill(c:rrect(115, 34, 125, 44, 5):cut(c:rect(0, 45, W - 1, H - 1)), "#f5b860")
c:fill(c:rect(115, 38, 125, 39):clip(c:rrect(115, 34, 125, 44, 5)), "#e8a317")

-- 9. railing (gap at the door)
local rail = c:rect(82, 39, 110, 40):add(c:rect(130, 39, 158, 40))
for x = 82, 106, 8 do rail:add(c:rect(x, 39, x + 1, 43)) end
for x = 133, 157, 8 do rail:add(c:rect(x, 39, x + 1, 43)) end
c:part(rail, "#9a6a3a", { flat = true })

-- 10. paper lantern (left) and fish sign on a bracket (right) with a toucan
c:fill(c:rect(86, 20, 86, 25), "#4a2c1a")
local lantern = c:rrect(83, 25, 89, 32, 2)
c:part(lantern, "#f08a24", { gloss = { 84, 27 } })
c:fill(c:rect(84, 28, 88, 28), "#ffd77a")
local bracket = c:rect(148, 19, 168, 20)
c:part(bracket, "#6a3a22", { flat = true })
c:fill(c:rect(160, 21, 160, 22), "#4a2c1a")
local fish = c:ellipse(160, 26, 6, 3.5):add(c:poly({ { 165, 26 }, { 170, 22 }, { 170, 31 } }))
c:part(fish, "#3f8fb0", { gloss = { 156, 24 } })
c:px(156, 26, D)
-- toucan on the bracket end
local tbody = c:ellipse(165, 14, 3, 4)
c:part(tbody, "#3e2f66", { gloss = false })
c:fill(c:rect(163, 13, 164, 15), "#fff1c8")
local beak = c:poly({ { 160, 11 }, { 165, 11 }, { 165, 14 }, { 160, 13 } })
c:part(beak, "#f08a24", { flat = true })
c:px(160, 12, "#dd3a2a")
c:px(165, 11, "#fff1c8")

-- 11. orange cat sitting on the deck, right of the door
local cat = c:ellipse(141, 40, 4, 3.5):add(c:ellipse(141, 35, 3.5, 3))
cat:add(c:poly({ { 138, 34 }, { 138, 30 }, { 141, 33 } })):add(c:poly({ { 141, 33 }, { 144, 30 }, { 144, 34 } }))
local tail = c:line({ { 145, 42 }, { 147, 40 }, { 147, 37 } }, 2)
c:part(tail, "#e8913a", { flat = true })
c:part(cat, "#e8913a", { gloss = false })
c:px(140, 35, D); c:px(142, 35, D)
c:fill(c:rect(141, 31, 141, 32), "#b8661a")

-- 12. feather bunting strung from the side trees to the roof ears
local function bunting(x0, y0, x1, y1, sag)
  local cols = { "#dd3a2a", "#f5cf6a", "#3f8fb0", "#7ab55c" }
  local i = 0
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = math.floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + 0.5)
    c:px(x, y, "#4a2c1a")
    if (x - x0) % 6 == 3 and x < x1 - 2 then
      i = i + 1
      local col = cols[(i - 1) % 4 + 1]
      c:paint({ "xx", "xx", "xx", ".x" }, x - 1, y + 1, { x = col })
    end
  end
end
bunting(56, 4, 94, 13, 6)
bunting(146, 13, 188, 4, 6)

-- 13. canopy fringe at the top corners and hanging vines
local crownL = c:ellipse(10, 0, 30, 7):add(c:ellipse(40, -1, 18, 5))
local crownR = c:ellipse(230, 0, 30, 7):add(c:ellipse(200, -1, 18, 5))
c:part(crownL, "#4f8a3e", { gloss = false })
c:part(crownR, "#4f8a3e", { gloss = false })
for _, v in ipairs({ { 14, 22 }, { 30, 14 }, { 62, 8 }, { 178, 8 }, { 212, 16 }, { 228, 24 } }) do
  local vm = c:rect(v[1], 4, v[1] + 1, v[2])
  c:fill(vm, "#3f7a3a")
  for y = 8, v[2] - 1, 5 do c:fill(c:rect(v[1] + ((y // 5) % 2 == 0 and 2 or -2), y, v[1] + ((y // 5) % 2 == 0 and 3 or -1), y + 1), "#6a9a4a") end
end

-- 14. foreground leaves and a red bromeliad
local leafL = c:ellipse(12, 52, 16, 8):add(c:ellipse(34, 57, 12, 5))
local leafR = c:ellipse(228, 51, 16, 8):add(c:ellipse(206, 57, 12, 5))
c:part(leafL, "#4a8a3e", { gloss = { 6, 47 } })
c:part(leafR, "#4a8a3e", { gloss = { 220, 46 } })
c:fill(c:line({ { 0, 53 }, { 26, 52 } }, 1):clip(leafL), "#2f5a2a")
c:fill(c:line({ { 214, 52 }, { 239, 52 } }, 1):clip(leafR), "#2f5a2a")
local brom = c:poly({ { 196, 52 }, { 199, 42 }, { 202, 50 }, { 205, 40 }, { 208, 50 }, { 211, 43 }, { 213, 52 } })
c:part(brom, "#dd3a2a", { gloss = false })
c:fill(c:rect(203, 46, 206, 49), "#f5cf6a")

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-SA-pets.aseprite", OUT .. "banner-SA-pets.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)

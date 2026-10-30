-- banner-OC-pets.lua : Cat Fish pet shops (claude/plan-catfish-petshops.md s1), OC "Reef & Purr"
-- Shop banner for the Coralscatter market town (Oceania). Same format as game/assets/img/scenes/banner-*.png:
-- 480x120 opaque, drawn on a 240x60 grid in gvlib "scene" mode at out=2, no border, gold hem stitch top and
-- bottom, umber outline on raised objects only, stepped bands for sky and lagoon, a small palette.
-- Focal subject: one open-sided round fale on a white-sand islet in a turquoise lagoon. Its domed thatch roof has
-- cat ears, two brass portholes glow warm like cat eyes over a pink cowrie-shell nose and cream whiskers, and a
-- band of brown-and-cream tapa cloth hangs under the eave. Inside, a warm-lit counter with yarn and fish, and a
-- tabby on it. A carved pole on the left carries a fish sign topped with a shell; an outrigger canoe with a
-- crab-claw sail is moored on the right with a white cat asleep in it. Warm sunset light from the upper left,
-- a leaning palm with a frangipani garland, distant islands and coral heads in the shallows. No text.
-- Pass 1: palette 75 -> 30 (hand ramps), roof raised 2 px so the interior shows, darker back wall, tabby
-- in front of the tapa hem, canoe cat moved off the sail, branching coral. Pass 2: sea turtle in the shallows.
-- Run: AppRun -b --script banner-OC-pets.lua     Writes ../out/banner-OC-pets.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local W, H = 240, 60
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
local sin = math.sin

---------------------------------------------------------------- palette (<= 30 colours, shared by every part)
-- R(base, shade, rim, gloss): hand ramp from palette entries only (deep/bounce = shade, dot = gloss)
local function R(base, shade, rim, gloss)
  return { base = base, shade = shade, deep = shade, bounce = shade, rim = rim, gloss = gloss or rim, dot = gloss or rim }
end
local O2 = "#4a2c1a"
local CREAM, GLOW = "#fff1c8", "#ffd77a"
local SKY1, SKY2, SKY3 = "#f2a07e", "#f5b28c", "#f9d4ae"
local SEA1, SEA2, SEA3, SEA4 = "#2f7fa8", "#3f9fb8", "#6cc8c6", "#9fe0d0"
local WOOD  = R("#b07a45", "#8a4f2a", "#d9a660", "#f0d49a")
local DARKW = R("#6a3a22", O2, "#8a4f2a")
local STRAW = R("#e0a83c", "#b8782a", "#f5cf6a", CREAM)
local SAND  = R("#f0d49a", "#d9a660", CREAM)
local LEAF  = R("#4a8a3e", "#2f6a3a", "#8fb860")
local PINK  = R("#e46a9b", "#b8466e", "#f7b8cf")
local ORNG  = R("#e8913a", "#b8661a", "#f5cf6a")
local TEAL  = R(SEA2, SEA1, SEA3, SEA4)
local BRASS = R("#e8913a", "#b8661a", GLOW)
local RED = "#c23a4a"
local TAPA = DARKW.base
local D = "#2a1a10"
local function thin(m) c:outline(m, { ol = 1, olx = 0 }) end
local function small(m, ramp, o)
  o = o or {}; o.outline = false
  local p = c:part(m, ramp, o); thin(m); return p
end

-- 1. sky: warm coral sunset in hard bands; low sun upper left
c:bands(c:rect(0, 0, W - 1, 27), { SKY1, SKY2, SKY3 }, { dir = "v" })
c:fill(c:ellipse(52, 13, 7, 7), GLOW)
c:fill(c:ellipse(51, 12, 5, 5), CREAM)
c:fill(c:rrect(150, 6, 176, 7, 1):add(c:rrect(158, 4, 170, 5, 1)), SKY3)
c:fill(c:rrect(196, 13, 214, 14, 1), SKY3)

-- 2. sea: deep horizon to turquoise lagoon, hard bands; sun path and sparkles
c:bands(c:rect(0, 28, W - 1, H - 1), { SEA1, SEA2, SEA3 }, { dir = "v" })
for _, p in ipairs({ { 46, 29, 12 }, { 49, 31, 6 }, { 44, 33, 8 }, { 50, 35, 5 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + p[3] - 1, p[2]), SKY3)
end
for _, p in ipairs({ { 76, 31 }, { 170, 30 }, { 222, 33 }, { 8, 40 }, { 226, 44 }, { 30, 44 }, { 212, 39 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 3, p[2]), SEA4)
end

-- 3. distant islands with tiny palms (flat)
local function isle(cx, w, palm)
  local m = c:ellipse(cx, 28, w, 3):clip(c:rect(0, 0, W - 1, 28))
  c:fill(m, LEAF.base); c:fill(m:edge():clip(c:rect(0, 0, W - 1, 26)), LEAF.rim)
  if palm then
    local tx = cx - 2
    c:fill(c:rect(tx, 22, tx, 26), LEAF.shade)
    c:paint({ "xx.xx", "x.x.x" }, tx - 2, 21, { x = LEAF.shade })
  end
end
isle(92, 10, false); isle(206, 14, true); isle(229, 6, true)

-- 4. shallows ring and the sand islet
c:fill(c:ellipse(120, 52, 72, 9), SEA4)
local islet = c:ellipse(120, 52, 62, 7)
c:part(islet, SAND, { gloss = false, outline = false }); thin(islet)

-- 5. carved pole + fish sign on the left of the fale
small(c:rect(66, 22, 68, 50), DARKW, { flat = true })
c:fill(c:rect(66, 30, 68, 30):add(c:rect(66, 36, 68, 36)):add(c:rect(66, 42, 68, 42)), O2)
small(c:ellipse(67, 20, 3, 2.5), PINK, { flat = true }) -- cowrie shell cap
c:px(67, 20, PINK.shade); c:px(66, 19, CREAM)
small(c:rect(54, 25, 65, 26), DARKW, { flat = true })
c:fill(c:rect(58, 27, 58, 28), O2)
small(c:ellipse(58, 32, 6, 3.5):add(c:poly({ { 62, 32 }, { 67, 28 }, { 67, 37 } })), TEAL, { gloss = { 54, 30 } })
c:px(54, 32, D)

-- 6. fale: stone-and-wood platform, open interior, counter, tabby, posts
c:part(c:rrect(80, 42, 160, 47, 1), WOOD, { gloss = false })
local inside = c:rect(84, 29, 156, 42)
c:fill(inside, WOOD.shade)
c:fill(c:rect(84, 29, 156, 35), DARKW.base)
c:fill(c:ellipse(120, 42, 30, 4):clip(inside), STRAW.base)
c:fill(c:ellipse(124, 42, 12, 2):clip(inside), GLOW)
-- back shelf with yarn balls
c:fill(c:rect(90, 35, 150, 35), O2)
for _, b in ipairs({ { 93, 33, PINK.base }, { 99, 33, SEA2 }, { 142, 33, STRAW.rim }, { 148, 33, LEAF.rim } }) do
  c:fill(c:ellipse(b[1], b[2], 2, 2), b[3]); c:px(b[1] - 1, b[2] - 1, CREAM)
end
-- counter with a tapa front
local counter = c:rect(102, 39, 138, 42)
c:part(counter, DARKW, { flat = true })
for x = 104, 136, 4 do c:paint({ "xxx", ".x." }, x, 40, { x = CREAM }) end
-- a fish on a plate beside the tabby
small(c:ellipse(127, 36, 4, 1.5):add(c:poly({ { 130, 36 }, { 133, 34 }, { 133, 38 } })), TEAL, { flat = true })
c:px(124, 36, D)
c:fill(c:rect(121, 38, 135, 38), CREAM)
-- posts (in front of the interior)
local posts = c:mask()
for _, x in ipairs({ 84, 97, 142, 155 }) do posts:add(c:rect(x, 29, x + 1, 42)) end
small(posts, WOOD, { flat = true })

-- 7. domed thatch roof with cat ears
local roof = c:ellipse(120, 25, 43, 19):cut(c:rect(0, 26, W - 1, H - 1))
roof:add(c:poly({ { 85, 13 }, { 92, 2 }, { 105, 8 } })):add(c:poly({ { 135, 8 }, { 148, 2 }, { 155, 13 } }))
c:part(roof, STRAW, { gloss = { 99, 10 } })
c:fill(c:poly({ { 91, 9 }, { 93, 5 }, { 99, 8 } }), PINK.base)
c:fill(c:poly({ { 141, 8 }, { 147, 5 }, { 149, 9 } }), PINK.base)
for _, p in ipairs({ { 112, 9 }, { 126, 8 }, { 119, 11 }, { 95, 17 }, { 143, 17 }, { 103, 22 }, { 135, 22 }, { 88, 21 }, { 150, 21 }, { 113, 15 }, { 125, 15 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 2, p[2]), STRAW.shade)
end
c:seam({ { 79, 24 }, { 161, 24 } })
-- tapa band under the eave: brown felt with cream triangles
local tapa = c:rect(78, 25, 162, 28)
c:fill(tapa, TAPA)
for x = 79, 160, 4 do c:paint({ "xxx", ".x." }, x, 26, { x = CREAM }) end
thin(tapa)

-- 8. brass porthole eyes, cowrie nose, whiskers
local function port(cx, cy)
  small(c:ellipse(cx, cy, 6, 6), BRASS, { flat = true })
  c:fill(c:ellipse(cx, cy, 4, 4), GLOW)
  c:fill(c:ellipse(cx - 1.5, cy - 1.5, 1.5, 1.5), CREAM)
  c:fill(c:rect(cx, cy - 3, cx, cy + 3), WOOD.shade)
end
port(106, 15); port(134, 15)
local nose = c:ellipse(120, 19, 3, 2.5)
small(nose, PINK, { flat = true })
c:px(120, 20, PINK.shade); c:px(120, 18, CREAM)
c:fill(c:line({ { 115, 19 }, { 101, 22 } }, 1):add(c:line({ { 125, 19 }, { 139, 22 } }, 1)), CREAM)

-- tabby sitting on the counter, facing out (drawn last so its ears overlap the tapa hem)
local tab = c:ellipse(112, 37, 4.5, 2.5):add(c:ellipse(112, 34, 4, 3))
tab:add(c:poly({ { 107, 34 }, { 108, 28 }, { 112, 32 } })):add(c:poly({ { 112, 32 }, { 116, 28 }, { 117, 34 } }))
small(c:line({ { 116, 38 }, { 119, 37 }, { 120, 34 } }, 2), ORNG, { flat = true })
small(tab, ORNG, { gloss = false })
c:px(110, 34, D); c:px(114, 34, D); c:px(112, 35, PINK.base)
c:fill(c:rect(112, 31, 112, 32):add(c:rect(111, 37, 111, 38)):add(c:rect(113, 37, 113, 38)), ORNG.shade)
c:px(109, 31, PINK.base); c:px(115, 31, PINK.base)

-- 9. outrigger canoe with crab-claw sail on the right
small(c:rect(180, 49, 181, 54):add(c:rect(198, 49, 199, 54)), WOOD, { flat = true })
small(c:rrect(172, 54, 206, 55, 1), DARKW, { flat = true })
small(c:rect(189, 18, 190, 45), DARKW, { flat = true })
local sail = c:poly({ { 188, 44 }, { 172, 12 }, { 181, 18 }, { 189, 21 }, { 197, 15 }, { 206, 9 }, { 192, 44 } })
small(sail, SAND, { gloss = false })
c:fill(c:line({ { 177, 21 }, { 189, 38 } }, 1):add(c:line({ { 201, 19 }, { 191, 38 } }, 1)), RED)
c:part(c:poly({ { 166, 45 }, { 214, 45 }, { 210, 50 }, { 172, 50 } }), DARKW, { gloss = { 170, 46 } })
c:fill(c:rect(170, 47, 210, 47), CREAM)
-- sleeping cream cat in the canoe
local wcat = c:ellipse(180, 43, 5, 2.5):add(c:ellipse(175, 42, 3, 2.5))
wcat:add(c:poly({ { 172, 41 }, { 173, 38 }, { 175, 40 } })):add(c:poly({ { 175, 40 }, { 177, 38 }, { 178, 41 } }))
small(wcat, SAND, { gloss = false })
c:fill(c:rect(173, 42, 174, 42):add(c:rect(176, 42, 177, 42)), D)
c:px(175, 43, PINK.base)
c:fill(c:rect(184, 41, 185, 42), WOOD.rim)
-- mooring rope to the right post
c:fill(c:line({ { 157, 40 }, { 162, 43 }, { 167, 45 } }, 1), SAND.shade)

-- 10. leaning palm on the left
small(c:line({ { 10, 60 }, { 14, 46 }, { 19, 32 }, { 24, 20 } }, 3), WOOD, { flat = true })
for y = 24, 56, 5 do local x = math.floor(10 + (60 - y) * 0.36) c:fill(c:rect(x, y, x + 2, y), WOOD.shade) end
local fronds = c:poly({ { 24, 18 }, { 8, 15 }, { 0, 22 }, { 12, 19 } })
fronds:add(c:poly({ { 24, 18 }, { 38, 14 }, { 47, 21 }, { 36, 19 } }))
fronds:add(c:poly({ { 24, 18 }, { 18, 6 }, { 6, 4 }, { 18, 11 } }))
fronds:add(c:poly({ { 24, 18 }, { 30, 5 }, { 42, 6 }, { 30, 11 } }))
fronds:add(c:poly({ { 24, 18 }, { 32, 23 }, { 35, 31 }, { 27, 23 } }))
small(fronds, LEAF, { gloss = false })
c:fill(c:ellipse(24, 19, 2, 2), WOOD.shade)
-- frangipani garland: palm -> pole -> roof ear
local function garland(x0, y0, x1, y1, sag)
  local cols = { CREAM, PINK.base, CREAM }
  local i = 0
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = math.floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + 0.5)
    c:px(x, y, LEAF.shade)
    if (x - x0) % 6 == 3 and x < x1 - 2 then
      i = i + 1
      c:paint({ ".x.", "xyx", ".x." }, x - 1, y, { x = cols[(i - 1) % 3 + 1], y = STRAW.rim })
    end
  end
end
garland(27, 20, 64, 19, 5)
garland(70, 19, 86, 12, 3)
garland(154, 12, 188, 21, 5)

-- 11. branching coral heads in the foreground shallows
local function coral(x, y, ramp, hs)
  local m = c:ellipse(x, y + 1, #hs * 1.5 + 1, 1.5)
  for i, h in ipairs(hs) do
    local fx = x - #hs * 1.5 + (i - 1) * 3
    m:add(c:rrect(math.floor(fx), y - h, math.floor(fx) + 1, y, 1))
  end
  small(m, ramp, { flat = true })
end
coral(38, 58, PINK, { 4, 6, 3, 5 }); coral(50, 59, ORNG, { 3, 5, 2 }); coral(88, 59, ORNG, { 2, 4 })
coral(152, 59, PINK, { 3, 5 }); coral(222, 58, PINK, { 5, 3, 6, 4 }); coral(233, 59, ORNG, { 4, 2 })
-- a little green sea turtle paddling in the shallows (a nod to the Shellback captain)
small(c:rect(40, 47, 41, 48):add(c:rect(40, 52, 41, 53)):add(c:rect(50, 47, 51, 48)):add(c:rect(50, 52, 51, 53)), LEAF, { flat = true })
small(c:ellipse(53, 50, 2, 1.5), SAND, { flat = true })
small(c:ellipse(46, 50, 5, 3), LEAF, { gloss = false })
c:fill(c:rect(45, 49, 47, 49):add(c:rect(44, 51, 44, 51)):add(c:rect(48, 51, 48, 51)), LEAF.rim)
c:px(54, 49, D)
-- palm frond reaching in from the top right corner
small(c:poly({ { 241, -1 }, { 214, 5 }, { 204, 12 }, { 222, 8 }, { 241, 7 } }), LEAF, { gloss = false })

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-OC-pets.aseprite", OUT .. "banner-OC-pets.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)

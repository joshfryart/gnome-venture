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
-- Run: AppRun -b --script banner-OC-pets.lua     Writes ../out/banner-OC-pets.png + .aseprite
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
local SAND  = felt("#f0d49a", { shade = "#d9b27a" })
local LEAF  = felt("#4a8a3e", { gloss = "#8fb860", rim = "#6a9a4a" })
local PINK  = felt("#e46a9b")
local ORNG  = felt("#e8913a")
local TEAL  = felt("#3f8fb0")
local BRASS = felt("#e8a33a", { rim = "#f5cf6a" })
local CREAM = "#fbe6c2"
local GLOW, GLOW2 = "#ffd77a", "#fff1c8"
local TAPA = "#7a3e22"

local function thin(m) c:outline(m, { ol = 1, olx = 0 }) end
local function small(m, ramp, o)
  o = o or {}; o.outline = false
  local p = c:part(m, ramp, o); thin(m); return p
end

-- 1. sky: warm coral sunset in hard bands; low sun upper left sinking into the sea
c:bands(c:rect(0, 0, W - 1, 27), { "#f2a07e", "#f5b28c", "#f8c49c", "#f9d4ae" }, { dir = "v" })
c:fill(c:ellipse(40, 24, 9, 9):clip(c:rect(0, 0, W - 1, 27)), "#fbe6c2")
c:fill(c:ellipse(40, 24, 6, 6):clip(c:rect(0, 0, W - 1, 27)), GLOW2)
-- two soft cloud bars
c:fill(c:rrect(150, 6, 176, 8, 1):add(c:rrect(158, 4, 170, 6, 1)), "#fbd9c0")
c:fill(c:rrect(60, 9, 80, 10, 1), "#fbd9c0")

-- 2. sea: deep horizon to turquoise lagoon, hard bands; sun path glints
c:bands(c:rect(0, 28, W - 1, H - 1), { "#2f7fa8", "#3f9fb8", "#4fb3c0", "#6cc8c6" }, { dir = "v" })
c:fill(c:rect(0, 28, W - 1, 28), "#4f9fc0")
for i, p in ipairs({ { 34, 30, 12 }, { 37, 32, 6 }, { 30, 34, 8 }, { 40, 36, 5 }, { 33, 39, 4 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + p[3] - 1, p[2]), "#f9d4ae")
end
for _, p in ipairs({ { 70, 33 }, { 172, 31 }, { 214, 35 }, { 12, 44 }, { 60, 41 }, { 226, 46 }, { 180, 38 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 3, p[2]), "#8fdcd2")
end

-- 3. distant islands with tiny palms (flat)
local function isle(cx, w)
  local m = c:ellipse(cx, 28, w, 3):clip(c:rect(0, 0, W - 1, 28))
  c:fill(m, "#5d8f6a"); c:fill(m:edge():clip(c:rect(0, 0, W - 1, 26)), "#7aa872")
  local tx = cx - 2
  c:fill(c:line({ { tx, 27 }, { tx + 1, 22 } }, 1), "#4a6a4a")
  c:paint({ "x...x", ".xxx.", "x.x.x" }, tx - 1, 20, { x = "#4a6a4a" })
end
isle(14, 12); isle(206, 14); isle(226, 6)

-- 4. shallows ring and the sand islet
c:fill(c:ellipse(120, 52, 70, 9), "#9fe0d0")
c:part(c:ellipse(120, 52, 60, 7), SAND, { gloss = false, outline = false })
thin(c:ellipse(120, 52, 60, 7))
c:fill(c:rect(66, 54, 70, 54):add(c:rect(160, 55, 166, 55)), SAND.rim)

-- 5. carved pole + fish sign on the left
local pole = c:rect(66, 22, 68, 50)
small(pole, DARKW, { flat = true })
c:fill(c:rect(66, 28, 68, 28):add(c:rect(66, 34, 68, 34)), "#4a2c1a")
small(c:ellipse(67, 20, 3, 2.5), PINK, { gloss = false, flat = true }) -- cowrie shell cap
c:px(67, 20, "#f7b8cf")
small(c:rect(56, 25, 66, 26), DARKW, { flat = true })
c:fill(c:rect(59, 27, 59, 28), "#4a2c1a")
small(c:ellipse(59, 32, 6, 3.5):add(c:poly({ { 63, 32 }, { 68, 28 }, { 68, 37 } })), TEAL, { gloss = { 55, 30 } })
c:px(55, 32, D)

-- 6. fale: platform, open interior, posts, counter
c:part(c:rrect(80, 42, 160, 47, 1), WOOD, { gloss = false })
local inside = c:rect(84, 29, 156, 42)
c:fill(inside, "#c97a3a")
c:fill(c:rect(84, 29, 156, 33), "#9a5228")
c:fill(c:ellipse(120, 38, 24, 6):clip(inside), "#f5b860")
c:fill(c:ellipse(120, 38, 14, 4):clip(inside), GLOW)
-- back shelf with yarn balls and a fish
c:fill(c:rect(92, 35, 148, 35), "#7a3e22")
for _, b in ipairs({ { 95, 33, "#e46a9b" }, { 101, 33, "#3f8fb0" }, { 141, 33, "#f5cf6a" }, { 147, 33, "#7ab55c" } }) do
  c:fill(c:ellipse(b[1], b[2], 2, 2), b[3]); c:px(b[1] - 1, b[2] - 1, GLOW2)
end
-- counter with a tapa front
local counter = c:rect(104, 37, 136, 42)
c:part(counter, DARKW, { flat = true })
for x = 106, 134, 4 do c:paint({ "x.", "xx" }, x, 39, { x = CREAM }) end
-- tabby on the counter
local tab = c:ellipse(124, 33, 4, 3):add(c:ellipse(124, 29, 3.5, 3))
tab:add(c:poly({ { 120, 29 }, { 121, 24 }, { 124, 27 } })):add(c:poly({ { 124, 27 }, { 127, 24 }, { 128, 29 } }))
small(c:line({ { 128, 35 }, { 131, 34 }, { 132, 31 } }, 2), ORNG, { flat = true })
small(tab, ORNG, { gloss = false })
c:px(122, 29, D); c:px(126, 29, D); c:px(124, 30, PINK.base)
c:fill(c:rect(124, 25, 124, 26):add(c:rect(123, 33, 123, 34)):add(c:rect(125, 33, 125, 34)), ORNG.shade)
-- posts (in front of the interior)
local posts = c:mask()
for _, x in ipairs({ 84, 96, 143, 155 }) do posts:add(c:rect(x, 30, x + 1, 42)) end
small(posts, WOOD, { flat = true })

-- 7. domed thatch roof with cat ears
local roof = c:ellipse(120, 31, 43, 21):cut(c:rect(0, 32, W - 1, H - 1))
roof:add(c:poly({ { 85, 18 }, { 91, 3 }, { 105, 12 } })):add(c:poly({ { 135, 12 }, { 149, 3 }, { 155, 18 } }))
c:part(roof, STRAW, { gloss = { 98, 15 } })
c:fill(c:poly({ { 90, 12 }, { 92, 7 }, { 99, 11 } }), PINK.base)
c:fill(c:poly({ { 141, 11 }, { 148, 7 }, { 150, 12 } }), PINK.base)
for _, p in ipairs({ { 112, 14 }, { 126, 13 }, { 118, 12 }, { 96, 22 }, { 144, 22 }, { 104, 27 }, { 136, 27 }, { 88, 27 }, { 150, 26 } }) do
  c:fill(c:rect(p[1], p[2], p[1] + 2, p[2]), STRAW.shade)
end
-- tapa band under the eave: brown felt with cream triangles
local tapa = c:rect(79, 30, 161, 33)
c:fill(tapa, TAPA)
for x = 80, 160, 4 do c:paint({ "xxx", ".x." }, x, 31, { x = CREAM }) end
thin(tapa)
c:seam({ { 80, 29 }, { 160, 29 } })

-- 8. brass porthole eyes, cowrie nose, whiskers
local function port(cx, cy)
  small(c:ellipse(cx, cy, 6, 6), BRASS, { gloss = false, flat = true })
  c:fill(c:ellipse(cx, cy, 4, 4), GLOW)
  c:fill(c:ellipse(cx - 1.5, cy - 1.5, 1.5, 1.5), GLOW2)
  c:fill(c:rect(cx, cy - 3, cx, cy + 3), "#c97a3a")
end
port(106, 21); port(134, 21)
local nose = c:ellipse(120, 25, 3, 2.5)
small(nose, PINK, { gloss = false })
c:px(120, 24, "#f7b8cf"); c:px(120, 26, PINK.shade)
c:fill(c:line({ { 115, 25 }, { 101, 28 } }, 1):add(c:line({ { 125, 25 }, { 139, 28 } }, 1)), CREAM)

-- 9. outrigger canoe with crab-claw sail on the right
local hull = c:poly({ { 166, 45 }, { 214, 45 }, { 210, 50 }, { 172, 50 } })
local float = c:rrect(172, 54, 206, 55, 1)
small(c:rect(180, 49, 181, 54):add(c:rect(198, 49, 199, 54)), WOOD, { flat = true })
small(float, DARKW, { flat = true })
local mast = c:rect(189, 18, 190, 45)
small(mast, DARKW, { flat = true })
local sail = c:poly({ { 188, 44 }, { 172, 13 }, { 181, 19 }, { 189, 21 }, { 197, 16 }, { 205, 10 }, { 192, 44 } })
small(sail, felt("#ecc58a", { shade = "#d4a064" }), { gloss = false })
c:fill(c:line({ { 177, 22 }, { 189, 38 } }, 1):add(c:line({ { 200, 20 }, { 191, 38 } }, 1)), "#c23a4a")
c:part(hull, DARKW, { gloss = { 170, 46 } })
c:fill(c:rect(170, 47, 210, 47), CREAM)
-- sleeping white cat in the canoe
local wcat = c:ellipse(203, 43, 5, 2.5):add(c:ellipse(199, 42, 3, 2.5))
wcat:add(c:poly({ { 196, 41 }, { 197, 38 }, { 199, 40 } })):add(c:poly({ { 199, 40 }, { 201, 38 }, { 202, 41 } }))
small(wcat, felt("#f4ead8", { shade = "#d8c4a8" }), { gloss = false })
c:fill(c:rect(197, 42, 198, 42):add(c:rect(200, 42, 201, 42)), D)
c:fill(c:rect(206, 41, 207, 42), "#9a8a80")
-- mooring rope to the right post
c:fill(c:line({ { 157, 40 }, { 162, 43 }, { 167, 45 } }, 1), "#e8c58a")

-- 10. leaning palm on the left with a frangipani garland to the roof ear
small(c:line({ { 16, 60 }, { 20, 46 }, { 26, 32 }, { 33, 18 } }, 3), WOOD, { flat = true })
for y = 22, 56, 5 do c:fill(c:rect(math.floor(16 + (60 - y) * 0.4), y, math.floor(18 + (60 - y) * 0.4), y), "#8a4f2a") end
local fronds = c:poly({ { 33, 16 }, { 14, 14 }, { 4, 22 }, { 18, 18 } })
fronds:add(c:poly({ { 33, 16 }, { 50, 12 }, { 60, 20 }, { 46, 17 } }))
fronds:add(c:poly({ { 33, 16 }, { 24, 4 }, { 12, 2 }, { 28, 8 } }))
fronds:add(c:poly({ { 33, 16 }, { 42, 3 }, { 54, 4 }, { 40, 9 } }))
fronds:add(c:poly({ { 33, 16 }, { 40, 22 }, { 44, 30 }, { 36, 22 } }))
small(fronds, LEAF, { gloss = false })
c:fill(c:ellipse(33, 17, 2, 2), "#8a4f2a")
local function garland(x0, y0, x1, y1, sag)
  local cols = { "#fff1c8", "#e46a9b", "#f5cf6a" }
  local i = 0
  for x = x0, x1 do
    local t = (x - x0) / (x1 - x0)
    local y = math.floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + 0.5)
    c:px(x, y, LEAF.shade)
    if (x - x0) % 6 == 3 and x < x1 - 2 then
      i = i + 1
      c:paint({ ".x.", "xyx", ".x." }, x - 1, y, { x = cols[(i - 1) % 3 + 1], y = "#f5cf6a" })
    end
  end
end
garland(36, 18, 87, 13, 8)
garland(153, 13, 188, 22, 5)

-- 11. coral heads in the foreground shallows
local function coral(x, y, col, w)
  small(c:ellipse(x, y, w, 2.5):add(c:ellipse(x - w + 1, y - 2, 1.5, 2)):add(c:ellipse(x + w - 1, y - 3, 1.5, 2)), felt(col), { gloss = false })
end
coral(40, 57, "#e46a7b", 5); coral(52, 58, "#ee8a4a", 3); coral(92, 59, "#9a6ab8", 4)
coral(150, 59, "#ee8a4a", 4); coral(222, 57, "#e46a7b", 5); coral(232, 58, "#9a6ab8", 3)
-- palm frond reaching in from the top right corner
small(c:poly({ { 241, -1 }, { 214, 6 }, { 200, 14 }, { 222, 8 }, { 241, 8 } }), LEAF, { gloss = false })

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

local t = c:save(OUT .. "banner-OC-pets.aseprite", OUT .. "banner-OC-pets.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)

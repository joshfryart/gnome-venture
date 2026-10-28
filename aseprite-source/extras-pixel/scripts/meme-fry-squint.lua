-- puzzles/fry-squint.gif redraw: an orange-haired felt puppet gives a suspicious side-eye squint
-- while the camera pushes in on his eyes, then holds as the squint narrows.
-- Source 498x364, 46 frames x 70 ms (3.22 s). Here: 332x242 (same aspect), 22 frames, per-frame ms
-- resampled from the source timing, loops forever, solid background.
-- Drawn on a 166x121 half grid (scene mode), written at 2x nearest.
-- World coords = frame-1 half-grid coords; every shape goes through the camera T().
-- Pass 2: push-in capped at 1.75x so brow, hairline, nose and mouth stay in frame; head, hair and
-- ear are smooth Catmull-Rom outlines sampled in float world coords (no per-frame vertex rounding),
-- so the silhouette stays the same shape at every zoom; slimmer crescents (no nose slab).
-- Pass 3: felt wall with hem seams and sparse nap flecks (matches the other puzzle GIFs) instead of
-- the slanted duct; stitch rings on head and jacket, gold hairline seam; bigger pupils, heavier lids
-- and brow ridges that drop during the hold; longer first/last frames so the loop snap reads as a beat.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local W, H = 166, 121
local GAME = "/home/user/gnome-venture/game/assets/img/puzzles/"

-- source-frame samples (70 ms each in the source); duration = gap to the next sample
local SAMPLES = { 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43 }
local SRC_N, SRC_MS = 46, 70

local E = { 92, 62 }           -- zoom anchor: between the eyes (world)
local ZMAX = 0.75              -- extra zoom at the end of the push (1.75x)
local function ease(s)
  local p = math.max(0, math.min(1, (s - 2) / 18))
  return 1 - (1 - p) ^ 2.2
end
local function cam(s)          -- zoom z and the screen spot of the anchor
  local e = ease(s)
  return 1 + ZMAX * e, 92 - 3 * e, 62 - 2 * e
end
local function squint(s)       -- eye-slit height factor: holds, then narrows a touch in the hold
  if s < 22 then return 1 end
  return 1 - 0.3 * math.min(1, (s - 22) / 15)
end

-- closed Catmull-Rom through world points (smooth felt outlines), n samples per span
local function spline(pts, n)
  n = n or 6
  local o, N = {}, #pts
  for i = 1, N do
    local p0, p1, p2, p3 = pts[(i - 2) % N + 1], pts[i], pts[i % N + 1], pts[(i + 1) % N + 1]
    for k = 0, n - 1 do
      local t = k / n
      local t2, t3 = t * t, t * t * t
      local function f(a)
        return 0.5 * ((2 * p1[a]) + (-p0[a] + p2[a]) * t + (2 * p0[a] - 5 * p1[a] + 4 * p2[a] - p3[a]) * t2
          + (-p0[a] + 3 * p1[a] - 3 * p2[a] + p3[a]) * t3)
      end
      o[#o + 1] = { f(1), f(2) }
    end
  end
  return o
end

local hair  = GV.ramp("#f08a24")   -- ember family
local skin  = "skin"
local shirt = GV.ramp("#f1ece0")   -- soil cream
local wall  = GV.ramp("#5b6f96")   -- stone family nudged to slate blue
local duct  = GV.ramp("#3e5a7a")
local UMB = GV.C.umber or "#4a2c1a"

-- world outlines (frame-1 half-grid coords)
local HEAD = spline({
  { 86, 27 }, { 100, 30 }, { 108, 40 }, { 111, 51 }, { 112, 60 }, { 115, 65 }, { 121, 69 },
  { 125, 73 }, { 122, 78 }, { 114, 80 }, { 112, 84 }, { 113, 88 }, { 110, 93 }, { 103, 97 },
  { 92, 98 }, { 80, 94 }, { 70, 85 }, { 64, 72 }, { 62, 55 }, { 68, 37 },
}, 8)
local EAR = spline({ { 66, 64 }, { 70, 66 }, { 70, 74 }, { 66, 80 }, { 61, 79 }, { 59, 72 }, { 61, 66 } }, 6)
local HAIR = spline({
  { 108, 36 }, { 98, 40 }, { 86, 43 }, { 77, 47 }, { 72, 53 }, { 70, 62 }, { 66, 63 },
  { 61, 56 }, { 56, 46 }, { 55, 36 }, { 61, 27 }, { 73, 21 }, { 89, 20 }, { 103, 24 }, { 110, 30 },
}, 8)
local SPIKES = {
  { { 60, 30 }, { 63, 3 }, { 78, 23 } },
  { { 76, 24 }, { 100, 5 }, { 97, 26 } },
  { { 58, 42 }, { 40, 35 }, { 58, 30 } },
  { { 100, 27 }, { 118, 21 }, { 109, 36 } },
}

local function drawFrame(s)
  local z, ax, ay = cam(s)
  local sq = squint(s)
  local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
  local function X(u) return ax + (u - E[1]) * z end
  local function Y(v) return ay + (v - E[2]) * z end
  local function F(pts) local o = {} for i, p in ipairs(pts) do o[i] = { X(p[1]), Y(p[2]) } end return o end
  local function P(pts) local o = {} for i, p in ipairs(pts) do o[i] = { math.floor(X(p[1]) + 0.5), math.floor(Y(p[2]) + 0.5) } end return o end
  local function poly(pts) return c:poly(F(pts)) end
  local function pen(w) return math.max(1, math.floor(w * z + 0.5)) end
  local function ink(pts, w, hex) c:fill(c:line(P(pts), pen(w or 0.8)), hex or UMB) end
  local function cr(n) return math.max(2, math.floor(n * z + 0.5)) end

  -- background: three felt wall panels (world-space bands so they zoom with the face), a hem seam
  -- on each join and sparse nap flecks so the wall reads as fabric like the other puzzle GIFs
  local BANDS = { { -200, 34, wall.rim }, { 34, 86, wall.base }, { 86, 300, wall.shade } }
  for _, b in ipairs(BANDS) do
    c:fill(poly{ {-200, b[1]}, {400, b[1]}, {400, b[2]}, {-200, b[2]} }, b[3])
  end
  local fleck = { wall.gloss, wall.rim, wall.bounce }
  for gy = -40, 200, 9 do
    for gx = -100, 300, 11 do
      local wx, wy = gx + (gy * 7) % 11 - 5, gy + (gx * 5) % 9 - 4
      local band = wy < 34 and 1 or (wy < 86 and 2 or 3)
      local hex = band == 1 and fleck[1] or (band == 2 and fleck[2] or fleck[3])
      local x, y = math.floor(X(wx) + 0.5), math.floor(Y(wy) + 0.5)
      c:px(x, y, hex); if z > 1.4 then c:px(x + 1, y, hex) end
    end
  end
  for _, yy in ipairs({ 34, 86 }) do c:seam(P{ {-200, yy}, {400, yy} }, { free = true }) end
  c:part(poly{ {-60, -40}, {240, -40}, {240, -22}, {-60, 12} }, duct, { gloss = false, cres = 3, stitch = true })
  c:seam(P{ {-60, 10}, {240, -24} }, { free = true })

  -- jacket, shirt, neck
  c:part(poly{ {30, 140}, {44, 104}, {66, 96}, {104, 98}, {112, 140} }, "red", { cres = cr(3), stitch = { side = "lit" } })
  c:part(poly{ {64, 140}, {68, 104}, {80, 112}, {96, 104}, {98, 140} }, shirt, { pale = true, gloss = false })
  c:part(poly{ {72, 112}, {74, 88}, {98, 88}, {94, 112} }, skin, { gloss = false, cres = cr(2) })
  c:seam(P{ {48, 104}, {66, 98}, {74, 106} })
  c:seam(P{ {98, 104}, {104, 99} })

  -- head: one smooth outline (cranium, long nose, lips, chin), then the ear
  c:part(poly(HEAD), skin, { cres = cr(3), deep = cr(1), gloss = { X(84), Y(46) }, stitch = { side = "lit" } })
  c:part(poly(EAR), skin, { cres = cr(1.5), deep = 1, gloss = false })
  ink({ { 67, 69 }, { 64, 71 }, { 64, 75 }, { 66, 77 } }, 0.7)

  -- hair: smooth felt mop with the hairline sweeping down to a sideburn, plus four sharp spikes
  local h = poly(HAIR)
  for _, sp in ipairs(SPIKES) do h:add(poly(sp)) end
  c:part(h, hair, { cres = cr(3), deep = cr(1), stitch = { side = "lit" }, gloss = { X(70), Y(28) } })
  -- gold hairline seam where the felt mop is sewn to the head
  c:seam(P{ { 108, 37 }, { 98, 41 }, { 86, 44 }, { 77, 48 }, { 72, 54 }, { 70, 62 } }, { free = true })

  -- the squint: two flat cream slits under heavy lids, pupils parked hard right
  local eh = 4.4 * sq
  local drop = (1 - sq) * 2.5          -- brow ridge sinks onto the lids in the hold
  for _, e in ipairs({ { 82, 62 }, { 101, 61 } }) do
    local ex, ey = e[1], e[2]
    ink({ { ex - 9, ey - 6 + drop }, { ex - 3, ey - 7.5 + drop }, { ex + 6, ey - 7 + drop } }, 1.3)  -- brow ridge
    local slit = c:rrect(math.floor(X(ex - 9)), math.floor(Y(ey - eh / 2)), math.floor(X(ex + 9)),
      math.floor(Y(ey + eh / 2)), math.floor(z))
    c:fill(slit, "#f1ece0")
    c:fill(c:rect(math.floor(X(ex - 9)), math.floor(Y(ey + eh / 2)) - pen(0.3) + 1, math.floor(X(ex + 9)), math.floor(Y(ey + eh / 2))), "#d8c49a")
    ink({ { ex - 10, ey - eh / 2 - 0.4 }, { ex + 10, ey - eh / 2 - 0.8 } }, 1.5)  -- upper lid, heavy
    ink({ { ex - 9, ey + eh / 2 + 0.6 }, { ex + 9, ey + eh / 2 + 0.6 } }, 0.7)    -- lower lid
    local px = X(ex + 4 + (s >= 22 and math.min(1, (s - 22) / 15) or 0))
    local pr = math.max(3, math.floor(3 * z + 0.5))
    local pm = c:rect(math.floor(px - pr / 2), math.floor(Y(ey) - pr / 2), math.floor(px - pr / 2) + pr, math.floor(Y(ey) - pr / 2) + pr)
    pm:clip(slit)
    c:fill(pm, "#2a1a10")
    c:px(math.floor(px - pr / 2), math.floor(Y(ey) - pr / 2), "#f9d49c")
    ink({ { ex - 6, ey + eh / 2 + 2.6 }, { ex + 4, ey + eh / 2 + 2.2 } }, 0.5)   -- eye bag crease
  end
  -- brow creases over the lids, cheek-to-nose crease, mouth
  ink({ { 90, 52 }, { 92, 56 }, { 91, 64 } }, 0.6)
  ink({ { 76, 55 }, { 75, 60 } }, 0.6)
  ink({ { 108, 55 }, { 109, 59 } }, 0.6)
  ink({ { 100, 66 }, { 105, 74 }, { 112, 78 } }, 0.6)
  ink({ { 100, 86 }, { 105, 85.5 }, { 110, 87.5 } }, 0.9)  -- tight downturned mouth
  return c:image()
end

local spr = Sprite(W * 2, H * 2, ColorMode.RGB)
local layer = spr.layers[1]
layer.name = "fry-squint"
for i, s in ipairs(SAMPLES) do
  if i > 1 then spr:newEmptyFrame(i) end
  local img = drawFrame(s)
  if i == 1 then spr.cels[1].image = img; img:saveAs(GAME .. "fry-squint-still.png")
  else spr:newCel(layer, i, img) end
  local nxt = SAMPLES[i + 1] or SRC_N
  local ms = (nxt - s) * SRC_MS
  if i == 1 then ms = 260 elseif i == #SAMPLES then ms = 480 end   -- a beat before and after the push
  spr.frames[i].duration = ms / 1000
  local t = GV.check(img)
  if i == 1 or i == #SAMPLES then print("frame " .. i .. ": " .. GV.report(t)) end
  assert(t.semi == 0 and t.bw == 0)
end
pcall(function() app.fs.makeAllDirectories(D .. "extras-pixel/puzzles-gif") end)
spr:saveAs(D .. "extras-pixel/puzzles-gif/fry-squint.aseprite")
spr:saveCopyAs(GAME .. "fry-squint.gif")
spr:close()
print("saved")

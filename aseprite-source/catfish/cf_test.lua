-- cf_test.lua : Cat Fish test art, pass 4 (grey cat idle A + pounce, catch, nap, stalk key frames, plain plushie
-- fish, cat wand rod, kibble + yarn icons).
-- Run: AppRun -b --script cf_test.lua      (Stitched Toy, art-style-guide Part D, via gvlib)
--
-- GREY CAT TEMPLATE TONES (the recolour script tools/catfish_recolor.py maps exactly these 4 hex values):
--   shade  #6c6680   crescent, deep, contact shadow, toe lines, tail stripe
--   base   #9c98a6   body felt, ears, tail, head crescent
--   light  #c8c4cc   head felt, paws, muzzle, tail tip, body rim
--   gloss  #eee8e0   enamel comma and dot, head rim
-- Everything else on the cat is a FIXED accent and is never recoloured:
--   pink #e8909e / #c66a80 (nose, inner ear), eye cream #f2e4c0, umber #2a1a10 #4a2c1a #74462a,
--   thread gold #f5cf6a #e8a317, button hole #8a4a1c, border #000000.
-- Parts stay separate (tail, earL, earR, body, head, paws) so folded ears and bobtail can replace them later.
-- Pass 3: head is felt one tone lighter than the body (head/body split reads at 16 px), tall ears with a clear
-- notch, tail curls up clear of the body, edge stitch runs continuous (2 on / 1 off) round the visible body.
-- Pass 4: one shared head/ears/face/paw/tail-tip template (catHead, catFace, paw, tailTip) drawn at a per-frame
-- offset (OX, OY) from idle A; open eyes get a 1 px umber-2 ring; closed eyes are 1 px umber arcs (see EYES);
-- yarn thread joins the outlined silhouette. Frame offsets: idleA 0,0  pounce 8,0  catch 0,0  nap 0,20
-- stalk 15,20. The catch fish reuses the cf-fish-1 colours on trimmed ramps. No 'z' on the nap frame: a z small
-- enough to fit is 2 px tall at 32 px and does not read.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

local GREY = { shade = "#6c6680", base = "#9c98a6", light = "#c8c4cc", gloss = "#eee8e0" }
local function coat(t) -- body ramp: 4-tone in gvlib's 7 slots
  return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base }
end
local function coatHi(t) -- head/paw ramp: one tone up (base = light, crescent = base, deep = shade)
  return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light }
end
local PINK, PINKS = "#e8909e", "#c66a80"

-- recolour pixels of `from` inside mask m to `to` (keeps the crescent and contours intact)
local function tint(c, m, from, to)
  m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end)
end

-- continuous edge stitch: 1 px thread gold 2 on / 1 off, walked round the ring 2 px inside mask m,
-- painted only where part P still shows (so it never lands on a head or paw drawn over it); skips gloss.
local function edgeStitch(c, m, P, o)
  o = o or {}
  local s1 = m:shrink(1); local s2 = s1:shrink(1)
  local x0, y0, x1, y1 = m:bbox()
  local cx, cy = o.cx or (x0 + x1) / 2, o.cy or (y0 + y1) / 2
  local ring = {}
  for k in pairs(s1.s) do
    if not s2.s[k] then
      local x, y = c:xy(k)
      if c:inside(x, y) then ring[#ring + 1] = { x, y, k, math.atan(y - cy, x - cx) } end
    end
  end
  table.sort(ring, function(a, b) return a[4] < b[4] end)
  local on, off = o.on or 2, o.off or 1
  for i, p in ipairs(ring) do
    local k = p[3]
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end

-- ===== shared cat template pieces (every frame uses the same head, ears, face, eyes, paws, tail tip) =====
-- The head is drawn at idle A's place shifted by (ox, oy), so all frames share one face and the eye overlay
-- positions are just idle A's plus the frame offset. Ears and tail stay separate parts in every frame.
-- EYES: open = locked disc (gvlib c:eye) with a 1 px umber-2 (#4a2c1a) ring just outside it, so the cream disc
-- reads on the light head felt (pass 4). Closed = a 1 px umber (#2a1a10) arc, 5 px wide, in the middle two rows
-- of the 5x5 eye box: "happy" squint is an upturned arc (catch), "sleep" is a downturned arc (nap). Closed-eye
-- frames take no eye-colour overlay.
local function catHead(c, ox, oy) -- returns build entries (earL, earR, head) and the head mask
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local earL = c:poly({ {10 + ox, 21 + oy}, {12 + ox, 7 + oy}, {23 + ox, 13 + oy} }):grow(1)
  local earR = c:poly({ {27 + ox, 13 + oy}, {38 + ox, 7 + oy}, {40 + ox, 21 + oy} }):grow(1)
  return {
    { "earL", earL, g, { cres = 2, gloss = false } },
    { "earR", earR, g, { cres = 2, gloss = false } },
    { "head", head, h, { gloss = { 14 + ox, 15 + oy } } },
  }, head
end
local function eyeRing(c, x, y) -- 1 px umber-2 ring round the 5x5 cut-corner disc at (x, y)
  c:paint({
    "..uuu..",
    ".u...u.",
    "u.....u",
    "u.....u",
    "u.....u",
    ".u...u.",
    "..uuu..",
  }, x - 1, y - 1, { u = "ol2" })
end
local function catEye(c, x, y, mode)
  if mode == "happy" then c:paint({ ".uuu.", "u...u" }, x, y + 1, { u = "umber" })
  elseif mode == "sleep" then c:paint({ "u...u", ".uuu." }, x, y + 2, { u = "umber" })
  else eyeRing(c, x, y); c:eye(x, y) end
end
local function catFace(c, ox, oy, head, eyes) -- inner ears, muzzle, nose, mouth, eyes set wide
  c:fill(c:poly({ {13 + ox, 18 + oy}, {13 + ox, 9 + oy}, {21 + ox, 14 + oy} }):cut(head), PINK)
  c:fill(c:poly({ {29 + ox, 14 + oy}, {37 + ox, 9 + oy}, {37 + ox, 18 + oy} }):cut(head), PINK)
  c:fill(c:ellipse(25 + ox, 27 + oy, 3, 1.5), GREY.gloss)
  c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy, { p = PINK, q = PINKS })
  c:paint({ "u.u" }, 24 + ox, 27 + oy, { u = "ol2" })
  catEye(c, 14 + ox, 19 + oy, eyes); catEye(c, 32 + ox, 19 + oy, eyes)
end
local function paw(c, cx, cy, toes) -- light-tone paw (flat), toe lines in the base tone
  c:part(c:ellipse(cx, cy, 4.5, 2.5), coatHi(GREY), { flat = true })
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = GREY.base }) end
end
local function tailTip(c, tail, region, seam) -- light-tone tip with a gold seam at the join
  tint(c, region:clip(tail), GREY.base, GREY.light)
  c:seam(seam)
end
-- rotated ellipse mask (pixel centres), angle in radians (screen coords, y down)
local function rell(c, cx, cy, rx, ry, a)
  local m, ca, sa, R = c:mask(), math.cos(a), math.sin(a), math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do
    for x = math.floor(cx - R), math.ceil(cx + R) do
      local dx, dy = x - cx, y - cy
      local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
      if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
    end
  end
  return m
end
local function catSave(c, name)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-6s ", name:match("grey%-(.*)$")) .. GV.report(t))
  return t
end

-- ===== cat body, grey template, idle A (64x64 sticker) =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local H, head = catHead(c, 0, 0)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tail = c:line({ {38, 52}, {45, 52}, {50, 49}, {52, 44}, {52, 38}, {51, 34} }, 5)
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 15, 40 } } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(46, 30, 56, 36), { { 49, 37 }, { 53, 37 } })
  paw(c, 19.5, 53); paw(c, 30.5, 53)                                        -- paws on top (light tone)
  edgeStitch(c, body, p.body, { cy = 45 })
  -- belly seam with a button at its head (front join of the two body halves)
  c:button(23, 35)
  c:seam({ { 25, 39 }, { 25, 50 } })
  catFace(c, 0, 0, head, "open")
  catSave(c, "cf-cat-grey-idleA")
end

-- ===== pounce: mid-leap, body stretched on the diagonal, front paws reaching right, back legs tucked =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 8, 0
  local H, head = catHead(c, OX, OY)
  local A = math.atan(-14, 24)                                             -- body axis, rising to the right
  local body = rell(c, 25, 42, 15.5, 8.5, A)
  local tail = c:line({ {14, 47}, {10, 42}, {9, 36}, {10, 30}, {13, 26} }, 5)
  local legF = c:line({ {36, 33}, {43, 32}, {48, 31} }, 4)                -- far foreleg (behind the body)
  local legN = c:line({ {35, 38}, {42, 39}, {47, 39} }, 4)                -- near foreleg
  local thigh = rell(c, 18, 48, 6.5, 4.5, A)                               -- tucked hind leg
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "legF", legF, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 16, 40 } } },
    { "thigh", thigh, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
    { "legN", legN, g, { cres = 2, gloss = false } },
  }
  tailTip(c, tail, c:rect(6, 22, 20, 29), { { 8, 30 }, { 12, 30 } })
  paw(c, 51.5, 32); paw(c, 50.5, 39.5)
  paw(c, 25.5, 52)                                                         -- hind paw tucked under the belly
  edgeStitch(c, body, p.body)
  catFace(c, OX, OY, head, "open")
  catSave(c, "cf-cat-grey-pounce")
end

-- ===== catch: sitting proud, plushie fish (cf-fish-1 look, scaled) hugged in the front paws, happy squint =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local H, head = catHead(c, 0, 0)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tail = c:line({ {38, 52}, {45, 51}, {50, 46}, {52, 39}, {51, 33}, {47, 30} }, 5)
  -- the fish (cf-fish-1 colours): orange felt body, gold fins, light belly, hand gloss comma, gill seam, small
  -- eye. Trimmed ramps (no deep/bounce, flat fins) keep the frame under 24 colours.
  local F = { gloss = "#ffc27a", dot = "#fff1c8", rim = "#f4b46a", base = "#e0872a", shade = GV.ramp("#e0872a").shade }
  F.deep, F.bounce = F.shade, F.shade
  local FIN = { gloss = "#f2c14e", dot = "#f2c14e", rim = "#f2c14e", base = "#f2c14e", shade = GV.ramp("#f2c14e").shade }
  FIN.deep, FIN.bounce = FIN.shade, FIN.shade
  local fish = c:ellipse(23, 41, 9, 5.5)
  local fTail = c:poly({ {30, 41}, {39, 34}, {40, 38}, {37, 41}, {40, 44}, {39, 48} })
  local fFin = c:poly({ {18, 37}, {21, 33}, {26, 33}, {29, 37} })
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 15, 40 } } },
    H[1], H[2], H[3],
    { "fTail", fTail, FIN, { cres = 2, deep = 0, bounce = false, gloss = false } },
    { "fFin", fFin, FIN, { cres = 2, deep = 0, bounce = false, gloss = false } },
    { "fish", fish, F, { cres = 2, deep = 0, bounce = false, gloss = false } },
  }
  tailTip(c, tail, c:rect(42, 26, 52, 32), { { 48, 29 }, { 49, 33 } })
  tint(c, c:ellipse(23, 45, 7, 1.5):clip(fish), F.base, F.rim)            -- belly
  c:paint({ "..gg", ".g..", "g..." }, 19, 37, { g = F.gloss }); c:px(21, 38, F.dot) -- gloss comma + dot
  c:paint({ "s.s", ".s." }, 25, 41, { s = F.shade })                       -- scale stitch
  c:seam({ { 18, 37 }, { 19, 40 }, { 18, 44 } })                           -- gill seam
  c:eye(15, 39, true)
  paw(c, 19.5, 53); paw(c, 30.5, 53)                                        -- hind feet
  paw(c, 15.5, 46, false); paw(c, 30.5, 46.5, false)                        -- front paws hugging the fish
  edgeStitch(c, body, p.body, { cy = 45 })
  catFace(c, 0, 0, head, "happy")
  catSave(c, "cf-cat-grey-catch")
end

-- ===== nap: curled loaf asleep, head down on the left, haunch on the right, tail wrapped round the front =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 0, 20
  local H, head = catHead(c, OX, OY)
  local body = c:ellipse(36, 44.5, 20, 10.5)
  local thigh = c:ellipse(46, 45, 8, 7)
  local tail = c:line({ {54, 40}, {54, 47}, {50, 52}, {40, 53}, {30, 53}, {22, 52}, {17, 49} }, 5)
  local p = c:build{
    { "body", body, g, { gloss = { 30, 37 } } },
    { "thigh", thigh, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
    { "tail", tail, g, { cres = 2, gloss = false } },
  }
  tailTip(c, tail, c:rect(10, 44, 20, 58), { { 21, 50 }, { 21, 54 } })
  edgeStitch(c, body, p.body)
  catFace(c, OX, OY, head, "sleep")
  catSave(c, "cf-cat-grey-nap")
end

-- ===== stalk: low crouch, chin on the front paws, bum up, tail low, eyes wide =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 15, 20
  local H, head = catHead(c, OX, OY)
  local body = rell(c, 27, 31, 14, 7.5, 0.95)                              -- back slopes down from a high rump
  local thigh = c:ellipse(24, 44, 6, 6.5)                                  -- folded haunch
  local tail = c:line({ {15, 22}, {11, 27}, {9, 33}, {9, 39}, {11, 43}, {14, 44} }, 5)
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 19, 24 } } },
    { "thigh", thigh, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(4, 41, 18, 50), { { 7, 40 }, { 11, 40 } })
  paw(c, 22, 53)                                                           -- hind paw
  paw(c, 34.5, 53); paw(c, 45.5, 53)                                       -- front paws under the chin
  edgeStitch(c, body, p.body)
  catFace(c, OX, OY, head, "open")
  catSave(c, "cf-cat-grey-stalk")
end

-- ===== plain plushie fish (48x48 sticker) =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = GV.ramp("#e0872a", { gloss = "#ffc27a", dot = "#fff1c8" }) -- gloss kept clear of thread gold
  local fin = GV.ramp("#f2c14e")
  local body = c:ellipse(20, 24, 13, 9)
  c:build{
    { "tail", c:poly({ {29, 24}, {39, 14}, {41, 19}, {38, 24}, {41, 29}, {39, 34} }), fin, { cres = 2 } },
    { "fin",  c:poly({ {13, 18}, {17, 11}, {24, 11}, {28, 18} }), fin, { cres = 2, gloss = false } },
    { "body", body, f, { stitch = { side = "lit" }, gloss = false } },
  }
  tint(c, c:ellipse(19, 31, 9, 3), f.base, "#f4b46a")                                      -- belly
  c:paint({ "s.s", ".s." }, 25, 24, { s = f.shade })                                       -- scale stitches
  c:paint({ "s.s", ".s." }, 30, 21, { s = f.shade })
  c:paint({ "s.s", ".s." }, 21, 24, { s = f.shade })
  c:seam({ { 14, 16 }, { 16, 19 }, { 17, 23 }, { 16, 28 }, { 14, 31 } })                   -- gill seam
  -- enamel gloss comma, drawn by hand: a 2 px thick arc on the lit upper left of the body, plus a dot
  c:paint({
    "...ggddd",
    "..gddd..",
    ".gdd....",
    "gdd...d.",
    "gd......",
  }, 19, 17, { g = f.gloss, d = f.dot })
  c:eye(9, 19)
  c:paint({ "uu", "u." }, 8, 27, { u = "ol2" })                                            -- mouth
  local t = c:save(OUT .. "cf-fish-1.aseprite", OUT .. "cf-fish-1.png")
  print("fish   " .. GV.report(t))
end

-- ===== cat wand rod (48x64 sticker). String is drawn in code from the eye-loop at the tip. =====
-- Axis runs (35,11) -> (15,51), slope 1:2. Eye-loop hole at (35,9): attach the string there.
-- Grip: felt ribbon wound in a spiral (each wrap = dark under-edge + lit ridge), tapered from a collar to a
-- rounded butt; blue yarn pompom on the butt (matches the bow).
do
  local c = GV.canvas{ w = 48, h = 64, mode = "sticker" }
  local ax, ay = -1 / math.sqrt(5), 2 / math.sqrt(5)   -- unit vector down the axis
  local nx, ny = 2 / math.sqrt(5), 1 / math.sqrt(5)    -- unit normal (points right/down = shade side)
  local GX, GY = 23, 34                                  -- grip start on the axis
  local function at(t, v) return GX + ax * t + nx * v, GY + ay * t + ny * v end
  local function band(t0, t1, w0, w1) -- tapered band along the axis: t0..t1, half widths w0..w1
    local a1, a2 = at(t0, -w0); local b1, b2 = at(t0, w0); local c1, c2 = at(t1, w1); local d1, d2 = at(t1, -w1)
    return c:poly({ { a1, a2 }, { b1, b2 }, { c1, c2 }, { d1, d2 } })
  end
  local loop   = c:ellipse(35, 9, 2.5):cut(c:rect(34, 8, 36, 10))
  local stick  = c:line({ { 34, 13 }, { 22, 37 } }, 3)
  local bx, by = at(13.5, 0)
  local grip   = band(2, 13.5, 2.6, 3.6):add(c:ellipse(bx, by, 3.5)):closed(1)
  local collar = band(-0.5, 2.5, 3.7, 3.7):closed(1)
  local px, py = at(19.5, 0)
  local pom    = c:ellipse(px, py, 3.5)
  local bowL   = c:ellipse(28, 16, 2.5, 2)
  local bowR   = c:ellipse(36, 20, 2.5, 2)
  local p = c:build{
    { "loop",  loop, "gold", { flat = true } },
    { "stick", stick, "wood", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "bowL",  bowL, "water", { flat = true } },
    { "bowR",  bowR, "water", { flat = true } },
    { "tailL", c:line({ { 31, 19 }, { 29, 22 }, { 29, 24 } }, 2), "water", { flat = true } },
    { "tailR", c:line({ { 33, 20 }, { 34, 23 }, { 36, 25 } }, 2), "water", { flat = true } },
    { "knot",  c:rect(31, 17, 33, 19), "water", { flat = true } },
    { "grip",  grip, "red", { cres = 2, gloss = false } },
    { "collar", collar, "red", { cres = 1, deep = 0, gloss = false } },
    { "pom",   pom, "water", { cres = 2, gloss = false } },
  }
  -- spiral wrap: the grip slants 1:2, so level rows cross it on a spiral. Each turn is a 1 px dark
  -- under-edge row with a 1 px lit ridge row above it (lit felt only).
  local R = GV.R.red
  local inner = grip:copy():cut(collar:grow(1)):cut(pom:grow(1)):shrink(1)
  for _, y in ipairs({ 40, 43, 46, 49 }) do
    for x = 0, 47 do
      local k = c:key(x, y)
      if inner:has(x, y) and c.own[k] == p.grip then c:px(x, y, c.shd[k] and R.deep or R.shade) end
      local k2 = c:key(x, y - 1)
      if inner:has(x, y - 1) and c.own[k2] == p.grip and not c.shd[k2] then c:px(x, y - 1, R.rim) end
    end
  end
  c:gloss(pom, "water", { 12, 50 })
  c:seam({ { 19, 35 }, { 26, 38 } })                                                       -- collar hem
  local t = c:save(OUT .. "cf-rod.aseprite", OUT .. "cf-rod.png")
  print("rod    " .. GV.report(t))
end

-- ===== kibble icon (32x32, icon mode): felt bowl heaped with round kibble =====
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local K = GV.ramp("#bf7a3c")
  local bowl = c:ellipse(15.5, 17, 8.5, 2.5):add(c:poly({ {7, 17}, {25, 17}, {22, 24}, {10, 24} })):closed(1)
  local list = {}
  local pieces = { {14, 8}, {10, 11}, {14, 11}, {18, 11}, {8, 14}, {12, 14}, {16, 14}, {20, 14} } -- back to front, top-left corners
  for i, q in ipairs(pieces) do                          -- 4 x 4 cut-corner kibble, like a felt button
    list[#list + 1] = { "k" .. i, c:rrect(q[1], q[2], q[1] + 3, q[2] + 3, 1), K, { cres = 1, deep = 0, bounce = false, gloss = false } }
  end
  list[#list + 1] = { "bowl", bowl, "water", { cres = 3, gloss = { 9, 19 } } }
  c:build(list)
  for _, q in ipairs(pieces) do c:px(q[1] + 1, q[2] + 1, K.gloss) end                    -- 1 px glaze on each kibble
  c:seam({ { 9, 18 }, { 23, 18 } })                                                        -- bowl rim hem
  local t = c:save(OUT .. "cf-ico-kibble.aseprite", OUT .. "cf-ico-kibble.png")
  print("kibble " .. GV.report(t))
end

-- ===== yarn ball icon (32x32, icon mode): wound felt yarn with a trailing thread =====
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local Y = GV.R.petal
  local ball = c:ellipse(12.5, 11.5, 6.5, 6)
  -- the loose thread is a 2 px felt strand that joins the silhouette (pass 4): it gets the full umber outline
  -- under the black border, so it reads at 16 px. Routed tighter so the outline keeps the 3 px margin.
  local thread = c:line({ { 16, 16 }, { 18, 19 }, { 20, 21 }, { 23, 21 } }, 2)
  local p = c:build{
    { "thread", thread, Y, { flat = true } },
    { "ball", ball, Y, { cres = 3, gloss = { 9, 9 } } },
  }
  -- wound strands: concentric arcs (one family from the upper right, one cross band), only on the ball
  local inner = ball:shrink(1)
  local strands = c:mask()
  for _, r in ipairs({ 7, 10, 13 }) do strands:add(c:ellipse(22, 3, r):cut(c:ellipse(22, 3, r - 1))) end
  strands:add(c:ellipse(2, 21, 12):cut(c:ellipse(2, 21, 11)))
  strands:clip(inner)
  strands:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] then c:px(x, y, c.shd[k] and Y.deep or Y.shade) end
  end)
  c:seam({ { 16, 17 }, { 17, 18 } }, { free = true })                                       -- thread joins the ball
  local t = c:save(OUT .. "cf-ico-yarn.aseprite", OUT .. "cf-ico-yarn.png")
  print("yarn   " .. GV.report(t))
end

-- cf_test.lua : Cat Fish test art, pass 6 (grey cat idle A + pounce, catch, nap, stalk key frames, plain plushie
-- fish, cat wand rod, kibble + yarn icons).
-- Run: AppRun -b --script cf_test.lua      (Stitched Toy, art-style-guide Part D, via gvlib)
--
-- GREY CAT TEMPLATE TONES (the recolour script tools/catfish_recolor.py maps exactly these 4 hex values):
--   shade  #57516f   crescent, deep, contact shadow, toe lines, tail stripe
--   base   #8a859b   body felt, ears, tail, head crescent
--   light  #cdc9d3   head felt, paws, muzzle, tail tip, body rim
--   gloss  #f1ebe3   enamel comma and dot, head rim
-- Everything else on the cat is a FIXED accent and is never recoloured:
--   pink #e8909e / #c66a80 (nose, inner ear), eye cream #f2e4c0, umber #2a1a10 #4a2c1a #74462a,
--   thread gold #f5cf6a #e8a317, border #000000. (Pounce floor shadow is umber #4a2c1a; no cat button.)
-- Parts stay separate (tail, earL, earR, body, head, paws) so folded ears and bobtail can replace them later.
-- Pass 3: head is felt one tone lighter than the body (head/body split reads at 16 px), tall ears with a clear
-- notch, tail curls up clear of the body, edge stitch runs continuous (2 on / 1 off) round the visible body.
-- Pass 4: one shared head/ears/face/paw/tail-tip template (catHead, catFace, paw, tailTip) drawn at a per-frame
-- offset (OX, OY) from idle A; open eyes get a 1 px umber-2 ring; closed eyes are 1 px umber arcs (see EYES).
-- Pass 5: grey tones spread wider (darker shade and base, lighter head) for the 16 px read; pounce redrawn as a
-- leap (fore and hind legs stretched out, tail streaming, a floor shadow left behind); stalk is a play bow with
-- the tail held out and flicked up (no enclosed hole); nap tail rides round the haunch so its tip seam is clear
-- of the face; props use felt ramps shaded like the coat (see felt()).
-- Pass 6 (16 px read): edge stitch on the lit half of the body only (the crescent side stays clean felt) and no
-- belly seam/button on idle A (it read as a coat zip and no other frame had it); open-eye ring is umber, closed
-- eyes are 3-row arcs that survive 32 px; stalk haunch is one big round egg; catch paws cradle the fish from
-- below with toes; pounce floor shadow is a slim umber dash. Props: rod grip gets the enamel comma, kibble is a
-- wide bowl with a 4-piece heap, yarn's loose end lies on the floor (it hung like a balloon string).
-- Frame offsets: idleA 0,0  pounce 16,0  catch 0,0  nap 0,18  stalk 15,20. The catch fish reuses the cf-fish-1
-- colours on trimmed ramps. No 'z' on the nap frame: a z small enough to fit is 2 px tall at 32 px.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) -- body ramp: 4-tone in gvlib's 7 slots
  return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base }
end
local function coatHi(t) -- head/paw ramp: one tone up (base = light, crescent = base, deep = shade)
  return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light }
end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3 -- edge stitch only on the lit half of the body (s <= LIT): the crescent side stays clean felt

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
    local lit = (p[1] - cx) + (p[2] - cy) <= (o.lit or 1e9)
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end

-- ===== shared cat template pieces (every frame uses the same head, ears, face, eyes, paws, tail tip) =====
-- The head is drawn at idle A's place shifted by (ox, oy), so all frames share one face and the eye overlay
-- positions are just idle A's plus the frame offset. Ears and tail stay separate parts in every frame.
-- EYES: open = locked disc (gvlib c:eye) with a 1 px umber ring just outside it, so the cream disc
-- reads on the light head felt (pass 4; umber #2a1a10 from pass 6). Closed = a 3-row umber arc, 5 px wide, in
-- the middle of the 5x5 eye box (pass 6, was 1 px): "happy" squint is an upturned arc (catch), "sleep" is a downturned arc (nap). Closed-eye
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
local function eyeRing(c, x, y) -- 1 px umber ring round the 5x5 cut-corner disc at (x, y)
  c:paint({
    "..uuu..",
    ".u...u.",
    "u.....u",
    "u.....u",
    "u.....u",
    ".u...u.",
    "..uuu..",
  }, x - 1, y - 1, { u = "umber" })
end
local function catEye(c, x, y, mode)
  if mode == "happy" then c:paint({ ".uuu.", "uu.uu", "u...u" }, x, y + 1, { u = "umber" })
  elseif mode == "sleep" then c:paint({ "u...u", "uu.uu", ".uuu." }, x, y + 1, { u = "umber" })
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
local function paw(c, cx, cy, toes, rx, ry) -- light-tone paw (flat), toe lines in the base tone
  c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), coatHi(GREY), { flat = true })
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
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, 0, 0, head, "open")
  catSave(c, "cf-cat-grey-idleA")
end

-- ===== pounce: mid-leap, body stretched on the diagonal, front paws reaching right, back legs tucked =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 16, 0
  local H, head = catHead(c, OX, OY)
  local A = math.atan(-10, 24)                                             -- body axis, rising to the right
  local body = rell(c, 28, 37, 15, 7, A)
  local tail = c:line({ {17, 38}, {12, 35}, {9, 30}, {9, 24}, {12, 20} }, 5) -- streams up behind
  local legF = c:line({ {38, 33}, {44, 37}, {48, 39} }, 4)                -- far foreleg (behind the body)
  local legN = c:line({ {36, 38}, {41, 42}, {45, 44} }, 4)                -- near foreleg, reaching down
  local legB = c:line({ {17, 40}, {13, 41}, {12, 41} }, 4)                -- far hind leg, trailing
  local legH = c:line({ {22, 44}, {17, 47}, {14, 49} }, 5)                -- near hind leg, kicked straight back
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "legB", legB, g, { cres = 2, gloss = false } },
    { "legF", legF, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 18, 36 } } },
    { "legH", legH, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
    { "legN", legN, g, { cres = 2, gloss = false } },
  }
  tailTip(c, tail, c:rect(5, 15, 18, 23), { { 7, 24 }, { 11, 24 } })
  paw(c, 50.5, 39.5); paw(c, 47.5, 45.5)                                   -- front paws out, about to land
  paw(c, 10.5, 41.5); paw(c, 11.5, 49.5)                                   -- hind paws trailing
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open")
  c:ground(30.5, 57.5, 5.5, 1, "#4a2c1a")                                  -- slim umber floor shadow: airborne
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
  local F = { gloss = "#ffc27a", dot = "#fff1c8", rim = "#f2a860", base = "#dc6f2c", shade = GV.ramp("#dc6f2c").shade }
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
  paw(c, 16.5, 45.5, true, 3.5, 2.5); paw(c, 28.5, 46, true, 3.5, 2.5)    -- small front paws cradle the fish from below
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, 0, 0, head, "happy")
  catSave(c, "cf-cat-grey-catch")
end

-- ===== nap: curled loaf asleep, head down on the left, haunch on the right, tail wrapped round the front =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 0, 18
  local H, head = catHead(c, OX, OY)
  local body = c:ellipse(36, 42, 20, 10)
  local thigh = c:ellipse(45, 42, 8, 7)
  -- tail rides the outside of the haunch and the bottom edge, tip ends right of the face (pass 5: the tip seam
  -- used to sit under the left eye)
  local tail = c:line({ {50, 35}, {53, 38}, {54, 44}, {51, 50}, {46, 53}, {38, 54} }, 5)
  local p = c:build{
    { "body", body, g, { gloss = { 30, 35 } } },
    { "thigh", thigh, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
    { "tail", tail, g, { cres = 2, gloss = false } },
  }
  tailTip(c, tail, c:rect(30, 48, 41, 58), { { 42, 52 }, { 42, 56 } })
  edgeStitch(c, body, p.body, { ymax = 46, lit = LIT })                               -- none on the thin strip under the chin
  catFace(c, OX, OY, head, "sleep")
  catSave(c, "cf-cat-grey-nap")
end

-- ===== stalk: low crouch, chin on the front paws, bum up, tail low, eyes wide =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 15, 20
  local H, head = catHead(c, OX, OY)
  local body = rell(c, 25, 32, 15, 7.5, 0.9)                               -- play bow: rump high, chest down
  -- haunch: one big round egg leaning forward from the rump to the hind paw (pass 6: the small upright
  -- ellipse left a square stub between the body and the head)
  local thigh = rell(c, 17.5, 39, 7.5, 10, -0.35)
  -- tail held low behind, tip flicked up: open shape, never closes a hole against the body (pass 5)
  local tail = c:line({ {18, 22}, {13, 23}, {9, 21}, {8, 16}, {10, 11} }, 5)
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 18, 24 } } },
    { "thigh", thigh, g, { cres = 2, gloss = { 13, 33 } } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(4, 4, 15, 14), { { 6, 15 }, { 10, 15 } })
  paw(c, 19.5, 53)                                                         -- hind paw under the haunch
  paw(c, 34.5, 53); paw(c, 45.5, 53)                                       -- front paws under the chin
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open")
  catSave(c, "cf-cat-grey-stalk")
end

-- ===== props: felt ramps shaded like the cat coat (pass 5) =====
-- felt(hex): gvlib ramp with deep = shade and bounce = base, so a prop has the same 4 felt steps as the cat
-- (rim, base, one crescent shade, gloss comma) instead of the full 7-step enamel ramp.
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end

-- ===== plain plushie fish (48x48 sticker) =====
-- Pass 5: sewn from felt panels like the cat: a light belly panel and a tail panel, each joined by a gold seam
-- (shade gaps so the dashes read on orange), a gold button at the head of the tail-panel seam, a gill seam,
-- one stitched rib on the fin and two on the tail, and the hand-drawn enamel gloss comma. Felt ramps only.
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = felt("#dc6f2c", { gloss = "#ffc27a", dot = "#fff1c8" }) -- redder than thread gold so seams show
  local fin = felt("#f2c14e", { gloss = "#fff1c8" })
  local body = c:ellipse(20, 24, 13, 9)
  local tail = c:poly({ {29, 24}, {39, 14}, {41, 19}, {38, 24}, {41, 29}, {39, 34} })
  local finM = c:poly({ {13, 18}, {17, 11}, {24, 11}, {28, 18} })
  local p = c:build{
    { "tail", tail, fin, { cres = 2, gloss = false } },
    { "fin",  finM, fin, { cres = 2, gloss = false } },
    { "body", body, f, { gloss = false } },
  }
  tint(c, c:ellipse(19, 31, 9, 3):clip(body), f.base, "#f2a860")                       -- belly panel
  c:seam({ { 10, 28 }, { 14, 31 }, { 20, 32 }, { 25, 31 } }, { gap = f.shade })        -- belly panel seam
  c:paint({ "s..", ".s.", ".s." }, 19, 13, { s = fin.shade })                           -- fin rib
  c:paint({ "ss...", "..ss." }, 35, 18, { s = fin.shade })                              -- tail ribs
  c:paint({ "..ss.", "ss..." }, 35, 28, { s = fin.shade })
  c:seam({ { 13, 17 }, { 15, 20 }, { 15, 24 }, { 14, 28 } }, { gap = f.shade })        -- gill seam
  c:seam({ { 29, 22 }, { 29, 27 }, { 27, 30 } }, { gap = f.shade })                     -- tail panel seam
  c:button(27, 18)                                                                       -- at its head
  c:paint({
    "...ggddd",
    "..gddd..",
    ".gdd....",
    "gdd...d.",
    "gd......",
  }, 17, 17, { g = f.gloss, d = f.dot })
  c:eye(8, 19)
  c:paint({ "uu", "u." }, 8, 27, { u = "ol2" })                                          -- mouth
  local t = c:save(OUT .. "cf-fish-1.aseprite", OUT .. "cf-fish-1.png")
  print("fish   " .. GV.report(t))
end

-- ===== cat wand rod (48x64 sticker). String is drawn in code from the tip bead. =====
-- Axis runs (35,11) -> (15,51), slope 1:2. Tip bead with its thread hole at (35,9): attach the string there.
-- Pass 5: the busy red collar + hem is now one plain gold ferrule, the square eye-loop is a round gold bead,
-- the bow is two clean felt loops on a knot, the grip is red felt wound in a spiral, yarn pompom on the butt.
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
  local RED, BLUE = felt("#dd3a2a", { gloss = "#ff9158", rim = "#f2793a" }), felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8" })
  local bead   = c:ellipse(35, 9, 3)
  local stick  = c:line({ { 34, 13 }, { 22, 37 } }, 3)
  local bx, by = at(13.5, 0)
  local grip   = band(2, 13.5, 2.6, 3.6):add(c:ellipse(bx, by, 3.5)):closed(1)
  local collar = band(-1.5, 2, 3.2, 3.2):closed(1)
  local px, py = at(19.5, 0)
  local pom    = c:ellipse(px, py, 3.5)
  local bowL   = c:poly({ {31, 19}, {25, 15}, {25, 21} }):grow(1)
  local bowR   = c:poly({ {33, 20}, {39, 18}, {37, 24} }):grow(1)
  local p = c:build{
    { "stick", stick, "wood", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "bead",  bead, "gold", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "bowL",  bowL, BLUE, { cres = 2, gloss = false } },
    { "bowR",  bowR, BLUE, { cres = 2, gloss = false } },
    { "knot",  c:rrect(31, 18, 34, 21, 1), BLUE, { flat = true } },
    { "grip",  grip, RED, { cres = 2, gloss = { 17, 38 } } },              -- enamel comma like the cat (pass 6)
    { "collar", collar, "gold", { cres = 1, deep = 0, bounce = false, gloss = false } },
    { "pom",   pom, BLUE, { cres = 2, gloss = false } },
  }
  c:px(35, 9, GV.C.hole); c:px(33, 7, GV.R.gold.gloss); c:px(34, 7, GV.R.gold.gloss)                              -- bead thread hole + glint
  -- spiral wrap: the grip slants 1:2, so level rows cross it on a spiral. Each turn is a 1 px shade
  -- under-edge row with a 1 px lit ridge row above it (lit felt only).
  local inner = grip:copy():cut(collar:grow(1)):cut(pom:grow(1)):shrink(1)
  for _, y in ipairs({ 40, 44, 48 }) do
    for x = 0, 47 do
      local k = c:key(x, y)
      if inner:has(x, y) and c.own[k] == p.grip and not c.shd[k] and not c.gl.s[k] then c:px(x, y, RED.shade) end
      local k2 = c:key(x, y - 1)
      if inner:has(x, y - 1) and c.own[k2] == p.grip and not c.shd[k2] and not c.gl.s[k2] then c:px(x, y - 1, RED.rim) end
    end
  end
  c:gloss(pom, BLUE, { 12, 50 })
  c:paint({ "s.", ".s" }, 13, 51, { s = BLUE.shade })                                     -- yarn tufts on the pompom
  local t = c:save(OUT .. "cf-rod.aseprite", OUT .. "cf-rod.png")
  print("rod    " .. GV.report(t))
end

-- ===== kibble icon (32x32, icon mode): wide felt bowl heaped with round kibble =====
-- Pass 6: the bowl is wide and shallow with its lip sticking out past the heap on both sides, so the silhouette
-- is a bowl with a bumpy top instead of an egg. Five darker brown kibble, each its own part with an umber
-- contour, so they read as separate pieces; the bumps show in the outline. No paw print (it read as teeth).
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local K = felt("#c47a36", { gloss = "#ffd79a", rim = "#e09a58" })
  local B = felt("#3f8fb0", { gloss = "#c8ecdc", rim = "#8fcbd8" })
  local bowl = c:ellipse(15.5, 18, 9, 2):add(c:poly({ {7, 18}, {25, 18}, {22, 25}, {10, 25} })):closed(1)
  local list = {}
  local pieces = { {15.5, 11.5}, {11, 15}, {20, 15}, {15.5, 15.5} }  -- back to front: one on top, three in front
  for i, q in ipairs(pieces) do
    list[#list + 1] = { "k" .. i, c:ellipse(q[1], q[2], 2.5, 2.5), K, { cres = 2, gloss = false, bounce = false } }
  end
  list[#list + 1] = { "bowl", bowl, B, { cres = 3, gloss = { 9, 20 } } }
  c:build(list)
  for _, q in ipairs(pieces) do                                          -- glaze dot + the kibble's hole
    c:px(math.floor(q[1]) - 1, math.floor(q[2]) - 1, K.gloss); c:px(math.floor(q[1]), math.floor(q[2]), K.shade)
  end
  c:seam({ { 9, 21 }, { 22, 21 } }, { gap = B.shade })                                     -- bowl hem
  local t = c:save(OUT .. "cf-ico-kibble.aseprite", OUT .. "cf-ico-kibble.png")
  print("kibble " .. GV.report(t))
end

-- ===== yarn ball icon (32x32, icon mode): wound felt yarn with a loose end trailing along the floor =====
-- Pass 6: the loose end leaves the ball's right side and snakes off along the floor (a hanging string read as a
-- balloon). Wraps are shade grooves with a lit ridge on their upper-left side (the rod grip's wrap language).
do
  local c = GV.canvas{ w = 32, h = 32, mode = "icon" }
  local Y = felt("#e46a9b")
  local ball = c:ellipse(14, 14, 8, 8)
  local thread = c:line({ { 20, 21 }, { 22, 23 }, { 24, 24 }, { 26, 23 }, { 26, 21 } }, 2) -- lies on the floor
  local p = c:build{
    { "thread", thread, Y, { flat = true, solid = false, contact = false } },
    { "ball", ball, Y, { cres = 3, gloss = { 10, 9 } } },
  }
  local inner = ball:shrink(1)
  local strands, ridge = c:mask(), c:mask()
  local function arcs(cx, cy, list)
    for _, r in ipairs(list) do
      strands:add(c:ellipse(cx, cy, r):cut(c:ellipse(cx, cy, r - 1)))
      ridge:add(c:ellipse(cx, cy, r - 1):cut(c:ellipse(cx, cy, r - 2)))
    end
  end
  arcs(27, 1, { 10, 14, 18, 22, 26 })                             -- wraps running lower-left to upper-right
  local cross = c:ellipse(1, 28, 19):cut(c:ellipse(1, 28, 11.5))  -- crossing band wound on top
  strands:cut(cross); ridge:cut(cross)
  arcs(1, 28, { 15, 19 })
  strands:clip(inner); ridge:clip(inner):cut(strands)
  ridge:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] and not c.shd[k] then c:px(x, y, Y.rim) end
  end)
  strands:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == p.ball and not c.gl.s[k] then c:px(x, y, Y.shade) end
  end)
  local t = c:save(OUT .. "cf-ico-yarn.aseprite", OUT .. "cf-ico-yarn.png")
  print("yarn   " .. GV.report(t))
end

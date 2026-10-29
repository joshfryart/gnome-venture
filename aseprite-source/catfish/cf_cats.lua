-- cf_cats.lua : Cat Fish grey cat key frames (idleA, pounce, catch, nap, stalk), split out of cf_test.lua in pass 7.
-- Run: AppRun -b --script cf_cats.lua      (Stitched Toy, art-style-guide Part D, via gvlib), then cf_overlays.lua
-- (it re-renders these frames and stops if its copy is out of step).
-- Pass 7: pounce is airborne (level body, forelegs tucked, hind legs kicked out behind, tail streaming back, wide
-- shadow far below); stalk haunch is a smaller round ball set back, with a chest lobe showing under the chin.
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

-- ===== pounce: airborne. Body level and stretched, forelegs tucked up under the chest, hind legs kicked
-- straight out behind, tail streaming up; the cat rides high over a wide slim floor shadow (pass 7: the old
-- pose had the front paws reaching down to the floor and read as a reach, not a leap) =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 16, 0
  local H, head = catHead(c, OX, OY)
  local A = math.atan(-5, 24)                                              -- body axis, nearly level
  local body = rell(c, 27, 33.5, 16, 7, A)
  local tail = c:line({ {16, 30}, {13, 26}, {11, 21}, {10, 16}, {8, 12} }, 5)   -- streams up and back
  local legF = c:line({ {39, 33}, {45, 35}, {49, 34} }, 4)                -- far foreleg, tucked under the chin
  local legN = c:line({ {35, 36}, {40, 40}, {44, 39} }, 4)                -- near foreleg, folded up
  local legB = c:line({ {17, 33}, {13, 33}, {11, 32} }, 4)                -- far hind leg, straight back
  local legH = c:line({ {21, 37}, {16, 39}, {13, 40} }, 5)                -- near hind leg, kicked out behind
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "legB", legB, g, { cres = 2, gloss = false } },
    { "legF", legF, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 18, 31 } } },
    { "legH", legH, g, { cres = 2, gloss = false } },
    H[1], H[2], H[3],
    { "legN", legN, g, { cres = 2, gloss = false } },
  }
  tailTip(c, tail, c:rect(4, 4, 16, 15), { { 7, 16 }, { 12, 16 } })
  paw(c, 51.5, 34.5); paw(c, 46.5, 40)                                     -- front paws tucked
  paw(c, 10.5, 32.5); paw(c, 11.5, 40.5)                                   -- hind paws trailing
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open")
  c:ground(29.5, 57.5, 9, 1, "#4a2c1a")                                    -- wide slim umber shadow far below
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
-- Pass 7: the haunch is a round ball set back on the rump (the leaning egg read blocky), and a chest lobe
-- peeks out between haunch and chin so the tuxedo/calico bib has somewhere to show.
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 15, 20
  local H, head = catHead(c, OX, OY)
  local body = rell(c, 24, 33, 15, 8, 0.8):add(c:ellipse(26, 46, 5, 6.5)) -- play bow + chest lobe under the chin
  local thigh = rell(c, 14.5, 43, 7, 8, -0.45)                             -- round haunch, set back
  -- tail held low behind, tip flicked up: open shape, never closes a hole against the body (pass 5)
  local tail = c:line({ {18, 22}, {13, 23}, {9, 21}, {8, 16}, {10, 11} }, 5)
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 18, 25 } } },
    { "thigh", thigh, g, { cres = 2, gloss = { 10, 38 } } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(4, 4, 15, 14), { { 6, 15 }, { 10, 15 } })
  paw(c, 15.5, 53)                                                         -- hind paw under the haunch
  paw(c, 34.5, 53); paw(c, 45.5, 53)                                       -- front paws under the chin
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open")
  catSave(c, "cf-cat-grey-stalk")
end

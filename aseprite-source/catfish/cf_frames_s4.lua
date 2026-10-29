-- cf_frames_s4.lua : Cat Fish animation slice S4, idle-variety grey cat frames (Stitched Toy, via gvlib).
-- Run: AppRun -b --script cf_frames_s4.lua      Writes test/cf-cat-grey-<yawn|stretch|washA|washB>.png + .aseprite.
-- Then run cf_overlays_s4.lua (it loads this file as a library, re-renders every frame, stops if a PNG is out of
-- step, and writes the full overlay set for the four frames).
-- Same template as cf_cats.lua / cf_frames2.lua: the 4 grey tones (shade #57516f, base #8a859b, light #cdc9d3,
-- gloss #f1ebe3), fixed accents only (pink, eye cream, umber, thread gold, #000000 border), separate
-- tail/ear/body/head/paw/leg parts, edge stitch on the lit half only. The helpers below are a clean copy of
-- cf_overlays.lua's switchable frame code (ears orig|none|fold, tail orig|none|bob), so the overlay script can
-- render the replacement-part variants from this one source. With the new options left out (no face shift, no
-- yawn mouth, ear offsets 0) they draw exactly what cf_cats.lua / cf_frames2.lua draw.
-- New in the copy: catFace takes o.fy (eyes, nose and mouth moved up/down inside the head) and o.mouth = "yawn";
-- catEye gains "squeezeL"/"squeezeR" (eyes screwed shut, > <).
--
-- Frame offsets (head; eye boxes are idle A's 14,19 and 32,19 plus the offset, plus fy for the yawn):
--   yawn    0,-1  ears laid back (+-1, +2), face up 2 (fy -2): eyes squeezed shut, big open mouth (umber throat,
--                 cream fangs, pink tongue); idle A's body and paws, tail stretched up. No eye-colour overlay.
--   stretch 15,9  long diagonal body: rump high on the left on two straight hind legs, chest dropped, both
--                 forelegs reaching forward along the floor under the raised chin, tail up with the tip curled
--                 back; half-lidded eyes (same lid as bored, iris overlay IRIS_HALF).
--   washA   0,0   sitting (idle A body), eyes closed (sleep arcs), the near forepaw raised high to the cheek,
--                 toes toward the face; tail curled up and out.
--   washB   2,3   same body and tail; head bent down toward the paw (right ear dips), paw at the mouth, pink
--                 tongue out onto the paw, eyes closed. washA/washB alternate as the wash loop.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"
local M = { GV = GV, OUT = OUT, STITCH_ONLY = nil }

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3
M.GREY, M.coat, M.coatHi, M.PINK, M.PINKS = GREY, coat, coatHi, PINK, PINKS

-- ======================= shared template (copy of cf_overlays.lua's frame code) =======================
local function tint(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:px(x, y, to) end end) end
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
  local only = M.STITCH_ONLY -- (overlays) set while rendering a part variant: no new dash on body a part used to hide
  for i, p in ipairs(ring) do
    local k = p[3]
    local lit = (p[1] - cx) + (p[2] - cy) <= (o.lit or 1e9)
    local skip = only and not only[p[2] * 64 + p[1]]
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit and not skip then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end
-- folded ear (Scottish fold) flap, idleA coords, left; the right one is its mirror about x = 25
local function foldMask(c, ox, oy, dL, dR)
  local L = c:poly({ {11, 13}, {14, 9}, {19, 8.5}, {22.5, 11}, {21, 14}, {16, 16}, {12, 16} })
  local R = c:mask()
  L:each(function(x, y) R:set(50 - x, y) end)
  dL, dR = dL or { 0, 0 }, dR or { 0, 0 }
  return L:shift(ox + dL[1], oy + dL[2]), R:shift(ox + dR[1], oy + dR[2])
end
local Z = { 0, 0 }
local function catHead(c, ox, oy, eL, eR, ears, fL, fR)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local a, b = ox + eL[1], oy + eL[2]
  local earL = c:poly({ {10 + a, 21 + b}, {12 + a, 7 + b}, {23 + a, 13 + b} }):grow(1)
  a, b = ox + eR[1], oy + eR[2]
  local earR = c:poly({ {27 + a, 13 + b}, {38 + a, 7 + b}, {40 + a, 21 + b} }):grow(1)
  local list = {}
  if ears == "orig" then
    list[#list + 1] = { "earL", earL, g, { cres = 2, gloss = false } }
    list[#list + 1] = { "earR", earR, g, { cres = 2, gloss = false } }
  end
  list[#list + 1] = { "head", head, h, { gloss = { 14 + ox, 15 + oy } } }
  if ears == "fold" then
    local mL, mR = foldMask(c, ox, oy, fL, fR)
    list[#list + 1] = { "foldL", mL, g, { cres = 2, gloss = false } }
    list[#list + 1] = { "foldR", mR, g, { cres = 2, gloss = false } }
  end
  return list, head
end
local function eyeRing(c, x, y)
  c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, x - 1, y - 1, { u = "umber" })
end
local function catEye(c, x, y, mode)
  if mode == "happy" then c:paint({ ".uuu.", "uu.uu", "u...u" }, x, y + 1, { u = "umber" })
  elseif mode == "sleep" then c:paint({ "u...u", "uu.uu", ".uuu." }, x, y + 1, { u = "umber" })
  elseif mode == "squeezeL" then c:paint({ "uu...", "..uuu", "uu..." }, x, y + 1, { u = "umber" }) -- screwed shut: >
  elseif mode == "squeezeR" then c:paint({ "...uu", "uuu..", "...uu" }, x, y + 1, { u = "umber" }) -- <
  elseif mode == "half" then
    eyeRing(c, x, y); c:eye(x, y)
    c:paint({ ".bbbbb.", "bLLLLLb", "uuuuuuu" }, x - 1, y - 1, { b = GREY.base, L = GREY.light, u = "umber" })
  else eyeRing(c, x, y); c:eye(x, y) end
end
-- o.fy: eyes, nose and mouth moved fy px inside the head; o.mouth = "yawn": the big open mouth under the nose
local function catFace(c, ox, oy, head, eyes, eL, eR, ears, fL, fR, o)
  eL, eR, o = eL or Z, eR or Z, o or {}
  local fy = o.fy or 0
  if ears == "orig" then
    local a, b = ox + eL[1], oy + eL[2]
    c:fill(c:poly({ {13 + a, 18 + b}, {13 + a, 9 + b}, {21 + a, 14 + b} }):cut(head), PINK)
    a, b = ox + eR[1], oy + eR[2]
    c:fill(c:poly({ {29 + a, 14 + b}, {37 + a, 9 + b}, {37 + a, 18 + b} }):cut(head), PINK)
  elseif ears == "fold" then
    local mL, mR = foldMask(c, ox, oy, fL, fR)
    fL, fR = fL or Z, fR or Z
    local function crease(m, d, pts)
      for _, p in ipairs(pts) do
        local x, y = p[1] + ox + d[1], p[2] + oy + d[2]
        if m:has(x, y) and c:get(x, y) ~= GREY.shade then c:px(x, y, GREY.shade) end
      end
    end
    crease(mL, fL, { {13, 12}, {14, 12}, {15, 11}, {16, 11}, {17, 11}, {18, 11} })
    crease(mR, fR, { {37, 12}, {36, 12}, {35, 11}, {34, 11}, {33, 11}, {32, 11} })
  end
  if o.mouth == "yawn" then
    -- jaw dropped wide: umber rim, darker-umber throat, two cream fangs, pink tongue (shaded at the back);
    -- whisker pads (gloss) puff out either side of the top of the mouth
    c:paint({ "ppp", ".q." }, 24 + ox, 24 + oy + fy, { p = PINK, q = PINKS })
    c:paint({ "gg...........gg" }, 18 + ox, 26 + oy + fy, { g = GREY.gloss })
    c:paint({
      "...uuuuu...",
      ".uuhdddhuu.",
      "udddddddddu",
      "udddddddddu",
      "uddqqqqqddu",
      ".uqpppppqu.",
      "..uuuuuuu..",
    }, 20 + ox, 26 + oy + fy, { u = "ol3", d = "ol2", h = "halo", p = PINK, q = PINKS })
  else
    c:fill(c:ellipse(25 + ox, 27 + oy + fy, 3, 1.5), GREY.gloss)
    c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy + fy, { p = PINK, q = PINKS })
    c:paint({ "u.u" }, 24 + ox, 27 + oy + fy, { u = "ol2" })
  end
  local eyL, eyR = eyes, eyes
  if eyes == "squeeze" then eyL, eyR = "squeezeL", "squeezeR" end
  catEye(c, 14 + ox, 19 + oy + fy, eyL); catEye(c, 32 + ox, 19 + oy + fy, eyR)
end
local function paw(c, cx, cy, toes, rx, ry)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), coatHi(GREY), { flat = true })
  c.names[P] = "paw"
  if toes ~= false then c:paint({ "s.s", "s.s" }, math.floor(cx) - 1, math.floor(cy) + 1, { s = GREY.base }) end
  return P
end
local function tailTip(c, tail, region, seam) tint(c, region:clip(tail), GREY.base, GREY.light); c:seam(seam) end
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
local function build(c, list)
  local p = c:build(list)
  for n, P in pairs(p) do c.names[P] = n end
  return p
end
local function bobEntry(c, m) return { "bob", m, coat(GREY), { cres = 2, gloss = false } } end
local function newCanvas() local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }; c.names = {}; return c end
M.rell, M.foldMask = rell, foldMask
-- =========================================== end of copy ===========================================

-- per frame: head offset, ear offsets (orig ears), folded-flap offsets, bobtail centre, face shift
local OFF  = { yawn = { 0, -1 }, stretch = { 15, 9 }, washA = { 0, 0 }, washB = { 2, 3 } }
local EARS = { yawn = { { -1, 2 }, { 1, 2 } }, washB = { { 0, -1 }, { 1, 2 } } }
local FOLD = { yawn = { { 0, 2 }, { 0, 2 } }, washB = { { 0, -1 }, { 1, 2 } } } -- a flap rides with its ear (yawn: no splay)
local BOB  = { yawn = { 44.5, 50.5 }, stretch = { 11.5, 19 }, washA = { 44.5, 50.5 }, washB = { 44.5, 50.5 } }
local FY   = { yawn = -2 }
M.OFF, M.EARS, M.FOLD, M.BOB, M.FY = OFF, EARS, FOLD, BOB, FY
M.FRAMES = { "yawn", "stretch", "washA", "washB" }
M.CLOSED = { yawn = true, washA = true, washB = true }
M.HALF = { stretch = true }

local function tailEntry(c, f, o, tail)
  if o.tail == "orig" then return { "tail", tail, coat(GREY), { cres = 2, gloss = false } }
  elseif o.tail == "bob" then return bobEntry(c, c:ellipse(BOB[f][1], BOB[f][2], 4, 3.5)) end
end
local function headParts(c, f, o)
  local ox, oy = OFF[f][1], OFF[f][2]
  local eL, eR = EARS[f] and EARS[f][1], EARS[f] and EARS[f][2]
  local fL, fR = FOLD[f] and FOLD[f][1], FOLD[f] and FOLD[f][2]
  local H, head = catHead(c, ox, oy, eL, eR, o.ears, fL, fR)
  return H, head, { ox = ox, oy = oy, eL = eL, eR = eR, fL = fL, fR = fR, fy = FY[f] or 0 }
end

local FR = {}
-- ===== yawn: idle A sit, head tipped back (ears laid back, face up 2), eyes squeezed shut, mouth wide open =====
FR.yawn = function(o)
  local c = newCanvas()
  local g = coat(GREY)
  local H, head, I = headParts(c, "yawn", o)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tpts = { {38, 52}, {45, 52}, {50, 48}, {52, 42}, {53, 36}, {53, 30} } -- stretched straight up with the yawn
  local tail = c:line(tpts, 5)
  local list = {}
  list[#list + 1] = tailEntry(c, "yawn", o, tail)
  list[#list + 1] = { "body", body, g, { gloss = { 15, 40 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(46, 22, 58, 31), { { 50, 32 }, { 56, 32 } }) end
  paw(c, 19.5, 53); paw(c, 30.5, 53)
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, I.ox, I.oy, head, "squeeze", I.eL, I.eR, o.ears, I.fL, I.fR, { fy = I.fy, mouth = "yawn" })
  I.tpts, I.p = tpts, p
  return c, I
end

-- ===== stretch: rump high on straight hind legs, long sloping back, forelegs reaching forward, half-lidded =====
FR.stretch = function(o)
  local c = newCanvas()
  local g = coat(GREY)
  local H, head, I = headParts(c, "stretch", o)
  local A = 0.62
  local body = rell(c, 22, 32, 17.5, 8, A)                                 -- long back from the high rump to the chest
  local hpts, bpts = { {13, 27}, {13, 40}, {14, 50} }, { {21, 34}, {22, 43}, {23, 50} }
  local legH = c:line(hpts, 6)                                              -- near hind leg, straight
  local legB = c:line(bpts, 4)                                              -- far hind leg
  local fpts, npts = { {33, 41}, {40, 47}, {44, 51} }, { {31, 44}, {40, 50}, {50, 53} }
  local legF = c:line(fpts, 4)                                              -- far foreleg, reaching
  local legN = c:line(npts, 5)                                              -- near foreleg, reaching flat along the floor
  local tpts = { {12, 21}, {9, 16}, {9, 11}, {12, 8}, {16, 8} }            -- up off the rump, tip curled over
  local tail = c:line(tpts, 5)
  local list = {
    { "legB", legB, g, { cres = 2, gloss = false } },
    { "legF", legF, g, { cres = 2, gloss = false } },
    { "legH", legH, g, { cres = 2, gloss = false } },
  }
  list[#list + 1] = tailEntry(c, "stretch", o, tail)
  list[#list + 1] = { "body", body, g, { gloss = { 12, 22 } } }
  list[#list + 1] = { "legN", legN, g, { cres = 2, gloss = false } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(8, 2, 24, 9), { { 11, 10 }, { 15, 10 } }) end
  paw(c, 14.5, 53); paw(c, 23.5, 53)                                        -- hind paws planted
  paw(c, 45.5, 51.5, true, 4, 2.5); paw(c, 52, 53.5)                        -- front paws far forward
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, I.ox, I.oy, head, "half", I.eL, I.eR, o.ears, I.fL, I.fR)
  I.tpts, I.p, I.A, I.hpts, I.bpts, I.fpts, I.npts = tpts, p, A, hpts, bpts, fpts, npts
  return c, I
end

-- ===== wash: idle A sit, near forepaw raised to the face, eyes closed; washB bends the head to lick it =====
local function wash(f, o)
  local c = newCanvas()
  local g = coat(GREY)
  local H, head, I = headParts(c, f, o)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tpts = { {38, 52}, {45, 52}, {50, 49}, {52, 44}, {53, 39}, {52, 34} } -- curled up and out
  local tail = c:line(tpts, 5)
  local list = {}
  list[#list + 1] = tailEntry(c, f, o, tail)
  list[#list + 1] = { "body", body, g, { gloss = { 15, 40 } } }
  for _, e in ipairs(H) do list[#list + 1] = e end
  local p = build(c, list)
  if o.tail == "orig" then tailTip(c, tail, c:rect(46, 26, 60, 35), { { 50, 36 }, { 55, 36 } }) end
  paw(c, 19.5, 53)                                                          -- the other forepaw on the floor
  paw(c, 30.5, 53.5, true, 4, 2)                                            -- hind foot peeking out
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, I.ox, I.oy, head, "sleep", I.eL, I.eR, o.ears, I.fL, I.fR)
  local apts
  if f == "washA" then
    apts = { {31, 48}, {35, 41}, {36, 34} }
    local A = c:part(c:line(apts, 6), g, { cres = 2, gloss = false }); c.names[A] = "legN"
    paw(c, 36.5, 29, false, 4.5, 4)                                         -- up at the cheek
    c:paint({ "s", ".", "s", ".", "s" }, 33, 27, { s = GREY.base })         -- toes toward the face
  else
    apts = { {31, 48}, {33, 42}, {33, 37} }
    local A = c:part(c:line(apts, 5), g, { cres = 2, gloss = false }); c.names[A] = "legN"
    paw(c, 33, 33, false, 4, 3.5)                                           -- at the mouth
    c:paint({ "s", ".", "s" }, 30, 32, { s = GREY.base })
    c:paint({ "pp", "qpp", ".q" }, 27, 31, { p = PINK, q = PINKS })         -- tongue out onto the paw
  end
  I.tpts, I.p, I.apts = tpts, p, apts
  return c, I
end
FR.washA = function(o) return wash("washA", o) end
FR.washB = function(o) return wash("washB", o) end
M.FR = FR

if CF_S4_LIB then return M end

-- ===== save the grey bases =====
for _, f in ipairs(M.FRAMES) do
  local c = FR[f]({ ears = "orig", tail = "orig" })
  local name = "cf-cat-grey-" .. f
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-8s ", f) .. GV.report(t))
  assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24, name .. ": check failed")
end
return M

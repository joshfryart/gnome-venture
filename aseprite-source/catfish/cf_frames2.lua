-- cf_frames2.lua : Cat Fish step 2 (claude/catfish-art-brief.md): the last 3 grey cat body frames, Stitched Toy.
-- Run: AppRun -b --script cf_frames2.lua      Writes test/cf-cat-grey-<wiggle|bored|idleB>.png + .aseprite.
-- Same template as cf_test.lua pass 6 (the 4 grey tones, fixed accents, separate tail/ear/body/head/paw parts,
-- edge stitch on the lit half only, eyes as the locked disc with an umber ring). The shared head, face, paw
-- and tail-tip code below is a clean copy of cf_test.lua's (cf_test.lua runs all its art when loaded, so it
-- cannot be dofile'd); catHead/catFace gain optional per-ear offsets and catEye a "half" (half-lidded) mode.
-- With the ear offsets left at 0 they draw exactly what cf_test.lua draws.
--
-- Frame offsets (head, eyes; add to idle A's eye boxes at 14,19 and 32,19):
--   wiggle 15,19  (eyes open)   bored -1,3  (half-lidded: no eye-colour overlay)   idleB 1,1  (eyes open)
-- wiggle: butt-wiggle before the pounce. Chest and chin down on the front paws, rump hiked high on two straight
--   hind legs, tail straight up with a hooked tip (stalk keeps its rump on a crouched haunch, tail out behind).
-- bored: sitting slumped (head sunk 3 px into the shoulders, wider bottom-heavy body, ears drooped out to the
--   sides), half-lidded eyes, one front paw raised to the mouth and licked (2 px pink tongue), tail lying out
--   along the floor with only the tip flicked up.
-- idleB: idle A with the head tilted (shifted 1,1, the left ear dipped 1 px lower than the right) and the tail
--   tip swung 3 px in toward the head; body and paws do not move, so A/B alternate as a breath and a tail sway.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

local GREY = { shade = "#57516f", base = "#8a859b", light = "#cdc9d3", gloss = "#f1ebe3" }
local function coat(t) return { gloss = t.gloss, dot = t.gloss, rim = t.light, base = t.base, shade = t.shade, deep = t.shade, bounce = t.base } end
local function coatHi(t) return { gloss = t.gloss, dot = t.gloss, rim = t.gloss, base = t.light, shade = t.base, deep = t.shade, bounce = t.light } end
local PINK, PINKS = "#e8909e", "#c66a80"
local LIT = 3

-- ===================== shared template (copy of cf_test.lua pass 6) =====================
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
  for i, p in ipairs(ring) do
    local k = p[3]
    local lit = (p[1] - cx) + (p[2] - cy) <= (o.lit or 1e9)
    if (i - 1) % (on + off) < on and c.own[k] == P and not c.gl.s[k] and p[2] <= (o.ymax or 1e9) and lit then
      c.pix[k] = c.shd[k] and GV.C.goldS or GV.C.gold
    end
  end
end
-- eL, eR: optional {dx, dy} extra offsets for the left / right ear (and its inner pink)
local Z = { 0, 0 }
local function catHead(c, ox, oy, eL, eR)
  eL, eR = eL or Z, eR or Z
  local g, h = coat(GREY), coatHi(GREY)
  local head = c:ellipse(25 + ox, 20.5 + oy, 15, 9.5):add(c:ellipse(25 + ox, 24.5 + oy, 15.5, 7.5))
  local a, b = ox + eL[1], oy + eL[2]
  local earL = c:poly({ {10 + a, 21 + b}, {12 + a, 7 + b}, {23 + a, 13 + b} }):grow(1)
  a, b = ox + eR[1], oy + eR[2]
  local earR = c:poly({ {27 + a, 13 + b}, {38 + a, 7 + b}, {40 + a, 21 + b} }):grow(1)
  return {
    { "earL", earL, g, { cres = 2, gloss = false } },
    { "earR", earR, g, { cres = 2, gloss = false } },
    { "head", head, h, { gloss = { 14 + ox, 15 + oy } } },
  }, head
end
local function eyeRing(c, x, y)
  c:paint({ "..uuu..", ".u...u.", "u.....u", "u.....u", "u.....u", ".u...u.", "..uuu.." }, x - 1, y - 1, { u = "umber" })
end
local function catEye(c, x, y, mode)
  if mode == "happy" then c:paint({ ".uuu.", "uu.uu", "u...u" }, x, y + 1, { u = "umber" })
  elseif mode == "sleep" then c:paint({ "u...u", "uu.uu", ".uuu." }, x, y + 1, { u = "umber" })
  elseif mode == "half" then
    -- half-lidded (bored): the locked disc and ring, then the upper lid pulled down over the top two rows:
    -- head felt with a base-tone crease, and a full-width umber lash line across the pupil's top row
    eyeRing(c, x, y); c:eye(x, y)
    c:paint({
      ".bbbbb.",
      "bLLLLLb",
      "uuuuuuu",
    }, x - 1, y - 1, { b = GREY.base, L = GREY.light, u = "umber" })
  else eyeRing(c, x, y); c:eye(x, y) end
end
local function catFace(c, ox, oy, head, eyes, eL, eR)
  eL, eR = eL or Z, eR or Z
  local a, b = ox + eL[1], oy + eL[2]
  c:fill(c:poly({ {13 + a, 18 + b}, {13 + a, 9 + b}, {21 + a, 14 + b} }):cut(head), PINK)
  a, b = ox + eR[1], oy + eR[2]
  c:fill(c:poly({ {29 + a, 14 + b}, {37 + a, 9 + b}, {37 + a, 18 + b} }):cut(head), PINK)
  c:fill(c:ellipse(25 + ox, 27 + oy, 3, 1.5), GREY.gloss)
  c:paint({ "ppp", ".q." }, 24 + ox, 25 + oy, { p = PINK, q = PINKS })
  c:paint({ "u.u" }, 24 + ox, 27 + oy, { u = "ol2" })
  catEye(c, 14 + ox, 19 + oy, eyes); catEye(c, 32 + ox, 19 + oy, eyes)
end
local function paw(c, cx, cy, toes, rx, ry)
  local P = c:part(c:ellipse(cx, cy, rx or 4.5, ry or 2.5), coatHi(GREY), { flat = true })
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
local results = {}
local function catSave(c, name)
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local line = string.format("%-6s ", name:match("grey%-(.*)$")) .. GV.report(t)
  print(line)
  assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24, name .. ": check failed")
  results[#results + 1] = line
  return t
end
-- ======================================= end of copy =======================================

-- ===== idle B: idle A breathing, head tilted 1 px, tail tip swung in =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 1, 1
  local EL, ER = { -1, 1 }, { 0, -1 } -- tilt: left ear dips, right ear stays up (net of the 1 px head drop)
  local H, head = catHead(c, OX, OY, EL, ER)
  local body = c:ellipse(25, 46.5, 15, 8.5):add(c:ellipse(25, 41, 12, 8))
  local tail = c:line({ {38, 52}, {45, 52}, {50, 49}, {52, 44}, {52, 39}, {50, 34}, {47, 32} }, 5)
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 15, 40 } } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(40, 26, 56, 34), { { 49, 35 }, { 54, 35 } })
  paw(c, 19.5, 53); paw(c, 30.5, 53)
  edgeStitch(c, body, p.body, { cy = 45, lit = LIT })
  catFace(c, OX, OY, head, "open", EL, ER)
  catSave(c, "cf-cat-grey-idleB")
end

-- ===== bored: slumped sit, half-lidded, licking a raised paw, tail out flat with the tip flicked =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = -1, 3
  local EL, ER = { -2, 2 }, { 2, 2 } -- ears drooped out to the sides
  local H, head = catHead(c, OX, OY, EL, ER)
  local body = c:ellipse(25, 47.5, 16, 8):add(c:ellipse(25, 43, 12, 7)) -- bottom-heavy, shoulders dropped
  local tail = c:line({ {38, 53}, {47, 54}, {51, 52}, {53, 48}, {53, 45} }, 5) -- flat on the floor, tip flicked up
  local arm = c:line({ {31, 47}, {33, 41}, {33, 37} }, 5)               -- raised foreleg, in front of the body
  local p = c:build{
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 15, 41 } } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(49, 38, 60, 47), { { 50, 48 }, { 56, 48 } })
  paw(c, 18.5, 54)                                                         -- the other front paw on the floor
  paw(c, 29.5, 54.5, true, 4, 2)                                           -- hind foot peeking out
  edgeStitch(c, body, p.body, { cy = 46, lit = LIT })
  catFace(c, OX, OY, head, "half", EL, ER)
  c:part(arm, g, { cres = 2, gloss = false })
  paw(c, 32, 33, false, 4, 3.5)                                            -- licked paw up at the mouth
  c:paint({ "s", ".", "s" }, 29, 32, { s = GREY.base })                    -- toes face the mouth
  c:paint({ "pp", "qp" }, 27, 31, { p = PINK, q = PINKS })                 -- tongue out to the paw
  catSave(c, "cf-cat-grey-bored")
end

-- ===== wiggle: chest down, rump hiked high on straight hind legs, tail straight up =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local g = coat(GREY)
  local OX, OY = 15, 19
  local H, head = catHead(c, OX, OY)
  local body = rell(c, 22, 31, 16, 9.5, 0.95)                             -- plump back sloping from a high rump
  local legH = c:line({ {14, 31}, {15, 42}, {17, 50} }, 6)                -- hind legs straight, under the rump
  local legB = c:line({ {22, 37}, {24, 44}, {25, 50} }, 4)
  local tail = c:line({ {16, 22}, {14, 16}, {14, 12}, {16, 9}, {19, 9} }, 5) -- straight up, hooked tip
  local p = c:build{
    { "legB", legB, g, { cres = 2, gloss = false } },
    { "legH", legH, g, { cres = 2, gloss = false } },
    { "tail", tail, g, { cres = 2, gloss = false } },
    { "body", body, g, { gloss = { 14, 24 } } },
    H[1], H[2], H[3],
  }
  tailTip(c, tail, c:rect(8, 2, 24, 11), { { 11, 12 }, { 17, 12 } })
  paw(c, 25.5, 53); paw(c, 17.5, 53)                                       -- hind paws planted
  paw(c, 34.5, 53); paw(c, 45.5, 53)                                       -- front paws under the chin
  edgeStitch(c, body, p.body, { lit = LIT })
  catFace(c, OX, OY, head, "open")
  catSave(c, "cf-cat-grey-wiggle")
end

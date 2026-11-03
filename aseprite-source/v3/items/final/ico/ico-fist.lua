-- ico-fist (final, Opus single pass). A raised fist seen from the front: four curled fingers as rounded columns
-- (middle one tallest), the thumb wrapped across them with a glossy nail, a slim wrist and a rolled cloth cuff.
-- Material: per-pixel pillow light on each finger (6-tone skin, warm hi, cool-violet shade), knuckle highlights,
-- skin creases, AO in the gaps between fingers and a contact shadow cast by the thumb; cuff has a diagonal weave,
-- a fold groove and one gold stitched hem.
-- quirk: a red reminder thread is tied in a bow around the index finger.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("ico-fist")

local SKIN = { "#6a3330", "#a2584a", "#cf8466", "#eeaa84", "#ffcca4", "#ffe6c8" }
local NAIL = { "#b06a68", "#e0a09a", "#f8cfc4", "#fff0e6" }
local CUFF = { "#232a52", "#2f3f78", "#3f5ea0", "#5a82c4", "#82aee0", "#b6d6f4" }
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }

-- masks
local wrist = c:rrect(22, 38, 40, 52, 3)
local palm = c:rrect(15, 25, 46, 45, 7)
local fingers = {
  { x0 = 16, x1 = 22, top = 18 },
  { x0 = 23, x1 = 29, top = 14 },
  { x0 = 30, x1 = 36, top = 19 },
  { x0 = 37, x1 = 43, top = 19 },
}
local fall = HP.mask()
for _, f in ipairs(fingers) do
  f.m = c:rrect(f.x0, f.top, f.x1, 34, 3)
  fall:add(f.m)
end
local thumbP = { { 14, 37 }, { 21, 34 }, { 30, 32 }, { 38, 31 } }
local thumb, tn, TT, TS = A.tube(thumbP, function(t) return 4.4 - 0.9 * t end)
local cuff = c:rrect(19, 48, 43, 57, 2)

-- wrist (behind everything), AO under the palm and above the cuff
do
  local b = {}
  X.ao(b, wrist, palm, 2, -1) X.ao(b, wrist, cuff, 1, -1)
  A.shade(c, wrist, X.pillow(wrist, 4), SKIN, { cuts = CUTS, bias = b, tok = A.tok("wrist") })
end
-- palm / back of the hand
do
  local b = {}
  X.ao(b, palm, fall, 1, -2)
  A.shade(c, palm, X.pillow(palm, 6), SKIN, { cuts = CUTS, bias = b, tok = A.tok("palm") })
end
-- fingers
for i, f in ipairs(fingers) do
  local b = {}
  A.cast(b, f.m, thumb, 1, 2, -1)
  X.ao(b, f.m, thumb, 1, -1)
  local tok = A.tok("finger" .. i)
  local idx = A.shade(c, f.m, X.pillow(f.m, 3.2), SKIN, { cuts = CUTS, bias = b, tok = tok,
    tilt = { 30, 22, 30, 0.08 } })
  -- knuckle: lit 2x1 on the upper-left of the top, crease pair below it
  c:put(f.x0 + 2, f.top + 2, SKIN[6], tok) c:put(f.x0 + 3, f.top + 2, SKIN[6], tok)
  local cy = f.top + 7
  A.step(c, idx, SKIN, f.x0 + 2, cy, -2, tok) A.step(c, idx, SKIN, f.x0 + 3, cy, -2, tok)
  A.step(c, idx, SKIN, f.x0 + 4, cy + 1, -2, tok)
end
-- thumb (on top), nail at its tip
do
  local b = {}
  thumb:each(function(x, y) local k = K(x, y) if TT[k] < 0.08 then b[k] = -1 end end)
  local tok = A.tok("thumb")
  local idx = A.shade(c, thumb, tn, SKIN, { cuts = CUTS, bias = b, tok = tok })
  -- knuckle crease of the thumb
  for _, p in ipairs{ { 26, 31 }, { 26, 32 }, { 27, 33 } } do A.step(c, idx, SKIN, p[1], p[2], -2, tok) end
  local nail = A.ell(37, 31, 2.6, 2.1)
  local ntok = A.tok("nail")
  nail:each(function(x, y)
    if thumb:has(x, y) then
      local col = NAIL[2]
      if x + y < 66 then col = NAIL[3] end
      if x - 37 > 1 or y - 31 > 1 then col = NAIL[1] end
      c:put(x, y, col, ntok)
    end
  end)
  c:put(36, 30, NAIL[4], ntok) c:put(37, 30, NAIL[4], ntok)
end
-- cuff: rolled cloth with weave and a fold groove
do
  local b = {}
  cuff:each(function(x, y) local k = K(x, y)
    if (x + y) % 3 == 0 then b[k] = -1 end
    if y == 52 then b[k] = -2 elseif y == 51 then b[k] = 1 end
  end)
  A.shade(c, cuff, X.pillow(cuff, 3), CUFF, { cuts = CUTS, bias = b, tok = A.tok("cuff") })
  c:stitch{ { 21, 55 }, { 41, 55 } }
end

-- quirk: red reminder thread tied round the index finger, bow loops sticking out to the left
local THR = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local ttok = A.tok("thread")
for x = 16, 22 do
  local yy = 24 + floor((x - 16) / 4)
  c:put(x, yy, (x % 2 == 0) and THR[3] or THR[2], ttok)
  c:put(x, yy + 1, (x % 2 == 0) and THR[1] or THR[2], ttok)
end
A.map(c, {
  "hRR..",
  "R.RR.",
  "hRRKk",
  "R.rr.",
  "rrr..",
}, 12, 22, { h = THR[4], R = THR[3], r = THR[2], K = THR[2], k = THR[1] }, ttok)

A.save(c, "ico-fist")

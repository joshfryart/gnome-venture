-- ico-bear (final, Opus). A brown bear sitting up, front view: chunky round head with round ears, pale muzzle,
-- pear-shaped body with a lighter belly, stubby arms resting at the sides and two feet out front showing pads.
-- Material: fur lit per pixel (6-tone brown) with short strand dashes and tufted cheeks, contact shade under the
-- head and behind the arms, inner ears, muzzle with a lit top, ink nose with a cream glint and a dark underside,
-- pink-brown paw pads (one big pad + three toe beans).
-- quirk: a bumblebee has stopped for a rest on the bear's ear.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-bear")
local FUR = { "#3a1f22", "#5a3026", "#7d4630", "#a2623c", "#c4824e", "#e2a868" }
local TAN = { "#8a5a40", "#b07c58", "#d2a276", "#ecc698", "#f8e2bc" }
local PAD = { "#5e3236", "#8a4c50", "#b06c6a" }
local ftok = { r = { name = "fur" } }
local function strands(m, idx, seed)
  m:each(function(x, y)
    if X.hash(x, y, seed) > 0.93 and m:has(x + 1, y + 1) and idx[K(x, y)] and idx[K(x, y)] > 2 then
      A.step(c, idx, FUR, x, y, -1, ftok) A.step(c, idx, FUR, x + 1, y + 1, -1, ftok)
    end
  end)
end

c:groundShadow(32, 55, 15, 2)
-- body (pear)
local body = A.ellM(31.5, 43, 11.5, 10):add(A.ellM(31.5, 37, 9, 7))
local bn = X.pillow(body, 5)
local bb = {}
local bidx = A.shade(c, body, bn, FUR, { tok = ftok, bias = bb, amb = 0.05, wrap = 0.2 })
strands(body, bidx, 3)
-- belly
local belly = A.ellM(31.5, 44, 6.5, 6.2)
local bln = X.pillow(belly, 3)
A.shade(c, belly, bln, { FUR[3], FUR[4], FUR[5], TAN[2], TAN[3], TAN[4] }, { tok = ftok, amb = 0.1, wrap = 0.3 })
-- arms resting at the sides (over body), contact shade behind
local arms = {}
for _, sx in ipairs{ -1, 1 } do
  local am = HP.mask()
  local cx = 31.5 + sx * 9.5
  am:add(A.ellM(cx, 42, 3.6, 6.2))
  arms[#arms + 1] = am
  local ring = am:grow(1):cut(am)
  ring:each(function(x, y) if body:has(x, y) and (sx < 0 and x > cx or sx > 0 and x < cx) then c:put(x, y, FUR[1], ftok) end end)
  local an = X.pillow(am, 2.5)
  local aidx = A.shade(c, am, an, FUR, { tok = ftok, amb = 0.06, wrap = 0.22 })
  -- claw ticks at the paw end
  for i = -1, 1 do c:put(floor(cx + i + 0.5), 47, FUR[1], ftok) end
end
-- feet out front with pads
for _, sx in ipairs{ -1, 1 } do
  local cx = 31.5 + sx * 7
  local fm = A.ellM(cx, 52, 5, 3.4)
  local fn = X.pillow(fm, 2)
  A.shade(c, fm, fn, FUR, { tok = ftok, amb = 0.08, wrap = 0.25 })
  local px = floor(cx + 0.5)
  A.map(c, {
    ".a.a.a.",
    "..bbb..",
    ".bbbbc.",
    "..ccc..",
  }, px - 3, 49, { a = PAD[2], b = PAD[2], c = PAD[1] }, ftok)
  c:put(px - 1, 51, PAD[3], ftok)
end
-- contact shade along the top of the feet
local feet = A.ellM(31.5 - 7, 52, 5, 3.4):add(A.ellM(31.5 + 7, 52, 5, 3.4))
feet:grow(1):cut(feet):each(function(x, y) if body:has(x, y) and y < 52 then c:put(x, y, FUR[1], ftok) end end)

-- ears (behind head)
local etok = ftok
for _, sx in ipairs{ -1, 1 } do
  local cx = 31.5 + sx * 9
  local em = A.ellM(cx, 12, 4, 4)
  local en = X.sphere(cx - 0.5, 11.5, 4.5, em)
  A.shade(c, em, en, FUR, { tok = etok, amb = 0.06, wrap = 0.25 })
  local im = A.ellM(cx + sx * 0.0, 12.6, 2, 2)
  im:each(function(x, y) c:put(x, y, (y < 12) and TAN[1] or PAD[1], etok) end)
end
-- head
local head = A.ellM(31.5, 22, 11, 9.5)
-- cheek tufts
head:add(c:poly{ { 21, 25 }, { 20, 28 }, { 24, 27 } }):add(c:poly{ { 42, 25 }, { 43, 28 }, { 39, 27 } })
local hn = X.pillow(head, 5)
local hidx = A.shade(c, head, hn, FUR, { tok = ftok, amb = 0.06, wrap = 0.22 })
strands(head, hidx, 9)
-- contact shade under the chin on the body
for x = 22, 41 do local y = 32
  if body:has(x, y) and not head:has(x, y) then c:put(x, y, FUR[1], ftok) if body:has(x, y + 1) then c:put(x, y + 1, FUR[2], ftok) end end
end
-- muzzle
local muz = A.ellM(31.5, 26, 5, 3.6)
local mn = X.pillow(muz, 2.2)
A.shade(c, muz, mn, TAN, { tok = ftok, amb = 0.12, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- nose: rounded ink, cream glint, dark underside row on the muzzle
A.map(c, {
  "KgKKK.",
  "KKKKKK",
  ".KKKK.",
}, 29, 23, { K = A.INK, g = A.CREAM })
c:put(31, 26, TAN[1]) c:put(32, 26, TAN[1])
c:put(31, 27, A.INK) c:put(32, 27, A.INK)
c:put(30, 28, A.INK) c:put(33, 28, A.INK)
-- eyes + brow tone
c:eyeSmall(25, 18) c:eyeSmall(37, 18)
c:put(24, 17, FUR[3]) c:put(25, 16, FUR[3]) c:put(38, 16, FUR[3]) c:put(39, 17, FUR[3])

-- quirk: a bumblebee resting on the right ear
A.map(c, {
  ".cc.",
  "cWWc",
  "YKYKd",
  "YKYKd",
  ".dd.",
}, 42, 8, { c = "#c9e8f0", W = "#fff4d6", Y = "#f5b82e", K = A.INK, d = "#8f4a1f" })

A.save(c, "ico-bear")

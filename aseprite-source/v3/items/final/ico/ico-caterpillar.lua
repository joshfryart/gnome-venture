-- ico-caterpillar (final pass, Opus). Lime caterpillar inching along a bare twig: tail and front legs gripping,
-- middle segments arched up in a hump, round head raised to look at the viewer. Body: per-segment sphere light,
-- 6-tone lime with cool teal shade, AO + deep seam where each segment tucks under the next, gold spot and
-- dark spiracle per segment, pale belly line, ink prolegs. Twig: 6-tone bark tube with grain streaks, a knot,
-- a pale cut end grain, and a snapped side twiglet with a pale break.
-- quirk: a single dewdrop is balanced on top of the hump.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-caterpillar")
local BODY = { "#1c4640", "#256a48", "#3f9446", "#6cbc42", "#a2dc56", "#dcf59a" }
local BARK = { "#3e2428", "#5e3a2c", "#82553a", "#a5744a", "#c99862", "#e8c48c" }
local LEAF = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local btok, ttok = A.tok("body"), A.tok("twig")

-- twig
local tp = { { 9, 51.5 }, { 23, 49 }, { 38, 53 }, { 53, 49.5 } }
local tm, tn, TT, TS = A.tube(tp, function(t) return 2.5 - t * 0.4 end)
local tidx = A.shade(c, tm, tn, BARK, { tok = ttok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
tm:each(function(x, y) local k = K(x, y)
  local s = TS[k]
  if X.hash(floor(x / 3), floor(s * 3 + 3), 2) < 0.35 and abs(s) < 0.8 then A.step(c, tidx, BARK, x, y, -1, ttok) end
end)
-- knot
A.map(c, { ".k.", "kKk" }, 17, 50, { k = BARK[2], K = BARK[1] }, ttok)
c:put(17, 50, BARK[5], ttok)
-- cut end grain (right end): pale disc with a ring
local ex, ey = 53, 49.5
local endm = A.ell(ex + 0.3, ey, 1.3, 2.0)
endm:each(function(x, y) c:put(x, y, BARK[6], ttok) end)
c:put(53, 49, BARK[5], ttok) c:put(53, 50, BARK[4], ttok) c:put(54, 51, BARK[4], ttok)
-- a snapped side twiglet stub pointing down-left, pale break
local st = c:line({ { 30, 53 }, { 27, 56 } }, 2)
st:each(function(x, y) c:put(x, y, x < 28 and BARK[3] or BARK[2], ttok) end)
c:put(27, 56, BARK[6], ttok) c:put(26, 56, BARK[5], ttok)

-- segments, tail -> head; each later one covers the one before
local segs = {
  { 12, 45.5, 3.3 }, { 17, 44, 3.9 }, { 21.5, 39.5, 4.2 }, { 26, 35, 4.4 },
  { 31, 33.5, 4.5 }, { 36, 35.5, 4.4 }, { 40.5, 40, 4.2 }, { 44, 42.5, 3.9 },
}
local all = HP.mask()
local masks, idxs = {}, {}
-- prolegs first (behind)
for _, i in ipairs{ 1, 2, 7, 8 } do
  local s = segs[i]
  local lx = floor(s[1]) - 1
  A.map(c, { "lL", "lL", "kk" }, lx, floor(s[2] + s[3]) - 0, { l = "#3a6a4a", L = "#24544a", k = "#2b1c26" }, btok)
end
for i, s in ipairs(segs) do
  local m = A.ell(s[1], s[2], s[3], s[3] * 0.95)
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3] + 0.3, m)
  local idx = A.shade(c, m, n, BODY, { tok = btok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.82 }, amb = 0.06 })
  -- pale belly line
  m:each(function(x, y) if y >= s[2] + s[3] - 1.6 and not m:has(x, y + 1) == false and y > s[2] + s[3] * 0.55 then
    if abs(x - s[1]) < s[3] * 0.5 then A.step(c, idx, BODY, x, y, 1, btok) end end end)
  -- gold spot + spiracle
  local gx, gy = floor(s[1] - 0.5), floor(s[2] - s[3] * 0.25)
  if i >= 2 then
    c:put(gx, gy - 1, "#f5b82e", btok) c:put(gx + 1, gy - 1, "#ffe38a", btok) c:put(gx, gy, "#d98322", btok) c:put(gx + 1, gy, "#f5b82e", btok)
    c:put(floor(s[1] + 0.5), floor(s[2] + s[3] * 0.45), "#24544a", btok)
  end
  -- deep seam on this segment where the previous one meets it (contact shadow onto the previous)
  if i > 1 then
    local pm, pidx = masks[i - 1], idxs[i - 1]
    pm:each(function(x, y) if not m:has(x, y) and (m:has(x + 1, y) or m:has(x, y + 1) or m:has(x - 1, y) or m:has(x, y - 1)) then c:put(x, y, BODY[1], btok) end end)
    A.ao(c, pidx, BODY, pm, m:grow(1), 1, -1, btok)
  end
  masks[i], idxs[i] = m, idx
  all:add(m)
end

-- head
local HX, HY, HR = 48.5, 34.5, 6.5
local head = A.ell(HX, HY, HR, HR - 0.3)
-- antennae (behind head)
for _, a in ipairs{ { { 45, 29 }, { 43, 23 } }, { { 52, 29 }, { 54, 23 } } } do
  local am = c:line({ a[1], a[2] }, 2)
  am:each(function(x, y) c:put(x, y, x < (a[1][1] + a[2][1]) / 2 + 0.5 and BODY[3] or BODY[2], btok) end)
  local kx, ky = a[2][1], a[2][2]
  A.map(c, { ".hb", "hbb", "bbd" }, kx - 1, ky - 2, { h = "#ff9a78", b = "#e8493b", d = "#b52e3f" }, btok)
end
local hidx = A.shade(c, head, X.sphere(HX - 0.4, HY - 0.4, HR + 0.6, head), BODY, { tok = btok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.82 }, amb = 0.08 })
masks[8]:each(function(x, y) if not head:has(x, y) and head:grow(1):has(x, y) then c:put(x, y, BODY[1], btok) end end)
A.ao(c, idxs[8], BODY, masks[8], head:grow(1), 1, -1, btok)
-- face: eyes, cheeks, smile
c:eyeSmall(45, 32) c:eyeSmall(50, 32)
c:cheek(43, 36) c:cheek(52, 36)
A.map(c, { "k...k", ".kkk." }, 46, 36, { k = "#2b1c26" })
-- head shine
c:put(45, 30, BODY[6]) c:put(46, 30, BODY[6])

-- quirk: dewdrop on the hump (glass: bright rim, pale core, dark lower rim)
A.map(c, {
  ".rr.",
  "rcCr",
  "rcsr",
  ".dd.",
}, 29, 26, { r = "#5fc4c8", c = "#b6f0e0", C = "#fff4d6", s = "#8fdcd8", d = "#3a86b0" }, A.tok("drop"))
-- contact shadow under the drop on the segment
c:put(29, 30, BODY[2], btok) c:put(32, 30, BODY[2], btok)

A.save(c, "ico-caterpillar")

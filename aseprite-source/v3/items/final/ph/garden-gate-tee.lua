-- garden-gate-tee (final pass, Opus single pass). A rustic split-log fence T-junction in a light 3/4 view: one long run
-- of two round log rails across the back between slim posts, and a branch run that comes TOWARD the viewer from the
-- tall junction post down to a bigger front post (posts grow 4 -> 5 -> 6 px with depth). Material: per-pixel cylinder
-- light on every log, bark streaks along the axis with pale flecks, sawn end grain with rings on each post top,
-- AO where rails enter posts, contact shadow under the branch rails on the junction post, 2-tone ground shadows.
-- quirk: two little orange bracket fungi have sprouted on the shady side of the junction post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("garden-gate-tee")
c:groundShadow(31, 45, 24, 2)
c:groundShadow(49, 57, 6, 1)

local B = A.BARK
local function bark(m, idx, T, S, len, w, tok, seed)
  m:each(function(x, y)
    local k = K(x, y)
    local i = idx[k] if not i then return end
    local band = floor((S[k] + 1) * w + 0.5)
    local seg = floor(T[k] * len / 3 + band * 0.5)
    local h = X.hash(band, seg, seed)
    if h > 0.62 and i > 1 then c:put(x, y, B[i - 1], tok)
    elseif h < 0.07 and i < 6 and S[k] < 0.3 then c:put(x, y, B[i + 1], tok) end
  end)
end
local function vpost(x0, x1, y0, y1, seed, bias)
  local w = (x1 - x0) / 2
  local cx = (x0 + x1) / 2
  local m, idx, T, S, tok = A.pole(c, cx, y0, cx, y1, function() return w end, B, { bias = bias, name = "post" .. seed, amb = 0.1 })
  bark(m, idx, T, S, y1 - y0, w + 1, tok, seed)
  -- sawn top: end grain ellipse with a ring and a dark heart
  local OAKP = A.OAK
  for x = x0, x1 do
    local edge = (x == x0 or x == x1)
    c:put(x, y0 - 1, edge and OAKP[4] or OAKP[6], tok)
    c:put(x, y0, edge and OAKP[3] or OAKP[5], tok)
  end
  for x = x0 + 1, x1 - 1 do c:put(x, y0 - 2, OAKP[5], tok) end
  local mid = floor(cx)
  c:put(mid, y0 - 1, OAKP[4], tok) if x1 - x0 >= 4 then c:put(mid + 1, y0 - 1, OAKP[5], tok) c:put(mid - 1, y0 - 1, OAKP[5], tok) end
  for x = x0, x1 do c:put(x, y0 + 1, B[2], tok) end -- bark lip shadow under the cut
  return m, tok
end
local function rail(ax, ay, bx, by, r, seed, bias)
  local m, idx, T, S, tok = A.pole(c, ax, ay, bx, by, function(t) return r end, B, { bias = bias, name = "rail" .. seed, amb = 0.12 })
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  bark(m, idx, T, S, len, r + 1, tok, seed)
  return m, tok
end

-- masks first, for AO
local pL = c:rect(7, 21, 10, 45)
local pJ = c:rect(29, 13, 33, 48)
local pR = c:rect(54, 21, 57, 45)
local pF = c:rect(46, 36, 51, 57)
local posts = pL:copy():add(pJ):add(pR)

-- back run rails
for i, ry in ipairs{ 26, 36 } do
  local b = {}
  A.cast(b, X.cyl(8, ry, 56, ry, function() return 1.4 end), posts, 1, 0, -1)
  A.cast(b, X.cyl(8, ry, 56, ry, function() return 1.4 end), posts, -1, 0, -1)
  A.cast(b, X.cyl(8, ry, 56, ry, function() return 1.4 end), posts, 2, 0, -1)
  rail(8, ry, 56, ry, 1.4, i, b)
end
-- back posts + junction post (junction gets contact shadow from the branch rails drawn later)
vpost(7, 10, 21, 45, 11)
vpost(54, 57, 21, 45, 12)
local brU = X.cyl(32, 30, 47, 42, function() return 1.7 end)
local brL = X.cyl(32, 41, 47, 52, function() return 1.7 end)
local jb = {}
A.cast(jb, pJ, brU:copy():add(brL), 0, 1, -2)
A.cast(jb, pJ, brU:copy():add(brL), 0, 2, -1)
local _, jtok = vpost(29, 33, 13, 48, 13, jb)

-- branch rails toward the viewer (AO near the front post)
local fb1, fb2 = {}, {}
A.cast(fb1, brU, pF, -1, 0, -1) A.cast(fb2, brL, pF, -1, 0, -1)
rail(32, 30, 47, 42, 1.7, 21, fb1)
rail(32, 41, 47, 52, 1.7, 22, fb2)
-- front post (biggest)
vpost(46, 51, 36, 57, 14)

-- quirk: orange bracket fungi on the junction post's shade side
local F = { "#6e2a22", "#a8452a", "#e07a34", "#ffb35a", "#ffe0a0" }
local ftok = { r = { name = "fungus" } }
A.map(c, {
  "dee.",
  "ccdd",
  ".bbb",
}, 33, 19, { e = F[5], d = F[4], c = F[3], b = F[2] }, ftok)
A.map(c, {
  "de.",
  "ccd",
  ".bb",
}, 33, 23, { e = F[5], d = F[4], c = F[3], b = F[2] }, ftok)
c:put(33, 22, F[1], ftok) c:put(33, 26, F[1], ftok)

A.save(c, "garden-gate-tee")

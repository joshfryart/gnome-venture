-- ico-stone-wall (Opus artist pass): a short dry-stone field wall, three staggered courses of big, chunky dressed
-- stones (3 / 4 / 3) so it still reads as a wall at 16 px, moss creeping over one cope stone. No mortar: the joints are deep violet shadow gaps.
-- Material: each stone is a per-pixel pillow (bevel radius 3) snapped to one of three 6-tone stone ramps (cool
-- grey, warm grey, sandy) so neighbours read apart; chisel pits (dark pit + lit lower lip) and one crack; the
-- course under each overhang gets an ambient row; 2-tone ground shadow because it stands.
-- quirk: a small pink snail is crawling across the middle course, leaving a pale silver trail.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aA10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = D.new("ico-stone-wall")
local R = { D.STC, D.STW, D.STS }

c:groundShadow(32, 52, 26, 2)
-- stones: x0, y0, x1, y1, ramp, radius
local S = {
  -- bottom course
  { 9, 39, 22, 50, 1, 3 }, { 24, 40, 38, 50, 2, 3 }, { 40, 39, 54, 50, 1, 3 },
  -- middle course (staggered over the joints)
  { 9, 29, 15, 37, 2, 2 }, { 17, 28, 31, 37, 1, 3 }, { 33, 28, 46, 37, 3, 3 }, { 48, 29, 54, 37, 1, 2 },
  -- top course
  { 10, 18, 24, 26, 2, 3 }, { 26, 17, 38, 26, 1, 3 }, { 40, 18, 53, 26, 1, 3 },
}
local all, masks = HP.mask(), {}
for i, s in ipairs(S) do masks[i] = c:rrect(s[1], s[2], s[3], s[4], s[6]) all:add(masks[i]) end
-- backing joints: fill the 1 px gaps between stones (not the outside notches)
local back = HP.mask()
all:grow(1):each(function(x, y)
  if all:has(x, y) then return end
  local h = (all:has(x - 1, y) and all:has(x + 1, y)) or (all:has(x, y - 1) and all:has(x, y + 1))
    or (all:has(x - 1, y - 1) and all:has(x + 1, y + 1)) or (all:has(x + 1, y - 1) and all:has(x - 1, y + 1))
  if h then back:set(x, y) end
end)
c:fillMask(back, "#261d36")

local tok = {}
local idxAll = {}
for i, s in ipairs(S) do
  local m = masks[i]
  tok[i] = { r = { name = "stone" .. i } }
  local n, d = X.pillow(m, 3, 0.9)
  -- gentle lumpy surface: hash tilt per 2x2 cell
  for k, nn in pairs(n) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local hx = X.hash(floor(x / 3), floor(y / 3), i) - 0.5
    local hy = X.hash(floor(x / 3), floor(y / 3), i + 40) - 0.5
    local a, b, cz = nn[1] + hx * 0.12, nn[2] + hy * 0.12, nn[3]
    local l = sqrt(a*a + b*b + cz*cz) n[k] = { a / l, b / l, cz / l }
  end
  local bias = {}
  -- ambient: top rows of a stone sitting under an overhanging stone above, and the joint sides
  m:each(function(x, y) local k = K(x, y)
    if back:has(x, y - 1) and d[k] < 1 then bias[k] = -1 end
  end)
  local idx = D.tone(c, m, n, R[s[5]], { amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok[i] })
  for k, v in pairs(idx) do idxAll[k] = { v, i } end
  -- chisel pits
  m:each(function(x, y) local k = K(x, y)
    if d[k] > 2 and X.hash(x, y, 7) < 0.03 and idx[k] >= 3 and m:has(x + 1, y + 1) then
      c:put(x, y, R[s[5]][max(1, idx[k] - 2)], tok[i])
      c:put(x + 1, y + 1, R[s[5]][min(6, idx[k] + 1)], tok[i])
    end
  end)
  -- one glint per stone on the upper-left shoulder
end
-- crack across the big bottom-middle stone, with a lit lip under it
local crack = { { 30, 42 }, { 31, 43 }, { 31, 44 }, { 32, 45 }, { 33, 46 }, { 33, 47 } }
for _, p in ipairs(crack) do
  local e = idxAll[K(p[1], p[2])]
  if e then c:put(p[1], p[2], R[1][1], tok[e[2]]) if masks[e[2]]:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], R[1][5], tok[e[2]]) end end
end
-- single pop: cream glint + 2x1 hi on the top-left cope stone
c:put(29, 19, D.CREAM, tok[9]) c:put(30, 19, D.STC[6], tok[9]) c:put(29, 20, D.STC[6], tok[9])

-- moss cushion creeping over the top-left corner of the top-right cope stone, two drips down its face
local moss = D.ell(44, 17.4, 4.6, 1.9):add(D.ell(41, 18.6, 2, 1.6)):add(c:rect(40, 19, 41, 21)):add(c:rect(46, 19, 46, 20))
local mn = X.pillow(moss, 1.6, 1)
local mtok = { r = { name = "moss" } }
D.tone(c, moss, mn, D.MOSS, { amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = mtok })
c:put(42, 16, D.MOSS[6], mtok) c:put(43, 16, D.MOSS[5], mtok)
-- contact shadow under the moss on the stone
for x = 38, 50 do local y = 15 while moss:has(x, y) do y = y + 1 end
  local e = idxAll[K(x, y)] if e then c:put(x, y, R[S[e[2]][5]][max(1, e[1] - 2)], tok[e[2]]) end end

-- quirk: a snail on the sandy middle stone (shell spiral + body), silver trail behind it
local sx, sy = 35, 29
local map = {
  "..sSSs...",
  ".sSpPPs..",
  "sSpdPpPs.",
  "sPdhdPps.",
  "sPpddpPs.",
  ".sPPPPs..",
  "bbBBBBBBb",
}
local col = { s = D.SNAIL[2], S = D.SNAIL[3], P = D.SNAIL[4], p = D.SNAIL[3], d = D.SNAIL[1], h = D.SNAIL[5],
  b = D.BODY[1], B = D.BODY[2] }
local qtok = { r = { name = "snail" } }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if col[ch] then c:put(sx + xx - 1, sy + yy - 1, col[ch], qtok) end end end
-- head + eye-stalk
c:put(sx + 9, sy + 6, D.BODY[2], qtok) c:put(sx + 9, sy + 5, D.BODY[2], qtok) c:put(sx + 10, sy + 4, D.BODY[1], qtok)
c:put(sx + 10, sy + 3, D.INK, qtok)
c:put(sx + 2, sy + 1, D.SNAIL[5], qtok)
-- silver trail behind it, back across the joint
for _, p in ipairs{ { 30, 36 }, { 31, 36 }, { 33, 35 }, { 34, 35 } } do c:put(p[1], p[2], "#dfe6f2", qtok) end
D.save(c, "ico-stone-wall")

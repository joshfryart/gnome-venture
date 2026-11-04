-- broken-wayfarer-s-staff (aB12_5, Opus single pass). Tall near-upright gnarled oak staff: the top curls over into a
-- crook cradling a blue travel-stone, a twisted rope binding under the head, knobbly shaft, iron spike foot.
-- Material: per-pixel cylinder light (6-tone dark oak, wavy gnarl width, grain dashes), rope twist (diagonal
-- strands), faceted gem (sphere light + facet line + cream glint), AO where the rope meets wood and the gem sits in
-- the crook. broken: the lower shaft split lengthwise (open crack with a peeling sliver), a facet chipped off the
-- stone; flying gem shard + wood splinter.
-- quirk: a little brass traveller's bell hangs from the crook tip on a cord.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin
local c = A.new("broken-wayfarer-s-staff")
local Wd, R, Gm, B, Fe = A.DWOOD, A.ROPE, A.GEM, A.GOLD, A.TIN

-- gem (behind the crook)
local gcx, gcy = 27.5, 15
local gm, gn = A.sphere(c, gcx, gcy, 3.6, Gm, { cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
-- crook head
local hp = { { 34, 24 }, { 38, 10 }, { 27, 3 }, { 21.5, 12 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 1.9 - t * 0.55 + 0.25 * sin(t * 14) end)
local hb = {}
X.ao(hb, hm, gm, 1, -1)
A.tone(c, hm, hn, Wd, { bias = hb })
-- shaft
local p = { { 34, 22 }, { 32, 33 }, { 30, 44 }, { 28, 55 } }
local sm, sn, ST, SS, samp, LEN = A.tube(p, function(t) return 1.8 + 0.3 * sin(t * 21) - t * 0.25 end)
local bias = {}
sm:each(function(x, y) local k = K(x, y)
  local s, t = SS[k], ST[k]
  local seg = floor(t * LEN / 3)
  if (abs(s + 0.35) < 0.18 and X.hash(seg, 3) > 0.35) or (abs(s - 0.4) < 0.18 and X.hash(seg, 5) > 0.5) then bias[k] = -1 end
end)
A.tone(c, sm, sn, Wd, { bias = bias })
-- iron spike foot
sm:each(function(x, y) local k = K(x, y)
  if ST[k] > 0.93 then local s = SS[k] c:px(x, y, Fe[s < -0.45 and 5 or s < 0 and 4 or s < 0.45 and 3 or 2]) end
end)
local tx, ty = A.bez(p, 1)
c:px(floor(tx), floor(ty) + 1, Fe[3]) c:px(floor(tx), floor(ty) + 2, Fe[2])
-- rope binding under the head (twisted strands)
local rp = { A.bez(p, 0.05) }
local rm, rn, RT, RS = A.tube({ { 34, 23 }, { 33.7, 25 }, { 33.4, 27 }, { 33.1, 29.5 } }, function() return 2.6 end)
local rb = {}
local ridx = A.tone(c, rm, rn, R, { bias = rb })
rm:each(function(x, y) local k = K(x, y)
  local u = (y + floor(x * 0.5)) % 3
  if u == 0 then A.step(c, x, y, R, -2) elseif u == 1 and RS[k] < 0.3 then A.step(c, x, y, R, 1) end
end)
-- rope tail hanging
A.rows(c, { "a", "b", "a", ".c" }, 37, 28, { a = R[4], b = R[3], c = R[2] })

-- gem: facet line + glint, AO where it sits in the crook
c:px(26, 13, Gm[6]) c:px(25, 14, Gm[6]) c:px(26, 12, A.SPEC)
for _, q in ipairs{ { 28, 16 }, { 29, 17 }, { 27, 17 } } do A.step(c, q[1], q[2], Gm, -1) end

-- broken: a facet chipped off the stone (upper-right), shard flying
for _, q in ipairs{ { 30, 12 }, { 31, 13 }, { 30, 13 }, { 31, 14 } } do A.clear(c, q[1], q[2]) end
c:px(29, 12, Gm[5]) c:px(30, 14, Gm[5]) c:px(29, 13, Gm[3])
A.rows(c, { "ab", "bc", ".d" }, 41, 14, { a = Gm[6], b = Gm[5], c = Gm[3], d = Gm[2] })
-- broken: lengthwise split down the lower shaft, a sliver peeling away
local split = HP.mask()
sm:each(function(x, y) local k = K(x, y)
  local t, s = ST[k], SS[k]
  if t > 0.55 and t < 0.86 then
    local centre = 0.05 + 0.12 * sin(t * 30)
    local wdt = 0.16 * sin((t - 0.55) / 0.31 * math.pi) + 0.02
    if abs(s - centre) < wdt then split:set(x, y) end
  end
end)
A.clearMask(c, split)
-- lit lip on the left edge of the crack
split:grow(1):cut(split):each(function(x, y) if sm:has(x, y) and split:has(x + 1, y) then A.step(c, x, y, Wd, 1) end end)
-- peeling sliver
A.rows(c, { "a.", "ab", ".b", ".c" }, 33, 42, { a = Wd[6], b = Wd[4], c = Wd[2] })
-- flying splinter
A.rows(c, { "a..", ".bc" }, 19, 44, { a = Wd[6], b = Wd[4], c = Wd[2] })

-- quirk: brass bell on a cord from the crook tip
local ex, ey = A.bez(hp, 1)
ex, ey = floor(ex + .5), floor(ey + .5)
for yy = ey + 2, ey + 6 do c:px(ex, yy, R[2]) end
A.rows(c, {
  ".ab.",
  ".bc.",
  "abcd",
  "eeee",
  ".k..",
}, ex - 1, ey + 7, { a = B[6], b = B[5], c = B[4], d = B[2], e = B[3], k = B[1] })

A.save(c)

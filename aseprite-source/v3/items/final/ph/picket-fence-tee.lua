-- picket-fence-tee (final, Opus single pass). A T junction seen from a raised three-quarter view: a run of white
-- pickets left and right of a stout junction post (pyramid cap), and a branch receding toward the viewer drawn as
-- stacked picket tips between two side rails, ending on a short stub post. Sawn rail ends show paler end grain.
-- Material: bevelled grained boards, two-plane pyramid caps, iron nail heads, contact shadow of each nearer picket on
-- the one behind, AO where the branch meets the post. Ground shadow under the branch foot.
-- quirk: a little blue butterfly rests on the junction post cap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("picket-fence-tee")
local P, W, I = A.PAINT, A.WOOD, A.IRON

c:groundShadow(32, 52, 9, 2)

-- back run: rails
for i, ry in ipairs{ 13, 23 } do
  local rm = c:rect(9, ry, 54, ry + 1)
  A.board(c, rm, W, { R = 1, dir = "h", seed = i * 4, name = "rail" })
  c:put(9, ry, W[6]) c:put(9, ry + 1, W[5]) c:put(54, ry, W[4]) c:put(54, ry + 1, W[3])
end
-- back run: pickets
local xs = { 11, 17, 23, 37, 43, 49 }
for i, x in ipairs(xs) do
  local top = 9 + ((i == 2 or i == 6) and 1 or 0)
  local m = HP.mask()
  m:set(x + 1, top) m:set(x + 2, top)
  for y = top + 1, 28 do for xx = x, x + 3 do m:set(xx, y) end end
  A.cast(c, m, 1, 1, -1)
  A.board(c, m, P, { R = 1.3, dir = "v", seed = i * 6, dens = 0.22, name = "picket" })
  c:put(x + 1, 14, I[2]) c:put(x + 1, 24, I[2])
  for xx = x, x + 3 do A.step(c, xx, 28, -1) end
end
-- branch side rails (receding toward the viewer)
for i, rx in ipairs{ 27, 36 } do
  local rm = c:rect(rx, 27, rx + 1, 46)
  A.board(c, rm, W, { R = 1, dir = "v", seed = 20 + i, name = "brail" })
end
-- junction post
local pm = c:rect(29, 8, 34, 31)
A.cast(c, pm, 1, 1, -1)
A.board(c, pm, W, { R = 2, dir = "v", seed = 3, name = "post", knot = { 31, 20 } })
local cm = c:rect(28, 6, 35, 7)
A.board(c, cm, W, { R = 1, grain = false, name = "cap" })
c:put(28, 6, W[6]) c:put(28, 7, W[5])
local fm = HP.mask()
for y = 2, 5 do local h = y - 2 for x = 31 - h, 32 + h do if x >= 29 and x <= 34 then fm:set(x, y) end end end
A.pyramid(c, fm, 32, W)
-- branch: stacked picket tips, far to near
local tops = { 29, 33, 37, 41 }
for j, t in ipairs(tops) do
  local m = HP.mask()
  m:set(31, t) m:set(32, t)
  for y = t + 1, t + 7 do for x = 30, 33 do m:set(x, y) end end
  A.cast(c, m, 0, 1, -1) A.cast(c, m, 1, 1, -1)
  A.sep(c, m, P)
  A.sep(c, m, W)
  A.board(c, m, P, { R = 1.2, dir = "v", seed = 40 + j, dens = 0.2, name = "bpicket" })
  c:put(31, t + 3, I[2])
end
-- stub post at the near end
local sm = c:rect(29, 46, 34, 51)
A.cast(c, sm, 0, -1, -1)
A.board(c, sm, W, { R = 1.6, dir = "v", seed = 9, name = "stub" })
for x = 29, 34 do c:put(x, 46, (x < 32) and W[6] or W[5]) end -- paler sawn top (end grain)
c:put(31, 47, W[4]) c:put(32, 47, W[4])
for x = 29, 34 do A.step(c, x, 51, -1) end
-- chipped paint + pop
for _, p in ipairs{ { 18, 19 }, { 19, 19 }, { 18, 20 }, { 44, 24 }, { 31, 39 } } do c:put(p[1], p[2], W[4]) end
c:put(12, 12, A.CREAM)

-- quirk: a blue butterfly on the cap (wings up)
A.map(c, {
  "SH.HS",
  "SsksS",
  ".dkd.",
}, 33, 2, { S = "#3a86b0", s = "#5fc4c8", H = "#b6f0e0", d = "#2a4a7a", k = "#2b1c26" })
A.save(c, "picket-fence-tee")

-- compost_bin-mossy (final, Opus single pass). An old open-slat compost bin: two slim corner posts with pale end grain,
-- five weathered grey-brown slats with air gaps that show the dark compost inside, a domed heap on top (peel, eggshell,
-- leaf bits), velvety moss cushions on the left post cap, the top slat, the right post and the foot, with tiny
-- red-brown spore capsules. AO under each slat and where slats meet posts; nail heads; contact ground shadow.
-- quirk: a little snail with a gold spiral shell is climbing the right post.
local NAME = "compost_bin-mossy"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)
local SOIL = { "#1c1216", "#2e1d1d", "#452a22", "#5e3b29", "#7a5034", "#986842" }
local POST = { "#3a2422", "#5a3628", "#7d5134", "#a06e44", "#c49462", "#e2bc8a" }
local SLAT = { "#2f2530", "#4a3c40", "#6a5a54", "#8b7a68", "#ad9b82", "#d0bfa0" }
local MOSS = { "#1d4031", "#2a5c3a", "#3f7c40", "#5d9c44", "#8bbe4e", "#c0dc70" }

c:groundShadow(32, 55, 25, 2)

-- compost heap: dome above the slats + body behind them
local heap = A.poly{ {14, 30}, {14, 22}, {17, 17}, {23, 13.5}, {32, 12}, {41, 13.5}, {46, 17}, {49, 22}, {49, 30} }
heap:add(A.rect(14, 24, 49, 52))
local hb = {}
for y = 24, 52 do for x = 14, 49 do local k = K(x, y) hb[k] = (hb[k] or 0) - 2 end end
A.bumpy(c, heap, SOIL, { R = 4, rough = 1.1, seed = 11, bias = hb, name = "heap" })
-- scraps on the dome: orange peel, eggshell, leaf, straw
c:paint({ "ab", "bc" }, 20, 18, { a = "#ffb050", b = "#ee6c22", c = "#b5401f" })
c:paint({ "ab.", "bbc" }, 36, 15, { a = "#fff4d6", b = "#e2d6b4", c = "#a89a80" })
c:paint({ ".a", "ab", "b." }, 28, 14, { a = "#9dd06c", b = "#3f9150" })
c:paint({ "ab", ".ab" }, 42, 19, { a = "#f5d27a", b = "#c49440" })
c:paint({ "a" }, 25, 20, { a = "#7a5034" })
c:paint({ "a" }, 33, 19, { a = "#d8a256" })

-- slats (drawn before the posts; ends tuck under the posts)
local slats = {}
local ys = { 24, 30, 36, 42, 48 }
for i, y0 in ipairs(ys) do
  local m = A.rect(14, y0, 49, y0 + 3)
  slats[i] = m
end
local posts = { A.rect(10, 20, 13, 55), A.rect(50, 20, 53, 55) }
local pall = posts[1]:copy():add(posts[2])
for i, m in ipairs(slats) do
  local b = {}
  X.ao(b, m, pall, 1, -1)
  -- the second slat is cracked at the right third
  A.plank(c, m, SLAT, { R = 1.4, bias = b, seed = i * 3, name = "slat" .. i, knots = (i == 3) and { { 23, ys[i] + 2 } } or nil })
  -- contact shadow on the compost under each slat
  for x = 14, 49 do c:put(x, ys[i] + 4, SOIL[1], { r = { name = "heap" } }) end
end
-- split in slat 2
c:paint({ "a..", ".aa", "...a" }, 38, 31, { a = SLAT[1] })

-- posts: round-ish square posts, end grain on top
for i, m in ipairs(posts) do
  local tok = { r = { name = "post" .. i } }
  A.plank(c, m, POST, { R = 1.6, dir = "v", seed = 20 + i, tok = tok })
  local x0 = (i == 1) and 10 or 50
  -- end grain cap (pale) with a ring
  for x = x0, x0 + 3 do c:put(x, 20, POST[6], tok) c:put(x, 21, POST[5], tok) end
  c:put(x0 + 1, 21, POST[4], tok) c:put(x0 + 2, 20, POST[5], tok)
  -- nail heads at each slat
  for _, y0 in ipairs(ys) do c:put(x0 + 1 + (i == 1 and 1 or 0), y0 + 1, "#444663", tok) c:put(x0 + 1 + (i == 1 and 1 or 0), y0 + 2, "#6e3a2e", tok) end
  -- foot darkens where it meets the ground
  for x = x0, x0 + 3 do c:put(x, 55, POST[1], tok) end
end

-- moss cushions
local mtok = { r = { name = "moss" } }
local moss = HP.mask()
moss:add(A.poly{ {8.5, 21}, {9, 18.5}, {11, 16.5}, {14, 16.5}, {16, 18.5}, {16.5, 21}, {15, 22.5}, {10, 22.5} })   -- left cap
moss:add(A.poly{ {13, 23}, {16, 21.5}, {24, 21.5}, {29, 22.5}, {31, 24}, {27, 25.5}, {21, 25.5}, {16, 26} })        -- top slat
moss:add(A.poly{ {49, 33}, {51, 31}, {54.5, 32}, {55, 36}, {53.5, 39}, {51, 38}, {49.5, 36} })                    -- right post
moss:add(A.poly{ {11, 54}, {12, 50.5}, {16, 49}, {21, 49.5}, {24, 52}, {23, 54.5}, {13, 55} })                   -- foot
local md = {}
A.bumpy(c, moss, MOSS, { R = 2.2, rough = 1.3, seed = 31, tok = mtok })
-- drips: moss trails hanging off the top slat
for _, d in ipairs{ {17, 26, 3}, {20, 26, 2}, {25, 26, 4}, {12, 23, 3} } do
  for j = 0, d[3] - 1 do c:put(d[1], d[2] + j, j == d[3] - 1 and MOSS[2] or MOSS[3 + (j == 0 and 1 or 0)], mtok) end
end
-- spore stalks with capsules on the left cap
for _, s in ipairs{ {11, 16, 3}, {14, 16, 2} } do
  for j = 1, s[3] do c:put(s[1], s[2] - j, "#c9a24a", mtok) end
  c:put(s[1], s[2] - s[3] - 1, "#a2332e", mtok) c:put(s[1] + 1, s[2] - s[3] - 1, "#6e2038", mtok)
end

-- quirk: snail climbing the right post (shell gold spiral, body pale grey-green)
local stok = { r = { name = "snail" } }
c:paint({
  "..a.a...",
  "..b.b...",
  "..cc....",
  "..cdfgg.",
  "..dfhihg",
  "..dgijhg",
  "..dfgghg",
  "..e.fgg.",
}, 48, 41, { a = "#2b1c26", b = "#a8b498", c = "#c8d4b4", d = "#a8b498", e = "#7a8a74",
  f = "#d98322", g = "#f5b82e", h = "#ffe38a", i = "#8f4a1f", j = "#fff4d6" })

A.save(c, NAME)

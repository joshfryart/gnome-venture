-- Cob Scout (mh-cob-scout), yard sprite 64x64. Opus richness pass (c00/opus3), built on c00/opus2.
-- Richness pass: the back husk leaves now rise and flop outward with their tips hanging (peeled, not a cradle),
-- with lengthwise veins and a pale midrib; every kernel gets a shine and a darker base; the tally stick has bark
-- grain and fresh pale notches, the slash cut bold across them; one kernel is missing (a dark socket) high on the
-- right: the row it lost count at.
-- Wayfinder, common, Maizehollow. "Counts rows of kernels to keep from getting lost."
-- A sweet-corn cob standing up in its own husk: neat kernel rows (each kernel lit on its own, darker gaps that
-- fade around the face so the face stays clean), a tuft of corn silk on top, husk leaves peeled down as a cape and
-- two husk arms.
-- quirk: it carries a notched tally stick in one husk hand, a row count scratched into it (four and a slash).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mh-cob-scout-yard", 64)

local CORN = { "#7a3a1f", "#b0601f", "#d98a22", "#f5b82e", "#ffd75a", "#fff0a0" }
local HUSK = { "#1f4438", "#2e6a40", "#3f9150", "#6fb055", "#a8d070", "#d8eca0" }
local SILK = { "#864c33", "#c98a55", "#e8c07a", "#f8e2a6" }
local WOOD = { "#3e2526", "#5e3428", "#864c33", "#b97a4a", "#d89c62", "#e8b982" }
local function leaf(p, w0, w1)
  return O.tube(p, function(t) return w0 + (w1 - w0) * t + (w1 > w0 and 0 or 0) end)
end

c:groundShadow(32, 57, 19, 3)

-- back husk leaves, peeled outward like a cape
for _, d in ipairs({ -1, 1 }) do
  local m, n, T0, S = O.tube({ { 32 + d * 3, 54 }, { 32 + d * 15, 47 }, { 32 + d * 21, 20 }, { 32 + d * 26, 37 } },
    function(t) return 5.2 * (1 - t) ^ .7 + .5 end)
  local I, T = O.shadeN(c, m, n, HUSK, { amb = .25, wrap = .4, rim = true, bounce = "#2f5a6a", bmax = 2, sep = HUSK[1] })
  O.tex(c, I, T, HUSK, function(x, y, i)
    local v, t = S[K(x, y)], T0[K(x, y)]
    if not v then return 0 end
    if math.abs(v) < .1 and t < .85 then return 1 end                      -- pale midrib
    if math.abs(math.abs(v) - .5) < .12 and i >= 3 then return -1 end      -- lengthwise veins
    if t > .78 then return -1 end                                          -- the hanging tip turns into shadow
  end)
end

-- the cob
local cob = c:ellipse(32, 30, 11, 19)
cob:add(c:ellipse(32, 37, 12, 12))
local cI, cT = O.shade(c, cob, CORN, { sphere = { 28, 24, 24 }, amb = .3, wrap = .45, rim = true, bounce = "#9a5a6a", bmax = 2 })
-- kernel rows: gaps two tones down, each kernel's top-left corner one up; softer grid round the face
local function face(x, y) return x >= 22 and x <= 42 and y >= 23 and y <= 37 end
local function clear(x, y) return (x >= 23 and x <= 29 and y >= 25 and y <= 31) or (x >= 34 and x <= 40 and y >= 25 and y <= 31) or (x >= 28 and x <= 35 and y >= 33 and y <= 37) end
O.tex(c, cI, cT, CORN, function(x, y, i)
  local col = (x - 20) % 3
  local rowoff = ((x - 20) // 3) % 2
  local r = (y + rowoff * 2) % 4
  if clear(x, y) then return 0 end
  if face(x, y) then
    if col == 2 or r == 3 then return -1 end
    return 0
  end
  if col == 2 or r == 3 then return -2 end
  if col == 0 and r == 0 then return 1 end
  if r == 2 and col == 1 then return -1 end
end)
-- the missing kernel: a dark socket high on the right
O.mark(c, { { 38, 16 }, { 39, 16 }, { 38, 17 }, { 39, 17 }, { 38, 18 } }, CORN[1])
O.mark(c, { { 39, 18 } }, CORN[2])

-- corn silk: a fine tuft combed over to one side, browning at the tips
for _, p in ipairs({ { { 31, 12 }, { 29, 7 }, { 24, 5 }, { 20, 8 } }, { { 32, 12 }, { 31, 6 }, { 27, 3 }, { 23, 4 } },
                     { { 33, 12 }, { 34, 7 }, { 37, 5 }, { 39, 7 } } }) do
  local m, n, T = O.tube(p, function(t) return .9 - .2 * t end)
  local I, Tk = O.shadeN(c, m, n, SILK, { amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
  O.tex(c, I, Tk, SILK, function(x, y, i) if T[K(x, y)] and T[K(x, y)] > .75 then return -2 end end)
end

-- front husk leaves wrapping the bottom of the cob, a V that shows the kernels between
for _, d in ipairs({ -1, 1 }) do
  local m, n, _, S = O.tube({ { 32 + d * 2, 55 }, { 32 + d * 9, 52 }, { 32 + d * 11, 46 }, { 32 + d * 9, 39 } },
    function(t) return 4.5 * (1 - t) ^ .7 + .4 end)
  local I, T = O.shadeN(c, m, n, HUSK, { amb = .25, wrap = .4, sep = HUSK[1] })
  O.tex(c, I, T, HUSK, function(x, y, i) local v = S[K(x, y)] if v and math.abs(v) < .14 and i >= 3 then return -1 end end)
end
O.shade(c, c:rrect(29, 51, 35, 55, 2), HUSK, { R = 2, amb = .25, wrap = .4, sep = HUSK[1] }) -- stalk stub

-- tally stick (behind the right hand)
local stick = c:rect(50, 14, 52, 50)
O.shade(c, stick, WOOD, { R = 1, amb = .4, wrap = .5, sep = WOOD[1] })
for y = 30, 50 do if y % 3 == 0 then O.mark(c, { { 51, y } }, WOOD[3]) end end   -- bark grain below the grip
O.mark(c, { { 50, 36 }, { 50, 37 }, { 52, 42 }, { 52, 43 } }, WOOD[3])
for _, y in ipairs({ 17, 20, 23, 26 }) do O.dots(c, { { 50, y }, { 51, y }, { 52, y } }, WOOD[6]) O.dots(c, { { 50, y + 1 }, { 51, y + 1 }, { 52, y + 1 } }, WOOD[1]) end
O.dots(c, { { 52, 16 }, { 52, 18 }, { 51, 19 }, { 51, 21 }, { 51, 22 }, { 50, 24 }, { 50, 25 }, { 50, 27 }, { 49, 27 } }, WOOD[2]) -- the slash across the four
O.dots(c, { { 49, 27 } }, WOOD[2])
O.dots(c, { { 51, 14 }, { 52, 14 } }, WOOD[5])

-- husk arms
local armL, aL = O.tube({ { 22, 34 }, { 17, 36 }, { 15, 40 }, { 17, 43 } }, function(t) return 2.2 - 1 * t end)
O.shadeN(c, armL, aL, HUSK, { amb = .3, wrap = .4, sep = HUSK[1] })
local armR, aR = O.tube({ { 42, 34 }, { 46, 35 }, { 48, 34 }, { 50, 32 } }, function(t) return 2.2 - .6 * t end)
O.shadeN(c, armR, aR, HUSK, { amb = .3, wrap = .4, sep = HUSK[1] })
-- leafy fingers wrapped round the stick
O.flat(c, c:rect(49, 31, 53, 32), HUSK[4], "grip") O.dots(c, { { 49, 31 }, { 50, 31 } }, HUSK[5]) O.dot(c, 53, 32, HUSK[3])

-- face
c:eyeLocked(24, 26)
c:eyeLocked(35, 26)
c:cheek(23, 32) c:cheek(39, 32)
O.dots(c, { { 29, 34 }, { 30, 35 }, { 31, 35 }, { 32, 35 }, { 33, 35 }, { 34, 34 } }, P.ink)
O.dots(c, { { 31, 36 }, { 32, 36 } }, CORN[2])

O.shift(c, 0, -1)
O.done(c, "mh-cob-scout-yard")

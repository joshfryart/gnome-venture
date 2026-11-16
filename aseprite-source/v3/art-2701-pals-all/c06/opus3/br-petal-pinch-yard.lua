-- Petal Pinch (br-petal-pinch), yard sprite 64x64. Opus richness pass (c06/opus3), built on c06/opus2.
-- Common, bloomcaller (knob: round). "Pinches one pink petal from every tree and keeps them in a pocket."
-- A round berry-rose pal with a round two-leaf sprout on top, a moss-green cloth pocket stitched to its belly
-- and stuffed with pale cherry petals, one hand up pinching a big notched sakura petal.
-- Richness: velvety berry skin (pale pinpricks in the light, dimples in the shade), veined sprout leaves,
-- ribbed weave and a shaded opening lip on the pocket with gold running stitches, a vein and a deeper
-- blush at the base of every petal.
-- quirk: the pocket is so full that one petal has slipped out over the edge and is drifting down.
-- Closer look: a dewdrop still sits on the petal it just pinched.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-petal-pinch-yard", 64)

local ROSE = { "#3e1630", "#642444", "#8c3460", "#b44c7a", "#d4709a", "#eca2bc" }
local SAK  = { "#c2708e", "#eea4b8", "#fbcdd8", "#fff0f2" }
local LEAF = { "#1f3b2e", "#2c5a3a", "#3f7f43", "#5ea24c", "#8cc463", "#c2e290" }
local CLTH = { "#24402e", "#33583a", "#4a7646", "#6a9656", "#92b872", "#bcd89a" }
local GOLD = "#f0c050"
local BNC  = "#5a5a8a"

c:groundShadow(31, 58, 17, 2.5)

-- petal: sakura petal from a pixel pattern (notch in the wide end); (x,y) = top-left
local PET = {
  s = { "##.##", "#####", ".###.", "..#.." },
  b = { ".##.##.", "#######", "#######", ".#####.", "..###..", "...#..." },
  f = { "##.", "###", ".##", "..#" }, -- tumbling, seen tilted
}
local function petal(x, y, kind, flip)
  local pat = PET[kind]
  local m = HP.mask()
  for j, row in ipairs(pat) do for i = 1, #row do
    if row:sub(i, i) == "#" then m:set(x + (flip and (#row - i) or (i - 1)), y + j - 1) end
  end end
  O.shade(c, m, SAK, { sphere = { x, y, #pat[1] + 2 }, amb = .4, wrap = .5, sep = SAK[1], cuts = { .3, .55, .8 } })
  -- deeper blush at the narrow base, a vein up the middle
  local bx0, by0, bx1, by1 = m:bbox()
  if kind == "b" then
    O.mark(c, { { x + 3, y + 5 }, { x + 3, y + 4 } }, SAK[1]) O.mark(c, { { x + 3, y + 3 }, { x + 3, y + 2 } }, SAK[2])
  elseif kind == "s" then O.mark(c, { { x + 2, y + 3 } }, SAK[1]) O.mark(c, { { x + 2, y + 2 } }, SAK[2]) end
  return m
end

-- feet
for _, fx in ipairs({ 24, 39 }) do
  O.shade(c, c:ellipse(fx, 55, 4.5, 2.5), ROSE, { R = 2, amb = .22, wrap = .3, bounce = BNC, bmax = 2 })
end
-- body
local body = c:ellipse(31, 41, 15, 14)
local rI, rT = O.shade(c, body, ROSE, { sphere = { 26, 35, 18 }, amb = .26, wrap = .35, sep = ROSE[1], rim = true, bounce = BNC, bmax = 2 })
-- velvety berry skin: pale pinpricks in the light, dimples in the shade (face oval kept clean)
O.tex(c, rI, rT, ROSE, function(x, y, i)
  if ((x - 31) / 11)^2 + ((y - 37) / 6)^2 < 1 then return 0 end
  local h = O.H(x, y, 17)
  if (x * 2 + y * 3) % 7 == 0 and h > .35 then
    if i >= 4 then return 1 elseif i >= 2 then return -1 end
  end
end)
-- sprout: stem + two round leaves
O.flat(c, c:rect(31, 22, 31, 27), LEAF[3], "stem")
O.shade(c, c:ellipse(27, 22, 3.5, 2.5), LEAF, { sphere = { 26, 21, 4 }, amb = .3, wrap = .4, sep = LEAF[1], rim = true })
O.shade(c, c:ellipse(35, 21, 3.5, 2.5), LEAF, { sphere = { 34, 20, 4 }, amb = .3, wrap = .4, sep = LEAF[1] })
O.dots(c, { { 25, 22 }, { 26, 22 }, { 27, 22 }, { 28, 22 } }, LEAF[2]) O.dots(c, { { 34, 21 }, { 35, 21 }, { 36, 21 }, { 37, 21 } }, LEAF[2]) -- midribs
O.dots(c, { { 26, 21 }, { 28, 23 } }, LEAF[6]) O.dots(c, { { 35, 20 }, { 37, 22 } }, LEAF[4]) -- side veins catch the light

-- face
c:eyeLocked(23, 32)
c:eyeLocked(34, 32)
O.dots(c, { { 29, 39 }, { 30, 40 }, { 31, 40 }, { 32, 39 } }, P.ink)
c:cheek(20, 38) c:cheek(39, 38)

-- petals stuffed in the pocket (behind the pocket front)
petal(23, 45, "s") petal(29, 44, "s") petal(35, 45, "s")
-- cloth pocket
local pk = c:rrect(21, 48, 41, 55, 3)
local pb = {} pk:each(function(x, y) if y == 48 then pb[K(x, y)] = 2 end end)
local cI, cT = O.shade(c, pk, CLTH, { R = 2, amb = .28, wrap = .4, bias = pb, sep = CLTH[1], rim = true })
-- linen weave + the shaded opening lip
O.tex(c, cI, cT, CLTH, function(x, y, i)
  if y == 49 then return -2 end
  if y % 3 == 0 and y > 49 and x % 6 ~= 0 then return -1 end -- woven weft rows
  if y % 3 == 2 and (x + y) % 6 == 0 and i >= 3 then return 1 end
end)
for x = 23, 39, 4 do O.mark(c, { { x, 50 } }, GOLD) end -- stitched hem
O.mark(c, { { 23, 52 }, { 23, 54 }, { 39, 52 }, { 39, 54 } }, GOLD)

-- quirk: one petal slipped out over the pocket edge, drifting down at the left
petal(9, 41, "f")

-- left arm resting on the pocket
O.shade(c, c:ellipse(18, 49, 2.5, 2), ROSE, { R = 1, amb = .3, sep = ROSE[1] })
-- right arm up, pinching a big petal
local arm, an = O.tube({ { 44, 44 }, { 49, 41 }, { 51, 35 }, { 51, 30 } }, function(t) return 1.8 end)
O.shadeN(c, arm, an, ROSE, { amb = .3, wrap = .4, sep = ROSE[1] })
petal(48, 21, "b") -- petal held up, notch at the top
-- closer look: a dewdrop still on the pinched petal
O.pat(c, 50, 23, { "ab", "bc" }, { a = "#f2fbf8", b = "#bfe2ea", c = "#7ab0c8" }, "dew")
-- finger and thumb pinching its base
O.shade(c, c:ellipse(49.5, 28, 1.5, 1.5), ROSE, { R = 1, amb = .4, sep = ROSE[1] })
O.shade(c, c:ellipse(52.5, 28, 1.5, 1.5), ROSE, { R = 1, amb = .3, sep = ROSE[1] })

O.shift(c, 0, -5)
O.done(c, "br-petal-pinch-yard", function(c)
  -- drift line under the falling petal (un-outlined)
  for _, p in ipairs({ { 7, 39 }, { 6, 38 }, { 9, 46 }, { 56, 21 }, { 57, 20 }, { 57, 24 }, { 58, 24 } }) do
    local y = p[2] - 5 if not c.pix[y * c.w + p[1]] then c:put(p[1], y, SAK[3]) end
  end
end)

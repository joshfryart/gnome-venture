-- Grotto Glim (cs-grotto-glim), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Uncommon, seedkeeper. "Glows with the glowworms in the cave and whispers ooh."
-- A plump cave glowworm grub rearing up in an S-curve: dusky violet segments (each lit and ink-separated), a pale
-- belly line, teal-green glow spots along its sides, a glowing lantern tail tip and two antennae with glow beads.
-- Fixes: the Haiku snowman stack (three flat blobs) is now a curving segmented grub with a clear head and tail;
-- glow is a cool bioluminescent teal against the violet, not dull gold specks.
-- quirk: the awed little "ooh" mouth, whispering at two silk threads of glow beads dangling from the cave roof.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-grotto-glim-yard", 64)

local DUSK = { "#241a40", "#35295f", "#4e3a8a", "#6e58b0", "#957cd0", "#c2aeec" }
local GLOW = { "#1f6a72", "#2fb8b0", "#7af0dc", "#d4fff4" }
local BNC = "#2a6a8a"

c:groundShadow(31, 58, 21, 2.5)

-- segments from the tail (lying left) to the neck (rearing up)
local segs = {
  { 13, 53, 3.5 }, { 18, 54, 4.5 }, { 24, 54, 5.5 }, { 31, 53, 6.5 }, { 37, 49, 7 }, { 39, 42, 7.5 }, { 37, 35, 7.5 },
}
-- glowing lantern tail tip
do
  local tip = c:ellipse(8, 52, 3, 2.5)
  O.shade(c, tip, GLOW, { sphere = { 7, 51, 3 }, amb = .55, wrap = .5, cuts = { .3, .55, .8 } })
end
for i, s in ipairs(segs) do
  local m = c:ellipse(s[1], s[2], s[3], s[3] * .92)
  local I, T = O.shade(c, m, DUSK, { sphere = { s[1] - s[3] * .4, s[2] - s[3] * .5, s[3] * 1.5 }, amb = .33, wrap = .4, sep = DUSK[1], rim = true, bounce = BNC, bmax = 2 })
  -- glow spot on each segment's side
  if i >= 2 then
    local gx, gy = math.floor(s[1] + s[3] * .35), math.floor(s[2] + s[3] * .25)
    O.mark(c, { { gx, gy }, { gx + 1, gy }, { gx, gy + 1 } }, GLOW[3])
    O.mark(c, { { gx + 1, gy + 1 } }, GLOW[2])
  end
end
-- pale belly running down the front of the rearing part
O.mark(c, { { 31, 40 }, { 32, 41 }, { 32, 42 }, { 32, 43 }, { 33, 44 }, { 31, 46 }, { 30, 47 } }, DUSK[5])

-- antennae with glow beads
for _, a in ipairs({ { 26, 15, 20, 5 }, { 37, 15, 42, 4 } }) do
  local m, n = O.tube({ { a[1], a[2] }, { a[1] + (a[3] - a[1]) * .3, a[2] - 5 }, { a[3], a[4] + 4 }, { a[3], a[4] } }, function() return .8 end)
  O.flat(c, m, DUSK[3], "antenna")
  O.shade(c, c:ellipse(a[3], a[4] - 1, 1.6, 1.6), GLOW, { R = 1, amb = .55, cuts = { .3, .55, .8 } })
end

-- head
local head = c:ellipse(31, 25, 11, 9.5)
local hI, hT = O.shade(c, head, DUSK, { sphere = { 27, 20, 14 }, amb = .3, wrap = .4, sep = DUSK[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, hI, hT, DUSK, function(x, y, i) if y < 21 and O.H(x, y, 31) > .93 and i >= 3 then return 1 end end)
-- glow freckles across the brow
O.mark(c, { { 24, 18 }, { 31, 17 }, { 38, 18 } }, GLOW[3])

-- face
c:eyeLocked(23, 22)
c:eyeLocked(34, 22)
c:cheek(21, 28) c:cheek(39, 28)
-- "ooh" mouth: a small round O
O.dots(c, { { 30, 29 }, { 31, 29 }, { 29, 30 }, { 32, 30 }, { 29, 31 }, { 32, 31 }, { 30, 32 }, { 31, 32 } }, P.ink)
O.dots(c, { { 30, 30 }, { 31, 30 }, { 30, 31 }, { 31, 31 } }, "#7d2c5e")
O.dot(c, 31, 31, "#c94f84")

O.done(c, "cs-grotto-glim-yard", function(c)
  -- quirk: silk threads of glow beads hanging from the cave roof (no outline)
  for _, th in ipairs({ { 52, 0, 16 }, { 57, 0, 24 } }) do
    for y = th[2], th[3] do
      if (y - th[2]) % 5 == 4 then
        c:put(th[1], y, GLOW[3]) c:put(th[1], y + 1, GLOW[2])
      elseif not c:get(th[1], y) then
        c:put(th[1], y, "#8a8aa8")
      end
    end
  end
  -- glow drip at the end of the long thread
  c:put(57, 25, GLOW[2]) c:put(56, 26, GLOW[2]) c:put(58, 26, GLOW[2]) c:put(57, 26, GLOW[4]) c:put(57, 27, GLOW[2])
  -- tail glow halo flecks
  c:put(3, 49, GLOW[3]) c:put(5, 46, GLOW[2])
end)

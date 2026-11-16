-- Howl Echo (pl-gwk-5), yard sprite 64x64. Opus second pass (c13/opus2), built on c13/haiku.
-- Rootwarden, uncommon, Lair of the Grey Wolf King. "A howl that rings around once and comes back a little smaller."
-- Haiku weakness fixed: a plain teal ball with two arcs read as a generic singing blob, and the "comes back
-- smaller" half of the blurb was missing. Now the howl is a sound wisp: a round twilight-blue head throwing its
-- big "O" howl up and to the right, with a soft flame tip on top, and its tail swings out and rings once right round
-- behind it.
-- quirk: the end of the ring comes back as a small echo of itself: a little wisp with its own tiny howl, at the
-- upper left. closer-look: two sound ripples arcing off the howl inside the ring.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-5-yard", 64)

local WISP = { "#1c2458", "#2c4486", "#3d6cb0", "#58a0d2", "#8ccde8", "#cdeef6" }
local RING = { "#2a2a66", "#3e4e96", "#5a7cc0", "#80aedc", "#b0d8ee", "#e0f4fa" }
local MOUTH = "#3a1e4a"
local TONG = { "#a83a5e", "#e0708e" }

c:groundShadow(32, 58, 16, 2)
-- the ring: tail swinging out low right, up behind, round to the upper left (drawn first: it is behind)
local seg = {
  { { { 38, 44 }, { 50, 50 }, { 60, 40 }, { 57, 26 } }, function(t) return 4 - t * .8 end },
  { { { 57, 26 }, { 54, 13 }, { 42, 6 }, { 30, 7 } }, function(t) return 3.2 - t * .8 end },
  { { { 30, 7 }, { 22, 8 }, { 16, 10 }, { 13, 14 } }, function(t) return 2.4 - t * .3 end },
}
for _, sg in ipairs(seg) do
  local m, n, T = O.tube(sg[1], sg[2])
  local I, Tk = O.shadeN(c, m, n, RING, { amb = .32, wrap = .5, rim = true })
  -- flow streaks along the ring
  O.tex(c, I, Tk, RING, function(x, y, i) if (x + y) % 6 == 0 and i >= 3 then return 1 end end)
end
-- the echo: a smaller wisp at the end of the ring
local echo = c:ellipse(11, 17, 6, 5.5)
echo:add(c:poly{ { 8, 13 }, { 12, 12 }, { 7, 7 } })
O.shade(c, echo, WISP, { sphere = { 8, 14, 8 }, amb = .35, wrap = .5, rim = true, sep = RING[1] })
O.dots(c, { { 9, 16 }, { 13, 16 } }, P.ink)
O.flat(c, c:ellipse(11.5, 20, 1, 1), MOUTH, "echomouth")

-- the head: round wisp with a flame tip on top (curling left), throwing its howl up-right
local head = c:ellipse(28, 36, 14, 13)
head:add(c:poly{ { 20, 26 }, { 32, 24 }, { 22, 17 }, { 25, 22 } })
local hI, hT = O.shade(c, head, WISP, { sphere = { 22, 28, 20 }, amb = .3, wrap = .5, rim = true, bounce = "#9a7ad0", bmax = 3, sep = RING[1] })
-- glowing core streaks (sound) on the lit side
O.tex(c, hI, hT, WISP, function(x, y, i)
  if x >= 18 and x <= 40 and y >= 30 and y <= 46 then return 0 end
  if (x * 2 - y) % 7 == 0 and i >= 3 and i <= 5 then return 1 end
end)
-- wisp tail flick at the bottom left
local flick = O.tube({ { 16, 44 }, { 12, 48 }, { 11, 52 }, { 14, 54 } }, function(t) return 2.5 - t * 2 end)
O.shade(c, flick, WISP, { R = 1, amb = .35, wrap = .5, sep = WISP[2] })

-- face: eyes and the big O howl, tilted up-right
c:eyeLocked(20, 32)
c:eyeLocked(30, 30)
c:cheek(18, 39) c:cheek(36, 37)
local mouth = c:ellipse(30, 41, 3.5, 4)
O.flat(c, mouth, MOUTH, "mouth")
O.dots(c, { { 29, 44 }, { 30, 44 }, { 31, 44 }, { 30, 43 } }, TONG[1]) O.dot(c, 29, 43, TONG[2])
mouth:grow(1):cut(mouth):each(function(x, y) c:put(x, y, P.ink, { r = { name = "lip" } }) end)

O.done(c, "pl-gwk-5-yard", function(c)
  -- closer-look: sound ripples inside the ring, off the howl (two, then one smaller)
  for _, r in ipairs({ { 17, -48, -8 }, { 21, -40, -14 } }) do
    for d = r[2], r[3], 2 do
      local a = math.rad(d)
      local x, y = math.floor(30 + math.cos(a) * r[1] + .5), math.floor(41 + math.sin(a) * r[1] + .5)
      if not c:get(x, y) then c:put(x, y, RING[6]) end
    end
  end
  c:sparkle(4, 30)
  c:sparkle(61, 52)
end)

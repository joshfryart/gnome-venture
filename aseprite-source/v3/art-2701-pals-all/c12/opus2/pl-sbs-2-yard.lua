-- Web Snag (pl-sbs-2), yard sprite 64x64. Opus second pass (c12/opus2), built on c12/haiku.
-- Wayfinder, common, Hollow of the Silverback Spider. "A loose thread of web that snags hats, then hands them back."
-- Haiku was a pale blue disc with a purple blob beside it (the hat did not read, the disc read as a ball). Now a
-- torn scrap of web hanging from a twig: a round silk knot at the hub carries the face, a few radial threads
-- and broken spiral rungs fan up to the twig (thin, un-outlined, pale), and one loose, thicker thread runs out
-- of the knot like an arm and curls into a hook.
-- quirk: on the hook hangs a little red gnome hat it snagged, held out to give it back.
-- closer look: a dew bead caught on one rung.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-sbs-2-yard", 64)

local SILK = { "#3a4a6e", "#5a6e96", "#8aa0c2", "#b4c8e0", "#d8e6f2", "#eef6fb" }
local BARK = { "#3a2428", "#51302b", "#864c33", "#b97a4a", "#d39a62", "#e8b982" }
local HAT  = { "#6e2038", "#9a2a3c", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }
local LEAF = { "#24544a", "#2f6e4e", "#3f9150", "#7cc35a", "#c4e07a", "#e2f0a8" }
local hub = { 27, 32 }
local anchors = { { 10, 10 }, { 22, 8 }, { 36, 8 }, { 50, 10 } }

-- twig the web hangs from
local tw, tn, tT = O.tube({ { 5, 11 }, { 20, 6 }, { 40, 7 }, { 58, 12 } }, function(t) return 2.2 - .8 * t end)
local wI, wT = O.shadeN(c, tw, tn, BARK, { amb = .25, wrap = .4, rim = true })
O.tex(c, wI, wT, BARK, function(x, y, i) if (x + y * 3) % 7 == 0 and i >= 3 then return -1 end end)
local lf, ln = O.tube({ { 44, 8 }, { 46, 4 }, { 50, 3 }, { 53, 4 } }, function(t) return 2 * math.sin(math.pi * t) + .2 end)
O.shadeN(c, lf, ln, LEAF, { amb = .3, wrap = .4, sep = LEAF[1] })
O.mark(c, { { 47, 5 }, { 49, 4 } }, LEAF[2])

-- the hook thread (thicker, outlined): out of the knot, down and right, curling up into a hook
local hk, hn, hT = O.tube({ { 33, 37 }, { 44, 46 }, { 52, 38 }, { 47, 35 } }, function(t) return 1.3 - .4 * t end)
O.shadeN(c, hk, hn, SILK, { amb = .35, wrap = .45 })

-- the hat, hanging by its tip from the hook
local cone = c:poly{ { 47, 37 }, { 55, 55 }, { 40, 55 } }
cone:add(c:ellipse(47.5, 55, 8, 2))
local cI, cT = O.shade(c, cone, HAT, { R = 4, amb = .2, wrap = .4, rim = true, bounce = "#7a3a6e", bmax = 2 })
-- fabric folds: two soft creases
O.mark(c, { { 46, 44 }, { 45, 46 }, { 45, 47 }, { 49, 48 }, { 50, 50 } }, HAT[2])
local band = c:rect(40, 52, 55, 53):clip(cone)
local bI, bT = O.shade(c, band, { "#4e3a1e", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff3b8" }, { R = 1, amb = .3, wrap = .4, sep = HAT[1] })

-- the silk knot at the hub (body)
local knot = c:ellipse(hub[1], hub[2], 10, 9)
local kI, kT = O.shade(c, knot, SILK, { sphere = { 23, 27, 15 }, amb = .3, wrap = .45, rim = true, bounce = "#6a7ab8", bmax = 2 })
-- wound-thread lines round the knot (the knot is a ball of web), clear of the face
O.tex(c, kI, kT, SILK, function(x, y, i)
  if y >= 29 and y <= 37 and x >= 19 and x <= 35 then return 0 end
  local dx, dy = x - hub[1], y - hub[2]
  if (math.floor(dx * .7 - dy * 1.1 + 40) % 3) == 0 then return i >= 4 and -2 or -1 end
end)

-- face
c:cheek(19, 35) c:cheek(33, 35)
O.dots(c, { { 25, 36 }, { 26, 37 }, { 27, 37 }, { 28, 37 }, { 29, 36 } }, P.ink)

local THREAD = "#e4eef8"
O.done(c, "pl-sbs-2-yard", function(c)
  c:eyeLocked(20, 28)
  c:eyeLocked(29, 28)
  local function seg(a, b)
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
    for s = 0, n do
      local x = math.floor(a[1] + (b[1] - a[1]) * s / n + .5)
      local y = math.floor(a[2] + (b[2] - a[2]) * s / n + .5)
      if not c.own[y * c.w + x] or c.pix[y * c.w + x] == nil then c:put(x, y, THREAD) end
    end
  end
  -- radial threads from the knot's top edge up to the twig
  local starts = { { 20, 26 }, { 24, 23 }, { 30, 23 }, { 34, 26 } }
  for i, a in ipairs(anchors) do seg(starts[i], { a[1], a[2] + 2 }) end
  -- broken spiral rungs between radials (torn scrap: some are missing)
  local function at(i, t) local s, a = starts[i], anchors[i] return { s[1] + (a[1] - s[1]) * t, s[2] + (a[2] + 2 - s[2]) * t } end
  for _, r in ipairs({ { 1, .35 }, { 2, .35 }, { 3, .35 }, { 1, .65 }, { 3, .65 }, { 2, .85 } }) do
    seg(at(r[1], r[2]), at(r[1] + 1, r[2]))
  end
  -- closer look: dew bead on a rung
  local d = at(2, .65)
  local bx, by = math.floor(d[1] + 3), math.floor(d[2] + 0.5)
  c:put(bx, by, "#8bc4ea") c:put(bx + 1, by, "#5f9ad0") c:put(bx, by + 1, "#5f9ad0") c:put(bx + 1, by + 1, "#3a6aa0")
  c:put(bx, by, P.cream)
end)

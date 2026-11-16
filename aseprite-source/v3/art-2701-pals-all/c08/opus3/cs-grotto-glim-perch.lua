-- Grotto Glim (cs-grotto-glim), perch sprite 36x36. Opus second pass, hand-built at this size: a violet glowworm
-- grub rearing up (four lit, ink-separated segments), glowing teal lantern tail, teal glow spots, two antennae with
-- glow beads, 2x3 pill eyes.
-- quirk: the round "ooh" mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-grotto-glim-perch", 36)

local DUSK = { "#241a40", "#35295f", "#4e3a8a", "#6e58b0", "#957cd0", "#c2aeec" }
local GLOW = { "#1f6a72", "#2fb8b0", "#7af0dc", "#d4fff4" }

c:groundShadow(17, 32.5, 13, 1.2)
O.shade(c, c:ellipse(5, 29, 2, 1.8), GLOW, { R = 1, amb = .55, cuts = { .3, .55, .8 } })
for i, s in ipairs({ { 9, 29.5, 2.5 }, { 14, 29, 3.5 }, { 20, 27.5, 4 }, { 22, 22, 4.5 } }) do
  O.shade(c, c:ellipse(s[1], s[2], s[3], s[3] * .92), DUSK, { sphere = { s[1] - 1, s[2] - 2, s[3] * 1.5 }, amb = .33, wrap = .4, sep = DUSK[1], rim = true, bounce = "#2a6a8a", bmax = 2 })
  if i >= 2 then O.mark(c, { { math.floor(s[1] + s[3] * .4), math.floor(s[2] + 1) } }, GLOW[3]) end
end
for _, a in ipairs({ { 14, 9, 11, 4 }, { 20, 9, 23, 3 } }) do
  O.flat(c, c:line({ { a[1], a[2] }, { a[3], a[4] + 1 } }, 1), DUSK[3], "antenna")
  O.shade(c, c:rect(a[3], a[4] - 1, a[3] + 1, a[4]), GLOW, { R = 1, amb = .55, cuts = { .3, .55, .8 } })
end
local head = c:ellipse(17, 15, 7.5, 6.5)
O.shade(c, head, DUSK, { sphere = { 15, 12, 9 }, amb = .35, wrap = .4, sep = DUSK[1], rim = true, bounce = "#2a6a8a", bmax = 2 })
O.mark(c, { { 17, 10 } }, GLOW[3])
c:eyeSmall(13, 13)
c:eyeSmall(20, 13)
O.dots(c, { { 11, 17 }, { 23, 17 } }, "#f5809f")
O.dots(c, { { 16, 17 }, { 17, 17 }, { 15, 18 }, { 18, 18 }, { 15, 19 }, { 18, 19 }, { 16, 20 }, { 17, 20 } }, P.ink)
O.dots(c, { { 16, 18 }, { 17, 18 }, { 16, 19 } }, "#7d2c5e") O.dot(c, 17, 19, "#c94f84")
O.done(c, "cs-grotto-glim-perch", function(c)
  c:put(2, 27, GLOW[3]) c:put(31, 6, GLOW[3]) c:put(31, 5, "#8a8aa8") c:put(31, 4, "#8a8aa8") c:put(31, 7, GLOW[2])
end)

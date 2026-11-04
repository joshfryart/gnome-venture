-- sacred-lotus-seed (first draft, Sonnet). Three hard dark-brown lotus nuts (pale nipple tip) lie on a broad round
-- blue-green lotus pad with radiating veins; one has sprouted: thin stems carrying a small flat pad and a rolled
-- spear leaf.
-- quirk: a bead of water rolls on the pad, glinting like a pearl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("sacred-lotus-seed")
local floor, sin, cos = math.floor, math.sin, math.cos
local pad = c:ellipse(30, 44, 26, 13)
A.lit(c, pad, "#3a9a88", 5, { amb = .12, wrap = .3 })
local r = A.R("#3a9a88")
for a = 0, 11 do
  local ang = a * math.pi / 6 + .2
  A.ln(c, 30, 44, floor(30 + cos(ang) * 24), floor(44 + sin(ang) * 11.5), (a % 2 == 0) and r[2] or r[5], pad)
end
A.sph(c, 30, 44, 1.8, r, { nospec = true })
c:fillMask(c:rect(30, 44, 30, 44), r[6])
local sd = A.R("#5a3a2a")
for _, s in ipairs{ { 17, 46, .2 }, { 25, 50, -.3 }, { 42, 48, .1 } } do
  A.seed(c, s[1], s[2], 3.6, 2.8, s[3], sd, r[1], "#e0c8a0")
  c:px(s[1] + 3, s[2] - 1, "#c8d890")
end
A.rod(c, 42, 45, 42, 22, .9, "#9ad0a0", { amb = .15 })
A.rod(c, 25, 48, 24, 30, .9, "#9ad0a0", { amb = .15 })
local lp = c:ellipse(42, 19, 8, 3.2)
A.lit(c, lp, "#5ab088", 2.2)
for k = -3, 3 do A.ln(c, 42, 19, 42 + k * 2, 19 + (math.abs(k) < 3 and (k > 0 and 1 or -1) * 0 or 0), "#2a7a68", lp) end
local sp = A.ell(24, 26, 2.4, 5, 0.1)
A.lit(c, sp, "#7ac890", 1.6)
-- water bead
A.sph(c, 48, 52, 2.6, "#b6f0e0", { spec = "#fff4d6" })
A.fin()

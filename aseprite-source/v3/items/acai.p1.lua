-- acai pass 1 (form): squat heap of 6 dark glossy berries (3-2-1), moss stem + 2 leaves on top,
-- quirk: one small paler berry peeking shyly from behind the top berry.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local P = HP.P
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "acai.p1" }
-- acai are darker than grapes: berry ramp = dusk shifted one step down (all palette tones), glossy dusk.hi pop
local ACAI = { hi = P.dusk.hi, base = P.dusk.shade, shade = P.dusk.deep, deep = P.ink }
local function berry(cx, cy, r, rp) return c:part(c:ellipse(cx, cy, r, r), rp or ACAI, { sep = true, band = 3 }) end
c:part(c:ellipse(42, 22, 4, 4), "dusk", { band = 2 })            -- quirk: shy little berry, behind
c:part(c:line({ {31, 6}, {32, 11}, {32, 17} }, 2), "moss", { nopop = true, band = 1 })
c:part(c:poly{ {31,11},{25,6},{17,5},{13,8},{19,12},{27,13} }, "moss", { band = 1 })
c:part(c:poly{ {33,10},{38,5},{46,5},{49,8},{43,11},{36,13} }, "moss", { band = 1 })
berry(32, 24, 7)
berry(25, 35, 7) berry(39, 35, 7)
berry(17, 46, 7) berry(32, 47, 7) berry(47, 46, 7)
c:px(28, 20, P.cream)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ png = out .. "acai.p1.png" }

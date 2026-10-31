-- ph/natto, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique: the straw sheaf is authentic but at 16 px it is a pale bar (reads as a cracker or a hay bale); the
-- defining thing about natto, the stretchy strings, is 1 px and vanishes. Fix (distill to the signature): a deep indigo
-- bowl heaped with glossy beans, chopsticks lifting a clump with a thick sticky web. Indigo + amber is its own pair.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "natto", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = GV.ramp("#2f3f7a", { gloss = "#a8c0f0", dot = "#e0ecff", rim = "#4a5fa0" })
local bean = GV.ramp("#b8782c", { shade = "#7a4a1f", deep = "#5e2f1e", gloss = "#f6c888", dot = "#fff0d0", rim = "#d8964a" })
local web = "#f2ead2"
-- chopsticks behind, from the upper right down into the clump
c:part(c:line({ {53, 7}, {36, 26} }, 3), "wood", { flat = true, contact = false })
c:part(c:line({ {55, 12}, {39, 29} }, 3), "wood", { flat = true, contact = false })
-- sticky web between the lifted clump and the heap (a solid pale fan so it reads, threads drawn inside it)
local fan = c:poly({ {31, 26}, {39, 26}, {44, 37}, {22, 37} })
c:part(fan, GV.ramp(web, { rim = "#fbf6e8" }), { flat = true, contact = false })
for _, l in ipairs({ { {33, 27}, {26, 36} }, { {35, 27}, {33, 36} }, { {37, 27}, {40, 36} } }) do c:fill(c:line(l, 1), "#d6c8a0") end
-- lifted clump at the chopstick tips
for _, p in ipairs({ {32, 23}, {37, 22}, {35, 26} }) do
  c:part(c:ellipse(p[1], p[2], 3, 2.5), bean, { flat = true, contact = false, contour = false })
  c:px(p[1] - 1, p[2] - 1, bean.dot); c:px(p[1] + 2, p[2] + 1, bean.deep)
end
-- bowl with a bean heap rising out of it
local heap = c:ellipse(32, 38, 18, 5)
c:part(heap, bean, { gloss = false, cres = 2 })
for _, p in ipairs({ {20, 37}, {26, 36}, {32, 37}, {38, 36}, {44, 37}, {23, 39}, {29, 40}, {35, 40}, {41, 39} }) do
  c:px(p[1], p[2], bean.dot); c:px(p[1] + 1, p[2] + 1, bean.shade); c:px(p[1] + 2, p[2], bean.deep)
end
local b = c:ellipse(32, 41, 21, 13):cut(c:rect(0, 0, 63, 40))
c:part(b, bowl, { gloss = { 16, 44 } })
c:fill(c:rect(12, 41, 52, 41):clip(b), "#7b8ad0")
c:part(c:rrect(24, 53, 40, 56, 1), bowl, { flat = true })
c:ground(32, 57, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

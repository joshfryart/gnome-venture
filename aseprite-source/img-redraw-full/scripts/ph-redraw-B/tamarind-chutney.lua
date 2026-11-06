-- ph/tamarind-chutney, redraw B (2.2.1 leftovers, Opus + impeccable critique lens).
-- Critique of the old icon: "a brown pot with a brown drip" could be any chutney (specificity fails) and it is one
-- brown value at 16 px. Fix: the hero is the tamarind POD (lumpy curved brown pod, the one shape only tamarind has)
-- lying across the front of a bright terracotta pot heaped with near-black glossy chutney. Two values, one idea.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "tamarind-chutney", "B"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local terra = GV.ramp("#d8743a")
local paste = GV.ramp("#3e1c12", { rim = "#6e3420", gloss = "#b06a3a", dot = "#e0a070" })
local pod = GV.ramp("#b8824a", { gloss = "#f6d8a8", dot = "#fbecd0", rim = "#d8a468" })
-- pot: wide round belly, short flared rim, chutney heaped above it
local pot = c:ellipse(34, 36, 18, 15):add(c:rrect(20, 19, 48, 25, 3))
c:part(pot, terra, { gloss = { 20, 30 } })
c:fill(c:rect(20, 27, 48, 28):clip(pot), "#f6e3c0")
local heap = c:ellipse(34, 17, 12, 6):cut(c:rect(0, 21, 63, 63)):add(c:rect(22, 19, 46, 21))
c:part(heap, paste, { gloss = { 27, 13 }, cres = 3 })
local drip = c:line({ {40, 21}, {40, 29} }, 4):add(c:ellipse(40.5, 31, 2.5, 2.5))
c:part(drip, paste, { flat = true, contact = false, contour = false })
c:px(39, 24, paste.gloss); c:px(39, 25, paste.gloss)
-- tamarind pod across the front: a chain of bulges on a gentle curve, cracked pale shell flecks
local pod_m = c:mask()
-- polish 1+2 (fatter bulges in pass 2): the pod leans up the pot front on a diagonal (lying flat it read as a boat under the pot)
for i, b in ipairs({ {12, 51, 5.5}, {18, 46, 6}, {24, 41, 6}, {30, 37, 5.5} }) do
  pod_m:add(c:ellipse(b[1], b[2], b[3], b[3] - 0.5))
end
c:part(pod_m, pod, { gloss = { 16, 45 } })
for _, l in ipairs({ { {13, 45}, {18, 51} }, { {19, 40}, {24, 46} }, { {25, 36}, {30, 41} } }) do c:fill(c:line(l, 1):clip(pod_m:shrink(1)), "#7a4a1f") end
for _, f in ipairs({ {15, 49}, {20, 45}, {25, 41}, {30, 38} }) do c:px(f[1], f[2], "#e8c494"); c:px(f[1] + 1, f[2], "#e8c494") end
-- stalk curl at the pod's left end
c:part(c:line({ {35, 34}, {38, 32}, {37, 29} }, 2), "wood", { flat = true, contact = false })
c:ground(32, 57, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")

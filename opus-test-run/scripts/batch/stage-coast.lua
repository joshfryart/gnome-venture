-- stage-coast v2: a grassy cliff headland with a striped lighthouse, layered sea with foam, two sailboats, gulls, shingle beach with rocks, driftwood, lobster pots, a rope fence.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 150, 20, 1); S.cloud(c, 90, 34, 0.7); S.cloud(c, 214, 40, 0.5)
X.layer(c, "far")
c:fill(c:rect(0, 56, 239, 91), "#25637d"); c:fill(c:rect(0, 56, 239, 66), "#3f8fb0"); c:fill(c:rect(0, 67, 239, 74), "#3f8fb0")
for y = 70, 90, 5 do for x = ((y // 5) % 2) * 11, 239, 22 do c:fill(c:rect(x, y, x + 6, y), "#a9d6ea") end end
-- two sailboats
for _, b in ipairs({ { 40, 72 }, { 96, 64 } }) do
  c:fill(c:poly({ { b[1], b[2] }, { b[1] + 12, b[2] }, { b[1] + 9, b[2] + 4 }, { b[1] + 3, b[2] + 4 } }), "#8a4f2a"); c:fill(c:rect(b[1] + 6, b[2] - 14, b[1] + 6, b[2]), "#5e2f1e"); c:fill(c:poly({ { b[1] + 7, b[2] - 13 }, { b[1] + 14, b[2] - 1 }, { b[1] + 7, b[2] - 1 } }), "#f2e4c0")
end
-- cliff headland on the right: grass cap, facets of stone, foam at the foot
c:fill(c:poly({ { 150, 91 }, { 158, 54 }, { 240, 50 }, { 240, 91 } }), "#8b8f96"); c:fill(c:poly({ { 190, 52 }, { 240, 50 }, { 240, 91 }, { 214, 91 } }), "#5b6470")
c:fill(c:poly({ { 156, 58 }, { 240, 52 }, { 240, 60 }, { 160, 66 } }), "#7ab55c"); c:fill(c:rect(160, 66, 240, 67), "#4f9a45")
for x = 152, 239, 4 do if x % 8 < 4 then c:px(x, 91, "#eef8f2"); c:px(x + 1, 91, "#eef8f2") end end
X.layer(c, "ground"); S.ground(c, { walk = "#c9c5bc", near = "#8b8f96", tuft = "#8b8f96", tuftNear = "#5b6470", seed = 17, bank = "#9a6b3f", bankDeep = "#7a4a1f" })
c:fill(c:rect(0, 92, 239, 93), "#eef8f2")                                    -- surf line
X.layer(c, "objects")
-- lighthouse on the headland: tall, red and cream stripes, gold lamp, red cap
local lx = 196
c:part(c:poly({ { lx - 7, 56 }, { lx + 7, 56 }, { lx + 4, 24 }, { lx - 4, 24 } }), H.flat("#f2e4c0", "#d8c49a"), { gloss = false, cres = 2, deep = 0 })
for i = 0, 2 do c:fill(c:poly({ { lx - 6 + i, 52 - i * 11 }, { lx + 6 - i, 52 - i * 11 }, { lx + 5.4 - i, 44 - i * 11 }, { lx - 5.4 + i, 44 - i * 11 } }), "#dd3a2a") end
c:part(c:rect(lx - 6, 16, lx + 6, 24), H.flat("#f5cf6a", "#e8a317"), { gloss = false, flat = true }); c:fill(c:rect(lx - 3, 18, lx + 3, 21), "#fff3c8")
c:part(c:poly({ { lx - 7, 16 }, { lx, 8 }, { lx + 7, 16 } }), H.flat("#dd3a2a", "#ae2a2a", "#f2793a"), { gloss = false, cres = 2, deep = 0 })
c:part(c:rect(lx - 3, 44, lx + 3, 56), H.flat("#8a4f2a", "#5e2f1e"), { gloss = false, flat = true })
c:build{ { "rock1", c:ellipse(92, 92, 9, 5), H.STONE, { gloss = false, cres = 3, deep = 0 } }, { "rock2", c:ellipse(103, 90, 6, 4), H.STONE, { gloss = false, cres = 2, deep = 0 } },
  { "rock3", c:ellipse(150, 93, 6, 3), H.STONE, { gloss = false, cres = 2, deep = 0 } }, { "drift", c:rrect(124, 94, 146, 97, 1), H.WOOD, { gloss = false, cres = 1, deep = 0 } } }
-- rope fence at the left edge (calm side, thin)
for _, x in ipairs({ 8, 28, 48 }) do c:part(c:rect(x, 80, x + 2, 94), H.WOOD, { gloss = false, flat = true }) end; c:fill(c:rect(10, 84, 48, 84), "#d9a660"); c:fill(c:rect(10, 88, 48, 88), "#d9a660")
-- lobster pot stack at the far right foot
c:part(c:rrect(212, 84, 228, 94, 2), H.flat("#c9a96e", "#9a6b3f"), { gloss = false, cres = 2, deep = 0 }); for x = 214, 226, 4 do c:fill(c:rect(x, 85, x, 93), "#9a6b3f") end
X.layer(c, "detail")
for _, g in ipairs({ { 60, 34 }, { 72, 29 }, { 120, 42 }, { 134, 36 } }) do S.bird(c, g[1], g[2]) end
for _, s in ipairs({ { 30, 112 }, { 80, 118 }, { 170, 114 }, { 200, 120 } }) do c:paint({ "xx.", ".xx" }, s[1], s[2], { x = "#5b6470" }) end
X.save(c, "stage-coast", "scenes", { w = 480, h = 270, cap = 32 })

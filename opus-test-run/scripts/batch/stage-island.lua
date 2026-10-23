-- stage-island v2: bright sea with wave rows and foam, a far volcano isle with a palm, a sailboat, sand ripples, three palms, shells, a starfish, driftwood, tide pools.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local H = loadfile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/batch/stagelib.lua")(X)
local S = H.S; S.theme = "island"
local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2 }

S.SKY = { "#8fcbd8", "#a9d6ea", "#c8ecdc", "#eef8f2" }
X.layer(c, "sky"); S.sky(c); S.sun(c, 34, 19); S.cloud(c, 150, 20, 1); S.cloud(c, 214, 36, 0.6); S.cloud(c, 90, 34, 0.5)
X.layer(c, "far")
c:fill(c:rect(0, 58, 239, 91), "#3f8fb0"); c:fill(c:rect(0, 58, 239, 64), "#25637d"); c:fill(c:rect(0, 65, 239, 72), "#3f8fb0")
for y = 68, 90, 5 do for x = ((y // 5) % 2) * 11, 239, 22 do c:fill(c:rect(x, y, x + 5, y), "#a9d6ea") end end
-- far volcano isle: dark cone, grey cap, green skirt, one tiny palm
c:fill(c:poly({ { 160, 60 }, { 176, 38 }, { 192, 60 } }), "#5b6470"); c:fill(c:poly({ { 176, 38 }, { 192, 60 }, { 182, 60 }, { 176, 50 } }), "#4e3a8a"); c:fill(c:rect(171, 38, 181, 40), "#c9c5bc")
c:fill(c:ellipse(176, 61, 20, 4), "#7ab55c"); c:fill(c:rect(198, 52, 198, 60), "#8a4f2a"); c:fill(c:rect(195, 51, 201, 52), "#4f9a45")
-- sailboat on the horizon
c:fill(c:poly({ { 60, 70 }, { 74, 70 }, { 71, 74 }, { 63, 74 } }), "#8a4f2a"); c:fill(c:rect(67, 56, 67, 70), "#5e2f1e"); c:fill(c:poly({ { 68, 57 }, { 76, 68 }, { 68, 68 } }), "#f2e4c0"); c:fill(c:poly({ { 66, 60 }, { 60, 68 }, { 66, 68 } }), "#f6b8cf")
for x = 0, 239 do if x % 3 < 2 then c:px(x, 92, "#eef8f2") end end
X.layer(c, "ground"); S.ground(c, { walkTop = 93, walk = "#f5cf6a", near = "#c9a96e", tuft = "#c9a96e", tuftNear = "#9a6b3f", seed = 13, bank = "#c9a96e", bankDeep = "#9a6b3f" })
for y = 96, 110, 4 do for x = ((y // 4) % 2) * 9, 239, 18 do c:fill(c:rect(x, y, x + 6, y), "#fff3c8") end end   -- sand ripples
X.layer(c, "objects")
local function palm(x, y, lean, h)
  local tx = x + lean
  c:part(c:poly({ { x, y }, { x + 3, y }, { tx + 4, y - h }, { tx + 1, y - h } }), H.WOOD, { gloss = false, cres = 2, deep = 0 })
  for _, f in ipairs({ { -16, 6 }, { 16, 6 }, { -11, -6 }, { 11, -6 }, { 0, -12 }, { -6, 9 }, { 8, 10 } }) do
    c:part(c:poly({ { tx + 2, y - h }, { tx + 2 + f[1] * 0.5, y - h + f[2] - 4 }, { tx + 2 + f[1], y - h + f[2] }, { tx + 2 + f[1] * 0.45, y - h + 3 } }), H.PINE, { gloss = false, cres = 1, deep = 0 })
  end
  c:fill(c:ellipse(tx + 1, y - h + 4, 2, 2), "#8a4f2a"); c:fill(c:ellipse(tx + 5, y - h + 5, 2, 2), "#8a4f2a")   -- coconuts
end
palm(124, 93, 6, 38); palm(168, 93, -3, 26); palm(22, 93, 4, 22)
c:build{ { "drift", c:rrect(96, 95, 120, 98, 1), H.WOOD, { gloss = false, cres = 1, deep = 0 } }, { "rock", c:ellipse(150, 94, 7, 3), H.STONE, { gloss = false, cres = 2, deep = 0 } } }
X.layer(c, "detail")
c:fill(c:ellipse(86, 100, 4, 2), "#f6b8cf"); c:fill(c:rect(85, 99, 87, 99), "#f2e4c0")                           -- shell
for i = 0, 4 do local a = i * 1.2566; c:px(math.floor(190 + math.cos(a) * 3 + 0.5), math.floor(106 + math.sin(a) * 3 + 0.5), "#dd3a2a") end; c:px(190, 106, "#f08a24")   -- starfish
c:fill(c:ellipse(60, 112, 7, 2), "#a9d6ea"); c:fill(c:ellipse(210, 116, 8, 2), "#a9d6ea")                         -- tide pools
S.bird(c, 80, 30); S.bird(c, 94, 36)
X.save(c, "stage-island", "scenes", { w = 480, h = 270, cap = 32 })

-- trek.lua : 16 Trek stage backdrops (chapters 1, 2, 3, 3b x path, fight, camp, boss), 240x135 grid -> 480x270. Part E: opaque, no border, cap 32.
-- Chapters: 1 Wilting Rows (warm withered topsoil, open sky), 2 Weeping Clay (clay walls, blue weeps), 3 Humming Deep (violet-grey rock, lantern gold),
-- 3b Knock Below (deeper violet, gold-seamed Still Gate). Same ground band as the stage backdrops so everything reads as one world.
local X = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/gvx.lua")
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local function R(base, shade, rim) return X.ramp(base, { shade = shade, deep = shade, bounce = shade, rim = rim or base, gloss = base, dot = base }) end
local OP = { gloss = false, cres = 2, deep = 0 }
local function P(c, m, r, o) c:part(m, r, o or OP) end
local RM = { wood = R("#b07a45", "#8a4f2a", "#d9a660"), stone = R("#8b8f96", "#5b6470", "#c9c5bc"), dstone = R("#5b6470", "#3d2a1c", "#8b8f96"),
  clay = R("#c9a96e", "#9a6b3f", "#f1ece0"), rclay = R("#a8582f", "#7a4a1f", "#d9a660"), gold = R("#f5cf6a", "#e8a317"), cream = R("#f2e4c0", "#d8c49a"),
  crys = R("#a9d6ea", "#3f8fb0", "#fff3c8"), vio = R("#7a5cc0", "#4e3a8a", "#c3b2ea"), red = R("#dd3a2a", "#ae2a2a", "#f2793a"), leaf = R("#7ab55c", "#4f9a45"),
  dry = R("#c9a96e", "#7a4a1f", "#f5cf6a"), ember = R("#f08a24", "#d6322b", "#f5cf6a") }
local function rock(c, x, y, rx, ry, rr) P(c, c:ellipse(x, y, rx, ry), rr or RM.stone, { gloss = false, cres = 2, deep = 0 }) end
local function lantern(c, x, y) c:fill(c:rect(x, y - 14, x, y), "#4a2c1a"); P(c, c:rrect(x - 2, y - 20, x + 2, y - 14, 1), RM.gold, { gloss = false, flat = true }); c:px(x, y - 17, "#fff3c8") end
local function fire(c, x, y)
  P(c, c:rect(x - 10, y - 2, x + 10, y), RM.wood); P(c, c:rect(x - 8, y - 4, x + 8, y - 2), RM.wood)
  c:fill(c:poly({ { x - 6, y - 4 }, { x, y - 20 }, { x + 6, y - 4 } }), "#f08a24"); c:fill(c:poly({ { x - 3, y - 4 }, { x, y - 13 }, { x + 3, y - 4 } }), "#f5cf6a") end
local function tent(c, x, y, w, h, rr) P(c, c:poly({ { x - w, y }, { x, y - h }, { x + w, y } }), rr, { gloss = false, cres = 3, deep = 0 }); c:fill(c:poly({ { x - 3, y }, { x, y - h * 0.5 }, { x + 3, y } }), "#3d2a1c") end
local function crystal(c, x, y, h, rr) P(c, c:poly({ { x - 3, y }, { x - 2, y - h * 0.7 }, { x, y - h }, { x + 2, y - h * 0.7 }, { x + 3, y } }), rr, { gloss = false, cres = 1, deep = 0 }) end
local function stalk(c, x, y, h) c:fill(c:rect(x, y - h, x, y), "#9a6b3f"); c:fill(c:rect(x + 1, y - h, x + 2, y - h + 1), "#9a6b3f"); P(c, c:ellipse(x + 2, y - h + 3, 3, 2), RM.dry, { gloss = false, flat = true }) end
local function pot(c, x, y, s) P(c, c:poly({ { x - 3 * s, y }, { x - 4 * s, y - 6 * s }, { x + 4 * s, y - 6 * s }, { x + 3 * s, y } }), RM.rclay, { gloss = false, cres = 2, deep = 0 }) end
local function drip(c, x, y0, y1) c:fill(c:rect(x, y0, x, y1), "#3f8fb0"); c:fill(c:rect(x, y1 + 1, x, y1 + 2), "#a9d6ea") end
local function sign(c, x, y) P(c, c:rect(x, y - 16, x + 1, y), RM.wood, { gloss = false, flat = true }); P(c, c:poly({ { x - 6, y - 16 }, { x + 7, y - 16 }, { x + 9, y - 12 }, { x + 7, y - 9 }, { x - 6, y - 9 } }), RM.wood, { gloss = false, cres = 2, deep = 0 }) end

local CH = {
  ["1"] = { sky = { "#a9d6ea", "#c8ecdc", "#f2e4c0", "#fff3c8" }, far = { "#c9a96e", "#a4b86a" }, ground = { walk = "#9a6b3f", near = "#7a4a1f", tuft = "#7a4a1f", tuftNear = "#3d2a1c", bank = "#7a4a1f", bankDeep = "#3d2a1c", seed = 31 },
    open = true, prop = function(c, x, y) stalk(c, x, y, 24) end, wall = nil },
  ["2"] = { wall = { "#7a4a1f", "#9a6b3f", "#a8582f", "#c9a96e", "#c9a96e" }, far = { "#9a6b3f", "#a8582f" }, ground = { walk = "#c9a96e", near = "#9a6b3f", tuft = "#9a6b3f", tuftNear = "#7a4a1f", bank = "#7a4a1f", bankDeep = "#3d2a1c", seed = 32 },
    stal = "#3d2a1c", prop = function(c, x, y) pot(c, x, y, 1.8) end },
  ["3"] = { wall = { "#4e3a8a", "#5b6470", "#5b6470", "#8b8f96", "#8b8f96" }, far = { "#5b6470", "#8b8f96" }, ground = { walk = "#8b8f96", near = "#5b6470", tuft = "#5b6470", tuftNear = "#4e3a8a", bank = "#5b6470", bankDeep = "#3d2a1c", seed = 33 },
    stal = "#3d2a1c", prop = function(c, x, y) crystal(c, x, y, 20, RM.crys) end },
  ["3b"] = { wall = { "#3d2a1c", "#4e3a8a", "#4e3a8a", "#5b6470", "#5b6470" }, far = { "#4e3a8a", "#5b6470" }, ground = { walk = "#5b6470", near = "#4e3a8a", tuft = "#4e3a8a", tuftNear = "#3d2a1c", bank = "#4e3a8a", bankDeep = "#3d2a1c", seed = 34 },
    stal = "#3d2a1c", prop = function(c, x, y) crystal(c, x, y, 20, RM.vio) end },
}
local SCENE = {
  path = function(k, c, ch)
    -- a worn track winds through the centre; a sign and a lantern/prop beside it
    for x = 60, 180 do c:fill(c:rect(x, 98 + math.floor(3 * math.sin(x / 13) + 0.5), x, 100 + math.floor(3 * math.sin(x / 13) + 0.5)), ch.ground.near) end
    sign(c, 140, 90); ch.prop(c, 100, 91); ch.prop(c, 108, 90)
    if k ~= "1" then lantern(c, 96, 92) end
  end,
  fight = function(k, c, ch)
    -- open and flat: only edge dressing outside the party/foe slots
    rock(c, 150, 91, 6, 3); ch.prop(c, 102, 91); ch.prop(c, 112, 92); rock(c, 124, 92, 4, 2)
  end,
  camp = function(k, c, ch)
    fire(c, 120, 92); tent(c, 70, 90, 12, 14, RM.cream); tent(c, 172, 90, 12, 14, RM.vio)
    P(c, c:rect(96, 90, 104, 94), RM.wood); P(c, c:rect(136, 90, 144, 94), RM.wood)   -- seats
    if k ~= "1" then lantern(c, 150, 90) end
  end,
  boss = function(k, c, ch)
    if k == "1" then   -- Gloomtooth's burrow mound with a dark hole and wilted rows either side
      P(c, c:ellipse(120, 92, 34, 30):cut(c:rect(80, 93, 160, 135)), RM.rclay, { gloss = false, cres = 4, deep = 0 })
      c:fill(c:ellipse(120, 92, 11, 14):cut(c:rect(100, 93, 140, 120)), "#3d2a1c"); stalk(c, 80, 92, 18); stalk(c, 160, 92, 18)
    elseif k == "2" then   -- the Sour Cistern: a round stone tank with pipes and a weeping drip
      P(c, c:rrect(88, 60, 152, 92, 6), RM.stone, { gloss = false, cres = 4, deep = 0 }); c:fill(c:rect(92, 64, 148, 72), "#3f8fb0"); c:fill(c:rect(92, 64, 148, 65), "#a9d6ea")
      P(c, c:rect(84, 70, 88, 92), RM.rclay); P(c, c:rect(152, 70, 156, 92), RM.rclay); for _, x in ipairs({ 100, 120, 140 }) do drip(c, x, 73, 80) end
    elseif k == "3" then   -- Old Gneiss: a huge cracked shell-rock on a pedestal in Echo Hollow
      P(c, c:ellipse(120, 80, 30, 24):cut(c:rect(80, 90, 160, 120)), RM.stone, { gloss = false, cres = 4, deep = 0 }); c:fill(c:rect(110, 62, 111, 76), "#3d2a1c"); c:fill(c:rect(111, 76, 113, 82), "#3d2a1c")
      P(c, c:rect(96, 90, 144, 94), RM.dstone, { gloss = false, flat = true }); crystal(c, 76, 92, 16, RM.crys); crystal(c, 164, 92, 14, RM.crys)
    else   -- the Still Gate: a tall stone arch with a gold seam, closed
      P(c, c:rect(86, 40, 154, 92), RM.stone, { gloss = false, cres = 4, deep = 0 }); P(c, c:ellipse(120, 60, 24, 24):cut(c:rect(90, 80, 150, 93)), RM.dstone, { gloss = false, flat = true })
      c:fill(c:rect(119, 40, 120, 92), "#f5cf6a"); c:fill(c:rect(118, 62, 121, 66), "#fff3c8"); crystal(c, 72, 92, 16, RM.vio); crystal(c, 168, 92, 16, RM.vio)
    end
  end,
}

-- ===== extra dressing per chapter (second pass: the first backdrops were sparse) =====
local function scarecrow(c, x, y)
  P(c, c:rect(x, y - 24, x + 1, y), RM.wood, { gloss = false, flat = true }); P(c, c:rect(x - 9, y - 18, x + 10, y - 17), RM.wood, { gloss = false, flat = true })
  P(c, c:poly({ { x - 5, y - 18 }, { x + 6, y - 18 }, { x + 7, y - 7 }, { x - 6, y - 7 } }), RM.red, { gloss = false, cres = 2, deep = 0 })
  P(c, c:ellipse(x + 0.5, y - 24, 4, 4), RM.cream, { gloss = false, flat = true }); P(c, c:poly({ { x - 6, y - 26 }, { x + 7, y - 26 }, { x + 4, y - 33 }, { x - 3, y - 33 } }), RM.dry, { gloss = false, cres = 1, deep = 0 })
  c:fill(c:rect(x - 3, y - 25, x - 3, y - 25), "#2a1a10"); c:fill(c:rect(x + 3, y - 25, x + 3, y - 25), "#2a1a10"); c:fill(c:rect(x - 11, y - 18, x - 9, y - 12), "#f5cf6a"); c:fill(c:rect(x + 10, y - 18, x + 12, y - 12), "#f5cf6a")
end
local function wilted(c, x, y, h)   -- wilted sunflower: bent stem, drooping head
  c:fill(c:rect(x, y - h, x, y), "#7ab55c"); c:fill(c:rect(x - 1, y - h + 2, x, y - h + 4), "#7ab55c")
  P(c, c:ellipse(x + 4, y - h + 6, 4, 3), RM.dry, { gloss = false, cres = 1, deep = 0 }); c:fill(c:ellipse(x + 4, y - h + 6, 2, 1), "#7a4a1f")
end
local function cart(c, x, y)
  P(c, c:poly({ { x - 12, y - 12 }, { x + 12, y - 12 }, { x + 9, y - 3 }, { x - 9, y - 3 } }), RM.dstone, { gloss = false, cres = 3, deep = 0 })
  c:fill(c:rect(x - 12, y - 13, x + 12, y - 12), "#c9c5bc"); for _, dx in ipairs({ -5, 1, 6 }) do c:fill(c:ellipse(x + dx, y - 14, 2, 2), "#2a1a10") end
  for _, dx in ipairs({ -7, 7 }) do P(c, c:ellipse(x + dx, y - 2, 3, 3), RM.wood, { gloss = false, cres = 1, deep = 0 }); c:fill(c:rect(x + dx, y - 3, x + dx, y - 1), "#2a1a10") end
end
local function glowshroom(c, x, y, col) c:fill(c:rect(x, y - 3, x + 1, y), "#f2e4c0"); c:fill(c:ellipse(x + 0.5, y - 4, 3, 2), col); c:px(x, y - 5, "#fff3c8") end
local function chain(c, x, y0, y1) for y = y0, y1, 2 do c:px(x, y, "#8b8f96") end; lantern(c, x, y1 + 8) end
local function books(c, x, y) for i, col in ipairs({ "#dd3a2a", "#3f8fb0", "#f5cf6a" }) do c:fill(c:rect(x - 6 + i, y - i * 3, x + 6 - i, y - i * 3 + 2), col) end end
local function puddle(c, x, y, rx, col) c:fill(c:ellipse(x, y, rx, 2), col); c:fill(c:rect(x - rx + 2, y - 1, x - 1, y - 1), "#a9d6ea") end
local EXTRA = {
  ["1"] = function(c, sc)
    S.cloud(c, 60, 14, 0.9); S.cloud(c, 150, 24, 0.7)
    for x = 4, 236, 9 do c:fill(c:rect(x, 85, x, 90), "#8a4f2a") end; c:fill(c:rect(0, 86, 239, 86), "#8a4f2a"); c:fill(c:rect(0, 89, 239, 89), "#8a4f2a")   -- far fence
    for y = 112, 128, 5 do c:fill(c:rect(0, y, 239, y), "#3d2a1c") end                                                      -- furrows
    if sc ~= "camp" then scarecrow(c, 176, 93) end
    for _, w in ipairs({ { 30, 96, 16 }, { 40, 98, 12 }, { 206, 97, 14 }, { 218, 96, 18 } }) do wilted(c, w[1], w[2], w[3]) end
    S.bird(c, 96, 40); S.bird(c, 104, 36)
  end,
  ["2"] = function(c, sc)
    chain(c, 60, 12, 24); chain(c, 180, 12, 20)
    puddle(c, 56, 120, 12, "#3f8fb0"); puddle(c, 190, 124, 14, "#3f8fb0"); puddle(c, 120, 128, 9, "#3f8fb0")
    if sc ~= "boss" then pot(c, 80, 93, 1.4); pot(c, 88, 94, 1.1); books(c, 154, 93) end
  end,
  ["3"] = function(c, sc)
    chain(c, 40, 8, 22); chain(c, 200, 8, 18)
    if sc == "path" or sc == "fight" then cart(c, 162, 94) end
    for _, p in ipairs({ { 20, 124 }, { 214, 120 } }) do crystal(c, p[1], p[2], 12, RM.crys); crystal(c, p[1] + 5, p[2] + 2, 8, RM.crys) end
    for _, p in ipairs({ { 70, 4 }, { 104, 6 }, { 144, 3 } }) do c:fill(c:poly({ { p[1] - 3, 0 }, { p[1], 24 + p[2] }, { p[1] + 3, 0 } }), "#3d2a1c") end
  end,
  ["3b"] = function(c, sc)
    for _, g in ipairs({ { 24, 96, "#7a5cc0" }, { 70, 100, "#f5cf6a" }, { 168, 98, "#7a5cc0" }, { 212, 95, "#f5cf6a" } }) do glowshroom(c, g[1], g[2], g[3]) end
    for _, d in ipairs({ { 60, 40 }, { 100, 56 }, { 150, 36 }, { 196, 64 }, { 30, 70 } }) do c:px(d[1], d[2], "#f5cf6a") end   -- gold dust motes
    for x = 14, 226, 30 do c:fill(c:rect(x, 118, x + 14, 118), "#f5cf6a") end                                                    -- gold seam in the floor
    chain(c, 120, 6, 16)
  end,
}

-- ===== shared set dressing by scene type (third pass) =====
local function bedroll(c, x, y, col) P(c, c:rrect(x - 8, y - 4, x + 8, y, 2), col, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x - 8, y - 4, x - 6, y), "#f2e4c0") end
local function pot(c2, x, y) c2:fill(c2:rect(x - 7, y - 12, x - 7, y), "#4a2c1a"); c2:fill(c2:rect(x + 7, y - 12, x + 7, y), "#4a2c1a"); c2:fill(c2:rect(x - 7, y - 12, x + 7, y - 12), "#4a2c1a"); P(c2, c2:ellipse(x, y - 8, 5, 4), RM.dstone, { gloss = false, cres = 2, deep = 0 }) end
local function crate(c, x, y) P(c, c:rect(x - 5, y - 9, x + 5, y), RM.wood, { gloss = false, cres = 2, deep = 0 }); c:fill(c:rect(x - 5, y - 5, x + 5, y - 5), "#8a4f2a"); c:fill(c:rect(x, y - 9, x, y), "#8a4f2a") end
local function brazier(c, x, y) c:fill(c:rect(x, y - 10, x, y), "#4a2c1a"); P(c, c:poly({ { x - 4, y - 14 }, { x + 4, y - 14 }, { x + 2, y - 10 }, { x - 2, y - 10 } }), RM.dstone, { gloss = false, flat = true }); c:fill(c:poly({ { x - 3, y - 14 }, { x, y - 22 }, { x + 3, y - 14 } }), "#f08a24"); c:fill(c:poly({ { x - 1, y - 14 }, { x, y - 18 }, { x + 1, y - 14 } }), "#f5cf6a") end
local function pennants(c, x0, x1, y) for x = x0, x1 do c:px(x, y + math.floor(3 * math.sin((x - x0) / (x1 - x0) * math.pi) + 0.5), "#4a2c1a") end
  for x = x0 + 3, x1 - 3, 7 do local yy = y + math.floor(3 * math.sin((x - x0) / (x1 - x0) * math.pi) + 0.5); c:fill(c:poly({ { x, yy + 1 }, { x + 4, yy + 1 }, { x + 2, yy + 5 } }), ({ "#dd3a2a", "#f5cf6a", "#3f8fb0" })[(x // 7) % 3 + 1]) end end
local COMMON = {
  camp = function(c, k)
    bedroll(c, 52, 100, RM.red); bedroll(c, 188, 102, RM.vio); pot(c, 136, 100); crate(c, 154, 96); crate(c, 162, 97); P(c, c:rrect(96, 98, 108, 101, 1), RM.wood, { gloss = false, cres = 1, deep = 0 })
    pennants(c, 70, 172, 70)
    c:fill(c:rect(66, 78, 66, 92), "#4a2c1a"); c:fill(c:rect(172, 78, 172, 92), "#4a2c1a")
  end,
  fight = function(c, k)
    for i = 0, 15 do local a = i * math.pi / 8; local x, y = 120 + math.cos(a) * 64, 100 + math.sin(a) * 9; c:fill(c:ellipse(x, y, 3, 1.5), (i % 2 == 0) and "#8b8f96" or "#5b6470"); c:px(math.floor(x), math.floor(y) - 1, "#c9c5bc") end
    for _, px in ipairs({ 36, 204 }) do c:fill(c:rect(px, 70, px, 92), "#4a2c1a"); c:fill(c:poly({ { px + 1, 70 }, { px + 10, 74 }, { px + 1, 79 } }), (px < 100) and "#dd3a2a" or "#3f8fb0") end
    P(c, c:ellipse(86, 93, 4, 2), RM.stone, { gloss = false, flat = true }); P(c, c:ellipse(158, 94, 3, 2), RM.stone, { gloss = false, flat = true })
  end,
  path = function(c, k) for i = 0, 5 do c:fill(c:ellipse(64 + i * 22, 99 + math.floor(3 * math.sin((64 + i * 22) / 13) + 0.5), 3, 1.5), "#8b8f96") end end,
  boss = function(c, k) brazier(c, 68, 93); brazier(c, 174, 93) end,
}
local only = os.getenv("ONLY"); local want = {}
if only then for k in only:gmatch("[^,]+") do want[k] = true end end
for _, k in ipairs({ "1", "2", "3", "3b" }) do for _, sc in ipairs({ "path", "fight", "camp", "boss" }) do
  local name = "trek-" .. k .. "-" .. sc
  if not only or want[name] then
    local ch = CH[k]
    local c = X.canvas{ mode = "scene", w = 240, h = 135, out = 2, ol = 1, olx = 1 }
    X.layer(c, "sky")
    if ch.open then
      c:fill(c:rect(0, 0, 239, 17), ch.sky[1]); c:fill(c:rect(0, 18, 239, 36), ch.sky[2]); c:fill(c:rect(0, 37, 239, 58), ch.sky[3]); c:fill(c:rect(0, 59, 239, 134), ch.sky[4]); S.sun(c, 200, 22)
    else
      for i, col in ipairs(ch.wall) do c:fill(c:rect(0, (i - 1) * 18, 239, i * 18 + (i == 5 and 60 or -1)), col) end
    end
    X.layer(c, "far")
    S.ridge(c, ch.far[1], 66, { { 4, 23, 0 }, { 2, 9, 1 } }); S.ridge(c, ch.far[2], 78, { { 3, 17, 2 } })
    if ch.stal then for x = 6, 234, 14 do local h = 10 + (x * 7 % 17); c:fill(c:poly({ { x - 4, 0 }, { x, h }, { x + 4, 0 } }), ch.stal) end end
    if k == "2" then for _, x in ipairs({ 30, 78, 160, 210 }) do drip(c, x, 14, 40) end end
    if k == "1" then for x = 6, 234, 12 do c:fill(c:rect(x, 70, x, 80), "#7a4a1f"); c:fill(c:rect(x - 2, 68, x + 2, 70), "#c9a96e") end end
    if k == "2" then for _, x in ipairs({ 20, 60, 100, 150, 190 }) do c:fill(c:rect(x, 44, x + 22, 66), "#3d2a1c"); for r = 0, 2 do c:fill(c:rect(x + 2, 46 + r * 7, x + 20, 50 + r * 7), "#7a4a1f"); for b = 0, 4 do c:fill(c:rect(x + 3 + b * 4, 47 + r * 7, x + 5 + b * 4, 49 + r * 7), ({ "#dd3a2a", "#3f8fb0", "#f5cf6a", "#7ab55c", "#c3b2ea" })[(b + r) % 5 + 1]) end end end end
    if k == "3" then for _, p in ipairs({ { 24, 50 }, { 70, 40 }, { 150, 46 }, { 206, 52 }, { 232, 38 } }) do crystal(c, p[1], p[2] + 18, 18, RM.crys); crystal(c, p[1] + 6, p[2] + 18, 10, RM.crys) end end
    if k == "3b" then for _, p in ipairs({ { 30, 14 }, { 80, 18 }, { 150, 12 }, { 200, 16 } }) do c:fill(c:poly({ { p[1] - 3, p[2] }, { p[1], p[2] + 18 }, { p[1] + 3, p[2] } }), "#7a5cc0") end; for x = 10, 230, 20 do c:fill(c:rect(x, 56 + (x % 3) * 4, x + 8, 56 + (x % 3) * 4), "#f5cf6a") end end
    X.layer(c, "ground"); S.ground(c, ch.ground)
    X.layer(c, "objects"); SCENE[sc](k, c, ch)
    X.layer(c, "detail"); EXTRA[k](c, sc); COMMON[sc](c, k)
    if k ~= "1" and sc ~= "boss" then crystal(c, 36, 92, 10, k == "2" and RM.clay or (k == "3" and RM.crys or RM.vio)) end
    X.save(c, name, "scenes", { w = 480, h = 270, cap = 32 })
  end
end end

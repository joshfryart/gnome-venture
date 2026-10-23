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
    X.layer(c, "detail")
    if k ~= "1" and sc ~= "boss" then crystal(c, 36, 92, 10, k == "2" and RM.clay or (k == "3" and RM.crys or RM.vio)) end
    X.save(c, name, "scenes", { w = 480, h = 270, cap = 32 })
  end
end end

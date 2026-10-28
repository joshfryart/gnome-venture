-- variety-stage : 5 stage icons (haul gather feed light clear). Drawn 64x64 gvlib icon mode,
-- then upscaled 1.5x nearest with PIL to 96x96 (game/assets/img/steps/stage-*.png).
-- run: AppRun -b --script-param out=DIR [--script-param only=haul] --script variety-stage.lua
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or "/tmp"
local ASE = "/home/user/gnome-venture/aseprite-source/extras-pixel/aseprite/"
local only = app.params.only
local INK, UMB = "#2a1a10", "#4a2c1a"
local function new() return GV.canvas{ w = 64, h = 64, mode = "icon" } end
local S = {}

function S.haul()
  local c = new()
  local wood, sack, rope = GV.R.wood, GV.ramp("#d9c08a"), GV.ramp("#a8784a")
  local b1 = c:line({ {34,56}, {50,10} }, 6)
  local b2 = c:line({ {42,58}, {58,16} }, 6)
  local body = c:ellipse(24, 43, 15, 14)
  local neck = c:rrect(18, 20, 30, 32, 3)
  c:build{
    { "plank2", b2, GV.ramp("#a8703a"), { gloss = false } },
    { "plank1", b1, wood, { gloss = false } },
    { "band", c:rect(36, 30, 56, 33):clip(b1:copy():add(b2)), rope, { flat = true } },
    { "sack", body, sack, { light = body:copy():add(neck) } },
    { "neck", neck, sack, { gloss = false } },
    { "knot", c:rrect(15, 17, 33, 22, 2), sack, { gloss = false } },
  }
  c:fill(c:rect(18, 28, 30, 29), "#a8784a"); c:seam({ {18, 28}, {30, 28} })
  c:fill(c:line({ {10,40},{14,46},{22,50} }, 1), "#a8784a")
  c:seam({ {16, 34}, {32, 34} }, { free = true })
  c:button(22, 39)
  return c
end

function S.gather()
  local c = new()
  local wick, leaf, shell, root = GV.ramp("#c08a4a"), GV.R.leaf, GV.ramp("#f1e0c0"), GV.ramp("#d9783a")
  local handle = c:line({ {14,36}, {17,16}, {32,8}, {47,16}, {50,36} }, 3)
  local basket = c:poly({ {10,34}, {54,34}, {48,58}, {16,58} }):add(c:rrect(8, 32, 55, 38, 2))
  c:build{
    { "handle", handle, GV.ramp("#a8703a"), { gloss = false } },
    { "fernL", c:poly({ {16,36},{14,22},{20,14},{24,26},{28,36} }), leaf, { gloss = false } },
    { "root", c:line({ {36,36},{38,22},{44,16} }, 5), root, { gloss = false } },
    { "shell", c:ellipse(30, 31, 8, 7), shell },
    { "fernR", c:poly({ {36,36},{44,24},{52,24},{50,36} }), GV.R.moss, { gloss = false } },
    { "basket", basket, wick },
  }
  -- shell whorl
  c:paint({ ".ooo.", "o.o.o", "o.ooo", ".ooo." }, 27, 28, { o = "#c8a070" })
  -- fern veins
  c:fill(c:line({ {21,34},{19,20} }, 1), "#2f6a3a")
  -- weave
  c:fill(c:line({ {12,42},{52,42} }, 1), "#8a5a2a"); c:fill(c:line({ {14,49},{50,49} }, 1), "#8a5a2a")
  for x = 15, 49, 6 do c:fill(c:rect(x, 38, x, 42), "#8a5a2a") end
  for x = 18, 46, 6 do c:fill(c:rect(x, 43, x, 49), "#8a5a2a"); c:fill(c:rect(x - 3, 50, x - 3, 56), "#8a5a2a") end
  return c
end

function S.feed()
  local c = new()
  local pot, soup, steam = GV.ramp("#7a6878"), GV.ramp("#e08a2a"), GV.ramp("#f1ece0", { shade = "#d8e4e4", deep = "#b8c8d0", bounce = "#e0e8e4" })
  local body = c:rrect(11, 30, 53, 55, 8)
  c:build{
    { "s1", c:line({ {24,26},{20,20},{25,14},{21,8} }, 3), steam, { flat = true } },
    { "s2", c:line({ {36,26},{32,21},{37,15},{33,10} }, 3), steam, { flat = true } },
    { "s3", c:line({ {47,26},{44,21},{48,17} }, 3), steam, { flat = true } },
    { "handles", c:ellipse(7, 38, 4, 3):add(c:ellipse(57, 38, 4, 3)), GV.ramp("#54447f"), { flat = true } },
    { "pot", body, pot },
    { "rim", c:rrect(9, 28, 55, 34, 3), GV.ramp("#8f7e8c"), { gloss = false } },
    { "soup", c:ellipse(32, 31, 20, 2.5), soup, { gloss = false, contour = false } },
  }
  c:fill(c:line({ {14,31},{50,31} }, 1), "#f0b050")
  c:seam({ {16, 46}, {48, 46} })
  c:paint({ "r.r", ".r." }, 28, 40, { r = "#4a3a4a" })
  return c
end

function S.light()
  local c = new()
  local metal, glass, flame = GV.ramp("#4a4458"), GV.ramp("#f5cf6a", { gloss = "#fff8e0", dot = "#ffffff", shade = "#e8a317", deep = "#b8661a", rim = "#fff1c8", bounce = "#e8a317" }), GV.R.flame
  local gl = c:rrect(18, 22, 46, 48, 4)
  c:build{
    { "ring", c:line({ {24,22},{26,8},{38,8},{40,22} }, 2), metal, { flat = true } },
    { "base", c:rrect(14, 46, 50, 54, 3), metal, { gloss = false } },
    { "glass", gl, glass },
    { "cap", c:poly({ {14,24},{22,15},{42,15},{50,24} }):add(c:rect(15, 22, 49, 25)), metal, { gloss = false } },
  }
  -- bars
  c:fill(c:rect(31, 25, 32, 45), "#4a4458")
  -- flame
  c:fill(c:ellipse(32, 38, 5, 7), "#f08a24"); c:fill(c:ellipse(32, 39, 3, 5), "#ffd25a"); c:fill(c:rect(31, 38, 32, 42), "#fff8e0")
  c:fill(c:poly({ {30,32},{32,27},{34,32} }), "#f08a24")
  return c
end

function S.clear()
  local c = new()
  local wood, steel = GV.R.wood, GV.ramp("#8fa6b8", { shade = "#5f7890", deep = "#3a4a68", bounce = "#6f8aa0" })
  local head = c:poly({ {30,12},{38,9},{46,6},{55,4},{58,12},{58,22},{55,30},{46,25},{38,23},{30,21} })
  c:build{
    { "chips", c:rect(8, 52, 14, 55):add(c:rect(18, 56, 22, 58)), GV.ramp("#d9a660"), { flat = true } },
    { "handle", c:line({ {14,56},{39,17} }, 5), wood },
    { "head", head, steel },
  }
  c:fill(c:line({ {55,8},{56,14},{55,22},{52,26} }, 1), "#cfe0ec")
  c:fill(c:rect(31, 14, 32, 19), "#3a4a68")
  c:seam({ {18, 50}, {30, 31} }, { free = true })
  return c
end

local order = { "haul","gather","feed","light","clear" }
for _, n in ipairs(order) do
  if not only or only == n then
    local t = S[n]():save(ASE .. "variety-stage-" .. n .. ".aseprite", OUT .. "/stage-" .. n .. ".png")
    print(n, GV.report(t))
  end
end

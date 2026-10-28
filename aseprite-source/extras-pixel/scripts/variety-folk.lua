-- variety-folk : 11 species portraits (64x64, gvlib icon mode) for game/assets/img/folk/*.png
-- run: AppRun -b --script variety-folk.lua --script-param out=DIR [--script-param only=hare]
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or "/tmp"
local ASE = "/home/user/gnome-venture/aseprite-source/extras-pixel/aseprite/"
local only = app.params.only
local INK, UMB = "#2a1a10", "#4a2c1a"
local function new() return GV.canvas{ w = 64, h = 64, mode = "icon" } end
local S = {}

function S.hare()
  local c = new()
  local fur, cream = GV.ramp("#b98a5e"), GV.ramp("#eadcc0")
  local head = c:ellipse(32, 31, 12, 10.5)
  local ears = c:ellipse(23.5, 13, 4.5, 9.5):add(c:ellipse(40.5, 13, 4.5, 9.5))
  c:build{
    { "ears", ears, fur, { gloss = false } },
    { "feet", c:ellipse(22, 55, 6.5, 3.5):add(c:ellipse(42, 55, 6.5, 3.5)), GV.ramp("#9a7048"), { gloss = false } },
    { "body", c:ellipse(32, 46, 14, 11), fur, { gloss = false } },
    { "belly", c:ellipse(32, 49, 8, 7), cream, { gloss = false, contour = false } },
    { "head", head, fur, { light = head:copy():add(ears) } },
    { "muzzle", c:ellipse(32, 35.5, 6, 5), cream, { gloss = false } },
  }
  c:fill(c:ellipse(23.5, 13, 2, 6.5):cut(head:grow(1)), "#e8a0a0")
  c:fill(c:ellipse(40.5, 13, 2, 6.5):cut(head:grow(1)), "#e8a0a0")
  c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 31, { n = INK }); c:px(31, 31, "#8a4a5a")
  c:paint({ "n.n", ".n." }, 31, 36, { n = UMB })
  c:eye(22, 24); c:eye(37, 24)
  return c
end

function S.wren()
  local c = new()
  local br, cream = GV.ramp("#9a6b3f"), GV.ramp("#e6d2ae")
  local body = c:ellipse(30, 38, 17, 14)
  local head = c:ellipse(38, 24, 10, 9.5)
  c:build{
    { "tail", c:poly({ {8,14},{15,12},{20,34},{12,40} }):add(c:ellipse(14,26,5,12)), GV.ramp("#7a4f2e"), { gloss = false } },
    { "legs", c:rect(26, 50, 28, 57):add(c:rect(34, 50, 36, 57)):add(c:rect(23, 56, 29, 58)):add(c:rect(31, 56, 37, 58)), GV.ramp("#d9a660"), { flat = true } },
    { "body", body, br, { light = body:copy():add(head), gloss = false } },
    { "breast", c:ellipse(38, 40, 9, 9), cream, { gloss = false, contour = false } },
    { "head", head, br, { light = body:copy():add(head) } },
    { "beak", c:poly({ {46,22},{58,25},{46,29} }), GV.ramp("#c8802a"), { flat = true } },
  }
  c:fill(c:rrect(18, 33, 30, 35, 1), "#6a4020"); c:fill(c:rrect(17, 39, 29, 41, 1), "#6a4020")
  c:fill(c:rrect(20, 45, 29, 46, 1), "#6a4020")
  c:fill(c:rect(33, 15, 46, 17), "#e6d2ae") -- eyebrow stripe
  c:eye(40, 20, true)
  return c
end

function S.mole()
  local c = new()
  local fur, pink = GV.ramp("#6a6478"), GV.ramp("#eba5a5")
  local head = c:ellipse(32, 27, 12.5, 11)
  c:build{
    { "body", c:ellipse(32, 44, 18, 14), fur, { gloss = false } },
    { "feet", c:ellipse(24, 57, 5, 3):add(c:ellipse(40, 57, 5, 3)), pink, { flat = true } },
    { "head", head, fur },
    { "armL", c:ellipse(15, 44, 7, 6), pink, { gloss = false } },
    { "armR", c:ellipse(49, 44, 7, 6), pink, { gloss = false } },
    { "nose", c:ellipse(32, 35, 5, 4), pink, { gloss = false } },
  }
  for _, x in ipairs{ 10, 14, 18, 46, 50, 54 } do c:fill(c:rect(x, 48, x + 1, 52), "#f4dcc0") end
  for _, x in ipairs{ 10, 14, 18, 46, 50, 54 } do c:px(x, 52, "#c98a8a"); c:px(x + 1, 52, "#c98a8a") end
  c:paint({ "n.n.n", ".nnn.", "n.n.n" }, 30, 33, { n = "#b8626a" })
  c:eye(23, 23, true); c:eye(38, 23, true)
  return c
end

function S.tortoise()
  local c = new()
  local shell, skin = GV.ramp("#7f9a3e"), GV.ramp("#c8b070")
  local dome = c:ellipse(29, 38, 21, 17):clip(c:rect(0, 0, 63, 47))
  dome:add(c:rect(9, 43, 49, 48))
  local head = c:ellipse(53, 39, 6.5, 6)
  c:build{
    { "legs", c:rrect(15, 46, 23, 56, 3):add(c:rrect(37, 46, 45, 56, 3)), skin, { gloss = false } },
    { "neck", c:rrect(46, 40, 54, 50, 3), skin, { gloss = false } },
    { "head", head, skin },
    { "shell", dome, shell },
  }
  local line = "#3f5a2a"
  c:fill(c:line({ {29,22}, {29,32} }, 1), line)
  c:fill(c:line({ {29,32}, {20,36}, {13,34} }, 1), line)
  c:fill(c:line({ {29,32}, {38,36}, {45,34} }, 1), line)
  c:fill(c:line({ {20,36}, {19,44} }, 1), line)
  c:fill(c:line({ {38,36}, {39,44} }, 1), line)
  c:fill(c:line({ {29,32}, {29,44} }, 1), line)
  c:fill(c:ellipse(29, 38, 3, 2.5), "#a8b855")
  c:seam({ {9, 45}, {49, 45} })
  c:eye(52, 37, true)
  c:px(57, 42, UMB); c:px(58, 42, UMB)
  return c
end

function S.moth()
  local c = new()
  local wing, dark = GV.ramp("#d8c8a8"), GV.ramp("#8a7358")
  local up = c:ellipse(18, 24, 14, 12):add(c:ellipse(46, 24, 14, 12))
  local lo = c:ellipse(21, 42, 10, 9):add(c:ellipse(43, 42, 10, 9))
  local ant = c:line({ {28,13},{24,8},{20,7} }, 1):add(c:line({ {36,13},{40,8},{44,7} }, 1))
  c:build{
    { "lo", lo, wing, { gloss = false } },
    { "up", up, wing },
    { "body", c:ellipse(32, 34, 5, 15), dark },
    { "head", c:ellipse(32, 17, 5, 4.5), dark, { gloss = false } },
  }
  c:fill(ant, UMB)
  c:fill(c:rect(18, 8, 19, 9), UMB)
  -- eyespots
  c:fill(c:ellipse(15, 22, 5, 4.5), "#8a7358"); c:fill(c:ellipse(15, 22, 3, 2.5), "#f0c860"); c:fill(c:ellipse(15, 22, 1.2, 1), INK)
  c:fill(c:ellipse(48, 22, 5, 4.5), "#8a7358"); c:fill(c:ellipse(48, 22, 3, 2.5), "#f0c860"); c:fill(c:ellipse(48, 22, 1.2, 1), INK)
  -- wing edge bands
  c:fill(c:line({ {8,30},{14,34},{22,34} }, 2):clip(up), "#b09870")
  c:fill(c:line({ {55,30},{49,34},{41,34} }, 2):clip(up), "#b09870")
  c:fill(c:ellipse(21, 45, 4, 3), "#b09870"); c:fill(c:ellipse(43, 45, 4, 3), "#b09870")
  c:eye(28, 15, true); c:eye(35, 15, true)
  return c
end

function S.shrew()
  local c = new()
  local fur, pink = GV.ramp("#8a6a58"), GV.ramp("#eba5a5")
  local body = c:ellipse(27, 40, 18, 12)
  local head = c:ellipse(44, 35, 9, 8)
  c:build{
    { "tail", c:line({ {12,42},{7,44},{5,50},{9,56} }, 2), GV.ramp("#b8908a"), { flat = true } },
    { "feet", c:ellipse(24, 54, 5, 3):add(c:ellipse(38, 54, 5, 3)), GV.ramp("#d99090"), { flat = true } },
    { "ear", c:ellipse(40, 26, 4, 4), fur, { gloss = false } },
    { "body", body, fur, { light = body:copy():add(head), gloss = false } },
    { "belly", c:ellipse(30, 46, 10, 5), GV.ramp("#cbb6a0"), { gloss = false, contour = false } },
    { "head", head, fur, { light = body:copy():add(head) } },
    { "snout", c:poly({ {48,28},{61,38},{48,44} }):add(c:ellipse(52, 37, 4, 5)), GV.ramp("#c4a090"), { gloss = false } },
  }
  c:fill(c:ellipse(40, 26, 2, 2), "#e8a0a0")
  c:fill(c:rect(58, 37, 59, 38), "#b8505a"); c:px(57, 38, "#b8505a")
  c:fill(c:line({ {52,42},{58,42} }, 1), UMB)
  c:eye(40, 31, true)
  return c
end

function S.gecko()
  local c = new()
  local g, belly = GV.ramp("#5fae6a"), GV.ramp("#a8d88a")
  local limbs = c:line({ {26,28},{14,24},{11,18} }, 3):add(c:line({ {38,28},{50,24},{53,18} }, 3))
  limbs:add(c:line({ {26,42},{14,46},{11,52} }, 3)):add(c:line({ {38,42},{50,46},{53,52} }, 3))
  local toes = c:ellipse(11, 16, 3.5):add(c:ellipse(53, 16, 3.5)):add(c:ellipse(11, 54, 3.5)):add(c:ellipse(53, 54, 3.5))
  local body = c:ellipse(32, 35, 9, 15)
  local head = c:ellipse(32, 18, 9, 8)
  c:build{
    { "tail", c:poly({ {28,44},{36,44},{36,52},{33,60},{29,60},{30,52} }), g, { gloss = false } },
    { "limbs", limbs, g, { gloss = false } },
    { "toes", toes, belly, { flat = true } },
    { "body", body, g, { light = body:copy():add(head), gloss = false } },
    { "head", head, g, { light = body:copy():add(head) } },
  }
  c:spot(c:ellipse(30, 32, 2, 2), "#2f7a4a"); c:spot(c:ellipse(35, 38, 2, 2), "#2f7a4a"); c:spot(c:ellipse(31, 44, 2, 1.5), "#2f7a4a")
  c:fill(c:rect(31, 24, 32, 27):clip(body), "#a8d88a")
  c:eye(24, 12); c:eye(34, 12)
  c:fill(c:line({ {29,24},{32,25},{35,24} }, 1), UMB)
  return c
end

function S.dragonfly()
  local c = new()
  local glass, body, eyes = GV.R.glass, GV.ramp("#3f8fb0"), GV.ramp("#4fae7a")
  local wings = c:ellipse(15, 24, 12, 5.5):add(c:ellipse(49, 24, 12, 5.5))
  local wl = c:ellipse(17, 33, 11, 5):add(c:ellipse(47, 33, 11, 5))
  c:build{
    { "wl", wl, glass, { gloss = false } },
    { "wu", wings, glass, { gloss = false } },
    { "tail", c:rrect(30, 28, 33, 57, 1), body, { gloss = false } },
    { "thorax", c:ellipse(32, 27, 5.5, 7), body },
    { "head", c:ellipse(32, 15, 8, 7), eyes },
  }
  c:seam({ {31, 38}, {31, 56} }, { free = true })
  c:fill(c:line({ {6,24},{22,24} }, 1):clip(wings), "#8fb4d6"); c:fill(c:line({ {42,24},{58,24} }, 1):clip(wings), "#8fb4d6")
  c:fill(c:line({ {8,33},{23,33} }, 1):clip(wl), "#8fb4d6"); c:fill(c:line({ {41,33},{56,33} }, 1):clip(wl), "#8fb4d6")
  c:eye(25, 11, true); c:eye(34, 11, true)
  return c
end

function S.toad()
  local c = new()
  local br, belly, gold = GV.ramp("#8f7a4a"), GV.ramp("#d8c490"), GV.ramp("#e8a317")
  local body = c:ellipse(32, 41, 22, 15)
  local bumps = c:ellipse(19, 24, 8):add(c:ellipse(44, 24, 8))
  c:build{
    { "toes", c:ellipse(14, 54, 5, 2.5):add(c:ellipse(49, 54, 5, 2.5)), belly, { flat = true } },
    { "body", body, br, { light = body:copy():add(bumps), gloss = false } },
    { "bumps", bumps, br, { light = body:copy():add(bumps), gloss = { 14, 18 } } },
    { "belly", c:ellipse(32, 48, 12, 6), belly, { gloss = false } },
    { "eyeL", c:ellipse(19, 24, 4.5), gold, { flat = true } },
    { "eyeR", c:ellipse(44, 24, 4.5), gold, { flat = true } },
  }
  for _, p in ipairs{ {13,40},{21,36},{40,36},{50,41},{30,31},{9,48},{54,48},{26,42},{37,43} } do
    c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#5e4a28")
  end
  c:fill(c:ellipse(19, 24, 1.5, 3.5), INK); c:fill(c:ellipse(44, 24, 1.5, 3.5), INK)
  c:px(18, 21, "#fff3c8")
  c:fill(c:line({ {20,43},{26,45},{32,46},{38,45},{44,43} }, 2), INK)
  c:px(29, 36, INK); c:px(34, 36, INK)
  return c
end

function S.grasshopper()
  local c = new()
  local g, d = GV.ramp("#6fb04a"), GV.ramp("#3f7a30")
  local body = c:ellipse(29, 36, 20, 7.5)
  local head = c:ellipse(51, 33, 7, 7)
  local thigh = c:poly({ {14,34},{24,28},{30,48},{22,50} })
  c:build{
    { "ant", c:line({ {54,28},{56,18},{60,10} }, 1):add(c:line({ {50,28},{50,18},{54,8} }, 1)), GV.ramp("#8a6a30"), { flat = true } },
    { "legs", c:line({ {22,48},{10,56},{6,50} }, 2):add(c:line({ {36,42},{38,50},{34,56} }, 2)):add(c:line({ {44,42},{48,52},{44,57} }, 2)), d, { flat = true } },
    { "body", body, g, { light = body:copy():add(head), gloss = false } },
    { "wing", c:ellipse(24, 33, 17, 4.5), GV.ramp("#a8cf74"), { gloss = false, contour = false } },
    { "head", head, g, { light = body:copy():add(head) } },
    { "thigh", c:ellipse(20, 41, 11, 6), d, { gloss = false } },
  }
  c:fill(c:line({ {42,32},{42,40} }, 1), "#3f7a30")
  c:fill(c:rect(12, 40, 28, 41), "#2f5a28")
  c:eye(52, 30, true)
  c:fill(c:line({ {54,38},{57,38} }, 1), UMB)
  return c
end

function S.firefly()
  local c = new()
  local dark, glow, red = GV.ramp("#5a4030"), GV.ramp("#f0e050", { gloss = "#ffffd0", dot = "#fffff0", shade = "#c8b030", deep = "#8a7a20", rim = "#fff8a0", bounce = "#d8c040" }), GV.ramp("#d8502a")
  local wings = c:ellipse(18, 32, 7, 14):add(c:ellipse(46, 32, 7, 14))
  local body = c:ellipse(32, 38, 9.5, 18)
  c:build{
    { "legs", c:line({ {22,28},{14,32} }, 2):add(c:line({ {42,28},{50,32} }, 2)):add(c:line({ {23,38},{15,44} }, 2)):add(c:line({ {41,38},{49,44} }, 2)):add(c:line({ {25,46},{19,54} }, 2)):add(c:line({ {39,46},{45,54} }, 2)), GV.ramp("#3a2a20"), { flat = true } },
    { "wings", wings, GV.ramp("#e8dcc0"), { gloss = false } },
    { "body", body, dark },
    { "glow", c:ellipse(32, 49, 9, 8):clip(body), glow, { gloss = { 28, 46 } } },
    { "pron", c:ellipse(32, 22, 7, 5), red, { gloss = false } },
    { "head", c:ellipse(32, 15, 6, 4.5), GV.ramp("#3a2a20"), { gloss = false } },
  }
  c:fill(c:line({ {32,24},{32,34} }, 1), "#3a2a20")
  c:fill(c:line({ {28,13},{25,8},{22,7} }, 1):add(c:line({ {36,13},{39,8},{42,7} }, 1)), UMB)
  c:eye(28, 13, true); c:eye(34, 13, true)
  -- sparkle ticks around the glow
  for _, p in ipairs{ {12,52},{51,52} } do c:fill(c:rect(p[1], p[2] + 1, p[1] + 2, p[2] + 1), "#fff3a0"); c:fill(c:rect(p[1] + 1, p[2], p[1] + 1, p[2] + 2), "#fff3a0") end
  return c
end

local order = { "hare","wren","mole","tortoise","moth","shrew","gecko","dragonfly","toad","grasshopper","firefly" }
for _, n in ipairs(order) do
  if not only or only == n then
    local c = S[n]()
    local t = c:save(ASE .. "variety-folk-" .. n .. ".aseprite", OUT .. "/" .. n .. ".png")
    print(n, GV.report(t))
  end
end

-- Shared bits for the Puzzles cast stickers (cast-*.lua). Shapes copied from the approved
-- jeff-v2 / ffej-v1 / wizard-v1 scripts so every sticker matches the cast exactly.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local K = { D = D, GV = GV,
  ASE = D .. "extras-pixel/cast/",
  PNG = "/home/user/gnome-venture/game/assets/img/puzzles/cast/" }

-- Ffej: upside-down block, knob down, notch up. Returns body (dx/dy shifted); arms are per sticker.
function K.ffejBody(c, dx, dy)
  dx, dy = dx or 0, dy or 0
  local body = c:rrect(16+dx, 13+dy, 47+dx, 41+dy, 3)
  body:add(c:rrect(26+dx, 39+dy, 37+dx, 52+dy, 2)); body:add(c:ellipse(31.5+dx, 50+dy, 7, 5.5))
  body:cut(c:rect(28+dx, 10+dy, 35+dx, 17+dy)); body:cut(c:ellipse(31.5+dx, 14+dy, 6, 4.5))
  return body
end
K.FFEJ_BODY, K.FFEJ_ARM = GV.ramp("#2f7a3e"), GV.ramp("#3c8f4a")
-- Ffej seams + button at the knob root
function K.ffejSeams(c, dx, dy)
  dx, dy = dx or 0, dy or 0
  c:seam({ {19+dx, 39+dy}, {26+dx, 39+dy} }); c:seam({ {37+dx, 39+dy}, {44+dx, 39+dy} })
  c:button(30+dx, 43+dy)
end
-- Ffej eyepatch (left) + strap, no eye/brow/mouth (those vary per mood)
function K.ffejPatch(c, dx, dy)
  dx, dy = dx or 0, dy or 0
  c:fill(c:rrect(22+dx, 24+dy, 28+dx, 29+dy, 1), "#2a1a10")
  c:paint({ "u.......u", ".u.....u.", "..uuuuu.." }, 20+dx, 21+dy, { u = "umber" })
  c:paint({ "ssss", ".sss" }, 23+dx, 25+dy, { s = "#4a3a6a" })
end

-- Wizard: ember puzzle body + arms (knob up, notch bottom), shifted by dx, dy (v1 used dy=4)
function K.wizardShapes(c, dx, dy)
  local function R(x0, y0, x1, y1, r) return c:rrect(x0+dx, y0+dy, x1+dx, y1+dy, r or 0) end
  local body = R(17, 26, 46, 49, 3)
  body:add(R(26, 14, 37, 28, 2)); body:add(c:ellipse(31.5+dx, 15+dy, 7, 5.5))
  body:cut(c:rect(27+dx, 44+dy, 36+dx, 50+dy))
  local arms = R(11, 33, 52, 39, 2); arms:add(c:ellipse(12+dx, 36+dy, 3, 4)); arms:add(c:ellipse(51+dx, 36+dy, 3, 4))
  arms:cut(R(18, 28, 45, 45))
  local hat = c:poly({ {29+dx, 6+dy-4}, {37+dx, 10+dy-4}, {41+dx, 20+dy-4}, {22+dx, 20+dy-4}, {27+dx, 11+dy-4} })
  hat:add(c:rrect(18+dx, 19+dy-4, 45+dx, 22+dy-4, 1))
  local beard = c:ellipse(31.5+dx, 44+dy-4, 11, 8):clip(c:rect(0, 40+dy-4, 63, 52+dy-4)):cut(c:rect(27+dx, 48+dy-4, 36+dx, 54+dy-4))
  beard:add(c:rrect(24+dx, 38+dy-4, 39+dx, 42+dy-4, 2))
  return body, arms, hat, beard
end
K.WIZ_BODY, K.WIZ_ARM, K.WIZ_HAT = GV.ramp("#e0501f"), GV.ramp("#f08a24"), GV.ramp("#5a3f9e")
K.WIZ_BEARD = GV.ramp("#f4ecd8", { pale = true, dot = "#fff3c8" })   -- no pure white dot
-- Wizard face and hat trim (same offsets as v1 with dy=4 baked in); dx,dy are extra shifts
function K.wizardFace(c, dx, dy)
  c:paint({ "..s..", ".sss.", "sssss", ".sss.", "s...s" }, 31+dx, 11+dy, { s = "#f5cf6a" })
  c:px(33+dx, 12+dy, "#fff1c8")
  c:seam({ {21+dx, 20+dy}, {42+dx, 20+dy} })
  c:paint({ ".ggggg", "gggggg" }, 20+dx, 31+dy, { g = "#c4c4c4" })
  c:paint({ "ggggg.", "gggggg" }, 34+dx, 31+dy, { g = "#c4c4c4" })
  c:paint({ "......", "ggGGGG" }, 20+dx, 31+dy, { G = "#9a9a9a" })
  c:paint({ "......", "GGGGgg" }, 34+dx, 31+dy, { G = "#9a9a9a" })
  c:eye(21+dx, 33+dy); c:eye(35+dx, 33+dy)
  c:paint({ "u.....u", ".uuuuu." }, 28+dx, 40+dy, { u = "umber" })
end

-- small jigsaw piece (Jeff's mini): 7x8 block, knob up, tab right, notch bottom, at top-left x,y
function K.miniPiece(c, x, y)
  local m = c:rrect(x, y+2, x+6, y+9, 1)
  m:add(c:ellipse(x+3, y+0.5, 2.5, 2.5)); m:add(c:ellipse(x+7, y+5.5, 2, 2))
  m:cut(c:ellipse(x+3, y+10, 2, 2))
  return m
end

-- Jeff (jeff-v2): leaning body, knob up, notch at the bottom, shifted by dx, dy. Arms are per pose.
K.JEFF_BODY, K.JEFF_ARM = GV.ramp("#1fb86b"), GV.ramp("#2cc97c")
function K.jeffBody(c, dx, dy)
  dx, dy = dx or 0, dy or 0
  local body = c:poly({ {16+dx, 25+dy}, {45+dx, 22+dy}, {46+dx, 50+dy}, {18+dx, 52+dy} })
  body:add(c:rrect(26+dx, 14+dy, 35+dx, 26+dy, 2)); body:add(c:ellipse(30.5+dx, 12+dy, 7.5, 6))
  body:cut(c:ellipse(32+dx, 53+dy, 6, 4.5))
  body:cut(c:rect(0, 61, 63, 63))
  return body
end
-- Jeff parts: arm tab (flat) and body (lit-side stitch) entries for c:build
function K.jeffArm(name, m) return { name, m, K.JEFF_ARM, { flat = true } } end
function K.jeffBodyPart(m) return { "body", m, K.JEFF_BODY, { stitch = { side = "lit" } } } end
-- Jeff button + seams + face (call after c:build). mood: grin (host) | hmm (think) | shout (cheer) draw the
-- approved faces exactly; mood "custom" takes o.eyes (open|happy|shut|wince|right|none), o.brows
-- (raised|up|worried), o.mouth (any JMOUTH key). o.nobutton skips the knob button (e.g. under a hat).
local JMOUTH = {
  grin  = { { "u.........u", ".u.......u.", ".uccccccc u", "..uuuuuuu.." }, 25, 38 },
  hmm   = { { "......uu", "uuuuuu.." }, 25, 40 },
  shout = { { ".uuuuuuuuu.", "ucccccccccu", "udddddddddu", "udddddddddu", ".uddddddddu", "..uuuuuuu.." }, 25, 38 },
  -- new-pose mouths (o.mouth)
  smile   = { { "u.........u", ".uu.....uu.", "...uuuuu..." }, 25, 38 },
  open    = { { ".uuuuuuuuu.", ".ucccccccu.", "..udddddu..", "...uuuuu..." }, 25, 38 },
  o       = { { ".uu.", "uddu", "uddu", ".uu." }, 29, 39 },
  grimace = { { "uuuuuuuuuuu", "ucucucucucu", "ucucucucucu", "uuuuuuuuuuu" }, 25, 38 },
  focus   = { { "uuuuuuu..", "......udu", ".......u." }, 26, 40 },   -- tight line, tongue out the corner
}
K.JMOUTH = JMOUTH
-- new-pose eyes (o.eyes), drawn at the jeff-v2 eye spots (20,28) and (36,27)
local JEYES = {
  happy = { { "..u..", ".uuu.", "uu.uu", "u...u" }, { "..u..", ".uuu.", "uu.uu", "u...u" }, 1 },
  shut  = { { "u...u", "uu.uu", ".uuu." }, { "u...u", "uu.uu", ".uuu." }, 2 },
  wince = { { "u....", "uuu..", "..uuu", "uuu..", "u...." }, { "....u", "..uuu", "uuu..", "..uuu", "....u" }, 0 },
  right = { { ".hhh.", "hhhuu", "hhuuu", "hhuuu", ".hhh." }, { ".hhh.", "hhhuu", "hhuuu", "hhuuu", ".hhh." }, 0 },
}
-- new-pose brows (o.brows): {left rows, right rows}, left at (19,25) right at (36,24)
local JBROWS = {
  raised  = { nil, { "uuuu" } },
  up      = { { "uuuu" }, { "uuuu" } },
  worried = { { "..uu", "uu.." }, { "uu..", "..uu" } },
}
function K.jeffFace(c, dx, dy, mood, o)
  dx, dy, o = dx or 0, dy or 0, o or {}
  local U = { u = "umber", c = "#f1ece0", d = "#6b1b2c", h = "halo" }
  if not o.nobutton then c:button(29+dx, 15+dy) end
  c:seam({ {21+dx, 47+dy}, {25+dx, 47+dy} }); c:seam({ {39+dx, 47+dy}, {43+dx, 47+dy} })
  if mood == "grin" then
    c:eye(20+dx, 28+dy); c:eye(36+dx, 27+dy)
    c:paint({ "uuuu" }, 36+dx, 24+dy, U)
  elseif mood == "hmm" then
    c:eye(20+dx, 28+dy); c:eye(36+dx, 27+dy)
    c:paint({ "..uuuu", "uu...." }, 34+dx, 22+dy, U)
    c:paint({ "uuuu" }, 19+dx, 25+dy, U)
  elseif mood == "shout" then
    c:eye(20+dx, 28+dy); c:eye(36+dx, 27+dy)
    c:paint({ "uuuu" }, 19+dx, 24+dy, U); c:paint({ "uuuu" }, 36+dx, 23+dy, U)
  else -- new poses: o.eyes, o.brows, o.mouth (keys of JEYES / JBROWS / JMOUTH; eyes default "open")
    local e = JEYES[o.eyes]
    if e then c:paint(e[1], 20+dx, 28+dy+e[3], U); c:paint(e[2], 36+dx, 27+dy+e[3], U)
    elseif o.eyes ~= "none" then c:eye(20+dx, 28+dy); c:eye(36+dx, 27+dy) end
    local b = JBROWS[o.brows]
    if b and b[1] then c:paint(b[1], 19+dx, 25+dy, U) end
    if b and b[2] then c:paint(b[2], 36+dx, 24+dy, U) end
    mood = o.mouth
  end
  local m = JMOUTH[mood]
  if m then c:paint(m[1], m[2]+dx, m[3]+dy, U) end
end

function K.save(c, name)
  -- --script-param out=<dir>/ and ase=<dir>/ redirect the PNG / .aseprite (staging, re-render checks)
  local P = app.params or {}
  local t = c:save((P.ase or K.ASE) .. name .. ".aseprite", (P.out or K.PNG) .. name .. ".png")
  print(name, GV.report(t))
  assert(t.semi == 0 and t.bw == 0 and t.margin >= 3, name .. " failed checks")
  return t
end
return K

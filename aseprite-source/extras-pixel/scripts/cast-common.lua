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

function K.save(c, name)
  local t = c:save(K.ASE .. name .. ".aseprite", K.PNG .. name .. ".png")
  print(name, GV.report(t))
  assert(t.semi == 0 and t.bw == 0 and t.margin >= 3, name .. " failed checks")
  return t
end
return K

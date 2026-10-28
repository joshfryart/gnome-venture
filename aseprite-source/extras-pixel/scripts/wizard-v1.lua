-- Old Wizard v1 (Puzzles helper): ember puzzle-piece body, tall bent purple hat with a gold star on the knob,
-- bushy grey brows, big cream beard, wooden staff with a gold ball held in the right arm. 64x64 sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/wizard/"

-- shared puzzle-piece body (knob up, notch bottom, arms out), shifted down by dy to leave room for the hat
local function shapes(c, dy)
  local function R(x0, y0, x1, y1, r) return c:rrect(x0, y0 + dy, x1, y1 + dy, r or 0) end
  local body = R(17, 26, 46, 49, 3)
  body:add(R(26, 14, 37, 28, 2)); body:add(c:ellipse(31.5, 15 + dy, 7, 5.5))
  body:cut(c:rect(27, 44 + dy, 36, 50 + dy))                       -- notch
  local arms = R(11, 33, 52, 39, 2); arms:add(c:ellipse(12, 36 + dy, 3, 4)); arms:add(c:ellipse(51, 36 + dy, 3, 4))
  arms:cut(R(18, 28, 45, 45))
  return body, arms
end

local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dy = 4
local body, arms = shapes(c, dy)
local hat = c:poly({ { 29, 6 }, { 37, 10 }, { 41, 20 }, { 22, 20 }, { 27, 11 } })   -- cone with a kink
hat:add(c:rrect(18, 19, 45, 22, 1))                                                  -- brim
local beard = c:ellipse(31.5, 44, 11, 8):clip(c:rect(0, 40, 63, 52)):cut(c:rect(27, 48, 36, 54))
beard:add(c:rrect(24, 38, 39, 42, 2))                                                -- moustache block
local staff = c:rect(52, 15, 53, 54)
local ball = c:ellipse(52.5, 12, 3, 3)

c:build{
  { "staff", staff, "wood", { flat = true } },
  { "ball",  ball,  "gold", {} },
  { "arms",  arms,  GV.ramp("#f08a24"), { flat = true } },
  { "body",  body,  GV.ramp("#e0501f"), { stitch = { side = "lit" } } },
  { "beard", beard, GV.ramp("#f4ecd8", { pale = true }), { gloss = { 26, 41 } } },
  { "hat",   hat,   GV.ramp("#5a3f9e"), { gloss = { 29, 10 } } },
}
-- hand grips the staff
c:paint({ "aaaa", "aaaa", "aaaa" }, 50, 38 + dy - 2, { a = "#f08a24" })
c:px(50, 38 + dy - 2, "#ffc27a")
-- gold star on the hat
c:paint({ "..s..", ".sss.", "sssss", ".sss.", "s...s" }, 31, 11, { s = "#f5cf6a" })
c:px(33, 12, "#fff1c8")
-- hat band seam
c:seam({ { 21, 20 }, { 42, 20 } })
-- brows (grey, bushy) above locked eyes
c:paint({ ".ggggg", "gggggg" }, 20, 30 + dy - 3, { g = "#c4c4c4" })
c:paint({ "ggggg.", "gggggg" }, 34, 30 + dy - 3, { g = "#c4c4c4" })
c:paint({ "......", "ggGGGG" }, 20, 30 + dy - 3, { G = "#9a9a9a" })
c:paint({ "......", "GGGGgg" }, 34, 30 + dy - 3, { G = "#9a9a9a" })
c:eye(21, 29 + dy); c:eye(35, 29 + dy)
-- kind smile on the moustache
c:paint({ "u.....u", ".uuuuu." }, 28, 40, { u = "umber" })

local t = c:save(OUT .. "wizard-v1.aseprite", OUT .. "wizard-v1.png")
print("wizard-v1", GV.report(t))
assert(t.semi == 0 and t.margin >= 3)

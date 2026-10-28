-- Puzzles cast, 64x64 Stitched Toy stickers: Jeff (helper, centre), Ffej (evil twin, upside down, left), the Old Wizard (helper, right).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/jeff/"

-- puzzle-piece body; up=false mirrors it top to bottom (knob down, notch up)
local function shapes(c, up)
  local function Y(y) return up and y or 63 - y end
  local function R(x0, y0, x1, y1, r) local a, b = Y(y0), Y(y1); return c:rrect(x0, math.min(a, b), x1, math.max(a, b), r or 0) end
  local body = R(17, 26, 46, 49, 3)
  body:add(R(26, 14, 37, 28, 2)); body:add(c:ellipse(31.5, Y(15), 7, 5.5))
  local nt = Y(47); body:cut(c:rect(27, math.min(nt - 3, nt + 3), 36, math.max(nt - 3, nt + 3)))
  local arms = R(11, 33, 52, 39, 2); arms:add(c:ellipse(12, Y(36), 3, 4)); arms:add(c:ellipse(51, Y(36), 3, 4))
  arms:cut(R(18, 28, 45, 45))
  return body, arms, Y
end

local function save(c, name) local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png"); print(name, GV.report(t)) end

-- Jeff: bright green, big eyes, wide smile
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local body, arms = shapes(c, true)
  c:build{ { "arms", arms, GV.ramp("#2cc97c"), { flat = true } }, { "body", body, GV.ramp("#1fb86b"), { stitch = { side = "lit" } } } }
  c:button(30, 27); c:seam({ {20, 44}, {26, 44} }); c:seam({ {37, 44}, {43, 44} })
  c:eye(23, 30); c:eye(36, 30)
  c:paint({ "u.......u", ".uuuuuuu." }, 27, 39, { u = "umber" })
  save(c, "jeff")
end

-- Ffej: upside-down, dark green-teal, eyepatch, one slanted brow, crooked smirk
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local body, arms = shapes(c, false)
  c:build{ { "arms", arms, GV.ramp("#2f9e6a"), { flat = true } }, { "body", body, GV.ramp("#157a55"), { stitch = { side = "lit" } } } }
  c:seam({ {20, 19}, {26, 19} }); c:seam({ {37, 19}, {43, 19} })
  c:eye(36, 29)                                                        -- good eye
  c:fill(c:rect(22, 29, 28, 34), "#2a1a10"); c:paint({ "u.....", ".u...." }, 20, 27, { u = "umber" }) -- patch + strap
  c:paint({ ".....uu", "....uu." }, 35, 24, { u = "umber" })          -- angry brow
  c:paint({ "u........", ".uuuuuuuu" }, 26, 36, { u = "umber" })       -- smirk, low on one side
  c:paint({ "uu" }, 35, 38, { u = "umber" })
  save(c, "ffej")
end

-- Old Wizard: ember orange body, purple hat on the knob, cream beard, grey brows
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local body, arms = shapes(c, true)
  local hat = c:poly({ { 31, 6 }, { 36, 14 }, { 42, 16 }, { 21, 16 }, { 27, 14 } })
  local beard = c:ellipse(31.5, 38, 11, 9):clip(c:rect(0, 34, 63, 49)):cut(c:rect(27, 46, 36, 50))
  c:build{
    { "arms", arms, GV.ramp("#f0a020"), { flat = true } },
    { "body", body, GV.ramp("#e0501a"), { stitch = { side = "lit" } } },
    { "beard", beard, GV.ramp("#f4ecd8", { pale = true }), {} },
    { "hat", hat, GV.ramp("#6a4fb0"), {} },
  }
  c:button(30, 10)
  c:paint({ "ggggg" }, 22, 28, { g = "#b8b8b8" }); c:paint({ "ggggg" }, 35, 28, { g = "#b8b8b8" })
  c:eye(23, 30, true); c:eye(36, 30, true)
  c:paint({ "uuuu" }, 28, 36, { u = "umber" })
  save(c, "wizard")
end

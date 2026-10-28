-- Jeff the puzzler: puzzle-piece mascot for the Puzzles section. 3 variations (happy, grumpy, sleepy). 64x64 Stitched Toy sticker.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local OUT = D .. "extras-pixel/jeff/"

local function jeff(name, base, face)
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local body = c:rrect(17, 26, 46, 49, 3)
  body:add(c:rrect(26, 14, 37, 28, 2)); body:add(c:ellipse(31.5, 15, 7, 5.5))   -- head knob
  body:cut(c:rect(27, 44, 36, 50))                                              -- bottom notch
  local arms = c:rrect(11, 33, 52, 39, 2); arms:add(c:ellipse(12, 36, 3, 4)); arms:add(c:ellipse(51, 36, 3, 4))
  arms:cut(c:rect(18, 28, 45, 45))
  c:build{
    { "arms", arms, base.limb, { flat = true } },
    { "body", body, base.main, { stitch = { side = "lit" } } },
  }
  c:seam({ {20, 44}, {26, 44} }); c:seam({ {37, 44}, {43, 44} })
  c:button(30, 27)
  if face == "happy" then
    c:eye(24, 30); c:eye(35, 30)
    c:paint({ "u.......u", ".uuuuuuu." }, 27, 38, { u = "umber" })
  elseif face == "grumpy" then
    c:eye(24, 30); c:eye(35, 30)
    c:paint({ "uu.....", ".uu...."}, 22, 27, { u = "umber" }); c:paint({ ".....uu", "....uu." }, 38, 27, { u = "umber" })
    c:paint({ ".uuuuuuu.", "u.......u" }, 27, 38, { u = "umber" })
  else
    c:paint({ "uuuuu" }, 22, 32, { u = "umber" }); c:paint({ "uuuuu" }, 34, 32, { u = "umber" })
    c:paint({ ".uuu.", "u...u", ".uuu." }, 29, 38, { u = "umber" })
    c:paint({ "zz.", ".z.", "zz." }, 46, 13, { z = "umber" })
  end
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(name, GV.report(t))
end

jeff("jeff-happy",  { main = GV.ramp("#1fb86b"), limb = GV.ramp("#2cc97c") }, "happy")
jeff("jeff-grumpy", { main = GV.ramp("#e0401a"), limb = GV.ramp("#f0a020") }, "grumpy")
jeff("jeff-sleepy", { main = GV.ramp("#7b66b4"), limb = GV.ramp("#9a86cc") }, "sleepy")

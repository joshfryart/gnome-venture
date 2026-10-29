-- cf_test.lua : Cat Fish test art (grey cat idle A + plain plushie fish). Run: AppRun -b --script cf_test.lua
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../gvlib/gvlib.lua")
local OUT = here .. "/test/"

-- ===== cat body, grey template, idle A (64x64 sticker) =====
do
  local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
  local grey = GV.ramp("#a9a5b0")
  local pink = GV.ramp("#e8909c")
  local p = c:build{
    { "tail",  c:line({ {46,50}, {51,48}, {53,43}, {51,38} }, 4), grey, { flat = true } },
    { "body",  c:ellipse(31.5, 44, 18, 11), grey, { stitch = { side = "lit" } } },
    { "earL",  c:poly({ {16,19}, {17,7}, {29,12} }), grey },
    { "earR",  c:poly({ {34,12}, {46,7}, {47,19} }), grey },
    { "head",  c:ellipse(31.5, 22, 15, 12), grey, { stitch = { side = "lit" } } },
    { "pawL",  c:ellipse(24, 53.5, 5, 2.5), grey, { flat = true } },
    { "pawR",  c:ellipse(39, 53.5, 5, 2.5), grey, { flat = true } },
  }
  c:fill(c:poly({ {19,17}, {19,10}, {25,13} }), pink.base)
  c:fill(c:poly({ {38,13}, {44,10}, {44,17} }), pink.base)
  c:fill(c:ellipse(31.5, 46, 8, 5), GV.ramp("#d6d2da").base)       -- belly patch
  c:seam({ {31, 35}, {31, 41} })                                      -- belly seam
  c:button(29, 40)
  c:eye(19, 19); c:eye(37, 19)
  c:paint({ "ppp", ".p." }, 30, 26, { p = pink.shade })               -- nose
  c:paint({ "u...u", ".u.u.", "..u.." }, 29, 29, { u = "umber" })
  local t = c:save(OUT .. "cf-cat-grey-idleA.aseprite", OUT .. "cf-cat-grey-idleA.png")
  print("cat  " .. GV.report(t))
end

-- ===== plain plushie fish (48x48 sticker) =====
do
  local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }
  local f = GV.ramp("#e0872a")
  local fin = GV.ramp("#f2c14e")
  c:build{
    { "tail", c:poly({ {31,24}, {41,12}, {41,36} }), fin },
    { "fin",  c:poly({ {13,15}, {19,8}, {27,15} }), fin, { flat = true } },
    { "body", c:ellipse(20.5, 24, 15, 10), f, { stitch = { side = "lit" } } },
  }
  c:seam({ {30, 17}, {30, 31} })
  c:eye(8, 20, true)
  c:paint({ "uu" }, 4, 29, { u = "umber" })
  local t = c:save(OUT .. "cf-fish-1.aseprite", OUT .. "cf-fish-1.png")
  print("fish " .. GV.report(t))
end

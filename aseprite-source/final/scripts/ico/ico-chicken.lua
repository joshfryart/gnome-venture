local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local body = c:ellipse(29, 37, 17, 11.5):add(c:ellipse(39, 25, 8, 8)):add(c:poly({ {31,22},{44,28},{40,40},{26,34} }))
local tail = c:poly({ {9,21},{14,22},{20,28},{20,38},{12,36},{10,30} })
local legs = c:rect(25, 46, 27, 53):add(c:rect(33, 46, 35, 53)):add(c:rect(24, 52, 29, 53)):add(c:rect(32, 52, 37, 53))
local comb = c:ellipse(34.5, 18, 2.5):add(c:ellipse(39, 16, 3)):add(c:ellipse(43.5, 18.5, 2.5))
c:build{
  { "legs", legs, "gold", { flat = true } },
  { "tail", tail, GV.ramp("#c9792c") },
  { "comb", comb, "red", { gloss = false } },
  { "body", body, GV.ramp("#b5651d"), { gloss = { 20, 32 } } },
  { "wing", c:line({ {17,37},{21,41},{27,43},{33,42},{38,38} }, 3), "#8a4f2a", { flat = true, contact = false } },
  { "wattle", c:ellipse(44, 32, 1.5, 2.5), "red", { flat = true } },
  { "beak", c:poly({ {45,22},{52,25},{52,26},{45,29} }), "gold", { flat = true } },
}
c:paint({ "ss.", ".ss" }, 21, 46, { s = "#8a4f2a" })
c:paint({ "ss.", ".ss" }, 30, 46, { s = "#8a4f2a" })
c:eye(39, 22, true)
local t = c:save(O .. "aseprite/ico/ico-chicken.aseprite", O .. "png/ico/ico-chicken.png")
print("ico-chicken " .. GV.report(t))

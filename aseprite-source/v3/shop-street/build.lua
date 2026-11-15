-- Run: AppRun -b --script-param upto=4 --script-param region=NA --script-param out=<dir>/ --script build.lua
-- upto: run passes 1..N (p1-base, p2-polish, p3-rich, p4-tidy), saving stages/<region>-<N>.png/.aseprite after each.
-- region: one code, or ALL (final pass only is saved per region; p1-p3 saved for NA).
local DIR = "/home/user/gnome-venture/aseprite-source/v3/shop-street/"
local X = dofile(DIR .. "common.lua")
local HP = X.HP
local upto = tonumber(app.params.upto or "4")
local want = app.params.region or "NA"
local OUT = app.params.out or DIR
local NAMES = { "p1-base", "p2-polish", "p3-rich", "p4-tidy" }
local regs = (want == "ALL") and X.REGIONS or { want }
for _, rg in ipairs(regs) do
  local look = X.LOOKS[X.REGION_LOOK[rg] or "timber"]
  local c = HP.canvas{ w = X.W, h = X.H, scale = 1, name = "shop-street-" .. rg }
  local L = X.layout()
  X.region, X.look = rg, look
  for n = 1, upto do
    local path = DIR .. NAMES[n] .. ".lua"
    local f = io.open(path)
    if f then
      f:close()
      dofile(path)(c, L, X)
      if n == upto or rg == "NA" then
        c:save{ aseprite = OUT .. "stages/" .. rg .. "-" .. n .. "-" .. NAMES[n] .. ".aseprite", png = OUT .. "stages/" .. rg .. "-" .. n .. "-" .. NAMES[n] .. ".png", scale = 1 }
      end
    end
  end
  print("built " .. rg .. " upto " .. upto)
end

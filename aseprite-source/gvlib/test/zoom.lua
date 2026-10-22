-- zoom.lua: upscale PNGs for viewing. usage: -b --script-param in=<png> --script-param out=<png> --script-param s=6 --script zoom.lua
local p = app.params
local spr = app.open(p["in"])
local s = tonumber(p.s or "6")
spr:resize(spr.width * s, spr.height * s)
spr:saveCopyAs(p.out)
spr:close()

Perch batch generator. Covers 475 pals (570 rows in puzzle_pals.txt minus 95 whimsy-* shapes).
Note: all 95 rare rows are whimsy, so the 475 are 285 common + 190 uncommon; rare sparkle is implemented but
exercised only in the sample (rarity forced to rare on 4 pals).
Files: build_params.py (sticker -> ramps + hash/keyword choices -> params.lua), perch_gen.lua (Aseprite generator), make_contact.py.
Run from this dir (R=/home/user/gnome-venture):
  python3 -I build_params.py /home/user/gnome-venture params.lua
  mkdir -p out && /tmp/aseq/squashfs-root/AppRun -b --script-param out=$PWD/out/ --script-param data=$PWD/params.lua --script perch_gen.lua
  (~5 s; prints "rendered 475"; add --script-param only=key1,key2 for a subset, --script-param aseprite=1 for .aseprite too)
Sample (12): sample_keys.txt, sample_params.lua, sample/, sample-contact6x.png, sample-contact-order.txt

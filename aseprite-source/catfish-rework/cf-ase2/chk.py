import sys, os
sys.path.insert(0,'/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2')
import mock_ase as m
r=m.r
d=sys.argv[1].rstrip('/')+'/'
out='/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2/chk-out/'
os.makedirs(out,exist_ok=True)
args=['--in',d,'--out',out,'--check','--tones',m.CF+'tones.json','--overlays',m.OVJ,'--glob',sys.argv[2] if len(sys.argv)>2 else 'cf-*.png']
sys.exit(r.main(args))

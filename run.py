#!/usr/bin/env python3

from pathlib import Path
import sys
sys.path.insert(0, (Path(__file__).parent / "submodules" / "vunit").as_posix())
from vunit import VUnit, about
import vunit

print(about.VERSION)
raise Exception(vunit.__file__)


ROOT = Path(__file__).parent / "src"

VU = VUnit.from_argv(compile_builtins = False)
VU.add_vhdl_builtins()
VU.add_osvvm()
VU.add_random()
VU.add_com()
spw = VU.add_library("spw")
spw.add_source_files(ROOT / "SpaceWireCODECIP_100MHz" / "VHDL" / "*.vhdl")
spw.add_source_files(ROOT / "SpaceWireRouterIP_6PortVersion" / "VHDL" / "*.vhdl")

files = [
    "spwpkg.vhd",
    "spwlink.vhd",
    "spwram.vhd",
    "spwrecvfront_fast.vhd",
    "spwrecvfront_generic.vhd",
    "spwrecv.vhd",
    "spwstream.vhd",
    "spwxmit_fast.vhd",
    "spwxmit.vhd",
    "streamtest.vhd",
    "syncdff.vhd"]
for f in files:
    spw.add_source_files(ROOT / "spacewire_light" / "trunk" / "rtl" / "vhdl" / f)
spw.add_source_files(ROOT / "testbench" / "rmap_crc.vhd")
spw.add_source_files(ROOT / "testbench" / "rmap_pkg.vhd")
spw.add_source_files(ROOT / "testbench" / "spw_actor_pkg.vhd")
spw.add_source_files(ROOT / "testbench" / "spw_actor.vhd")
spw.add_source_files(ROOT / "testbench" / "tb_spw_actor.vhd")
spw.add_source_files(ROOT / "testbench" / "tb_router.vhd")

VU.add_compile_option("ghdl.a_flags", ["-ggdb", "-O0"])
VU.set_sim_option("modelsim.vsim_flags.gui", ["-voptargs=+acc"])
VU.set_sim_option("ghdl.elab_flags", ["-ggdb", "-O0"])
VU.set_sim_option("ghdl.sim_flags", ["--assert-level=warning", "--backtrace-severity=note"])
VU.main()

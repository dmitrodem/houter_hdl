#!/usr/bin/env python3

import sys
from pathlib import Path

sys.path.append((Path(__file__).parent / "submodules" / "vunit").as_posix())

from vunit import VUnit

ROOT = Path(__file__).parent / "src"

VU = VUnit.from_argv(compile_builtins = False)
VU.add_vhdl_builtins()
spw = VU.add_library("spw")
spw.add_source_files(ROOT / "SpaceWireCODECIP_100MHz" / "VHDL" / "*.vhdl")
spw.add_source_files(ROOT / "SpaceWireRouterIP_6PortVersion" / "VHDL" / "*.vhdl")

VU.main()

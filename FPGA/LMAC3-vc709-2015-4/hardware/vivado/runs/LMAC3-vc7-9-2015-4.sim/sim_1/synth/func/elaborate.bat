@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 473c1d551ac642859131150f7cf23711 -m64 --debug typical --relax --mt 2 -d "USE_PIPE_SIM=1" -d "SIMULATION=1" -d "USE_DDR3_FIFO=1" -d "USE_XPHY=1" -d "NW_PATH_ENABLE=1" -d "x4Gb=1" -d "sg107E=1" -d "x8=1" -L xil_defaultlib -L unisims_ver -L secureip --snapshot board_func_synth xil_defaultlib.board xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

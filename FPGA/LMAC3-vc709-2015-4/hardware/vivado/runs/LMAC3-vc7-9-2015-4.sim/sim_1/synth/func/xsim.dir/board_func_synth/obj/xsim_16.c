/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#define CC_CLANG

#include "iki.h"
#ifdef __GNUC__
#include <stdlib.h>
#else
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#define CC_CLANG

#include "iki.h"
#ifdef __GNUC__
#include <stdlib.h>
#else
#define alloca _alloca
#endif
void relocate(char *dp) _asm("_relocate");

void relocate(char *dp)
{
	_iki_relocate(dp, "xsim.dir/board_func_synth/xsim.reloc", "xsim.dir/board_func_synth/xsimk.exe", (void*)relocate);

	/*Populate the transaction function pointer field in the whole net structure */
}
void sensitize(char *dp) _asm("_sensitize");


void sensitize(char *dp)
{
	_iki_sensitize(dp, "xsim.dir/board_func_synth/xsim.reloc");
}
void simulate(char *dp) _asm("_simulate");


void simulate(char *dp)
{
	_iki_schedule_processes_at_time_zero(dp, "xsim.dir/board_func_synth/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	_iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#define CC_CLANG
#include "iki_bridge.h"
void relocate(char *) _asm("_relocate");

void sensitize(char *) _asm("_sensitize");
void simulate(char *) _asm("_simulate");

int _main(int argc, char **argv)
{
    void* design_handle = _iki_create_design("xsim.dir/board_func_synth/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, _isimBridge_getWdbWriter(), 0, argc, argv);
     _iki_set_sv_type_file_path_name("xsim.dir/board_func_synth/xsim.svtype");
_iki_heap_initialize("ms", "isimmm", 0, 10485760) ;
    (void* ) design_handle;
    return _iki_simulate_design();
}

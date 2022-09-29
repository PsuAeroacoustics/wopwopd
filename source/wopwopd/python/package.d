module wopwopd.python;

import wopwopd.python.execute;
import wopwopd.python.geometry;
import wopwopd.python.loading;
import wopwopd.python.namelist;
import wopwopd.python.output;

import pyd.pyd;

extern(C) void PydMain() {
	python_execute_function_wraps;
    python_namelist_function_wraps;
    python_geometry_function_wraps;
	python_loading_function_wraps;
	python_output_function_wraps;

	module_init;

    python_namelist_class_wraps;
    python_geometry_class_wraps;
	python_loading_class_wraps;
	python_output_class_wraps;
}

// Boilerplate take from Pyd so I don't have to use distutils to build

import pyd.def;
import pyd.exception;
import pyd.thread;

//extern(C) void PydMain();

version(Python_3_0_Or_Later) {
    import deimos.python.Python;
    extern(C) export PyObject* PyInit_libwopwopd() {
        return pyd.exception.exception_catcher(delegate PyObject*() {
                pyd.thread.ensureAttached();
                pyd.def.pyd_module_name = "wopwopd";
                PydMain();
                return pyd.def.pyd_modules[""];
                });
    }
}else version(Python_2_4_Or_Later) {
    extern(C) export void initlibwopwopd() {
        pyd.exception.exception_catcher(delegate void() {
                pyd.thread.ensureAttached();
                pyd.def.pyd_module_name = "wopwopd";
                PydMain();
                });
    }
}else static assert(false);

extern(C) void _Dmain(){
    // make druntime happy
}

version(Windows) {
	import core.sys.windows.windows;
	import core.sys.windows.dll;

	__gshared HINSTANCE g_hInst;


	extern (Windows)
	BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
	{
		switch (ulReason)
		{
			case DLL_PROCESS_ATTACH:
				g_hInst = hInstance;
				dll_process_attach( hInstance, true );
				break;

			case DLL_PROCESS_DETACH:
				dll_process_detach( hInstance, true );
				break;

			case DLL_THREAD_ATTACH:
				dll_thread_attach( true, true );
				break;

			case DLL_THREAD_DETACH:
				dll_thread_detach( true, true );
				break;

		default:
			assert(0);
		}

		return true;
	}
} else {
	// This file requires the .so be compiled with '-nostartfiles'.
	// Also note that this is inferior to the Windows version: it does not call the
	// static constructors or unit tests. As far as I can tell, this can't be done
	// until Phobos is updated to explicitly allow it.
	extern(C) shared bool _D2rt6dmain212_d_isHaltingOb;
	alias _D2rt6dmain212_d_isHaltingOb _d_isHalting;
	extern(C) {

		void rt_init();
		void rt_term();

		version(LDC) {
			pragma(LDC_global_crt_ctor)
				void hacky_init() {
					rt_init();
				}

			pragma(LDC_global_crt_dtor)
				void hacky_fini() {
					if(!_d_isHalting){
						rt_term();
					}
				}
		}else{
			void hacky_init() {
				rt_init();
			}

			void hacky_fini() {
				if(!_d_isHalting){
					rt_term();
				}
			}
		}

	} /* extern(C) */
}

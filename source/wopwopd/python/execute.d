module wopwopd.python.execute;

static import wopwopd.execute;
static import wopwopd.namelist;
import wopwopd.python.namelist;

import pyd.pyd;

auto wopwop3(CaseList case_list, string work_dir = "./", size_t cores = 1) {
	return wopwopd.execute.wopwop3(case_list.internal, work_dir, cores);
}

void python_execute_function_wraps() {
	def!(wopwop3);
}

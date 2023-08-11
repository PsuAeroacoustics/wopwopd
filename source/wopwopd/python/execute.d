module wopwopd.python.execute;

static import wopwopd.execute;
static import wopwopd.namelist;
import wopwopd.python.namelist;

import pyd.pyd;

auto wopwop3(CaseList case_list, string work_dir = "./", size_t cores = 1) {
	return wopwopd.execute.wopwop3(case_list.internal, work_dir, cores);
}

auto exec_wopwop3(CaseList case_list, string work_dir = "./", size_t cores = 1, string caselist_prefix = "cases") {
	return wopwopd.execute.exec_wopwop3(case_list.internal, work_dir, cores, caselist_prefix);
}

void python_execute_function_wraps() {
	def!(wopwop3);
	def!(exec_wopwop3);
}

module wopwopd.execute;

import wopwopd.namelist;
import wopwopd.output;

import std.conv;
import std.path;
import std.process;
import std.stdio;
import std.range;

auto wopwop3(ref CaseList caselist, string work_dir = "./", size_t cores = 1) {

	foreach(ref _case; caselist.cases) {
		write_namelist(_case.namelist, work_dir~'/'~_case.globalFolderName.get()~_case.caseNameFile.get());
	}

	//write_caselist(caselist, work_dir);

	foreach(ref cases; chunks(caselist.cases, 4)) {
		auto sub_caselist = CaseList();
		sub_caselist.cases = cases;
		write_caselist(sub_caselist, work_dir);

		Pid pid;
		if(cores > 1) {
			pid = spawnProcess(["mpirun", "-n", cores.to!string, "wopwop3"], stdin, stdout, stderr, null, Config.none, work_dir);
		} else {
			pid = spawnProcess("wopwop3", stdin, stdout, stderr, null, Config.none, work_dir);
		}

		wait(pid);
	}

	auto results = new WopwopResult[caselist.cases.length];

	foreach(idx, ref _case; caselist.cases) {

		auto case_dir = work_dir.buildPath(_case.globalFolderName.isNull ? "" : _case.globalFolderName.get);
		results[idx] = parse_wopwop_results(case_dir, _case.namelist);
	}
	return results;
}

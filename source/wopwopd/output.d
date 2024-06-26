module wopwopd.output;

import wopwopd;
import wopwopd.namelist;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.file;
import std.getopt;
import std.path;
import std.range;
import std.stdio;
import std.string;

struct Function {
	float[] data;
}

struct Observer {
	float[] independent_axis;
    string[] function_names;
	Function[] functions;
}

struct Grid {
	float[][] obs_x;
    float[][] obs_y;
    float[][] obs_z;
}

struct WopwopResult {
    Observer[] observer_pressures;
    Observer[] observer_spectrum;
	Observer[] oaspl_db;
	Observer[] oaspl_dba;
	Observer[][] frequency_ranges_db;
	Observer[][] frequency_ranges_dba;
	Grid oaspl_db_grid;
	Grid oaspl_dba_grid;
}

auto read_plot3d_grid(string filename) {
	int[] header_buffer = new int[3];

	auto data_file = File(filename, "rb");
	scope(exit) data_file.close;

	Grid grid;

	header_buffer = data_file.rawRead(header_buffer);

	int i_max = header_buffer[0];
	int j_max = header_buffer[1];

	grid.obs_x = new float[][](j_max, i_max);
	grid.obs_y = new float[][](j_max, i_max);
	grid.obs_z = new float[][](j_max, i_max);

	foreach(j; 0..j_max) {
		data_file.rawRead(grid.obs_x[j]);
	}
	foreach(j; 0..j_max) {
		data_file.rawRead(grid.obs_y[j]);
	}
	foreach(j; 0..j_max) {
		data_file.rawRead(grid.obs_z[j]);
	}

	return grid;
}

auto read_plot3d_binary(string filename) {
	int[] header_buffer = new int[4];

	auto data_file = File(filename, "rb");
	scope(exit) data_file.close;

	Observer[] observers;

	header_buffer = data_file.rawRead(header_buffer);

	int i_max = header_buffer[0];
	int j_max = header_buffer[1];
	int samples = header_buffer[2];
	int functions = header_buffer[3];

	size_t total_obs = i_max*j_max;

	observers = new Observer[total_obs];

	foreach(ref observer; observers) {
		observer.independent_axis = new float[samples];
		observer.functions = new Function[functions - 1];
		foreach(ref func; observer.functions) {
			func.data = new float[samples];
		}
	}

	float[] sample_buff = new float[1];

	foreach(s_idx; 0..samples) {
		foreach(ref observer; observers) {
			sample_buff = data_file.rawRead(sample_buff);
			observer.independent_axis[s_idx] = sample_buff[0];
		}
	}

	foreach(f_idx; 0..(functions - 1)) {
		foreach(s_idx; 0..samples) {
			foreach(ref observer; observers) {
				sample_buff = data_file.rawRead(sample_buff);
				observer.functions[f_idx].data[s_idx] = sample_buff[0];
			}
		}
	}

	return observers;
}

auto parse_wopwop_results(string wopwop_directory, ref Namelist namelist) {

    // If ASCIIOutputFlag is null, then wopwop defaults it to false
    enforce(namelist.environment_in.ASCIIOutputFlag.isNull || !namelist.environment_in.ASCIIOutputFlag.get, "Ascii file reading not yet supported");

    auto result = WopwopResult();

	if(!namelist.environment_in.acousticPressureFlag.isNull && namelist.environment_in.acousticPressureFlag.get) {
		string prefix = namelist.environment_in.pressureFolderName.isNull ? "" : namelist.environment_in.pressureFolderName.get;
		auto pressure_filename = wopwop_directory.buildPath(prefix, "pressure.fn");
    	result.observer_pressures = read_plot3d_binary(pressure_filename);
	}

	if(!namelist.environment_in.spectrumFlag.isNull && namelist.environment_in.spectrumFlag.get) {
		string prefix = namelist.environment_in.SPLFolderName.isNull ? "" : namelist.environment_in.SPLFolderName.get;
 		auto spectrum_filename = wopwop_directory.buildPath(prefix~"spl_spectrum.fn");
    	result.observer_spectrum = read_plot3d_binary(spectrum_filename);
	}

	if(!namelist.environment_in.OASPLdBFlag.isNull && namelist.environment_in.OASPLdBFlag.get) {
		import std.file : copy;

		auto oaspldb_filename = wopwop_directory.buildPath("OASPLdB.fn");
		auto oaspldbx_filename = wopwop_directory.buildPath("OASPL.x");
		auto oaspldbxyz_filename = wopwop_directory.buildPath("OASPL.xyz");

		copy(oaspldbx_filename, oaspldbxyz_filename);

		result.oaspl_db = read_plot3d_binary(oaspldb_filename);
		result.oaspl_db_grid = read_plot3d_grid(oaspldbxyz_filename);
	}
	
	if(!namelist.environment_in.OASPLdBAFlag.isNull && namelist.environment_in.OASPLdBAFlag.get) {
		import std.file : copy;
		
		auto oaspldba_filename = wopwop_directory.buildPath("OASPLdBA.fn");
		auto oaspldbax_filename = wopwop_directory.buildPath("OASPL.x");
		auto oaspldbaxyz_filename = wopwop_directory.buildPath("OASPL.xyz");

		copy(oaspldbax_filename, oaspldbaxyz_filename);

		result.oaspl_dba = read_plot3d_binary(oaspldba_filename);
		result.oaspl_dba_grid = read_plot3d_grid(oaspldbaxyz_filename);
	}

	if(namelist.observers[0].ranges.length > 0) {
		foreach(ref range; namelist.observers[0].ranges) {
			import std.file : copy;

			auto oaspldbax_filename = wopwop_directory.buildPath("segmentProcess", "freqRanges.x");
			auto oaspldbaxyz_filename = wopwop_directory.buildPath("segmentProcess", "freqRanges.xyz");

			copy(oaspldbax_filename, oaspldbaxyz_filename);

			if(!namelist.environment_in.OASPLdBAFlag.isNull && namelist.environment_in.OASPLdBAFlag.get) {
				auto oaspldba_filename = wopwop_directory.buildPath("segmentProcess", range.Title.get()~"_dBA.fn");
				result.frequency_ranges_dba ~= read_plot3d_binary(oaspldba_filename);
				result.oaspl_dba_grid = read_plot3d_grid(oaspldbaxyz_filename);
			}

			if(!namelist.environment_in.OASPLdBFlag.isNull && namelist.environment_in.OASPLdBFlag.get) {
				auto oaspldb_filename = wopwop_directory.buildPath("segmentProcess", range.Title.get()~"_dB.fn");
				result.frequency_ranges_db ~= read_plot3d_binary(oaspldb_filename);
				result.oaspl_db_grid = read_plot3d_grid(oaspldbaxyz_filename);
			}
		}
	}

    return result;
}

auto parse_wopwop_results(string wopwop_directory, string namelist_filename) {

    auto namelist = parse_namelist(wopwop_directory.buildPath(namelist_filename));
    
    auto result = parse_wopwop_results(wopwop_directory, namelist);

    return result;
}

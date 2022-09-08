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

struct WopwopResult {
    Observer[] observer_pressures;
    Observer[][] observer_spectrum;
    float[] obs_x;
    float[] obs_y;
    float[] obs_z;
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

    auto pressure_filename = wopwop_directory.buildPath("pressure", "pressure.fn");
    auto spectrum_filename = wopwop_directory.buildPath("splspl_spectrum.fn");

    auto result = WopwopResult();

    result.observer_pressures = read_plot3d_binary(pressure_filename);
    result.observer_spectrum = read_plot3d_binary(spectrum_filename);

    return result;
}

auto parse_wopwop_results(string wopwop_directory, string namelist_filename) {

    auto namelist = parse_namelist(wopwop_directory.buildPath(namelist_filename));
    
    auto result = parse_wopwop_results(wopwop_directory, namelist);

    return result;
}

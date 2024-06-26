module wopwopd.python.output;

static import wopwopd.output;
import wopwopd.python.namelist;

import pyd.pyd;

import std.algorithm;
import std.array;
import std.conv;
import std.meta;
import std.string;
import std.traits;

auto parse_wopwop_results_namelist(string wopwop_directory, Namelist namelist) {
    return wopwopd.output.parse_wopwop_results(wopwop_directory, namelist.internal);
}


void python_output_function_wraps() {
    def!(parse_wopwop_results_namelist);
    def!(wopwopd.output.parse_wopwop_results, wopwopd.output.WopwopResult function(string, string));
}

void python_output_class_wraps() {
    wrap_struct!(
        wopwopd.output.WopwopResult,
        Member!("observer_pressures"),
        Member!("observer_spectrum"),
        Member!("oaspl_db"),
        Member!("oaspl_dba"),
        Member!("oaspl_db_grid"),
        Member!("oaspl_dba_grid"),
        Member!("frequency_ranges_db"),
        Member!("frequency_ranges_dba")
    );

    wrap_struct!(
        wopwopd.output.Observer,
        Member!("independent_axis"),
        Member!("function_names"),
        Member!("functions")
    );

    wrap_struct!(
        wopwopd.output.Grid,
        Member!("obs_x"),
        Member!("obs_y"),
        Member!("obs_z")
    );

    wrap_struct!(
        wopwopd.output.Function,
        Member!("data")
    );
}

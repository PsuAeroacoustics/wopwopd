module wopwopd.python.namelist;

static import wopwopd.namelist;

import pyd.pyd;

import std.algorithm;
import std.array;
import std.conv;
import std.meta;
import std.string;
import std.traits;

template NamelistWrap(S) {
	static string build_wrapped_props() {
		immutable string varname = "internal";
		string props = "wopwopd.namelist."~S.stringof~" "~varname~";\n\n";
		static foreach(m_idx, member; FieldNameTuple!S) {{
			static if(__traits(getVisibility, mixin("wopwopd.namelist."~S.stringof~"."~member)) == "public") {

				mixin("alias M = typeof(wopwopd.namelist."~S.stringof~"."~member~");");
				static if(is(M == wopwopd.namelist.OptionalString)) {
					props ~= "@property string "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn "~varname~"."~member~".get;\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(string p) {\n";
					props ~= "\t"~varname~"."~member~" = p;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalFloat)) {
					props ~= "@property float "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn "~varname~"."~member~".get;\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(float p) {\n";
					props ~= "\t"~varname~"."~member~" = p;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalFloatArray)) {
					props ~= "@property float[] "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn "~varname~"."~member~".get;\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(float[] p) {\n";
					props ~= "\t"~varname~"."~member~" = p;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalSize)) {
					props ~= "@property size_t "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn "~varname~"."~member~".get;\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(size_t p) {\n";
					props ~= "\t"~varname~"."~member~" = p;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalBool)) {
					props ~= "@property bool "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn "~varname~"."~member~".get;\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(bool p) {\n";
					props ~= "\t"~varname~"."~member~" = p;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalVec)) {
					props ~= "@property wopwopd.namelist.FVec3 "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn "~varname~"."~member~".get;\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.namelist.FVec3 p) {\n";
					props ~= "\t"~varname~"."~member~" = p;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalBPMIn)) {
					props ~= "@property wopwopd.python.BPMIn "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn new BPMIn("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.BPMIn p) {\n";
					props ~= "\t"~varname~"."~member~" = p.internal;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalBWIIn)) {
					props ~= "@property wopwopd.python.BWIIn "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn new BWIIn("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.BWIIn p) {\n";
					props ~= "\t"~varname~"."~member~" = p.internal;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalWindowFunction)) {
					props ~= "@property WindowFunction "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn WindowFunction("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(WindowFunction p) {\n";
					props ~= "\t"~varname~"."~member~" = p.wf;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalAverageSide)) {
					props ~= "@property AverageSide "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn AverageSide("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(AverageSide p) {\n";
					props ~= "\t"~varname~"."~member~" = p.as;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalAxisType)) {
					props ~= "@property wopwopd.python.AxisType "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn wopwopd.python.AxisType("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.AxisType p) {\n";
					props ~= "\t"~varname~"."~member~" = p.at;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalTranslationType)) {
					props ~= "@property wopwopd.python.TranslationType "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn wopwopd.python.TranslationType("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.TranslationType p) {\n";
					props ~= "\t"~varname~"."~member~" = p.tt;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalAngleType)) {
					props ~= "@property wopwopd.python.AngleType "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn wopwopd.python.AngleType("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.AngleType p) {\n";
					props ~= "\t"~varname~"."~member~" = p.at;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalTripType)) {
					props ~= "@property wopwopd.python.TripType "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn wopwopd.python.TripType("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.TripType p) {\n";
					props ~= "\t"~varname~"."~member~" = p.tt;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalUniformType)) {
					props ~= "@property wopwopd.python.UniformType "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn wopwopd.python.UniformType("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.UniformType p) {\n";
					props ~= "\t"~varname~"."~member~" = p.ut;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.OptionalBPMFlagType)) {
					props ~= "@property wopwopd.python.BPMFlagType "~member~"() {\n";
					props ~= "\tif(!"~varname~"."~member~".isNull) {\n";
					props ~= "\t\treturn wopwopd.python.BPMFlagType("~varname~"."~member~".get);\n";
					props ~= "\t} else {\n";
					props ~= "\t\tthrow new Exception(\""~member~" has not been set and is null\");\n";
					props~= "\t}\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.BPMFlagType p) {\n";
					props ~= "\t"~varname~"."~member~" = p.ft;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.CB[])) {
					props ~= "@property wopwopd.python.CB[] "~member~"() {\n";
					props ~= "\treturn "~varname~"."~member~".map!(a => new wopwopd.python.CB(a)).array;\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.CB[] p) {\n";
					props ~= "\t"~varname~"."~member~" = p.map!(a => a.internal).array;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.RangeIn[])) {
					props ~= "@property wopwopd.python.RangeIn[] "~member~"() {\n";
					props ~= "\treturn "~varname~"."~member~".map!(a => new wopwopd.python.RangeIn(a)).array;\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.RangeIn[] p) {\n";
					props ~= "\t"~varname~"."~member~" = p.map!(a => a.internal).array;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.ContainerIn[])) {
					props ~= "@property wopwopd.python.ContainerIn[] "~member~"() {\n";
					props ~= "\treturn "~varname~"."~member~".map!(a => new wopwopd.python.ContainerIn(a)).array;\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.ContainerIn[] p) {\n";
					props ~= "\t"~varname~"."~member~" = p.map!(a => a.internal).array;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.ObserverIn[])) {
					props ~= "@property wopwopd.python.ObserverIn[] "~member~"() {\n";
					props ~= "\treturn "~varname~"."~member~".map!(a => new wopwopd.python.ObserverIn(a)).array;\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.ObserverIn[] p) {\n";
					props ~= "\t"~varname~"."~member~" = p.map!(a => a.internal).array;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.EnvironmentIn)) {
					props ~= "@property wopwopd.python.EnvironmentIn "~member~"() {\n";
					props ~= "\treturn new EnvironmentIn("~varname~"."~member~");\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.EnvironmentIn p) {\n";
					props ~= "\t"~varname~"."~member~" = p.internal;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.EnvironmentConstants)) {
					props ~= "@property wopwopd.python.EnvironmentConstants "~member~"() {\n";
					props ~= "\treturn new EnvironmentConstants("~varname~"."~member~");\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.EnvironmentConstants p) {\n";
					props ~= "\t"~varname~"."~member~" = p.internal;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.Namelist)) {
					props ~= "@property wopwopd.python.Namelist "~member~"() {\n";
					props ~= "\treturn new Namelist("~varname~"."~member~");\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.Namelist p) {\n";
					props ~= "\t"~varname~"."~member~" = p.internal;\n";
					props ~= "}\n";
				} else static if(is(M == wopwopd.namelist.Casename[])) {
					props ~= "@property wopwopd.python.Casename[] "~member~"() {\n";
					props ~= "\treturn "~varname~"."~member~".map!(a => new wopwopd.python.Casename(a)).array;\n";
					props ~= "}\n\n";

					props ~= "@property void "~member~"(wopwopd.python.Casename[] p) {\n";
					props ~= "\t"~varname~"."~member~" = p.map!(a => a.internal).array;\n";
					props ~= "}\n";
				}
			}
		}}

		return props;
	}

	mixin(build_wrapped_props());
}

class CaseList {
	mixin NamelistWrap!(wopwopd.namelist.CaseList);

	this() {

	}

	this(ref wopwopd.namelist.CaseList cl) {
		internal = cl;
	}
}

class Casename {
	mixin NamelistWrap!(wopwopd.namelist.Casename);

	this() {

	}

	this(ref wopwopd.namelist.Casename cn) {
		internal = cn;
	}
}

class Namelist {
	mixin NamelistWrap!(wopwopd.namelist.Namelist);

	this() {

	}

	this(ref wopwopd.namelist.Namelist nl) {
		internal = nl;
	}

}

class RangeIn {
	mixin NamelistWrap!(wopwopd.namelist.RangeIn);

	this() {

	}

	this(ref wopwopd.namelist.RangeIn ri) {
		internal = ri;
	}
}

class EnvironmentIn {
	mixin NamelistWrap!(wopwopd.namelist.EnvironmentIn); 

	this() {

	}

	this(ref wopwopd.namelist.EnvironmentIn ei) {
		internal = ei;
	}
}

class EnvironmentConstants {
	mixin NamelistWrap!(wopwopd.namelist.EnvironmentConstants);

	this() {

	}

	this(ref wopwopd.namelist.EnvironmentConstants ec) {
		internal = ec;
	}
}

class ObserverIn {
	mixin NamelistWrap!(wopwopd.namelist.ObserverIn);

	this() {

	}

	this(ref wopwopd.namelist.ObserverIn oi) {
		internal = oi;
	}
}

class ContainerIn {
	mixin NamelistWrap!(wopwopd.namelist.ContainerIn);

	this() {

	}

	this(ref wopwopd.namelist.ContainerIn ci) {
		internal = ci;
	}
}

class CB {
	mixin NamelistWrap!(wopwopd.namelist.CB);

	this() {

	}

	this(ref wopwopd.namelist.CB cb) {
		internal = cb;
	}
}

class BPMIn {
	mixin NamelistWrap!(wopwopd.namelist.BPMIn);

	this() {

	}

	this(ref wopwopd.namelist.BPMIn bpm_in) {
		internal = bpm_in;
	}
}

class BWIIn {
	mixin NamelistWrap!(wopwopd.namelist.BWIIn);

	this() {

	}

	this(ref wopwopd.namelist.BWIIn bwi_in) {
		internal = bwi_in;
	}
}

struct TripType {
	private wopwopd.namelist.TripType tt;

	string toString() {
		return tt.to!string;
	}
}

TripType TripType_no_trip() {
	return TripType(wopwopd.namelist.TripType.no_trip);
}

TripType TripType_soft_trip() {
	return TripType(wopwopd.namelist.TripType.soft_trip);
}

TripType TripType_hard_trip() {
	return TripType(wopwopd.namelist.TripType.hard_trip);
}

struct UniformType {
	private wopwopd.namelist.UniformType ut;

	string toString() {
		return ut.to!string;
	}
}

UniformType UniformType_nonuniform() {
	return UniformType(wopwopd.namelist.UniformType.nonuniform);
}

UniformType UniformType_uniform() {
	return UniformType(wopwopd.namelist.UniformType.uniform);
}

struct BPMFlagType {
	private wopwopd.namelist.BPMFlagType ft;

	string toString() {
		return ft;
	}
}

BPMFlagType BPMFlagType_compute() {
	return BPMFlagType(wopwopd.namelist.BPMFlagType.compute);
}

BPMFlagType BPMFlagType_user_value() {
	return BPMFlagType(wopwopd.namelist.BPMFlagType.user_value);
}

BPMFlagType BPMFlagType_file_value() {
	return BPMFlagType(wopwopd.namelist.BPMFlagType.file_value);
}

struct WindowFunction {
	private wopwopd.namelist.WindowFunction wf;

	string toString() {
		return wf;
	}
}

WindowFunction WindowFunction_hanning_window() {
	return WindowFunction(wopwopd.namelist.WindowFunction.hanning_window);
}

WindowFunction WindowFunction_blackman_window() {
	return WindowFunction(wopwopd.namelist.WindowFunction.blackman_window);
}

WindowFunction WindowFunction_flatTop_window() {
	return WindowFunction(wopwopd.namelist.WindowFunction.flatTop_window);
}

WindowFunction WindowFunction_hamming_window() {
	return WindowFunction(wopwopd.namelist.WindowFunction.hamming_window);
}

struct AverageSide {
	private wopwopd.namelist.AverageSide as;

	string toString() {
		return as;
	}
}

AverageSide AverageSide_center() {
	return AverageSide(wopwopd.namelist.AverageSide.center);
}

struct AxisType {
	wopwopd.namelist.AxisType at;

	string toString() {
		return at;
	}
}

AxisType AxisType_time_independant() {
	return AxisType(wopwopd.namelist.AxisType.time_independent);
}

AxisType AxisType_non_periodic() {
	return AxisType(wopwopd.namelist.AxisType.non_periodic);
}

struct TranslationType {
	wopwopd.namelist.TranslationType tt;

	string toString() {
		return tt;
	}
}

TranslationType TranslationType_time_independant() {
	return TranslationType(wopwopd.namelist.TranslationType.time_independent);
}

TranslationType TranslationType_known_function() {
	return TranslationType(wopwopd.namelist.TranslationType.known_function);
}

TranslationType TranslationType_non_periodic() {
	return TranslationType(wopwopd.namelist.TranslationType.non_periodic);
}

struct AngleType {
	wopwopd.namelist.AngleType at;

	string toString() {
		return at;
	}
}

AngleType AngleType_time_independant() {
	return AngleType(wopwopd.namelist.AngleType.time_independent);
}

AngleType AngleType_known_function() {
	return AngleType(wopwopd.namelist.AngleType.known_function);
}

AngleType AngleType_periodic() {
	return AngleType(wopwopd.namelist.AngleType.periodic);
}

AngleType AngleType_non_periodic() {
	return AngleType(wopwopd.namelist.AngleType.non_periodic);
}

string wrap_namelist_class(C)() {
	string w = "wrap_class!("~C.stringof~",\n";
    
	static foreach(m_idx, member; FieldNameTuple!(typeof(C.internal))) {{
		static if(__traits(getVisibility, mixin("wopwopd.namelist."~typeof(C.internal).stringof~"."~member)) == "public") {
			w ~= "\tMember!\""~member~"\",\n";
		}
	}}

	w ~= ");";
	return w;
}

void write_namelist(Namelist namelist, string filename) {
	wopwopd.namelist.write_namelist(namelist.internal, filename);
}

Namelist parse_namelist(string filename) {
	auto namelist = wopwopd.namelist.parse_namelist(filename);
	return new Namelist(namelist);
}

void write_caselist(CaseList case_list, string directory) {
	static import wopwopd.namelist;
	wopwopd.namelist.write_caselist(case_list.internal, directory);
}

void write_caselist_custom_name(ref CaseList case_list, string directory, string caselist_filename) {
	static import wopwopd.namelist;
	wopwopd.namelist.write_caselist_custom_name(case_list.internal, directory, caselist_filename);
}

void python_namelist_function_wraps() {
	def!(write_caselist);
	def!(write_caselist_custom_name);
    def!(write_namelist);
	def!(parse_namelist);

	def!TripType_no_trip;
	def!TripType_soft_trip;
	def!TripType_hard_trip;

	def!UniformType_nonuniform;
	def!UniformType_uniform;

	def!BPMFlagType_compute;
	def!BPMFlagType_file_value;
	def!BPMFlagType_user_value;

	def!WindowFunction_hanning_window;
	def!WindowFunction_blackman_window;
	def!WindowFunction_flatTop_window;
	def!WindowFunction_hamming_window;

	def!AverageSide_center;

	def!AxisType_time_independant;
	def!AxisType_non_periodic;

	def!TranslationType_time_independant;
	def!TranslationType_known_function;
	def!TranslationType_non_periodic;

	def!AngleType_time_independant;
	def!AngleType_known_function;
	def!AngleType_periodic;
	def!AngleType_non_periodic;
}

void python_namelist_class_wraps() {
    mixin(wrap_namelist_class!Namelist);
	mixin(wrap_namelist_class!RangeIn);
	mixin(wrap_namelist_class!EnvironmentIn);
	mixin(wrap_namelist_class!EnvironmentConstants);
	mixin(wrap_namelist_class!ObserverIn);
	mixin(wrap_namelist_class!ContainerIn);
	mixin(wrap_namelist_class!CB);
	mixin(wrap_namelist_class!Casename);
	mixin(wrap_namelist_class!CaseList);
	mixin(wrap_namelist_class!BPMIn);
	mixin(wrap_namelist_class!BWIIn);

	wrap_struct!(
		TripType,
		Repr!(TripType.toString)
	);

	wrap_struct!(
		UniformType,
		Repr!(UniformType.toString)
	);

	wrap_struct!(
		BPMFlagType,
		Repr!(BPMFlagType.toString)
	);

	wrap_struct!(
		WindowFunction,
		Repr!(WindowFunction.toString)
	);

	wrap_struct!(
		AxisType,
		Repr!(AxisType.toString)
	);

	wrap_struct!(
		TranslationType,
		Repr!(TranslationType.toString)
	);

	wrap_struct!(
		AngleType,
		Repr!(AngleType.toString)
	);

	wrap_struct!(
		AverageSide,
		Repr!(AverageSide.toString)
	);

   	wrap_struct!(
		wopwopd.namelist.FVec3,
		PyName!"FVec3",
		Init!(float[3]),
		Member!"mData",
		OpIndex!(staticMap!(FunctionTypeOf, __traits(getOverloads, wopwopd.namelist.FVec3, "opIndex"))[1]),
	);
}
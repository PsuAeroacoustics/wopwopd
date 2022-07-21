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
				}
			}
		}}

		return props;
	}

	mixin(build_wrapped_props());
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

void python_namelist_function_wraps() {
    def!(write_namelist);
	def!(parse_namelist);

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
module wopwopd;

version(Have_mpid) {
	import mpid;
} else {
	bool have_mpi() {
		return false;
	}
}

public import wopwopd.geometry;
public import wopwopd.loading;
public import wopwopd.namelist;

import numd.linearalgebra.matrix;

import std.conv;
import std.exception;
import std.traits;
import std.stdio : File;

enum wopwop;

alias FVec3 = Vector!(3, float);

enum int wopwop_magic_number = 42;

enum Structuring : int {
	structured = 1,
	unstructured = 2
}

enum TimeType : int {
	constant = 1,
	periodic = 2,
	aperiodic = 3,
	multiple_time_aperiodic = 4
}

enum FileType : int {
	patch = 1,
	loading = 2
}

enum DataAlignment : int {
	node_centered = 1,
	face_centered = 2
}

enum LoadingType : int {
	surface_pressure = 1,
	surface_loading = 2,
	flow = 3
}

enum ReferenceFrame : int {
	stationary_ground_fixed = 1,
	rotating_ground_fixed = 2,
	patch_fixed = 3
}

enum LoadingDatatype : int {
	single = 1
}

enum int COMMENT_STR_LEN = 1024;
enum int UNITS_STR_LEN = 32;

template to_string(alias m) {
	enum string to_string = m.stringof;
}

static if(have_mpi) @trusted void serial_write_struct(S)(MPI_File file, auto ref S s) {
	import std.meta : staticMap;
	template to_string(alias m) {
		enum string to_string = m.stringof;
	}

	static if(have_mpi) {
		alias field_types = Fields!S;

		MPI_Status status;
		int ret = MPI_SUCCESS;

		static foreach(m_idx, member; staticMap!(to_string, getSymbolsByUDA!(S, wopwop))) {
			static if(isStaticArray!(field_types[m_idx])) {
				mixin("ret = MPI_File_write(file, &s."~member~"[0], field_types[m_idx].length, to_mpi_type!(ForeachType!(field_types[m_idx])), &status);");
			} else static if(isDynamicArray!(field_types[m_idx])) {
				mixin("ret = MPI_File_write(file, s."~member~".ptr, s."~member~".length.to!int, to_mpi_type!(ForeachType!(field_types[m_idx])), &status);");
			} else {
				mixin("ret = MPI_File_write(file, &s."~member~", 1, to_mpi_type!(field_types[m_idx]), &status);");
			}
			enforce(ret == MPI_SUCCESS, "Failed to write "~member);
		}
	} else {
		assert(0, "Need MPI to run MPI_File_write");
	}
}

@trusted void serial_write_struct(S)(File file, auto ref S s) {
	import std.meta : staticMap;
	
	alias field_types = Fields!S;

	static foreach(m_idx, member; staticMap!(to_string, getSymbolsByUDA!(S, wopwop))) {{
		import std.stdio : writeln;
		//writeln("writing member: ", member);
		mixin("auto v = s."~member~";");
		static if(isArray!(field_types[m_idx])) {
			file.rawWrite(v);
		} else {
			file.rawWrite([v]);
			writeln("v:", [v]);
		}
		
	}}
}

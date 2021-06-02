module wopwopd.geometry;

import mpid;
import mpid : Group, include, group;

import numd.linearalgebra.matrix;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;
import std.traits;

import wopwopd;

struct GeometryFileHeaderT(Structuring _structuring, TimeType _time_type) {
	@wopwop immutable int magic_number = wopwop_magic_number;
	@wopwop immutable int file_version_1 = 1;
	@wopwop immutable int file_version_2 = 0;
	@wopwop char[UNITS_STR_LEN] units;
	@wopwop char[COMMENT_STR_LEN] comment_str;
	@wopwop immutable FileType file_type = FileType.patch;
	@wopwop int number_of_zones;
	@wopwop immutable Structuring structuring = _structuring;
	@wopwop immutable TimeType time_type = _time_type;
	@wopwop DataAlignment data_alignment;
	@wopwop immutable LoadingDatatype data_type = LoadingDatatype.single;
	@wopwop int have_iblank = 0;
	@wopwop int reserved_2 = 0;

	this(string comment, string _units, int _number_of_zones, DataAlignment _data_alignment) {
		comment_str[] = '\0';
		units[] = '\0';
		auto comment_range = comment.length > comment_str.length ? comment_str.length : comment.length;
		comment_str[0..comment_range] = comment[0..comment_range];

		auto units_range = _units.length > units.length ? units.length : _units.length;
		units[0..units_range] = _units[0..units_range];

		number_of_zones = _number_of_zones;
		data_alignment = _data_alignment;
	}
}

struct GeometryFile(Structuring structuring, TimeType _time_type) {
	alias FileHeader = GeometryFileHeaderT!(structuring, _time_type);
	alias time_type = _time_type;
	
	FileHeader file_header;

	static if(structuring == Structuring.structured) {
		static if(time_type == TimeType.periodic) {
			static assert(false, "Periodic structured zone are not supported");
		} else static if(time_type == TimeType.aperiodic) {
			static assert(false, "Aperiodic structured zone are not supported");
		} else static if(time_type == TimeType.constant) {
			alias HeaderType = ConstantStructuredGeometryHeader;
		}
	} else {
		static if(time_type == TimeType.periodic) {
			alias HeaderType = PeriodicUnstructuredGeometryHeader;
		} else static if(time_type == TimeType.aperiodic) {
			alias HeaderType = AperiodicUnstructuredGeometryHeader;
		} else static if(time_type == TimeType.constant) {
			alias HeaderType = ConstantUnstructuredGeometryHeader;
		}
	}

	HeaderType[] zone_headers;

	this(string comment, string units, DataAlignment _data_alignment, HeaderType[] _zone_headers) {
		file_header = FileHeader(comment, units, _zone_headers.length.to!int, _data_alignment);
		zone_headers = _zone_headers;
	}
}

alias StructuredGeometryFile(TimeType time_type) = GeometryFile!(Structuring.structured, time_type);
alias UnstructuredGeometryFile(TimeType time_type) = GeometryFile!(Structuring.unstructured, time_type);

alias AperiodicUnstructuredGeometryFile = UnstructuredGeometryFile!(TimeType.aperiodic);
alias ConstantUnstructuredGeometryFile = UnstructuredGeometryFile!(TimeType.constant);

//alias AperiodicStructuredGeometryFile = StructuredGeometryFile!(TimeType.aperiodic);
alias ConstantStructuredGeometryFile = StructuredGeometryFile!(TimeType.constant);

struct ConstantStructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop int i_max;
	@wopwop int j_max;

	this(string _name, int _i_max, int _j_max) {
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		i_max = _i_max;
		j_max = _j_max;
	}
}

/+struct PeriodicStructuredGeometryHeader {
	char[32] name;
	float period;
	int timesteps;
	int number_of_nodes;
	int number_of_faces;
	int[] connectivity;

	this(string _name, float _period, int _timesteps, int _number_of_nodes, int _number_of_faces, int[] _connectivity) {
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		period = _period;
		timesteps = _timesteps;
		number_of_nodes = _number_of_nodes;
		number_of_faces = _number_of_faces;
		connectivity = new int[_connectivity.length];
		connectivity[] = _connectivity[];
	}
}

struct AperiodicStructuredGeometryHeader {
	char[32] name;
	int timesteps;
	int number_of_nodes;
	int number_of_faces;
	int[] connectivity;

	this(string _name, int _timesteps, int _number_of_nodes, int _number_of_faces, int[] _connectivity) {
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		timesteps = _timesteps;
		number_of_nodes = _number_of_nodes;
		number_of_faces = _number_of_faces;
		connectivity = new int[_connectivity.length];
		connectivity[] = _connectivity[];
	}
}+/

struct ConstantUnstructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop int number_of_nodes;
	@wopwop int number_of_faces;
	@wopwop int[] connectivity;

	this(string _name, int _number_of_nodes, int _number_of_faces, int[] _connectivity) {
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		number_of_nodes = _number_of_nodes;
		number_of_faces = _number_of_faces;
		connectivity = new int[_connectivity.length];
		connectivity[] = _connectivity[];
	}
}

struct PeriodicUnstructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop float period;
	@wopwop int timesteps;
	@wopwop int number_of_nodes;
	@wopwop int number_of_faces;
	@wopwop int[] connectivity;

	this(string _name, float _period, int _timesteps, int _number_of_nodes, int _number_of_faces, int[] _connectivity) {
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		period = _period;
		timesteps = _timesteps;
		number_of_nodes = _number_of_nodes;
		number_of_faces = _number_of_faces;
		connectivity = new int[_connectivity.length];
		connectivity[] = _connectivity[];
	}
}

struct AperiodicUnstructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop int timesteps;
	@wopwop int number_of_nodes;
	@wopwop int number_of_faces;
	@wopwop int[] connectivity;

	this(string _name, int _timesteps, int _number_of_nodes, int _number_of_faces, int[] _connectivity) {
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		timesteps = _timesteps;
		number_of_nodes = _number_of_nodes;
		number_of_faces = _number_of_faces;
		connectivity = new int[_connectivity.length];
		connectivity[] = _connectivity[];
	}
}

struct ConstantGeometryData {
	float[] x_nodes;
	float[] y_nodes;
	float[] z_nodes;

	float[] x_normals;
	float[] y_normals;
	float[] z_normals;

	this(size_t num_nodes) {
		x_nodes = new float[num_nodes];
		y_nodes = new float[num_nodes];
		z_nodes = new float[num_nodes];
		
		x_normals = new float[num_nodes];
		y_normals = new float[num_nodes];
		z_normals = new float[num_nodes];
	}
}

struct GeometryFileHandle {
	static if(have_mpi) {
		MPI_File file_handle;
		MPI_Info info;
		Datatype etype;
		Datatype[] node_filetype;
		Datatype[] normal_filetype;
		size_t[] x_node_displacement;
		size_t[] y_node_displacement;
		size_t[] z_node_displacement;
		size_t[] x_normal_displacement;
		size_t[] y_normal_displacement;
		size_t[] z_normal_displacement;
		size_t[] zone_data_size;
		size_t total_data_size;
		Group comm_group;
		Comm comm;
	} else {
		File file;
		// May need more things
	}
}

@trusted GeometryFileHandle create_geometry_file(GeomFileType)(auto ref GeomFileType patch_file, string filename, size_t[] rank_node_count, size_t[] rank_normal_count) {
	GeometryFileHandle file;

	// Fill in

	return file;
}

static if(have_mpi) @trusted GeometryFileHandle create_geometry_file(GeomFileType)(ref Comm comm, auto ref GeomFileType patch_file, string filename, size_t[] rank_node_count, size_t[] rank_normal_count) {
	GeometryFileHandle file;

	file.etype = to_mpi_type!float;

	// First we create a group and communicator for those ranks that actually have
	// loading data to save.
	size_t[] send_buff = new size_t[comm.size];
	size_t[] rcv_buff = new size_t[comm.size];

	file.zone_data_size = new size_t[rank_node_count.length];
	size_t[] total_normals = new size_t[rank_node_count.length];
	size_t[] total_nodes = new size_t[rank_node_count.length];

	foreach(zone, rnc; rank_node_count) {
		send_buff[] = rnc;
		comm.alltoall(send_buff, rcv_buff, 1);
		
		total_nodes[zone] = rcv_buff.sum*FVec3.sizeof;

		send_buff[] = rank_normal_count[zone];
		comm.alltoall(send_buff, rcv_buff, 1);

		total_normals[zone] = rcv_buff.sum*FVec3.sizeof;

		// multiply by 2 to account for both nodes and normals
		static if(GeomFileType.time_type == TimeType.constant) {
			file.zone_data_size[zone] = total_nodes[zone] + total_normals[zone];
		} else {
			file.zone_data_size[zone] = total_nodes[zone] + total_normals[zone] + float.sizeof;
		}
	}

	file.total_data_size = file.zone_data_size.sum;

	file.x_node_displacement = new size_t[rank_node_count.length];
	file.y_node_displacement = new size_t[rank_node_count.length];
	file.z_node_displacement = new size_t[rank_node_count.length];
	file.x_normal_displacement = new size_t[rank_node_count.length];
	file.y_normal_displacement = new size_t[rank_node_count.length];
	file.z_normal_displacement = new size_t[rank_node_count.length];
	
	int[] new_group_ranks = rcv_buff.enumerate.filter!(a => a[1] != 0).map!(a => a[0].to!int).array;

	file.comm_group = comm.group.include(new_group_ranks);

	file.comm = comm.create_group(file.comm_group, 55);

	if(file.comm_group.rank == MPI_UNDEFINED) {
		return file;
	}

	file.node_filetype = new Datatype[rank_node_count.length];
	file.normal_filetype = new Datatype[rank_node_count.length];

	foreach(zone, rnc; rank_node_count) {
		// Create the contiguous datatype for the loading array.
		auto ret = MPI_Type_contiguous(rnc.to!int, file.etype, &(file.node_filetype[zone]));
		enforce(ret == MPI_SUCCESS, "Failed to create contiguous MPI datatype");

		ret = file.node_filetype[zone].commit;
		enforce(ret == MPI_SUCCESS, "Failed to commit contiguous MPI datatype");


		ret = MPI_Type_contiguous(rank_normal_count[zone].to!int, file.etype, &(file.normal_filetype[zone]));
		enforce(ret == MPI_SUCCESS, "Failed to create contiguous MPI datatype");

		ret = file.normal_filetype[zone].commit;
		enforce(ret == MPI_SUCCESS, "Failed to commit contiguous MPI datatype");
	}

	auto ret = MPI_Info_create(&(file.info));
	enforce(ret == MPI_SUCCESS, "Failed to create MPI info object");

	ret = MPI_File_open(file.comm, filename.toStringz, MPI_MODE_CREATE | MPI_MODE_WRONLY, file.info, &file.file_handle);

	enforce(ret == MPI_SUCCESS, "Failed to open or create loading file");

	MPI_Offset offset = 0;
	// Only root rank writes header info.
	if(file.comm.rank == 0) {
		file.file_handle.serial_write_struct(patch_file.file_header);

		foreach(ref zone_header; patch_file.zone_headers) {
			file.file_handle.serial_write_struct(zone_header);
		}

		ret = MPI_File_get_position(file.file_handle, &offset);
	}

	file.comm.bcast(offset, 0);

	send_buff = new size_t[file.comm.size];
	rcv_buff = new size_t[file.comm.size];

	foreach(zone, rnc; rank_normal_count) {
		send_buff[] = rnc;
		file.comm.alltoall(send_buff, rcv_buff, 1);

		if(file.comm.rank == 0) {
			file.x_node_displacement[zone] = offset + file.zone_data_size[0..zone].sum;
		} else {
			static if(GeomFileType.time_type == TimeType.constant) {
				file.x_node_displacement[zone] = offset + rcv_buff[0..file.comm.rank].sum*float.sizeof + file.zone_data_size[0..zone].sum;
			} else {
				// add extra float offset for the timestamp
				file.x_node_displacement[zone] = offset + rcv_buff[0..file.comm.rank].sum*float.sizeof + float.sizeof + file.zone_data_size[0..zone].sum;
			}
		}

		file.y_node_displacement[zone] = file.x_node_displacement[zone] + total_nodes[zone]/3;
		file.z_node_displacement[zone] = file.y_node_displacement[zone] + total_nodes[zone]/3;

		file.x_normal_displacement[zone] = file.z_node_displacement[zone] + total_nodes[zone]/3;
		file.y_normal_displacement[zone] = file.x_normal_displacement[zone] + total_normals[zone]/3;
		file.z_normal_displacement[zone] = file.y_normal_displacement[zone] + total_normals[zone]/3;

		import std.stdio : writeln;
		//writeln("zone ", zone, " x_node_displacement: ", file.x_node_displacement[zone]);
		//writeln("zone ", zone, " y_node_displacement: ", file.y_node_displacement[zone]);
		//writeln("zone ", zone, " z_node_displacement: ", file.z_node_displacement[zone]);
		//writeln("zone ", zone, " x_normal_displacement: ", file.x_normal_displacement[zone]);
		//writeln("zone ", zone, " y_normal_displacement: ", file.y_normal_displacement[zone]);
		//writeln("zone ", zone, " z_normal_displacement: ", file.z_normal_displacement[zone]);
	}

	return file;
}

static if(have_mpi) @trusted private void append_geometry_data_mpi(GeometryData)(ref GeometryFileHandle patch_file, ref GeometryData patch_data, size_t zone = 0) {
	static if(is(GeometryData == ConstantGeometryData)) {

		if(patch_file.comm_group.rank == MPI_UNDEFINED) {
			return;
		}

		enforce(
			(patch_data.x_nodes.length == patch_data.y_nodes.length) &&
			(patch_data.x_nodes.length == patch_data.z_nodes.length)
		);

		enforce(
			(patch_data.x_normals.length == patch_data.y_normals.length) &&
			(patch_data.x_normals.length == patch_data.z_normals.length)
		);

		//enforce(patch_data.x_normals.length == patch_data.x_nodes.length);

		auto ret = MPI_File_set_view(patch_file.file_handle, patch_file.x_node_displacement[zone], patch_file.etype, patch_file.node_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.file_handle, patch_data.x_nodes.ptr, 1, patch_file.node_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.file_handle, patch_file.y_node_displacement[zone], patch_file.etype, patch_file.node_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.file_handle, patch_data.y_nodes.ptr, 1, patch_file.node_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.file_handle, patch_file.z_node_displacement[zone], patch_file.etype, patch_file.node_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.file_handle, patch_data.z_nodes.ptr, 1, patch_file.node_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");



		ret = MPI_File_set_view(patch_file.file_handle, patch_file.x_normal_displacement[zone], patch_file.etype, patch_file.normal_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.file_handle, patch_data.x_normals.ptr, 1, patch_file.normal_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.file_handle, patch_file.y_normal_displacement[zone], patch_file.etype, patch_file.normal_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.file_handle, patch_data.y_normals.ptr, 1, patch_file.normal_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.file_handle, patch_file.z_normal_displacement[zone], patch_file.etype, patch_file.normal_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.file_handle, patch_data.z_normals.ptr, 1, patch_file.normal_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

	} else {
		static assert("Cannot export non-constant patch data");
	}
}

@trusted private void append_geometry_data_serial(GeometryData)(ref GeometryFileHandle patch_file, ref GeometryData patch_data, size_t zone = 0) {
	static if(is(GeometryData == ConstantGeometryData)) {
		// Fill in.
	} else {
		static assert("Cannot export non-constant patch data");
	}
}

@trusted void append_geometry_data(GeometryData)(ref GeometryFileHandle patch_file, ref GeometryData patch_data, size_t zone = 0) {
	static if(have_mpi) {
		append_geometry_data_mpi(patch_file, patch_data, zone);
	} else {
		append_geometry_data_serial(patch_file, patch_data, zone);
	}
}

unittest {
	auto f = File("test_binary.bin", "wb");
	int[1] fourty_two = 42;

	f.rawWrite(fourty_two);
	f.close;
}

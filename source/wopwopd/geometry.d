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
	//static if(have_mpi) {
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
		bool is_serial;
	//} else {
		File file;
		// May need more things
	//}
}

@trusted GeometryFileHandle create_geometry_file(GeomFileType)(auto ref GeomFileType patch_file, string filename, size_t[] rank_node_count, size_t[] rank_normal_count) {
	GeometryFileHandle file;

	file.is_serial = true;
	file.file = File(filename, "wb");
	// Fill in


	file.file.serial_write_struct(patch_file.file_header);
	/++
		file.file_handle.serial_write_struct(patch_file.file_header);

		foreach(ref zone_header; patch_file.zone_headers) {
			file.file_handle.serial_write_struct(zone_header);
		}
	+/

	return file;
}

static if(have_mpi) @trusted GeometryFileHandle create_geometry_file(GeomFileType)(ref Comm comm, auto ref GeomFileType patch_file, string filename, size_t[] rank_node_count, size_t[] rank_normal_count) {
	GeometryFileHandle file;

	file.is_serial = false;
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
	if(patch_file.is_serial) {
		append_geometry_data_mpi(patch_file, patch_data, zone);
	} else {
		append_geometry_data_serial(patch_file, patch_data, zone);
	}
}

void close_geometry_file(ref GeometryFileHandle file) {
	if(file.is_serial) {
		if(file.comm_group.rank != MPI_UNDEFINED) {
			auto ret = MPI_File_close(&file.file_handle);
			enforce(ret == MPI_SUCCESS, "Failed to close wopwop loading file with error: "~ret.to!string);
		}
	} else {
		// Fill in.
	}
}

unittest {

	alias Vec3 = Vector!(3, double);

	immutable double R = 4.7324;
	immutable double AR = 17;

	/++
	 +	This is a cut section naca 0012 airfoil points. Used in blade geometry generation.
	 +/
	immutable double[2][] naca0012 = [
		[1.000000,  0.001260],
		[0.998459,  0.001476],
		[0.993844,  0.002120],
		[0.986185,  0.003182],
		[0.975528,  0.004642],
		[0.961940,  0.006478],
		[0.945503,  0.008658],
		[0.926320,  0.011149],
		[0.904508,  0.013914],
		[0.880203,  0.016914],
		[0.853553,  0.020107],
		[0.824724,  0.023452],
		[0.793893,  0.026905],
		[0.761249,  0.030423],
		[0.726995,  0.033962],
		[0.691342,  0.037476],
		[0.654508,  0.040917],
		[0.616723,  0.044237],
		[0.578217,  0.047383],
		[0.539230,  0.050302],
		[0.500000,  0.052940],
		[0.460770,  0.055241],
		[0.421783,  0.057148],
		[0.383277,  0.058609],
		[0.345492,  0.059575],
		[0.308658,  0.060000],
		[0.273005,  0.059848],
		[0.238751,  0.059092],
		[0.206107,  0.057714],
		[0.175276,  0.055709],
		[0.146447,  0.053083],
		[0.119797,  0.049854],
		[0.095492,  0.046049],
		[0.073680,  0.041705],
		[0.054497,  0.036867],
		[0.038060,  0.031580],
		[0.024472,  0.025893],
		[0.013815,  0.019854],
		[0.006156,  0.013503],
		[0.001541,  0.006877],
		[0.000000,  0.000000],
		[0.001541, -0.006877],
		[0.006156, -0.013503],
		[0.013815, -0.019854],
		[0.024472, -0.025893],
		[0.038060, -0.031580],
		[0.054497, -0.036867],
		[0.073680, -0.041705],
		[0.095492, -0.046049],
		[0.119797, -0.049854],
		[0.146447, -0.053083],
		[0.175276, -0.055709],
		[0.206107, -0.057714],
		[0.238751, -0.059092],
		[0.273005, -0.059848],
		[0.308658, -0.060000],
		[0.345492, -0.059575],
		[0.383277, -0.058609],
		[0.421783, -0.057148],
		[0.460770, -0.055241],
		[0.500000, -0.052940],
		[0.539230, -0.050302],
		[0.578217, -0.047383],
		[0.616723, -0.044237],
		[0.654508, -0.040917],
		[0.691342, -0.037476],
		[0.726995, -0.033962],
		[0.761249, -0.030423],
		[0.793893, -0.026905],
		[0.824724, -0.023452],
		[0.853553, -0.020107],
		[0.880203, -0.016914],
		[0.904508, -0.013914],
		[0.926320, -0.011149],
		[0.945503, -0.008658],
		[0.961940, -0.006478],
		[0.975528, -0.004642],
		[0.986185, -0.003182],
		[0.993844, -0.002120],
		[0.998459, -0.001476],
		[1.000000, -0.001260]
	];

	/++
	 +	This function generates the geometry arrays for the NACA 0012 blade.
	 +/
	auto generate_blade_geom(double[] radial_stations, double[] twist, double radius, double[] chord) {
		// radial_stations are in the y direction and the airfoil points are in the x-z plane.

		size_t num_nodes = radial_stations.length*naca0012.length;
		auto geom = ConstantGeometryData(num_nodes);

		size_t node_idx = 0;
		foreach(r_idx, rs; radial_stations) {
			foreach(p_idx, p; naca0012) {
				static import std.math;
				immutable xp = p[0]*chord[r_idx];
				immutable zp = p[1]*chord[r_idx];
				geom.x_nodes[node_idx] = xp*std.math.cos(twist[r_idx]) - zp*std.math.sin(twist[r_idx]);
				geom.y_nodes[node_idx] = rs*radius;
				geom.z_nodes[node_idx] = xp*std.math.sin(twist[r_idx]) + zp*std.math.cos(twist[r_idx]);

				node_idx++;
			}
		}

		node_idx = 0;
		foreach(r_idx, rs; radial_stations) {
			foreach(p_idx, p; naca0012) {

				immutable n1 = r_idx*naca0012.length + p_idx - 1;
				immutable n2 = r_idx*naca0012.length + p_idx + 1;
				immutable n3 = (r_idx - 1)*naca0012.length + p_idx;
				immutable n4 = (r_idx + 1)*naca0012.length + p_idx;

				if(r_idx == 0) {
					if(p_idx == 0) {
						// only use n2, n4, and node_idx

						immutable n2n = Vec3(
							geom.x_nodes[n2] - geom.x_nodes[node_idx],
							geom.y_nodes[n2] - geom.y_nodes[node_idx],
							geom.z_nodes[n2] - geom.z_nodes[node_idx]
						);

						immutable n4n = Vec3(
							geom.x_nodes[n4] - geom.x_nodes[node_idx],
							geom.y_nodes[n4] - geom.y_nodes[node_idx],
							geom.z_nodes[n4] - geom.z_nodes[node_idx]
						);

						immutable normal = n2n.cross(n4n).normalize;

						geom.x_normals[node_idx] = normal[0];
						geom.y_normals[node_idx] = normal[1];
						geom.z_normals[node_idx] = normal[2];

					} else if(p_idx == naca0012.length - 1) {
						// only use n1, n4, and node_idx

						immutable n1n = Vec3(
							geom.x_nodes[n1] - geom.x_nodes[node_idx],
							geom.y_nodes[n1] - geom.y_nodes[node_idx],
							geom.z_nodes[n1] - geom.z_nodes[node_idx]
						);

						immutable n4n = Vec3(
							geom.x_nodes[n4] - geom.x_nodes[node_idx],
							geom.y_nodes[n4] - geom.y_nodes[node_idx],
							geom.z_nodes[n4] - geom.z_nodes[node_idx]
						);

						immutable normal = n4n.cross(n1n).normalize;

						geom.x_normals[node_idx] = normal[0];
						geom.y_normals[node_idx] = normal[1];
						geom.z_normals[node_idx] = normal[2];

					} else {
						// only use n1, n2, n4, and node_idx

						immutable n1n = Vec3(
							geom.x_nodes[n1] - geom.x_nodes[node_idx],
							geom.y_nodes[n1] - geom.y_nodes[node_idx],
							geom.z_nodes[n1] - geom.z_nodes[node_idx]
						);

						immutable n4n = Vec3(
							geom.x_nodes[n4] - geom.x_nodes[node_idx],
							geom.y_nodes[n4] - geom.y_nodes[node_idx],
							geom.z_nodes[n4] - geom.z_nodes[node_idx]
						);

						immutable n2n = Vec3(
							geom.x_nodes[n2] - geom.x_nodes[node_idx],
							geom.y_nodes[n2] - geom.y_nodes[node_idx],
							geom.z_nodes[n2] - geom.z_nodes[node_idx]
						);

						immutable normal1 = n4n.cross(n1n).normalize;
						immutable normal2 = n2n.cross(n4n).normalize;

						// Average the 2 local face normals for the vert normal
						immutable ave_norm = 0.5*(normal1 + normal2).normalize;
						geom.x_normals[node_idx] = ave_norm[0];
						geom.y_normals[node_idx] = ave_norm[1];
						geom.z_normals[node_idx] = ave_norm[2];
					}
				} else if(r_idx == radial_stations.length - 1) {
					if(p_idx == 0) {
						// only use n2, n3, and node_idx

						immutable n2n = Vec3(
							geom.x_nodes[n2] - geom.x_nodes[node_idx],
							geom.y_nodes[n2] - geom.y_nodes[node_idx],
							geom.z_nodes[n2] - geom.z_nodes[node_idx]
						);

						immutable n3n = Vec3(
							geom.x_nodes[n3] - geom.x_nodes[node_idx],
							geom.y_nodes[n3] - geom.y_nodes[node_idx],
							geom.z_nodes[n3] - geom.z_nodes[node_idx]
						);

						immutable normal = n3n.cross(n2n).normalize;

						geom.x_normals[node_idx] = normal[0];
						geom.y_normals[node_idx] = normal[1];
						geom.z_normals[node_idx] = normal[2];

					} else if(p_idx == naca0012.length - 1) {
						// only use n1, n3, and node_idx

						immutable n1n = Vec3(
							geom.x_nodes[n1] - geom.x_nodes[node_idx],
							geom.y_nodes[n1] - geom.y_nodes[node_idx],
							geom.z_nodes[n1] - geom.z_nodes[node_idx]
						);

						immutable n3n = Vec3(
							geom.x_nodes[n3] - geom.x_nodes[node_idx],
							geom.y_nodes[n3] - geom.y_nodes[node_idx],
							geom.z_nodes[n3] - geom.z_nodes[node_idx]
						);

						immutable normal = n1n.cross(n3n).normalize;

						geom.x_normals[node_idx] = normal[0];
						geom.y_normals[node_idx] = normal[1];
						geom.z_normals[node_idx] = normal[2];

					} else {
						// only use n1, n2, n3, and node_idx

						immutable n1n = Vec3(
							geom.x_nodes[n1] - geom.x_nodes[node_idx],
							geom.y_nodes[n1] - geom.y_nodes[node_idx],
							geom.z_nodes[n1] - geom.z_nodes[node_idx]
						);

						immutable n3n = Vec3(
							geom.x_nodes[n3] - geom.x_nodes[node_idx],
							geom.y_nodes[n3] - geom.y_nodes[node_idx],
							geom.z_nodes[n3] - geom.z_nodes[node_idx]
						);

						immutable n2n = Vec3(
							geom.x_nodes[n2] - geom.x_nodes[node_idx],
							geom.y_nodes[n2] - geom.y_nodes[node_idx],
							geom.z_nodes[n2] - geom.z_nodes[node_idx]
						);

						immutable normal1 = n1n.cross(n3n).normalize;
						immutable normal2 = n3n.cross(n2n).normalize;

						// Average the 2 local face normals for the vert normal
						immutable ave_norm = 0.5*(normal1 + normal2).normalize;
						geom.x_normals[node_idx] = ave_norm[0];
						geom.y_normals[node_idx] = ave_norm[1];
						geom.z_normals[node_idx] = ave_norm[2];
					}
				} else {
					if(p_idx == 0) {
						// only use n2, n3, n4, and node_idx

						immutable n4n = Vec3(
							geom.x_nodes[n4] - geom.x_nodes[node_idx],
							geom.y_nodes[n4] - geom.y_nodes[node_idx],
							geom.z_nodes[n4] - geom.z_nodes[node_idx]
						);

						immutable n3n = Vec3(
							geom.x_nodes[n3] - geom.x_nodes[node_idx],
							geom.y_nodes[n3] - geom.y_nodes[node_idx],
							geom.z_nodes[n3] - geom.z_nodes[node_idx]
						);

						immutable n2n = Vec3(
							geom.x_nodes[n2] - geom.x_nodes[node_idx],
							geom.y_nodes[n2] - geom.y_nodes[node_idx],
							geom.z_nodes[n2] - geom.z_nodes[node_idx]
						);

						immutable normal1 = n2n.cross(n4n).normalize;
						immutable normal2 = n3n.cross(n2n).normalize;

						// Average the 2 local face normals for the vert normal
						immutable ave_norm = 0.5*(normal1 + normal2).normalize;
						geom.x_normals[node_idx] = ave_norm[0];
						geom.y_normals[node_idx] = ave_norm[1];
						geom.z_normals[node_idx] = ave_norm[2];
						
					} else if(p_idx == naca0012.length - 1) {
						// only use n1, n3, n4, and node_idx
						immutable n4n = Vec3(
							geom.x_nodes[n4] - geom.x_nodes[node_idx],
							geom.y_nodes[n4] - geom.y_nodes[node_idx],
							geom.z_nodes[n4] - geom.z_nodes[node_idx]
						);

						immutable n3n = Vec3(
							geom.x_nodes[n3] - geom.x_nodes[node_idx],
							geom.y_nodes[n3] - geom.y_nodes[node_idx],
							geom.z_nodes[n3] - geom.z_nodes[node_idx]
						);

						immutable n1n = Vec3(
							geom.x_nodes[n1] - geom.x_nodes[node_idx],
							geom.y_nodes[n1] - geom.y_nodes[node_idx],
							geom.z_nodes[n1] - geom.z_nodes[node_idx]
						);

						immutable normal1 = n4n.cross(n1n).normalize;
						immutable normal2 = n1n.cross(n3n).normalize;

						// Average the 2 local face normals for the vert normal
						immutable ave_norm = 0.5*(normal1 + normal2).normalize;
						geom.x_normals[node_idx] = ave_norm[0];
						geom.y_normals[node_idx] = ave_norm[1];
						geom.z_normals[node_idx] = ave_norm[2];
					} else {
						// only use all
						immutable n4n = Vec3(
							geom.x_nodes[n4] - geom.x_nodes[node_idx],
							geom.y_nodes[n4] - geom.y_nodes[node_idx],
							geom.z_nodes[n4] - geom.z_nodes[node_idx]
						);

						immutable n3n = Vec3(
							geom.x_nodes[n3] - geom.x_nodes[node_idx],
							geom.y_nodes[n3] - geom.y_nodes[node_idx],
							geom.z_nodes[n3] - geom.z_nodes[node_idx]
						);

						immutable n2n = Vec3(
							geom.x_nodes[n2] - geom.x_nodes[node_idx],
							geom.y_nodes[n2] - geom.y_nodes[node_idx],
							geom.z_nodes[n2] - geom.z_nodes[node_idx]
						);

						immutable n1n = Vec3(
							geom.x_nodes[n1] - geom.x_nodes[node_idx],
							geom.y_nodes[n1] - geom.y_nodes[node_idx],
							geom.z_nodes[n1] - geom.z_nodes[node_idx]
						);

						immutable normal1 = n1n.cross(n3n).normalize;
						immutable normal2 = n3n.cross(n2n).normalize;
						immutable normal3 = n2n.cross(n4n).normalize;
						immutable normal4 = n4n.cross(n1n).normalize;
						
						// Average the 4 local face normals for the vert normal
						immutable ave_norm = 0.25*(normal1 + normal2 + normal3 + normal4).normalize;
						geom.x_normals[node_idx] = ave_norm[0];
						geom.y_normals[node_idx] = ave_norm[1];
						geom.z_normals[node_idx] = ave_norm[2];
					}
				}

				geom.x_normals[node_idx] = -geom.x_normals[node_idx];
				geom.y_normals[node_idx] = -geom.y_normals[node_idx];
				geom.z_normals[node_idx] = -geom.z_normals[node_idx];
				
				node_idx++;
			}
		}

		return geom;
	}

	import numd.utility : linspace;
	
	// This generates the 1D lifting line where the blade loads go.
	// Also generate a chord and twist distribution down the blade.
	auto r = linspace(0.0, 1.0, 24);
	double[] twist = new double[r.length];
	double[] real_chord = new double[r.length];
	real_chord[] = (R/AR);

	// This is basically the header of the geometry file.
	// It includes each zone header as well. Here we have 2
	// geometry zones: the first for the detailed geometric
	// description of the blade and the second for the
	// description of the lifting line where the blade loads
	// are.
	auto geometry = ConstantStructuredGeometryFile(
		"Test parallel geometry file",
		"Pa",
		DataAlignment.node_centered,
		[
			ConstantStructuredGeometryFile.HeaderType(
				"Test blade geometry",
				r.length.to!int,
				naca0012.length.to!int,
			),
			ConstantStructuredGeometryFile.HeaderType(
				"Test lifting line",
				r.length.to!int,
				1
			)
		]
	);

	// Actually generate blade geom.
	auto blade_geom = generate_blade_geom(r, twist, R, real_chord);

	// Actually generate lifting line geom.
	auto lifting_line_geometry_data = ConstantGeometryData(r.length);
	lifting_line_geometry_data.y_nodes[] = r.map!(a => (R*a).to!float).array;
	lifting_line_geometry_data.x_nodes[] = 0;
	lifting_line_geometry_data.z_nodes[] = 0;

	lifting_line_geometry_data.x_normals[] = 0;
	lifting_line_geometry_data.y_normals[] = 0;
	lifting_line_geometry_data.z_normals[] = 1;

	// We need to init mpi to use any of the functions.
	mpi_init([]);
	// Create and write header for geometry file. We pass to it the MPI communicator to use, the file name, an array of the number of nodes for each zone and another array for the number of normals for each zone.
	auto geometry_file = world_comm.create_geometry_file(geometry, "parallel_geom.dat", [blade_geom.x_nodes.length, lifting_line_geometry_data.x_nodes.length], [blade_geom.x_normals.length, lifting_line_geometry_data.x_normals.length]);

	// Write the blade geometry to the file.
	geometry_file.append_geometry_data(blade_geom, 0);
	// Write the lifting line geometry to the file.
	geometry_file.append_geometry_data(lifting_line_geometry_data, 1);

	// Close the file.
	geometry_file.close_geometry_file;

	// And we need to shutdown mpi after we are done with it.
	mpi_shutdown;

	auto serial_geometry_file = create_geometry_file(geometry, "serial_geom.dat", [blade_geom.x_nodes.length, lifting_line_geometry_data.x_nodes.length], [blade_geom.x_normals.length, lifting_line_geometry_data.x_normals.length]);
	/+

		You will need to create and fill in these function call that write the same data, but not using the MPI file calls and instead using the file IO stuff from std.stdio

	// Create and write header for geometry file. We pass to it the MPI communicator to use, the file name, an array of the number of nodes for each zone and another array for the number of normals for each zone.
	auto geometry_file = create_geometry_file(geometry, "serial_geom.dat", [blade_geom.x_nodes.length, lifting_line_geometry_data.x_nodes.length], [blade_geom.x_normals.length, lifting_line_geometry_data.x_normals.length]);

	// Write the blade geometry to the file.
	geometry_file.append_geometry_data(blade_geom, 0);
	// Write the lifting line geometry to the file.
	geometry_file.append_geometry_data(lifting_line_geometry_data, 1);

	// Close the file.
	geometry_file.close_geometry_file;

	+/

	size_t expected_byte_size = 48412;
	ubyte[] parallel_file_buffer = new ubyte[expected_byte_size];

	auto parallel_file = File("parallel_geom.dat", "rb");

	parallel_file_buffer = parallel_file.rawRead(parallel_file_buffer);
	parallel_file.close;

	ubyte[] serial_file_buffer = new ubyte[expected_byte_size];

	auto serial_file = File("serial_geom.dat", "rb");

	serial_file_buffer = serial_file.rawRead(serial_file_buffer);
	serial_file.close;
	

	assert(parallel_file_buffer.equal(serial_file_buffer), "Parallel and serial file outputs do not agree.");
}

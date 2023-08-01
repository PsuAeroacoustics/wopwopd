module wopwopd.geometry;

version(Have_mpid) {
	import mpid;
	import mpid : Group, include, group;
}

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

	this(string comment, string units, int number_of_zones, DataAlignment data_alignment) {
		this.comment_str[] = '\0';
		this.units[] = '\0';
		auto comment_range = comment.length > comment_str.length ? comment_str.length : comment.length;
		this.comment_str[0..comment_range] = comment[0..comment_range];

		auto units_range = units.length > this.units.length ? this.units.length : units.length;
		this.units[0..units_range] = units[0..units_range];

		this.number_of_zones = number_of_zones;
		this.data_alignment = data_alignment;
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

	this(string comment, string units, DataAlignment data_alignment, HeaderType[] zone_headers) {
		file_header = FileHeader(comment, units, zone_headers.length.to!int, data_alignment);
		this.zone_headers = zone_headers;
	}
}

alias StructuredGeometryFile(TimeType time_type) = GeometryFile!(Structuring.structured, time_type);
alias UnstructuredGeometryFile(TimeType time_type) = GeometryFile!(Structuring.unstructured, time_type);

alias AperiodicUnstructuredGeometryFile = UnstructuredGeometryFile!(TimeType.aperiodic);
alias PeriodicUnstructuredGeometryFile = UnstructuredGeometryFile!(TimeType.periodic);
alias ConstantUnstructuredGeometryFile = UnstructuredGeometryFile!(TimeType.constant);

alias ConstantStructuredGeometryFile = StructuredGeometryFile!(TimeType.constant);

struct ConstantStructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop int i_max;
	@wopwop int j_max;

	this(string name, int i_max, int j_max) {
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.i_max = i_max;
		this.j_max = j_max;
	}
}

struct ConstantUnstructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop int number_of_nodes;
	@wopwop int number_of_faces;
	@wopwop int[] connectivity;

	this(string name, int number_of_nodes, int number_of_faces, int[] connectivity) {
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.number_of_nodes = number_of_nodes;
		this.number_of_faces = number_of_faces;
		this.connectivity = new int[connectivity.length];
		this.connectivity[] = connectivity[];
	}
}

struct PeriodicUnstructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop float period;
	@wopwop int timesteps;
	@wopwop int number_of_nodes;
	@wopwop int number_of_faces;
	@wopwop int[] connectivity;

	this(string name, float period, int timesteps, int number_of_nodes, int number_of_faces, int[] connectivity) {
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.period = period;
		this.timesteps = timesteps;
		this.number_of_nodes = number_of_nodes;
		this.number_of_faces = number_of_faces;
		this.connectivity = new int[connectivity.length];
		this.connectivity[] = connectivity[];
	}
}
struct AperiodicUnstructuredGeometryHeader {
	@wopwop char[32] name;
	@wopwop int timesteps;
	@wopwop int number_of_nodes;
	@wopwop int number_of_faces;
	@wopwop int[] connectivity;

	this(string name, int timesteps, int number_of_nodes, int number_of_faces, int[] connectivity) {
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.timesteps = timesteps;
		this.number_of_nodes = number_of_nodes;
		this.number_of_faces = number_of_faces;
		this.connectivity = new int[connectivity.length];
		this.connectivity[] = connectivity[];
	}
}

struct ConstantGeometryData {
	float[] x_nodes;
	float[] y_nodes;
	float[] z_nodes;

	float[] x_normals;
	float[] y_normals;
	float[] z_normals;

	this(ref ConstantGeometryData geo_data) {
		this.x_nodes = geo_data.x_nodes;
		this.y_nodes = geo_data.y_nodes;
		this.z_nodes = geo_data.z_nodes;

		this.x_normals = geo_data.x_normals;
		this.y_normals = geo_data.y_normals;
		this.z_normals = geo_data.z_normals;
	}

	this(size_t num_nodes) {
		x_nodes = new float[num_nodes];
		y_nodes = new float[num_nodes];
		z_nodes = new float[num_nodes];
		
		x_normals = new float[num_nodes];
		y_normals = new float[num_nodes];
		z_normals = new float[num_nodes];
	}
}

struct NonconstantGeometryData {
	float time;

	float[] x_nodes;
	float[] y_nodes;
	float[] z_nodes;

	float[] x_normals;
	float[] y_normals;
	float[] z_normals;

	this(ref NonconstantGeometryData geo_data) {
		this.time = geo_data.time;
		this.x_nodes = geo_data.x_nodes;
		this.y_nodes = geo_data.y_nodes;
		this.z_nodes = geo_data.z_nodes;

		this.x_normals = geo_data.x_normals;
		this.y_normals = geo_data.y_normals;
		this.z_normals = geo_data.z_normals;
	}

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
		MPI_File mpi_file;
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
		File serial_file;
	}
}

@trusted GeometryFileHandle create_geometry_file(GeomFileType)(auto ref GeomFileType patch_file, string filename) {
	GeometryFileHandle file;

	file.serial_file = File(filename, "wb");
	
	file.serial_file.serial_write_struct(patch_file.file_header);
	
	foreach(ref zone_header; patch_file.zone_headers) {
		file.serial_file.serial_write_struct(zone_header);
	}
	
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

	ret = MPI_File_open(file.comm, filename.toStringz, MPI_MODE_CREATE | MPI_MODE_WRONLY, file.info, &file.mpi_file);

	enforce(ret == MPI_SUCCESS, "Failed to open or create loading file");

	MPI_Offset offset = 0;
	// Only root rank writes header info.
	if(file.comm.rank == 0) {
		file.mpi_file.serial_write_struct(patch_file.file_header);

		foreach(ref zone_header; patch_file.zone_headers) {
			file.mpi_file.serial_write_struct(zone_header);
		}

		ret = MPI_File_get_position(file.mpi_file, &offset);
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

		auto ret = MPI_File_set_view(patch_file.mpi_file, patch_file.x_node_displacement[zone], patch_file.etype, patch_file.node_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.mpi_file, patch_data.x_nodes.ptr, 1, patch_file.node_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.mpi_file, patch_file.y_node_displacement[zone], patch_file.etype, patch_file.node_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.mpi_file, patch_data.y_nodes.ptr, 1, patch_file.node_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.mpi_file, patch_file.z_node_displacement[zone], patch_file.etype, patch_file.node_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.mpi_file, patch_data.z_nodes.ptr, 1, patch_file.node_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");



		ret = MPI_File_set_view(patch_file.mpi_file, patch_file.x_normal_displacement[zone], patch_file.etype, patch_file.normal_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.mpi_file, patch_data.x_normals.ptr, 1, patch_file.normal_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.mpi_file, patch_file.y_normal_displacement[zone], patch_file.etype, patch_file.normal_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.mpi_file, patch_data.y_normals.ptr, 1, patch_file.normal_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(patch_file.mpi_file, patch_file.z_normal_displacement[zone], patch_file.etype, patch_file.normal_filetype[zone], "native", patch_file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(patch_file.mpi_file, patch_data.z_normals.ptr, 1, patch_file.normal_filetype[zone], MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

	} else {
		static assert("Cannot export non-constant patch data");
	}
}

static if(!have_mpi) @trusted private void append_geometry_data_serial(GeometryData)(ref GeometryFileHandle patch_file, ref GeometryData patch_data, size_t zone = 0) {
	static if(is(GeometryData == NonconstantGeometryData)) {
		float[1] time = patch_data.time;
		patch_file.serial_file.rawWrite(time);
	}
	//static if(is(GeometryData == ConstantGeometryData)) {

	enforce(
		(patch_data.x_nodes.length == patch_data.y_nodes.length) &&
		(patch_data.x_nodes.length == patch_data.z_nodes.length)
	);

	enforce(
		(patch_data.x_normals.length == patch_data.y_normals.length) &&
		(patch_data.x_normals.length == patch_data.z_normals.length)
	);

	patch_file.serial_file.rawWrite(patch_data.x_nodes);
	patch_file.serial_file.rawWrite(patch_data.y_nodes);
	patch_file.serial_file.rawWrite(patch_data.z_nodes);
	patch_file.serial_file.rawWrite(patch_data.x_normals);
	patch_file.serial_file.rawWrite(patch_data.y_normals);
	patch_file.serial_file.rawWrite(patch_data.z_normals);
	//} else {
	//	static assert("Cannot export non-constant patch data");
	//} 
}
		

@trusted void append_geometry_data(GeometryData)(ref GeometryFileHandle patch_file, ref GeometryData patch_data, size_t zone = 0) {
	import std.stdio : writeln;
	static if(!have_mpi) {
		append_geometry_data_serial(patch_file, patch_data, zone);
	} else {
		append_geometry_data_mpi(patch_file, patch_data, zone);
	}
}

void close_geometry_file(ref GeometryFileHandle file) {
	static if(have_mpi) {
		if(file.comm_group.rank != MPI_UNDEFINED) {
			auto ret = MPI_File_close(&file.mpi_file);
			enforce(ret == MPI_SUCCESS, "Failed to close wopwop loading file with error: "~ret.to!string);
		}
	} else {
		file.serial_file.close(); 

	}
}

auto generate_simple_constant_blade_geom(double[2][] airfoil_xsection, double[] radial_stations, double[] twist, double radius, double[] chord) {
	// radial_stations are in the y direction and the airfoil points are in the x-z plane.

	import std.math : PI;

	size_t num_nodes = radial_stations.length*airfoil_xsection.length;
	auto geom = ConstantGeometryData(num_nodes);

	size_t node_idx = 0;
	foreach(p_idx, p; airfoil_xsection.retro.array) {
		foreach(r_idx, rs; radial_stations) {
			static import std.math;
			immutable xp = (p[0] - 0.25)*chord[r_idx];
			immutable zp = p[1]*chord[r_idx];
			geom.y_nodes[node_idx] = xp*std.math.cos(twist[r_idx] + PI) - zp*std.math.sin(twist[r_idx] + PI);
			geom.x_nodes[node_idx] = rs*radius;
			geom.z_nodes[node_idx] = xp*std.math.sin(twist[r_idx] + PI) + zp*std.math.cos(twist[r_idx] + PI);

			node_idx++;
		}
	}

	node_idx = 0;
	foreach(p_idx, p; airfoil_xsection.retro.array) {
		foreach(r_idx, rs; radial_stations) {
			immutable n1 = (p_idx - 1)*radial_stations.length + r_idx;
			immutable n2 = (p_idx + 1)*radial_stations.length + r_idx;
			immutable n3 = node_idx - 1;
			immutable n4 = node_idx + 1;

			if(r_idx == 0) {
				if(p_idx == 0) {
					// only use n2, n4, and node_idx

					immutable n2n = FVec3(
						geom.x_nodes[n2] - geom.x_nodes[node_idx],
						geom.y_nodes[n2] - geom.y_nodes[node_idx],
						geom.z_nodes[n2] - geom.z_nodes[node_idx]
					);

					immutable n4n = FVec3(
						geom.x_nodes[n4] - geom.x_nodes[node_idx],
						geom.y_nodes[n4] - geom.y_nodes[node_idx],
						geom.z_nodes[n4] - geom.z_nodes[node_idx]
					);

					immutable normal = n2n.cross(n4n).normalize;

					geom.x_normals[node_idx] = normal[0];
					geom.y_normals[node_idx] = normal[1];
					geom.z_normals[node_idx] = normal[2];

				} else if(p_idx == airfoil_xsection.length - 1) {
					// only use n1, n4, and node_idx

					immutable n1n = FVec3(
						geom.x_nodes[n1] - geom.x_nodes[node_idx],
						geom.y_nodes[n1] - geom.y_nodes[node_idx],
						geom.z_nodes[n1] - geom.z_nodes[node_idx]
					);

					immutable n4n = FVec3(
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

					immutable n1n = FVec3(
						geom.x_nodes[n1] - geom.x_nodes[node_idx],
						geom.y_nodes[n1] - geom.y_nodes[node_idx],
						geom.z_nodes[n1] - geom.z_nodes[node_idx]
					);

					immutable n4n = FVec3(
						geom.x_nodes[n4] - geom.x_nodes[node_idx],
						geom.y_nodes[n4] - geom.y_nodes[node_idx],
						geom.z_nodes[n4] - geom.z_nodes[node_idx]
					);

					immutable n2n = FVec3(
						geom.x_nodes[n2] - geom.x_nodes[node_idx],
						geom.y_nodes[n2] - geom.y_nodes[node_idx],
						geom.z_nodes[n2] - geom.z_nodes[node_idx]
					);

					immutable normal1 = n4n.cross(n1n).normalize;
					immutable normal2 = n2n.cross(n4n).normalize;

					// Average the 2 local face normals for the vert normal
					immutable ave_norm = (0.5*(normal1 + normal2)).normalize;
					geom.x_normals[node_idx] = ave_norm[0];
					geom.y_normals[node_idx] = ave_norm[1];
					geom.z_normals[node_idx] = ave_norm[2];
				}
			} else if(r_idx == radial_stations.length - 1) {
				if(p_idx == 0) {
					// only use n2, n3, and node_idx

					immutable n2n = FVec3(
						geom.x_nodes[n2] - geom.x_nodes[node_idx],
						geom.y_nodes[n2] - geom.y_nodes[node_idx],
						geom.z_nodes[n2] - geom.z_nodes[node_idx]
					);

					immutable n3n = FVec3(
						geom.x_nodes[n3] - geom.x_nodes[node_idx],
						geom.y_nodes[n3] - geom.y_nodes[node_idx],
						geom.z_nodes[n3] - geom.z_nodes[node_idx]
					);

					immutable normal = n3n.cross(n2n).normalize;

					geom.x_normals[node_idx] = normal[0];
					geom.y_normals[node_idx] = normal[1];
					geom.z_normals[node_idx] = normal[2];

				} else if(p_idx == airfoil_xsection.length - 1) {
					// only use n1, n3, and node_idx

					immutable n1n = FVec3(
						geom.x_nodes[n1] - geom.x_nodes[node_idx],
						geom.y_nodes[n1] - geom.y_nodes[node_idx],
						geom.z_nodes[n1] - geom.z_nodes[node_idx]
					);

					immutable n3n = FVec3(
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

					immutable n1n = FVec3(
						geom.x_nodes[n1] - geom.x_nodes[node_idx],
						geom.y_nodes[n1] - geom.y_nodes[node_idx],
						geom.z_nodes[n1] - geom.z_nodes[node_idx]
					);

					immutable n3n = FVec3(
						geom.x_nodes[n3] - geom.x_nodes[node_idx],
						geom.y_nodes[n3] - geom.y_nodes[node_idx],
						geom.z_nodes[n3] - geom.z_nodes[node_idx]
					);

					immutable n2n = FVec3(
						geom.x_nodes[n2] - geom.x_nodes[node_idx],
						geom.y_nodes[n2] - geom.y_nodes[node_idx],
						geom.z_nodes[n2] - geom.z_nodes[node_idx]
					);

					immutable normal1 = n1n.cross(n3n).normalize;
					immutable normal2 = n3n.cross(n2n).normalize;

					// Average the 2 local face normals for the vert normal
					immutable ave_norm = (0.5*(normal1 + normal2)).normalize;
					geom.x_normals[node_idx] = ave_norm[0];
					geom.y_normals[node_idx] = ave_norm[1];
					geom.z_normals[node_idx] = ave_norm[2];
				}
			} else {
				if(p_idx == 0) {
					// only use n2, n3, n4, and node_idx

					immutable n4n = FVec3(
						geom.x_nodes[n4] - geom.x_nodes[node_idx],
						geom.y_nodes[n4] - geom.y_nodes[node_idx],
						geom.z_nodes[n4] - geom.z_nodes[node_idx]
					);

					immutable n3n = FVec3(
						geom.x_nodes[n3] - geom.x_nodes[node_idx],
						geom.y_nodes[n3] - geom.y_nodes[node_idx],
						geom.z_nodes[n3] - geom.z_nodes[node_idx]
					);

					immutable n2n = FVec3(
						geom.x_nodes[n2] - geom.x_nodes[node_idx],
						geom.y_nodes[n2] - geom.y_nodes[node_idx],
						geom.z_nodes[n2] - geom.z_nodes[node_idx]
					);

					immutable normal1 = n2n.cross(n4n).normalize;
					immutable normal2 = n3n.cross(n2n).normalize;

					// Average the 2 local face normals for the vert normal
					immutable ave_norm = (0.5*(normal1 + normal2)).normalize;
					geom.x_normals[node_idx] = ave_norm[0];
					geom.y_normals[node_idx] = ave_norm[1];
					geom.z_normals[node_idx] = ave_norm[2];
					
				} else if(p_idx == airfoil_xsection.length - 1) {
					// only use n1, n3, n4, and node_idx
					immutable n4n = FVec3(
						geom.x_nodes[n4] - geom.x_nodes[node_idx],
						geom.y_nodes[n4] - geom.y_nodes[node_idx],
						geom.z_nodes[n4] - geom.z_nodes[node_idx]
					);

					immutable n3n = FVec3(
						geom.x_nodes[n3] - geom.x_nodes[node_idx],
						geom.y_nodes[n3] - geom.y_nodes[node_idx],
						geom.z_nodes[n3] - geom.z_nodes[node_idx]
					);

					immutable n1n = FVec3(
						geom.x_nodes[n1] - geom.x_nodes[node_idx],
						geom.y_nodes[n1] - geom.y_nodes[node_idx],
						geom.z_nodes[n1] - geom.z_nodes[node_idx]
					);

					immutable normal1 = n4n.cross(n1n).normalize;
					immutable normal2 = n1n.cross(n3n).normalize;

					// Average the 2 local face normals for the vert normal
					immutable ave_norm = (0.5*(normal1 + normal2)).normalize;
					geom.x_normals[node_idx] = ave_norm[0];
					geom.y_normals[node_idx] = ave_norm[1];
					geom.z_normals[node_idx] = ave_norm[2];
				} else {
					// only use all
					immutable n4n = FVec3(
						geom.x_nodes[n4] - geom.x_nodes[node_idx],
						geom.y_nodes[n4] - geom.y_nodes[node_idx],
						geom.z_nodes[n4] - geom.z_nodes[node_idx]
					);

					immutable n3n = FVec3(
						geom.x_nodes[n3] - geom.x_nodes[node_idx],
						geom.y_nodes[n3] - geom.y_nodes[node_idx],
						geom.z_nodes[n3] - geom.z_nodes[node_idx]
					);

					immutable n2n = FVec3(
						geom.x_nodes[n2] - geom.x_nodes[node_idx],
						geom.y_nodes[n2] - geom.y_nodes[node_idx],
						geom.z_nodes[n2] - geom.z_nodes[node_idx]
					);

					immutable n1n = FVec3(
						geom.x_nodes[n1] - geom.x_nodes[node_idx],
						geom.y_nodes[n1] - geom.y_nodes[node_idx],
						geom.z_nodes[n1] - geom.z_nodes[node_idx]
					);

					immutable normal1 = n1n.cross(n3n).normalize;
					immutable normal2 = n3n.cross(n2n).normalize;
					immutable normal3 = n2n.cross(n4n).normalize;
					immutable normal4 = n4n.cross(n1n).normalize;
					
					// Average the 4 local face normals for the vert normal
					immutable ave_norm = (0.25*(normal1 + normal2 + normal3 + normal4)).normalize;
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

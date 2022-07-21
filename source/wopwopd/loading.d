module wopwopd.loading;

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

struct LoadingFileHeaderT(Structuring _structuring, TimeType _time_type, LoadingType _loading_type) {
	@wopwop immutable int magic_number = wopwop_magic_number;
	@wopwop immutable int file_version_1 = 1;
	@wopwop immutable int file_version_2 = 0;
	@wopwop char[COMMENT_STR_LEN] comment_str;
	@wopwop immutable FileType file_type = FileType.loading;
	@wopwop int number_of_zones;
	@wopwop immutable Structuring structuring = _structuring;
	@wopwop immutable TimeType time_type = _time_type;
	@wopwop DataAlignment data_alignment;
	@wopwop immutable LoadingType loading_type = _loading_type;
	@wopwop ReferenceFrame reference_frame;
	@wopwop immutable LoadingDatatype data_type = LoadingDatatype.single;
	@wopwop int reserved_1 = 0;
	@wopwop int reserved_2 = 0;

	this(string comment, int _number_of_zones, ReferenceFrame _reference_frame, DataAlignment _data_alignment) {
		comment_str[] = '\0';
		auto range = comment.length > comment_str.length ? comment_str.length : comment.length;
		comment_str[0..range] = comment[0..range];
		number_of_zones = _number_of_zones;
		//loading_type = _loading_type;
		reference_frame = _reference_frame;
		data_alignment = _data_alignment;
	}
}

struct ConstantUnstructuredHeader {
	@wopwop char[32] name;
	@wopwop int number_of_data_points;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string name, int number_of_data_points, int zone = 0, bool compute_thickness = true, bool has_data = true) {
		this.zone = zone;
		this.compute_thickness = compute_thickness;
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.number_of_data_points = number_of_data_points;
		this.has_data = has_data;
	}
}

struct PeriodicUnstructuredHeader {
	@wopwop char[32] name;
	@wopwop float period;
	@wopwop int number_of_data_points;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string name, float period, int number_of_data_points, int zone = 0, bool compute_thickness = true, bool has_data = true) {
		this.zone = zone;
		this.compute_thickness = compute_thickness;
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.period = period;
		this.number_of_data_points = number_of_data_points;
		this.has_data = has_data;
	}
}

struct AperiodicUnstructuredHeader {
	@wopwop char[32] name;
	@wopwop int timesteps;
	@wopwop int number_of_data_points;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string name, int timesteps, int number_of_data_points, int zone = 0, bool compute_thickness = true, bool has_data = true) {
		this.zone = zone;
		this.compute_thickness = compute_thickness;
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.timesteps = timesteps;
		this.number_of_data_points = number_of_data_points;
		this.has_data = has_data;
	}
}

struct ConstantStructuredHeader {
	@wopwop char[32] name;
	@wopwop int i_max;
	@wopwop int j_max;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string name, int i_max, int j_max, int zone = 0, bool compute_thickness = true, bool has_data = true) {
		this.zone = zone;
		this.compute_thickness = compute_thickness;
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.i_max = i_max;
		this.j_max = j_max;
		this.has_data = has_data;
	}
}

struct PeriodicStructuredHeader {
	@wopwop char[32] name;
	@wopwop float period;
	@wopwop int i_max;
	@wopwop int j_max;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string name, float period, int i_max, int j_max, int zone = 0, bool compute_thickness = true, bool has_data = true) {
		this.zone = zone;
		this.compute_thickness = compute_thickness;
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.period = period;
		this.i_max = i_max;
		this.j_max = j_max;
		this.has_data = has_data;
	}
}

struct AperiodicStructuredHeader {
	@wopwop char[32] name;
	@wopwop int timesteps;
	@wopwop int i_max;
	@wopwop int j_max;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string name, int timesteps, int i_max, int j_max, int zone = 0, bool compute_thickness = true, bool has_data = true) {
		this.zone = zone;
		this.compute_thickness = compute_thickness;
		this.name[] = '\0';
		auto range = name.length > this.name.length ? this.name.length : name.length;
		this.name[0..range] = name[0..range];
		this.timesteps = timesteps;
		this.i_max = i_max;
		this.j_max = j_max;
		this.has_data = has_data;
	}
}

struct LoadingFile(Structuring structuring, TimeType time_type, LoadingType _loading_type) {
	enum LoadingType loading_type = _loading_type;
	alias FileHeader = LoadingFileHeaderT!(structuring, time_type, _loading_type);
	FileHeader file_header;
	int[] zones_with_data;

	static if(structuring == Structuring.unstructured) {
		static if(time_type == TimeType.periodic) {
			alias HeaderType = PeriodicUnstructuredHeader;
		} else static if(time_type == TimeType.aperiodic) {
			alias HeaderType = AperiodicUnstructuredHeader;
		} else static if(time_type == TimeType.constant) {
			alias HeaderType = ConstantUnstructuredHeader;
		}
	} else {
		static if(time_type == TimeType.periodic) {
			alias HeaderType = PeriodicStructuredHeader;
		} else static if(time_type == TimeType.aperiodic) {
			alias HeaderType = AperiodicStructuredHeader;
		} else static if(time_type == TimeType.constant) {
			alias HeaderType = ConstantStructuredHeader;
		}
	}

	HeaderType[] zone_headers;

	this(string comment, ReferenceFrame _reference_frame, DataAlignment _data_alignment, HeaderType[] _zone_headers) {
		zone_headers = _zone_headers;
		zones_with_data = zone_headers.filter!(a => a.has_data).map!(zh => zh.compute_thickness ? zh.zone : -zh.zone).array;
		file_header = FileHeader(comment, _zone_headers.length.to!int, _reference_frame, _data_alignment);
	}
}

alias UnstructuredLoadingFile(TimeType time_type, LoadingType loading_type) = LoadingFile!(Structuring.unstructured, time_type, loading_type);
alias StructuredLoadingFile(TimeType time_type, LoadingType loading_type) = LoadingFile!(Structuring.structured, time_type, loading_type);

alias AperiodicUnstructuredLoadingFile(LoadingType _loading_type) = UnstructuredLoadingFile!(TimeType.aperiodic, _loading_type);
alias AperiodicStructuredLoadingFile(LoadingType _loading_type) = StructuredLoadingFile!(TimeType.aperiodic, _loading_type);
alias PeriodicUnstructuredLoadingFile(LoadingType _loading_type) = UnstructuredLoadingFile!(TimeType.periodic, _loading_type);
alias PeriodicStructuredLoadingFile(LoadingType _loading_type) = StructuredLoadingFile!(TimeType.periodic, _loading_type);
alias ConstantUnstructuredLoadingFile(LoadingType _loading_type) = UnstructuredLoadingFile!(TimeType.constant, _loading_type);
alias ConstantStructuredLoadingFile(LoadingType _loading_type) = StructuredLoadingFile!(TimeType.constant, _loading_type);

struct ZoneLoadingData {
	float time;
	float[] x_loading;
	float[] y_loading;
	float[] z_loading;

	this(size_t num_points) {
		x_loading = new float[num_points];
		y_loading = new float[num_points];
		z_loading = new float[num_points];
	}
}

struct ZonePressureData {
	float time;
	float[] pressure;

	this(size_t num_points) {
		pressure = new float[num_points];
	}
}

struct LoadingFileT(LoadingType loading_type) {
	static if(have_mpi) {
		MPI_File file_handle;
		MPI_Info info;
		Datatype etype;
		Datatype filetype;
		size_t timestamp_displacement;
		size_t x_loading_displacement;
		static if(loading_type == LoadingType.surface_loading) {
			//size_t x_loading_displacement;
			size_t y_loading_displacement;
			size_t z_loading_displacement;
		} else static if(loading_type == LoadingType.surface_pressure) {
			//size_t loading_displacement;
		}
		size_t total_data_size;
		Group comm_group;
		Comm comm;
	} else {
		File serial_file;
	}
}


@trusted LoadingFileT!(LoadingFileType.loading_type) open_loading_file_append(LoadingFileType)(auto ref LoadingFileType loading_file, string filename) {
	LoadingFileT!(LoadingFileType.loading_type) file;
	
	file.serial_file = File(filename, "ab");

	return file;
}

@trusted LoadingFileT!(LoadingFileType.loading_type) create_loading_file(LoadingFileType)(auto ref LoadingFileType loading_file, string filename) {
	LoadingFileT!(LoadingFileType.loading_type) file;

	file.serial_file = File(filename, "wb");

	file.serial_file.serial_write_struct(loading_file.file_header);

	int[1] int_length;
	int_length[0] = loading_file.zones_with_data.length.to!int;
	file.serial_file.rawWrite(int_length);
	file.serial_file.rawWrite(loading_file.zones_with_data);

	foreach(ref zone_header; loading_file.zone_headers) {
		if(zone_header.has_data) {
			file.serial_file.serial_write_struct(zone_header);
		}
	}

	return file;
}

/++
 +	MPI collective call, shared serial call. All MPI processes, but only 1 thread per process,
 +	need to call this to get added to MPI file handle. Only the root rank writes the header information.
 +/
static if(have_mpi) @trusted LoadingFileT!(LoadingFileType.loading_type) open_loading_file_append(LoadingFileType)(ref Comm comm, auto ref LoadingFileType loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingFileType.loading_type) file;
	
	file.etype = to_mpi_type!float;

	// First we create a group and communicator for those ranks that actually have
	// loading data to save.
	int[] send_buff = new int[comm.size];
	int[] rcv_buff = new int[comm.size];

	send_buff[] = rank_loading_count;
	comm.alltoall(send_buff, rcv_buff, 1);
	
	file.total_data_size = rcv_buff.sum*FVec3.sizeof + float.sizeof;

	int[] new_group_ranks = rcv_buff.enumerate.filter!(a => a[1] != 0).map!(a => a[0].to!int).array;

	file.comm_group = comm.group.include(new_group_ranks);

	file.comm = comm.create_group(file.comm_group, 55);

	if(file.comm_group.rank == MPI_UNDEFINED) {
		return file;
	}

	// Create the contiguous datatype for the loading array.
	auto ret = MPI_Type_contiguous(rank_loading_count, file.etype, &file.filetype);
	enforce(ret == MPI_SUCCESS, "Failed to create contiguous MPI datatype");

	ret = file.filetype.commit;
	enforce(ret == MPI_SUCCESS, "Failed to commit contiguous MPI datatype");

	ret = MPI_Info_create(&(file.info));
	enforce(ret == MPI_SUCCESS, "Failed to create MPI info object");

	ret = MPI_File_open(file.comm, filename.toStringz, MPI_MODE_APPEND | MPI_MODE_WRONLY, file.info, &file.file_handle);
	enforce(ret == MPI_SUCCESS, "Failed to open loading file");

	MPI_Offset offset = 0;

	ret = MPI_File_get_size(file.file_handle, &offset);
	enforce(ret == MPI_SUCCESS, "Failed get size of file");

	//file.comm.bcast(offset, 0);

	send_buff = new int[file.comm.size];
	rcv_buff = new int[file.comm.size];

	send_buff[] = rank_loading_count;
	file.comm.alltoall(send_buff, rcv_buff, 1);

	if(file.comm.rank == 0) {
		file.timestamp_displacement = offset;
		file.x_loading_displacement = file.timestamp_displacement + float.sizeof;
	} else {
		// add extra float offset for the timestamp
		file.x_loading_displacement = offset + rcv_buff[0..file.comm.rank].sum*float.sizeof + float.sizeof;
	}

	immutable single_list_size = (file.total_data_size - float.sizeof)/3;

	static if(LoadingFileType.loading_type == LoadingType.surface_loading) {
		file.y_loading_displacement = file.x_loading_displacement + single_list_size;
		file.z_loading_displacement = file.y_loading_displacement + single_list_size;
	}

	// Write out the headers again to update the total timesteps we now have.
	ret = MPI_File_set_view(file.file_handle, 0, MPI_BYTE, MPI_BYTE, "native", MPI_STATUS_IGNORE);
	if(file.comm.rank == 0) {
		file.file_handle.serial_write_struct(loading_file.file_header);

		ret = MPI_File_get_position(file.file_handle, &offset);

		MPI_Status status;
		auto int_length = loading_file.zones_with_data.length.to!int;
		ret = MPI_File_write(file.file_handle, &int_length, 1, to_mpi_type!int, &status);
		enforce(ret == MPI_SUCCESS, "Failed write number of zones with data");
		ret = MPI_File_write(file.file_handle, loading_file.zones_with_data.ptr, loading_file.zones_with_data.length.to!int, to_mpi_type!int, &status);
		enforce(ret == MPI_SUCCESS, "Failed write zones with data list");

		foreach(zone_header_idx; loading_file.zones_with_data) {
			file.file_handle.serial_write_struct(loading_file.zone_headers[zone_header_idx-1]);
		}

		ret = MPI_File_get_position(file.file_handle, &offset);
	}

	return file;
}

/++
 +	MPI collective call, shared serial call. All MPI processes, but only 1 thread per process,
 +	need to call this to get added to MPI file handle. Only the root rank writes the header information.
 +/
static if(have_mpi) @trusted LoadingFileT!(LoadingFileType.loading_type) create_loading_file(LoadingFileType)(ref Comm comm, auto ref LoadingFileType loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingFileType.loading_type) file;

	file.etype = to_mpi_type!float;

	// First we create a group and communicator for those ranks that actually have
	// loading data to save.
	int[] send_buff = new int[comm.size];
	int[] rcv_buff = new int[comm.size];

	send_buff[] = rank_loading_count;
	comm.alltoall(send_buff, rcv_buff, 1);
	
	file.total_data_size = rcv_buff.sum*FVec3.sizeof + float.sizeof;

	int[] new_group_ranks = rcv_buff.enumerate.filter!(a => a[1] != 0).map!(a => a[0].to!int).array;

	file.comm_group = comm.group.include(new_group_ranks);

	file.comm = comm.create_group(file.comm_group, 55);

	if(file.comm_group.rank == MPI_UNDEFINED) {
		return file;
	}

	// Create the contiguous datatype for the loading array.
	auto ret = MPI_Type_contiguous(rank_loading_count, file.etype, &file.filetype);
	enforce(ret == MPI_SUCCESS, "Failed to create contiguous MPI datatype");

	ret = file.filetype.commit;
	enforce(ret == MPI_SUCCESS, "Failed to commit contiguous MPI datatype");

	ret = MPI_Info_create(&(file.info));
	enforce(ret == MPI_SUCCESS, "Failed to create MPI info object");

	ret = MPI_File_open(file.comm, filename.toStringz, MPI_MODE_CREATE | MPI_MODE_WRONLY, file.info, &file.file_handle);

	enforce(ret == MPI_SUCCESS, "Failed to open or create loading file");

	MPI_Offset offset = 0;
	// Only root rank writes header info.
	if(file.comm.rank == 0) {
		file.file_handle.serial_write_struct(loading_file.file_header);

		ret = MPI_File_get_position(file.file_handle, &offset);

		MPI_Status status;
		auto int_length = loading_file.zones_with_data.length.to!int;
		ret = MPI_File_write(file.file_handle, &int_length, 1, to_mpi_type!int, &status);
		enforce(ret == MPI_SUCCESS, "Failed write number of zones with data");
		ret = MPI_File_write(file.file_handle, loading_file.zones_with_data.ptr, loading_file.zones_with_data.length.to!int, to_mpi_type!int, &status);
		enforce(ret == MPI_SUCCESS, "Failed write zones with data list");

		//foreach(zone_header_idx; loading_file.zones_with_data) {
		foreach(ref zone_header; loading_file.zone_headers) {
			if(zone_header.has_data) {
				file.file_handle.serial_write_struct(zone_header);
			}
		}

		ret = MPI_File_get_position(file.file_handle, &offset);
	}

	file.comm.bcast(offset, 0);

	send_buff = new int[file.comm.size];
	rcv_buff = new int[file.comm.size];

	send_buff[] = rank_loading_count;
	file.comm.alltoall(send_buff, rcv_buff, 1);

	if(file.comm.rank == 0) {
		file.timestamp_displacement = offset;
		file.x_loading_displacement = file.timestamp_displacement + float.sizeof;
	} else {
		// add extra float offset for the timestamp
		file.x_loading_displacement = offset + rcv_buff[0..file.comm.rank].sum*float.sizeof + float.sizeof;
	}

	immutable single_list_size = (file.total_data_size - float.sizeof)/3;

	static if(LoadingFileType.loading_type == LoadingType.surface_loading) {
		file.y_loading_displacement = file.x_loading_displacement + single_list_size;
		file.z_loading_displacement = file.y_loading_displacement + single_list_size;
	}

	return file;
}

/++
 +	MPI collective call, shared serial call. One thread in all MPI processes should call this providing
 +	it process local loading data. This uses MPI collective writing calls for increased throughput.
 +	Only the root rank will write the time stamp.
 +/
static if(have_mpi) private void append_loading_data_mpi(LoadingFile, LoadingData)(ref LoadingFile file, auto ref LoadingData loading_data) {

	if(file.comm_group.rank == MPI_UNDEFINED) {
		return;
	}

	auto ret = MPI_File_set_view(file.file_handle, file.timestamp_displacement, MPI_BYTE, MPI_BYTE, "native", file.info);
	enforce(ret == MPI_SUCCESS, "Failed to set file view");
	if(file.comm.rank == 0) {
		// Write out current timestep
		float timestamp = loading_data.time;
		ret = MPI_File_write_at(file.file_handle, 0, &timestamp, 1, MPI_FLOAT, MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write iteration");

		file.timestamp_displacement += file.total_data_size;
	}
	
	file.comm.barrier;

	//static if(LoadingFile.loading_type == LoadingType.surface_loading) {
	static if(is(ZoneLoadingData == LoadingData)) {
		ret = MPI_File_set_view(file.file_handle, file.x_loading_displacement, file.etype, file.filetype, "native", file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(file.file_handle, loading_data.x_loading.ptr, 1, file.filetype, MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(file.file_handle, file.y_loading_displacement, file.etype, file.filetype, "native", file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(file.file_handle, loading_data.y_loading.ptr, 1, file.filetype, MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		ret = MPI_File_set_view(file.file_handle, file.z_loading_displacement, file.etype, file.filetype, "native", file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(file.file_handle, loading_data.z_loading.ptr, 1, file.filetype, MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		file.x_loading_displacement += file.total_data_size;
		file.y_loading_displacement += file.total_data_size;
		file.z_loading_displacement += file.total_data_size;
	} else static if(is(ZonePressureData == LoadingData)) {
		pragma(msg, "Saving pressures");
		ret = MPI_File_set_view(file.file_handle, file.x_loading_displacement, file.etype, file.filetype, "native", file.info);
		enforce(ret == MPI_SUCCESS, "Failed to set file view");

		ret = MPI_File_write_all(file.file_handle, loading_data.pressure.ptr, 1, file.filetype, MPI_STATUS_IGNORE);
		enforce(ret == MPI_SUCCESS, "Failed to write all");

		file.x_loading_displacement += file.total_data_size;
	}
}

private void append_loading_data_serial(LoadingFile, LoadingData)(ref LoadingFile file, auto ref LoadingData loading_data) {
	float[1] timestamp_buff;
	timestamp_buff[0] = loading_data.time;
	file.serial_file.rawWrite(timestamp_buff);

	static if(is (LoadingData == ZoneLoadingData)) {
		file.serial_file.rawWrite(loading_data.x_loading);
		file.serial_file.rawWrite(loading_data.y_loading);
		file.serial_file.rawWrite(loading_data.z_loading);
	} else {
		file.serial_file.rawWrite(loading_data.pressure);
	}
}

void append_loading_data(LoadingFile, LoadingData)(ref LoadingFile file, auto ref LoadingData loading_data) {
	static if(have_mpi) {
		append_loading_data_mpi(file, loading_data);
	} else {
		append_loading_data_serial(file, loading_data);
	}
}

void close_loading_file(LoadingFileT)(ref LoadingFileT file) {
	static if(have_mpi) {
		if(file.comm_group.rank != MPI_UNDEFINED) {
			auto ret = MPI_File_close(&file.file_handle);
			enforce(ret == MPI_SUCCESS, "Failed to close wopwop loading file with error: "~ret.to!string);
		}
	} else {
		file.serial_file.close;
	}
}

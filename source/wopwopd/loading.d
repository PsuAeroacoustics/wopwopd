module wopwopd.loading;

import mpid;
import mpid : Group, include, group;

import numd.linearalgebra.matrix;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.string;
import std.traits;
import std.stdio;

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

	this(string _name, int _number_of_data_points, int _zone = 0, bool _compute_thickness = true, bool _has_data = true) {
		zone = _zone;
		compute_thickness = _compute_thickness;
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		number_of_data_points = _number_of_data_points;
		has_data = _has_data;
	}
}

struct PeriodicUnstructuredHeader {
	@wopwop char[32] name;
	@wopwop float period;
	@wopwop int number_of_data_points;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string _name, float _period, int _number_of_data_points, int _zone = 0, bool _compute_thickness = true, bool _has_data = true) {
		zone = _zone;
		compute_thickness = _compute_thickness;
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		period = _period;
		number_of_data_points = _number_of_data_points;
		has_data = _has_data;
	}
}

struct AperiodicUnstructuredHeader {
	@wopwop char[32] name;
	@wopwop int timesteps;
	@wopwop int number_of_data_points;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string _name, int _timesteps, int _number_of_data_points, int _zone = 0, bool _compute_thickness = true, bool _has_data = true) {
		zone = _zone;
		compute_thickness = _compute_thickness;
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		timesteps = _timesteps;
		number_of_data_points = _number_of_data_points;
		has_data = _has_data;
	}
}

struct ConstantStructuredHeader {
	@wopwop char[32] name;
	@wopwop int i_max;
	@wopwop int j_max;
	int zone;
	bool compute_thickness;
	bool has_data;

	this(string _name, int _i_max, int _j_max, int _zone = 0, bool _compute_thickness = true, bool _has_data = true) {
		zone = _zone;
		compute_thickness = _compute_thickness;
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		i_max = _i_max;
		j_max = _j_max;
		has_data = _has_data;
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

	this(string _name, float _period, int _i_max, int _j_max, int _zone = 0, bool _compute_thickness = true, bool _has_data = true) {
		zone = _zone;
		compute_thickness = _compute_thickness;
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		period = _period;
		i_max = _i_max;
		j_max = _j_max;
		has_data = _has_data;
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

	this(string _name, int _timesteps, int _i_max, int _j_max, int _zone = 0, bool _compute_thickness = true, bool _has_data = true) {
		zone = _zone;
		compute_thickness = _compute_thickness;
		name[] = '\0';
		auto range = _name.length > name.length ? name.length : _name.length;
		name[0..range] = _name[0..range];
		timesteps = _timesteps;
		i_max = _i_max;
		j_max = _j_max;
		has_data = _has_data;
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
alias AperiodicStructuredLoadingFile(LoadingType _loading_type) = UnstructuredLoadingFile!(TimeType.aperiodic, _loading_type);

struct ZoneLoadingData {
	float time;
	float[] x_loading;
	float[] y_loading;
	float[] z_loading;
}

struct ZonePressureData {
	float time;
	float[] pressure;
}

struct LoadingFileT(LoadingType loading_type) {
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
	bool is_serial;
	File serial_file;
}


@trusted LoadingFileT!(LoadingFileType.loading_type) open_loading_file_append(LoadingFileType)(auto ref LoadingFileType loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingFileType.loading_type) file;
	
	file.is_serial = true;
	// Fill in.

	return file;
}

@trusted LoadingFileT!(LoadingFileType.loading_type) create_loading_file(LoadingFileType)(auto ref LoadingFileType loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingFileType.loading_type) file;

		//Filled In. 
	file.is_serial = true;
	file.serial_file = File(filename, "wb");


	file.serial_file.serial_write_struct(loading_file.file_header);

	foreach(ref zone_header; loading_file.zone_headers) {
		file.serial_file.serial_write_struct(zone_header);
	}
	
	return file;
}

/++
 +	MPI collective call, shared serial call. All MPI processes, but only 1 thread per process,
 +	need to call this to get added to MPI file handle. Only the root rank writes the header information.
 +/
@trusted LoadingFileT!(LoadingFileType.loading_type) open_loading_file_append(LoadingFileType)(ref Comm comm, auto ref LoadingFileType loading_file, strfilenameing , int rank_loading_count) {
	LoadingFileT!(LoadingFileType.loading_type) file;
	
	file.etype = to_mpi_type!float;
	file.is_serial = false;
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
@trusted LoadingFileT!(LoadingFileType.loading_type) create_loading_file(LoadingFileType)(ref Comm comm, auto ref LoadingFileType loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingFileType.loading_type) file;

	file.is_serial = false;
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
 +	MPI collective call, shared serial call. All MPI processes, but only 1 thread per process,
 +	need to call this to get added to MPI file handle. Only the root rank writes the header information.
 +/
/+@trusted LoadingFileT!(LoadingFileType.loading_type) open_loading_file_append(LoadingFileType)(ref Comm comm, auto ref LoadingFileType loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingType.surface_pressure) file;
	
	file.etype = to_mpi_type!float;

	// First we create a group and communicator for those ranks that actually have
	// loading data to save.
	int[] send_buff = new int[comm.size];
	int[] rcv_buff = new int[comm.size];

	send_buff[] = rank_loading_count;
	comm.alltoall(send_buff, rcv_buff, 1);
	
	file.total_data_size = rcv_buff.sum*float.sizeof + float.sizeof;

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

	dbgln!1("offset: ", offset);
	//file.comm.bcast(offset, 0);

	send_buff = new int[file.comm.size];
	rcv_buff = new int[file.comm.size];

	send_buff[] = rank_loading_count;
	file.comm.alltoall(send_buff, rcv_buff, 1);

	if(file.comm.rank == 0) {
		file.timestamp_displacement = offset;
		file.loading_displacement = file.timestamp_displacement + float.sizeof;
	} else {
		// add extra float offset for the timestamp
		file.loading_displacement = offset + rcv_buff[0..file.comm.rank].sum*float.sizeof + float.sizeof;
	}

	/+immutable single_list_size = (file.total_data_size - float.sizeof)/3;

	file.y_loading_displacement = file.x_loading_displacement + single_list_size;
	file.z_loading_displacement = file.y_loading_displacement + single_list_size;+/

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
@trusted LoadingFileT!(LoadingType.surface_pressure) create_loading_file(SimConfig, TimeType time_type)(ref MPIManagerT!SimConfig mpi_manager, UnstructuredLoadingFile!(time_type, LoadingType.surface_pressure) loading_file, string filename, int rank_loading_count) {
	LoadingFileT!(LoadingType.surface_pressure) file;

	file.etype = to_mpi_type!float;

	// First we create a group and communicator for those ranks that actually have
	// loading data to save.
	int[] send_buff = new int[comm.size];
	int[] rcv_buff = new int[comm.size];

	send_buff[] = rank_loading_count;
	comm.alltoall(send_buff, rcv_buff, 1);
	
	file.total_data_size = rcv_buff.sum*float.sizeof + float.sizeof;

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

		foreach(zone_header_idx; loading_file.zones_with_data) {
			file.file_handle.serial_write_struct(loading_file.zone_headers[zone_header_idx-1]);
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
		file.loading_displacement = file.timestamp_displacement + float.sizeof;
	} else {
		// add extra float offset for the timestamp
		file.loading_displacement = offset + rcv_buff[0..file.comm.rank].sum*float.sizeof + float.sizeof;
	}

	/+immutable single_list_size = (file.total_data_size - float.sizeof)/3;

	file.y_loading_displacement = file.x_loading_displacement + single_list_size;
	file.z_loading_displacement = file.y_loading_displacement + single_list_size;+/
	
	return file;
}
+/
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

private void append_loading_data_serial(LoadingFile, LoadingData)(ref LoadingFile file, auto ref LoadingData loading_data) 
{ 
	// Fill in.
	static if(is (LoadingData == ZoneLoadingData))
	{
	file.serial_file.rawWrite(loading_data.x_loading);
    file.serial_file.rawWrite(loading_data.y_loading);
  	file.serial_file.rawWrite(loading_data.z_loading);
// add  timestep 



} else 
{
	static assert ("Can't export non-constant loading data");
} 
}

void append_loading_data(LoadingFile, LoadingData)(ref LoadingFile file, auto ref LoadingData loading_data) {
	if(!file.is_serial) {
		append_loading_data_mpi(file, loading_data);
	} else {
		append_loading_data_serial(file, loading_data);
	}
}

void close_loading_file(LoadingFileT)(ref LoadingFileT file) {
	if(!file.is_serial) {
		if(file.comm_group.rank != MPI_UNDEFINED) {
			auto ret = MPI_File_close(&file.file_handle);
			enforce(ret == MPI_SUCCESS, "Failed to close wopwop loading file with error: "~ret.to!string);
		}
	} else {
		file.file.close();
	}
}

unittest {
	import numd.utility : linspace;
	
	// This generates the 1D lifting line where the blade loads go.
	// Also generate a chord and twist distribution down the blade.
	auto linear_load = linspace!float(0.0, 1.0, 24);
	//double[] twist = new double[r.length];
	//double[] real_chord = new double[r.length];
	//real_chord[] = (R/AR);
	//twist[] = 0;


	alias LoadingFileDef = AperiodicStructuredLoadingFile!(LoadingType.surface_loading);

	// This is basically the header of the geometry file.
	// It includes each zone header as well. Here we have 2
	// geometry zones: the first for the detailed geometric
	// description of the blade and the second for the
	// description of the lifting line where the blade loads
	// are.
	auto loading = LoadingFileDef(
		"Test loading file",
		ReferenceFrame.patch_fixed,
		DataAlignment.node_centered,
		[
			LoadingFileDef.HeaderType(
				"Dummy blade loading",
				1,//((start_iteration + iterations) - record_start_iteration).to!int,
				linear_load.length.to!int,
				1, // zone # (can't wait for named arguments)
				false, // Do not compute thickness noise for this patch,
				false // No loading data
			),
			LoadingFileDef.HeaderType(
				"Test lifting line loading",
				1,//((start_iteration + iterations) - record_start_iteration).to!int,
				linear_load.length.to!int,
				2, // zone # (can't wait for named arguments)
				false, // Do not compute thickness noise for this patch,
				true // Has loading data
			)
		]
	);

	ZoneLoadingData loading_data;
	loading_data.time = 0;
	loading_data.x_loading = new float[linear_load.length];
	loading_data.y_loading = new float[linear_load.length];
	loading_data.z_loading = new float[linear_load.length];

	loading_data.x_loading[] = 0;
	loading_data.y_loading[] = 0;
	loading_data.z_loading[] = linear_load[];
	// Actually generate blade geom.
	//auto blade_geom = generate_blade_geom(r, twist, R, real_chord);

	// Actually generate lifting line geom.
	//auto lifting_line_geometry_data = ConstantGeometryData(r.length);
	//lifting_line_geometry_data.y_nodes[] = r.map!(a => (R*a).to!float).array;
	//lifting_line_geometry_data.x_nodes[] = 0;
	//lifting_line_geometry_data.z_nodes[] = 0;
//
	//lifting_line_geometry_data.x_normals[] = 0;
	//lifting_line_geometry_data.y_normals[] = 0;
	//lifting_line_geometry_data.z_normals[] = 1;

	// We need to init mpi to use any of the functions.
	//mpi_init([]);
	// Create and write header for geometry file. We pass to it the MPI communicator to use, the file name, an array of the number of nodes for each zone and another array for the number of normals for each zone.
	//loading_files[r_idx][b_idx] = local_comm.create_loading_file(loading, loading_filename, r.length.to!int);
	auto loading_file = world_comm.create_loading_file(loading, "parallel_loading.dat", linear_load.length.to!int);

	// Write the blade geometry to the file.
	loading_file.append_loading_data(loading_data);

	// Close the file.
	loading_file.close_loading_file;

	// And we need to shutdown mpi after we are done with it.
	//mpi_shutdown;

	auto serial_loading_file = create_loading_file(loading, "serial_loading.dat", linear_load.length.to!int);


	serial_loading_file.append_loading_data(loading_data);

	serial_loading_file.close_loading_file;
	

	size_t expected_byte_size = 48412;
	ubyte[] parallel_file_buffer = new ubyte[expected_byte_size];

	auto parallel_file = File("parallel_loading.dat", "rb");

	parallel_file_buffer = parallel_file.rawRead(parallel_file_buffer);
	parallel_file.close;

	ubyte[] serial_file_buffer = new ubyte[expected_byte_size];

	auto serial_file = File("serial_loading.dat", "rb");

	serial_file_buffer = serial_file.rawRead(serial_file_buffer);
	serial_file.close;


	writeln(serial_file_buffer.length);
	writeln(parallel_file_buffer.length);

	foreach(index, element; parallel_file_buffer)
	{
		assert(element == serial_file_buffer [index], "Parallel and serial file outputs do not agree at index. " ~ index.to!string);
	}

	

	assert(parallel_file_buffer.equal(serial_file_buffer), "Parallel and serial file outputs do not agree.");
}

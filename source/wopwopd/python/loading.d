module wopwopd.python.loading;

static import wopwopd;
static import wopwopd.airfoils;
static import wopwopd.loading;

import pyd.pyd;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.meta;
import std.string;
import std.traits;


alias PyAperiodicUnstructuredSurfaceLoadingFile = wopwopd.AperiodicUnstructuredLoadingFile!(wopwopd.LoadingType.surface_loading);
alias PyAperiodicUnstructuredSurfacePressureFile = wopwopd.AperiodicUnstructuredLoadingFile!(wopwopd.LoadingType.surface_pressure);
alias PyPeriodicUnstructuredSurfaceLoadingFile = wopwopd.PeriodicUnstructuredLoadingFile!(wopwopd.LoadingType.surface_loading);
alias PyPeriodicUnstructuredSurfacePressureFile = wopwopd.PeriodicUnstructuredLoadingFile!(wopwopd.LoadingType.surface_pressure);
alias PyConstantUnstructuredSurfaceLoadingFile = wopwopd.ConstantUnstructuredLoadingFile!(wopwopd.LoadingType.surface_loading);
alias PyConstantUnstructuredSurfacePressureFile = wopwopd.ConstantUnstructuredLoadingFile!(wopwopd.LoadingType.surface_pressure);

alias PyAperiodicStructuredSurfaceLoadingFile = wopwopd.AperiodicStructuredLoadingFile!(wopwopd.LoadingType.surface_loading);
alias PyAperiodicStructuredSurfacePressureFile = wopwopd.AperiodicStructuredLoadingFile!(wopwopd.LoadingType.surface_pressure);
alias PyPeriodicStructuredSurfaceLoadingFile = wopwopd.PeriodicStructuredLoadingFile!(wopwopd.LoadingType.surface_loading);
alias PyPeriodicStructuredSurfacePressureFile = wopwopd.PeriodicStructuredLoadingFile!(wopwopd.LoadingType.surface_pressure);
alias PyConstantStructuredSurfaceLoadingFile = wopwopd.ConstantStructuredLoadingFile!(wopwopd.LoadingType.surface_loading);
alias PyConstantStructuredSurfacePressureFile = wopwopd.ConstantStructuredLoadingFile!(wopwopd.LoadingType.surface_pressure);

alias PyPressureFileHandle = wopwopd.LoadingFileT!(wopwopd.LoadingType.surface_pressure);
alias PyVectorFileHandle = wopwopd.LoadingFileT!(wopwopd.LoadingType.surface_loading);

class LoadingFileHandle {
	PyPressureFileHandle* pressure_file_handle;
	PyVectorFileHandle* vector_file_handle;

	this() {

	}
	
	this(PyPressureFileHandle fh) {
		pressure_file_handle = new PyPressureFileHandle();
		*pressure_file_handle = fh;
	}

	this(PyVectorFileHandle fh) {
		vector_file_handle = new PyVectorFileHandle();
		*vector_file_handle = fh;
	}
}

class LoadingFile {}

class PressureLoadingFile : LoadingFile {
	PyAperiodicUnstructuredSurfacePressureFile* aperiodic_unstructured_surface_pressure_file;
	PyPeriodicUnstructuredSurfacePressureFile* periodic_unstructured_surface_pressure_file;
	PyConstantUnstructuredSurfacePressureFile* constant_unstructured_surface_pressure_file;

	PyAperiodicStructuredSurfacePressureFile* aperiodic_structured_surface_pressure_file;
	PyPeriodicStructuredSurfacePressureFile* periodic_structured_surface_pressure_file;
	PyConstantStructuredSurfacePressureFile* constant_structured_surface_pressure_file;

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.ConstantUnstructuredHeader[] zone_headers) {
		enforce(zone_headers.length > 0, "Loading header list should not be empty");

		constant_unstructured_surface_pressure_file = new PyConstantUnstructuredSurfacePressureFile(
			comment,
			reference_frame,
			data_alignment,
			zone_headers
		);
	}

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicUnstructuredHeader[] zone_headers) {
		periodic_unstructured_surface_pressure_file = new PyPeriodicUnstructuredSurfacePressureFile(
			comment,
			reference_frame,
			data_alignment,
			zone_headers
		);
	}
	
	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicUnstructuredHeader[] zone_headers) {
		aperiodic_unstructured_surface_pressure_file = new PyAperiodicUnstructuredSurfacePressureFile(
			comment,
			reference_frame,
			data_alignment,
			zone_headers
		);
	}

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.ConstantStructuredHeader[] zone_headers) {
		enforce(zone_headers.length > 0, "Loading header list should not be empty");

		constant_structured_surface_pressure_file = new PyConstantStructuredSurfacePressureFile(
			comment,
			reference_frame,
			data_alignment,
			zone_headers
		);
	}

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicStructuredHeader[] zone_headers) {
		periodic_structured_surface_pressure_file = new PyPeriodicStructuredSurfacePressureFile(
			comment,
			reference_frame,
			data_alignment,
			zone_headers
		);
	}
	
	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicStructuredHeader[] zone_headers) {
		aperiodic_structured_surface_pressure_file = new PyAperiodicStructuredSurfacePressureFile(
			comment,
			reference_frame,
			data_alignment,
			zone_headers
		);
	}
}

class VectorLoadingFile : LoadingFile {
	PyAperiodicUnstructuredSurfaceLoadingFile* aperiodic_unstructured_surface_loading_file;
	PyPeriodicUnstructuredSurfaceLoadingFile* periodic_unstructured_surface_loading_file;
	PyConstantUnstructuredSurfaceLoadingFile* constant_unstructured_surface_loading_file;

	PyAperiodicStructuredSurfaceLoadingFile* aperiodic_structured_surface_loading_file;
	PyPeriodicStructuredSurfaceLoadingFile* periodic_structured_surface_loading_file;
	PyConstantStructuredSurfaceLoadingFile* constant_structured_surface_loading_file;
	

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.ConstantUnstructuredHeader[] cu_zone_headers) {
		enforce(cu_zone_headers.length > 0, "Loading header list should not be empty");

		constant_unstructured_surface_loading_file = new PyConstantUnstructuredSurfaceLoadingFile(
			comment,
			reference_frame,
			data_alignment,
			cu_zone_headers
		);
	}

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicUnstructuredHeader[] pu_zone_headers) {
		periodic_unstructured_surface_loading_file = new PyPeriodicUnstructuredSurfaceLoadingFile(
			comment,
			reference_frame,
			data_alignment,
			pu_zone_headers
		);
	}
	
	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicUnstructuredHeader[] au_zone_headers) {
		aperiodic_unstructured_surface_loading_file = new PyAperiodicUnstructuredSurfaceLoadingFile(
			comment,
			reference_frame,
			data_alignment,
			au_zone_headers
		);
	}

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.ConstantStructuredHeader[] cs_zone_headers) {
		enforce(cs_zone_headers.length > 0, "Loading header list should not be empty");

		constant_structured_surface_loading_file = new PyConstantStructuredSurfaceLoadingFile(
			comment,
			reference_frame,
			data_alignment,
			cs_zone_headers
		);
	}

	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicStructuredHeader[] ps_zone_headers) {
		periodic_structured_surface_loading_file = new PyPeriodicStructuredSurfaceLoadingFile(
			comment,
			reference_frame,
			data_alignment,
			ps_zone_headers
		);
	}
	
	this(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicStructuredHeader[] as_zone_headers) {
		aperiodic_structured_surface_loading_file = new PyAperiodicStructuredSurfaceLoadingFile(
			comment,
			reference_frame,
			data_alignment,
			as_zone_headers
		);
	}
}

VectorLoadingFile ConstUnstructuredVectorLoadingFile(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.ConstantUnstructuredHeader[] zone_headers) {
	return new VectorLoadingFile(comment, reference_frame, data_alignment, zone_headers);
}

VectorLoadingFile AperiodicUnstructuredVectorLoadingFile(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicUnstructuredHeader[] zone_headers) {
	return new VectorLoadingFile(comment, reference_frame, data_alignment, zone_headers);
}

VectorLoadingFile PeriodicUnstructuredVectorLoadingFile(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicUnstructuredHeader[] zone_headers) {
	return new VectorLoadingFile(comment, reference_frame, data_alignment, zone_headers);
}

VectorLoadingFile ConstStructuredVectorLoadingFile(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.ConstantStructuredHeader[] zone_headers) {
	return new VectorLoadingFile(comment, reference_frame, data_alignment, zone_headers);
}

VectorLoadingFile AperiodicStructuredVectorLoadingFile(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicStructuredHeader[] zone_headers) {
	return new VectorLoadingFile(comment, reference_frame, data_alignment, zone_headers);
}

VectorLoadingFile PeriodicStructuredVectorLoadingFile(string comment, wopwopd.ReferenceFrame reference_frame, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicStructuredHeader[] zone_headers) {
	return new VectorLoadingFile(comment, reference_frame, data_alignment, zone_headers);
}

LoadingFileHandle create_loading_file(LoadingFile loading_file, string filename) {
	if(typeid(loading_file).name == "wopwopd.python.loading.PressureLoadingFile") {
		auto p_loading_file = loading_file.to!PressureLoadingFile;
		if(p_loading_file.aperiodic_structured_surface_pressure_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(p_loading_file.aperiodic_structured_surface_pressure_file, filename));
		} else if(p_loading_file.periodic_structured_surface_pressure_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(p_loading_file.periodic_structured_surface_pressure_file, filename));
		} else if(p_loading_file.constant_structured_surface_pressure_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(p_loading_file.constant_structured_surface_pressure_file, filename));
		} else if(p_loading_file.aperiodic_unstructured_surface_pressure_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(p_loading_file.aperiodic_unstructured_surface_pressure_file, filename));
		} else if(p_loading_file.periodic_unstructured_surface_pressure_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(p_loading_file.periodic_unstructured_surface_pressure_file, filename));
		} else if(p_loading_file.constant_unstructured_surface_pressure_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(p_loading_file.constant_unstructured_surface_pressure_file, filename));
		}
	} else if(typeid(loading_file).name == "wopwopd.python.loading.VectorLoadingFile") {
		auto v_loading_file = loading_file.to!VectorLoadingFile;
		if(v_loading_file.aperiodic_structured_surface_loading_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(v_loading_file.aperiodic_structured_surface_loading_file, filename));
		} else if(v_loading_file.periodic_structured_surface_loading_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(v_loading_file.periodic_structured_surface_loading_file, filename));
		} else if(v_loading_file.constant_structured_surface_loading_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(v_loading_file.constant_structured_surface_loading_file, filename));
		} else if(v_loading_file.aperiodic_unstructured_surface_loading_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(v_loading_file.aperiodic_unstructured_surface_loading_file, filename));
		} else if(v_loading_file.periodic_unstructured_surface_loading_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(v_loading_file.periodic_unstructured_surface_loading_file, filename));
		} else if(v_loading_file.constant_unstructured_surface_loading_file !is null) {
			return new LoadingFileHandle(wopwopd.create_loading_file(v_loading_file.constant_unstructured_surface_loading_file, filename));
		}
	}
	
	throw new Exception("loading_file is in an invalid state.");
}

class ZoneData {}

class ZoneVectorData : ZoneData {
	import pyd.extra : d_to_python_numpy_ndarray;

	wopwopd.ZoneLoadingData* loading_data;

	this() {
		loading_data = new wopwopd.ZoneLoadingData();
	}

	this(size_t num_points) {
		loading_data = new wopwopd.ZoneLoadingData(num_points);
	}

	@property void time(float t) {
		enforce(loading_data !is null, "Vector data has not been intialized");
		loading_data.time = t;
	}

	@property float time() {
		enforce(loading_data !is null, "Vector data has not been intialized");
		return loading_data.time;
	}

	auto get_x_loading_array() {
		enforce(loading_data !is null, "Vector data has not been intialized");
		return loading_data.x_loading.d_to_python_numpy_ndarray;
	}

	auto get_y_loading_array() {
		enforce(loading_data !is null, "Vector data has not been intialized");
		return loading_data.y_loading.d_to_python_numpy_ndarray;
	}

	auto get_z_loading_array() {
		enforce(loading_data !is null, "Vector data has not been intialized");
		return loading_data.z_loading.d_to_python_numpy_ndarray;
	}

	void set_x_loading_array(float[] data) {
		enforce(loading_data !is null, "Vector data has not been intialized");
		loading_data.x_loading = data;
	}

	void set_y_loading_array(float[] data) {
		enforce(loading_data !is null, "Vector data has not been intialized");
		loading_data.y_loading = data;
	}

	void set_z_loading_array(float[] data) {
		enforce(loading_data !is null, "Vector data has not been intialized");
		loading_data.z_loading = data;
	}
}

class ZonePressureData : ZoneData {
	import pyd.extra : d_to_python_numpy_ndarray;

	wopwopd.ZonePressureData* pressure_data;

	this() {
		pressure_data = new wopwopd.ZonePressureData();
	}

	this(size_t num_points) {
		pressure_data = new wopwopd.ZonePressureData(num_points);
	}

	@property void time(float t) {
		enforce(pressure_data !is null, "Vector data has not been intialized");
		pressure_data.time = t;
	}

	@property float time() {
		enforce(pressure_data !is null, "Vector data has not been intialized");
		return pressure_data.time;
	}

	auto get_pressure_array() {
		enforce(pressure_data !is null, "Vector data has not been intialized");
		return pressure_data.pressure.d_to_python_numpy_ndarray;
	}

	void set_pressure_array(float[] data) {
		enforce(pressure_data !is null, "Vector data has not been intialized");
		pressure_data.pressure = data;
	}
}

void append_loading_data(LoadingFileHandle file_handle, ZoneData zone_data) {
	if(file_handle.pressure_file_handle !is null) {
		wopwopd.append_loading_data(file_handle.pressure_file_handle, *zone_data.to!ZonePressureData.pressure_data);
	} else if(file_handle.vector_file_handle !is null) {
		wopwopd.append_loading_data(file_handle.vector_file_handle, *zone_data.to!ZoneVectorData.loading_data);
	}
}

void close_loading_file(LoadingFileHandle file_handle) {
	if(file_handle.pressure_file_handle !is null) {
		wopwopd.close_loading_file(file_handle.pressure_file_handle);
	} else if(file_handle.vector_file_handle !is null) {
		wopwopd.close_loading_file(file_handle.vector_file_handle);
	}
}

auto ReferenceFrame_stationary_ground_fixed() {
	return wopwopd.ReferenceFrame.stationary_ground_fixed;
}

auto ReferenceFrame_rotating_ground_fixed() {
	return wopwopd.ReferenceFrame.rotating_ground_fixed;
}

auto ReferenceFrame_patch_fixed() {
	return wopwopd.ReferenceFrame.patch_fixed;
}

void python_loading_function_wraps() {
	def!ReferenceFrame_stationary_ground_fixed;
	def!ReferenceFrame_rotating_ground_fixed;
	def!ReferenceFrame_patch_fixed;

	def!create_loading_file;
	def!append_loading_data;
	def!close_loading_file;

	def!ConstUnstructuredVectorLoadingFile;
	def!AperiodicUnstructuredVectorLoadingFile;
	def!PeriodicUnstructuredVectorLoadingFile;
	def!ConstStructuredVectorLoadingFile;
	def!AperiodicStructuredVectorLoadingFile;
	def!PeriodicStructuredVectorLoadingFile;
}

void python_loading_class_wraps() {
	wrap_class!LoadingFile;

	wrap_class!(LoadingFile);
	wrap_class!(ZoneData);
	wrap_class!(LoadingFileHandle);

	wrap_class!(
		ZonePressureData,
		Init!(),
		Init!(size_t),
		Member!"time",
		Def!(ZonePressureData.get_pressure_array),
		Def!(ZonePressureData.set_pressure_array)
	);

	wrap_class!(
		ZoneVectorData,
		Init!(),
		Init!(size_t),
		Member!"time",
		Def!(ZoneVectorData.get_x_loading_array),
		Def!(ZoneVectorData.get_y_loading_array),
		Def!(ZoneVectorData.get_z_loading_array),
		Def!(ZoneVectorData.set_x_loading_array),
		Def!(ZoneVectorData.set_y_loading_array),
		Def!(ZoneVectorData.set_z_loading_array),
	);

	wrap_class!(
		VectorLoadingFile,
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.ConstantUnstructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.PeriodicUnstructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.AperiodicUnstructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.ConstantStructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.PeriodicStructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.AperiodicStructuredHeader[])
	);

	wrap_class!(
		PressureLoadingFile,
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.ConstantUnstructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.PeriodicUnstructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.AperiodicUnstructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.ConstantStructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.PeriodicStructuredHeader[]),
		Init!(string, wopwopd.ReferenceFrame, wopwopd.DataAlignment, wopwopd.AperiodicStructuredHeader[])
	);

	wrap_struct!(
		wopwopd.ConstantUnstructuredHeader,
		Init!(string, int, int, bool, bool)
	);

	wrap_struct!(
		wopwopd.PeriodicUnstructuredHeader,
		Init!(string, float, int, int, bool, bool)
	);

	wrap_struct!(
		wopwopd.AperiodicUnstructuredHeader,
		Init!(string, int, int, int, bool, bool)
	);

	wrap_struct!(
		wopwopd.ConstantStructuredHeader,
		Init!(string, int, int, int, bool, bool)
	);

	wrap_struct!(
		wopwopd.PeriodicStructuredHeader,
		Init!(string, float, int, int, int, bool, bool)
	);

	wrap_struct!(
		wopwopd.AperiodicStructuredHeader,
		Init!(string, int, int, int, int, bool, bool)
	);
}

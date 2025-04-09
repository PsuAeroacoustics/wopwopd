module wopwopd.python.geometry;

static import wopwopd;
static import wopwopd.airfoils;
static import wopwopd.geometry;

import pyd.pyd;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.meta;
import std.string;
import std.traits;


alias PyAperiodicUnstructuredGeometryFile = wopwopd.geometry.AperiodicUnstructuredGeometryFile;
alias PyPeriodicUnstructuredGeometryFile = wopwopd.geometry.PeriodicUnstructuredGeometryFile;
alias PyConstantUnstructuredGeometryFile = wopwopd.geometry.ConstantUnstructuredGeometryFile;
alias PyConstantStructuredGeometryFile = wopwopd.geometry.ConstantStructuredGeometryFile;

class GeometryFile {
    PyAperiodicUnstructuredGeometryFile* aperiodic_unstructured_geo_file;
    PyPeriodicUnstructuredGeometryFile* periodic_unstructured_geo_file;
    PyConstantUnstructuredGeometryFile* constant_unstructured_geo_file;
    PyConstantStructuredGeometryFile* constant_structured_geo_file;

    this(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.ConstantStructuredGeometryHeader[] zone_headers) {
        enforce(zone_headers.length > 0, "Geometry header list should not be empty");

        constant_structured_geo_file = new PyConstantStructuredGeometryFile(
            comment,
            units,
            data_alignment,
            zone_headers
        );
	}

    this(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.ConstantUnstructuredGeometryHeader[] zone_headers) {
        enforce(zone_headers.length > 0, "Geometry header list should not be empty");

        constant_unstructured_geo_file = new PyConstantUnstructuredGeometryFile(
            comment,
            units,
            data_alignment,
            zone_headers
        );
	}

    this(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicUnstructuredGeometryHeader[] zone_headers) {
        enforce(zone_headers.length > 0, "Geometry header list should not be empty");

        periodic_unstructured_geo_file = new PyPeriodicUnstructuredGeometryFile(
            comment,
            units,
            data_alignment,
            zone_headers
        );
	}

    this(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicUnstructuredGeometryHeader[] zone_headers) {
        enforce(zone_headers.length > 0, "Geometry header list should not be empty");

        aperiodic_unstructured_geo_file = new PyAperiodicUnstructuredGeometryFile(
            comment,
            units,
            data_alignment,
            zone_headers
        );
	}

}

GeometryFile AperiodicUnstructuredGeometryFile(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.AperiodicUnstructuredGeometryHeader[] zone_headers) {
	return new GeometryFile(comment, units, data_alignment, zone_headers);
}

GeometryFile PeriodicUnstructuredGeometryFile(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.PeriodicUnstructuredGeometryHeader[] zone_headers) {
	return new GeometryFile(comment, units, data_alignment, zone_headers);
}

GeometryFile ConstantUnstructuredGeometryFile(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.ConstantUnstructuredGeometryHeader[] zone_headers) {
	return new GeometryFile(comment, units, data_alignment, zone_headers);
}

GeometryFile ConstantStructuredGeometryFile(string comment, string units, wopwopd.DataAlignment data_alignment, wopwopd.ConstantStructuredGeometryHeader[] zone_headers) {
	return new GeometryFile(comment, units, data_alignment, zone_headers);
}

wopwopd.GeometryFileHandle create_geometry_file(GeometryFile patch_file, string filename) {
    if(patch_file.aperiodic_unstructured_geo_file !is null) {
        return wopwopd.create_geometry_file(*patch_file.aperiodic_unstructured_geo_file, filename);
    } else if(patch_file.periodic_unstructured_geo_file !is null) {
        return wopwopd.create_geometry_file(*patch_file.periodic_unstructured_geo_file, filename);
    } else if(patch_file.constant_unstructured_geo_file !is null) {
        return wopwopd.create_geometry_file(*patch_file.constant_unstructured_geo_file, filename);
    } else if(patch_file.constant_structured_geo_file !is null) {
        return wopwopd.create_geometry_file(*patch_file.constant_structured_geo_file, filename);
    }
    
    throw new Exception("patch_file is in an invalid state.");
}

class GeometryData {
    import pyd.extra : d_to_python_numpy_ndarray;

    wopwopd.ConstantGeometryData* constant_geo_data;
    wopwopd.NonconstantGeometryData* nonconstant_geo_data;

    this(ref wopwopd.ConstantGeometryData geo_data) {
        constant_geo_data = new wopwopd.ConstantGeometryData(geo_data);
    }

    this(ref wopwopd.NonconstantGeometryData geo_data) {
        nonconstant_geo_data = new wopwopd.NonconstantGeometryData(geo_data);
    }

    this(size_t num_nodes) {
        constant_geo_data = new wopwopd.ConstantGeometryData(num_nodes);
    }

    this(size_t num_nodes, float time = 0) {
        nonconstant_geo_data = new wopwopd.NonconstantGeometryData(num_nodes);
    }

    auto get_x_nodes(size_t timestep = 0) {
        if(constant_geo_data !is null) {
            return constant_geo_data.x_nodes.d_to_python_numpy_ndarray;
        } else if(nonconstant_geo_data !is null) {
            return nonconstant_geo_data.x_nodes.d_to_python_numpy_ndarray;
        }
        enforce(false, "GeometryData has not been initialized");
        assert(0);
    }

    void set_x_nodes(float[] nodes, float timestep = 0) {
        enforce((constant_geo_data !is null) || (nonconstant_geo_data !is null), "GeometryData has not been initialized");
        if(constant_geo_data !is null) {
            constant_geo_data.x_nodes[] = nodes[];
        } else if(nonconstant_geo_data !is null) {
            nonconstant_geo_data.time = timestep;
            nonconstant_geo_data.x_nodes[] = nodes[];
        }
    }

    auto get_y_nodes(size_t timestep = 0) {
        if(constant_geo_data !is null) {
            return constant_geo_data.y_nodes.d_to_python_numpy_ndarray;
        } else if(nonconstant_geo_data !is null) {
            return nonconstant_geo_data.y_nodes.d_to_python_numpy_ndarray;
        }
        enforce(false, "GeometryData has not been initialized");
        assert(0);
    }

    void set_y_nodes(float[] nodes, float timestep = 0) {
        enforce((constant_geo_data !is null) || (nonconstant_geo_data !is null), "GeometryData has not been initialized");
        if(constant_geo_data !is null) {
            constant_geo_data.y_nodes[] = nodes[];
        } else if(nonconstant_geo_data !is null) {
            nonconstant_geo_data.time = timestep;
            nonconstant_geo_data.y_nodes[] = nodes[];
        }
    }

    auto get_z_nodes(size_t timestep = 0) {
        if(constant_geo_data !is null) {
            return constant_geo_data.z_nodes.d_to_python_numpy_ndarray;
        } else if(nonconstant_geo_data !is null) {
            return nonconstant_geo_data.z_nodes.d_to_python_numpy_ndarray;
        }
        enforce(false, "GeometryData has not been initialized");
        assert(0);
    }

    void set_z_nodes(float[] nodes, float timestep = 0) {
        enforce((constant_geo_data !is null) || (nonconstant_geo_data !is null), "GeometryData has not been initialized");
        if(constant_geo_data !is null) {
            constant_geo_data.z_nodes[] = nodes[];
        } else if(nonconstant_geo_data !is null) {
            nonconstant_geo_data.time = timestep;
            nonconstant_geo_data.z_nodes[] = nodes[];
        }
    }

    auto get_x_normals(size_t timestep = 0) {
        if(constant_geo_data !is null) {
            return constant_geo_data.x_normals.d_to_python_numpy_ndarray;
        } else if(nonconstant_geo_data !is null) {
            return nonconstant_geo_data.x_normals.d_to_python_numpy_ndarray;
        }
        enforce(false, "GeometryData has not been initialized");
        assert(0);
    }

    void set_x_normals(float[] normals, float timestep = 0) {
        enforce((constant_geo_data !is null) || (nonconstant_geo_data !is null), "GeometryData has not been initialized");
        if(constant_geo_data !is null) {
            constant_geo_data.x_normals[] = normals[];
        } else if(nonconstant_geo_data !is null) {
            nonconstant_geo_data.time = timestep;
            nonconstant_geo_data.x_normals[] = normals[];
        }
    }

    auto get_y_normals(size_t timestep = 0) {
        if(constant_geo_data !is null) {
            return constant_geo_data.y_normals.d_to_python_numpy_ndarray;
        } else if(nonconstant_geo_data !is null) {
            return nonconstant_geo_data.y_normals.d_to_python_numpy_ndarray;
        }
        enforce(false, "GeometryData has not been initialized");
        assert(0);
    }

    void set_y_normals(float[] normals, float timestep = 0) {
        enforce((constant_geo_data !is null) || (nonconstant_geo_data !is null), "GeometryData has not been initialized");
        if(constant_geo_data !is null) {
            constant_geo_data.y_normals[] = normals[];
        } else if(nonconstant_geo_data !is null) {
            nonconstant_geo_data.time = timestep;
            nonconstant_geo_data.y_normals[] = normals[];
        }
    }

    auto get_z_normals(size_t timestep = 0) {
        if(constant_geo_data !is null) {
            return constant_geo_data.z_normals.d_to_python_numpy_ndarray;
        } else if(nonconstant_geo_data !is null) {
            return nonconstant_geo_data.z_normals.d_to_python_numpy_ndarray;
        }
        enforce(false, "GeometryData has not been initialized");
        assert(0);
    }

    void set_z_normals(float[] normals, float timestep = 0) {
        enforce((constant_geo_data !is null) || (nonconstant_geo_data !is null), "GeometryData has not been initialized");
        if(constant_geo_data !is null) {
            constant_geo_data.z_normals[] = normals[];
        } else if(nonconstant_geo_data !is null) {
            nonconstant_geo_data.time = timestep;
            nonconstant_geo_data.z_normals[] = normals[];
        }
    }
}

GeometryData ConstantGeometryData(size_t num_nodes) {
    return new GeometryData(num_nodes);
}

GeometryData NonconstantGeometryData(size_t num_nodes) {
    return new GeometryData(num_nodes, 0.0);
}

void append_geometry_data(wopwopd.GeometryFileHandle patch_file, GeometryData patch_data, int zone = 0) {
    if(patch_data.constant_geo_data !is null) {
        wopwopd.append_geometry_data(patch_file, *patch_data.constant_geo_data, zone);
    } else if(patch_data.nonconstant_geo_data !is null) {
        wopwopd.append_geometry_data(patch_file, *patch_data.nonconstant_geo_data, zone);
    }
}

double[2][] naca0012() {
    return wopwopd.airfoils.naca0012;
}

auto generate_simple_constant_blade_geom(double[2][] airfoil_xsection, double[] radial_stations, double[] twist, double radius, double[] chord, double[] thickness, double[] y) {
    auto geo_data = wopwopd.generate_simple_constant_blade_geom(airfoil_xsection, radial_stations, twist, radius, chord, thickness, y);
    return new GeometryData(geo_data);
}

int DataAlignment_node_centered() {
    return wopwopd.DataAlignment.node_centered;
}

int DataAlignment_face_centered() {
    return wopwopd.DataAlignment.face_centered;
}

void python_geometry_function_wraps() {
    def!create_geometry_file;
    def!append_geometry_data;
    def!naca0012;
    def!generate_simple_constant_blade_geom;
    def!DataAlignment_node_centered;
    def!DataAlignment_face_centered;
    def!(wopwopd.close_geometry_file);

    def!AperiodicUnstructuredGeometryFile;
    def!PeriodicUnstructuredGeometryFile;
    def!ConstantUnstructuredGeometryFile;
    def!ConstantStructuredGeometryFile;

    def!ConstantGeometryData;
    def!NonconstantGeometryData;
}

void python_geometry_class_wraps() {

    wrap_class!(
        GeometryFile,
        Init!(string, string, wopwopd.DataAlignment, wopwopd.ConstantStructuredGeometryHeader[]),
        Init!(string, string, wopwopd.DataAlignment, wopwopd.ConstantUnstructuredGeometryHeader[]),
        Init!(string, string, wopwopd.DataAlignment, wopwopd.PeriodicUnstructuredGeometryHeader[]),
        Init!(string, string, wopwopd.DataAlignment, wopwopd.AperiodicUnstructuredGeometryHeader[])
    );

    wrap_struct!(
        wopwopd.AperiodicUnstructuredGeometryHeader,
        Init!(string, int, int, int, int[])
    );

    wrap_struct!(
        wopwopd.PeriodicUnstructuredGeometryHeader,
        Init!(string, float, int, int, int, int[])
    );

    wrap_struct!(
        wopwopd.ConstantUnstructuredGeometryHeader,
        Init!(string, int, int, int[])
    );

    wrap_struct!(
        wopwopd.ConstantStructuredGeometryHeader,
        Init!(string, int, int)
    );

    wrap_struct!(
        wopwopd.GeometryFileHandle
    );

    wrap_class!(
        GeometryData,
        Init!(size_t),
        Def!(GeometryData.get_x_nodes),
        Def!(GeometryData.get_y_nodes),
        Def!(GeometryData.get_z_nodes),
        Def!(GeometryData.set_x_nodes),
        Def!(GeometryData.set_y_nodes),
        Def!(GeometryData.set_z_nodes),
        Def!(GeometryData.get_x_normals),
        Def!(GeometryData.get_y_normals),
        Def!(GeometryData.get_z_normals),
        Def!(GeometryData.set_x_normals),
        Def!(GeometryData.set_y_normals),
        Def!(GeometryData.set_z_normals)
    );
}

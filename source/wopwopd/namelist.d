module wopwopd.namelist;

import std.conv;
import std.stdio;
import std.traits;
import std.typecons;

import numd.linearalgebra.matrix;

alias FVec3 = Vector!(3, float);

alias OptionalVec = Nullable!FVec3;
alias OptionalFloat = Nullable!float;
alias OptionalFloatArray = Nullable!(float[]);
alias OptionalSize = Nullable!size_t;
alias OptionalString = Nullable!string;
alias OptionalBool = Nullable!bool;

struct Casename {
	OptionalString globalFolderName;
	OptionalString caseNameFile;
}

struct CaseList {
	Casename[] cases;
}

struct Namelist {
	EnvironmentIn environment_in;
	EnvironmentConstants environment_constants;
	ObserverIn[] observers;
	ContainerIn[] containers;
}

struct EnvironmentIn {
	private OptionalSize nbObserverContainers;
	private OptionalSize nbSourceContainers;
	OptionalString pressureFolderName;
	OptionalString SPLFolderName;
	OptionalString sigmaFolderName;
	OptionalSize debugLevel;
	OptionalBool ASCIIOutputFlag;
	OptionalBool OASPLdBFlag;
	OptionalBool OASPLdBAFlag;
	OptionalBool spectrumFlag;
	OptionalBool SPLdBFlag;
	OptionalBool SPLdBAFlag;
	OptionalBool pressureGradient1AFlag;
	OptionalBool acousticPressureFlag;
	OptionalBool thicknessNoiseFlag;
	OptionalBool loadingNoiseFlag;
	OptionalBool totalNoiseFlag;
	OptionalBool sigmaFlag;
	OptionalBool loadingSigmaFlag;
	OptionalBool machSigmaFlag;
	OptionalBool normalSigmaFlag;
}

struct EnvironmentConstants {
	OptionalFloat rho;
	OptionalFloat c;
	OptionalFloat gamma;
	OptionalFloat mu;
	OptionalFloat nu;
	OptionalFloat P_ref;
	OptionalFloat RelHumidity;
	OptionalFloat gasConstant;
}

struct ObserverIn {
	OptionalString Title;
	OptionalSize nt;
	OptionalFloat tMin;
	OptionalFloat tMax;
	OptionalSize nbBase;
	OptionalString attachedTo;
	OptionalSize nbBaseObsContFrame;
	OptionalSize nbBaseLocalFrame;
	OptionalString fileName;
	OptionalFloat xLoc;
	OptionalFloat yLoc;
	OptionalFloat zLoc;
	CB[] cobs;
}

struct ContainerIn {
	OptionalString Title;
	private OptionalSize nbContainer;
	OptionalFloat dTau;
	OptionalSize nTau;
	OptionalFloat tauMin;
	OptionalFloat tauMax;
	OptionalString patchGeometryFile;
	OptionalString patchLoadingFile;
	private OptionalSize nbBase;
	ContainerIn[] children;
	CB[] cobs;
}

enum AxisType : string {
	time_independent = "TimeIndependent",
	non_periodic = "NonPeriodic"
}

enum TranslationType : string {
	time_independent = "TimeIndependent",
	known_function = "KnownFunction",
	non_periodic = "NonPeriodic"
}

enum AngleType : string {
	time_independent = "TimeIndependent",
	known_function = "KnownFunction",
	periodic = "Periodic",
	non_periodic = "NonPeriodic"
}

alias OptionalAxisType = Nullable!AxisType;
alias OptionalTranslationType = Nullable!TranslationType;
alias OptionalAngleType = Nullable!AngleType;

struct CB {
	OptionalString Title;
	OptionalBool Rotation;
	OptionalBool Windframe;
	OptionalSize iB;
	OptionalAxisType AxisType;
	OptionalTranslationType TranslationType;
	OptionalAngleType AngleType;
	OptionalVec AH;
	OptionalVec VH;
	OptionalVec Y0;
	OptionalFloat Omega;
	OptionalFloat Psi0;
	OptionalFloat A0;
	OptionalFloat A1;
	OptionalFloat A2;
	OptionalFloat B1;
	OptionalFloat B2;
	OptionalFloatArray A;
	OptionalFloatArray B;
	OptionalString Filename;
	OptionalVec AxisValue;
	OptionalVec TranslationValue;
	OptionalFloat AngleValue;
	OptionalBool flightPath;
	OptionalString flightPathAccel;
	OptionalSize nbWayPoints;
}


void write_namelist_struct(F, S)(auto ref F file, auto ref S s) {
	alias field_types = Fields!S;

	//pragma(msg, S.stringof, ":");

	file.writeln("&", S.stringof);

	static foreach(m_idx, member; FieldNameTuple!S) {{
		static if((member == "cobs") || (member == "children")) {
			alias SaveType = field_types[m_idx];
			SaveType value;
			bool skip = true;
		} else static if(isInstanceOf!(Nullable, field_types[m_idx])) {
			alias _SaveType = Unqual!(ReturnType!(field_types[m_idx].get));
			
			static if(is(_SaveType == enum)) {
				alias SaveType = OriginalType!_SaveType;
			} else static if(isArray!_SaveType && !is(_SaveType : string)) {
				alias SaveType = Unqual!(ForeachType!_SaveType)[];
			} else {
				alias SaveType = _SaveType;
			}
			bool skip = true;
			SaveType value;
			mixin("auto nullable_value = s."~member~";");
			if(!nullable_value.isNull) {
				value = nullable_value.get;
				skip = false;
			}
		} else {
			alias SaveType = field_types[m_idx];
			bool skip = false;
			mixin("auto value = s."~member~";");
		}

		if(!skip) {
			static if(is(bool == SaveType)) {
				file.writeln("\t", member, " = .", value.to!string, ".");
			} else static if(is(string == SaveType)) {
				file.writeln("\t", member, " = \'", value, "\'");
			} else {
				static if(isArray!SaveType || is(SaveType == FVec3)) {
					import std.algorithm : map;
					import std.array : join;
					file.writeln("\t", member, " = ", value[0], value[1..$].map!(a => ", "~a.to!string).join);
				} else {
					file.writeln("\t", member, " = ", value.to!string);
				}
				
			}
		}
	}}

	file.writeln("/");
}

void write_caselist(ref CaseList case_list, string directory) {
	import std.path : buildPath;
	auto filename = directory.buildPath("cases.nam");
	auto file = File(filename, "w");
	foreach(ref c; case_list.cases) {
		file.write_namelist_struct(c);
	}
}

void write_namelist(ref Namelist namelist, string filename) {
	auto file = File(filename, "w");
	file._write_namelist(namelist);
}

private void _write_containers(F)(auto ref F file, ContainerIn[] containers) {
	foreach(container; containers) {
		if(container.cobs.length != 0) container.nbBase = container.cobs.length;
		if(container.children.length != 0) container.nbContainer = container.children.length;
		file.write_namelist_struct(container);
		foreach(ref cob; container.cobs) {
			file.write_namelist_struct(cob);
		}
		file._write_containers(container.children);
	}
}

private void _write_namelist(F)(auto ref F file, ref Namelist namelist) {
	if(namelist.containers.length != 0) namelist.environment_in.nbSourceContainers = namelist.containers.length;
	if(namelist.observers.length != 0) namelist.environment_in.nbObserverContainers = namelist.observers.length;
	file.write_namelist_struct(namelist.environment_in);
	file.write_namelist_struct(namelist.environment_constants);
	foreach(observer; namelist.observers) {
		if(observer.cobs.length != 0) observer.nbBase = observer.cobs.length;
		file.write_namelist_struct(observer);
		foreach(ref cob; observer.cobs) {
			file.write_namelist_struct(cob);
		}
	}
	file._write_containers(namelist.containers);
}

unittest {
	struct StringBuff {
		string buff;

		void writeln(Args...)(auto ref Args args) {
			write(args, "\n");
		}

		void write(Args...)(auto ref Args args) {
			import std.conv : to;
			static foreach(idx, arg; args) {
				static if(is(typeof(arg) : string)) {
					buff ~= arg;
				} else {
					buff ~= arg.to!string;
				}
			}
		}
	}

	Namelist namelist = {
		environment_in: {
			pressureFolderName: "/",
			SPLFolderName: "/",
			sigmaFolderName: "/",
			debugLevel: 13,
			ASCIIOutputFlag: true,
			OASPLdBFlag: true,
			OASPLdBAFlag: true,
			spectrumFlag: true,
			SPLdBFlag: true,
			SPLdBAFlag: true,
			pressureGradient1AFlag: true,
			acousticPressureFlag: true,
			thicknessNoiseFlag: true,
			loadingNoiseFlag: true,
			totalNoiseFlag: true
		},
		environment_constants: {
			rho: 1.2,
			c: 343,
			nu: 1.8e-5
		},
		observers: [
			{
				Title: "Mic",
				nt: 1,
				xLoc: 0,
				yLoc: 0,
				zLoc: 0
			}
		],
		containers: [
			{
				Title: "Main Rotor",
				dTau: 1,
				nTau: 1,
				tauMax: 1 - 1,
				cobs: [
					{
						Title: "Rotation",
						AxisType: AxisType.time_independent,
						AngleType: AngleType.known_function,
						AxisValue: FVec3(0, 0, 1),
						Omega: 20
					}
				],
				children: [
					{
						Title: "blade 1 container",
						patchGeometryFile: "geom_file_1.dat",
						patchLoadingFile: "loading_file_1.dat",
						cobs: [
							{
								Title: "blade pitch offset",
								AxisType: AxisType.time_independent,
								AngleType: AngleType.time_independent,
								AxisValue: FVec3(0, 1, 0),
								AngleValue: 0.2
							},
							{
								Title: "blade angle offset",
								AxisType: AxisType.time_independent,
								AngleType: AngleType.time_independent,
								AxisValue: FVec3(0, 0, 1),
								AngleValue: 0
							}
						]
					},
					{
						Title: "blade 2 container",
						patchGeometryFile: "geom_file_2.dat",
						patchLoadingFile: "loading_file_2.dat",
						cobs: [
							{
								Title: "blade pitch offset",
								AxisType: AxisType.time_independent,
								AngleType: AngleType.time_independent,
								AxisValue: FVec3(0, 1, 0),
								AngleValue: 0.2
							},
							{
								Title: "blade angle offset",
								AxisType: AxisType.time_independent,
								AngleType: AngleType.time_independent,
								AxisValue: FVec3(0, 0, 1),
								AngleValue: 1.56
							}
						]
					}
				]
			}
		]
	};

	StringBuff file;

	file._write_namelist(namelist);
	import std.stdio : writeln;
	// writeln(file.buff);
}

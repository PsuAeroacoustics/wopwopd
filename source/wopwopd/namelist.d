module wopwopd.namelist;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import std.traits;
import std.typecons;
import std.uni;

import numd.linearalgebra.matrix;

alias FVec3 = Vector!(3, float);

alias OptionalVec = Nullable!FVec3;
alias OptionalFloat = Nullable!float;
alias OptionalFloatArray = Nullable!(float[]);
alias OptionalSize = Nullable!size_t;
alias OptionalString = Nullable!string;
alias OptionalBool = Nullable!bool;


enum BlockType {
	EnvironmentIn,
	EnvironmentConstants,
	ObserverIn,
	ContainerIn,
	CB,
	BPMIn,
	RangeIn,
	Unknown
}

private BlockType parse_block_type(S)(S str) {
	switch(str.toLower) {
		case "&environmentin":
			return BlockType.EnvironmentIn;
		case "&environmentconstants":
			return BlockType.EnvironmentConstants;
		case "&observerin":
			return BlockType.ObserverIn;
		case "&containerin":
			return BlockType.ContainerIn;
		case "&cb":
			return BlockType.CB;
		case "&rangein":
			return BlockType.RangeIn;
		case "&bpmin":
			return BlockType.BPMIn;
		default:
			return BlockType.Unknown;
	}
}

enum AverageSide : string {
	center = "center"
}

alias OptionalAverageSide = Nullable!AverageSide;

enum WindowFunction : string {
	hanning_window = "Hanning Window",
	blackman_window = "Blackman Window",
	flatTop_window = "Flat Top Window",
	hamming_window = "Hamming Window"
}

alias OptionalWindowFunction = Nullable!WindowFunction;

struct Casename {
	OptionalString globalFolderName;
	OptionalString caseNameFile;
	Namelist namelist;
}

struct CaseList {
	Casename[] cases;
}

struct Namelist {
	EnvironmentIn environment_in;
	EnvironmentConstants environment_constants;
	ObserverIn[] observers;
	ContainerIn[] containers;

	bool opEquals(const Namelist other) const {
		bool result = true;

		result &= environment_in == other.environment_in;
		result &= environment_constants == other.environment_constants;

		result &= observers.length == other.observers.length;
		if(result) {
			foreach(idx, observer; observers) {
				result &= observer == other.observers[idx];
			}
		}

		result &= containers.length == other.containers.length;
		if(result) {
			foreach(idx, container; containers) {
				result &= container == other.containers[idx];
			}
		}

		return result;
	}
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
	OptionalBool loadingNoiseSigmaFlag;
	OptionalBool thicknessNoiseSigmaFlag;
	OptionalBool totalNoiseSigmaFlag;
	OptionalBool normalSigmaFlag;
	OptionalBool machSigmaFlag;
	OptionalBool observerSigmaFlag;
	OptionalBool velocitySigmaFlag;
	OptionalBool accelerationSigmaFlag;
	OptionalBool densitySigmaFlag;
	OptionalBool momentumSigmaFlag;
	OptionalBool pressureSigmaFlag;
	OptionalBool loadingSigmaFlag;
	OptionalBool areaSigmaFlag;
	OptionalBool MdotrSigmaFlag;
	OptionalBool iblankSigmaFlag;
	OptionalBool broadbandFlag;

	bool opEquals(const EnvironmentIn other) const {
		bool result = true;

		static foreach(member; FieldNameTuple!EnvironmentIn) {{
			mixin("auto this_m  = "~member~";");
			mixin("auto other_m  = other."~member~";");

			if(!this_m.isNull && !other_m.isNull) {
				result &= this_m.get == other_m.get;
			} else if(this_m.isNull != other_m.isNull) {
				result &= false;
			} else {
				result &= true;
			}
		}}

		return result;
	}
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

	bool opEquals(const EnvironmentConstants other) const {
		bool result = true;

		static foreach(member; FieldNameTuple!EnvironmentConstants) {{
			mixin("auto this_m  = "~member~";");
			mixin("auto other_m  = other."~member~";");

			if(!this_m.isNull && !other_m.isNull) {
				result &= this_m.get == other_m.get;
			} else if(this_m.isNull != other_m.isNull) {
				result &= false;
			} else {
				result &= true;
			}
		}}

		return result;
	}
}

struct ObserverIn {
	OptionalString Title;
	OptionalSize nt;
	OptionalFloat tMin;
	OptionalFloat tMax;
	private OptionalSize nbBase;
	OptionalString attachedTo;
	OptionalSize nbBaseObsContFrame;
	OptionalSize nbBaseLocalFrame;
	OptionalString fileName;
	OptionalFloat segmentSize;
	OptionalFloat segmentStepSize;
	OptionalFloat percentOverlap;
	OptionalSize numAverages;
	OptionalAverageSide averageSide;
	OptionalSize nbHarmonics;
	OptionalWindowFunction windowFunction;
	OptionalBool CorrFlag;
	OptionalSize segmentIncrement;
	OptionalSize nbNewSegments;
	OptionalSize maxObsTimeExpansions;
	private OptionalSize nbFreqRanges;
	OptionalFloat highPassFrequency;
	OptionalFloat lowPassFrequency;
	OptionalBool octaveFlag;
	OptionalFloat octaveNumber;
	OptionalBool octaveApproxFlag;
	OptionalBool AtmAtten;
	OptionalFloat xLoc;
	OptionalFloat yLoc;
	OptionalFloat zLoc;
	OptionalFloat radius;
	OptionalSize nbTheta;
	OptionalSize nbPsi;
	OptionalFloat thetaMin;
	OptionalFloat thetaMax;
	OptionalFloat psiMin;
	OptionalFloat psiMax;
	OptionalBool indexSwap;

	OptionalSize nbx;
	OptionalSize nby;
	OptionalSize nbz;
	OptionalFloat xMin;
	OptionalFloat xMax;
	OptionalFloat yMin;
	OptionalFloat yMax;
	OptionalFloat zMin;
	OptionalFloat zMax;

	CB[] cobs;
	RangeIn[] ranges;

	bool opEquals(const ObserverIn other) const {
		bool result = true;

		static foreach(member; FieldNameTuple!ObserverIn) {{
			static if(member == "cobs") {
				result &= cobs.length == other.cobs.length;
				if(result) {
					foreach(idx, cob; cobs) {
						result &= cob == other.cobs[idx];
					}
				}
			} else static if(member == "ranges") {
				result &= ranges.length == other.ranges.length;
				if(result) {
					foreach(idx, range; ranges) {
						result &= range == other.ranges[idx];
					}
				}
			} else static if(member != "nbBase") {
				mixin("auto this_m  = "~member~";");
				mixin("auto other_m  = other."~member~";");

				if(!this_m.isNull && !other_m.isNull) {
					result &= this_m.get == other_m.get;
				} else if(this_m.isNull != other_m.isNull) {
					result &= false;
				} else {
					result &= true;
				}
			}
		}}

		return result;
	}
}

struct RangeIn {
	OptionalString Title;
	OptionalFloat minFrequency;
	OptionalFloat maxFrequency;
	
	bool opEquals(const RangeIn other) const {
		bool result = true;

		static foreach(member; FieldNameTuple!RangeIn) {{
			mixin("auto this_m  = "~member~";");
			mixin("auto other_m  = other."~member~";");

			if(!this_m.isNull && !other_m.isNull) {
				result &= this_m.get == other_m.get;
			} else if(this_m.isNull != other_m.isNull) {
				result &= false;
			} else {
				result &= true;
			}
		}}

		return result;
	}
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
	OptionalBool PeggNoiseFlag;
	OptionalBool BPMNoiseFlag;
	private OptionalSize nbBase;
	ContainerIn[] children;
	CB[] cobs;
	OptionalBPMIn bpm_in;

	bool opEquals(const ContainerIn other) const {
		bool result = true;

		static foreach(member; FieldNameTuple!ContainerIn) {{
			static if(member == "cobs") {
				result &= cobs.length == other.cobs.length;
				if(result) {
					foreach(idx, cob; cobs) {
						result &= cob == other.cobs[idx];
					}
				}
			} else static if(member == "children") {
				result &= children.length == other.children.length;
				if(result) {
					foreach(idx, child; children) {
						result &= child == other.children[idx];
					}
				}
			} else static if(member != "nbBase" && member != "nbContainer") {
				mixin("auto this_m  = "~member~";");
				mixin("auto other_m  = other."~member~";");

				if(!this_m.isNull && !other_m.isNull) {
					result &= this_m.get == other_m.get;
					//writeln(member~": ", this_m.get == other_m.get);
				} else if(this_m.isNull != other_m.isNull) {
					result &= false;
					writeln("ContainerIn: ", member, " null mismatch. ", this_m, ", ", other_m);
				} else {
					result &= true;
				}
			}
		}}

		return result;
	}
}

struct BPMIn {
	OptionalString BPMNoiseFile;
	OptionalSize nSect;
	OptionalUniformType uniformBlade;
	OptionalTripType BLtrip;
	OptionalBPMFlagType sectChordFlag;
	OptionalFloatArray sectChord;
	OptionalBPMFlagType sectLengthFlag;
	OptionalFloatArray sectLength;
	OptionalBPMFlagType TEThicknessFlag;
	OptionalFloat TEThickness;
	OptionalBPMFlagType TEflowAngleFlag;
	OptionalFloatArray TEflowAngle;
	OptionalBPMFlagType TipLCSFlag;
	OptionalFloat TipLCS;
	OptionalBPMFlagType SectAOAFlag;
	OptionalFloatArray SectAOA;
	OptionalBPMFlagType UFlag;
	OptionalFloatArray U;
	OptionalBool LBLVSnoise;
	OptionalBool TBLTEnoise;
	OptionalBool bluntNoise;
	OptionalBool bladeTipNoise;
	OptionalBool DirectivityFlag;
}

alias OptionalBPMIn = Nullable!BPMIn;

enum TripType : int {
	no_trip = 0,
	soft_trip = 1,
	hard_trip = 2
}

enum UniformType : int {
	nonuniform = 0,
	uniform = 1
}

enum BPMFlagType : string {
	compute = "Compute",
	user_value = "UserValue",
	file_value = "FileValue"
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

private T parse_enum_value(T)(string str) {
	final switch(str.toLower) {
		static foreach(member; EnumMembers!T) {
			case member.toLower:
				mixin("return T."~member.to!string~";");
		}
	}
}

alias OptionalTripType = Nullable!TripType;
alias OptionalUniformType = Nullable!UniformType;
alias OptionalBPMFlagType = Nullable!BPMFlagType;
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

	bool opEquals(const CB other) const {
		bool result = true;

		static foreach(member; FieldNameTuple!CB) {{
			mixin("auto this_m  = "~member~";");
			mixin("auto other_m  = other."~member~";");

			if(!this_m.isNull && !other_m.isNull) {
				result &= this_m.get == other_m.get;
				//writeln(member~": ", this_m.get == other_m.get);
			} else if(this_m.isNull != other_m.isNull) {
				result &= false;
				writeln("CB: ", member, " null mismatch. ", this_m, ", ", other_m);
			} else {
				result &= true;
			}
		}}

		return result;
	}
}


void write_namelist_struct(F, S)(auto ref F file, auto ref S s) {
	alias field_types = Fields!S;

	//pragma(msg, S.stringof, ":");

	file.writeln("&", S.stringof);

	static foreach(m_idx, member; FieldNameTuple!S) {{
		static if((member == "cobs") || (member == "children") || (member == "ranges") || (member == "namelist") || (member == "bpm_in")) {
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
	write_caselist_custom_name(case_list, directory, "cases.nam");
}

void write_caselist_custom_name(ref CaseList case_list, string directory, string caselist_filename) {
	import std.path : buildPath;
	auto filename = directory.buildPath(caselist_filename);
	auto file = File(filename, "w");
	foreach(ref c; case_list.cases) {
		file.write_namelist_struct(c);
	}
}

void write_namelist(ref Namelist namelist, string filename) {
	auto file = File(filename, "w");
	file.write_namelist_impl(namelist);
}

private void _write_containers(F)(auto ref F file, ContainerIn[] containers) {
	foreach(container; containers) {
		if(container.cobs.length != 0) container.nbBase = container.cobs.length;
		if(container.children.length != 0) container.nbContainer = container.children.length;
		file.write_namelist_struct(container);
		foreach(ref cob; container.cobs) {
			file.write_namelist_struct(cob);
		}
		if(!container.BPMNoiseFlag.isNull && container.BPMNoiseFlag.get()) {
			enforce(!container.bpm_in.isNull, "BPMNoiseFlag is set but BPMIn namelist is not set");
			file.write_namelist_struct(container.bpm_in.get);
		}

		file._write_containers(container.children);
	}
}

private void write_namelist_impl(F)(auto ref F file, ref Namelist namelist) {
	if(namelist.containers.length != 0) namelist.environment_in.nbSourceContainers = namelist.containers.length;
	if(namelist.observers.length != 0) namelist.environment_in.nbObserverContainers = namelist.observers.length;
	file.write_namelist_struct(namelist.environment_in);
	file.write_namelist_struct(namelist.environment_constants);
	foreach(observer; namelist.observers) {
		if(observer.cobs.length != 0) observer.nbBase = observer.cobs.length;
		if(observer.ranges.length != 0) observer.nbFreqRanges = observer.ranges.length;
		file.write_namelist_struct(observer);
		foreach(ref cob; observer.cobs) {
			file.write_namelist_struct(cob);
		}
		foreach(ref range; observer.ranges) {
			file.write_namelist_struct(range);
		}
	}
	file._write_containers(namelist.containers);
}

private Type parse_section(Type)(string[] section_string) {
	Type section;
	foreach(ref var_str; section_string) {
		//writeln("var_str: ", var_str);
		if(var_str == "") continue;
		auto split_str = var_str.split("=");
		auto var_name = split_str[0].strip;
		auto var_value = split_str[$-1].strip.strip('\'').strip('\"');

		outer: switch(var_name.toLower) {
			static foreach(field; FieldNameTuple!(Type)) {
				static if(field != "cobs" && field != "children" && field != "ranges" && field != "bpm_in") {
					case field.toLower:
						mixin("alias _R = Unqual!(ReturnType!(Type."~field~".get));");
						static if(isArray!_R && !is(_R == AxisType) && !is(_R == AngleType) && !is(_R == TranslationType) && !is(_R == WindowFunction) && !is(_R == AverageSide) && !is(_R == BPMFlagType)) {
							alias R = Unqual!(ForeachType!_R)[];
						} else {
							alias R = _R;
						}

						static if(is(R == bool)) {
							mixin("section."~field~" = var_value.strip(\".\").to!R;");
						} else static if(is(R == FVec3)) {
							auto reformated_vec = 
								var_value
								.splitWhen!((a, b) => a.isWhite || a == ',')
								.map!(a => a.to!string.strip)
								.filter!(a => a != "")
								.map!(a => a.strip(","))
								.map!(a => a.to!float)
								.staticArray!(float[3]);

							mixin("section."~field~" = FVec3(reformated_vec);");
						} else static if(is(R == AxisType) || is(R == TranslationType) || is(R == AngleType) || is(R == WindowFunction) || is(R == AverageSide) || is(_R == BPMFlagType)) {
							mixin("section."~field~" = var_value.parse_enum_value!R;");
						} else static if(is(R == TripType) || is(R == UniformType)) {
							mixin("section."~field~" = var_value.to!int.to!R;");
						} else static if(isArray!R && !is(R: string) && !is(R: char[])) {
							mixin("section."~field~" = (\"[\"~var_value~\"]\").to!R;");
						} else {
							mixin("section."~field~" = var_value.to!R;");
						}

						break outer;
				}
			}
			default:
				writeln("WARNING: Skipping unknown field ", var_name, " parsing ", Type.stringof);
		}
	}

	return section;
}

private ObserverIn parse_observerin_namelist(R)(auto ref R range) {
	ObserverIn t;

	auto observer_block = range.front;
	range.popFront;

	enforce(parse_block_type(observer_block.front) == BlockType.ObserverIn, "Expected ObserverIn namelist");
	observer_block.popFront;

	t = parse_section!ObserverIn(observer_block);

	while(!range.empty && !range.front.empty && parse_block_type(range.front.front) == BlockType.CB) {
		auto cb_block = range.front;
		range.popFront;

		enforce(parse_block_type(cb_block.front) == BlockType.CB, "Expected CB namelist");
		cb_block.popFront;
		t.cobs ~= parse_section!CB(cb_block);
	}

	while(!range.empty && !range.front.empty && parse_block_type(range.front.front) == BlockType.RangeIn) {
		auto range_block = range.front;
		range.popFront;

		enforce(parse_block_type(range_block.front) == BlockType.RangeIn, "Expected RangeIn namelist");
		range_block.popFront;
		t.ranges ~= parse_section!RangeIn(range_block);
	}

	// Skip ObserverIn sub namelists that we do not support
	while(!range.empty && !range.front.empty && parse_block_type(range.front.front) == BlockType.Unknown) {
		writeln("WARNING: Skipping un-supported ", range.front.front, " namelist");
		range.popFront;
	}

	return t;
}

private ContainerIn parse_containerin_namelist(R)(auto ref R range) {
	ContainerIn t;

	auto container_block = range.front;
	range.popFront;

	auto block_type = parse_block_type(container_block.front);
	enforce(block_type == BlockType.ContainerIn, "Expected ContainerIn namelist. Instead got "~block_type.to!string);

	container_block.popFront;

	t = parse_section!ContainerIn(container_block);

	if(!t.nbBase.isNull) {
		foreach(cb_idx; 0..t.nbBase.get) {
			auto cb_block = range.front;
			range.popFront;

			enforce(parse_block_type(cb_block.front) == BlockType.CB, "Expected CB namelist");
			cb_block.popFront;
			t.cobs ~= parse_section!CB(cb_block);
		}
	}

	if(!t.PeggNoiseFlag.isNull) {
		// Just eject these sections into the sun if they exist.
		range.popFront;
	}

	if(!t.BPMNoiseFlag.isNull && t.BPMNoiseFlag.get) {
		auto bpm_block = range.front;
		range.popFront;

		enforce(parse_block_type(bpm_block.front) == BlockType.BPMIn, "Expected BPMIn namelist");
		bpm_block.popFront;
		t.bpm_in = parse_section!BPMIn(bpm_block);
	}

	if(!t.nbContainer.isNull) {
		foreach(cb_idx; 0..t.nbContainer.get) {
			t.children ~= parse_containerin_namelist(range);
		}
	}

	return t;
}

Namelist parse_namelist(string filename) {
	auto file = readText(filename);

	return parse_namelist_impl(file);
}

private Namelist parse_namelist_impl(F)(auto ref F file) {

	// Normalize line endings from windows to unix.
	// If it does not have windows line endings,
	// this is a no-op
	file = file.replace("\r\n", "\n");

	auto namelist_blocks =
		file
		.split("/\n")
		.filter!(a => a != "")
		.map!((a) {
			return 
				a
				.split('\n')
				.filter!(a => !a.startsWith("!!!")) // Remove whole line comments.
				.map!(s => s.strip)
				.filter!(s => s != "")
				.map!(s => s.split("!")[0]) // Remove inline comments.
				.array;
		})
		.filter!(a => !a.empty);

	Namelist namelist;

	if(!namelist_blocks.empty) {
		auto environment_block = namelist_blocks.front;
		namelist_blocks.popFront;

		enforce(parse_block_type(environment_block.front) == BlockType.EnvironmentIn, "EnvironmentIn namelist expected");
		environment_block.popFront;
		namelist.environment_in = parse_section!EnvironmentIn(environment_block);
	}

	if(!namelist_blocks.empty) {
		auto constants_block = namelist_blocks.front;
		namelist_blocks.popFront;

		enforce(parse_block_type(constants_block.front) == BlockType.EnvironmentConstants, "EnvironmentConstants namelist expected");
		constants_block.popFront;
		namelist.environment_constants = parse_section!EnvironmentConstants(constants_block);
	}

	while(!namelist_blocks.empty && !namelist_blocks.front.empty && parse_block_type(namelist_blocks.front.front) == BlockType.ObserverIn) {
		namelist.observers ~= parse_observerin_namelist(namelist_blocks);
	}

	// Fast forward to containers as we don't support walls n' such
	while(!namelist_blocks.empty && !namelist_blocks.front.empty && parse_block_type(namelist_blocks.front.front) != BlockType.ContainerIn) {
		namelist_blocks.popFront;
	}

	while(!namelist_blocks.empty && !namelist_blocks.front.empty && parse_block_type(namelist_blocks.front.front) == BlockType.ContainerIn) {
		namelist.containers ~= parse_containerin_namelist(namelist_blocks);
	}

	return namelist;
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

		string read() {
			return buff;
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

	write_namelist_impl(file, namelist);

	auto read_namlist = parse_namelist_impl(file.read);
	enforce(read_namlist == namelist);

	auto read_namlist_with_comments = parse_namelist("test_namelist.nam");
	enforce(read_namlist_with_comments == namelist);

	auto demi_test_namelist = parse_namelist("nmlst_hemi_Pegg.nam");

}

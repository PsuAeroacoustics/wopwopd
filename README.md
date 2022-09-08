# wopwopd

wopwopd is a library for easily creating the input files required for wopwop3. This includes patch files, loading files, and namelists. It also has some facilities for parsing the output files for further manipulation or plotting.

## Dependencies

wopwopd has a couple of dependencies that need to be setup and installed first. Some of these are provided as git submodules and are largely transparent to the user. If you are cloning a fresh repository run:

```
	git clone --recurse-submodules https://github.com/PsuAeroacoustics/wopwopd
```

If the repository is already cloned, but submodules were not cloned, run the following command to acquire the submodules:

```
	git submodule update --init
```

Setting up the remaining dependencies is described below.

### Required Dependencies

- The LLVM D Compiler (ldc) v1.26 or later (https://github.com/ldc-developers/ldc)

**Linux (Ubuntu)**

LDC can be installed through the Ubuntu package manager 

```
	sudo apt install ldc
```

If the appropriate version of ldc is not available in your distributions package manager, pre-compiled binaries can be obtained from there github releases page (https://github.com/ldc-developers/ldc/releases)

**macOS**

Homebrew can be used to install ldc on macOS:

```
	brew install ldc
```

## Building


Once all the dependencies have been installed, run the following command to build the library:
```
	dub build -c library -b release --compiler=ldc2
```

This command builds the library as a portable release build using the ldc compiler. There are a number of different configurations and build types that can be used.

### Build Types (`-b`)

There are number of supported build modes listed below. Note that the build types for AVX usage will not impact the performance of this library significantly and are more a holdover from other projects where they do have a significant impact.

| Configuration                      | Description                                    |
|------------------------------------|------------------------------------------------|
| `debug`                              | Basic debug mode, no optimizations.            |
| `release`                            | Portable release build. Non-CPU specific optimizations enabled |
| `release-native`                     | Native release build. Optimizes for host CPU   |
| `release-native-512`                 | Native release build. Optimizes for host CPU, Encourages use of AVX512 instructions, suppressing compiler instruction heuristics |
| `release-generic-avx`                | Portable release mode with AVX enabled         |
| `release-generic-avx2`               | Portable release mode with AVX2 enabled        |
| `release-generic-avx512f`            | Portable release mode with AVX512F enabled     |

### Configurations (`-c`)

| Build Type                    | Description                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| `library`                       | Builds the dynamic library for use with other D code. No python wrappers included |
| `library-python<version>`       | Builds the dynamic library for use with other D code. Python wrappers are built for the specific version of python. <version> can be any of 37,39,310 |


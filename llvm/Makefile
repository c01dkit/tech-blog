LLVM_BUILD := ~/llvm-project-15.0.7.src/build

# Rule to build the project
build_project:
	mkdir -p build \
		&& cd build \
		&& PATH=${LLVM_BUILD}/bin:${PATH} \
			CC=clang CXX=clang++ \
			cmake ../src \
				-DCMAKE_BUILD_TYPE=Release \
				-DLLVM_ENABLE_ASSERTIONS=ON \
				-DCMAKE_CXX_FLAGS_RELEASE="-std=c++17 -fno-rtti -fpic -g" \
		&& make

# Rule to clean the build directory
clean_project:
	rm -rf build

# Default target
all: project

# Clean target
clean: clean_project

# Project target depends on build_project
project: clean_project build_project
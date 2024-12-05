cmake_minimum_required(VERSION 3.13)
project(IPA)

find_package(LLVM REQUIRED CONFIG)
# list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
include_directories(${LLVM_INCLUDE_DIRS})
# add_definitions(${LLVM_DEFINITIONS})

set(project
    main.cpp
    PrintFunctionArgsPass.cpp
    PrintFunctionArgsPass.hpp
    PrintFunctionNamesPass.cpp
    PrintFunctionNamesPass.hpp
)
add_executable(ipa ${project})

target_link_libraries(
    ipa
    LLVMCore
    LLVMSupport
    LLVMIRReader
    LLVMAnalysis
)
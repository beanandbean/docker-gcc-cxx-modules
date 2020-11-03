cmake_minimum_required(VERSION 3.14)
project(cxx_modules_example CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(modules)

add_subdirectory(text)
add_subdirectory(lang)
add_subdirectory(all_mods)

add_executable(hello main.cpp)
cxx_module_dependencies(hello all_mods)
cxx_module_compile_options(hello)

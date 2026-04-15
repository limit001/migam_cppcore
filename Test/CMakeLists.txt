cmake_minimum_required(VERSION 3.1)
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/TestHarness.cmake")

add_library(cppcore_gtest STATIC ../Inc/gtest-all.cc)
target_include_directories(cppcore_gtest PUBLIC "${CMAKE_SOURCE_DIR}/Inc")

add_library(cppcore_gtest_main STATIC ../Inc/gtest_main.cc)
target_include_directories(cppcore_gtest_main PUBLIC "${CMAKE_SOURCE_DIR}/Inc")
target_link_libraries(cppcore_gtest_main PUBLIC cppcore_gtest)

if(MSVC)
	target_compile_options(cppcore_gtest PRIVATE
		/bigobj
		/wd4996
		$<$<CONFIG:Debug>:/MTd>
		$<$<NOT:$<CONFIG:Debug>>:/MT>
	)
	target_compile_options(cppcore_gtest_main PRIVATE
		/bigobj
		/wd4996
		$<$<CONFIG:Debug>:/MTd>
		$<$<NOT:$<CONFIG:Debug>>:/MT>
	)
endif()

option(CPPCORE_ENABLE_ENCODER_TESTS "Build the legacy encoder test suite" OFF)

add_subdirectory(StringTest)
add_subdirectory(CommonTest)
add_subdirectory(FormatterTest)
add_subdirectory(ServerTest)
add_subdirectory(DummyProcess)
add_subdirectory(DummyDynamicLibrary)
if(CPPCORE_ENABLE_ENCODER_TESTS)
	add_subdirectory(EncoderTest)
endif()
add_subdirectory(SystemTest)

get_property(cppcore_test_targets GLOBAL PROPERTY CPPCORE_TEST_TARGETS)
add_custom_target(check
	COMMAND ${CMAKE_CTEST_COMMAND} -C $<CONFIG> --output-on-failure
	DEPENDS ${cppcore_test_targets}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

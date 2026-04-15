function(cppcore_get_test_output_dir out_var)
	set(${out_var} "${CMAKE_SOURCE_DIR}/Build/Test" PARENT_SCOPE)
endfunction()

function(cppcore_get_runtime_libs out_var)
	if(MSVC)
		set(libs cppcore)
	elseif(APPLE)
		set(libs cppcore iconv)
	else()
		set(libs cppcore dl pthread rt)
	endif()

	set(${out_var} ${libs} PARENT_SCOPE)
endfunction()

function(cppcore_collect_test_sources out_var)
	file(GLOB_RECURSE sources *.cpp *.c)

	if(MSVC)
		file(GLOB_RECURSE excluded
			*_Mac.cpp
			*_Linux.cpp
			*_Linux_Mac.cpp
		)
	elseif(APPLE)
		file(GLOB_RECURSE excluded
			*_Win.cpp
			*_Linux.cpp
		)
	else()
		file(GLOB_RECURSE excluded
			*_Win.cpp
			*_Mac.cpp
		)
	endif()

	if(excluded)
		list(REMOVE_ITEM sources ${excluded})
	endif()

	set(${out_var} ${sources} PARENT_SCOPE)
endfunction()

function(cppcore_apply_test_target_defaults target_name)
	cppcore_get_test_output_dir(output_dir)

	target_include_directories(${target_name} PRIVATE "${CMAKE_SOURCE_DIR}/Inc")

	set_target_properties(${target_name} PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${output_dir}"
		LIBRARY_OUTPUT_DIRECTORY "${output_dir}"
		RUNTIME_OUTPUT_DIRECTORY "${output_dir}"
	)

	if(MSVC)
		target_compile_options(${target_name} PRIVATE
			/bigobj
			/wd4996
			/wd4267
			/wd4244
			/wd4838
			$<$<CONFIG:Debug>:/MTd>
			$<$<NOT:$<CONFIG:Debug>>:/MT>
		)
	else()
		target_compile_options(${target_name} PRIVATE -std=gnu++14 -O3 -fPIC)
	endif()
endfunction()

function(cppcore_register_test_target target_name suite_name)
	set(options)
	set(one_value_args WORKING_DIRECTORY)
	set(multi_value_args)
	cmake_parse_arguments(CPPTESTREG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	cppcore_get_test_output_dir(output_dir)
	set(working_directory "${output_dir}")
	if(CPPTESTREG_WORKING_DIRECTORY)
		set(working_directory "${CPPTESTREG_WORKING_DIRECTORY}")
	endif()

	add_test(
		NAME ${target_name}
		COMMAND $<TARGET_FILE:${target_name}>
		WORKING_DIRECTORY "${working_directory}"
	)
	set_tests_properties(${target_name} PROPERTIES LABELS "${suite_name}")
	set_property(GLOBAL APPEND PROPERTY CPPCORE_TEST_TARGETS ${target_name})
endfunction()

function(cppcore_add_gtest_suite suite_name)
	set(options)
	set(one_value_args WORKING_DIRECTORY)
	set(multi_value_args DEPENDS)
	cmake_parse_arguments(CPPTEST "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	cppcore_collect_test_sources(sources)
	cppcore_get_runtime_libs(runtime_libs)

	foreach(variant IN ITEMS A W)
		set(target_name "${suite_name}${variant}")
		add_executable(${target_name} ${sources})
		cppcore_apply_test_target_defaults(${target_name})
		target_link_libraries(${target_name} PRIVATE cppcore_gtest_main ${runtime_libs})

		if(variant STREQUAL "W")
			target_compile_definitions(${target_name} PRIVATE UNICODE _UNICODE)
		endif()

		if(CPPTEST_DEPENDS)
			add_dependencies(${target_name} ${CPPTEST_DEPENDS})
		endif()

		cppcore_register_test_target(${target_name} ${suite_name}
			WORKING_DIRECTORY "${CPPTEST_WORKING_DIRECTORY}"
		)
	endforeach()
endfunction()

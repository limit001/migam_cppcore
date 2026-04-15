cppcore_add_gtest_suite(SystemTest
	DEPENDS
		DummyProcess
		DummyDynamicLibrary
	WORKING_DIRECTORY
		"$<TARGET_FILE_DIR:SystemTestA>"
)

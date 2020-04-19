
find_package(GTest REQUIRED)
message(STATUS "${GTEST_INCLUDE_DIRS}")

set(SNAPPY_DEPS "gtest"
        "gtest_main"
        "snappy::snappy")

if (HAVE_LIBZ)
    list(APPEND SNAPPY_DEPS "z")
endif ()
carbin_cc_test(
        NAME snappy_unittest
        SRCS snappy_unittest.cc snappy-test.cc
        DEPS ${SNAPPY_DEPS}
)

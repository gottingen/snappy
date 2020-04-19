
find_package(GTest REQUIRED)

set(SNAPPY_DEPS
        "GTest::Main"
        "GTest::GTest"
        "snappy::snappy")

if (HAVE_LIBZ)
    list(APPEND SNAPPY_DEPS "z")
endif ()
carbin_cc_test(
        NAME snappy_unittest
        SRCS snappy_unittest.cc snappy-test.cc
        DEPS ${SNAPPY_DEPS}
)

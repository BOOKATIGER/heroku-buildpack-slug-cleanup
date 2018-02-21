. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testCompileScriptPresent()
{
    if [ ! -f $BUILDPACK_HOME/bin/compile ]; then
        fail "compile script not found"
    fi
}

# Test the buildpack without any .slugcleanup files - should not raise any errors
testCompileSlugCleanupAbsent()
{
    echo "this is a test file" > $BUILD_DIR/test
    
    compile

    # Asster no errors
    assertEquals 0 ${rtrn}
    assertEquals "" "$(cat ${STD_ERR})"

    # Test file should exist after the call to compile()
    if [ ! -f $BUILD_DIR/test ]; then
        fail "test file not found in output directory"
    fi

    # Content of original file should be the same
    assertEquals "this is a test file" "$(cat ${BUILD_DIR}/test)"
}

# Test the buildpack with a .slugcleanup and only one file
testCompileSlugCleanupPresent()
{
    echo "test" > $BUILD_DIR/.slugcleanup
    echo "this is a test file" > ${BUILD_DIR}/test

    compile

    # Assert no errors
    assertEquals 0 ${rtrn}
    assertEquals "" "$(cat ${STD_ERR})"

    # We should found the reference to the file we deleted in the logs
    assertContains "${BUILD_DIR}/test" "$(cat ${STD_OUT})"

    # If the test file and .slugcleanup should be removed
    if [ -f $BUILD_DIR/test ] || [ -f $BUILD_DIR/.slugcleanup ]; then
        fail $(cat ${BUILD_DIR}/test)
    fi
}

# Test the buildpack  with a .slugcleanup with directories, empty lines and comments
testCompileSlugCleanupPresentDirectories()
{
    cat <<EOF  > $BUILD_DIR/.slugcleanup
testfile # which doesn't exist and shouldn't crash anything

# this is a comment
foo/bar
foo
EOF
    mkdir $BUILD_DIR/foo
    touch $BUILD_DIR/foo/bar

    compile

    # Assert no errors
    assertEquals 0 ${rtrn}
    assertEquals "" "$(cat ${STD_ERR})"
    
    assertContains "$BUILD_DIR/foo" "$(cat ${STD_OUT})"
    assertContains "$BUILD_DIR/foo/bar" "$(cat ${STD_OUT})"
    assertContains "$BUILD_DIR/testfile" "$(cat ${STD_OUT})"

    # We shouldn't find the commented lines in the output
    assertNotContains "this is a comment" "$(cat ${STD_OUT})"
    assertNotContains "which doesn't exist and shouldn't crash anything" "$(cat ${STD_OUT})"

    if [ -d $BUILD_DIR/foo ] || [ -f $BUILD_DIR/foo/bar ] || [ -f $BUILD_DIR/.slugcleanup ]; then
        fail "One or more files weren't properly removed"
    fi
}
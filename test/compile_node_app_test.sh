. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

# This piece of code is ran before each test
afterSetUp()
{
    export NODE_APP="my_app"

    # This is how we setup env variable on heroku buildpacks
    echo $NODE_APP > $ENV_DIR/NODE_APP

    mkdir $BUILD_DIR/my_app
}

# Test the buildpack without any .slugcleanup files - should not raise any errors
testCompileSlugCleanupAbsent()
{
    echo "this is a test file"          > $BUILD_DIR/testfile
    echo "this is another test file"    > $BUILD_DIR/$NODE_APP/anothertestfile
    
    compile


    # Assert no errors
    assertEquals 0 ${rtrn}
    assertEquals "" "$(cat ${STD_ERR})"

    # Test file should exist after the call to compile()
    if [ ! -f $BUILD_DIR/testfile ] || [ ! -f $BUILD_DIR/$NODE_APP/anothertestfile ]; then
        fail "test file not found in output directory"
    fi

    # Content of original file should be the same
    assertEquals "this is a test file" "$(cat ${BUILD_DIR}/testfile)"
    assertEquals "this is another test file" "$(cat ${BUILD_DIR}/${NODE_APP}/anothertestfile)"
    
}

# Simple test with a .slugcleanup in both $NODE_APP and root directory
testCompileSlugCleanupPresent()
{
    echo "anothertest"                  > $BUILD_DIR/$NODE_APP/.slugcleanup
    echo "this is another test file"    > $BUILD_DIR/$NODE_APP/anothertest

    compile

    # Assert no errors
    assertEquals 0 ${rtrn}
    assertEquals "" "$(cat ${STD_ERR})"

    # We should found the reference to the file we deleted in the logs
    assertContains "${BUILD_DIR}/${NODE_APP}/anothertest" "$(cat ${STD_OUT})"

    # The test file and .slugcleanup should be removed
    if [ -f $BUILD_DIR/$NODE_APP/anothertest ] || [ -f $BUILD_DIR/$NODE_APP/.slugcleanup ]; then
        fail "The required files weren't properly removed"
    fi
}

# More complex test with .slugcleanup with directories, empty lines and comments
testCompileSlugCleanupPresentDirectories()
{
    cat <<EOF > $BUILD_DIR/$NODE_APP/.slugcleanup
testfile # which doesn't exist and shouldn't crash anything

# this is a comment
foo/bar

foo

../unrelatedfolder

EOF

    mkdir $BUILD_DIR/$NODE_APP/foo
    mkdir $BUILD_DIR/unrelatedfolder


    touch $BUILD_DIR/$NODE_APP/foo/bar
    touch $BUILD_DIR/unrelatedfolder/test
    echo "I should still exist after compile" > $BUILD_DIR/stillexists

    compile

    # Assert no errors
    assertEquals 0 ${rtrn}
    assertEquals "" "$(cat ${STD_ERR})"
    
    assertContains "$BUILD_DIR/$NODE_APP/foo" "$(cat ${STD_OUT})"
    assertContains "$BUILD_DIR/$NODE_APP/foo/bar" "$(cat ${STD_OUT})"
    assertContains "$BUILD_DIR/unrelatedfolder" "$(cat ${STD_OUT})"

    # We don't want to delete files not listed
    assertNotContains "$BUILD_DIR/stillexists" "$(cat ${STD_OUT})"

    # We shouldn't find the commented lines in the output
    assertNotContains "this is a comment" "$(cat ${STD_OUT})"
    assertNotContains "which doesn't exist and shouldn't crash anything" "$(cat ${STD_OUT})"

    if [ -d $BUILD_DIR/$NODE_APP/foo ] || [ -f $BUILD_DIR/$NODE_APP/foo/bar ] || [ -f $BUILD_DIR/$NODE_APP/.slugcleanup ] || [ -d $BUILD_DIR/unrelatedfolder ]; then
        fail "One or more files weren't properly removed"
    fi

    if [ ! -f $BUILD_DIR/stillexists ]; then
        fail "A file that should've been kept was removed"
    fi

    assertContains "I should still exist after compile" "$(cat $BUILD_DIR/stillexists)"
}
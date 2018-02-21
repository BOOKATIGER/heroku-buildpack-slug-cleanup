. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testDetectScriptPresent()
{
    if [ ! -f $BUILDPACK_HOME/bin/detect ]; then
        fail "detect script not found"
    fi
}

# Detect should always return true for this buildpack
testDetect()
{
    detect
    assertEquals 0 ${rtrn}
    assertEquals "Cleanup" "$(cat ${STD_OUT})"
    assertEquals "" "$(cat ${STD_ERR})"
}
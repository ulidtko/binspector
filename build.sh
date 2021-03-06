#!/bin/bash

# Run a command, and echo before doing so. Also checks the exit
# status and quits if there was an error.
echo_run ()
{
    echo "EXEC : $@"
    "$@"
    r=$?
    if test $r -ne 0 ; then
        exit $r
    fi
}

echo_run cd `dirname $0`

echo "INFO : Make sure you run the configure script before this one to ensure dependencies are in place."

if [ "$BUILDTOOL" == "" ] ; then
    echo "INFO : BUILDTOOL unknown. Defaulting to bjam."

    BUILDTOOL="bjam"
fi

if [ "$BUILDTOOL" == "xcode" ] ; then

    if [ "$BUILDMODE" == "debug" ] ; then
        CURMODE="Debug"
    elif [ "$BUILDMODE" == "release" ] ; then
        CURMODE="Release"
    else
        echo "INFO : xcode mode unknown. Defaulting to debug."

        CURMODE="Debug"
    fi

    cd xcode

    echo_run xcodebuild -configuration $CURMODE

elif [ "$BUILDTOOL" == "bjam" ] ; then

    if [ "$BUILDMODE" == "debug" ] ; then
        CURMODE="debug"
    elif [ "$BUILDMODE" == "release" ] ; then
        CURMODE="release"
    else
        echo "INFO : bjam mode unknown. Defaulting to debug."

        CURMODE="debug"
    fi

    PROCESSOR_COUNT=`sysctl -n hw.ncpu`

    if [ "$PROCESSOR_COUNT" == "" ] ; then
        PROCESSOR_COUNT=`nproc`
    fi

    if [ "$PROCESSOR_COUNT" == "" ] ; then
        PROCESSOR_COUNT=1
    fi

    echo "INFO : Found $PROCESSOR_COUNT processors."

    echo_run ../boost_libraries/b2 --toolset=${TOOLSET:-clang} --without-python --hash -j$PROCESSOR_COUNT $CURMODE

else

    echo "ERRR : BUILDTOOL unknown. Goodbye."

    exit 1;

fi

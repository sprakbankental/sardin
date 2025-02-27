# Legacy text data resources tests

This is a test group designed to perform regression tests to
ensure that we maintain backwards compatibility with the 
original MTM preproc codebase.


## Background

The MTM preproc codebase reads in text resources in one of two ways:

1. by compiling the resources from resources that may in part be  
   licensed in such a manner that MTM cannot share them freely original
2. by reading in precompiled data from Berkeley DB database files.

The former is not available to the public until all data has been 
cleared, which may or may not happen. The latter is riddled with 
compatibility issues. Berkeley DB is often preinstalled on systems,
and different libraries require different versions which are not
compatible, so portability becomes less than great.

For these reasons, CT implemented routines that dump the Berkeley DB 
database contents in text files (*Legacy DB text dumps*), and 
corresponding routines to read these files into data MTM preproc 
structures again.

Since both the original codebase and the refactored mtmpreproc will 
coexist for quite some time, and since the bulk of resource updates 
will take place in the original codebase first, it is essential that 
we maintain backwards compatibility. In other words, we must be sure
that we can slurp new text data resource files exported from the 
original codebase in the future.

We ensure this by implementing robust and static methods to read and 
write the legacy text data resource files, and set up tests (here, in 
this directory) to make sure they keep working.

## Test methods

Although the read and write routines are implemented as OO methods, 
we opt not to test them using Test::Class (or at least not 
Test::Class alone). Instead we use a traditional test script to 
facilitate the development of the routines, of Sereal persistance
methods, and - in time - of new internal data structures.

The methods will be developed in a *test first* manner, and we follow
the outline set up in isse #85 for the test design.


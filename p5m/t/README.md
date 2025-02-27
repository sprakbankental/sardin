# MTM/SBTal text processing and analysis packages - tests

The MTM/SBTal text processing and text analysis packages (MTM) uses tests 
on a number of levels:

- Test driven development - all code that is intended for release should be 
test first, code second.
- Regression tests - all code, all formats, and all training should be coupled 
with regression tests.
- Bug recreation - bugs should first be replicated in a test (with reference 
to the bug report), then fixed. The test remains to safeguard against the bug 
creeping back into the codebase.

We're following Språkbanken Tal policy and stick to best practice for the 
programming language in question. For Perl, this means:

- Use the Test::Class family of testing modules (e.g. `Test::Simple`, `Test::More`)
-- We avoid Test::Most in order to keep the code more explicit (Test::Most basically
pulls in a number of the most common modules)
- Any external scripts or programmes running these texts should be able to parse 
[TAP (Test Anything Protocol)](https://en.wikipedia.org/wiki/Test_Anything_Protocol).
- If testing from Perl, use `TAP::Harness` or possible `prove`if possible.

Finally, we're not committing to any one test paradigm, but use what's suitable for each task, e.g.:
- For obvious OO object testing, we use Test::Class based tests as described in this
[Modern Perl Programming blog post from 2009](http://www.modernperlbooks.com/mt/2009/03/organizing-test-suites-with-testclass.html).
- For bug replication, one test script per bug, with the test scripts as short and 
independent as possible.
- For regression after (re)training, some evaluation paradigm may have to be included in the testing.

## Tests of OO functionality

We follow the general outline in [Modern Perl Programming blog post from 2009](http://www.modernperlbooks.com/mt/2009/03/organizing-test-suites-with-testclass.html).

## File structure

This is the current structure:

- `t/` contains tests
- `t/classtests/` holds OO class specific test patterns based on `Test::Class`, in a structure that replicates `lib/`
- `coveragetests` holds tests of POD coverage

- `mtm-legacyflags.t` - we currently manage what used to be global flags by making
them available on `MTM::TTS*` objects. This test checks that they are actually 
available and that they default properly. All of these will be worked over in a 
later release, at which point this test will become obsolete. Until then, the test 
serves the added purpose of documenting these flags.
- `perl-dependencies.t` - checks (and documents) the module dependencies for the system
- `runclasstests.t` - runs all classtests (note that classtests on a single class can 
be executed with `perl -It/classtests/ ./t/classtests/Test/PATH/MODULE.pm`) 

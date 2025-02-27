# MTM TTS preprocessing v1.3.0-0.2.1

This repo contains a development version of a new, generalized version of 
the text-to-speech (TTS) preprocessing system used by Swedish Agency for 
Accessible Media (MTM). The code base will be released to the public once
MTM specific dependencies have been removed and the code has been refactored.


# Directory structure

- /data - Example and test data.
- /devnotes - Temporary development directory for notes and such.
- /doc - Documentation that is outside of the code docs (which is provided in the module files, in POD format). Note that this will mainly be populated during phase 2.
- /lib - Perl modules that are paet of this code base.
- /old - Temporary directory containing the original code base - will be reaped during stage 1 and then removed.
- /script - Convenience scripts and demos.
- /t - Tests. Note that this will mainly be populated during phase 2.

# Releases

- v1.3.0-0.2.0 - Dev update of Sardin code. Mainly VAC refactoring.
- v1.2.0 - Major update of Sardin code. Cleanup of MTM specific data and code.
- v1.1.2 - Hotfix, MQTT timeouts (Sardin server should now ping MQTT while processing)
- v1.1.1 - Hotfix, remove  dependency on hardcoded /tmp directory that prevents building
- v0.2.0 - Release, feature complete wrt the original code base. 
           DB_File based lists reinstated (for load speed until list building 
		       and Sereal and/or proper DB persistance are in place.
- v0.1.0 - Initial prerelease, feature complete wrt the original code base.


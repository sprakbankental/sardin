# Swedish Agency for Accessible Media TTS preprocessing

This repo is built automatically to create three types of build:




Placeholder README


# Interactive containers (Docker one-liners)

Bash shell with latest develop (test) version:

$ docker run -it sprakbankental/mtmpreproc:test bash

Bash shell with latest master (stable) version:

$ docker run -it sprakbankental/mtmpreproc:stable bash

Bash shell with specific release (increasing specificity):

$ docker run -it sprakbankental/mtmpreproc:1 bash

$ docker run -it sprakbankental/mtmpreproc:1.0 bash

$ docker run -it sprakbankental/mtmpreproc:1.0.0 bash

# Image including test materials

The mtmpreproc container is built using 
[a multistage build](https://docs.docker.com/develop/develop-images/multistage-build/). 
In the first stage, all tests and test data is included
(these are used by the automated tests ran at Docker Hub as part of 
the autobuild process). 

As these materials are bulky and not needed for the system's 
functionality, they are not copied into the second stage. Should you 
wish to keep them, it i spossible to set the target to the first stage,
and they will remain in the final container:

```docker build --target test -f docker/Dockerfile --tag testversion .```

$ docker run -it testversion bash
 
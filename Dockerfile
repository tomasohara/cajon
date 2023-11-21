# Barebones docker file for Github actions created via ChatGPT,
# as well as based on mezcla and shell-scripts versions.

# Use the GitHub Actions runner image with Ubuntu
# NOTE: Uses older 20.04 both for stability and for convenience in pre-installed Python downloads (see below).
# See https://github.com/catthehacker/docker_images
FROM catthehacker/ubuntu:act-20.04

# Set default debug level (n.b., use docker build --build-arg "arg1=v1" to override)
# Also optionally set the regex of tests to run.
# Note: maldito act/nektos/docker not overriding properly
ARG DEBUG_LEVEL=4
ARG TEST_REGEX=""

# Set the working directory in the container
ARG WORKDIR=/home/visual-diff
WORKDIR $WORKDIR

# Setup path for scripts
ENV PATH="$WORKDIR:$WORKDIR/tests:${PATH}"
ENV PYTHONPATH="$WORKDIR:$WORKDIR/tests:${PYTHONPATH}"

# Copy the current directory contents into the container
## TODO: COPY ./* ./.* .
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --requirement requirements.txt

# Make sure setup OK (n.b., used in posthoc review)
RUN echo "Checking installation"
RUN pwd; ls

# Run tests when the container launches
# note: CMD specified arguments to default ENTRYPOINT of "/bin/sh -c".
ENTRYPOINT DEBUG_LEVEL=$DEBUG_LEVEL TEST_REGEX="$TEST_REGEX"  run_tests.bash


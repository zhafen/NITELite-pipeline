#!/bin/bash

# Function to display help message
show_help() {
    cat << EOF
Usage: ./bin/mapmake.sh -c CONFIG_FILEPATH -d DATA_DIR [OPTIONS]

Options:
    -c, --config CONFIG_FILEPATH    Location of the configuration file.
                                    Must be inside either the repository
                                    or the data directory.

    -d, --data DATA_DIR             Location of the data directory. This will
                                    be mounted to the /data directory inside
                                    the docker container. Any data you want to
                                    use should be inside DATA_DIR, and any paths
                                    in the config should be relative to this.

    -i, --interactive               Instead of running the execution script,
                                    open an interactive shell inside the
                                    docker container.

    -f, --compose-file              Specify the docker-compose file to use.
                                    Default is ./build/docker-compose.yaml

    -h, --help                      Show this help message

    --validate_only                 Only validate the setup and exit. This
                                    will not run the pipeline.

    --mount_code                    Mount the code directory into the docker
                                    container. This is useful if you want to
                                    use your own version of the pipeline code.
                                    Note that if you added or removed any
                                    dependencies, you will need to rebuild the
                                    docker image instead.

Example:
    ./bin/mapmake.sh -c ./config/mosaic.yaml -d /Users/shared/data
EOF
}


# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -c|--config)
            CONFIG_FILEPATH="$2"
            shift # past argument
            shift # past value
            ;;
        -d|--data)
            DATA_DIR="$2"
            shift # past argument
            shift # past value
            ;;
        -f|--compose-file)
            COMPOSE_FILE="$2"
            shift # past argument
            shift # past value
            ;;
        -i|--interactive)
            INTERACTIVE="true"
            shift # past argument
            ;;
        --validate_only)
            VALIDATE_ONLY="true"
            shift # past argument
            ;;
        --mount_code)
            MOUNT_CODE="true"
            shift # past argument
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unrecognized option $1"
            show_help
            exit 1
            ;;
    esac
done

# Check the necessary arguments are provided
if [ -z "$INTERACTIVE" ]; then
    if [ -z "$CONFIG_FILEPATH" ]; then
        echo "Error: Configuration filepath is required."
        show_help
        exit 1
    fi
fi
if [ -z "$COMPOSE_FILE" ]; then
    COMPOSE_FILE="./build/docker-compose.yaml"
fi

# Construct docker command
DOCKER_CMD="docker compose -f $COMPOSE_FILE"
# The docker command itself
DOCKER_CMD+=" run"

# If not interactive, then we add a "run"
if [ -n "$INTERACTIVE" ]; then
    DOCKER_CMD+=" -i"
fi

# Mount the data directory
if [ -n "$DATA_DIR" ]; then
    DOCKER_CMD+=" --volume $DATA_DIR:/data"
fi

# Mount the config file
if [ -n "$CONFIG_FILEPATH" ]; then
    CONFIG_FILEPATH=$(realpath $CONFIG_FILEPATH)
    DOCKER_CMD+=" --volume $CONFIG_FILEPATH:/used-config.yaml"
fi

# Mount the code directory
if [ -n "$MOUNT_CODE" ]; then
    DOCKER_CMD+=" --volume $(realpath .):/NITELite-pipeline"
fi

# Name of the service
DOCKER_CMD+=" nitelite-pipeline"

# The script to run inside the docker image
if [ -z "$INTERACTIVE" ]; then

    # This part of the command specifies the python environment
    # (inside the docker image) to use
    DOCKER_CMD+=" conda run -n nitelite-pipeline-conda --live-stream"

    DOCKER_CMD+=" python night-horizons-mapmaker/night_horizons/pipeline.py"

    # Pass in the config itself
    DOCKER_CMD+=" /used-config.yaml"

    # If validation only, then add the flag
    if [ -n "$VALIDATE_ONLY" ]; then
        DOCKER_CMD+=" --validate_only"
    fi
else
    DOCKER_CMD+=" /bin/bash"
fi

# Execute docker run command
echo "Executing:"
echo $DOCKER_CMD
echo
eval $DOCKER_CMD

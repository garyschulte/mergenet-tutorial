# Starts a Lighthouse Validator Client using either:
#
# - A docker image: provide `docker` as the first argument.
# - A local binary:: provide `binary` as the first argument.

BINARY=binary
DOCKER=docker
DOCKER_IMAGE=sigp/lighthouse:rayonism

# Ensure necessary env vars are present.
if [ -z "$TESTNET_NAME" ]; then
    echo TESTNET_NAME is not set, exiting
    exit 1
fi
if [ -z "$1" ]; then
    echo The first argument must be \"$BINARY\" or \"$DOCKER\", exiting
    exit 1
fi

COMMON_LH_PARAMS="--testnet-deposit-contract-deploy-block 0 \
    --testnet-genesis-state "$TESTNET_NAME/genesis.ssz" \
    --testnet-yaml-config "$TESTNET_NAME/eth2_config.yaml" \
    validator_client \
    --init-slashing-protection \
    --validators-dir "./$TESTNET_NAME/keys" \
    --secrets-dir "./$TESTNET_NAME/secrets""

# Start Lighthouse using the binary available on $PATH.
if [ $1 = $BINARY ]; then
    exec lighthouse \
        --datadir "$(pwd)/$TESTNET_NAME/nodes/lighthouse_binary" \
        $COMMON_LH_PARAMS
    exit 0
fi

# Start Lighthouse using a docker image on Docker Hub.
if [ $1 = $DOCKER ]; then
    docker pull $DOCKER_IMAGE &&
    exec docker \
        run \
	-d \
        --net host \
        --mount 'type=bind,source='$(pwd)'/'$TESTNET_NAME',target=/'$TESTNET_NAME \
        $DOCKER_IMAGE \
        lighthouse \
        $COMMON_LH_PARAMS
    exit 0
fi

echo "Unknown argument: $1. Use \"$BINARY\" or \"$DOCKER\"."

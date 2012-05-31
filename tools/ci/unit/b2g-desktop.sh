#!/bin/bash
CI_TOOLS=`cd $(dirname ${BASH_SOURCE[0]}); pwd`;

cd $GAIA_PATH && make -C $GAIA_PATH update-common;

source $CI_TOOLS/config.sh

echo "Building Profile";

# Prevent failures from missing dirs

cd $GAIA_PATH && make -C $GAIA_PATH \
  DEBUG=1 \
  GAIA_PORT=$GAIA_PORT \
  GAIA_DOMAIN=$GAIA_DOMAIN

DOMAIN=http://test-agent.$GAIA_DOMAIN$GAIA_PORT/index.html#?websocketUrl=$TEST_AGENT_SERVER

echo "Starting B2G Desktop";

$B2G_HOME/dist/bin/b2g -profile $GAIA_PATH/profile &
PID=`jobs -p | tail -n 1`;

# Horrible hack need real
# script in b2g-scripts to wait for a port first..
sleep 10

if [ "$?" -ne "0" ];
then
  echo "B2G Desktop failed to start."
  exit $?
fi

cd $GAIA_PATH;
./tools/test-agent/node_modules/b2g-scripts/bin/b2g-scripts cmd goUrl $DOMAIN

echo "Running tests";
$CI_TOOLS/test.sh

kill $PID;
exit $EXIT_STATUS;


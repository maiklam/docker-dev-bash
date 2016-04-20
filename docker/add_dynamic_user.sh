USER_BOOTSTRAP=/user_bootstrap.sh

# Temp files to capture the output from groupadd incase there are issues
groupadd_output=$(mktemp)
useradd_output=$(mktemp)

groupadd --gid $GID $USERNAME > "${groupadd_output}" 2>&1
GROUPADD_EXIT=$?

#http://linux.die.net/man/8/groupadd
#exit code 4 = GID not unique (when -o not used)
if [[ "x$GROUPADD_EXIT" != "x0" && "x$GROUPADD_EXIT" != "x4" ]]
then
  echo "groupadd failed, attempting to continue... "
  cat ${groupadd_output}
fi

groupadd -f --gid $DOCKER_GROUP_ID docker
useradd --gid $GID -G docker,$DOCKER_GROUP_ID  --uid $UID $USERNAME > "${useradd_output}" 2>&1

if [ "x$?" != "x0"  ]
then
  echo "useradd failed, attempting to continue... "
  cat ${useradd_output}
fi

# anything mounted into $USERNAME's home from the host will be owned by root by default
chown -R ${USERNAME} /home/${USERNAME}

if [ -f "${USER_BOOTSTRAP}" ]; then
  su $USERNAME ${USER_BOOTSTRAP}
fi

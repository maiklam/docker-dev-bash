#!/bin/bash

cmd=$@

/add_dynamic_user.sh

su $USERNAME -c "$cmd"

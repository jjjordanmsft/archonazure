#!/bin/bash

# Root keys found at https://www.archlinux.org/master-keys/
KEYS="6AC6A4C2 824B18E8 4C7EA887 CDFD6BB0 FFF979E7 77514E00"
KEYRING=$(pwd)/archkeys.gpg

# Ensure no previous run pollutes future results
rm -rf $KEYRING ${KEYRING}~

# Fetch and trust each root key in a temporary keyring
for k in $KEYS ; {
	gpg --no-default-keyring --keyring $KEYRING --keyserver ha.pool.sks-keyservers.net --recv $k || exit $?
	echo -e "trust\n5\ny\n" | gpg --no-default-keyring --keyring $KEYRING --command-fd 0 --edit-key $k --yes || exit $?
}

# Verify signature with temp keyring
gpg --no-default-keyring --keyring $KEYRING --keyserver-options auto-key-retrieve --verify $1 || exit $?

# Remove temporary keyring
rm -rf $KEYRING ${KEYRING}~
true

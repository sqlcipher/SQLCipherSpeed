SQLCIPHER_DIR := ${CURDIR}/sqlcipher
.DEFAULT_GOAL := amalgamation

amalgamation:
	cd ${SQLCIPHER_DIR} && \
	${SQLCIPHER_DIR}/configure --with-crypto-lib=commoncrypto --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLCIPHER_CRYPTO_CC" LDFLAGS="-framework Security" && \
	make sqlite3.c

init:
	git submodule update --init

clean:
	-cd ${SQLCIPHER_DIR} && make clean
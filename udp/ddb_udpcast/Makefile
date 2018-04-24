all:
	head -c 10 /dev/zero | tr '\0' '\n'; \
	gcc -Werror -I$$HOME/pe/deadbeef/include -fPIC -std=c99 -shared -O2 -o $$HOME/pe/deadbeef/lib/deadbeef/ddb_udpcast.so udpcast.c


OUT=webdis
HIREDIS_OBJ=hiredis/hiredis.o hiredis/sds.o hiredis/net.o hiredis/async.o hiredis/dict.o
JANSSON_OBJ=jansson/src/dump.o jansson/src/error.o jansson/src/hashtable.o jansson/src/load.o jansson/src/strbuffer.o jansson/src/utf.o jansson/src/value.o jansson/src/variadic.o 
FORMAT_OBJS=formats/json.o formats/raw.o formats/common.o formats/custom-type.o formats/bson.o
HTTP_PARSER_OBJS=http-parser/http_parser.o
DEPS=$(FORMAT_OBJS) $(HIREDIS_OBJ) $(JANSSON_OBJ) $(HTTP_PARSER_OBJS)
OBJS=webdis.o cmd.o worker.o slog.o server.o libb64/cencode.o acl.o md5/md5.o http.o client.o websocket.o pool.o conf.o $(DEPS)

CFLAGS=-O3 -Wall -Wextra -I. -Ijansson/src -Ihttp-parser
LDFLAGS=-levent -pthread

PREFIX ?= /usr/local
CONFDIR ?= $(DESTDIR)/etc

INSTALL_DIRS = $(DESTDIR) \
	       $(DESTDIR)/$(PREFIX) \
	       $(DESTDIR)/$(PREFIX)/bin \
	       $(CONFDIR)

all: .CHECK_FOR_MSGPACK

.CHECK_FOR_MSGPACK:
	@if [ -f /usr/lib/libmsgpack.so ]; then make .WITH_MSGPACK; else make .WITHOUT_MSGPACK ; fi

.WITH_MSGPACK:
	@echo "Building with MsgPack support"
	@make CFLAGS="$(CFLAGS) -DMSGPACK=1" .REAL_BUILD

.WITHOUT_MSGPACK:
	@echo "Building without MsgPack support"
	@make .REAL_BUILD

.REAL_BUILD: $(OUT) Makefile

$(OUT): $(OBJS) Makefile
	$(CC) $(LDFLAGS) -o $(OUT) $(OBJS)

%.o: %.c %.h Makefile
	$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.c Makefile
	$(CC) -c $(CFLAGS) -o $@ $<

$(INSTALL_DIRS):
	mkdir -p $@

clean:
	rm -f $(OBJS) $(OUT)

install: $(OUT) $(INSTALL_DIRS)
	cp $(OUT) $(DESTDIR)/$(PREFIX)/bin
	cp webdis.prod.json $(CONFDIR)

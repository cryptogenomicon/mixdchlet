SHELL      = /bin/sh

CC         = gcc
CFLAGS     = -O3
# CFLAGS     = -g -Wall

ESL_INCDIR = easel    # or something like ${HOME}/src/easel, if you already have a copy of Easel source
ESL_LIBDIR = easel    # "  "         "  . ${HOME}/src/easel/build-osx-debug, if you have an Easel build

LIBS       = -leasel -lm

all:  mixdchlet

mixdchlet: mixdchlet.o
	${CC} ${CFLAGS} -I ${ESL_INCDIR} -I ${ESL_LIBDIR} -L ${ESL_LIBDIR} -o $@ $@.o ${LIBS}

.c.o:
	${CC} ${CFLAGS} -I ${ESL_INCDIR} -I ${ESL_LIBDIR} -o $@ -c $<

clean:
	rm -f *.o
	rm -f mixdchlet


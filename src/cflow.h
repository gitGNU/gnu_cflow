/*  $Id$
 *  cflow
 *  Copyright (C) 1997 Gray
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
#define DEBUG 1
#define GNU_STYLE_OPTIONS 1

#define SYSTEM_ERROR 0x0100
#define FATAL_ERROR  0x0200
#define FATAL(n) FATAL_ERROR|(n)

#define NUMITEMS(a) sizeof(a)/sizeof((a)[0])

typedef struct cons *Consptr;
typedef struct cons Cons;
struct cons {
    Consptr car;
    Consptr cdr;
};

#define CAR(a) (a)->car
#define CDR(a) (a)->cdr

enum symtype {
    SymUndefined,
    SymToken,
    SymFunction,
};

enum storage {
    ExternStorage,
    StaticStorage,
    AutoStorage,
    AnyStorage,
};

typedef struct {
    int line;
    char *source;
} Ref;

typedef struct symbol Symbol;

struct symbol {
    Symbol *next;
    enum symtype type;
    char *name;
    int active;
    union {
	struct {
	    int token_type;
	    char *source;
	    int def_line;
	    Consptr ref_line;
	} type;
	struct {
	    int token_type;
	    char *source;
	    int def_line;
	    Consptr ref_line;
	    char *type;
	    enum storage storage;
	    int argc;
	    char *args;
	    int level;          /* for local vars only */
	    Consptr caller;
	    Consptr callee;
	} func;
    } v;
};

/* two output modes */
#define OUT_TEXT 0
#define OUT_HTML 1

extern char *progname;
extern int verbose;
extern int ignore_indentation;
extern int assume_cplusplus;
extern int record_defines;
extern int record_typedefs;
extern int cross_ref;
extern int strict_ansi;
extern int globals_only;
extern int print_level;
extern char level_indent[];
extern int output_mode;
extern int print_levels;
extern int print_as_tree;

#ifdef DEBUG
extern int debug;
#endif
extern int token_stack_length;
extern int token_stack_increase;

extern int symbol_count;

void *emalloc(int);
void efree(void*);
Symbol *lookup(char*);
Symbol *install(char*);
Consptr alloc_cons();
int collect_symbols(Symbol ***, int (*sel)());



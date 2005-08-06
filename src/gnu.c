/* This file is part of GNU cflow
   Copyright (C) 1997,2005 Sergey Poznyakoff
 
   GNU cflow is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
 
   GNU cflow is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with GNU cflow; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301 USA */

#include <cflow.h>

void
print_function_name(Symbol *sym, int has_subtree)
{
     fprintf(outfile, "%s", sym->name);
     if (sym->arity >= 0)
	  fprintf(outfile, "()");
     if (sym->decl)
	  fprintf(outfile, " <%s at %s:%d>",
		  sym->decl,
		  sym->source,
		  sym->def_line);
     if (sym->active) {
	  fprintf(outfile, " (recursive: see %d)", sym->active-1);
	  return;
     }
     if (sym->recursive)
	  fprintf(outfile, " (R)");
     if (!print_as_tree && has_subtree)
	  fprintf(outfile, ":");
}


static int
print_symbol(FILE *outfile, int line, struct output_symbol *s)
{
     int has_subtree = s->direct ? 
 	                  s->sym->callee != NULL :
	                  s->sym->caller != NULL;
     
     print_level(s->level, s->last);
     print_function_name(s->sym, has_subtree);
	  
     if (brief_listing) {
	  if (s->sym->expand_line) {
	       fprintf(outfile, " [see %d]", s->sym->expand_line);
	       return 1;
	  } else if (s->sym->callee)
	       s->sym->expand_line = line;
     }
     return 0;
}

int
gnu_output_handler(cflow_output_command cmd,
		   FILE *outfile, int line,
		   void *data, void *handler_data)
{
     switch (cmd) {
     case cflow_output_init:
     case cflow_output_begin:
     case cflow_output_end:
     case cflow_output_separator:
	  break;
     case cflow_output_newline:
	  fprintf(outfile, "\n");
	  break;
     case cflow_output_text:
	  fprintf(outfile, "%s", (char*) data);
	  break;
     case cflow_output_symbol:
	  return print_symbol(outfile, line, data);
     }
     return 0;
}

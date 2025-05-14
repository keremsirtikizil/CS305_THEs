/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     tASSIGN = 258,
     tCOMMA = 259,
     tDAILY = 260,
     tDATE = 261,
     tDESCRIPTION = 262,
     tENDDATE = 263,
     tENDMEETING = 264,
     tENDSUBMEETINGS = 265,
     tFREQUENCY = 266,
     tIDENTIFIER = 267,
     tINTEGER = 268,
     tISRECURRING = 269,
     tLOCATIONS = 270,
     tMEETINGNUMBER = 271,
     tMONTHLY = 272,
     tNO = 273,
     tREPETITIONCOUNT = 274,
     tSTARTDATE = 275,
     tSTARTMEETING = 276,
     tSTARTSUBMEETINGS = 277,
     tSTARTTIME = 278,
     tSTRING = 279,
     tTIME = 280,
     tWEEKLY = 281,
     tYEARLY = 282,
     tYES = 283,
     tENDTIME = 284
   };
#endif
/* Tokens.  */
#define tASSIGN 258
#define tCOMMA 259
#define tDAILY 260
#define tDATE 261
#define tDESCRIPTION 262
#define tENDDATE 263
#define tENDMEETING 264
#define tENDSUBMEETINGS 265
#define tFREQUENCY 266
#define tIDENTIFIER 267
#define tINTEGER 268
#define tISRECURRING 269
#define tLOCATIONS 270
#define tMEETINGNUMBER 271
#define tMONTHLY 272
#define tNO 273
#define tREPETITIONCOUNT 274
#define tSTARTDATE 275
#define tSTARTMEETING 276
#define tSTARTSUBMEETINGS 277
#define tSTARTTIME 278
#define tSTRING 279
#define tTIME 280
#define tWEEKLY 281
#define tYEARLY 282
#define tYES 283
#define tENDTIME 284




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;


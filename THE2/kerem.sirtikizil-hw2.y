%{
#include <stdio.h>
#include <stdlib.h>
void yyerror (const char * s)
{
    return; /* overriden to return nothing */
}
int yylex();

%}

%token tASSIGN tCOMMA tDAILY tDATE tDESCRIPTION tENDDATE tENDMEETING tENDSUBMEETINGS tFREQUENCY tIDENTIFIER tINTEGER
%token tISRECURRING tLOCATIONS tMEETINGNUMBER tMONTHLY tNO tREPETITIONCOUNT tSTARTDATE tSTARTMEETING 
%token tSTARTSUBMEETINGS tSTARTTIME tSTRING tTIME tWEEKLY tYEARLY tYES tENDTIME 
%start program

%%
program:
    meeting_list
    ;

meeting_list:
    meeting_block
    | meeting_list meeting_block
    ;

meeting_block:
    tSTARTMEETING tSTRING 
    tMEETINGNUMBER tASSIGN tINTEGER
    tDESCRIPTION tASSIGN tSTRING
    tSTARTDATE tASSIGN tDATE
    tSTARTTIME tASSIGN tTIME
    tENDDATE tASSIGN tDATE
    tENDTIME tASSIGN tTIME
    tLOCATIONS tASSIGN location_list
    tISRECURRING tASSIGN recurrence_value
    frequency_opt
    repetition_count_opt
    sub_meetings_opt
    tENDMEETING
    ;

location_list:
    tIDENTIFIER
    | location_list tCOMMA tIDENTIFIER
    ;

recurrence_value:
    tYES
    | tNO
    ;

frequency_opt:
    /* optional */
    | tFREQUENCY tASSIGN frequency_value
    ;

frequency_value:
    tDAILY 
    | tWEEKLY 
    | tMONTHLY 
    | tYEARLY
    ;

repetition_count_opt:
    /* optional */
    | tREPETITIONCOUNT tASSIGN tINTEGER
    ;

sub_meetings_opt:
    /* optional */
    | tSTARTSUBMEETINGS meeting_list tENDSUBMEETINGS
    ;

%%

int main()
{
    if(yyparse()){
        //yyparse returns 1 if there is an error
        printf("ERROR\n");
        return 1;
    }else{
        //successful parsing 
        printf("OK\n");
        return 0;
    }
}
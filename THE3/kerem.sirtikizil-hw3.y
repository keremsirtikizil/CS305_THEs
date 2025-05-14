%{


#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#define DAYS_IN_MONTH 28
#define MONTHS_IN_YEAR 12

typedef struct LocationAttr{
    char * list[100];
    int count; 
} LocationAttr;
struct Date{
    int day;
    int month;
    int year;
    int line;
    char raw[20];
} ;

struct Time{
    int hour;
    int minute;
    int line;
    char raw[20];
}; 

typedef struct Meeting {
    int line; // line which Meeting keyword exists
    int meetingNumber; // meeting number
    int meetingNumber_line; // line which meeting number exists
    char * Name; // meeting name
    char * description; // meeting 
    struct Date *startDate, *endDate; 
    struct Time *startTime, *endTime;
    int _date_time_valid_flag;
    char * locations[50]; // to be passes into locationExists array i.e.
    int locationsLine;
    int locationCount; // Idk if I need this - yes I need this now I understood
    int isRecurring; 
    int isRecurring_line;
    char *frequency; //daily, monthly etc.
    int frequency_line; 
    int repetitionCount;
    int repetitionCount_line;
    int am_I_sub;

    struct Meeting* next; // next level pointer
    struct Meeting* subMeetings; // sub level pointer
    
    
} Meeting;


int yylex();
void yyerror(const char *s){
    return;
}
extern int yylineno;

int seenMeetingNumbers[100];
int seenCount = 0;
char semanticErrors[200][100]; // no pointer needed, I guess so no strdup is needed.
int errorCount = 0;
Meeting * allMeetings = NULL;

typedef struct tied_for_frequency{
        int line_no;
        char *FREQUENCY;
}tied_for_frequency;

typedef struct tied_for_repetition{
        int line_no;
        int REPETITION;
}tied_for_repetition;

//*****************SEMANTIC_CHECK_FUNCTIONS**************************************

int isValidTime(struct Time *t){
    return(t->hour>=0 && t->hour <= 23 && t->minute >= 0 && t->minute<=59);
}

int isValidDate(struct Date *d) {
    return (d->day >= 1 && d->day <= 28 && d->month >= 1 && d->month <= 12 && d->year >= 2025 && d->year <= 2050);
}

int isEndAfterStart(struct Date *sd, struct Time *st, struct Date *ed, struct Time *et) {
    //s->start, e->end
    if (ed->year != sd->year) return ed->year > sd->year;
    if (ed->month != sd->month) return ed->month > sd->month;
    if (ed->day != sd->day) return ed->day > sd->day;
    if (et->hour != st->hour) return et->hour > st->hour;
    return et->minute > st->minute; 
    // returns 1 if the meeting ends after it starts 
}

int isEndAfterStart_range_check(struct Date *sd, struct Time *st, struct Date *ed, struct Time *et) {
    //s->start, e->end
    if (ed->year != sd->year) return ed->year > sd->year;
    if (ed->month != sd->month) return ed->month > sd->month;
    if (ed->day != sd->day) return ed->day > sd->day;
    if (et->hour != st->hour) return et->hour > st->hour;
    return et->minute >= st->minute; 
    // returns 1 if the meeting ends after it starts 
}

int locationRepeated(Meeting * m){ // returns 1 if locations repeated
    for(int i = 0; i < m->locationCount-1; i++){
        for(int j = i+1; j < m->locationCount; j++){
            if(strcmp(m->locations[i], m->locations[j]) == 0)
            return 1;
        }
    }
    return 0;
}

int isLocationExist_in_Parent(Meeting *p, Meeting *c) {
    for (int i = 0; i < c->locationCount; i++) {
        int found = 0;
        for (int j = 0; j < p->locationCount; j++) {
            if (strcmp(c->locations[i], p->locations[j]) == 0) {
                found = 1;
                break; // Found a common location
            }
        }
        if(!found){
            return 1;
        }
    }
    return 0; // No common locations
}

int am_I_repeating_as_a_submeeting(Meeting *m){
    if(m->am_I_sub){
        if(m->isRecurring){
            return 1;
        }
    }
    return 0;
}

int is_there_frequency_if_noisRecurring(Meeting *m){
    if(!m->isRecurring){
        if(strcmp(m->frequency, "NULL") == 0){
            return 1;
        }
    }
    return 0;
}

int is_there_repetitionCount_if_noisRecurring(Meeting *m){
    if(!m->isRecurring){
        if(m->repetitionCount == -1){
            return 1;
        }
    }
    return 0;
}

int is_there_repetitionCount_and_frequency_if_isRecurring(Meeting *m){
    if(!m->am_I_sub && m->isRecurring){
        if(strcmp(m->frequency, "NULL") == 0 || m->repetitionCount == -1){
            return 0;
        }
    }
    return 1;
}

int isMeetingNumberDuplicate(int number) {
    for (int i = 0; i < seenCount; i++) {
        if (seenMeetingNumbers[i] == number) return 1;
    }
    seenMeetingNumbers[seenCount++] = number;
    return 0;
}

int runSemantics(Meeting * m, Meeting *parent){
    while(m){
        int key1 = 1;
        m->_date_time_valid_flag = 1;
        if(!isValidTime(m->startTime)){
            sprintf(semanticErrors[errorCount++], "%d_INVALID_TIME_(%02d.%02d)", m->startTime->line, m->startTime->hour, m->startTime->minute);
            key1= 0;
            m->_date_time_valid_flag = 0;
        }
        if(!isValidTime(m->endTime)){
            sprintf(semanticErrors[errorCount++], "%d_INVALID_TIME_(%02d.%02d)", m->endTime->line, m->endTime->hour, m->endTime->minute);
            key1= 0;
            m->_date_time_valid_flag = 0;
        }
        if(!isValidDate(m->startDate)){
            sprintf(semanticErrors[errorCount++], "%d_INVALID_DATE_(%02d.%02d.%04d)", m->startDate->line, m->startDate->day, m->startDate->month, m->startDate->year);
            key1= 0;
            m->_date_time_valid_flag = 0;
        }
        if(!isValidDate(m->endDate)){
            sprintf(semanticErrors[errorCount++], "%d_INVALID_DATE_(%02d.%02d.%04d)", m->endDate->line, m->endDate->day, m->endDate->month, m->endDate->year);
            key1= 0;
            m->_date_time_valid_flag = 0;
        }
        if(key1 && !isEndAfterStart(m->startDate,m->startTime,m->endDate,m->endTime)){
            sprintf(semanticErrors[errorCount++], "%d_ENDTIME_ERROR_(%d)",m->line,m->meetingNumber);
            m->_date_time_valid_flag = 0;
        }
        if(m->am_I_sub && m->_date_time_valid_flag && parent->_date_time_valid_flag && (!isEndAfterStart_range_check(parent->startDate,parent->startTime,m->startDate,m->startTime) 
        || !isEndAfterStart_range_check(m->endDate,m->endTime,parent->endDate,parent->endTime))){
            sprintf(semanticErrors[errorCount++], "%d_RANGE_ERROR_(%d_%d)", m->line, m->meetingNumber, parent->meetingNumber);

        }
        if(locationRepeated(m)){
            char temp_all_loc[1000] = "";
            for(int i = 0; i < m->locationCount; i++){
                strcat(temp_all_loc, m->locations[i]);
                if(i != m->locationCount-1){strcat(temp_all_loc, ", ");}

            }
            sprintf(semanticErrors[errorCount++], "%d_REPEATED_ROOM_ERROR_(%s)", m->locationsLine, temp_all_loc);
        }

        if(m->am_I_sub && isLocationExist_in_Parent(parent,m)){
            sprintf(semanticErrors[errorCount++], "%d_LOCATION_ERROR_(%d_%d)", m->locationsLine, m->meetingNumber, parent->meetingNumber);
        }

        if(m->am_I_sub && am_I_repeating_as_a_submeeting(m)){
            sprintf(semanticErrors[errorCount++], "%d_REPEATING_SUBMEETING_(%d)", m->isRecurring_line, m->meetingNumber);
        }

        if(!m->isRecurring && !is_there_frequency_if_noisRecurring(m)){
            sprintf(semanticErrors[errorCount++], "%d_UNEXPECTED_FREQUENCY_(%d)", m->frequency_line, m->meetingNumber);
        }

        if(!m->isRecurring && !is_there_repetitionCount_if_noisRecurring(m)){
            sprintf(semanticErrors[errorCount++], "%d_UNEXPECTED_REPETITIONCOUNT_(%d)", m->repetitionCount_line, m->meetingNumber);
        }
        if(!m->am_I_sub && !is_there_repetitionCount_and_frequency_if_isRecurring(m)){
            sprintf(semanticErrors[errorCount++], "%d_MISSING_ELEMENT_(%d)", m->isRecurring_line, m->meetingNumber);
        }
        
        if(isMeetingNumberDuplicate(m->meetingNumber)){
            sprintf(semanticErrors[errorCount++], "%d_REPEATED_MEETINGNUMBER_(%d)", m->meetingNumber_line, m->meetingNumber);
        }



        if(m->subMeetings){
            runSemantics(m->subMeetings,m);
        }

        m = m->next;
    }
    return (errorCount == 0) ? 1 : 0;
}

void swapErrors(int i, int j){
    char temp[100];
    strcpy(temp,semanticErrors[i]);
    strcpy(semanticErrors[i],semanticErrors[j]);
    strcpy(semanticErrors[j],temp);
}


void sortErrors(){ // bubble sort algorithm for sorting errors according to rules provided
    for(int i = 0; i <errorCount-1; i++){
        for(int j = 0; j< errorCount-i-1; j++){
            int lineNum1 = atoi(semanticErrors[j]);
            int lineNum2 = atoi(semanticErrors[j+1]);
            
            if(lineNum1 > lineNum2 || (lineNum1 == lineNum2 && strcmp(semanticErrors[j],semanticErrors[j+1]) > 0)){
                swapErrors(j,j+1);
            }
        }
    }
}

void PrintErrors(){
    sortErrors();
    for(int i = 0; i<errorCount; i++){
        printf("%s\n",semanticErrors[i]);
    }
}


//***************************REPORT_GENERATE_FUNCTIONS*****************************
struct CS305Date {
    int day, month, year;
};


struct CS305Time {
    int hour, minute;
};

// Flattened meeting instance for report purposes
typedef struct FlatMeeting {
    char room[50];
    struct CS305Date startDate, endDate;
    struct CS305Time startTime, endTime;
    int meetingNumber;
} FlatMeeting;


FlatMeeting allLeafMeetings[500];
int flatCount = 0;

int computeOffset(struct CS305Date offset) {
    return offset.day + (offset.month * 28) + (offset.year * 336);
}


void add_days(struct CS305Date* date, int days) {
    date->day += days;
    while (date->day > DAYS_IN_MONTH) {
        date->day -= DAYS_IN_MONTH;
        date->month++;
        if (date->month > MONTHS_IN_YEAR) {
            date->month = 1;
            date->year++;
        }
    }
}


void add_weeks(struct CS305Date* date, int weeks) { add_days(date, 7 * weeks); }
void add_months(struct CS305Date* date, int months) {
    date->month += months;
    while (date->month > MONTHS_IN_YEAR) {
        date->month -= MONTHS_IN_YEAR;
        date->year++;
    }
}
void add_years(struct CS305Date* date, int years) { date->year += years; }


struct CS305Date fromOriginalDate(struct Date* d) {
    struct CS305Date c = { d->day, d->month, d->year };
    return c;
}


struct CS305Time fromOriginalTime(struct Time* t) {
    struct CS305Time c = { t->hour, t->minute };
    return c;
}

// fill allLeafMeetings[]
void collectLeafMeetings(Meeting* m, struct CS305Date offsetStart, struct CS305Date offsetEnd) {
    while (m) {
        struct CS305Date startD = fromOriginalDate(m->startDate);
        struct CS305Date endD = fromOriginalDate(m->endDate);
        add_days(&startD, computeOffset(offsetStart));
        add_days(&endD, computeOffset(offsetEnd));

        if (!m->subMeetings) {
            for (int i = 0; i < m->locationCount; i++) {
                FlatMeeting f;
                strcpy(f.room, m->locations[i]);
                f.startDate = startD;
                f.endDate = endD;
                f.startTime = fromOriginalTime(m->startTime);
                f.endTime = fromOriginalTime(m->endTime);
                f.meetingNumber = m->meetingNumber;
                allLeafMeetings[flatCount++] = f;
            }
        } else {
            collectLeafMeetings(m->subMeetings, offsetStart, offsetEnd);
        }
        m = m->next;
    }
}


void generateReport(Meeting* allMeetings) {
    Meeting* m = allMeetings;
    while (m) {
        if (m->isRecurring) {
            for (int i = 0; i < m->repetitionCount; i++) {
                struct CS305Date offset = {0, 0, 0};
                if (strcmp(m->frequency, "daily") == 0) offset.day = i;
                else if (strcmp(m->frequency, "weekly") == 0) offset.day = 7 * i;
                else if (strcmp(m->frequency, "monthly") == 0) offset.month = i;
                else if (strcmp(m->frequency, "yearly") == 0) offset.year = i;
                collectLeafMeetings(m, offset, offset);
            }
        } else {
            struct CS305Date zero = {0, 0, 0};
            collectLeafMeetings(m, zero, zero);
        }
        m = m->next;
    }
}


int compareFlatMeetings(FlatMeeting* m1, FlatMeeting* m2) {
    int cmp = strcmp(m1->room, m2->room);
    if (cmp != 0) return cmp;
    if (m1->startDate.year != m2->startDate.year) return m1->startDate.year - m2->startDate.year;
    if (m1->startDate.month != m2->startDate.month) return m1->startDate.month - m2->startDate.month;
    if (m1->startDate.day != m2->startDate.day) return m1->startDate.day - m2->startDate.day;
    if (m1->startTime.hour != m2->startTime.hour) return m1->startTime.hour - m2->startTime.hour;
    return m1->startTime.minute - m2->startTime.minute;
}


void sortLeafMeetings() {
    for (int i = 0; i < flatCount - 1; i++) {
        for (int j = 0; j < flatCount - i - 1; j++) {
            if (compareFlatMeetings(&allLeafMeetings[j], &allLeafMeetings[j+1]) > 0) {
                FlatMeeting temp = allLeafMeetings[j];
                allLeafMeetings[j] = allLeafMeetings[j+1];
                allLeafMeetings[j+1] = temp;
            }
        }
    }
}


void printSchedulerReport() {
    sortLeafMeetings();

    char currentRoom[100] = "";
    for (int i = 0; i < flatCount; i++) {
        FlatMeeting* m = &allLeafMeetings[i];
        if (strcmp(currentRoom, m->room) != 0) {
            strcpy(currentRoom, m->room);
            printf("%s:\n", currentRoom);
        }
        printf("%02d.%02d.%04d_%02d.%02d_%02d.%02d.%04d_%02d.%02d_%d\n",
               m->startDate.day, m->startDate.month, m->startDate.year,
               m->startTime.hour, m->startTime.minute,
               m->endDate.day, m->endDate.month, m->endDate.year,
               m->endTime.hour, m->endTime.minute,
               m->meetingNumber);
    }
}




%}
%locations 

%union{
    struct Meeting * meeting_;
    int intVal;
    char* strVal;
    struct tied_for_frequency *Frequency_Val;
    struct tied_for_repetition *Repetition_Val;
    struct LocationAttr * loclist;
}
%type  <loclist>locations
%type  <meeting_> features meeting submeet meeting_list
%type  <Frequency_Val> frequency
%type  <strVal> bool_val freq 
%type  <Repetition_Val> repetition
%token <strVal> tSTRING tIDENTIFIER tDATE tTIME
%token <intVal> tINTEGER 
%token tSTARTMEETING tMEETINGNUMBER tSTARTDATE tENDDATE tLOCATIONS tFREQUENCY
%token tDAILY tMONTHLY tWEEKLY tYEARLY tYES tNO tSTARTSUBMEETINGS tENDSUBMEETINGS
%token tSTARTTIME tENDTIME tASSIGN tDESCRIPTION tISRECURRING tREPETITIONCOUNT
%token tCOMMA tENDMEETING
%%

program: 
        meeting_list {allMeetings = $1; }
        ;

meeting_list:    
            meeting { $$ = $1; }
            |meeting meeting_list {
                $1->next = $2;
                $$ = $1;
            }
            ;

meeting:    
        tSTARTMEETING features tENDMEETING {
            $2->line = @1.first_line;
            $$ = $2;
        }
        ;


features: //1          2           3       4          5          6      7        8          9     10       11       12     13     14       15     16     17        18     19       20       21     22         23        24       25         26      27        28
        tSTRING tMEETINGNUMBER tASSIGN tINTEGER tDESCRIPTION tASSIGN tSTRING tSTARTDATE tASSIGN tDATE tSTARTTIME tASSIGN tTIME tENDDATE tASSIGN tDATE tENDTIME tASSIGN tTIME tLOCATIONS tASSIGN locations tISRECURRING tASSIGN bool_val frequency repetition submeet
        {
            Meeting * currentMeeting = malloc(sizeof(Meeting));
            memset(currentMeeting, 0, sizeof(Meeting));
            currentMeeting->Name = strdup($1);
            free($1);
            currentMeeting->meetingNumber = $4;
            currentMeeting->meetingNumber_line = @2.first_line;
            currentMeeting->description = strdup($7);
            free($7);
            currentMeeting->startDate = (struct Date*) malloc(sizeof(struct Date));
            int d,m,y;
            sscanf($10, "%d.%d.%d", &d, &m, &y);
            free($10);
            currentMeeting->startDate->day = d;
            currentMeeting->startDate->month = m;
            currentMeeting->startDate->year = y;
            currentMeeting->startDate->line = @10.first_line;
            currentMeeting->startTime = (struct Time*) malloc(sizeof(struct Time));
            sscanf($13, "%d.%d", &d, &m);
            free($13);
            currentMeeting->startTime->hour = d;
            currentMeeting->startTime->minute = m;
            currentMeeting->startTime->line = @13.first_line;
            currentMeeting->endDate = (struct Date*) malloc(sizeof(struct Date));
            sscanf($16, "%d.%d.%d", &d, &m, &y);
            free($16);
            currentMeeting->endDate->day = d;
            currentMeeting->endDate->month = m;
            currentMeeting->endDate->year = y;
            currentMeeting->endDate->line = @16.first_line;
            currentMeeting->endTime = (struct Time*) malloc(sizeof(struct Time));
            sscanf($19, "%d.%d", &d, &m);
            free($19);
            currentMeeting->endTime->hour = d;
            currentMeeting->endTime->minute = m;
            currentMeeting->endTime->line = @19.first_line;
            currentMeeting->locationsLine = @20.first_line;
            currentMeeting->isRecurring_line = @23.first_line;
            currentMeeting->isRecurring = (strcmp("YES", $25) == 0) ? 1 : 0;
            free($25);
            for(int i = 0; i < $22->count; i++){
                currentMeeting->locations[i] = $22->list[i];
            }
            currentMeeting->locationCount = $22->count;
            free($22);
            currentMeeting->frequency = strdup($26->FREQUENCY);
            currentMeeting->frequency_line = $26->line_no;
            
            currentMeeting->repetitionCount = $27->REPETITION;
            currentMeeting->repetitionCount_line = $27->line_no;
            currentMeeting->subMeetings = $28;
            $$ = currentMeeting;
        }
        ;

locations:
            tIDENTIFIER {
                LocationAttr* locs = malloc(sizeof(LocationAttr));
                locs->list[0] = strdup($1);
                locs->count = 1;
                $$ = locs;
            }
            | locations tCOMMA tIDENTIFIER {
                $1->list[$1->count++] = strdup($3);
                $$ = $1;
            }
            ;

bool_val:        tYES {$$ = strdup("YES");}
                |tNO  {$$ = strdup("NO");}
                ;

frequency:       tFREQUENCY tASSIGN freq { $$ = malloc(sizeof(struct tied_for_frequency)); $$->line_no = @1.first_line; $$->FREQUENCY = strdup($3);}
                | {$$ = malloc(sizeof(struct tied_for_frequency)); $$->FREQUENCY = strdup("NULL");}
                ;

freq:           tDAILY {$$ = strdup("daily");}
                |tWEEKLY {$$ = strdup("weekly");}
                |tMONTHLY {$$ = strdup("monthly");}
                |tYEARLY {$$ = strdup("yearly");}
                ;

repetition:      tREPETITIONCOUNT tASSIGN tINTEGER {
                    $$ = malloc(sizeof(struct tied_for_repetition));
                    $$->REPETITION = $3; $$->line_no = @1.first_line;
                    
                    }

                | { $$ = malloc(sizeof(struct tied_for_repetition));
                    $$->REPETITION = -1;  // means no repetition
                    $$->line_no = -1; 
                    
                    } //means there is no repetition, how I am going to check it.
                ;

submeet:        tSTARTSUBMEETINGS meeting_list tENDSUBMEETINGS { 
                    
                    Meeting *temp = $2;
                    while(temp){
                        temp->am_I_sub = 1;
                        temp = temp->next;
                    }
                    $$ = $2; 
                }
                | {$$ = NULL; } 
                ;



%%

    int main()
    {
        
        if (yyparse()){
            printf("ERROR\n");
            return 1;
        }
        else{
            
            if(runSemantics(allMeetings,NULL)){
                generateReport(allMeetings);
                printSchedulerReport(); 
            
            }else{
                
                PrintErrors();
            }
            
            
        }
        return 0;
    }
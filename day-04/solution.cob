       IDENTIFICATION DIVISION.
       PROGRAM-ID. aoc_day4.
       
       DATA DIVISION.
           working-storage section.
           01 WS-nlines PIC 9(3).

           01 WS-line PIC 9(10) VALUE 0.
           01 WS-counter PIC 9(3) VALUE 0.
           01 WS-i PIC 9(3) VALUE 0.
           01 WS-j PIC 9(3) VALUE 0.
           01 WS-is-extracted PIC 9(3) VALUE 0.
           01 WS-value PIC 9(3) VALUE 0.
           01 WS-result PIC 9(10) VALUE 0.
           01 WS-extraction.
               05 WS-extracted PIC 9(2) VALUE 0 OCCURS 10 TIMES.     
               05 WS-numbers PIC 9(2) VALUE 0 OCCURS 25 TIMES.     

       PROCEDURE DIVISION.
       main-PARA.
           ACCEPT WS-nlines.

           PERFORM parse-and-calculate-PARA VARYING WS-line
               FROM 1 BY 1 UNTIL WS-line = WS-nlines + 1.

           DISPLAY "The result is:".
           DISPLAY WS-result.
           STOP RUN.

       parse-and-calculate-PARA.
           PERFORM parse-one-extracted-PARA VARYING WS-counter
               FROM 1 BY 1 UNTIL WS-counter = 11.
           PERFORM parse-one-number-PARA VARYING WS-counter
               FROM 1 BY 1 UNTIL WS-counter = 26.
           PERFORM calculate-value-PARA.
           ADD WS-value TO WS-result.

       parse-one-extracted-PARA.
           ACCEPT WS-extracted(WS-counter).

       parse-one-number-PARA.
           ACCEPT WS-numbers(WS-counter).

       calculate-value-PARA.
           MOVE 0 to WS-value.
           PERFORM check-if-in-extracted-PARA VARYING WS-i
               FROM 1 BY 1 UNTIL WS-i = 26.
           
       
       check-if-in-extracted-PARA.
           MOVE 0 to WS-is-extracted.
           PERFORM check-extracted-PARA VARYING WS-j
               FROM 1 BY 1 UNTIL WS-j = 11.
           IF WS-is-extracted IS EQUAL TO 1 THEN
               IF WS-value IS EQUAL TO 0 THEN
                   MOVE 1 TO WS-value
               ELSE
                   ADD WS-value TO WS-value
               END-IF
           END-IF.
                   
       check-extracted-PARA.
           iF WS-extracted(WS-j) IS EQUAL TO WS-numbers(WS-i) THEN
               MOVE 1 TO WS-is-extracted
           END-IF.
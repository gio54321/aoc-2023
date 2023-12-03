#!/bin/awk -f
BEGIN {
    solution = 0;
    solution2 = 0;
}
{
    id=substr($2, 1, length($2)-1);
    solution += id;

    maxr = 0;
    maxg = 0;
    maxb = 0;
    for (i = 3; i <= NF; i=i+2)
    {
        num = $i;
        color = $(i+1)
        if (i < NF-1) {
            color = substr(color, 1, length(color)-1);
        }

        if(color == "red" && num > maxr) {
            maxr = num;
        }
        if (color == "green" && num > maxg) {
            maxg = num;
        }
        if (color == "blue" && num > maxb) {
            maxb = num;
        }
    }

    for (i = 3; i <= NF; i=i+2)
    {
        num = $i;
        color = $(i+1)
        if (i < NF-1) {
            color = substr(color, 1, length(color)-1);
        }

        if(color == "red" && num > 12) {
            solution -= id;
            break;
        }
        if (color == "green" && num > 13) {
            solution -= id;
            break;
        }
        if (color == "blue" && num > 14) {
            solution -= id;
            break;
        }
    }
    solution2 += maxr * maxg * maxb;
}
END {
    print "The solution for part 1 is: " solution
    print "The solution for part 2 is: " solution2
}

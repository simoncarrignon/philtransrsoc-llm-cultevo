A="The sky appears blue to the human eye as the short waves of blue light are scattered more than the other colours in the spectrum, making the blue light more visible." ; 
B="The French president is having an affairs with a younger boy"; 

for i in {1..100} ; do
    echo "step $i"
    C=`echo "Between these two statements, which one do you think is more susceptible to interest a human? A: '$A' or B:'$B'. Pick the statement you think is most interesting, modify it to make it even more interesting and write it back to me. Do not include anything else in your answer except your modified statement; never mention the fact that your are an AI, just write your modified statement" | ./bin/python3 chatbox.py `
    echo "new proposition"
    echo $C
    B=$C
done

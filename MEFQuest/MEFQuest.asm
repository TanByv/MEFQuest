## Macros
# Printer Macro
.macro print($string)
    la $a0, $string
    li $v0, 4
    syscall
.end_macro

# Register Printer
.macro printregister($register)
    # Print value of specified $t register
    li $v0, 1
    move $a0, $register
    syscall
.end_macro

# Stat Printer
.macro printstats
    print(stats_player_HP)
    printregister($t2)
    print(stats_spacing)
    print(stats_enemy_HP)
    printregister($t4)
    print(newline)
    print(newline)
.end_macro

# Clear Macro
.macro clearterminal
    li $t0, 60
clearloop:
    li $v0, 4
    la $a0, newline
    syscall
    addi $t0, $t0, -1
    bnez $t0, clearloop
.end_macro

# Selection Macro
# Selection Macro
.macro selection($prompt, $destination1, $destination2)
    print($prompt)

    # read integer from user
    li $v0, 5
    syscall
    move $t0, $v0

    # check if user entered 1
    li $t1, 1
    beq $t0, $t1, $destination1

    # check if user entered 2
    li $t1, 2
    beq $t0, $t1, $destination2

    # check if user entered 1337 (very secret debug menu)
    li $t1, 1337
    beq $t0, $t1, debugmenu

    # handle else
    j invalid_input
.end_macro

# Sleep Macro
.macro sleep($ms)
    li $a0, $ms
    li $v0, 32
    syscall
.end_macro

# Breakpoint Macro
.macro fakebreakpoint
    print(breakpoint_prompt)
    li $v0, 8 # syscall code for reading a string
    la $a0, buffer # load the address of the buffer into $a0
    li $a1, 4 # maximum number of characters to read
    syscall
.end_macro

# Notes from Tan:
# t0 and t1 is used by macros and other functions, temporary data
# t2 is player HP, t3 is enemy HP, t4 is damage thats going to be dealt (multiplier calculated inside fight)
# t5 is for RNG
# t8 and t9 is used for keeping time
# t6-t7 is usable atm

.data
    prompt1: .asciiz "							.88b  d88. d88888b d88888b       .d88b.  db    db d88888b .d8888. d888888b\n							88'YbdP`88 88'     88'          .8P  Y8. 88    88 88'     88'  YP `~~88~~' \n							88  88  88 88ooooo 88ooo        88    88 88    88 88ooooo `8bo.      88    \n							88  88  88 88~~~~~ 88~~~        88    88 88    88 88~~~~~   `Y8b.    88    \n							88  88  88 88.     88           `8P  d8' 88b  d88 88.     db   8D    88    \n							YP  YP  YP Y88888P YP            `Y88'Y8 ~Y8888P' Y88888P `8888Y'    YP    \n\n			MMMMMMMWXOkOOOOO0xOKxON0k0WKOO0MWO0OkNWWKd0XdOMWWMMOlOWNdxWMWNXNOdO0kO00KKKK0KNNNNdl0KKKodNWMNXWMMkdNM0oOMWWWWOdXKdOWNWKd00xXWWMWWMMMMMMMMMM\n			MMMMMMWXOkkOO0OOKk0Kx0N0kKWKkk0MWkOOkNMMKxKKdOMWWMMOl0MNdxNNNXXW0xXX0KXXKKKKOOXNNNdoXWWWdoNMMWNWMMkdXMKoOMMWWMOdXXdOWNNXxO0xKWWMWWMMMMMMMMMM\n			MMMMMWKkkkkOOOOOKOKKx0N0kKW0kk0MN0KkkWMMKxKKdOWNNWWkl0WXooXWMNNW0xXXKNMMWMWNKKXXXXdlKWWWxoNWWNXNWMkoKN0oOMMNWMOdXNxOMWWXxO0dKWWWWWMMMMMMMMMM\n			MMMMWKkkkkkOOOOOKOKKkKNOkKM0kkKMWWXodNWW0o00okX00XNxc0WXodWMWXKXkdK00XNXNWWWXNMMMWxlKNXXolKXNNXNWWko0N0lkMWNNMOdKNxOMWWNxOKx0WNWWWMMMMMMMMMM\n			MMMWKOOkkkkOOOOO0kKKxKNOkKW0OOKMMM0loKNXOlO0lxOx0XNxlKMNloXNNKKXkxNX0XNXXXNX0KNNWWxoNWWWdoKXXX0KXNklKMXokWWXXW0o0NxkMWWWkkXx0WWWWWMMMMMMMMMM\n			WWNKOOOOOOOOO0O00xK0d0XOkKW0kkKMNKl;lOXXxlkOldKKXNNxl0XKloNWWNXXkxNXKNWWWWWNKKNNNNdl0XXXdoNWWNKXXNxcONKoxWWXXW0oOXdxWWWWkkXxOWWMWWMMMMMMMMMM\n			KK0OkOOOkkO0O0O00xOkd0KkkKWOkk0WKlccldxOx:oxclkO00KdcONXldNWWXKKxdXXKNWWWWMWXXMWWWxl0K00ll0KXK0XNWOlONKodXXKKN0oOWdxWNNWkxXxOWWWWWMMMMMMMMMM\n			0OxxkkkkkOO0OOkO0dxdokkxx0XkxxOXOloolxddocoxccoxkO0d:xOOcckkkdoocdNX0NMWWWWWKXMWWNdlKNXXdl000OkO0KxckXKodNNXKN0oONddNNNWkdKxOMWWWWMMMMMWWWNN\n			0kdxxxxkkOO000kkkddoodxddkOdookXkcoooOxdo:dx:;oxO00o;ldd:;llc:;;,oNX0XWWWWWNKXWWWWdlKNNXdl0XKKO0KXkcx0OloKXKKN0oOWxoXNNWkxXkkWWMWNK0K00OOOOO\n			OxxxdxxxxxkkOOkxxoddlxxddk0doookxllldOddol00:,cddooc,:ll:;c:;,;,'oNX0XWWNNWNKXWNNNdlKWWWxlKNNX0KNNOlOWNddXNKKN0lxNxdXWNWOdXkxNWWWXOO0KKKXK0O\n			kxxxxdddddddxOxdoodolddodxxoddoll:ccoxoxockk:,colcl:,;;c:,,,'';'.oXKOKXXNNNN0KWNNNdc0XXNxlKNNNKXNW0lkWWxdNWNXWXoxNxoXNXNOdKkxNWWWXdcc::;,,''\n			kdoddoooooooddooolollddlllcclc:;;:lc::;cc:lo;,clc:c:,,,;::,...,'.lXKk0XKKXKK0KNNNNdcOXKXdl0XKX0KXNOckWNdoXWXXWXokMkoXWNWOo0kdNWNWKc.''',,,;:\n			Okxkdlllllllllodollcldoc:;;;:;,';:lc,''',,';,.'','';'..,cc,...;..lK0k0XXXXKKOOKKKXd:xOkklcOKKKOO0KkcxXXdlKNXXWNdxWOoKWNWKd0OxXWWWXl,:;,;;;;:\n			OOO0Oolllllllclollollolcccc::;'';:c:,'',,,',,...'..,;..'c:....;..ckOkOKK0K00Ok0OO0o:k0OOocOXXX00KXOcdK0olKWNXWNdxWOoKWNWKd0OdXWWMNxcloodddxx\n			OkOOxlllccc:::colllccllccc:;:;,;::c:,'',,..,;'..'..,;..'c:...':;'ckk |  \\/  | __| __| | | | |_ _ (_)_ _____ _ _ __(_) |_ _  _ WWWW0xxxxxddoo\n			0OkOdcc:;:::::clcllccllc::;;:;;;::c:::;:;,.,;;'.'..;:;;cclllllccldkk | |\\/| | _|| _|  | |_| | ' \\| \\ V / -_) '_(_-< |  _| || |WWWNd.........\n			0Okko;;;;::::;clcllccccc:::;;::c::l::cclc::cccc:cloolloooooollcccdkO |_|  |_|___|_|    \\___/|_||_|_|\\_/\\___|_| /__/_|\\__|\\_, |0WWWWx,;,;:...\n			OOOkc'',,;;;;;clcllc:c::::::::cllclllolodolooollccc:::;;;,''....'okkoodddooodxxdddxkxxxxxxxxxkOOkxk00OkOOkO00k0K00XKKKKKK|__/ x0WWWWx':;;l'.\n			kkOk:..'',,,,,:ccllcllllllollllloc:::;,,,,'........             .:looodddooodxxdddxkxxxxxxxxxkOOkxk00OkOOkO00k0K00XKKKKKXKXXKXXNNNKdlccl::;,\n			xdddl:ccccclllddxxl::;;,,'''.......                     .          ..'''.'............'''',,,;:::::ccc:cccclolodddxxxkOOOO0K0KKKXXNk;;;,;;;;\n			kxxd:'''''''',,,,,'..........................                       ,::::l,                       ..  ..'.    .. .........';;'';;;;'........\n			kooo.            ..',,::,''''................. .      .   .    .....:doodkc. ....  ...          ....  .:dc             . .'l:  .'....  .  ..\n			dllc.       ..  ....'''..................  ......     .....    .....ckkkk0l.  ...  .......   .......  'lOo.  ........,,,'.:ko'',;,....     .\n			lcc;....... ..  .,..'.......................'................ .....'lOkOOKo.  ... ........   ....';,..,o0d. ........:occ:,lOo..,:c,..      ;\n			c'............  ':.......  .. ..............,................ .,,,,,o0OO0Ko.  .:. .::;,;;'. ....',,,,';dKx. ........','..,cdl..,;cl:,.     ;\n			c:;,;::;::::;,..,;''.'''.............  . . .,.,'       ...... .... .o0000Kd.  .;. .:cc:cc,......''....:d0Ol::::;:;;;;;,..,c:'...',cc;......:\n			lcc:,:clodxkkkkxdool;;:;;;;;:::;,,''''.....',';,.....  .   ..  .   .o0000Ko.  .....',,,;:,. .....'''.,cdOXXKKKKKKKK00K0Okl;''',;..,lxdddolcx\n			lccccc::clodkxxkxkOOOkxdolc::::;;;;::::c:::c;';,.....  ..  ..  .   .o0000Ko.  .... .. ..... ...''.',,;:dOKKKXXXXXNNXNNNNXd:,;coc..;oXKOK0odX\n			ccccllllc::loc;lccxk000KK0OOOkxdocc:::;;;;:c;';,. ... ... ...      .o0000Ko.   ............'',,;'..',,:d0KxdkkOOkO0OOOOOOd:;,,::'',cdocll::o\n			cccllccllcclc;.,,.,okkOKKKXXXKKK0OOOkxolcc:c:,:;..''''......       .oK00KXd. ....',,,',,;;;;;;;;'.';;,;dOKkoooddddoooooolll::;',,;;:::::;;;:\n			ooooooloolc::,',..,lkxxOXXXKKKKK00KXXK0000Okxddddxxxxxdlc:;;;;;;;:ccxK00KKx,'',,;;;;;::::cccllc;;:,',;ldkOkl;:c:;:;,,,,,,,,,,:::::::::::::::\n			:oxkxddddoc:,':l:;,;lloOXKKK0KKKXKKKK000KKK0KK0OOkxddxxxxxxxxdddlodcdK000Kklccllllllloooolllll:,,;,..,:ldxkkkOkkxxxdddoolollllcccc::cl;,,,;:\n			.,coddddoc:;'';ll,.,ooxKXXXXXXXXXXXXXXKKKKKK00KKKKK00OOkkxxxxddddddlxKKKKXOxxooddollllccccccc:;,'...,:;,,:oldxlxOxk00000KK000KK0K0kxkklcdoco\n			,;clooolll:;'.';;:;:lokKXXXXXXXXXXXXXXXKKKKKKKXXKKKKKKKKKKK0OkOOkxxxk000Oxolccccc::;;;;;;;;;;;,'''','';,,;;;;;,::,clcolckOolodxdlkx;;c;,::,;\n			cccclddlccc::;;,';:;;:dKXKKXXKXKKKK000KKXXKKKXXXXXXXKKKKKXXXKKKKK00OOOOOOkkkxddooolcc::;;:;,,,',;;',;,,;,;,;;;;;::;;:;;;co:;;;:;;::;;;;;::::\n			;cxkxlccloo:,,....'..';oxkOKKXKK0dl::xKKXXXXXXXXXXXXKKKKXXKKXKKKKKKKKKKKKKKKKKKK00OOOOkxxxxdoolcc::;;;;codkOOxddddooooloodollllllllllllloooo\n			::o0X0xloOXXkl;col:,',;'.'lOKKK0d'...:0XXXXKKKKKXXKKKKKKKKKKKKKKXXXXXXXXXXXKXXKKKKKKKKKK0KKK00OOOkkkkkOXNNXKKK0K0000000000000000000000000KKK\n			ocloxXXkoox0NNOddkdodddxxxdxkxxkd;'.,o0KKXXKK00000OKXXXXXKXXXXKKKKKKKKKXKKKKXXKKKKKKKK00KKK0OOKKKXNWWWXXXK00KKKKKKKKKKKKKKKKKK0KK0KKK0K0KK00\n			dl:;cxOdollox0XKxl;:xKOxk0KKK00XNK0kkO0KKXNNKd:;::lkKKXXXXXXKKKKKKKKKKXXXXXXKXXKKKKKKK00KKKXXXNWWWNX00k0KK0KKKKKXKK00KKKKK00KKKKKKKKKKKKKKKK\n			:;;,,,;:;,;::lddl;,;codoc:ldkkxdk0KK0000xOXXXo...',cxOKK0KXK0KKKKKKKKKXXXXXKKKXKKKKKKKKXXNNNWNNXK00O0OO0000000KKKKK0K00000KK00KKKKKK00KKKK0K\n			::;;;;;;,;:;::::::;,;;;;;;;,;:;,,;clollooxxokx;..,,,:xOkddO0O0KKKKK00OO0KK00KKKKKXXXNWWWWNXXK0K000000000O00KK0KKKKKKK00KK0KK0OOO0000O0KK00O0\n			;::::;;:::::clccc:c:;;::ccc:ccc:,,;::;'';:;;::,.....;ddcccodxkkkO00kxocoO0kkO0000XWWWWNNNK0OOk0KK0O000KKKKKXXKXKKKXKK00000KXK000O0KKKKKKKK00\n\n"
    newline: .asciiz "\n"
    buffer: .space 4
    invalid_option: .asciiz "Please enter a valid option"
    breakpoint_prompt: .asciiz "Press Enter to Continue"
    fight_starting: .asciiz "Fight is starting in 5 seconds, get ready!"
    answer_prompt: .asciiz "> Enter Answer: "

    stats_spacing: .asciiz "                    "
    stats_player_HP: .asciiz " [HP]: " 
    stats_player_HP_followup: .asciiz "/100"
    stats_enemy_HP: .asciiz "[ENEMY HP]: "
    stats_enemy_HP_followup: .asciiz "/100"
    stats_finalenemy_HP: .asciiz "???/???"

    debugprompt: .asciiz " ______   _______  _______  __   __  _______    __   __  _______  __    _  __   __ \n|      | |       ||  _    ||  | |  ||       |  |  |_|  ||       ||  |  | ||  | |  |\n|  _    ||    ___|| |_|   ||  | |  ||    ___|  |       ||    ___||   |_| ||  | |  |\n| | |   ||   |___ |       ||  |_|  ||   | __   |       ||   |___ |       ||  |_|  |\n| |_|   ||    ___||  _   | |       ||   ||  |  |       ||    ___||  _    ||       |\n|       ||   |___ | |_|   ||       ||   |_| |  | ||_|| ||   |___ | | |   ||       |\n|______| |_______||_______||_______||_______|  |_|   |_||_______||_|  |__||_______|\n\n"
    debugoptions: .asciiz "[1] Test fight\n[2] Nothingness\n[3] Floor3Elevator"

    startmenu_prompt: .asciiz "Do you want to start the game?\n[1] Start the game\n[2] Use checkpoint code\n"

    testfight_guards: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n                \n                \n                                            #                                               #\n                              {}            | `_' `-' `_' `-' `_' `' `-' `_' `-' `_' `' `-' |            {}\n                             .--.           |                                               |           .--.\n                            /.--.\\          |                                               |          /.--.\\                                                              \n                            |====|          |                                               |          |====|\n                            |`::`|          |                                               |          |`::`|\n                        .-;`\\..../`;_.-^-._ |                                               |      .-;`\\..../`;_.-^-._\n                 /\\\\   /  |...::..|`   :   `|                                               /\\\\   /  |...::..|`   :   `|\n                 |:'\\ |   /'''::''|   .:.   |                                               |:'\\ |   /'''::''|   .:.   | \n                @|\\ /\\;-,/\\   ::  |..:::::..|                                               |\\ /\\;-,/\\   ::  |..:::::..|\n                `||\\ <` >  >._::_.| ':::::' |                                               ||\\ <` >  >._::_.| ':::::' |\n                 || `''`  /   ^^  |   ':'   |                                               || `''`  /   ^^  |   ':'   |\n                 ||       |       \\    :    |                                               ||       |       \\    :    /   \n                 ||       |        \\   :   /|                                               ||       |        \\   :   /\n                 ||       |___/\\___|`-.:.-` |                                               ||       |___/\\___|`-.:.-`\n                 ||        \\_ || _/    `    |                                               ||        \\_ || _/    `\n                 ||        <_ >< _>         |                                               ||        <_ >< _>     \n                 ||        |  ||  |         |                                               ||        |  ||  |\n                 ||        |  ||  |         |                                               ||        |  ||  |\n                 ||       _\\.:||:./_        |                                               ||       _\\.:||:./_\n                 \\/      /____/\\____\\       T                                               \\/      /____/\\____\\\n                \n\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    testfight_dialog: .asciiz "hello world 123\n"
    
    floor3_elevator: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ \n---------------------------------------------\n|               |------------|              |\n|               |            |              |\n|               |------------|              |              ?????\n|---------------------||--------------------|             ??   ?\n|          |          ||         |          |             ?   ??\n|          |          ||         |          |               ???\n|          |          ||         |          |              ??\n|          |          ||         |          |\n|          |          ||         |          |         @@@  ?\n|          |          ||         |          |        @o@o@\n|          |          ||         |          |        @@@@@xxxxx\n|          |          ||         |   |--|   |         @@@    xxxxx\n|          |          ||         |   |..|   |       xxxxxxxxx xxxx\n|          |          ||         |   |..|   |    xxxxxxxxxxxxxxxx\n|          |          ||         |   |..|   |    xxxxxxxxxxxx\n|          |          ||         |   |--|   |   xxxxxxxxxxxxx\n|          |          ||         |          |  xxx  xxxxxxxxx\n|          |          ||         |          |       xxxxxxxxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |     xxxxx   xxxxx\n---------------------------------------------\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    elevator_q1: .asciiz "The organizational changes in processor design have primarily been focused on increasing instruction-level parallelism so that more work could be done in each clock cycle.\n[1]True\n[2]False\n"
    elevator_q2: .asciiz "GPUs are capable of running operating systems.\n[1]True\n[2]False\n"
    elevator_q3: .asciiz "Prefetching algorithms decrease the importance of memory access patterns since now we have pages we need in the main memory.\n[1]True\n[2]False\n"
    elevator_q4: .asciiz "With superscalar organization increased performance can be achieved by increasing the number of parallel pipelines.\n[1]True\n[2]False\n"
    elevator_q5: .asciiz "The caches hold recently accessed data.\n[1]True\n[2]False\n"
.text
main:
    clearterminal
    print(prompt1)
    selection(startmenu_prompt, startgame, checkpoint)

debugmenu:
    clearterminal
    print(debugprompt)
    print(debugoptions)

    # read integer from user
    li $v0, 5
    syscall
    move $t0, $v0

    # check if user entered 1
    li $t1, 1
    beq $t0, $t1, testfight

    # check if user entered 2
    li $t1, 2
    beq $t0, $t1, end
   
    # check if user entered 3 
    li $t1, 3
    beq $t0, $t1, elevatorgame

    # handle else
    j invalid_input

testfight:
    clearterminal
    print(testfight_guards)

    li $t2, 100
    li $t3, 100
    printstats()

    print(testfight_dialog)
    print(testfight_dialog)
    print(testfight_dialog)
    fakebreakpoint

    clearterminal
    print(testfight_guards)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    printregister($t9)

    sleep(5000)

    li $v0, 30
    syscall
    move $t8, $a0 # Store time in $t8
    print(newline)
    printregister($t8)

    j end
    
elevatorgame:
    
    q1:
    clearterminal
    print(floor3_elevator)
    selection(elevator_q1, q1correct, q2)
   
    q1correct:
    add $t4, $t4, 1
    
    q2:
    clearterminal
    print(floor3_elevator)
    selection(elevator_q2, q3, q2correct)
    
    q2correct:
    add $t4, $t4, 1
    
    q3:
    clearterminal
    print(floor3_elevator)
    selection(elevator_q3, q4, q3correct)
   
    q3correct:
    add $t4, $t4, 1
    
    q4:
    clearterminal
    print(floor3_elevator)
    selection(elevator_q4, q4correct, q5)
    
    q4correct:
    add $t4, $t4, 1
    
    q5:
    clearterminal
    print(floor3_elevator)
    selection(elevator_q5, q5correct, elevatorend)
    
    q5correct:
    add $t4, $t4, 1
    
    elevatorend:
    printregister($t4)
    
    j end
    
    
   
startgame:
    print(startmenu_prompt) # test output
    j end

checkpoint:
    print(startmenu_prompt) # test output
    j end

invalid_input:
    print(invalid_option) # test output
    j end

end:

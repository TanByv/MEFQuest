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
    printregister($t3)
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

# Four Way Selection Macro
.macro selection_lib($prompt, $destination1, $destination2, $destination3, $destination34)
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
    
     # check if user entered 3
    li $t1, 3
    beq $t0, $t1, $destination3

    # check if user entered 4
    li $t1, 4
    beq $t0, $t1, $destination4
    
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

# RNG Macro
.macro randomness($upper, $lower)
    li $v0, 42 # syscall for random int
    li $a1, $upper # upper bound
    syscall
    addi $a0, $a0, $lower # add lower bound to result
    move $t5, $a0 # move random int to $t5
.end_macro

# Dialog Randomizer Macro
.macro printrandom($text1, $text2, $text3)
    move $t6, $t5
    randomness(3, 0)
    beq $t5, 0, print_text1
    beq $t5, 1, print_text2
    j print_text3

    print_text1:
        print($text1)
        j macroend

    print_text2:
        print($text2)
        j macroend

    print_text3:
        print($text3)
        j macroend

    macroend:
        move $t5, $t6
.end_macro

# Notes from Tan:
# t0 and t1 is used by macros and other functions, temporary data
# t2 is player HP, t3 is enemy HP, t4 is damage thats going to be dealt (multiplier calculated inside fight)
# t5 is for RNG
# t8 and t9 is used for keeping time
# t6-t7 is temp data

.data
    prompt1: .asciiz "							.88b  d88. d88888b d88888b       .d88b.  db    db d88888b .d8888. d888888b\n							88'YbdP`88 88'     88'          .8P  Y8. 88    88 88'     88'  YP `~~88~~' \n							88  88  88 88ooooo 88ooo        88    88 88    88 88ooooo `8bo.      88    \n							88  88  88 88~~~~~ 88~~~        88    88 88    88 88~~~~~   `Y8b.    88    \n							88  88  88 88.     88           `8P  d8' 88b  d88 88.     db   8D    88    \n							YP  YP  YP Y88888P YP            `Y88'Y8 ~Y8888P' Y88888P `8888Y'    YP    \n\n			MMMMMMMWXOkOOOOO0xOKxON0k0WKOO0MWO0OkNWWKd0XdOMWWMMOlOWNdxWMWNXNOdO0kO00KKKK0KNNNNdl0KKKodNWMNXWMMkdNM0oOMWWWWOdXKdOWNWKd00xXWWMWWMMMMMMMMMM\n			MMMMMMWXOkkOO0OOKk0Kx0N0kKWKkk0MWkOOkNMMKxKKdOMWWMMOl0MNdxNNNXXW0xXX0KXXKKKKOOXNNNdoXWWWdoNMMWNWMMkdXMKoOMMWWMOdXXdOWNNXxO0xKWWMWWMMMMMMMMMM\n			MMMMMWKkkkkOOOOOKOKKx0N0kKW0kk0MN0KkkWMMKxKKdOWNNWWkl0WXooXWMNNW0xXXKNMMWMWNKKXXXXdlKWWWxoNWWNXNWMkoKN0oOMMNWMOdXNxOMWWXxO0dKWWWWWMMMMMMMMMM\n			MMMMWKkkkkkOOOOOKOKKkKNOkKM0kkKMWWXodNWW0o00okX00XNxc0WXodWMWXKXkdK00XNXNWWWXNMMMWxlKNXXolKXNNXNWWko0N0lkMWNNMOdKNxOMWWNxOKx0WNWWWMMMMMMMMMM\n			MMMWKOOkkkkOOOOO0kKKxKNOkKW0OOKMMM0loKNXOlO0lxOx0XNxlKMNloXNNKKXkxNX0XNXXXNX0KNNWWxoNWWWdoKXXX0KXNklKMXokWWXXW0o0NxkMWWWkkXx0WWWWWMMMMMMMMMM\n			WWNKOOOOOOOOO0O00xK0d0XOkKW0kkKMNKl;lOXXxlkOldKKXNNxl0XKloNWWNXXkxNXKNWWWWWNKKNNNNdl0XXXdoNWWNKXXNxcONKoxWWXXW0oOXdxWWWWkkXxOWWMWWMMMMMMMMMM\n			KK0OkOOOkkO0O0O00xOkd0KkkKWOkk0WKlccldxOx:oxclkO00KdcONXldNWWXKKxdXXKNWWWWMWXXMWWWxl0K00ll0KXK0XNWOlONKodXXKKN0oOWdxWNNWkxXxOWWWWWMMMMMMMMMM\n			0OxxkkkkkOO0OOkO0dxdokkxx0XkxxOXOloolxddocoxccoxkO0d:xOOcckkkdoocdNX0NMWWWWWKXMWWNdlKNXXdl000OkO0KxckXKodNNXKN0oONddNNNWkdKxOMWWWWMMMMMWWWNN\n			0kdxxxxkkOO000kkkddoodxddkOdookXkcoooOxdo:dx:;oxO00o;ldd:;llc:;;,oNX0XWWWWWNKXWWWWdlKNNXdl0XKKO0KXkcx0OloKXKKN0oOWxoXNNWkxXkkWWMWNK0K00OOOOO\n			OxxxdxxxxxkkOOkxxoddlxxddk0doookxllldOddol00:,cddooc,:ll:;c:;,;,'oNX0XWWNNWNKXWNNNdlKWWWxlKNNX0KNNOlOWNddXNKKN0lxNxdXWNWOdXkxNWWWXOO0KKKXK0O\n			kxxxxdddddddxOxdoodolddodxxoddoll:ccoxoxockk:,colcl:,;;c:,,,'';'.oXKOKXXNNNN0KWNNNdc0XXNxlKNNNKXNW0lkWWxdNWNXWXoxNxoXNXNOdKkxNWWWXdcc::;,,''\n			kdoddoooooooddooolollddlllcclc:;;:lc::;cc:lo;,clc:c:,,,;::,...,'.lXKk0XKKXKK0KNNNNdcOXKXdl0XKX0KXNOckWNdoXWXXWXokMkoXWNWOo0kdNWNWKc.''',,,;:\n			Okxkdlllllllllodollcldoc:;;;:;,';:lc,''',,';,.'','';'..,cc,...;..lK0k0XXXXKKOOKKKXd:xOkklcOKKKOO0KkcxXXdlKNXXWNdxWOoKWNWKd0OxXWWWXl,:;,;;;;:\n			OOO0Oolllllllclollollolcccc::;'';:c:,'',,,',,...'..,;..'c:....;..ckOkOKK0K00Ok0OO0o:k0OOocOXXX00KXOcdK0olKWNXWNdxWOoKWNWKd0OdXWWMNxcloodddxx\n			OkOOxlllccc:::colllccllccc:;:;,;::c:,'',,..,;'..'..,;..'c:...':;'ckk |  \\/  | __| __| | | | |_ _ (_)_ _____ _ _ __(_) |_ _  _ WWWW0xxxxxddoo\n			0OkOdcc:;:::::clcllccllc::;;:;;;::c:::;:;,.,;;'.'..;:;;cclllllccldkk | |\\/| | _|| _|  | |_| | ' \\| \\ V / -_) '_(_-< |  _| || |WWWNd.........\n			0Okko;;;;::::;clcllccccc:::;;::c::l::cclc::cccc:cloolloooooollcccdkO |_|  |_|___|_|    \\___/|_||_|_|\\_/\\___|_| /__/_|\\__|\\_, |0WWWWx,;,;:...\n			OOOkc'',,;;;;;clcllc:c::::::::cllclllolodolooollccc:::;;;,''....'okkoodddooodxxdddxkxxxxxxxxxkOOkxk00OkOOkO00k0K00XKKKKKK|__/ x0WWWWx':;;l'.\n			kkOk:..'',,,,,:ccllcllllllollllloc:::;,,,,'........             .:looodddooodxxdddxkxxxxxxxxxkOOkxk00OkOOkO00k0K00XKKKKKXKXXKXXNNNKdlccl::;,\n			xdddl:ccccclllddxxl::;;,,'''.......                     .          ..'''.'............'''',,,;:::::ccc:cccclolodddxxxkOOOO0K0KKKXXNk;;;,;;;;\n			kxxd:'''''''',,,,,'..........................                       ,::::l,                       ..  ..'.    .. .........';;'';;;;'........\n			kooo.            ..',,::,''''................. .      .   .    .....:doodkc. ....  ...          ....  .:dc             . .'l:  .'....  .  ..\n			dllc.       ..  ....'''..................  ......     .....    .....ckkkk0l.  ...  .......   .......  'lOo.  ........,,,'.:ko'',;,....     .\n			lcc;....... ..  .,..'.......................'................ .....'lOkOOKo.  ... ........   ....';,..,o0d. ........:occ:,lOo..,:c,..      ;\n			c'............  ':.......  .. ..............,................ .,,,,,o0OO0Ko.  .:. .::;,;;'. ....',,,,';dKx. ........','..,cdl..,;cl:,.     ;\n			c:;,;::;::::;,..,;''.'''.............  . . .,.,'       ...... .... .o0000Kd.  .;. .:cc:cc,......''....:d0Ol::::;:;;;;;,..,c:'...',cc;......:\n			lcc:,:clodxkkkkxdool;;:;;;;;:::;,,''''.....',';,.....  .   ..  .   .o0000Ko.  .....',,,;:,. .....'''.,cdOXXKKKKKKKK00K0Okl;''',;..,lxdddolcx\n			lccccc::clodkxxkxkOOOkxdolc::::;;;;::::c:::c;';,.....  ..  ..  .   .o0000Ko.  .... .. ..... ...''.',,;:dOKKKXXXXXNNXNNNNXd:,;coc..;oXKOK0odX\n			ccccllllc::loc;lccxk000KK0OOOkxdocc:::;;;;:c;';,. ... ... ...      .o0000Ko.   ............'',,;'..',,:d0KxdkkOOkO0OOOOOOd:;,,::'',cdocll::o\n			cccllccllcclc;.,,.,okkOKKKXXXKKK0OOOkxolcc:c:,:;..''''......       .oK00KXd. ....',,,',,;;;;;;;;'.';;,;dOKkoooddddoooooolll::;',,;;:::::;;;:\n			ooooooloolc::,',..,lkxxOXXXKKKKK00KXXK0000Okxddddxxxxxdlc:;;;;;;;:ccxK00KKx,'',,;;;;;::::cccllc;;:,',;ldkOkl;:c:;:;,,,,,,,,,,:::::::::::::::\n			:oxkxddddoc:,':l:;,;lloOXKKK0KKKXKKKK000KKK0KK0OOkxddxxxxxxxxdddlodcdK000Kklccllllllloooolllll:,,;,..,:ldxkkkOkkxxxdddoolollllcccc::cl;,,,;:\n			.,coddddoc:;'';ll,.,ooxKXXXXXXXXXXXXXXKKKKKK00KKKKK00OOkkxxxxddddddlxKKKKXOxxooddollllccccccc:;,'...,:;,,:oldxlxOxk00000KK000KK0K0kxkklcdoco\n			,;clooolll:;'.';;:;:lokKXXXXXXXXXXXXXXXKKKKKKKXXKKKKKKKKKKK0OkOOkxxxk000Oxolccccc::;;;;;;;;;;;,'''','';,,;;;;;,::,clcolckOolodxdlkx;;c;,::,;\n			cccclddlccc::;;,';:;;:dKXKKXXKXKKKK000KKXXKKKXXXXXXXKKKKKXXXKKKKK00OOOOOOkkkxddooolcc::;;:;,,,',;;',;,,;,;,;;;;;::;;:;;;co:;;;:;;::;;;;;::::\n			;cxkxlccloo:,,....'..';oxkOKKXKK0dl::xKKXXXXXXXXXXXXKKKKXXKKXKKKKKKKKKKKKKKKKKKK00OOOOkxxxxdoolcc::;;;;codkOOxddddooooloodollllllllllllloooo\n			::o0X0xloOXXkl;col:,',;'.'lOKKK0d'...:0XXXXKKKKKXXKKKKKKKKKKKKKKXXXXXXXXXXXKXXKKKKKKKKKK0KKK00OOOkkkkkOXNNXKKK0K0000000000000000000000000KKK\n			ocloxXXkoox0NNOddkdodddxxxdxkxxkd;'.,o0KKXXKK00000OKXXXXXKXXXXKKKKKKKKKXKKKKXXKKKKKKKK00KKK0OOKKKXNWWWXXXK00KKKKKKKKKKKKKKKKKK0KK0KKK0K0KK00\n			dl:;cxOdollox0XKxl;:xKOxk0KKK00XNK0kkO0KKXNNKd:;::lkKKXXXXXXKKKKKKKKKKXXXXXXKXXKKKKKKK00KKKXXXNWWWNX00k0KK0KKKKKXKK00KKKKK00KKKKKKKKKKKKKKKK\n			:;;,,,;:;,;::lddl;,;codoc:ldkkxdk0KK0000xOXXXo...',cxOKK0KXK0KKKKKKKKKXXXXXKKKXKKKKKKKKXXNNNWNNXK00O0OO0000000KKKKK0K00000KK00KKKKKK00KKKK0K\n			::;;;;;;,;:;::::::;,;;;;;;;,;:;,,;clollooxxokx;..,,,:xOkddO0O0KKKKK00OO0KK00KKKKKXXXNWWWWNXXK0K000000000O00KK0KKKKKKK00KK0KK0OOO0000O0KK00O0\n			;::::;;:::::clccc:c:;;::ccc:ccc:,,;::;'';:;;::,.....;ddcccodxkkkO00kxocoO0kkO0000XWWWWNNNK0OOk0KK0O000KKKKKXXKXKKKXKK00000KXK000O0KKKKKKKK00\n\n"
    newline: .asciiz "\n"
    buffer: .space 4
    invalid_option: .asciiz "Please enter a valid option"
    breakpoint_prompt: .asciiz "Press enter to continue"
    fight_starting: .asciiz "Fight is starting in 5 seconds, get ready!\n"
    answer_prompt: .asciiz "> Enter answer: "

    stats_spacing: .asciiz "                    "
    stats_player_HP: .asciiz " [HP]: " 
    stats_player_HP_followup: .asciiz "/100"
    stats_enemy_HP: .asciiz "[ENEMY HP]: "
    stats_enemy_HP_followup: .asciiz "/100"
    stats_finalenemy_HP: .asciiz "???/???"

    debugprompt: .asciiz " ______   _______  _______  __   __  _______    __   __  _______  __    _  __   __ \n|      | |       ||  _    ||  | |  ||       |  |  |_|  ||       ||  |  | ||  | |  |\n|  _    ||    ___|| |_|   ||  | |  ||    ___|  |       ||    ___||   |_| ||  | |  |\n| | |   ||   |___ |       ||  |_|  ||   | __   |       ||   |___ |       ||  |_|  |\n| |_|   ||    ___||  _   | |       ||   ||  |  |       ||    ___||  _    ||       |\n|       ||   |___ | |_|   ||       ||   |_| |  | ||_|| ||   |___ | | |   ||       |\n|______| |_______||_______||_______||_______|  |_|   |_||_______||_|  |__||_______|\n\n"
    debugoptions: .asciiz "[1] Test fight\n[2] Nothingness\n[3] Floor3_Elevator\n"

    startmenu_prompt: .asciiz "Do you want to start the game?\n[1] Start the game\n[2] Use checkpoint code\n"
    enemyvanquished: .asciiz "\n\n@@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@@@@   @@@ @@@           @@@  @@@   @@@@@@   @@@  @@@   @@@@@@    @@@  @@@  @@@   @@@@@@   @@@  @@@  @@@@@@@@  @@@@@@@   \n@@@@@@@@  @@@@ @@@  @@@@@@@@  @@@@@@@@@@@  @@@ @@@           @@@  @@@  @@@@@@@@  @@@@ @@@  @@@@@@@@   @@@  @@@  @@@  @@@@@@@   @@@  @@@  @@@@@@@@  @@@@@@@@  \n@@!       @@!@!@@@  @@!       @@! @@! @@!  @@! !@@           @@!  @@@  @@!  @@@  @@!@!@@@  @@!  @@@   @@!  @@@  @@!  !@@       @@!  @@@  @@!       @@!  @@@  \n!@!       !@!!@!@!  !@!       !@! !@! !@!  !@! @!!           !@!  @!@  !@!  @!@  !@!!@!@!  !@!  @!@   !@!  @!@  !@!  !@!       !@!  @!@  !@!       !@!  @!@  \n@!!!:!    @!@ !!@!  @!!!:!    @!! !!@ @!@   !@!@!            @!@  !@!  @!@!@!@!  @!@ !!@!  @!@  !@!   @!@  !@!  !!@  !!@@!!    @!@!@!@!  @!!!:!    @!@  !@!  \n!!!!!:    !@!  !!!  !!!!!:    !@!   ! !@!    @!!!            !@!  !!!  !!!@!!!!  !@!  !!!  !@!  !!!   !@!  !!!  !!!   !!@!!!   !!!@!!!!  !!!!!:    !@!  !!!  \n!!:       !!:  !!!  !!:       !!:     !!:    !!:             :!:  !!:  !!:  !!!  !!:  !!!  !!:!!:!:   !!:  !!!  !!:       !:!  !!:  !!!  !!:       !!:  !!!  \n:!:       :!:  !:!  :!:       :!:     :!:    :!:              ::!!:!   :!:  !:!  :!:  !:!  :!: :!:    :!:  !:!  :!:      !:!   :!:  !:!  :!:       :!:  !:!  \n :: ::::   ::   ::   :: ::::  :::     ::      ::               ::::    ::   :::   ::   ::  ::::: :!   ::::: ::   ::  :::: ::   ::   :::   :: ::::   :::: ::  \n: :: ::   ::    :   : :: ::    :      :       :                 :       :   : :  ::    :    : :  :::   : :  :   :    :: : :     :   : :  : :: ::   :: :  :   \n\n"

    testfight_guards: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n                \n                \n                                            #                                               #\n                              {}            | `_' `-' `_' `-' `_' `' `-' `_' `-' `_' `' `-' |            {}\n                             .--.           |                                               |           .--.\n                            /.--.\\          |                                               |          /.--.\\                                                              \n                            |====|          |                                               |          |====|\n                            |`::`|          |                                               |          |`::`|\n                        .-;`\\..../`;_.-^-._ |                                               |      .-;`\\..../`;_.-^-._\n                 /\\\\   /  |...::..|`   :   `|                                               /\\\\   /  |...::..|`   :   `|\n                 |:'\\ |   /'''::''|   .:.   |                                               |:'\\ |   /'''::''|   .:.   | \n                @|\\ /\\;-,/\\   ::  |..:::::..|                                               |\\ /\\;-,/\\   ::  |..:::::..|\n                `||\\ <` >  >._::_.| ':::::' |                                               ||\\ <` >  >._::_.| ':::::' |\n                 || `''`  /   ^^  |   ':'   |                                               || `''`  /   ^^  |   ':'   |\n                 ||       |       \\    :    |                                               ||       |       \\    :    /   \n                 ||       |        \\   :   /|                                               ||       |        \\   :   /\n                 ||       |___/\\___|`-.:.-` |                                               ||       |___/\\___|`-.:.-`\n                 ||        \\_ || _/    `    |                                               ||        \\_ || _/    `\n                 ||        <_ >< _>         |                                               ||        <_ >< _>     \n                 ||        |  ||  |         |                                               ||        |  ||  |\n                 ||        |  ||  |         |                                               ||        |  ||  |\n                 ||       _\\.:||:./_        |                                               ||       _\\.:||:./_\n                 \\/      /____/\\____\\       T                                               \\/      /____/\\____\\\n                \n\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    testfight_dialog: .asciiz "hello world 123\n\n"
    testfight_instruction: .asciiz "Write this number as quickly as possible and press enter: "
    testfight_takehit: .asciiz "Guards: ARGHH-!\n\n> You dealt "
    testfight_takehit2: .asciiz " damage.\n\n"
    testfight_hitplayer_dialog: .asciiz "Guards: Take this!\n\n> You took "
    testfight_youwin: .asciiz "Congrats you won\n\n"
    
    floor3_elevator: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ \n---------------------------------------------\n|               |------------|              |\n|               |            |              |\n|               |------------|              |              ?????\n|---------------------||--------------------|             ??   ?\n|          |          ||         |          |             ?   ??\n|          |          ||         |          |               ???\n|          |          ||         |          |              ??\n|          |          ||         |          |\n|          |          ||         |          |         @@@  ?\n|          |          ||         |          |        @o@o@\n|          |          ||         |          |        @@@@@xxxxx\n|          |          ||         |   |--|   |         @@@    xxxxx\n|          |          ||         |   |..|   |       xxxxxxxxx xxxx\n|          |          ||         |   |..|   |    xxxxxxxxxxxxxxxx\n|          |          ||         |   |..|   |    xxxxxxxxxxxx\n|          |          ||         |   |--|   |   xxxxxxxxxxxxx\n|          |          ||         |          |  xxx  xxxxxxxxx\n|          |          ||         |          |       xxxxxxxxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |       xxx   xxx\n|          |          ||         |          |     xxxxx   xxxxx\n---------------------------------------------\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    elevator_q1: .asciiz "The organizational changes in processor design have primarily been focused on increasing instruction-level parallelism so that more work could be done in each clock cycle.\n[1]True\n[2]False\n"
    elevator_q2: .asciiz "GPUs are capable of running operating systems.\n[1]True\n[2]False\n"
    elevator_q3: .asciiz "Prefetching algorithms decrease the importance of memory access patterns since now we have pages we need in the main memory.\n[1]True\n[2]False\n"
    elevator_q4: .asciiz "With superscalar organization increased performance can be achieved by increasing the number of parallel pipelines.\n[1]True\n[2]False\n"
    elevator_q5: .asciiz "The caches hold recently accessed data.\n[1]True\n[2]False\n"

    floor0_backstory_art: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n	kxxxxdddddddxOxdoodolddodxxoddoll:ccoxoxockk:,colcl:,;;c:,,,'';'.oXKOKXXNNNN0KWNNNdc0XXNxlKNNNKXNW0lkWWxdNWNXWXoxNxoXNXNOdKkxNWWWXdcc::;,,''\n	kdoddoooooooddooolollddlllcclc:;;:lc::;cc:lo;,clc:c:,,,;::,...,'.lXKk0XKKXKK0KNNNNdcOXKXdl0XKX0KXNOckWNdoXWXXWXokMkoXWNWOo0kdNWNWKc.''',,,;:\n	Okxkdlllllllllodollcldoc:;;;:;,';:lc,''',,';,.'','';'..,cc,...;..lK0k0XXXXKKOOKKKXd:xOkklcOKKKOO0KkcxXXdlKNXXWNdxWOoKWNWKd0OxXWWWXl,:;,;;;;:\n	OOO0Oolllllllclollollolcccc::;'';:c:,'',,,',,...'..,;..'c:....;..ckOkOKK0K00Ok0OO0o:k0OOocOXXX00KXOcdK0olKWNXWNdxWOoKWNWKd0OdXWWMNxcloodddxx\n	OkOOxlllccc:::colllccllccc:;:;,;::c:,'',,..,;'..'..,;..'c:...':;'ckk |  \\/  | __| __| | | | |_ _ (_)_ _____ _ _ __(_) |_ _  _ WWWW0xxxxxddoo\n	0OkOdcc:;:::::clcllccllc::;;:;;;::c:::;:;,.,;;'.'..;:;;cclllllccldkk | |\\/| | _|| _|  | |_| | ' \\| \\ V / -_) '_(_-< |  _| || |WWWNd.........\n	0Okko;;;;::::;clcllccccc:::;;::c::l::cclc::cccc:cloolloooooollcccdkO |_|  |_|___|_|    \\___/|_||_|_|\\_/\\___|_| /__/_|\\__|\\_, |0WWWWx,;,;:...\n	OOOkc'',,;;;;;clcllc:c::::::::cllclllolodolooollccc:::;;;,''....'okkoodddooodxxdddxkxxxxxxxxxkOOkxk00OkOOkO00k0K00XKKKKKK|__/ x0WWWWx':;;l'.\n	kkOk:..'',,,,,:ccllcllllllollllloc:::;,,,,'........             .:looodddooodxxdddxkxxxxxxxxxkOOkxk00OkOOkO00k0K00XKKKKKXKXXKXXNNNKdlccl::;,\n	xdddl:ccccclllddxxl::;;,,'''.......                     .          ..'''.'............'''',,,;:::::ccc:cccclolodddxxxkOOOO0K0KKKXXNk;;;,;;;;\n	kxxd:'''''''',,,,,'..........................                       ,::::l,                       ..  ..'.    .. .........';;'';;;;'........\n	kooo.            ..',,::,''''................. .      .   .    .....:doodkc. ....  ...          ....  .:dc             . .'l:  .'....  .  ..\n	dllc.       ..  ....'''..................  ......     .....    .....ckkkk0l.  ...  .......   .......  'lOo.  ........,,,'.:ko'',;,....     .\n	lcc;....... ..  .,..'.......................'................ .....'lOkOOKo.  ... ........   ....';,..,o0d. ........:occ:,lOo..,:c,..      ;\n	c'............  ':.......  .. ..............,................ .,,,,,o0OO0Ko.  .:. .::;,;;'. ....',,,,';dKx. ........','..,cdl..,;cl:,.     ;\n	c:;,;::;::::;,..,;''.'''.............  . . .,.,'       ...... .... .o0000Kd.  .;. .:cc:cc,......''....:d0Ol::::;:;;;;;,..,c:'...',cc;......:\n	lcc:,:clodxkkkkxdool;;:;;;;;:::;,,''''.....',';,.....  .   ..  .   .o0000Ko.  .....',,,;:,. .....'''.,cdOXXKKKKKKKK00K0Okl;''',;..,lxdddolcx\n	lccccc::clodkxxkxkOOOkxdolc::::;;;;::::c:::c;';,.....  ..  ..  .   .o0000Ko.  .... .. ..... ...''.',,;:dOKKKXXXXXNNXNNNNXd:,;coc..;oXKOK0odX\n	ccccllllc::loc;lccxk000KK0OOOkxdocc:::;;;;:c;';,. ... ... ...      .o0000Ko.   ............'',,;'..',,:d0KxdkkOOkO0OOOOOOd:;,,::'',cdocll::o\n	cccllccllcclc;.,,.,okkOKKKXXXKKK0OOOkxolcc:c:,:;..''''......       .oK00KXd. ....',,,',,;;;;;;;;'.';;,;dOKkoooddddoooooolll::;',,;;:::::;;;:\n	ooooooloolc::,',..,lkxxOXXXKKKKK00KXXK0000Okxddddxxxxxdlc:;;;;;;;:ccxK00KKx,'',,;;;;;::::cccllc;;:,',;ldkOkl;:c:;:;,,,,,,,,,,:::::::::::::::\n	:oxkxddddoc:,':l:;,;lloOXKKK0KKKXKKKK000KKK0KK0OOkxddxxxxxxxxdddlodcdK000Kklccllllllloooolllll:,,;,..,:ldxkkkOkkxxxdddoolollllcccc::cl;,,,;:\n	.,coddddoc:;'';ll,.,ooxKXXXXXXXXXXXXXXKKKKKK00KKKKK00OOkkxxxxddddddlxKKKKXOxxooddollllccccccc:;,'...,:;,,:oldxlxOxk00000KK000KK0K0kxkklcdoco\n	,;clooolll:;'.';;:;:lokKXXXXXXXXXXXXXXXKKKKKKKXXKKKKKKKKKKK0OkOOkxxxk000Oxolccccc::;;;;;;;;;;;,'''','';,,;;;;;,::,clcolckOolodxdlkx;;c;,::,;\n	cccclddlccc::;;,';:;;:dKXKKXXKXKKKK000KKXXKKKXXXXXXXKKKKKXXXKKKKK00OOOOOOkkkxddooolcc::;;:;,,,',;;',;,,;,;,;;;;;::;;:;;;co:;;;:;;::;;;;;::::\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    floor0_backstory_text: .asciiz "Ercan Korkut has declared the program of 'Yetmez Gencler' mandatory for the all students of MEF University.\n\nHis plans were unpredictable; he wanted both students and instructors to become his puppets.\n\nHe has manipulated everyone with brainwashing videos of 'Yetmez Gencler'.\n\nOne day Ercan noticed a unexpected outlier. One of the students were not watching the videos...\n\nWhen he tried reaching out to that student it was already too late for him, Ms Yilmaz have already figured out Ercan's plans.\n\nMs. Yilmaz has reached to the student before Ercan could. She told him about devilish plans of Ercan and he was the only one left who could stop him.\n\nMs. Yilmaz managed to stay unaffected by the videos because she noticed the true purposes of them. However, Ercan was aware of who watched those videos and who didn't.\n\nNoticing that Ms. Yilmaz manage to resist the brainwashing videos, he set out to capture her.\n\nBy the time you arrive at to the campus almost all studens and school personel have been converted into mindless zombies.\n\nAccepting the sitation you're in, you approach the gates of the campus.\n\n\n"

    sliceview_floor0: .asciiz "_################################################################################\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |    |     xxxxx    |\n  |                 |     |          | |____|  ||  |____| |  | && |     x        |\n  |                 |     |          |  ____ ==||== ____  |  |&&&&|     xxxxx    |\n  |                 |    O|          | |    |  ||  |    | |  |_&&&|         x    |\n  |                 |     |          | |____|  ||  |____| |             xxxxx    |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |\\  /|     x   x    |\n  |                 |     |          | |____|  ||  |____| |  | /  |     x   x    |\n  |                 |     |          |  ____ ==||== ____  |  |/ \\ |     xxxxx    |\n  |                 |    O|          | |    |  ||  |    | |  |/__\\|         x    |\n  |                 |     |          | |____|  ||  |____| |                 x    |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |\\####|          | |    |  ||  |    | |  | #  |     xxxxx    |\n  |                 | \\###|          | |____|  ||  |____| |  | ## |         x    |\n  |                 |  \\ #|          |  ____ ==||== ____  |  |### |       xxx    |\n  |                 |  |##|          | |    |  ||  |    | |  |____|         x    |\n  |                 | o|##|          | |____|  ||  |____| |             xxxxx    |\n  |_________________|__|__|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  | @@ |     xxxxx    |\n  |                 |     |          | |____|  ||  |____| |  |@@  |         x    |\n  |                 |     |          |  ____ ==||== ____  |  | @@@|     xxxxx    |\n  |                 |    O|          | |    |  ||  |    | |  |@___|     x        |\n  |                 |     |          | |____|  ||  |____| |             xxxxx    |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |$$$$|        x     |\n  |                 |     |          | |____|  ||  |____| |  |$$$$|       xx     |\n  |                 |     |          |  ____ ==||== ____  |  | $$ |      x x     |\n  |                 |    O|          | |    |  ||  |    | |  |_$__|        x     |\n  |                 |     |          | |____|  ||  |____| |              xxxxx   |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |    |      xxxxx   |\n  |     __O         |     |          | |____|  ||  |____| |  | @@ |      x   x   |\n  |    / /\\_,       |     |          |  ____ ==||== ____  |  |@@@@|      x   x   |\n  |   ___/\\         |    O|          | |    |  ||  |    | |  |___@|      x   x   |\n  |       /_        |     |          | |____|  ||  |____| |              xxxxx   |\n  |_________________|_____|__________|____________________|______________________|\n\n> Entering Floor 0.\n\n\n "
    sliceview_floor1: .asciiz "_#################################################################################\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |    |     xxxxx    |\n   |                 |     |          | |____|  ||  |____| |  | && |     x        |\n   |                 |     |          |  ____ ==||== ____  |  |&&&&|     xxxxx    |\n   |                 |    O|          | |    |  ||  |    | |  |_&&&|         x    |\n   |                 |     |          | |____|  ||  |____| |             xxxxx    |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |\\  /|     x   x    |\n   |                 |     |          | |____|  ||  |____| |  | /  |     x   x    |\n   |                 |     |          |  ____ ==||== ____  |  |/ \\ |     xxxxx    |\n   |                 |    O|          | |    |  ||  |    | |  |/__\\|         x    |\n   |                 |     |          | |____|  ||  |____| |                 x    |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |\\####|          | |    |  ||  |    | |  | #  |     xxxxx    |\n   |                 | \\###|          | |____|  ||  |____| |  | ## |         x    |\n   |                 |  \\ #|          |  ____ ==||== ____  |  |### |       xxx    |\n   |                 |  |##|          | |    |  ||  |    | |  |____|         x    |\n   |                 | o|##|          | |____|  ||  |____| |             xxxxx    |\n   |_________________|__|__|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  | @@ |     xxxxx    |\n   |                 |     |          | |____|  ||  |____| |  |@@  |         x    |\n   |                 |     |          |  ____ ==||== ____  |  | @@@|     xxxxx    |\n   |                 |    O|          | |    |  ||  |    | |  |@___|     x        |\n   |                 |     |          | |____|  ||  |____| |             xxxxx    |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |$$$$|        x     |\n   |     __O         |     |          | |____|  ||  |____| |  |$$$$|       xx     |\n   |    / /\\_,       |     |          |  ____ ==||== ____  |  | $$ |      x x     |\n   |   ___/\\         |    O|          | |    |  ||  |    | |  |_$__|        x     |\n   |       /_        |     |          | |____|  ||  |____| |              xxxxx   |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |    |      xxxxx   |\n   |                 |     |          | |____|  ||  |____| |  | @@ |      x   x   |\n   |                 |     |          |  ____ ==||== ____  |  |@@@@|      x   x   |\n   |                 |    O|          | |    |  ||  |    | |  |___@|      x   x   |\n   |                 |     |          | |____|  ||  |____| |              xxxxx   |\n   |_________________|_____|__________|____________________|______________________|\n\n> Entering Floor 1.\n\n\n"
    sliceview_floor2: .asciiz "_################################################################################\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |    |     xxxxx    |\n  |                 |     |          | |____|  ||  |____| |  | && |     x        |\n  |                 |     |          |  ____ ==||== ____  |  |&&&&|     xxxxx    |\n  |                 |    O|          | |    |  ||  |    | |  |_&&&|         x    |\n  |                 |     |          | |____|  ||  |____| |             xxxxx    |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |\\  /|     x   x    |\n  |                 |     |          | |____|  ||  |____| |  | /  |     x   x    |\n  |                 |     |          |  ____ ==||== ____  |  |/ \\ |     xxxxx    |\n  |                 |    O|          | |    |  ||  |    | |  |/__\\|         x    |\n  |                 |     |          | |____|  ||  |____| |                 x    |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |\\####|          | |    |  ||  |    | |  | #  |     xxxxx    |\n  |                 | \\###|          | |____|  ||  |____| |  | ## |         x    |\n  |                 |  \\ #|          |  ____ ==||== ____  |  |### |       xxx    |\n  |                 |  |##|          | |    |  ||  |    | |  |____|         x    |\n  |                 | o|##|          | |____|  ||  |____| |             xxxxx    |\n  |_________________|__|__|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  | @@ |     xxxxx    |\n  |     __O         |     |          | |____|  ||  |____| |  |@@  |         x    |\n  |    / /\\_,       |     |          |  ____ ==||== ____  |  | @@@|     xxxxx    |\n  |   ___/\\         |    O|          | |    |  ||  |    | |  |@___|     x        |\n  |       /_        |     |          | |____|  ||  |____| |             xxxxx    |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |$$$$|        x     |\n  |                 |     |          | |____|  ||  |____| |  |$$$$|       xx     |\n  |                 |     |          |  ____ ==||== ____  |  | $$ |      x x     |\n  |                 |    O|          | |    |  ||  |    | |  |_$__|        x     |\n  |                 |     |          | |____|  ||  |____| |              xxxxx   |\n  |_________________|_____|__________|____________________|______________________|\n  |                  _____           |  ____   ||   ____  |   ____               |\n  |                 |     |          | |    |  ||  |    | |  |    |      xxxxx   |\n  |                 |     |          | |____|  ||  |____| |  | @@ |      x   x   |\n  |                 |     |          |  ____ ==||== ____  |  |@@@@|      x   x   |\n  |                 |    O|          | |    |  ||  |    | |  |___@|      x   x   |\n  |                 |     |          | |____|  ||  |____| |              xxxxx   |\n  |_________________|_____|__________|____________________|______________________|\n\n> Entering Floor 2.\n\n\n"
    sliceview_floor3: .asciiz "_################################################################################\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |    |     xxxxx    |\n   |                 |     |          | |____|  ||  |____| |  | && |     x        |\n   |                 |     |          |  ____ ==||== ____  |  |&&&&|     xxxxx    |\n   |                 |    O|          | |    |  ||  |    | |  |_&&&|         x    |\n   |                 |     |          | |____|  ||  |____| |             xxxxx    |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |\\  /|     x   x    |\n   |                 |     |          | |____|  ||  |____| |  | /  |     x   x    |\n   |                 |     |          |  ____ ==||== ____  |  |/ \\ |     xxxxx    |\n   |                 |    O|          | |    |  ||  |    | |  |/__\\|         x    |\n   |                 |     |          | |____|  ||  |____| |                 x    |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |\\####|          | |    |  ||  |    | |  | #  |     xxxxx    |\n   |      __O        | \\###|          | |____|  ||  |____| |  | ## |         x    |\n   |     / /\\_,      |  \\ #|          |  ____ ==||== ____  |  |### |       xxx    |\n   |    ___/\\        |  |##|          | |    |  ||  |    | |  |____|         x    |\n   |        /_       | o|##|          | |____|  ||  |____| |             xxxxx    |\n   |_________________|__|__|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  | @@ |     xxxxx    |\n   |                 |     |          | |____|  ||  |____| |  |@@  |         x    |\n   |                 |     |          |  ____ ==||== ____  |  | @@@|     xxxxx    |\n   |                 |    O|          | |    |  ||  |    | |  |@___|     x        |\n   |                 |     |          | |____|  ||  |____| |             xxxxx    |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |$$$$|        x     |\n   |                 |     |          | |____|  ||  |____| |  |$$$$|       xx     |\n   |                 |     |          |  ____ ==||== ____  |  | $$ |      x x     |\n   |                 |    O|          | |    |  ||  |    | |  |_$__|        x     |\n   |                 |     |          | |____|  ||  |____| |              xxxxx   |\n   |_________________|_____|__________|____________________|______________________|\n   |                  _____           |  ____   ||   ____  |   ____               |\n   |                 |     |          | |    |  ||  |    | |  |    |      xxxxx   |\n   |                 |     |          | |____|  ||  |____| |  | @@ |      x   x   |\n   |                 |     |          |  ____ ==||== ____  |  |@@@@|      x   x   |\n   |                 |    O|          | |    |  ||  |    | |  |___@|      x   x   |\n   |                 |     |          | |____|  ||  |____| |              xxxxx   |\n   |_________________|_____|__________|____________________|______________________|\n\n> Entering Floor 3.\n\n\n"
    sliceview_floor5: .asciiz "_################################################################################\n |                  _____           |  ____   ||   ____  |   ____               |\n |                 |     |          | |    |  ||  |    | |  |    |     xxxxx    |\n |       __O       |     |          | |____|  ||  |____| |  | && |     x        |\n |      / /\\_,     |     |          |  ____ ==||== ____  |  |&&&&|     xxxxx    |\n |     ___/\\       |    O|          | |    |  ||  |    | |  |_&&&|         x    |\n |         /_      |     |          | |____|  ||  |____| |             xxxxx    |\n |_________________|_____|__________|____________________|______________________|\n |                  _____           |  ____   ||   ____  |   ____               |\n |                 |     |          | |    |  ||  |    | |  |\\  /|     x   x    |\n |                 |     |          | |____|  ||  |____| |  | /  |     x   x    |\n |                 |     |          |  ____ ==||== ____  |  |/ \\ |     xxxxx    |\n |                 |    O|          | |    |  ||  |    | |  |/__\\|         x    |\n |                 |     |          | |____|  ||  |____| |                 x    |\n |_________________|_____|__________|____________________|______________________|\n |                  _____           |  ____   ||   ____  |   ____               |\n |                 |\\####|          | |    |  ||  |    | |  | #  |     xxxxx    |\n |                 | \\###|          | |____|  ||  |____| |  | ## |         x    |\n |                 |  \\ #|          |  ____ ==||== ____  |  |### |       xxx    |\n |                 |  |##|          | |    |  ||  |    | |  |____|         x    |\n |                 | o|##|          | |____|  ||  |____| |             xxxxx    |\n |_________________|__|__|__________|____________________|______________________|\n |                  _____           |  ____   ||   ____  |   ____               |\n |                 |     |          | |    |  ||  |    | |  | @@ |     xxxxx    |\n |                 |     |          | |____|  ||  |____| |  |@@  |         x    |\n |                 |     |          |  ____ ==||== ____  |  | @@@|     xxxxx    |\n |                 |    O|          | |    |  ||  |    | |  |@___|     x        |\n |                 |     |          | |____|  ||  |____| |             xxxxx    |\n |_________________|_____|__________|____________________|______________________|\n |                  _____           |  ____   ||   ____  |   ____               |\n |                 |     |          | |    |  ||  |    | |  |$$$$|        x     |\n |                 |     |          | |____|  ||  |____| |  |$$$$|       xx     |\n |                 |     |          |  ____ ==||== ____  |  | $$ |      x x     |\n |                 |    O|          | |    |  ||  |    | |  |_$__|        x     |\n |                 |     |          | |____|  ||  |____| |              xxxxx   |\n |_________________|_____|__________|____________________|______________________|\n |                  _____           |  ____   ||   ____  |   ____               |\n |                 |     |          | |    |  ||  |    | |  |    |      xxxxx   |\n |                 |     |          | |____|  ||  |____| |  | @@ |      x   x   |\n |                 |     |          |  ____ ==||== ____  |  |@@@@|      x   x   |\n |                 |    O|          | |    |  ||  |    | |  |___@|      x   x   |\n |                 |     |          | |____|  ||  |____| |              xxxxx   |\n |_________________|_____|__________|____________________|______________________|\n\n> Entering Floor 4.\n\n\n"

    floor0_guards_dialog1: .asciiz "Player: Hey, good day!\n\n"
    floor0_guards_dialog2: .asciiz "Guard: Where is your MEF ID?\n\n" 
    floor0_guards_dialog3: .asciiz "Player: Oh, I guess I forgot it at home, may I pa-\n\n"
    floor0_guards_dialog4: .asciiz "Guard: No way I'm letting you pass without your ID.\n\n" 
    floor0_guards_dialog5: .asciiz "Player: Looks like I'll have to pass using my way!\n\n\n" 

    floor0_guards_inbattle1: .asciiz "You shall not pass!\n\n"
    floor0_guards_inbattle2: .asciiz "Argh-!\n\n"
    floor0_guards_inbattle3: .asciiz "Ughh-!\n\n"
    floor0_guards_takehit1: .asciiz "> You dealt "
    floor0_guards_takehit2: .asciiz " damage.\n\n"

    floor0_kantin_ascii: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n			    __ __               __   _           \n			   / //_/____ _ ____   / /_ (_)____      \n			  / ,<  / __ `// __ \\ / __// // __ \\     \n			 / /| |/ /_/ // / / // /_ / // / / /     \n			/_/ |_|\\__,_//_/ /_/ \\__//_//_/ /_/      \n						  \n			   ||        Coffee         ||\n	   ________________||_______________________||_____________\n	  |_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_||   \n	  |_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|| /|\n	  |_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_||/|| \n	  |_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|||/|        ____________   \n	  |_|_|_|_|_|_|_|_|_|     _      _     |_|_|_|_|_|_|_|_|_|_|/||       |            |   #############\n	  |_| Drinks        |    (_)    (_)    |Sandwich         |_|/||       |  .......   |   ##         ##\n	  |_|    Toast      |__________________|         Sancks  |_||/|       |   .....    |   #  ~~   ~~  #\n	  |_|               |_|      ||      |_|                 |_|/||       |____________|   #  ()   ()  #\n	  |_|               |_| llup || push |_|                 |_||/|                    o   (     ^     )\n	  |_|____________   |_| tuo  ||  in  |_| _____________   |_|/||                      o  |         |\n	  |_|  |      |     |_|     [||]     |_|   |        |    |_||/|                        o|  {===}  |\n	  |_|  |      |     |_|      ||      |_|   |        |    |_|/||                          \\       /\n	  |_|__|______|_____|_|      ||      |_|___|____ ___|__ _|_||/|                         /  -----  \\\n	  |_|_|_|_|_|_|_|_|_|_|______||______|_|_|_|_|_|_|_|_|_|_|_|/||                      ---  |%\\ /%|  ---\n	__|_|_|_|_|_|_|_|_|_|_|______||______|_|_|_|_|_|_|_|_|_|_|_||/________              /     |%%%%%|     \\\n	 /     /     /     /     /     /     /     /     /     /     /     /                      |%/ \\%|\n	/_____/_____/_____/_____/_____/_____/_____/_____/_____/_____/_____/\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    floor0_kantin_dialog1: .asciiz "Player: Looks like I reached the Kantin. Maybe I can find something to eat here.\n\n"
    floor0_kantin_dialog2: .asciiz "Toaster Guy: Hello there! I hope you are hungry, we have pizza toast, kumru, bagels and pogacas.\n\n"
    floor0_kantin_dialog3: .asciiz "Player: I'll take a kumru then.\n\n"
    floor0_kantin_dialog4: .asciiz "Toaster Guy: Gladly, but lets watch this Yetmez Gencler video first!\n\n"
    floor0_kantin_dialog5: .asciiz "Player: Oh hell no!\n\n\n"

    floor0_kantin_inbattle1: .asciiz "Oof! I will take all of your money-\n\n"
    floor0_kantin_inbattle2: .asciiz "Argh-! You won't able to resist against my pizza toasts.\n\n"
    floor0_kantin_inbattle3: .asciiz "Ughh-! Why won't you eat the toast?\n\n"
    floor0_kantin_hitplayer_dialog: .asciiz "Toaster Guy: Take this!\n\n> You took "

    floor0_kantin_afterfight1: .asciiz "Toaster Guy: Wait where am I? I was preparing sandwiches...\n\n"
    floor0_kantin_afterfight2: .asciiz "Player: You were brainwashed and attacked me.\n\n"
    floor0_kantin_afterfight3: .asciiz "Toaster Guy: Oh, how did that happen?\n\n"
    floor0_kantin_afterfight4: .asciiz "Player: I don't know yet, but I will figure it out.\n\n"
    floor0_kantin_afterfight5: .asciiz "Toaster Guy: Good luck with that, take this kumru with you. A full stomach is a happy stomach!\n\n\n"   
   
    floor1_student_ascii: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n\n   /////////////\\\\\\\\      ___________        ___________          ***           $$\n  (((((((((((((( \\\\\\\\    |           |      |           |       *******       $$$$$\n  ))) ~~      ~~  (((    |  .......  |      |  .......  |      *********      $$$$$\n  ((( (*)     (*) )))    |   .....   |      |   .....   |   /\\* ### ### */\\    $$\n  )))     <       (((    |___________|      |___________|   |    @ / @    |    $$\n  ((( '\\______/`  )))   o                                o  \\/\\    ^    /\\/    $$\n  )))\\___________/(((  o                                   o   \\  ===  /       $$\n         _) (_       o                                       o  \\_____/      $$$$\n      xxxxxxxxx                                                  _|_|_     $$$\n   xxxxxxxxxxxxxxxx                                $$$$$$$$$$$$$$$$$$$$$*$$$\n xxx xxxxxxxxxxx  xxx                               $$$$$$$$$$$$$$$$$$$$$$\nxxx  xxxxxxxxxxx xxx                                           $$$$$$$$$$$\n  xxxxxxxxxxxxxxxx                                             $$$$$$$$$$$\n    xxxxxxxxxxxxx                                              $$$$$$$$$$$\n   xxxxxxxxxxxxxxx                                             $$$$$$$$$$$\n  xxxxxxxxxxxxxxxxx                                            $$$$$$$$$$$\n xxxxxxxxxxxxxxxxxxx                                           $$$$$$$$$$$\n\n\n\n\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-\n\n"
    floor1_student_dialog1: .asciiz "Player: (There are students blocking the way upstairs.)\n\n"
    floor1_student_dialog2: .asciiz "Student 1: Where is the C Block by the way?\n\n"
    floor1_student_dialog3: .asciiz "Student 2: I don't really know, I was going to ask you where is dining hall.\n\n"
    floor1_student_dialog4: .asciiz "Player: Hey, are you guys alright?\n\n"
    floor1_student_dialog5: .asciiz "Student 1: What is it to you? Get lost!\n\n"
    floor1_student_dialog6: .asciiz "Player: Take it easy man, I just wanted to ask where Student Affairs office is.\n\n"
    floor1_student_dialog7: .asciiz "Student 2: How about you watch this Yetmez Gencler video with us? *Points their phone at you*\n\n"
    floor1_student_dialog8: .asciiz "Player: We wont be needing that. I guess I have to take you all down!\n\n\n"

    floor1_student_inbattle1: .asciiz "Students: Oof! Cut that out man!\n\n"
    floor1_student_inbattle2: .asciiz "Students: Argh-! We wont let you pass!\n\n"
    floor1_student_inbattle3: .asciiz "Students: Ughh-! Who asked for your opinion?\n\n"
    floor1_student_hitplayer_dialog: .asciiz "Students: Take this!\n\n> You took "

    floor1_student_afterfight1: .asciiz "Student 1: Where am I?\n\n"
    floor1_student_afterfight2: .asciiz "Student 2: The last thing I remember is we were watching Yetmez Gencler's video...\n\n"
    floor1_student_afterfight3: .asciiz "Player: Yeah, you and all the other students were getting manipulated by Professor Ercan Korkut.\n\n"
    floor1_student_afterfight4: .asciiz "Student 1: No way...\n\n"
    floor1_student_afterfight5: .asciiz "Player: I'm surprised that you don't remember a thing.\n\n"
    floor1_student_afterfight6: .asciiz "Student 2: I told you man, last thing I remember is we were watching Yetmez Gencler's course video.\n\n"
    floor1_student_afterfight7: .asciiz "Student 1: Now that you mention it.. Where are all the other students?\n\n"
    floor1_student_afterfight8: .asciiz "Student 2: Wait wait! We are late for Calculus Class!\n\n\n"

    floor1_ilkay_ascii: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n00KKKKKKKK0c.         .....',,;;;;:cccllloooddddddddxxxxxxxxxxxxxxxddddddddddoolldOkdlllodxxxxxxxxxd\n0KKKKKKKKKO:.         .....',,;;;;::ccllloooooooddddddxxxxxxxxxxxxxxxddddddddlc;,,lxdlllodxxxxxxxxdd\n0KKK00000KO:.        ......',,;;;::ccclloooooooooooollllloooooooddddddddddooc:;;;;:odolcldxxxxxxxxxx\n00KKK00000O:.      ........',,;;:::cclllloolllllllcccccccccc::;::ccloddddollccclllldxolcldxxxxxxxxxx\n00K0000000Oc.     ........'',,;;::cccllllllllcccccclloooddddollllllloodddollllcccclxkdlcloxxxxxxxxxx\n00K0000000Ol.    .........'',,,;::ccllllllccccclloooddddddddooooooooooddddlllc;,',cxkxollodxxxxxxxxx\n00KK0000000d'   .........'''',,:ccclllllcccccllooooooolllllc::cloollllodddool;'.';okOxolcldxxxxxxxxx\n00KK0000000Oc............''''',:ccllllllllllloooollc:::cc;,'.';ccccccclloddoc:;;;cdOOxolclodxxxxxxxx\n00KK00000000d'...''.....'''''',:cclllloooooooooolllcc::cc;,,,;:cclllllllloddoolllldkOkolccodxxxxxxxx\n00KKK000000KOl;:ccllcc;,''''',,:ccllllooodddddooooooooooolllllllooooollcllooooooooodkOdlccldxxxxxxxx\n000KK00000000xlc::cccccc:;'''',:ccllllooodddddddooodddddddddddoddddolcccccoddooooooodkxllclodxxxxxxx\n0000000000000xl:::cc:::::;,,'',:ccllllloooooddddddddddddddddddxxxdolcc::clodxxdddddodkkolllodxxxxxxx\n0000000000000kl:::lc::;;;;;,,,,:cccllllllooooodddddddddddddxxxkkxoccccclllodxxkkxxdddxkdlllldxxxxxxx\n0000000000000Odc:clc:;;,;;:;;;;:cccccllllloooooodddddddxxxxxxkkkxo::clllllcclodxxxxxdkkxolcloxxxxxxx\n00000000000K00Odcclc:::;;;::;::::ccccclllloooooodddddddxxxxkkkOkkxocllllclc::clodxkxxkOxolllodxxxxxx\n0000000000000000xlcccc:::;;;;;;:::cccclllloooooooddddddxxxkkOOOkkxxdlllllloollclodxxxkOkdlclodxxxxxx\n00000000000000000koc::::c:;;;;;;::cccccllllooooodddddddxxkkOOOOkkxxdollllooollccclodxxkkdolcldxxxxxx\n0000000000000000OOOxlcccccc:;;;;:::cccclllllooodddddddxxkkOOOOOkkxxdooooooooollllllodxkOxolccodxxxxx\nOOO000000000OOOOOOOkxdolccc:;;;;;::ccccllllloooddddddxxxkkkOOOkkxxxxddollccc:::ccllodkkOxolccodxxxxx\nOOOOOOOOOO00OOOOOOOkkkkxl:;;;,,;;;::ccccllllooooddddxxxxkkkkkkxxddoolc;,''',,',;clodxkOOkolccldxdxxx\nOOOOOOOOOOOOOOkkkkkkxxkkdc;;;,,,;;;:::ccllllooooddddxxxxkkkkkxxdolc:;;;;:::ccccccodxkOOOkdlcccodxxxx\nOOOOOOOOOOOOOkkkkkkxxxxxxdc;;,,,,,;;:::cccllooooddddxxxxxkkkkxddooooooollolllllllodxkOOOkxlcccoddddx\nkkkkkkkkkkxxkkkkkkxxxxkkkko:;,,,,,;;;;:::cclloooddddddxxxxkkxxxdddxxxddddoolloooodxkOOOOkxolcclddddd\nxxxxxkxoldoodxxxxxxxxxkkxxdc;,,,,,;;;;;;::cclloodddddddddxxxxxxxxxxxxxxxddoooooooxkOOOOOOkdlcccodddd\ndlllodoolldooxxooxxxdddddol:;,,,,,;;;;;;:::cccloodddddddddxxxxxxxxxxxkkxxxdddddddkOOOOOOOOxlcccodddd\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
    floor1_ilkay_dialog1: .asciiz "Ilkay: Hey! You three over there! What are you all up to? You're supposed to be in class!\n\n"
    floor1_ilkay_dialog2: .asciiz "Player: Sorry but instead of attending class most people are learning calculus by watching 'Buders Bogaziciliden'. They really don't need your classes.\n\n"
    floor1_ilkay_dialog3: .asciiz "Ilkay: How dare you?! I will make sure they will fail the class!\n\n\n"
    
    floor1_ilkay_inbattle1: .asciiz "Ilkay: Ouch-! This theorem is well known!\n\n"
    floor1_ilkay_inbattle2: .asciiz "Ilkay: Argh-! You are so predictable, your moves are well known!\n\n"
    floor1_ilkay_inbattle3: .asciiz "Ilkay: Ughh-! No calculators! This is a math class, you're the calculator\n\n"
    floor1_ilkay_hitplayer_dialog: .asciiz "Ilkay: Take this!\n\n> You took "
    
    floor1_ilkay_afterfight1: .asciiz "Player: Are you alright professor?\n\n"
    floor1_ilkay_afterfight2: .asciiz "Ilkay: Where am I, 'guys'?\n\n"
    floor1_ilkay_afterfight3: .asciiz "Player: Ercan has brainwashed everyone. We have to catch him. But I don't know where he is.\n\n"
    floor1_ilkay_afterfight4: .asciiz "Ilkay: As I remember he is hiding in 5th floor.\n\n"
    floor1_ilkay_afterfight5: .asciiz "Player: I have to stop him at any cost!\n\n\n"
    
    floor2_student_ascii: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n\n\n              @@@@@@@\n          @@@@@@@@@@@\n         @@@@@@@@@@@@@\n        ((* ### ### *))                       ---------                            ---------                            ---------\n       (     Q | Q     )             =======@@|       |@@=======          =======@@|       |@@=======          =======@@|       |@@=======\n        (      v      )                   []  |       |  []                    []  |       |  []                    []  |       |  []\n          ((  ___  ))                     []  |       |  []                    []  |       |  []                    []  |       |  []\n           ((_____))                      []  |_______|  []                    []  |_______|  []                    []  |_______|  []\n             _|_|_                        []  ||     ||  []                    []  ||     ||  []                    []  ||     ||  []\n ######################                   []  ||_____||  []                    []  ||_____||  []                    []  ||_____||  []\n  ########################                []  ||     ||  [|                    []  ||     ||  [|                    []  ||     ||  [|\n           ################               []  ||     ||  []                    []  ||     ||  []                    []  ||     ||  []\n           ###########  ####              []  ||     ||  []                    []  ||     ||  []                    []  ||     ||  []\n           ###########   #####\n           ###########     ####\n           ###########\n           ###########\n				\n\n\n\n\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+					\n\n"
    floor2_student_dialog1: .asciiz "Player: (This should be the English Prep year-)\n\n"
    floor2_student_dialog2: .asciiz "Student: School good but school no has campus.\n\n"
    floor2_student_dialog3: .asciiz "Player: Haven't you been told that it's forbidden to talk Turkish here?\n\n"
    floor2_student_dialog4: .asciiz "Student: Don't tell me what to do!\n\n\n"

    floor2_student_inbattle1: .asciiz "Student: Ughh-! I don't now\n\n"
    floor2_student_inbattle2: .asciiz "Student: Ouch-!\n\n"
    floor2_student_inbattle3: .asciiz "Student: Argh-! I have a essay for homework\n\n"
    floor2_student_hitplayer_dialog: .asciiz "Student: Take this!\n\n> You took "
    
    floor2_student_afterfight1: .asciiz "Student: What happened?\n\n"
    floor2_student_afterfight2: .asciiz "Player: Are you alright?\n\n"
    floor2_student_afterfight3: .asciiz "Student: No my head is spinning... Leave me alone!\n\n"
    floor2_student_afterfight4: .asciiz "Player: (It's really exhausting to try talk with those guys... I might find something useful in the Registrar Office.)\n\n\n"

    office_art: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+					\n\n\n            _,,,_                     \\|    ]|   .-'\n          .'     `'.                   L.__  .--'(\n         /     ____ \\                ,---|_      \\---------,                  __/)                   __/)\n        |    .'_  _\\/              \\/ .--._|=-    |_      /|               .-(__(=:               .-(__(=:\n        /    ) a  a|         .----.`\\/ .-'          '.   / |               |    \\)                |    \\)\n       /    (    > |        /|  ;-:'--.|             |-./  |   ejm97 (\\__  |          ejm97 (\\__  |\n      (      ) ._  /        || /_ ]| )/`-.-----------')/)  |        :=)__)-|  __/)         :=)__)-|  __/)\n      )    _/-.__.'`\\       ||\\//`]|`/,=::|.'`````````/ (  |         (/    |-(__(=:         (/    |-(__(=:\n     (  .-'`-.   \\__ )      ||/ `-]|` `=::|          /   ) |       ______  |  _ \\)        ______  |  _ \\)\n      `/      `-./  `.      ||    ]|    ::|         /   (  |      /      \\ | / \\         /      \\ | / \\\n     _ |    \\      \\  \\     \\|----]|---.-'--------'|     ) |           ___\\|/___\\             ___\\|/___\\\n    / \\|     \\   \\  \\  \\    |L.__  .--'(           |    /  |          [         ]\\           [         ]\\\n   |   |\\     `. /  /   \\  ,---|_      \\---------, |   (   |           \\       /  \\           \\       /  \\\n   |   `\\'.     '. /`\\   \\/ .--._|=-    |_      /| |    ) ,|            \\     /                \\     /\n   |     \\ '.     '._ './`\\/|.-'          '.   / | |   ( /||             \\___/                  \\___/\n   |     |   `'.     `;-:-;`)|             |-./  | |   )/ ``\n   |    /_      `'--./_  ` )/'-------------')/)  | |  (/\n   \\   | `````----``\\//````/,===..'`````````/ (  | |  /)\n    |  |            / `---` `==='          /   ) | | /\n    /  \\           /        | .-----------/---(--|.||\n   |    '------.  |'--------------------'|     ) |```\n    \\           `-|                      |    /  |\n     `--...,______|                      |   (   |\n\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+					\n\n"
    office_artbig: .asciiz "                      ____________                                         ===========|=============\n                     |           |                                         |==========||============\n                     |        // |                                         ||         ||          ||\n                     |    @@ //  |                                         ||         ||          ||\n                     |  @@@@@    |                                         ||         ||          ||\n                     |  //@@@@   |  .----.                                 ||     ----|---        ||\n                     |/// @@@@   | /|     '--.                             ||     ----|--         ||\n                     |  xxxx x   | ||    ]|   `-.                          ||         ||          ||\n                     |xxxxxxxxxx | ||    ]|    ::|                         ||         ||          ||\n                     |xxxxxxxxxxx| ||    ]|    ::|                         |===========|==========||\n                                   ||    ]|    ::|                         ||==========|===========|\n         _,,,_                     \\|    ]|   .-'\n       .'     `'.                   L.__  .--'(\n      /     ____ \\                ,---|_      \\---------,                  __/)                   __/)\n     |    .'_  _\\/              \\/ .--._|=-    |_      /|               .-(__(=:               .-(__(=:\n     /    ) a  a|         .----.`\\/ .-'          '.   / |               |    \\)                |    \\)\n    /    (    > |        /|  ;-:'--.|             |-./  |   ejm97 (\\__  |          ejm97 (\\__  |\n   (      ) ._  /        || /_ ]| )/`-.-----------')/)  |        :=)__)-|  __/)         :=)__)-|  __/)\n   )    _/-.__.'`\\       ||\\//`]|`/,=::|.'`````````/ (  |         (/    |-(__(=:         (/    |-(__(=:\n  (  .-'`-.   \\__ )      ||/ `-]|` `=::|          /   ) |       ______  |  _ \\)        ______  |  _ \\)\n   `/      `-./  `.      ||    ]|    ::|         /   (  |      /      \\ | / \\         /      \\ | / \\\n  _ |    \\      \\  \\     \\|----]|---.-'--------'|     ) |           ___\\|/___\\             ___\\|/___\\\n / \\|     \\   \\  \\  \\    |L.__  .--'(           |    /  |          [         ]\\           [         ]\\\n|   |\\     `. /  /   \\  ,---|_      \\---------, |   (   |           \\       /  \\           \\       /  \\\n|   `\\'.     '. /`\\   \\/ .--._|=-    |_      /| |    ) ,|            \\     /                \\     /\n|     \\ '.     '._ './`\\/|.-'          '.   / | |   ( /||             \\___/                  \\___/\n|     |   `'.     `;-:-;`)|             |-./  | |   )/ `'\n|    /_      `'--./_  ` )/'-------------')/)  | |  (/\n\\   | `''''----'`\\//`''`/,===..'`````````/ (  | |  /)\n |  |            / `---` `==='          /   ) | | /\n /  \\           /        | .-----------/---(--|.||\n|    '------.  |'--------------------'|     ) |`'`\n \\           `-|                      |    /  |\n  `--...,______|                      |   (   |\n         | |   |                      |    ) ,|\n         | |   |                      |   ( /||\n         | |   |                      |   )/ `'\n        /   \\  |                      |  (/\n  jgs .' /I\\ '.|                      |  /)\n   .-'_.'/ \\'. |                      | /\n   ```  `'''` `| .-------------------.||\n               `'`                   `'`\n\n"
    office_beforefight_convo1: .asciiz "Student: Um, hello. Is this the Registrar's Office?\n\n"
	office_beforefight_convo2: .asciiz "Registrar: Not to you.. You look different!\n\n"
	office_beforefight_convo3: .asciiz "Registrar: Haven't you attended Yetmez Gençler? You won't be able graduate.\n\n"
	office_beforefight_convo4: .asciiz "Player: Cut the crap, where is Professor Korkut?\n\n"
	office_beforefight_convo5: .asciiz "Registrar: We can't inform you about that topic, you may mail us later.\n\n"
	office_beforefight_convo6: .asciiz "Player: How about we solve this problem right now?\n\n\n"

	office_infight1: .asciiz "Ouch-! You may mail us.\n\n"
	office_infight2: .asciiz "Ughh-! We can't help you right now.\n\n"
	office_infight3: .asciiz "Argh-! You need to ask it to your advisor professor.\n\n"
	floor2_office_hitplayer_dialog: .asciiz "Office: Take this!\n\n> You took "

	office_afterfight_convo1: .asciiz "Player: Are you working with them? This is madness! Students are acting like brainless zombies.\n\n"
	office_afterfight_convo2: .asciiz "Registrar: It was his idea... Ercan Korkut... We brainwashed the students with Yetmez Gençler videos.\n\n"
	office_afterfight_convo3: .asciiz "Player: And why did he need to do this exactly?\n\n"
	office_afterfight_convo4: .asciiz "Registrar: His ambition... He believed that MEF University was the most successful one at graduating competent students. He wanted all others to respect that belief...\n\n"
	office_afterfight_convo5: .asciiz "Registrar: He brainwashed everyone to make them believe it as well. So he get other to join MEF in the future without any hangups.\n\n"
	office_afterfight_convo6: .asciiz "Player: Brain washing people is not a solution to this! How can I end this madness?\n\n"
	office_afterfight_convo7: .asciiz "Registrar: He is on 5th floor. Defeat him... He is still giving Yetmez Gençler courses.\n\n"
	office_afterfight_convo8: .asciiz "***Player starts walking off to take stairs.***\n\n\n"
	office_afterfight_convo9: .asciiz "Registrar: Wait! You can't defeat him, you are still weak!\n\n"
	office_afterfight_convo10: .asciiz "Player: Do you know something?\n\n"
	office_afterfight_convo11: .asciiz "Registrar: Aye, according to the ancient legends, there is only one person who knows how to defeat him.\n\n"
	office_afterfight_convo12: .asciiz "Player: And who is that?\n\n"
	office_afterfight_convo13: .asciiz "Registrar: I'm telling you 'ancient legends' right? There is a book of his learnings in the library.\n\n"
	office_afterfight_convo14: .asciiz "Registrar: The book is guarded by someone who resides in the library. You need to be careful.\n\n"
	office_afterfight_convo15: .asciiz "Player: (Is that 'someone', our librarian? I knew the time would come someday. I shall pay a visit to library.)\n\n"
	office_afterfight_convo16: .asciiz "Player: Take care.\n\n"
	office_afterfight_convo17: .asciiz "***Player takes upstairs.***\n\n\n"
	
	floor3_librarian_ascii: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ \n\n	___________________________________________________________________________________\n	||=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=| __..\\/ |  |_|  ||#||==|  / /|_|  ||#||==|  / / |\n	|| | | | | | | | | | | | | | | | | |/\\ \\  \\\\|++|=|  || ||==| / / |=|  || ||==| / /  |\n	||_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_/_/\\_.___\\__|_|__||_||__|/_/__|_|__||_||__|/_/_  |\n	|________________________________ /\\~()/()~//\\ _____________________________________|\n	|   _____ _ __    _               \\_  (_ .  _/ _    ___     __ _     _____          |\n	||=|=|~~|_|..|~~|_|..|__| || |_ _   \\ //\\\\ /  |=|__|~|~|___| | | |=|__|~|~|___| | | |\n	|| | |--|+|^^|--|+|^^|==|1||2| | |__/\\ __ /\\__| |==|x|x|+|+|=|=|=| |==|x|x|+|+|=|=|=|\n	|| | |__|_|__|__|_|__|__|_||_|_| /  \\ \\  / /  \\_|__|_|_|_|_|_|_|_|__|_|_|_|_|_|_|_ _|\n	|_____________________________ _/    \\/\\/\\/    \\_ __________________________________|\n	|                    |/      \\../      \\|  __   __   _____   __   ______  _         |\n	||=|=|~~|_|..|_____|_| |_|##|_||   |   \\/ __|   ||_|==|_|++|_|-|||==|_|++|_|-||-|| ||\n	|| | |~~|_|..|______||=|#|--| |\\   \\   o    /   /| |  |~|  | | |||  |~|  | | || || ||\n	||_|_|__|_|..|______||_|_|__|_|_\\   \\  o   /   /_|_|__|_|__|_|_|||__|_|__|_|_|| ||_||\n	|_____________________ __________\\___\\____/___/___________ _______________________  |\n	|             __    _   /    ________     ______           /| _ _ _                 |\n	|   |=||%|%|%| \\ \\  |=|/   //    /| //   /  /  / |        / ||%|%|%|\\ \\  |=||%|%|%| |\n	|   |*||=|=|=|	\\/\\ |*/  .//____//.//   /__/__/ (_)      /  ||=|=|=| \\/\\ |*||=|=|=| |\n	|   | ||~|~|~|	 \\/\\|/   /(____|/ //                    /  /||~|~|~|  \\/\\| ||~|~|~| |\n	|   |=||_|_|_| ___\\_/   /________//   ________         /  / ||_|_|_|   \\ |=||_|_|_| |\n	|_________ /   (|________/   |\\_______\\       /  /| |_________________________|_____|\n              /                  \\|________)     /  / | |\n			  \n			  \n			  \n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
	floor3_library_dialog1: .asciiz "Player: (This should be the library, looks like it's being guarded.)\n\n"
	floor3_library_dialog2: .asciiz "Player: Can I pass through? I need a book for my reasearch project.\n\n"
	floor3_library_dialog3: .asciiz "Librarian: No one is allowed unless you get permission from Professor Korkut. Do you have a signed paper?\n\n"
	floor3_library_dialog4: .asciiz "Player: No I don't, you have to let me through!\n\n"
	floor3_library_dialog5: .asciiz "Librarian: You're not going anywhere!\n\n"
	floor3_library_dialog6: .asciiz "Player: We will see about that!\n\n\n"

	floor3_library_inbattle1: .asciiz "Argh-! You shall not pass!\n\n"
	floor3_library_inbattle2: .asciiz "Ouch-! It's finals week, you make so much noise.\n\n"
	floor3_library_inbattle3: .asciiz "Ughh-! Do you know about how to make citations?\n\n"
	floor3_library_hitplayer_dialog: .asciiz "Librarian: Take this!\n\n> You took "

	floor3_library_afterbattle1: .asciiz "Librarian: Ugh... I feel dizzy, what happened to me?!\n\n"
	floor3_library_afterbattle2: .asciiz "Player: Professor Korkut is manipulating everyone in the school.\n\n"
	floor3_library_afterbattle3: .asciiz "Player: I need some help now. I should gather some information to stop him. Will you help me.\n\n"
	floor3_library_afterbattle4: .asciiz "Librarian:You talk about the forbidden part of the library I guess. It has 3 different corridors. The information you need should be there.\n\n\n"

	floor3_library_hallwat_ascii: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n        \\                                        /\n          \\                                     /\n           \\                                   /\n           ]                                  [    ,'|\n           ]                                  [   /  |\n           ]____                          ____[ ,'   |\n           ]   ]\\                        /[   [ |:   |\n           ]   ] \\                      / [   [ |:   |\n           ]   ]  ]                    [  [   | | :  |\n           ]   ]  ]____             ___[  [   [ |:   |\n           ]   ]  ]   ]\\     _    /[   [  [   [ |:   |\n           ]   ]  ]   ]     (#)    [   [  [   [ :===='\n           ]   ]  ]___]    .nHn.   [___[  [   [\n           ]   ]  ]       HHHHH.       [  [   [\n           ]   ] /        `HH('N        \\ [   [\n           ]___]/          HHH  '        \\[___[\n           ]               NNN                [\n           ]               N/'                [\n           ]               N H                [\n          /                N                   \\\n         /                 q,                   \\\n        /                                        \\\n			\n\n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+				\n\n"
	floor3_library_book_ascii: .asciiz "      ______ ______\n    _/      Y      \_\n   // ~~ ~~ | ~~ ~  \\\n  // ~ ~ ~~ | ~~~ ~~ \\\     \n //________.|.________\\\    \n`----------`-'----------'\n\n"

	floo3_library_book1_name: .asciiz "1st Book; The Secret of Ortayli\n\n"
	floor3_book1: .asciiz ".-..-. .-- . / -... . .-.. .. . ...- . / - .... .- - / ..--- ----- - .... / -. .- - .. --- -. .- .-.. / . -.. ..- -.-. .- - .. --- -. \n/ -.-. --- ..- -. -.-. .. .-.. / .. ... / ...- . .-. -.-- / .. -- .--. --- .-. - .- -. - .-.-.- / .. - / .. ... / -... . -.-. .- ..- ... . \n/ - .... . .-. . / .- .-. . / ... --- -- . / .--. .-. --- -... .-.. . -- ... / .- -. -.. / - .... . -.-- / -- ..- ... - / -... . \n/ ... --- .-.. ...- . -.. / .. -. / ... --- -- . / .-- .- -.-- .-.-.- / .. - / .. ... / .- / ... --- -.-. .. .- .-.. / .- -. -.. \n/ -. .- - .. --- -. .- .-.. / -- .- - - . .-. / .- -. -.. / .. - / -.-. --- -. -.-. . .-. -. ... / .- .-.. .-.. \n/ .--. . --- .--. .-.. . .-.-.- .-.-.- .-.-.- / ..-. .. .-. ... - / --- ..-. / .- .-.. .-.. --..-- / - .... . .-. . / .. ... / - .... . \n/ .--. .-. . ... -.-. .... --- --- .-.. / .. ... ... ..- . .-.-.- .-.-.- .-.-.- / - ..- .-. -.- . -.-- / .. ... \n/ .. -. -.. ..- ... - .-. .. .- .-.. .. --.. . -.. --..-- / - .... . / -. ..- -- -... . .-. / --- ..-. / .-- --- .-. -.- .. -. --. \n/ .--. --- .--. ..- .-.. .- - .. --- -. / .... .- ... / .. -. -.-. .-. . .- ... . -.. / .- -. -.. / -. --- .-- / -... --- - .... \n/ .--. .- .-. . -. - ... / .- .-. . / --. --- .. -. --. / - --- / .-- --- .-. -.- .-.-.- / .. - / .. ... / -. --- - / --- -. .-.. -.-- \n/ ...- .- .-.. .. -.. / .. -. / -... .. --. / -.-. .. - .. . ... --..-- / - .... .. ... / .... .- ... / ... .--. .-. . .- -.. / - --- \n/ - .... . / . -. - .. .-. . / -.-. --- ..- -. - .-. -.-- .-.-.- / .. - / .. ... / -. --- - / .-. .. --. .... - / - --- / .-.. . - \n/ -.-. .... .. .-.. -.. .-. . -. / -.-. .- .-. .-. -.-- / - .... . / -... ..- .-. -.. . -. / --- ..-. / .- / --. .-. --- .-- .. -. --. \n/ .. -. -.. ..- ... - .-. -.-- / .- -. -.. / -... ..- ... .. -. . ... ... / .-.. .. ..-. . .-.-.- / -.-. .... .. .-.. -.. .-. . -. \n/ ... .... --- ..- .-.. -.. / .-.. . .- .-. -. / - .... . .. .-. / -- --- - .... . .-. / .-.. .- -. --. ..- .- --. . / .- - / .- \n/ ...- . .-. -.-- / -.-- --- ..- -. --. / .- --. . --..--\n\n"

	floor3_dialog_after_book1: .asciiz "Player: Ehh...\n\n"

	floor3_library_book2_name: .asciiz "2nd Book; Computer Architecture\n\n"
	floor3_library_book2_1: .asciiz "The organizational changes in processor design have primarily been focused on increasing instruction-level parallelism so that more work could be done in each clock cycle. - True\n\n"
	floor3_library_book2_2: .asciiz "GPUs are capable of running operating systems. - False\n\n"
	floor3_library_book2_3: .asciiz "With superscalar organization increased performance can be achieved by increasing the number of parallel pipelines - True\n\n"
	floor3_library_book2_4: .asciiz "The caches hold recently accessed data - True\n\n"

	floor3_library_book2_dialog: .asciiz "Player: I don't really need that book now.\n\n"

	floo3_library_book3_name: .asciiz "3rd book; Egitim Sizde Sistem Caresiz by Ercan Korkut\n\n"
	floor3_library_book3_dialog1: .asciiz "Player: That was my favorite book back in my freshman days.\n\n"
	floor3_library_book3_dialog2: .asciiz "Player: He was such a good man, I wonder why the things turned out like this.\n\n"

	floor3_library_book3_story: .asciiz "*MC finds a marked page, only thing written on that page is 'Use the power of Math'\n\n"

	floor3_library_book3_dialog4: .asciiz "Player: Oh, I should have attended the calculus classes...\n\n"
	floor3_library_book3_dialog5: .asciiz "Player: Anyways, let's keep going.\n\n\n"

    floor3_minigame_ascii1: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n\n\n\n\n                            @@@@                                           @@@@                                           @@@@\n                            @@@@@                                          @@@@@                                          @@@@@\n                            @@@@@                                          @@@@@                                          @@@@@\n                         @@@ @@@ @@@@                                   @@@ @@@ @@@@                                   @@@ @@@ @@@@\n                        @@---------@@                                  @@---------@@                                  @@---------@@\n                 =======@@|       |@@=======                    =======@@|       |@@=======                    =======@@|       |@@=======\n                      []@@|       |@@[]                              []@@|       |@@[]                              []@@|       |@@[]\n                OO    []@@|       |@@[]                              []@@|       |@@[]                              []@@|       |@@[]\n               OxxO   []  |_______|  []                              []  |_______|  []                              []  |_______|  []\n        ####### OO    []  ||     ||  []                              []  ||     ||  []                              []  ||     ||  []\n      // #######      []  ||_____||  []                              []  ||_____||  []                              []  ||_____||  []\nJJ===// ||     \\\\\\zz  []  ||     ||  [|                              []  ||     ||  [|                              []  ||     ||  [|\n J      ||      \\\\    []  ||     ||  []                              []  ||     ||  []                              []  ||     ||  []\n   JJ===||       ==   []  ||     ||  []                              []  ||     ||  []                              []  ||     ||  []\n  \n\n\n\n\n\n\n\n\n\n \n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n"
    floor3_minigame_ascii2: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n\n\n\n\n                            @@@@                                           @@@@                                           @@@@\n                            @@@@@                                          @@@@@                                          @@@@@\n                            @@@@@                                          @@@@@                                          @@@@@\n                         @@@ @@@ @@@@                                   @@@ @@@ @@@@                                   @@@ @@@ @@@@\n                        @@---------@@                                  @@---------@@                                  @@---------@@\n                 =======@@|       |@@=======                    =======@@|       |@@=======                    =======@@|       |@@=======\n                      []@@|       |@@[]                              []@@|       |@@[]                              []@@|       |@@[]\n                      []@@|       |@@[]                   OO         []@@|       |@@[]                              []@@|       |@@[]\n                      []  |_______|  []                  OxxO        []  |_______|  []                              []  |_______|  []\n                      []  ||     ||  []           ####### OO         []  ||     ||  []                              []  ||     ||  []\n                      []  ||_____||  []         // #######           []  ||_____||  []                              []  ||_____||  []\n                      []  ||     ||  [|   JJ===// ||     \\\\\\zz       []  ||     ||  [|                              []  ||     ||  [|\n                      []  ||     ||  []    J      ||      \\\\         []  ||     ||  []                              []  ||     ||  []\n                      []  ||     ||  []      JJ===||       ==        []  ||     ||  []                              []  ||     ||  []\n                                              J\n\n\n\n\n\n\n\n\n \n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n"
    floor3_minigame_ascii3: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n\n\n\n\n                             @@@@                                           @@@@                                           @@@@\n                             @@@@@                                          @@@@@                                          @@@@@\n                             @@@@@                                          @@@@@                                          @@@@@\n                          @@@ @@@ @@@@                                   @@@ @@@ @@@@                                   @@@ @@@ @@@@\n                         @@---------@@                                  @@---------@@                                  @@---------@@\n                  =======@@|       |@@=======                    =======@@|       |@@=======                    =======@@|       |@@=======\n                       []@@|       |@@[]                              []@@|       |@@[]                              []@@|       |@@[]\n                       []@@|       |@@[]                              []@@|       |@@[]                     OO       []@@|       |@@[]\n                       []  |_______|  []                              []  |_______|  []                    OxxO      []  |_______|  []\n                       []  ||     ||  []                              []  ||     ||  []             ####### OO       []  ||     ||  []\n                       []  ||_____||  []                              []  ||_____||  []           // #######         []  ||_____||  []\n                       []  ||     ||  [|                              []  ||     ||  [|     JJ===// ||     \\\\\\zz     []  ||     ||  [|\n                       []  ||     ||  []                              []  ||     ||  []      J      ||      \\\\       []  ||     ||  []\n                       []  ||     ||  []                              []  ||     ||  []        JJ===||       ==      []  ||     ||  []\n                            \n\n\n\n\n\n\n\n\n\n \n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n"
    floor3_minigame_ascii4: .asciiz "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n\n\n\n\n                            @@@@                                           @@@@                                           @@@@\n                            @@@@@                                          @@@@@                                          @@@@@\n                            @@@@@                                          @@@@@                                          @@@@@\n                         @@@ @@@ @@@@                                   @@@ @@@ @@@@                                   @@@ @@@ @@@@\n                        @@---------@@                                  @@---------@@                                  @@---------@@\n                 =======@@|       |@@=======                    =======@@|       |@@=======                    =======@@|       |@@=======\n                      []@@|       |@@[]                              []@@|       |@@[]                              []@@|       |@@[]\n                      []@@|       |@@[]                              []@@|       |@@[]                              []@@|       |@@[]                   OO\n                      []  |_______|  []                              []  |_______|  []                              []  |_______|  []                  OxxO\n                      []  ||     ||  []                              []  ||     ||  []                              []  ||     ||  []           ####### OO\n                      []  ||_____||  []                              []  ||_____||  []                              []  ||_____||  []         // #######\n                      []  ||     ||  [|                              []  ||     ||  [|                              []  ||     ||  [|   JJ===// ||     \\\\\\zz\n                      []  ||     ||  []                              []  ||     ||  []                              []  ||     ||  []    J      ||      \\\\\n                      []  ||     ||  []                              []  ||     ||  []                              []  ||     ||  []      JJ===||       ==\n                                                                                                                                            J\n                            \n\n\n\n\n\n\n\n\n\n \n+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n\n"
    floor3_minigame_dialog1: .asciiz "Player: (I've reached the library hall but there are so many students. They are all focused on those brainwashing videos though.)\n\n"
    floor3_minigame_dialog2: .asciiz "Player: (I may be able to sneak in, I can't fight with all of them.)\n\n\n"

    floor3_minigame_instructions: .asciiz "Quick time event! You have to type the singular number shown on screen and then press enter as quickly as you can!\n\n\n"
    floor3_minigame_prompt1: .asciiz "Type "
    floor3_minigame_prompt2: .asciiz " and press enter as quickly as you can!\n\n"

    floor3_after_hallway: .asciiz "Player: (That was close...)\n\n"
    floor3_before_toasterguy: .asciiz "Player: Looks like this is going to another encounter with the toaster guy.\n\n\n"

    floor3_toasterguy_dialog1: .asciiz "Toaster Guy: How is going? Have you found a way?\n\n"
    floor3_toasterguy_dialog2: .asciiz "Player: Aye, I got some intel, I should find some kind of ancient information inside the Library to defeat him.\n\n"
    floor3_toasterguy_dialog3: .asciiz "Toaster Guy: Nice, in any case if you need this *Offers a pizza toast*\n\n"
    floor3_toasterguy_dialog4: .asciiz "Player: Thanks man.\n\n\n"

    floor3_minigame_gameoverslow: .asciiz " @@@@@@@@   @@@@@@   @@@@@@@@@@   @@@@@@@@            @@@@@@   @@@  @@@  @@@@@@@@  @@@@@@@   \n@@@@@@@@@  @@@@@@@@  @@@@@@@@@@@  @@@@@@@@           @@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@@  \n!@@        @@!  @@@  @@! @@! @@!  @@!                @@!  @@@  @@!  @@@  @@!       @@!  @@@  \n!@!        !@!  @!@  !@! !@! !@!  !@!                !@!  @!@  !@!  @!@  !@!       !@!  @!@  \n!@! @!@!@  @!@!@!@!  @!! !!@ @!@  @!!!:!             @!@  !@!  @!@  !@!  @!!!:!    @!@!!@!   \n!!! !!@!!  !!!@!!!!  !@!   ! !@!  !!!!!:             !@!  !!!  !@!  !!!  !!!!!:    !!@!@!    \n:!!   !!:  !!:  !!!  !!:     !!:  !!:                !!:  !!!  :!:  !!:  !!:       !!: :!!   \n:!:   !::  :!:  !:!  :!:     :!:  :!:                :!:  !:!   ::!!:!   :!:       :!:  !:!  \n::: ::::  ::   :::  :::     ::    :: ::::           ::::: ::    ::::     :: ::::  ::   :::  \n:: :: :    :   : :   :      :    : :: ::             : :  :      :      : :: ::    :   : :  \n                                                                                             \n\n> You were too slow and got caught!\n\n\n"
    floor3_minigame_gameoverwrong: .asciiz " @@@@@@@@   @@@@@@   @@@@@@@@@@   @@@@@@@@            @@@@@@   @@@  @@@  @@@@@@@@  @@@@@@@   \n@@@@@@@@@  @@@@@@@@  @@@@@@@@@@@  @@@@@@@@           @@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@@  \n!@@        @@!  @@@  @@! @@! @@!  @@!                @@!  @@@  @@!  @@@  @@!       @@!  @@@  \n!@!        !@!  @!@  !@! !@! !@!  !@!                !@!  @!@  !@!  @!@  !@!       !@!  @!@  \n!@! @!@!@  @!@!@!@!  @!! !!@ @!@  @!!!:!             @!@  !@!  @!@  !@!  @!!!:!    @!@!!@!   \n!!! !!@!!  !!!@!!!!  !@!   ! !@!  !!!!!:             !@!  !!!  !@!  !!!  !!!!!:    !!@!@!    \n:!!   !!:  !!:  !!!  !!:     !!:  !!:                !!:  !!!  :!:  !!:  !!:       !!: :!!   \n:!:   !::  :!:  !:!  :!:     :!:  :!:                :!:  !:!   ::!!:!   :!:       :!:  !:!  \n::: ::::  ::   :::  :::     ::    :: ::::           ::::: ::    ::::     :: ::::  ::   :::  \n:: :: :    :   : :   :      :    : :: ::             : :  :      :      : :: ::    :   : :  \n                                                                                             \n\n> You typed the wrong number and got caught!\n\n\n"

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
    beq $t0, $t1, floor2_officefight
   
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
    li $t4, 0
    printstats()

    print(testfight_dialog)
    print(testfight_dialog)
    print(testfight_dialog)
    fakebreakpoint

    clearterminal
    print(testfight_guards)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

    testfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, testfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(testfight_guards)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, testfight_correct # branch to label 'equal' if $v0 == $t5
        j testfight_loop

        testfight_correct:
            addi $t4, $t4, 1
            j testfight_loop

    testfight_turn_ends:
        li $t0, 15 # load immediate value 15 into $t0 (damage multiplier, 7 hits = KO for this fight)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, testfight_enemydead # check if enemy is dead

        randomness(40, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal        
        print(testfight_guards)
        printstats
        
        print(testfight_takehit)
        printregister($t4)
        print(testfight_takehit2)
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(testfight_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2)
        fakebreakpoint
        sleep(1000)

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j testfight_loop

    testfight_enemydead:
        li $t3, 0
        clearterminal
        print(testfight_guards)
        printstats
        print(testfight_takehit)
        printregister($t4)
        print(testfight_takehit2)
        print(testfight_youwin)
        fakebreakpoint
        j debugmenu
    
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
    
invalid_input:
    print(invalid_option) # test output
    j end

checkpoint:
    print(startmenu_prompt) # test output
    j end

startgame:
    clearterminal
    print(floor0_backstory_art)
    print(floor0_backstory_text)
    fakebreakpoint

    clearterminal
    print(sliceview_floor0)
    fakebreakpoint

    j floor0_guardfight

floor0_guardfight:
    clearterminal
    print(testfight_guards)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(floor0_guards_dialog1)
    sleep(3000)
    print(floor0_guards_dialog2)
    sleep(3000)
    print(floor0_guards_dialog3)
    sleep(3000)
    print(floor0_guards_dialog4)
    sleep(3000)
    print(floor0_guards_dialog5)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(testfight_guards)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 20000 # Give 20 seconds to the user

    floor0_guardfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor0_guardfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(testfight_guards)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor0_guardfight_correct # branch to label 'equal' if $v0 == $t5
        j floor0_guardfight_loop

        floor0_guardfight_correct:
            addi $t4, $t4, 1
            j floor0_guardfight_loop

    floor0_guardfight_turn_ends:
        li $t0, 13 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor0_guardfight_enemydead # check if enemy is dead

        randomness(15, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(testfight_guards)
        printstats
        
        printrandom(floor0_guards_inbattle1, floor0_guards_inbattle2, floor0_guards_inbattle3)
        print(floor0_guards_takehit1)
        printregister($t4)
        print(floor0_guards_takehit2)
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(testfight_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2)
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 20000 # Give 20 seconds to the user

        j floor0_guardfight_loop

    floor0_guardfight_enemydead:
        li $t3, 0
        clearterminal
        print(testfight_guards)
        printstats
        print(testfight_takehit)
        printregister($t4)
        print(testfight_takehit2)
        print(enemyvanquished)
        fakebreakpoint

        j floor0_kantinfight


floor0_kantinfight:
    clearterminal
    print(floor0_kantin_ascii)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(floor0_kantin_dialog1)
    sleep(3000)
    print(floor0_kantin_dialog2)
    sleep(3000)
    print(floor0_kantin_dialog3)
    sleep(3000)
    print(floor0_kantin_dialog4)
    sleep(3000)
    print(floor0_kantin_dialog5)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(floor0_kantin_ascii)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

    floor0_kantinfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor0_kantinfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(floor0_kantin_ascii)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor0_kantinfight_correct # branch to label 'equal' if $v0 == $t5
        j floor0_kantinfight_loop

        floor0_kantinfight_correct:
            addi $t4, $t4, 1
            j floor0_kantinfight_loop

    floor0_kantinfight_turn_ends:
        li $t0, 15 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor0_kantinfight_enemydead # check if enemy is dead

        randomness(39, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(floor0_kantin_ascii)
        printstats
        
        printrandom(floor0_kantin_inbattle1, floor0_kantin_inbattle2, floor0_kantin_inbattle3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(floor0_kantin_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2) # leave
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j floor0_kantinfight_loop

    floor0_kantinfight_enemydead:
        li $t3, 0
        clearterminal
        print(floor0_kantin_ascii)
        printstats
        print(testfight_takehit)
        printregister($t4)
        print(testfight_takehit2)
        print(enemyvanquished)
        fakebreakpoint

        clearterminal
        print(floor0_kantin_ascii)
        printstats
        print(floor0_kantin_afterfight1)
        sleep(3000)
        print(floor0_kantin_afterfight2)
        sleep(3000)
        print(floor0_kantin_afterfight3)
        sleep(3000)
        print(floor0_kantin_afterfight4)
        sleep(3000)
        print(floor0_kantin_afterfight5)
        sleep(3000)
        fakebreakpoint

        clearterminal
        print(sliceview_floor1)
        fakebreakpoint
        j floor1_studentfight


floor1_studentfight:
    clearterminal
    print(floor1_student_ascii)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(floor1_student_dialog1)
    sleep(3000)
    print(floor1_student_dialog2)
    sleep(3000)
    print(floor1_student_dialog3)
    sleep(3000)
    print(floor1_student_dialog4)
    sleep(3000)
    print(floor1_student_dialog5)
    sleep(3000)
    print(floor1_student_dialog6)
    sleep(3000)
    print(floor1_student_dialog7)
    sleep(3000)
    print(floor1_student_dialog8)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(floor1_student_ascii)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

    floor1_studentfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor1_studentfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(floor1_student_ascii)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor1_studentfight_correct # branch to label 'equal' if $v0 == $t5
        j floor1_studentfight_loop

        floor1_studentfight_correct:
            addi $t4, $t4, 1
            j floor1_studentfight_loop

    floor1_studentfight_turn_ends:
        li $t0, 10 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor1_studentfight_enemydead # check if enemy is dead

        randomness(25, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(floor0_kantin_ascii)
        printstats
        
        printrandom(floor1_student_inbattle1, floor1_student_inbattle2, floor1_student_inbattle3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(floor1_student_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2) # leave
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j floor1_studentfight_loop

    floor1_studentfight_enemydead:
        li $t3, 0
        clearterminal
        print(floor1_student_ascii)
        printstats
        printrandom(floor1_student_inbattle1, floor1_student_inbattle2, floor1_student_inbattle3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        print(enemyvanquished)
        fakebreakpoint

        clearterminal
        print(floor1_student_ascii)
        printstats
        print(floor1_student_afterfight1)
        sleep(3000)
        print(floor1_student_afterfight2)
        sleep(3000)
        print(floor1_student_afterfight3)
        sleep(3000)
        print(floor1_student_afterfight4)
        sleep(3000)
        print(floor1_student_afterfight5)
        sleep(3000)
        print(floor1_student_afterfight6)
        sleep(3000)
        print(floor1_student_afterfight7)
        sleep(3000)
        print(floor1_student_afterfight8)
        sleep(3000)
        fakebreakpoint

        j floor1_ilkayfight


floor1_ilkayfight:
    clearterminal
    print(floor1_ilkay_ascii)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(floor1_ilkay_dialog1)
    sleep(3000)
    print(floor1_ilkay_dialog2)
    sleep(3000)
    print(floor1_ilkay_dialog3)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(floor1_ilkay_ascii)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

    floor1_ilkayfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor1_ilkayfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(floor1_ilkay_ascii)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor1_ilkayfight_correct # branch to label 'equal' if $v0 == $t5
        j floor1_ilkayfight_loop

        floor1_ilkayfight_correct:
            addi $t4, $t4, 1
            j floor1_ilkayfight_loop
   
    floor1_ilkayfight_turn_ends:
        li $t0, 15 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor1_ilkayfight_enemydead # check if enemy is dead

        randomness(39, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(floor1_ilkay_ascii)
        printstats
        
        printrandom(floor1_ilkay_inbattle1, floor1_ilkay_inbattle2, floor1_ilkay_inbattle3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(floor1_ilkay_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2) # leave
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j floor1_ilkayfight_loop

    floor1_ilkayfight_enemydead:
        li $t3, 0
        clearterminal
        print(floor1_ilkay_ascii)
        printstats
	printrandom(floor1_ilkay_inbattle1, floor1_ilkay_inbattle2, floor1_ilkay_inbattle3)
        print(floor0_guards_takehit1)
        printregister($t4)
        print(floor0_guards_takehit2)
        print(enemyvanquished)
        fakebreakpoint

        clearterminal
        print(floor1_ilkay_ascii)
        printstats
        print(floor1_ilkay_afterfight1)
        sleep(3000)
        print(floor1_ilkay_afterfight2)
        sleep(3000)
        print(floor1_ilkay_afterfight3)
        sleep(3000)
        print(floor1_ilkay_afterfight4)
        sleep(3000)
        print(floor1_ilkay_afterfight5)
        sleep(3000)
        fakebreakpoint
	
	clearterminal
        print(sliceview_floor2)
        fakebreakpoint
        j floor2_studentfight

floor2_studentfight:
    clearterminal
    print(floor2_student_ascii)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(floor2_student_dialog1)
    sleep(3000)
    print(floor2_student_dialog2)
    sleep(3000)
    print(floor2_student_dialog3)
    sleep(3000)
    print(floor2_student_dialog4)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(floor2_student_ascii)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

floor2_studentfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor2_studentfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(floor2_student_ascii)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor2_studentfight_correct # branch to label 'equal' if $v0 == $t5
        j floor2_studentfight_loop

        floor2_studentfight_correct:
            addi $t4, $t4, 1
            j floor2_studentfight_loop
   
    floor2_studentfight_turn_ends:
        li $t0, 15 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor2_studentfight_enemydead # check if enemy is dead

        randomness(39, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(floor2_student_ascii)
        printstats
        
        printrandom(floor2_student_inbattle1, floor2_student_inbattle2, floor2_student_inbattle3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(floor2_student_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2) # leave
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j floor2_studentfight_loop

    floor2_studentfight_enemydead:
        li $t3, 0
        clearterminal
        print(floor2_student_ascii)
        printstats
        printrandom(floor2_student_inbattle1, floor2_student_inbattle2, floor2_student_inbattle3)
        print(floor0_guards_takehit1)
        printregister($t4)
        print(floor0_guards_takehit2)
        print(enemyvanquished)
        fakebreakpoint

        clearterminal
        print(floor2_student_ascii)
        printstats
        print(floor2_student_afterfight1)
        sleep(3000)
        print(floor2_student_afterfight2)
        sleep(3000)
        print(floor2_student_afterfight3)
        sleep(3000)
        print(floor2_student_afterfight4)
        sleep(3000)
        fakebreakpoint

        j floor2_officefight
		
floor2_officefight:
    clearterminal
    print(office_artbig)
    sleep(3000)
    clearterminal
    print(office_art)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(office_beforefight_convo1)
    sleep(3000)
    print(office_beforefight_convo2)
    sleep(3000)
    print(office_beforefight_convo3)
    sleep(3000)
    print(office_beforefight_convo4)
    sleep(3000)
    print(office_beforefight_convo5)
    sleep(3000)
    print(office_beforefight_convo6)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(office_art)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

    floor2_officefight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor2_officefight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(office_art)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor2_officefight_correct # branch to label 'equal' if $v0 == $t5
        j floor2_officefight_loop

        floor2_officefight_correct:
            addi $t4, $t4, 1
            j floor2_officefight_loop

    floor2_officefight_turn_ends:
        li $t0, 15 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor2_officefight_enemydead # check if enemy is dead

        randomness(39, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(office_art)
        printstats
        
        printrandom(office_infight1, office_infight2, office_infight3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(floor2_office_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2) # leave
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j floor2_officefight_loop

    floor2_officefight_enemydead:
        li $t3, 0
        clearterminal
        print(office_art)
        printstats
        printrandom(office_infight1, office_infight2, office_infight3)
        print(floor0_guards_takehit1)
        printregister($t4)
        print(floor0_guards_takehit2)
        print(enemyvanquished)
        fakebreakpoint

        clearterminal
        print(office_art)
        printstats
        print(office_afterfight_convo1)
        sleep(3000)
        print(office_afterfight_convo2)
        sleep(3000)
        print(office_afterfight_convo3)
        sleep(3000)
        print(office_afterfight_convo4)
        sleep(3000)
        print(office_afterfight_convo5)
        sleep(3000)
        print(office_afterfight_convo6)
        sleep(3000)
        print(office_afterfight_convo7)
        sleep(3000)
        print(office_afterfight_convo8)
        sleep(3000)
        
        fakebreakpoint
        clearterminal
        print(office_art)
        printstats
        
        print(office_afterfight_convo9)
        sleep(3000)
        print(office_afterfight_convo10)
        sleep(3000)
        print(office_afterfight_convo11)
        sleep(3000)
        print(office_afterfight_convo12)
        sleep(3000)
        print(office_afterfight_convo13)
        sleep(3000)
        print(office_afterfight_convo14)
        sleep(3000)
        print(office_afterfight_convo15)
        sleep(3000)
        print(office_afterfight_convo16)
        sleep(3000)
        print(office_afterfight_convo17)
        sleep(3000)
        fakebreakpoint

        clearterminal
        print(sliceview_floor3)
        fakebreakpoint
        j floor3_slither_minigame

floor3_slither_minigame:
    clearterminal
    print(floor3_minigame_ascii1)
    print(floor3_minigame_dialog1)
    sleep(3000)
    print(floor3_minigame_dialog2)
    sleep(3000)
    print(floor3_minigame_instructions)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(floor3_minigame_ascii1)

    randomness(9, 0)
    print(floor3_minigame_prompt1)
    printregister($t5)
    print(floor3_minigame_prompt2)
    print(answer_prompt)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 3000 # Give 3 seconds to the user

    # read integer from user
    li $v0, 5
    syscall
    move $t0, $v0

    li $v0, 30
    syscall
    move $t8, $a0 # Store time in $t8
    bgt $t8, $t9, floor3_minigame_gameover_tooslow  # too slow

    # check if user entered correct
    move $t1, $t5
    beq $t0, $t1, minigame_correct1

    # WRONG
    j floor3_minigame_gameover_incorrect

    minigame_correct1:
        clearterminal
        print(floor3_minigame_ascii2)

        randomness(9, 0)
        print(floor3_minigame_prompt1)
        printregister($t5)
        print(floor3_minigame_prompt2)
        print(answer_prompt)

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 3000 # Give 3 seconds to the user

        # read integer from user
        li $v0, 5
        syscall
        move $t0, $v0

        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor3_minigame_gameover_tooslow  # too slow

        # check if user entered correct
        move $t1, $t5
        beq $t0, $t1, minigame_correct2

        # WRONG
        j floor3_minigame_gameover_incorrect

        minigame_correct2:
            clearterminal
            print(floor3_minigame_ascii3)

            randomness(9, 0)
            print(floor3_minigame_prompt1)
            printregister($t5)
            print(floor3_minigame_prompt2)
            print(answer_prompt)

            # Get current time before user input
            li $v0, 30
            syscall
            move $t9, $a0 # Store starting time in $t9
            addi $t9, $t9, 3000 # Give 3 seconds to the user

            # read integer from user
            li $v0, 5
            syscall
            move $t0, $v0

            li $v0, 30
            syscall
            move $t8, $a0 # Store time in $t8
            bgt $t8, $t9, floor3_minigame_gameover_tooslow  # too slow

            # check if user entered correct
            move $t1, $t5
            beq $t0, $t1, minigame_correct3

            # WRONG
            j floor3_minigame_gameover_incorrect

            minigame_correct3:
                clearterminal
                print(floor3_minigame_ascii4)
                print(floor3_after_hallway)
                print(floor3_before_toasterguy)
                fakebreakpoint

                clearterminal
                print(floor0_kantin_ascii)
                print(floor3_toasterguy_dialog1)
                sleep(3000)
                print(floor3_toasterguy_dialog2)
                sleep(3000)
                print(floor3_toasterguy_dialog3)
                sleep(3000)
                print(floor3_toasterguy_dialog4)
                sleep(3000)

                j floor3_librarianfight #librarian fight


floor3_minigame_gameover_tooslow:
    clearterminal
    print(floor3_minigame_gameoverslow)
    fakebreakpoint
    j main

floor3_minigame_gameover_incorrect:
    clearterminal
    print(floor3_minigame_gameoverwrong)
    fakebreakpoint
    j main


floor3_librarianfight:
	clearterminal
    print(floor3_librarian_ascii)

    li $t2, 100
    li $t3, 100
    li $t4, 0
    li $t5, 0
    printstats()

    print(floor3_library_dialog1)
    sleep(3000)
    print(floor3_library_dialog2)
    sleep(3000)
    print(floor3_library_dialog3)
    sleep(3000)
    print(floor3_library_dialog4)
    sleep(3000)
    print(floor3_library_dialog5)
    sleep(3000)
    print(floor3_library_dialog6)
    sleep(3000)
    fakebreakpoint

    clearterminal
    print(floor3_librarian_ascii)
    printstats
    print(fight_starting)
    sleep(5000)

    # Get current time before user input
    li $v0, 30
    syscall
    move $t9, $a0 # Store starting time in $t9
    addi $t9, $t9, 15000 # Give 15 seconds to the user

floor3_librarianfight_loop:
        li $v0, 30
        syscall
        move $t8, $a0 # Store time in $t8
        bgt $t8, $t9, floor3_librarianfight_turn_ends # if $t8 > $t9 exit the loop

        clearterminal
        print(floor3_librarian_ascii)
        printstats

        randomness(89999, 10000)

        print(testfight_instruction)
        printregister($t5)
        print(newline)
        print(answer_prompt)

        li $v0, 5 # system call code for reading an integer
        syscall # read integer from user and store in $v0
        beq $v0, $t5, floor3_librarianfight_correct # branch to label 'equal' if $v0 == $t5
        j floor3_librarianfight_loop

        floor3_librarianfight_correct:
            addi $t4, $t4, 1
            j floor3_librarianfight_loop
   
    floor3_librarianfight_turn_ends:
        li $t0, 15 # load immediate value 15 into $t0 (damage multiplier)
        mult $t4, $t0 # multiply $t4 by $t0
        mflo $t4 # move the result from the LO register to $t4
        sub $t3, $t3, $t4 # deal dmg to enemy
        bltz $t3, floor3_librarianfight_enemydead # check if enemy is dead

        randomness(39, 10)
        sub $t2, $t2, $t5 # player takes dmg

        clearterminal
        print(floor3_librarian_ascii)
        printstats
        
        printrandom(floor3_library_inbattle1, floor3_library_inbattle2, floor3_library_inbattle3)
        print(floor0_guards_takehit1) # leave
        printregister($t4)
        print(floor0_guards_takehit2) # leave
        li $t4, 0 # reset dmg
        sleep(1500)
        
        print(newline)
        print(floor3_library_hitplayer_dialog)
        printregister($t5)
        print(testfight_takehit2) # leave
        print(newline)
        fakebreakpoint

        # Get current time before user input
        li $v0, 30
        syscall
        move $t9, $a0 # Store starting time in $t9
        addi $t9, $t9, 15000 # Give 15 seconds to the user

        j floor3_librarianfight_loop

    floor3_librarianfight_enemydead:
        li $t3, 0
        clearterminal
        print(floor3_librarian_ascii)
        printstats
        printrandom(floor3_library_inbattle1, floor3_library_inbattle2, floor3_library_inbattle3)
        print(floor0_guards_takehit1)
        printregister($t4)
        print(floor0_guards_takehit2)
        print(enemyvanquished)
        fakebreakpoint

        clearterminal
        print(floor3_librarian_ascii)
        printstats
        print(floor3_library_afterbattle1)
        sleep(3000)
        print(floor3_library_afterbattle2)
        sleep(3000)
        print(floor3_library_afterbattle3)
        sleep(3000)
        print(floor3_library_afterbattle4)
        sleep(3000)
        fakebreakpoint

        j debugmenu
end:
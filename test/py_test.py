# -*- coding: utf-8 -*-
import time

processed_state = {}
state_record = {}
current_state = {}
temp_state = {}
step = 0

# check the correspounding state existence and record it in processed_state, current_state and state_record
# r_b_state: index from red/blud tiles
# white_state: index from the white tile
# dir: the last motion resulting in the current state
def check_and_set( r_b_state, white_state, dir ):
    if processed_state.has_key(r_b_state):
        if processed_state[r_b_state][white_state]:
            return True
        
    if not processed_state.has_key(r_b_state):
        processed_state[r_b_state] = [False, False, False, False, False, False, False, False]
        state_record[r_b_state] = ['','','','','','','','']
    processed_state[r_b_state][white_state] = True
    state_record[r_b_state][white_state] = dir
    
    if not temp_state.has_key(r_b_state):
        temp_state[r_b_state] = [False, False, False, False, False, False, False, False]
    temp_state[r_b_state][white_state] = True

# decode the current state and check the 4 possible motion, record them if necessary
# r_b_state: index from red/blud tiles
# white_state: index from the white tile 
def get_adjacent_state(r_b_state, white_state):
    lResult = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    lWhite_count = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    one_count = 0
    white_pos = 0
    r_b_state_bak = r_b_state
    for i in range(0, 16):
        if 1 == r_b_state & 1 :
            lResult[i] = 1
            lWhite_count[i] = one_count
            one_count += 1
            if 0 == white_state:
                white_pos = i
            white_state -= 1
        else:
            lWhite_count[i] = one_count
        r_b_state = r_b_state >> 1

    white_y = white_pos / 4
    white_x = white_pos % 4

    if white_x > 0:
        if 1 == lResult[white_pos-1]:
            rbs = r_b_state_bak
        else:
            rbs = r_b_state_bak - (1<<(white_pos-1))
        ws = lWhite_count[white_pos-1]
        check_and_set(rbs, ws, 'L')
    if white_x < 3:
        if 1 == lResult[white_pos+1]:
            rbs = r_b_state_bak
            ws = lWhite_count[white_pos+1]
        else:
            rbs = r_b_state_bak + (1 << white_pos)
            ws = lWhite_count[white_pos+1]-1
        check_and_set(rbs, ws, 'R')
    if white_y > 0:
        if 1 == lResult[white_pos-4]:
            rbs = r_b_state_bak
        else:
            rbs = r_b_state_bak - 15*(1<<(white_pos-4))
        ws = lWhite_count[white_pos-4]
        check_and_set(rbs, ws, 'U')
    if white_y < 3:
        if 1 == lResult[white_pos+4]:
            rbs = r_b_state_bak
            ws = lWhite_count[white_pos+4]
        else:
            rbs = r_b_state_bak + 15*(1<<white_pos)
            ws = lWhite_count[white_pos+4]-1
        check_and_set(rbs, ws, 'D')
    return

# traceback the motion sequence from state_record
# final_rbs: target index from red/blud files
# final_ws: target index from the while tile
def traceback(final_rbs, final_ws):
    lMotion_seq = []
    while ( 13107 != final_rbs or 0 != final_ws ):
        dir = state_record[final_rbs][final_ws]
        lMotion_seq.append(dir)
        
        lResult = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        lWhite_count = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        one_count = 0
        white_pos = 0
        white_state = final_ws
        r_b_state = final_rbs
        r_b_state_bak = r_b_state
        for i in range(0, 16):
            if 1 == r_b_state & 1 :
                lResult[i] = 1
                lWhite_count[i] = one_count
                one_count += 1
                if 0 == white_state:
                    white_pos = i
                white_state -= 1
            else:
                lWhite_count[i] = one_count
            r_b_state = r_b_state >> 1
        white_y = white_pos / 4
        white_x = white_pos % 4

        if 'L' == dir:
            if 1 == lResult[white_pos+1]:
                final_rbs = r_b_state_bak
                final_ws = lWhite_count[white_pos+1]
            else:
                final_rbs = r_b_state_bak + (1 << white_pos)
                final_ws = lWhite_count[white_pos+1]-1
        elif 'R' == dir:
            if 1 == lResult[white_pos-1]:
                final_rbs = r_b_state_bak
            else:
                final_rbs = r_b_state_bak - (1<<(white_pos-1))
            final_ws = lWhite_count[white_pos-1]
        elif 'U' == dir:
            if 1 == lResult[white_pos+4]:
                final_rbs = r_b_state_bak
                final_ws = lWhite_count[white_pos+4]
            else:
                final_rbs = r_b_state_bak + 15*(1<<white_pos)
                final_ws = lWhite_count[white_pos+4]-1
        else:
            if 1 == lResult[white_pos-4]:
                final_rbs = r_b_state_bak
            else:
                final_rbs = r_b_state_bak - 15*(1<<(white_pos-4))
            final_ws = lWhite_count[white_pos-4]

    lMotion_seq.reverse()
    print lMotion_seq

# main search process
def start_search():
    # for implicity the first state-check is omitted... U_U
    # put the init state into the state dicts
    global current_state
    current_state[13107] = [True, False, False, False, False, False, False, False]
    state_record[13107] = ['','','','','','','','']
    processed_state[13107] = [True, False, False, False, False, False, False, False]

    # start searching, set 50 as the upperbound for search. It's not reasonable only for protection.
    global step
    while(step < 50):
        global temp_state
        temp_state = {}
        for cs in current_state:
            lWhite_state = current_state[cs]
            for i in range(0,8):
                if lWhite_state[i]:
                    if 42405 == cs and 0 == i:
                        print "Got it!" + str(step) + " steps"
                        traceback( 42405, 0 )
                        return
                    current_state[cs][i] = False
                    get_adjacent_state(cs, i)
        current_state = temp_state
        step += 1
    return

start_time = time.time()
start_search()
print str(time.time() - start_time) + "s passed"
        

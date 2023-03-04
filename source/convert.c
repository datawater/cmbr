#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

uint16_t string_to_cmbr(char *string) {
    register uint8_t piece = 0;
    register uint8_t turn_into = 0;
    register uint8_t to_square = 0;
    register uint8_t from_square = 0;
    
    register size_t len = strlen((char*) string);
    register bool from_square_needs_using = false;
    register bool column_or_file = false;
    
    static const uint8_t piece_lookup['R' - 'A' + 1] = {
        ['N'-'A'] = 0b001, ['B'-'A'] = 0b010, ['R'-'A'] = 0b011, 
        ['Q'-'A'] = 0b100, ['K'-'A'] = 0b101, 0
    };
    
    static const uint8_t turn_into_lookup['R' - 'A' + 1] = {
        ['N'-'A'] = 0b00, ['B'-'A'] = 0b01,
        ['R'-'A'] = 0b10, ['Q'-'A'] = 0b11,
    };
    
    if (strncmp(string, "O-O", 3)   == 0)
        return 0b110;
    if (strncmp(string, "O-O-O", 5) == 0)
        return 0b111;

    if (islower(string[0])) {
        piece = 0;
    } else {
        if (string[0] != '\0') {
            piece = piece_lookup[(int) (string[0] - 'A')];
            string++; len--;
        }
    }
    
    if (piece != 0) {
        string++; len--;
    } // If the piece isn't a pawn, remove the first charachter  
     
    if (string[len-2] == '=') {
        turn_into = turn_into_lookup[(int) string[len-1]];
        string[len-1] = '\0'; string[len-2] = '\0'; len -= 2;
    }
    
    to_square = (uint8_t) ((string[len-1]-'0'-1) << 3) | ((uint8_t) string[len-2]-'A'-1);
    
    if (string[0] != '\0') {
        from_square_needs_using = true;
        if (isalpha(string[0])) from_square = string[0] - 'A' - 1;
        else {from_square = string[0] - '0' - 1; column_or_file = true;}
    }
    
    register uint16_t final_cmbr = turn_into;
    
    if (!from_square_needs_using) {final_cmbr <<= 5;}
    else {
        final_cmbr <<= 1; final_cmbr |= 1; 
        final_cmbr <<= 1; final_cmbr |= column_or_file; 
        final_cmbr <<= 3; final_cmbr |= from_square;
    }
    
    final_cmbr <<= 6; final_cmbr |= to_square; 
    final_cmbr <<= 3; final_cmbr |= piece;
    
    return final_cmbr;
}
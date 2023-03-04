/**
 * Authors: Data gogiberidze <datawater1@gmail.com>
 */

module convert;

import std.stdio, std.string, std.stdint, std.encoding;
import core.stdc.string, core.stdc.ctype;
import utils, console;

extern (C) {
uint16_t string_to_cmbr(char* string);
}

/**
 * Basically a 2 dimensional array that represnets the metadata in text format.
 * 
 *
 * key   - An array of chars that stores the key value. Eg: `[Foo "Bar"]``, Key would store `Foo`
 * value - An array of chars that stores the value.                         Value here would store `Bar`
 */
struct metadata_text {
    align:
        char[16] key;
        char[32] value;
}

/** 
 * Flags that a cmbr can have
 */
enum cmbr_flag {
    no_flag,
    starts_variation,
    starts_variation_with_black,
    ends_variation
}

/**
 * A CMBR representation struct
 */
struct cmbr_move {
    align:
        uint16_t move;
        int flags;
    this(uint16_t move, int flags) {
        this.move = move; this.flags = flags;
    }
}

/**
 * A funciton that converts a pgn file to cmbr file
 *
 *
 * input_file_names -- An array of input file names
 * input_files_num  -- The size of the array of input file names
 * output_file_name -- The name of an output file
 */
void pgn_to_cmbr(string[256] input_files, uint8_t input_files_length, string output_filename) {
    File output_file;
    try {output_file = File(output_filename, "wb");} catch (Error err) {
        console.error("Couldn't open file: %s. Reason: %s\n", output_filename.ptr, err.msg.ptr);
        utils.exit(1);
    }

    ulong line_number             = 0;
    metadata_text[16] metadata    = {0};  uint8_t metadata_i = 0;
    string[32] game;                      uint8_t game_i     = 0;
    cmbr_move[256] moves;

    for (int file_i = 0; file_i < input_files_length; file_i++) {
        File input_file;
        try {
            input_file = File(input_files[file_i], "r");
        } catch (Error err) {
            console.error("Couldn't open file: %s. Reason: %s\n", toStringz(input_files[file_i]), toStringz(err.msg));
            utils.exit(1);
        }

        while (!input_file.eof()) {
            line_number++;
            if (line_number % 1000 == 0 || line_number == 1)
                console.info("Reading line number: %lu. File: %s\n", line_number, toStringz(input_files[file_i]));
           
            string line = input_file.readln(); //line = \;
            if (line.length < 3) continue;

            line = strip(line);

            /// If the first char of the line is a `[`. it means that the line if for metadata.
            if (line[0] == '[') {
                carve_metadata(line, &metadata[metadata_i++]); continue;
            }

            game[game_i++] = line;

            string last_three = line[$-3 .. $];

            if (last_three == "1/2" || last_three == "1-0" || last_three == "0-1") {
                game_to_moves(game.ptr, game_i, moves.ptr);
            }
        }
    }
}

void cmbr_to_pgn(string[256] input_files, uint8_t input_files_length, string output_file) {
    // TODO: Implement function cmbr_to_pgn
    assert("TODO. IMPLEMENT FUNCTION CMBR_TO_PGN" && 0);
}

/**
 * Carves out metadata from a string and saves it into the supplied metadata_txt
 *
 *
 * line      -- The input string
 * metadata_ -- Pointer to the metadata_txt buffer
*/
void carve_metadata(string line_, metadata_text* metadata) {
    ulong length = line_.length;
    assert(!(length < 5)); // The smallest valid tag pair should be [ ""] whichs length is 5.

    char* line = cast(char*) toStringz(line_);

    line++; length--;  // Remove the `[` ==> Foo "Bar"]
    length -= 2;       // Removes the ending `"]` ==> Foo "Bar

    // Extract the key
    for (int i = 0; line[0] != '\0' && line[0] != ' '; i++) // ==> "Bar
        metadata.key[i] = line++[0 & length--]; // `0 & length--` is just a trick to decrement the length in one line, since `0 & x` is 0
    
    line += 2; length -= 2; // Remove the ` "`. ==> Bar
    // Now, all that's left in line is the value. So we can copy it into the metadata.value
    for (int i = 0; i < length; i++)
        metadata.value[i] = line[i];
}

/** A Function that converts and stores a raw string game into a cmbr array
 *
 *
  * game     -- An array of strings that hold the game
 *  moves    -- A pointer to the cmbr array where the result needs to be stored
 *  game_len -- The size of the "game" array
 */
void game_to_moves(string* game, ubyte game_i, cmbr_move* moves) {
    // TODO: Implement variation support.

    ubyte moves_i = 0;

    for (int i = 0; i < game_i; i++) {
        ulong string_length = (game[i]).length;

        char[16] buffer; ubyte buffer_i = 0;
        utils.memset(cast(char*)&buffer, '\0', 16);

        for (size_t string_i = 0; string_i < string_length; string_i++) {
            /// If encountered `.` the string stored in the buffer was a number.
            if (game[i][string_i] == '.') {
                utils.memset(cast(char*)&buffer, '\0', buffer_i); string_i++;
                buffer_i = 0;
                continue;
            }

            /** 
             * If encountered ` ` the string stored in the buffer was a string
             * Example:
                * 1. e4 e5
                * After one pass after detecting `.` and the buffer is discarded and the loop
                * skips over the ` `
                * After the second path, after detecting the ` ` the buffer gets passed into the convertion
                * function and then the loop starts again.
             */
            if (game[i][string_i] == ' ') {
                uint16_t cmbr = string_to_cmbr(cast(char*)toStringz(buffer));
                moves[moves_i] = cmbr_move(cmbr, cmbr_flag.no_flag);

                writef("Move: %d\n", cmbr);

                utils.memset(cast(char*)&buffer, '\0', buffer_i); 
                buffer_i = 0;
                
                continue;
            }

            if (game[i][string_i] == 'x' || game[i][string_i] == '+'
            ||  game[i][string_i] == '!' || game[i][string_i] == '?'
            ||  game[i][string_i] == '#') continue;

            buffer[buffer_i++] = game[i][string_i];
        }
    }
}
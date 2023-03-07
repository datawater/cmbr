// ? TODO: Follow stylistic guidelines

/**
 * Authors: Data gogiberidze <datawater1@gmail.com>
 */

module convert;

import std.stdio, std.string, std.stdint, std.encoding;
import core.stdc.string, core.stdc.ctype, core.stdc.stdio;
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
    char[16] key;
    char[32] value;
}

/** 
 * Flags that a cmbr can have
 */
enum cmbr_flag : ubyte {
    no_flag = 0,
    starts_variation = 1,
    starts_variation_with_black = 2,
    ends_variation = 3,
}

/**
 * A CMBR representation struct
 */
struct cmbr_move {
    uint16_t move;
    ubyte flags;
    this(uint16_t move, ubyte flags) {
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
    // TODO: PGN Validation
    // TODO: Checksum for each game or file || (Maybe XXH3) https://cyan4973.github.io/xxHash/ 
    // *                                                    https://github.com/Cyan4973/xxHash
    // *                                                    https://github.com/repeatedly/xxhash-d
    // TODO: Multi-threading

    File output_file;
    try {output_file = File(output_filename, "wb");} catch (Error err) {
        console.error("Couldn't open file: %s. Reason: %s\n", toStringz(output_filename), toStringz(err.msg));
        utils.exit(1);
    }

    output_file.write("cmbr\4"); // CMBR file magic number. http://en.wikipedia.org/wiki/Magic_number_(programming) 

    ulong line_number             = 0;
    metadata_text[16] metadata    = {0, 0};  uint8_t metadata_i = 0;
    string[32] game;                         uint8_t game_i     = 0;
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
            // TODO: A proper progress bar, using threads and fseek.s
            if (line_number % 1000 == 0 || line_number == 1)
                console.info("Reading line number: %lu. File: %s\n", line_number, toStringz(input_files[file_i]));
           
            string line = input_file.readln(); //line = \;
            line = strip(line);
            if (line.length < 3) {continue;}

            /// If the first char of the line is a `[`. it means that the line if for metadata.
            if (line[0] == '[') {
                carve_metadata(line, &metadata[metadata_i++]); continue;
            }

            game[game_i++] = line;

            string last_three = line[$-3 .. $];

            if (last_three == "1/2" || last_three == "1-0" || last_three == "0-1" || last_three == "  *") {
                ubyte moves_i = game_to_moves(game.ptr, game_i, moves.ptr);

                // FIXME
                char result;
                if (last_three == "1/2") result = 'd';
                if (last_three == "1-0") result = 'w';
                if (last_three == "0-1") result = 'b';
                if (last_three == "  *") result = 'u';

                write_as_cmbr(moves.ptr, metadata.ptr, output_file, moves_i, metadata_i, result);

                game_i = 0; metadata_i = 0;
                for (int i = 0; i < metadata_i; i++) {
                    utils.memset(cast(char*)&(metadata[i].key),   '\0', 16);
                    utils.memset(cast(char*)&(metadata[i].value), '\0', 32);
                }
            }
        }

        input_file.close();
        console.printc(FGREEN, toStringz("[SUCCESS]"));
        writefln(" Converted file: `%s` to .cmbr format.", input_files[file_i]);
    }

    output_file.close();
}

void cmbr_to_pgn(string[256] input_files, uint8_t input_files_length, string output_filename) {
    File output_file;
    try {
        output_file = File(output_filename, "w");
    } catch(Error err) {
        console.error("Couldn't open file: %s. Reason: %s\n", toStringz(output_filename), toStringz(err.msg));
        utils.exit(1);
    }

    FILE* output_handle = output_file.getFP();

    for (int file_i = 0; file_i < input_files_length; file_i++) {
        File input_file;
        try {
            input_file = File(input_files[file_i], "rb");
        } catch (Error err) {
            console.error("Couldn't open file: %s. Reason: %s\n", toStringz(input_files[file_i]), toStringz(err.msg));
            utils.exit(1);
        }

        FILE* input_handle = input_file.getFP();

        char[5] magic = new char[5]; input_file.rawRead(magic);
        if (strncmp(toStringz(magic), toStringz("cmbr\4"), 5) != 0) {
            console.error("Invalid CMBR file: %s.", toStringz(input_files[file_i]));
            utils.exit(1);
        }

        char r;
        while (!input_file.eof()) {
            char[2] two_bytes = [cast(char)fgetc(input_handle), cast(char)fgetc(input_handle)];

            if (strncmp(toStringz(two_bytes), toStringz("\1\1"), 2) == 0) {
                int metadata_size = fgetc(input_handle);
                for (int metadata_i = 0; metadata_i < metadata_size; metadata_i++) {
                    char[32][2] metadata;
                    int[2] kv_size;

                    for (int kv = 0; kv < 2; kv++) {
                        kv_size[kv] = fgetc(input_handle);
                        for (int i = 0; i < kv_size[kv]; i++)
                            metadata[kv][i] = cast(char)fgetc(input_handle);
                    }

                    core.stdc.stdio.fprintf(output_handle, "[%.*s \"%.*s\"]\n", kv_size[0], toStringz(metadata[0]), 
                                                                                kv_size[1], toStringz(metadata[1]));
                }
                output_file.write("\n");
            }

            if (strncmp(toStringz(two_bytes), toStringz("\4\4"), 2) == 0) {
                int game_size          = fgetc(input_handle);
                bool is_first_halfmove = true;
                int game_moves_count   = 0;
                
                if (is_first_halfmove) game_moves_count++;
                
                for (int game_i = 0; game_i < game_size; game_i++) {
                    // TODO: Handle Variations
                    ushort cmbr_move = cast(ushort)(fgetc(input_handle) << 8 | fgetc(input_handle));

                    if (is_first_halfmove) {fprintf(input_handle, "%d. %s ", game_moves_count, toStringz(cmbr_to_text(cmbr_move)));}
                    else                   {fprintf(input_handle, "%s ",     toStringz(cmbr_to_text(cmbr_move))); ++game_moves_count;}
                    
                    if (game_moves_count % 7 == 0)
                        fputc('\n', input_handle);
                    
                    is_first_halfmove = !is_first_halfmove;
                }

                // A tring to read and ignore 2 charachters, and then read and store the third one in one line
                // ((0 & x) & y) | y = (0 & y) | z = 0 | z = z
                char result_c = cast(char)(((0 & fgetc(input_handle)) & fgetc(input_handle)) | fgetc(input_handle));
                string result;

                if (result_c == 'd') result = "1/2";
                if (result_c == 'w') result = "1-0";
                if (result_c == 'b') result = "0-1";
                if (result_c == 'u') result = "  *";

                fprintf(input_handle, " %s\n\n", toStringz(result));
            }
        }

        input_file.close();
    }
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
    for (int i = 0; line[0] != ' '; i++) // ==> "Bar
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
ubyte game_to_moves(string* game, ubyte game_i, cmbr_move* moves) {
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
                moves[moves_i++] = cmbr_move(cmbr, cmbr_flag.no_flag);

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

    return moves_i;
}

/** A Funciton that writes an array of cmbrs and metadata into the inputed file
 *
 *
 * moves        - The array of cmbrs to write
 * metadata     - The metadata to write
 * output       - A file pointer to the file.
 * moves_len    - The length of the array of moves
 * metadata_len - The length of the array of metadata
 */

void write_as_cmbr(cmbr_move* moves, metadata_text* metadata, File output, ubyte moves_len, ubyte metadata_len, char result) {
    FILE* output_handle = output.getFP();

    fputs("\1\1", output_handle); // Metadata start
    fputc(cast(char)metadata_len, output_handle); // Amount of metadata lines

    for (ubyte i = 0; i < metadata_len; i++) {
        ubyte key_length = cast(ubyte)strlen(toStringz(metadata[i].key));
        ubyte val_length = cast(ubyte)strlen(toStringz(metadata[i].value));

        fputc(cast(char)key_length, output_handle);
        fwrite(cast(void*)toStringz(metadata[i].key),   1, key_length, output_handle);
        fputc(cast(char)val_length, output_handle);
        fwrite(cast(void*)toStringz(metadata[i].value), 1, val_length, output_handle);
    }

    fputs("\4\4", output_handle); // Start of game
    fwrite(cast(void*)&moves_len, cast(ulong)(ubyte.sizeof), 1, output_handle); // Amount of moves

    for (ubyte i = 0; i < moves_len; i++) {
        cmbr_move to_write = moves[i];
        fprintf(output_handle, "%c%c%c", to_write.flags, to_write.move >> 8, to_write.move & ((1 << 8)-1));
    }
    fprintf(output_handle, "\3\3%c", result);
}


/************************************/
string cmbr_to_text(ushort cmbr) {
    ubyte pieceb = cmbr & 0x7; // Get the last 3 bits
    char piece = ' ';

    switch (pieceb) {
        case 0b000: {} break;
        case 0b001: {piece = 'N';}    break;
        case 0b010: {piece = 'B';}    break;
        case 0b011: {piece = 'R';}    break;
        case 0b100: {piece = 'Q';}    break;
        case 0b101: {piece = 'K';}    break;
        case 0b110: {return "O-O";}
        case 0b111: {return "O-O-O";}
        default: assert(0);
    }

    char to_square_ver = ((cmbr >> 3) & 0x7) + 1 + 96; // Remove the last 3 bits and get the last 3 bits
    char to_square_hor = ((cmbr >> 6) & 0x7) + 1 + 48; // Remove the last 6 bits and get the last 3 bits


    char from_square = ' ';
    if (((cmbr >> (9+4)) & 1) == 1) { // Get the use-or-not bit.
        ushort to_add = (((cmbr >> (9+3)) & 1) == 1) ? 48 : 96; // Determen if it's a column or a file
        from_square   = cast(char)(((cmbr >> 9) & 0x7) + 1 + to_add);
    }

    char turn_into = ' ';
    if (piece == ' ' && (to_square_hor == '8' || to_square_hor == '1')) {
        switch (cmbr >> 14) {
            case 0b00: {turn_into = 'N';} break;
            case 0b01: {turn_into = 'B';} break;
            case 0b10: {turn_into = 'R';} break;
            case 0b11: {turn_into = 'Q';} break;
            default:   {assert(0 && "UNCREACHABLE");}
        }
    }

    uint i = 0;
    char[8] to_return;

    if (piece != ' ') to_return[i++] = piece;
    if (from_square != ' ') to_return[i++] = from_square;

    to_return[i++] = to_square_ver;
    to_return[i++] = to_square_hor;

    if (turn_into != ' ') {
        to_return[i++] = '=';
        to_return[i++] = turn_into;
    }

    return to_return[0 .. i].idup;
}
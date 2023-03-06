// ? TODO: Follow stylistic guidelines

/**
 * Authors: Data gogiberidze <datawater1@gmail.com>
 */

import std.stdio, std.file, std.array, std.stdint;
import core.memory;
import console, convert;

void usage() {
    console.printc(FYELLOW, "Author: "); printf("datawater\n");
    console.printc(FYELLOW, "Usage: ");
    printf("cmbr [OPTIONS] [INPUT_FILES] --output [OUTPUT_FILE] [CONcERTION_MODE]\n\tOptions:\n\t\t-h or --help\n\t\t\tDisplays this help message\n\t\t-o or --output\n\t\t\tSpecifies the output file (required)\n\t\t-ptc or --pgn-to-cmbr\n\t\t\tSets the convertion mode to from pgn to cmbr.\n\t\t-ctp or --cmbr-to-pgn\n\t\t\tSets the convertion mode to from cmbr to pgn\n\n");
}

int main(string[] argv) {
	GC.disable();

	uint64_t argc = argv.length-1; argv.popFront(); // @suppress(dscanner.suspicious.length_subtraction)
	console.init();
	
	string[256] input_files; uint8_t input_files_i = 0;
	string      output_file = "";
	/**
		-1 : Not set
		0  : Pgn to CMBR
		1  : CMBR to pgn
	*/
	int convertion_mode = -1;

	for (uint64_t i = 0; i < argc; i++) {
		if (argv[i] == "--help" || argv[i] == "-h") {
			usage(); return 0;
		}
		
		else if (argv[i] == "--output" || argv[i] == "-o") {
			if (output_file != "") {
				console.error("Output file already set. Run `cmbr --help` for help.\n");
				return 1;
			}

			if (i+1 > argc-1) {
				console.error("Filename is not specified for the -output flag. Run `cmbr --help` for help.\n");
				return 1;
			}

			output_file = argv[++i];
		}
		
		else if (argv[i] == "--pgn-to-cmbr" || argv[i] == "-ptc")
			convertion_mode = 0;
		
		else if (argv[i] == "--cmbr-to-pgn" || argv[i] == "-ctp")
			convertion_mode = 1;
		
		else if (argv[i][0] == '-') {
			console.error("Invalid flag: \033[1m`%s`\033[0m | Position: \033[1m%d\033[0m.\n\tRun `cmbr --help` for Usage.\n", 
					     argv[i].ptr, i+1);

			return 1; 
		}

		else {
			if (!exists(argv[i])) {
				console.error("Input File: `%s` Doesn't exist. Run `cmbr --help` for help.\n", argv[i].ptr);	
				return 1;
			}

			input_files[input_files_i++] = argv[i];
		}
	}

	if (output_file == "") {
		console.error("Output file not set. Run `cmbr --help` for help.\n");
		return 1;
	}

	if (input_files_i == 0) {
		console.error("Input files not provided. Run `cmbr --help` for help.\n");
		return 1;
	}

	if (convertion_mode == -1)
		{console.error("Convertion mode not set. Run `cmbr --help` for help.\n"); return 1;}
	if (convertion_mode == 0)
		convert.pgn_to_cmbr(input_files, input_files_i, output_file);
	if (convertion_mode == 1)
		convert.cmbr_to_pgn(input_files, input_files_i, output_file);

	return 0;
}

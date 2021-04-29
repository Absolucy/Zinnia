pub(crate) mod models;
pub(crate) mod passes;
pub(crate) mod preprocess;
pub(crate) mod shuffle;

use clap::{AppSettings, Clap};
use std::path::PathBuf;

#[derive(Clap, Debug)]
#[clap(setting = AppSettings::InferSubcommands)]
enum CmdOpts {
	Binary {
		#[clap(long)]
		init: bool,
		#[clap(short, long, parse(from_os_str))]
		string_table: PathBuf,
		#[clap(parse(from_os_str))]
		path: PathBuf,
	},
	Source {
		#[clap(short, long, parse(from_os_str))]
		string_table: PathBuf,
		#[clap(parse(from_os_str))]
		files: Vec<PathBuf>,
	},
}

fn main() {
	let opt = CmdOpts::parse();

	println!();
	match opt {
		CmdOpts::Binary {
			init,
			string_table,
			path,
		} => {
			passes::handle(init, &string_table, &path);
		}
		CmdOpts::Source {
			string_table,
			files,
		} => {
			preprocess::preprocess(&string_table, &files);
		}
	}
	println!();
}

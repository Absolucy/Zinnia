#[macro_use]
extern crate log;

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
		#[clap(short = 's', long, parse(from_os_str))]
		string_table: Vec<PathBuf>,
		#[clap(parse(from_os_str))]
		path: PathBuf,
	},
	Source {
		#[clap(short = 's', long, parse(from_os_str))]
		string_table: Vec<PathBuf>,
		#[clap(parse(from_os_str))]
		files: Vec<PathBuf>,
	},
}

fn main() {
	pretty_env_logger::init();
	let opt = CmdOpts::parse();

	println!();
	match opt {
		CmdOpts::Binary {
			init,
			mut string_table,
			path,
		} => {
			info!("running binary post-processor");
			string_table.sort();
			passes::handle(init, &string_table, &path);
		}
		CmdOpts::Source {
			mut string_table,
			files,
		} => {
			string_table.sort();
			info!("running preprocessor");
			preprocess::preprocess(&string_table, &files);
		}
	}
	println!();
}

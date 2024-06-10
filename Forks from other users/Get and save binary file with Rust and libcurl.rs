use curl::easy::Easy;
use std::fs::File;
use std::io::prelude::*;

fn main() -> std::io::Result<()> {
    let mut dst = Vec::new();
    let mut easy = Easy::new();
    easy.url("https://github.com/SFML/SFML/releases/download/2.5.1/SFML-2.5.1-windows-vc15-64-bit.zip").unwrap();
    let _redirect = easy.follow_location(true);

    {
        let mut transfer = easy.transfer();
        transfer.write_function(|data| {
            dst.extend_from_slice(data);
            Ok(data.len())
        }).unwrap();
        transfer.perform().unwrap();
    }
    {
        let mut file = File::create("SFML-2.5.1-windows-vc15-64-bit.zip")?;
        file.write_all(dst.as_slice())?;
    }

    Ok(())
}
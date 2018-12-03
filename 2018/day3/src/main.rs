extern crate regex;

use std::fs::File;
use std::io::prelude::*;
use regex::Regex;
use std::process::exit;

struct FabricClaim {
    id: usize,
    x: usize,
    y: usize,
    width: usize,
    height: usize,
}

fn main() {
    let fabric_claims = get_fabric_claims();

    let mut fabric = vec![vec![0u8; 1000]; 1000]; 

    let mut overlapping_fabric_parts_count = 0;

    for p in &fabric_claims {
        for x in p.x..(p.x + p.width) {
            for y in p.y..(p.y + p.height) {
                fabric[x][y] += 1;

                if fabric[x][y] == 2 {
                    overlapping_fabric_parts_count += 1;
                }
            }
        }
    }

    println!("{}", overlapping_fabric_parts_count);

    for p in &fabric_claims {
        let mut is_overlapped = false;
        for x in p.x..(p.x + p.width) {
            for y in p.y..(p.y + p.height) {
                if fabric[x][y] != 1 {
                    is_overlapped = true;
                    break;
                }
            }
            if is_overlapped {
                break;
            }
        }

        if is_overlapped {
            continue;
        }

        println!("{}", p.id);
        exit(0);
    }

    panic!("Can't find single non overlapping claim");
}

fn get_fabric_claims() -> Vec<FabricClaim> {
    let mut f = File::open("input.txt").expect("file not found");

    let mut contents = String::new();
    f.read_to_string(&mut contents)
        .expect("something went wrong reading the file");

    // #7 @ 864,215: 15x23
    let re = Regex::new(r"(\d+) @ (\d+),(\d+): (\d+)x(\d+)").unwrap();

    let mut fabric_claims: Vec<FabricClaim> = Vec::new();

    for cap in re.captures_iter(&contents) {
        fabric_claims.push(FabricClaim {
            id: cap[1].parse().unwrap(),
            x: cap[2].parse().unwrap(),
            y: cap[3].parse().unwrap(),
            width: cap[4].parse().unwrap(),
            height: cap[5].parse().unwrap()
        })
    }

    fabric_claims
}

use std::fs::File;
use std::io::prelude::*;
use std::collections::HashSet;

fn main() {
    let numbers = get_frequency_changes();

    let frequency_sum: i32 = numbers.iter().sum();
    println!("{}", frequency_sum);

    let mut frequency = 0;
    let mut frequencies: HashSet<i32> = HashSet::new();
    frequencies.insert(0);

    for n in numbers.iter().cycle() {
        frequency += n;
        if frequencies.contains(&frequency) {
            break;
        }
        frequencies.insert(frequency);
    }

    println!("{}", frequency);
}

fn get_frequency_changes() -> Vec<i32> {
    let mut f = File::open("input.txt").expect("file not found");

    let mut contents = String::new();
    f.read_to_string(&mut contents)
        .expect("something went wrong reading the file");

    let numbers: Vec<i32> = contents.lines()
        .map(|n| n.parse().unwrap())
        .collect();
    
    numbers
}

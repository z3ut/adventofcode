use std::fs;
use itertools::Itertools;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let history: Vec<Vec<i32>> = lines.iter().map(|l| l.split_whitespace().map(|n| n.parse().unwrap()).collect()).collect();

    let sequences: Vec<Vec<Vec<i32>>> = history.iter().map(|history| {
        let mut histories: Vec<Vec<i32>> = vec![];
        let mut cur_history = history.clone();
        loop {
            histories.push(cur_history.clone());
            cur_history = cur_history.iter().tuple_windows().map(|(a, b)| b - a).collect();
            
            if cur_history.iter().all(|h| *h == 0) {
                return histories;
            }
        }
    }).collect();

    let sum: i32 = sequences.iter()
        .map(|s| s.iter().map(|h| h.last().unwrap()).sum::<i32>())
        .sum();

    println!("{}", sum);

    let sum: i32 = sequences.iter()
        .map(|s| s.iter().map(|h| *h.first().unwrap()).rev().reduce(|acc, cur| cur - acc).unwrap())
        .sum();

    println!("{}", sum);
}

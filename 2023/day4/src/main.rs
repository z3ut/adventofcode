use std::cmp;
use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut points = 0;

    let mut cards = HashMap::new();
    let mut card_wins = HashMap::new();

    let mut i = 0;
    for line in &lines {
        let (_, second) = line.split_once(":").unwrap();
        let (winning_str, actual_str) = second.split_once("|").unwrap();

        let winning: Vec<&str> = winning_str
            .split(" ")
            .collect();
        let actual: Vec<&str> = actual_str
            .split(" ")
            .filter(|c| !c.is_empty())
            .collect();

        let winning_count = winning
            .iter()
            .filter(|w| actual.contains(w))
            .count() as u32;
        
        if winning_count > 0 {
            points += 2_i32.pow(winning_count - 1);
        }

        card_wins.insert(i, winning_count);
        cards.insert(i, 1);
        i += 1;
    }

    println!("{}", points);


    for i in 0..lines.len() {
        let card_count = *cards.get(&i).unwrap();
        let card_wins = *card_wins.get(&i).unwrap();
        for j in i + 1..cmp::min(i + (card_wins as usize) + 1, lines.len()) {
            *cards.get_mut(&j).unwrap() += card_count;
        }
    }

    println!("{}", cards.values().sum::<u32>());
}

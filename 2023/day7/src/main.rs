use std::cmp::Ordering;
use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");

    let mut cards: Vec<(&str, i32)> = input.lines().map(|line| {
        let (hand, bid) = line.split_once(" ").unwrap();
        (hand, bid.parse::<i32>().unwrap())
    }).collect();


    cards.sort_by(|&(a, _), &(b, _)| {
        let a_s = get_hand_strength(a);
        let b_s = get_hand_strength(b);

        if a_s != b_s {
            return a_s.cmp(&b_s);
        } else {
            for (ac, bc) in a.chars().zip(b.chars()) {
                let ac_s = get_card_strength1(&ac);
                let bc_s = get_card_strength1(&bc);
                if ac_s != bc_s {
                    return ac_s.cmp(&bc_s);
                }
            }
            return Ordering::Equal;
        }
    });

    // // 253603890
    println!("{}", count_winning(&cards));


    cards.sort_by(|&(a, _), &(b, _)| {
        let a_s = get_possible_hands_with_jokers(a)
            .iter()
            .map(|c| get_hand_strength(c))
            .max()
            .unwrap();

        let b_s = get_possible_hands_with_jokers(b)
            .iter()
            .map(|c| get_hand_strength(c))
            .max()
            .unwrap();

        if a_s != b_s {
            return a_s.cmp(&b_s);
        } else {
            for (a1, b1) in a.chars().zip(b.chars()) {
                let a1_s = get_card_strength2(&a1);
                let b1_s = get_card_strength2(&b1);
                if a1_s != b1_s {
                    return a1_s.cmp(&b1_s);
                }
            }
            return Ordering::Equal;
        }
    });

    // 253630098
    println!("{}", count_winning(&cards));
}

fn get_hand_strength(card: &str) -> i32 {
    let mut cards = HashMap::<char, i32>::new();
    for c in card.chars() {
        *cards.entry(c).or_insert(0) += 1;
    }

    let mut values: Vec<&i32> = cards.values().collect();
    values.sort();
    values.reverse();

    return match values[..] {
        [5] => 7,
        [4, 1] => 6,
        [3, 2] => 5,
        [3, 1, 1] => 4,
        [2, 2, 1] => 3,
        [2, 1, 1, 1] => 2,
        _ => 1
    };
}

fn get_card_strength1(card: &char) -> i32 { get_card_strength(card, 11) }

fn get_card_strength2(card: &char) -> i32 { get_card_strength(card, 1) }

fn get_card_strength(card: &char, joker_strenght: i32) -> i32 {
    return match card {
        '2'..='9' => card.to_digit(10).unwrap() as i32,
        'T' => 10,
        'J' => joker_strenght,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        _ => panic!("wrong card")
    }
}

fn get_possible_hands_with_jokers(card: &str) -> Vec<String> {
    let joker_positions: Vec<i32> = card
        .chars()
        .enumerate()
        .filter(|(_, c)| *c == 'J')
        .map(|(i, _)| i as i32)
        .collect();

    let swaps = vec!['J', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A'];

    map_string_rec(card, &joker_positions, &swaps)
}

fn map_string_rec(input: &str, positions: &Vec<i32>, chars: &Vec<char>) -> Vec<String> {
    if positions.len() == 0 {
        return vec![input.to_string()];
    }
    let mut strings: Vec<String> = vec![];

    for c in chars {
        let mut cur_input = String::from(input);
        let pos = *positions.first().unwrap() as usize;
        cur_input.replace_range(pos..pos + 1, &c.to_string());

        strings.append(&mut map_string_rec(&cur_input, &positions[1..].to_vec(), chars))
    }

    return strings;
}

fn count_winning(cards: &Vec<(&str, i32)>) -> i32 {
    cards
        .iter()
        .enumerate()
        .map(|(rank, &(_, bid))| bid * (rank + 1) as i32)
        .sum()
}
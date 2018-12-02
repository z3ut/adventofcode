use std::fs::File;
use std::io::prelude::*;
use std::collections::HashMap;

fn main() {
    let boxes_id = get_boxes_id();

    let checksum = get_boxes_checksum(&boxes_id);

    println!("{}", checksum);

    let shared_part_id = find_shared_part_id(&boxes_id);

    println!("{}", shared_part_id);
}

fn get_boxes_id() -> Vec<String> {
    let mut f = File::open("input.txt").expect("file not found");

    let mut contents = String::new();
    f.read_to_string(&mut contents)
        .expect("something went wrong reading the file");

    let boxes_id: Vec<String> = contents.lines()
        .map(|s| s.to_string())
        .collect();
    
    boxes_id
}

fn get_boxes_checksum(boxes_id: &Vec<String>) -> i32 {
    let mut two_equal_chars_count= 0;
    let mut three_equal_chars_count = 0;

    for id in boxes_id {
        let mut letters_count = HashMap::new();

        for l in id.chars() {
            *letters_count.entry(l).or_insert(0) += 1;
        }

        if letters_count.values().any(|&count| count == 2) {
            two_equal_chars_count += 1;
        }

        if letters_count.values().any(|&count| count == 3) {
            three_equal_chars_count += 1;
        }
    }

    two_equal_chars_count * three_equal_chars_count
}

fn find_shared_part_id(ids: &Vec<String>) -> String {
    for (i, id1) in ids.iter().enumerate() {
        for id2 in ids.iter().skip(i + 1) {
            if id1.len() != id2.len() {
                continue
            }

            if id1.chars()
                .zip(id2.chars())
                .filter(|(c1, c2)| c1 != c2)
                .count() == 1 {
                    
                return id1.chars()
                    .zip(id2.chars())
                    .filter(|(c1, c2)| c1 == c2)
                    .map(|(c1, _)| c1)
                    .collect();
            }
        }
    }

    panic!("Similar boxes id were not found");
}

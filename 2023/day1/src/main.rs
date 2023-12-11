use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let sum1 = lines.iter().map(|line| {
        let digits: Vec<u32> = line
            .chars()
            .filter_map(|d| d.to_digit(10))
            .collect();
        digits[0] * 10 + digits.last().unwrap()
    }).sum::<u32>();
    
    println!("{}", sum1);

    let digits_mapping: Vec<(&str, u32)> = vec![
        ("one", 1),
        ("two", 2),
        ("three", 3),
        ("four", 4),
        ("five", 5),
        ("six", 6),
        ("seven", 7),
        ("eight", 8),
        ("nine", 9)
    ];

    let sum2 = lines.iter().map(|line| {
        let digits: Vec<u32> = map_instruction(line, &digits_mapping);
        digits[0] * 10 + digits.last().unwrap()
    }).sum::<u32>();

    println!("{}", sum2);
}

fn map_instruction(line: &str, mapping: &Vec<(&str, u32)>) -> Vec<u32> {
    let mut digits: Vec<u32> = vec![];

    for i in 0..line.len() {
        let cur_line = &line[i..];

        if let Some(d) = cur_line.chars().nth(0).unwrap().to_digit(10) {
            digits.push(d);
            continue;
        }

        for (str, value) in mapping {
            if cur_line.starts_with(str) {
                digits.push(*value);
                break;
            }
        }
    }

    digits
}

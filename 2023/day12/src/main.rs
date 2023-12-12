use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let records: Vec<(&str, Vec<usize>)> = lines.iter().map(|line| {
        let (f, s) = line.split_once(" ").unwrap();
        (f, s.split(",").map(|n| n.parse::<usize>().unwrap()).collect())
    }).collect();

    let sum: usize = records
        .iter()
        .map(|(row, conditions)|
            build_possible_combinations(row.to_string())
                .iter()
                .filter(|r| is_satisfied(r, conditions))
                .count())
        .sum();

    println!("{}", sum);
}

fn build_possible_combinations(springs: String) -> Vec<String> {
    if !springs.contains("?") {
        return vec![springs];
    }

    let mut res = Vec::new();
    res.append(&mut build_possible_combinations(springs.replacen("?", ".", 1)));
    res.append(&mut build_possible_combinations(springs.replacen("?", "#", 1)));
    res
}

fn is_satisfied(row: &str, conditions: &Vec<usize>) -> bool {
    row
        .split(".")
        .filter(|s| !s.is_empty())
        .map(|s| s.len())
        .eq(conditions.iter().map(|c| *c))
}

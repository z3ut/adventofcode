use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let values: Vec<&str> = input.split(",").collect();

    println!("{}", values.iter().map(|v| calculate_hash(v)).sum::<usize>());

    let mut boxes: Vec<Vec<(&str, usize)>> = vec![vec![]; 256];

    for v in values {
        if v.contains("-") {
            let lens = &v[..v.len()-1];
            let hash = calculate_hash(lens);

            boxes[hash].retain(|&(l, _)| l != lens);
        }
        if v.contains("=") {
            let lens = &v[..v.len()-2];
            let hash = calculate_hash(lens);
            let focal = v.chars().last().unwrap().to_digit(10).unwrap() as usize;

            let index = boxes[hash].iter().position(|&(l, _)| l == lens);
            if index.is_some() {
                boxes[hash][index.unwrap()] = (lens, focal);
            } else {
                boxes[hash].push((lens, focal));
            }
        }
    }

    let mut sum = 0;
    for i in 0..256 {
        for j in 0..boxes[i].len() {
            sum += (i + 1) * (j + 1) * boxes[i][j].1;
        }
    }

    println!("{}", sum);

}

fn calculate_hash(value: &str) -> usize {
    value
        .chars()
        .map(|c| c as usize)
        .fold(0, |acc, c| (acc + c) * 17 % 256)
}

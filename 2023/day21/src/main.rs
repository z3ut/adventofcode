use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let map: Vec<Vec<char>> = lines.iter().map(|l| l.chars().collect()).collect();

    let width = map[0].len();
    let height = map.len();

    let mut current = map.clone();

    for _ in 0..64 {
        let previous = current.clone();
        current = map.clone();
        current[65][65] = '.';
        for x in 0..width {
            for y in 0..height {
                if previous[y][x] == '0' || previous[y][x] == 'S' {
                    if y + 1 < height && previous[y + 1][x] != '#' {
                        current[y + 1][x] = '0';
                    }
                    if y >= 1 && previous[y - 1][x] != '#' {
                        current[y - 1][x] = '0';
                    }
                    if x + 1 < width && previous[y][x + 1] != '#' {
                        current[y][x + 1] = '0';
                    }
                    if x >= 1 && previous[y][x - 1] != '#' {
                        current[y][x - 1] = '0';
                    }
                }
            }
        }
        print_map(&current);
    }
    
    let mut sum = 0;
    for x in 0..width {
        for y in 0..height {
            if current[y][x] == '0' {
                sum += 1;
            }
        }
    }

    println!("{}", sum);
}

fn print_map(map: &Vec<Vec<char>>) {
    for line in map {
        for c in line {
            print!("{}", c);
        }
        println!();
    }
    println!();
}

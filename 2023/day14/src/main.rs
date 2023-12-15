use std::fs;
use std::collections::HashMap;
use itertools::Itertools;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut platform: HashMap<(usize, usize), char> = HashMap::new();

    let rows = lines.len();
    let columns = lines[0].len();

    for y in 0..rows {
        for x in 0..columns {
            platform.insert((x, y), lines[y].chars().nth(x).unwrap());
        }
    }

    // tilt_platform_north(&mut platform, rows, columns);
    // println!("{}", calculate_north_total_load(&platform, rows, columns));

    let mut history: Vec<String> = vec![];
    let mut step = 0;

    loop {
        step += 1;
        cycle_platform(&mut platform, rows, columns);

        let cur = platform
            .iter()
            .map(|(k, v)| format!("{:?}={}", k, v))
            .join(",");

        if history.iter().any(|h| h.eq(&cur)) {
            let equal_from = history.iter().position(|h| **h == cur).unwrap();
            let remaining = (1000000000 - step) % (step - equal_from - 1);

            for _ in 0..remaining {
                cycle_platform(&mut platform, rows, columns);
            }

            break;
        }

        history.push(cur);
    }

    println!("{}", calculate_north_total_load(&platform, rows, columns));
}

fn cycle_platform(platform: &mut HashMap<(usize, usize), char>, rows: usize, columns: usize) {
    tilt_platform_north(platform, rows, columns);
    tilt_platform_west(platform, rows, columns);
    tilt_platform_south(platform, rows, columns);
    tilt_platform_east(platform, rows, columns);
}

fn tilt_platform_north(platform: &mut HashMap<(usize, usize), char>, rows: usize, columns: usize) {
    for x in 0..columns {
        let mut y = 0;
        while y < rows {
            if platform[&(x, y)] == '#' {
                y += 1;
                continue;
            }

            let mut passed = 0;
            let mut number_of_sliding_rocks = 0;
            for yy in y..rows {
                if platform[&(x, yy)] == '#' {
                    break;
                }
                if platform[&(x, yy)] == 'O' {
                    number_of_sliding_rocks += 1;
                    platform.insert((x, yy), '.');
                }
                
                passed += 1;
            }

            for yy in y..y + number_of_sliding_rocks {
                platform.insert((x, yy), 'O');
            }
            
            y += passed;
        }
    }
}

fn tilt_platform_west(platform: &mut HashMap<(usize, usize), char>, rows: usize, columns: usize) {
    for y in 0..rows {
        let mut x = 0;
        while x < columns {
            if platform[&(x, y)] == '#' {
                x += 1;
                continue;
            }

            let mut passed = 0;
            let mut number_of_sliding_rocks = 0;
            for xx in x..columns {
                if platform[&(xx, y)] == '#' {
                    break;
                }
                if platform[&(xx, y)] == 'O' {
                    number_of_sliding_rocks += 1;
                    platform.insert((xx, y), '.');
                }
                
                passed += 1;
            }

            for xx in x..x + number_of_sliding_rocks {
                platform.insert((xx, y), 'O');
            }
            
            x += passed;
        }
    }
}

fn tilt_platform_south(platform: &mut HashMap<(usize, usize), char>, rows: usize, columns: usize) {
    for x in 0..columns {
        let mut y = rows - 1;
        while y > 0 {
            if platform[&(x, y)] == '#' {
                y -= 1;
                continue;
            }

            let mut passed = 0;
            let mut number_of_sliding_rocks = 0;
            for yy in (0..y + 1).rev() {
                if platform[&(x, yy)] == '#' {
                    break;
                }
                if platform[&(x, yy)] == 'O' {
                    number_of_sliding_rocks += 1;
                    platform.insert((x, yy), '.');
                }
                
                passed += 1;
            }

            for yy in (y + 1 - number_of_sliding_rocks..y + 1).rev() {
                platform.insert((x, yy), 'O');
            }
            
            if passed > y {
                break;
            }

            y -= passed;
        }
    }
}

fn tilt_platform_east(platform: &mut HashMap<(usize, usize), char>, rows: usize, columns: usize) {
    for y in 0..rows {
        let mut x = columns - 1;
        while x > 0 {
            if platform[&(x, y)] == '#' {
                x -= 1;
                continue;
            }

            let mut passed = 0;
            let mut number_of_sliding_rocks = 0;
            for xx in (0..x + 1).rev() {
                if platform[&(xx, y)] == '#' {
                    break;
                }
                if platform[&(xx, y)] == 'O' {
                    number_of_sliding_rocks += 1;
                    platform.insert((xx, y), '.');
                }
                
                passed += 1;
            }

            for xx in (x + 1- number_of_sliding_rocks..x + 1).rev() {
                platform.insert((xx, y), 'O');
            }

            if passed > x {
                break;
            }
            
            x -= passed;
        }
    }
}


fn print_plantform(platform: &HashMap<(usize, usize), char>, rows: usize, columns: usize) {
    for y in 0..rows {
        for x in 0..columns {
            print!("{}", platform[&(x, y)])
        }
        println!();
    }
    println!();
}

fn calculate_north_total_load(platform: &HashMap<(usize, usize), char>, rows: usize, columns: usize) -> usize {
    let mut sum = 0;

    for y in 0..rows {
        for x in 0..columns {
            if platform[&(x, y)] == 'O' {
                sum += rows - y;
            }
        }
    }

    sum
}
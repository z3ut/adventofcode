use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();
    let instructions: Vec<Vec<&str>> = lines.iter().map(|l| l.split_whitespace().collect()).collect();

    let mut x1 = 0;
    let mut y1 = 0;

    let mut x2 = 0;
    let mut y2 = 0;

    let mut points1: Vec<(i32, i32)> = vec![];
    let mut points2: Vec<(i32, i32)> = vec![];

    let mut total_steps1: i64 = 0;
    let mut total_steps2: i64 = 0;

    for instruction in instructions {
        match instruction[..] {
            [direction1, s, rgb] => {
                let steps1: i32 = s.parse().unwrap();
                let steps2: i32 = i32::from_str_radix(&rgb[2..7], 16).unwrap();
                let direction2 = rgb.chars().nth(7).unwrap();

                total_steps1 += steps1 as i64;
                total_steps2 += steps2 as i64;
                
                match direction1 {
                    "R" => x1 += steps1,
                    "D" => y1 -= steps1,
                    "L" => x1 -= steps1,
                    "U" => y1 += steps1,
                    _ => panic!("Wrong instruction")
                }

                match direction2 {
                    '0' => x2 += steps2,
                    '1' => y2 -= steps2,
                    '2' => x2 -= steps2,
                    '3' => y2 += steps2,
                    _ => panic!("Wrong instruction")
                }

                points1.push((x1, y1));
                points2.push((x2, y2));
            },
            _ => panic!("Wrong instruction")
        }
    }

    println!("{}", calculate_area(points1) + total_steps1 / 2 + 1);
    println!("{}", calculate_area(points2) + total_steps2 / 2 + 1);
}

fn calculate_area(points: Vec<(i32, i32)>) -> i64 {
    let mut area: i64 = 0;
    let mut j = points.len() - 1;

    for i in 0..points.len() {
        area += (points[j].0 as i64 + points[i].0 as i64) * (points[j].1 as i64 - points[i].1 as i64);
        j = i;
    }

    area.abs() / 2
}

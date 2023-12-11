use std::fs;

fn main() {
    let guesses = get_guesses();

    let max_red = 12;
    let max_green = 13;
    let max_blue = 14;

    let result1: u32 = guesses
        .iter()
        .filter(|g| g.reveals.iter().all(|r| r.red <= max_red && r.green <= max_green && r.blue <= max_blue))
        .map(|g| g.id)
        .sum();

    println!("{}", result1);

    let result2: u32 = guesses
        .iter()
        .map(|g| g.reveals.iter().max_by_key(|r| r.red).unwrap().red *
            g.reveals.iter().max_by_key(|r| r.green).unwrap().green *
            g.reveals.iter().max_by_key(|r| r.blue).unwrap().blue)
        .sum();

    println!("{}", result2);
}

fn get_guesses() -> Vec<Guess>{
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut guesses: Vec<Guess> = vec![];
    for line in &lines {
        let (first, second) = line.split_once(":").unwrap();
        let id: u32 = first[5..].parse().unwrap();

        let mut cubes: Vec<Cubes> = vec![];
        for guess in second.split(";") {
            let mut cube = Cubes { red: 0, green: 0, blue: 0 };
            for parts in guess.split(",") {
                let (n, c) = parts.trim().split_once(" ").unwrap();
                let count: u32 = n.parse().unwrap();

                match c {
                    "red" => cube.red = count,
                    "green" => cube.green = count,
                    "blue" => cube.blue = count,
                    _ => ()
                }
            }
            cubes.push(cube);
        }

        guesses.push(Guess { id, reveals: cubes });
    }

    guesses
}

struct Guess {
    id: u32,
    reveals: Vec<Cubes>
}

#[derive(Debug)]
struct Cubes {
    red: u32,
    green: u32,
    blue: u32
}
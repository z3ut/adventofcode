use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let instructions: Vec<Turn> = lines.first().unwrap().chars()
        .map(|c| match c {
            'L' => Turn::Left,
            'R' => Turn::Right,
            _ => panic!("Wrong turn"
        )})
        .collect();

    let mut network: HashMap<&str, (&str, &str)> = HashMap::<&str, (&str, &str)>::new();
    for node in &lines[2..] {
        network.insert(&node[0..3], (&node[7..10], &node[12..15]));
    }


    let mut step = 0;
    let mut position = "AAA";

    while position != "ZZZ" {
        position = get_new_position(&position, step, &instructions, &network);
        step += 1;
    }

    println!("{}", step);


    let positions: Vec<&str> = network.keys().map(|k| *k).filter(|node| node.ends_with("A")).collect();
    let steps_with_exit: Vec<i32> = positions.iter().map(|&position| {
        let mut step = 0;
        let mut p = position;

        while position != p || step == 0 {
            p = get_new_position(p, step, &instructions, &network);
            step += 1;
            if p.ends_with("Z") {
                return step;
            }
        }

        panic!("Wrong position");
    }).collect();

    println!("{:?}", steps_with_exit.iter().map(|s| *s as i128).reduce(|a, b| num::integer::lcm(a, b)).unwrap());
}

#[derive(Debug)]
enum Turn {
    Left,
    Right
}

fn get_new_position<'n>(position: &str, step: i32, instructions: &Vec<Turn>, network: &'n HashMap<&str, (&str, &str)>) -> &'n str {
    match get_new_turn(&instructions, step) {
        Turn::Left => network.get(position).unwrap().0,
        Turn::Right => network.get(position).unwrap().1
    }
}

fn get_new_turn(instructions: &Vec<Turn>, step: i32) -> &Turn {
    instructions.iter().nth((step % instructions.len() as i32) as usize).unwrap()
}

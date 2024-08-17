use std::{fs, collections::HashMap};
use serde::{Deserialize, Serialize};
use std::cmp;

fn main() {
    let workflows_input = fs::read_to_string("workflows.txt")
        .expect("Input file");
    let workflows_lines: Vec<&str> = workflows_input.lines().collect();

    let mut workflows: HashMap<&str, Vec<(char, char, u32, &str)>> = HashMap::new();

    for line in workflows_lines {
        let (name, rest) = line.split_once("{").unwrap();

        workflows.insert(name, vec![]);

        for comm in rest[..rest.len() - 1].split(",") {
            if !comm.contains(":") {
                workflows.entry(name).or_insert(Vec::new()).push(('x', '>', 0, comm));
                continue;
            }
            let (first, second) = comm.split_once(':').unwrap();

            let field = first.chars().nth(0).unwrap();
            let check = first.chars().nth(1).unwrap();
            let value = first[2..].parse::<u32>().unwrap();
            let move_to = second;

            workflows.entry(name).or_insert(Vec::new()).push((field, check, value, move_to));
        }
    }

    let mut final_conditions: Vec<Vec<(char, char, u32)>> = vec![];

    traverse("in", &workflows, &vec![], &mut final_conditions);


    let mut accepted = 0;

    for conditions in final_conditions {
        let mut min_x = 1;
        let mut min_m = 1;
        let mut min_a = 1;
        let mut min_s = 1;

        let mut max_x = 4000;
        let mut max_m = 4000;
        let mut max_a = 4000;
        let mut max_s = 4000;

        for predicate in conditions {
            match predicate.0 {
                'x' => {
                    match predicate.1 {
                        '<' => max_x = cmp::min(max_x, predicate.2 - 1),
                        '>' => min_x = cmp::max(min_x, predicate.2 + 1),
                        '1' => min_x = cmp::max(min_x, predicate.2),
                        '2' => max_x = cmp::min(max_x, predicate.2),
                        _ => panic!("wrong action")
                    }
                },
                'm' => {
                    match predicate.1 {
                        '<' => max_m = cmp::min(max_m, predicate.2 - 1),
                        '>' => min_m = cmp::max(min_m, predicate.2 + 1),
                        '1' => min_m = cmp::max(min_m, predicate.2),
                        '2' => max_m = cmp::min(max_m, predicate.2),
                        _ => panic!("wrong action")
                    }
                },
                'a' => {
                    match predicate.1 {
                        '<' => max_a = cmp::min(max_a, predicate.2 - 1),
                        '>' => min_a = cmp::max(min_a, predicate.2 + 1),
                        '1' => min_a = cmp::max(min_a, predicate.2),
                        '2' => max_a = cmp::min(max_a, predicate.2),
                        _ => panic!("wrong action")
                    }
                },
                's' => {
                    match predicate.1 {
                        '<' => max_s = cmp::min(max_s, predicate.2 - 1),
                        '>' => min_s = cmp::max(min_s, predicate.2 + 1),
                        '1' => min_s = cmp::max(min_s, predicate.2),
                        '2' => max_s = cmp::min(max_s, predicate.2),
                        _ => panic!("wrong action")
                    }
                },
                _ => panic!("wrong property")
            }
        }

        let count = (max_x as u64 - min_x as u64 + 1) * (max_m as u64 - min_m as u64 + 1) * (max_a as u64 - min_a as u64 + 1) * (max_s as u64 - min_s as u64 + 1);

        accepted += count;
    }

    println!("{}", accepted);
}

fn traverse(current: &str, workflows: &HashMap<&str, Vec<(char, char, u32, &str)>>, current_conditions: &Vec<(char, char, u32)>, final_conditions: &mut Vec<Vec<(char, char, u32)>>) {
    let w = workflows.get(current).unwrap();

    let mut reversed_cond: Vec<(char, char, u32)> = vec![];

    println!("{}", current);

    for &rule in w {
        match rule.3 {
            "R" => {
                reversed_cond.push((rule.0, reverse_action(rule.1), rule.2));
            },
            "A" => {
                let mut result_cond = current_conditions.clone();
                result_cond.append(&mut reversed_cond.clone());
                result_cond.push((rule.0, rule.1, rule.2));
                final_conditions.push(result_cond);

                reversed_cond.push((rule.0, reverse_action(rule.1), rule.2));
            },
            _ => {
                let mut result_cond = current_conditions.clone();
                result_cond.append(&mut reversed_cond.clone());
                result_cond.push((rule.0, rule.1, rule.2));
                
                traverse(rule.3, workflows, &result_cond, final_conditions);

                reversed_cond.push((rule.0, reverse_action(rule.1), rule.2));
            }
        }
    }
}

fn reverse_action(action: char) -> char {
    match action {
        '<' => '1',
        '>' => '2',
        _ => panic!("Wrong action")
    }
}

#[derive(Serialize, Deserialize, Debug)]
struct Part {
    x: u32,
    m: u32,
    a: u32,
    s: u32
}

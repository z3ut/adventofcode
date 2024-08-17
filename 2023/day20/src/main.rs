use std::{fs, collections::HashMap};

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut module_types: HashMap<&str, &str> = HashMap::new();
    let mut wires: HashMap<&str, Vec<&str>> = HashMap::new();
    let mut flip_flop_state: HashMap<&str, u32> = HashMap::new();
    let mut conjunction_state: HashMap<&str, HashMap<&str, u32>> = HashMap::new();

    for l in lines {
        let (module, connections) = l.split_once(" -> ").unwrap();
        let con: Vec<&str> = connections.split(", ").collect();

        if module == "broadcaster" {
            module_types.insert(&module, "b");
            wires.insert(&module, con);
        } else {
            module_types.insert(&module[1..], &module[0..1]);
            wires.insert(&module[1..], con);
        }
    }

    for (module, t) in module_types.clone() {
        match t {
            "%" => {
                flip_flop_state.insert(module, 0);
            },
            "&" => {
                let connected_to = wires.iter().filter(|(_, receivers)| receivers.contains(&module)).map(|(c, _)| c);
                let mut hm: HashMap<&str, u32> = HashMap::new();
                for c in connected_to {
                    hm.insert(c, 0);
                }
                conjunction_state.insert(module, hm);
            },
            _ => ()
        }
    }

    let mut signals: Vec<(&str, &str, u32)> = vec![];

    let mut mk = -1;
    let mut xt = -1;
    let mut zc = -1;
    let mut fp = -1;

    for i in 1..5000 {
        //i += 1;
        signals.push(("button", "broadcaster", 0));

        while signals.len() != 0 {
            let (sender, receiver, signal) = signals.remove(0);
            let mut s = handle_signal(sender, receiver, signal, &wires, &module_types, &mut flip_flop_state, &mut conjunction_state);

            signals.append(&mut s);

            if signals.iter().any(|(from, _, signal)| *from == "ll" && *signal == 0) {
                println!("ll {}", i);
            }

            if signals.iter().any(|(from, _, signal)| *from == "gv" && *signal == 0) {
                println!("gv {}", i);
            }

            if signals.iter().any(|(from, _, signal)| *from == "qf" && *signal == 0) {
                println!("qf {}", i);
            }

            if signals.iter().any(|(from, _, signal)| *from == "rc" && *signal == 0) {
                println!("rc {}", i);
            }
        }

        if mk == -1 {
            if conjunction_state.get("mk").unwrap().iter().all(|(_, s)| *s == 1) {
                println!("mk {}", i);
                println!("{:?}", conjunction_state.get("mk"));
                mk = i;
            }
        }
        
        if xt == -1 {
            if conjunction_state.get("xt").unwrap().iter().all(|(_, s)| *s == 1) {
                println!("xt {}", i);
                xt = i;
            }
        }
        
        if zc == -1 {
            if conjunction_state.get("zc").unwrap().iter().all(|(_, s)| *s == 1) {
                println!("zc {}", i);
                zc = i;
            }
        }
        
        if fp == -1 {
            if conjunction_state.get("fp").unwrap().iter().all(|(_, s)| *s == 1) {
                println!("fp {}", i);
                fp = i;
            }
        }
    }

    // LCM 3767 3923 3931 4007
    // 232774988886497
}

fn handle_signal<'a>(sender: &'a str, receiver: &'a str, signal: u32, wires: &HashMap<&'a str, Vec<&'a str>>, module_types: &HashMap<&str, &str>, flip_flop_state: &mut HashMap<&'a str, u32>, conjunction_state: &mut HashMap<&'a str , HashMap<&'a str, u32>>) -> Vec<(&'a str, &'a str, u32)> {
    let mut new_signals: Vec<(&str, &str, u32)> = vec![];

    if module_types.get(receiver).is_none() {
        return new_signals;
    }

    match *module_types.get(receiver).unwrap() {
        "b" => {
            for m in wires.get(receiver).unwrap() {
                new_signals.push((receiver, m, signal));
            }
        },
        "%" => {
            // flip-flop
            if signal == 1 {
                // ignore
            } else {
                if *flip_flop_state.get(receiver).unwrap() == 0 {
                    flip_flop_state.insert(receiver, 1);
                    for m in wires.get(receiver).unwrap() {
                        new_signals.push((receiver, m, 1));
                    }
                } else {
                    flip_flop_state.insert(receiver, 0);
                    for m in wires.get(receiver).unwrap() {
                        new_signals.push((receiver, m, 0));
                    }
                }
            }
        },
        "&" => {
            // conjunction 
            let state = conjunction_state.entry(receiver).or_insert(HashMap::new());
            state.insert(sender, signal);
            if state.values().all(|&s| s == 1) {
                for m in wires.get(receiver).unwrap() {
                    new_signals.push((receiver, m, 0));
                }
            } else {
                for m in wires.get(receiver).unwrap() {
                    new_signals.push((receiver, m, 1));
                }
            }
        },
        _ => panic!("Wrong module type")
    }

    new_signals
}

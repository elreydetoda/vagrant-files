#!/usr/bin/env python3

from pathlib import Path
from argparse import ArgumentParser

def check_ips(base: Path, targets: Path) -> list:
    # reading in both files
    base_ips = base.read_text()
    target_ips = targets.read_text()

    # putting them in strings and removing extra whitespace
    base_list = base_ips.strip().split('\n')
    target_list = target_ips.strip().split('\n')

    # list comprehension to check for extra IPs
    extra_targets = [ new_target for new_target in target_list if new_target not in base_list ]

    # return extra IPs
    return extra_targets

def main():
    parser = ArgumentParser(description='Used to check results from results of nmap -sL and masscan output. Expects 2 files newline delimited IPs')
    parser.add_argument('baseline', help="baseline is Nmap's -sL output file")
    parser.add_argument('targets', help="targets is masscan's output of the live hosts")
    args = parser.parse_args()

    base = Path(args.baseline)
    targets = Path(args.targets)

    if base.resolve().exists() and targets.resolve().exists():
        new_ips = check_ips(base.resolve(), targets.resolve())
        print('\n'.join(new_ips))
    else:
        print("One of the files don't exist")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3

"""Script to convert ZSH history to my Persistent History format."""

# Inspired by Eli Bendersky:
#  - http://eli.thegreenplace.net/2013/06/11/keeping-persistent-history-in-bash/
#  - https://github.com/eliben/code-for-blog/blob/master/2016/persistent-history/add-persistent-history.sh
#
# This was done per-entry when using the Bash shell, using the prompt strings.
# On moving to zsh and oh-my-zsh, this is no longer feasible.
# zsh stores its history in a particular format in ~/.zsh_history:
#
# : 1612182922:0;git st
# : 1612201796:0;history | tail
# : 1612201819:0;tail ~/.zsh_history
#
# The first integer is time since epoch, the second is runtime, the remainder of the line after ';'
# is the command line.

import argparse
import sys
import os
import socket
import datetime
import shutil
import re


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-O",
        "--overwrite",
        action="store_true",
        dest="overwrite",
        help="Overwrite the output file, if it already exists.",
    )
    parser.add_argument(
        "-s",
        "--sort",
        action="store_true",
        dest="sort",
        help="Sort the output, in ascending time order.",
    )
    parser.add_argument(
        "-i",
        "--infile",
        type=str,
        metavar="FILE",
        default="~/.persistent_history",
        help="Input persistent history file",
    )
    parser.add_argument(
        "-o",
        "--outfile",
        type=str,
        metavar="FILE",
        default="~/.persistent_history",
        help="Output persistent history file",
    )
    parser.add_argument(
        "-z",
        "--zfile",
        type=str,
        metavar="FILE",
        default="~/.zsh_history",
        help="Input zsh history file",
    )
    parser.add_argument(
        "-e",
        "--extra-file",
        type=str,
        dest="extra_file",
        metavar="FILE",
        help="Extra input persistent history file",
    )
    args = parser.parse_args()

    infile = os.path.expanduser(args.infile)
    print(f"Input persistent history: {infile}")
    zfile = os.path.expanduser(args.zfile)
    print(f"Input ZSH history: {zfile}")
    outfile = os.path.expanduser(args.outfile)
    print(f"Output persistent history: {outfile}")

    extra_file = None
    if args.extra_file:
        extra_file = os.path.expanduser(args.extra_file)
        if not os.path.exists(extra_file):
            sys.exit(
                f"Error: extra history file {extra_file} does not exist!"
            )
        extra_file = os.abspath(extra_file)
        print(f"Extra ZSH input history file: {extra_file}")

    for filename in (infile, zfile):
        if not os.path.exists(filename):
            sys.exit(
                f"Error: input history file {filename} does not exist!"
            )

    if outfile != infile:
        if os.path.exists(outfile) and not args.overwrite:
            sys.exit(
                f"Error: output persistent history file {outfile} already exists!"
            )

    real_infile = os.path.realpath(infile)
    if not os.path.exists(real_infile):
        sys.exit(
            f"Error: input history file {infile} is a symlink to {real_infile} which does not exist!"
        )
    print(f"Real input file: {real_infile}")

    real_outfile = os.path.realpath(outfile)
    if not os.path.exists(real_outfile):
        sys.exit(
            f"Error: output history file {outfile} is a symlink to {real_outfile} which does not exist!"
        )
    print(f"Real output file: {real_outfile}")

    # Read input ZSH history file.
    with open(zfile, 'r') as f:
        zdata = f.readlines()

    hostname = socket.gethostname()
    user = os.getenv("USER")
    usernames = os.getenv("_USERNAMES")
    if usernames is None:
        usernames = [user]
    else:
        usernames = usernames.split()
        usernames.append(user)
        usernames = list(set(usernames))

    # Regexes to find occurrences of usernames not in paths.
    user_regexes = [f".*[^/]{user}[^/].*" for user in usernames]
    combined_regex = "(" + ")|(".join(user_regexes) + ")"

    # Read input ZSH history file.
    with open(infile, 'r') as f:
        histdata = f.readlines()

    for line in zdata:
        if not line.startswith(':') or ';' not in line:
            continue
        timestamp = int(line.split(':')[1].strip())
        time = datetime.datetime.fromtimestamp(timestamp)
        # duration = line.split(':')[2].strip().split(';')[0]
        cmd = line.split(';')[1].strip()
        # Remove any potential creds
        if "API_KEY" in cmd or "PASSWORD" in cmd:
            print(f"Skipping {cmd}")
            continue
        if re.match(combined_regex, cmd):
            print(f"Skipping {cmd}")
            continue
        histdata.append(f"{hostname} | {time} | {cmd}\n")

    extra_data = []
    if extra_file:
        with open(extra_file, 'r') as f:
            extra_data = f.readlines()
        histdata.extend(extra_data)

    # uniq the records.
    histdata = list(set(histdata))

    # Sort by the date field, ascending.
    histdata = sorted(histdata, key=lambda x: x.split('|')[1].strip())

    # Save data.
    savefilename = f"{real_infile}.new"
    print(f"Writing {savefilename} ...")
    with open(f"{savefilename}", 'w') as f:
        f.write(''.join(histdata))

    # Now, move the files around.
    #  - infile -> infile.backup
    #  - outfile -> infile
    if args.overwrite:
        print(f"Moving {real_infile} to {real_infile}.backup ...")
        shutil.move(real_infile, f"{real_infile}.backup")
        print(f"Moving {savefilename} to {real_infile} ...")
        shutil.move(savefilename, real_infile)


if __name__ == "__main__":
    main()

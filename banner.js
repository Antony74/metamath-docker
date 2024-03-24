const greenBold = "\x1b[1;92m";
const noColor = "\x1b[0m";

console.log(
  [
    `${greenBold}`,
    `=========================================================================`,
    `Metamath command line tools (https://github.com/Antony74/metamath-docker)`,
    `=========================================================================`,
    ``,
    `Please find below, an example command for each of the tools provided here:`,
    `${noColor}`,
    `metamath "READ set.mm" "VERIFY PROOF *" "exit"`,
    `checkmmc set.mm`,
    `metamath-knife --verify set.mm`,
    `echo -e "LoadFile,set.mm\\nVerifyProof,*" > params.txt && mmj2 -f params.txt`,
    `python3 mmverify.py set.mm`,
    `hmmverify < demo0.mm`,
    `checkmm set.mm`,
    `prettier --write demo0.mm`,
    `alt-mm set.mm`,
    `cd /metamath-test && ./run-testsuite-all-drivers`,
    `${greenBold}`,
    `Prefix with ${noColor}time${greenBold} to measure how long a command took.`,
    `Put command in quotes and prefix with ${noColor}hyperfine -w 2 --${greenBold} to benchmark how long it takes.`,
    `${noColor}`,
  ].join("\n")
);

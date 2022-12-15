const greenBold = "\033[1;92m";
const noColor = "\033[0m";

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
    `${greenBold}`,
    `Prefix with ${noColor}time${greenBold} to measure how long a command took.`,
    `${noColor}`,
  ].join("\n")
);

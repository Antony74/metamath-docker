const fsp = require("fs/promises");

const greenBold = "\x1b[1;92m";
const noColor = "\x1b[0m";

const main = async () => {
  const verifierCommands = await fsp.readFile("verifier-commands", {
    encoding: "utf-8",
  });

  console.log(
    [
      `${greenBold}`,
      `=========================================================================`,
      `Metamath command line tools (https://github.com/Antony74/metamath-docker)`,
      `=========================================================================`,
      ``,
      `Please find below, an example command for each of the tools provided here:`,
      `${noColor}`,
      verifierCommands.trim(),
      `hmmverify < demo0.mm`,
      `prettier --write demo0.mm`,
      `alt-mm set.mm`,
      `./benchmark-all`,
      `cd /metamath-test && ./run-testsuite-all-drivers`,
      `${greenBold}`,
      `Prefix with ${noColor}time${greenBold} to measure how long a command took.`,
      `Put command in quotes and prefix with ${noColor}hyperfine -w 2 --${greenBold} to benchmark how long it takes.`,
      `${noColor}`,
    ].join("\n")
  );
};

main();

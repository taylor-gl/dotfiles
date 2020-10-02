#!/usr/bin/js

var readline = require("readline");
var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

// Load Hyphenopoly
const Hyphenopoly = require("./Hyphenopoly/hyphenopoly.module.js")
const hyphenator = Hyphenopoly.config({
    "require": ["en-us"],
    "hyphen": "­"
});

// Run hyphenation function on each line of stdin
rl.on("line", function(line) {
    hyphenator.then(
        function function_name(hyphenateText) {
            console.log(hyphenateText(line))
        }
    )
})

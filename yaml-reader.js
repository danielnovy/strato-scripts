#!/usr/bin/env node
var yaml = require("js-yaml");
var fs = require("fs");

var yamlFile = process.argv[2];
var section = process.argv[3];

var yamlString = fs.readFileSync(yamlFile, "utf8");
var yamlObj = yaml.safeLoad(yamlString);

if (section in yamlObj) {
    console.log(yamlObj[section].join(" "));
}

"use strict"

const path = require('path')
const cp = require('child_process')
const fs = require('fs')

module.exports = (req, context) => {
	let err;
	const tmpFile = path.join('/tmp', 'input', `${uuid()}.jsonnet`)

	// args
	let args = []
	if (typeof req.query.y !== 'undefined') {
		args = [...args, '-y']
	}
	if (typeof req.query.e !== 'undefined') {
		args = [...args, '-e']
	}
	// get body
	const body = req.body
	// save to a file name
	if (!fs.existsSync('/tmp/input')) {
		fs.mkdirSync('/tmp/input')
	}
	fs.writeFileSync(tmpFile, body, 'utf8')
	const command = [...args, tmpFile]
	const output = cp.spawnSync('jsonnet', command)
	context
		.status(200)
		.succeed(output.stdout.toString());
	fs.unlinkSync(tmpFile)
}

const uuid = () => {
  return 'xxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
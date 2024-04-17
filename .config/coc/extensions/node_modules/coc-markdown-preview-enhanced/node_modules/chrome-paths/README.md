# chrome-paths

[![npm version](https://img.shields.io/npm/v/chrome-paths.svg)](https://www.npmjs.com/package/chrome-paths)
[![Build Status](https://travis-ci.com/shinnn/chrome-paths.svg?branch=master)](https://travis-ci.com/shinnn/chrome-paths)

Possible paths or binary names of [Chrome](https://www.google.com/chrome/), [Chrome Canary](https://www.google.com/chrome/canary/) and [Chromium](https://www.chromium.org/Home) in the current platform

```javascript
const chromePaths = require('chrome-paths');

// On macOS

chromePaths.chrome; //=> '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
chromePaths.chromeCanary; //=> '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary'
chromePaths.chromium; //=> '/Applications/Chromium.app/Contents/MacOS/Chromium'

// On Linux

chromePaths.chrome; //=> 'google-chrome'
chromePaths.chromeCanary; //=> null
chromePaths.chromium; //=> 'chromium'

// On Windows

chromePaths.chrome; //=> 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
chromePaths.chromeCanary; //=> 'C:\\Program Files (x86)\\Google\\Chrome SxS\\Application\\chrome.exe'
chromePaths.chromium //=> 'C:\\Program Files (x86)\\Chromium\\Application\\chrome.exe'

// On Solaris

chromePaths.chrome; //=> null
chromePaths.chromeCanary; //=> null
chromePaths.chromium; //=> null
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/about-npm/).

```
npm install chrome-paths
```

## API

```javascript
const chromePaths = require('chrome-paths');
```

### chromePaths.chrome, chromePaths.chromeCanary, chromePaths.chromium

Type: `string` or `null`

```javascript
const {execFile} = require('child_process');
const {promisify} = require('util');
const {chrome, chromeCanary} = require('chrome-paths');

(async () => {
  (await promisify(execFile)(chrome, ['--version'])).stdout; //=> 'Google Chrome 71.0.3578.98 \n'
  (await promisify(execFile)(chromeCanary, ['--version'])).stdout; //=> 'Google Chrome 74.0.3689.0 canary\n'
})();
```

Whether each property is a full path, just a binary name or `null` depends on the current [platform](https://nodejs.org/api/process.html#process_process_platform).

## License

[ISC License](./LICENSE) © 2018 - 2019 Shinnosuke Watanabe

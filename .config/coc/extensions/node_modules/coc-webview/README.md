# coc-webview

Webview panel ported to coc.nvim

## Install

`:CocInstall coc-webview`

## Lists

`:CocList webview`

## Webview as API

Install the coc-webview to `devDependencies`

```typescript
// import only type
import type { WebviewAPI, WebviewPanel } from 'coc-webview';

// fetch API
let webviewExt: Extension<WebviewAPI> | undefined;

const getWebviewAPI = () => {
  if (!webviewExt) {
    webviewExt = extensions.all.find((ext) => ext.id === 'coc-webview') as Extension<WebviewAPI> | undefined;
  }
  if (!webviewExt) {
    const hint = 'Please install the coc-webview extension';
    void window.showErrorMessage(hint);
    throw new Error(hint);
  }
  return webviewExt.exports;
};

// create webview panel
export async function example(): Promise<void> {
  const panel = await getWebviewAPI().createWebviewPanel(
    // viewType
    'markdown-preview-enhanced',
    // title
    `Preview markdown`,
    {
      // open in browser
      openURL: true,
      // route name
      routeName: 'markdown-preview-enhanced',
    },
    {
      localResourceRoots: [...],
      enableScripts: true,
    }
  );

  // update title
  panel.title = 'Preview markdown-2'

  // update html
  panel.webview.html = '<html>...</html>'

  // postMessage
  panel.webview.postMessage({type: 'command', 'token': 'xxx'})

  this.onDidReceiveMessage((msg: {type: string, token: string}) => {
    // msg.type
  });

  cosnt util = getWebviewAPI().util;
  util.openUri('https://domain.com/');
}
```

## Configurations

Usage: https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file

- `webview.debug`: Enable debug mode
- `webview.colorStrategy`: Color strategy for webview
- `webview.primaryColors`: Primary colors for webview
- `webview.minPort`: Mix port for webview service
- `webview.maxPort`: Max port for webview service
- `webview.openCommand`: Command template for open webview, arguments(%u webview url), example: `chrome "%u"`

## TODO

- [x] dark mode
- [x] webview reveal
- [x] display iconPath
- [ ] vim keybinding
- [ ] cspSource

## License

MIT

---

> This extension is built with [create-coc-extension](https://github.com/fannheyward/create-coc-extension)

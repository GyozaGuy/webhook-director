const { app, Menu, Notification, Tray } = require('electron');
const path = require('path');
const { WebSocket } = require('ws');

const APP_ICON = path.join(__dirname, 'img', 'appicon.png');
let tray; // NOTE: This is defined here to prevent the tray icon from disappearing when this variable is garbage collected
let ws;

function createTray() {
  const menu = Menu.buildFromTemplate([{ click: () => app.exit(), label: 'Close' }]);
  tray = new Tray(APP_ICON);

  tray.setToolTip('Notifications');
  tray.setContextMenu(menu);
}

if (!app.requestSingleInstanceLock()) {
  app.exit();
}

function reconnect() {
  while (!ws) {
    ws = new WebSocket('ws://localhost:8080');
  }
}

app.on('ready', () => {
  ws = new WebSocket('ws://localhost:8080');

  ws.on('close', () => {
    reconnect();
  });

  ws.on('error', err => {
    console.error(err);
  });

  ws.on('message', message => {
    const json = JSON.parse(String(message));

    new Notification({
      body: json.content,
      icon: APP_ICON,
      title: `${json.source} :: ${json.title}`
    }).show();
  });

  createTray();
});

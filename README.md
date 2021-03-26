# Shift73k

Calendaring app for shift-worker shift tracking, with support for CSV export and sharing work schedule with others.

Written in Elixir & Phoenix LiveView, with Bootstrap v5.

## TODO

- [ ] Ability to edit shifts?
- [ ] Proper modal to delete shifts?
- [ ] Allow all-day items for notes, or require hours even for sick days?

## Deploying

### New versions

When improvements are made, we can update the deployed version like so:

```shell
cd /opt/shift73k
git pull 73k master
mix deps.get --only prod
MIX_ENV=prod mix compile
# might not be needed:
MIX_ENV=prod mix ecto.migrate
# rebuild static assets:
rm -rf priv/static/
npm run deploy --prefix ./assets
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --overwrite
# test starting it:
MIX_ENV=prod _build/prod/rel/shift73k/bin/shift73k start
```

### systemd unit:

```ini
[Unit]
Description=Shift73k service
After=local-fs.target network.target

[Service]
Type=simple
User=runuser
Group=runuser
WorkingDirectory=/opt/shift73k/_build/prod/rel/shift73k
ExecStart=/opt/shift73k/_build/prod/rel/shift73k/bin/shift73k start
ExecStop=/opt/shift73k/_build/prod/rel/shift73k/bin/shift73k stop
#EnvironmentFile=/etc/default/myApp.env
Environment=LANG=en_US.utf8
Environment=MIX_ENV=prod
#Environment=PORT=4000
LimitNOFILE=65535
UMask=0027
SyslogIdentifier=shift73k
Restart=always

[Install]
WantedBy=multi-user.target
```

### nginx config:

```conf
upstream phoenix {
  server 127.0.0.1:4000 max_fails=5 fail_timeout=60s;
}
server {
  location / {
    allow all;
    # Proxy Headers
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Cluster-Client-Ip $remote_addr;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_redirect off;
    # WebSockets
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass http://phoenix;
  }
}
```
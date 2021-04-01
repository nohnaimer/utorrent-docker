### Run via Docker CLI client

To run the utorrent container you can execute:

```bash
docker run                                            \
    --name utorrent                                   \
    -v /path/to/data/dir:/data                        \
    -p 8080:8080                                      \
    -p 6881:6881                                      \
    -p 6881:6881/udp                                  \
    nohnaimer/utorrent
```
Open a browser and point your to [http://docker-host:8080/gui](http://docker-host:8080/gui)

### Settings persistence

#### Dir on host machine
```bash
docker run                                            \
    --name utorrent                                   \
    -v /path/to/data/dir:/data                        \
    -v /path/to/setting/dir:/opt/utorrent/settings    \
    -p 8080:8080                                      \
    -p 6881:6881                                      \
    -p 6881:6881/udp                                  \
    nohnaimer/utorrent
```

#### Named volume
```bash
docker volume create utorrent-settings

docker run                                            \
    --name utorrent                                   \
    -v /path/to/data/dir:/data                        \
    -v utorrent-settings:/opt/utorrent/settings       \
    -p 8080:8080                                      \
    -p 6881:6881                                      \
    -p 6881:6881/udp                                  \
    nohnaimer/utorrent
```

### Configure
Almost all of these settings can be changed except:
- `bind_ip` - set as 0.0.0.0
- `dir_active`, `dir_completed` - /data
- `dir_torrent_files` - /opt/utorrent/torrents
- `dir_autoload` - /opt/utorrent/autoload
- `preferred_interface` - empty
- `randomize_bind_port` - false

```bash
docker run                                            \
    --name utorrent                                   \
    -v /path/to/data/dir:/data                        \
    -v /path/to/data/settings:/opt/utorrent/settings  \
    -v /path/to/data/torrents:/opt/utorrent/torrents  \
    -v /path/to/data/autoload:/opt/utorrent/autoload  \
    -p 8080:8080                                      \
    -p 6881:6881                                      \
    -p 6881:6881/udp                                  \
    nohnaimer/utorrent
```

## Run via Docker Compose

Create your Docker Compose file (docker-compose.yml) using the following YAML snippet:

```yaml
version: '3.7'
services:
  utorrent:
    image: nohnaimer/utorrent:<tag>
    volumes:
      - utorrent-settings:/utorrent/settings
      - /path/to/data/dir:/data
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  utorrent-settings:
```

## Changes
* 2021-04-01 Init commit.
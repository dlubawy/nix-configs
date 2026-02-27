# hostapd-roamer

A CLI tool for managing hostapd station roaming. Based on this [hostapd-roamer PHP script](https://github.com/anonymous-one/hostapd-roamer/tree/master).
This tool borrows code from the [hostapd tests/hwsim Python modules](https://git.w1.fi/cgit/hostap/tree/tests/hwsim) to create the main interfaces
for controlling hostapd.

This tool is very simple and will only work on a single AP right now. The premise is to
iterate through list of stations and check the current signal strength of the station on
the current AP. If the station has an extremely strong 2.4GHz signal then we most likely
want to roam to the 5GHz band. Conversely, if we have an extremely weak 5GHz signal then
we most likely want to roam to 2.4GHz. The notion is that a very strong 2.4GHz means
the station is likely close enough for a decent 5GHz signal, while the opposite means
we need a better overall signal.

The roaming uses hostapd `bss_tm_req` to tell the station which neighbor to roam to.
Neighbor lists are generated among a set of local hostapd interfaces passed to the
tool. Future improvement would be to set up a client/server process for different
APs to exchange neighbor information among each other.

## Configuration

Values can be provided to the tool to configure when a roam may be required,
how often to check stations, etc. These can be set at `~/.config/hostapd-roamer/config.ini`,
or another file passed to the CLI with `-c <my_conf.ini>`.

## Examples

- `hostapd-roamer --help`
- `hostapd-roamer -i wlan0,wlan1`
- `hostapd-roamer -c config.ini`

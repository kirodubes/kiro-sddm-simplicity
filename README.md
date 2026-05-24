<p align="center">
  <img src="kiro.jpg" alt="Kiro" width="220" />
</p>

# edu-sddm-simplicity

A clean, minimal SDDM (Simple Desktop Display Manager) login theme. Part of the `~/EDU/` learning series.

## What's in this repo

- `usr/share/sddm/themes/` — the SDDM theme assets that land in `/usr/share/sddm/themes/`.
- `etc/` — optional SDDM config drop-in to select the theme by default.
- `setup.sh`, `up.sh` — standard EDU bash scaffold.

## Companion variant

- [edu-sddm-simplicity-qt6](https://github.com/erikdubois/edu-sddm-simplicity-qt6) — Qt 6 version of the same theme.

## Installation

### From `nemesis_repo` (recommended)

```ini
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/$repo/$arch
```

```bash
sudo pacman -Syu
sudo pacman -S edu-sddm-simplicity
```

You'll also need SDDM itself:

```bash
sudo pacman -S sddm
sudo systemctl enable sddm.service
```

### Manual

```bash
git clone https://github.com/erikdubois/edu-sddm-simplicity.git
cd edu-sddm-simplicity
sudo cp -r usr/share/sddm/themes/. /usr/share/sddm/themes/
```

### Activate

Edit `/etc/sddm.conf` (or drop a file under `/etc/sddm.conf.d/`):

```ini
[Theme]
Current=simplicity
```

Then restart SDDM (or reboot) to see the new login screen.

## Websites

Information : https://erikdubois.be

## Social Media

Youtube : https://www.youtube.com/erikdubois

<!-- KIRO-FUNDING-FOOTER:START — managed by Kiro-HQ/cascade-readme-footer.sh -->
## Help fund Kiro

Everything I build here stays free and open — always. If Kiro or any of these
tools have ever saved you time or taught you something, a small monthly
contribution helps keep the work going. Donations target break-even, nothing
more — the core always stays free for everyone.

- GitHub Sponsors: https://github.com/sponsors/erikdubois
- Patreon: https://www.patreon.com/c/kiroproject
- YouTube memberships: https://www.youtube.com/@ErikDubois/join
- Ko-fi: https://ko-fi.com/erikdubois
- PayPal: https://www.paypal.me/erikdubois
<!-- KIRO-FUNDING-FOOTER:END -->

## License

See [LICENSE](./LICENSE).
